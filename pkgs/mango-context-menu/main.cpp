#include <QAction>
#include <QApplication>
#include <QCoreApplication>
#include <QDir>
#include <QEvent>
#include <QFont>
#include <QFontMetrics>
#include <QGuiApplication>
#include <QIcon>
#include <QJsonDocument>
#include <QJsonObject>
#include <QKeyEvent>
#include <QMenu>
#include <QMouseEvent>
#include <QPainter>
#include <QPixmap>
#include <QProxyStyle>
#include <QStyleOptionMenuItem>
#include <QProcess>
#include <QScreen>
#include <QWidget>

#include <LayerShellQt/Window>

#include <algorithm>
#include <iostream>
#include <optional>
#include <string>
#include <unistd.h>

namespace {

struct CursorLocation {
    QPoint position;
    QString monitorName;
};

std::optional<CursorLocation> getCursorLocation()
{
    QProcess process;
    process.start(QStringLiteral("mmsg"),
                  {QStringLiteral("get"), QStringLiteral("cursorpos")});

    if (!process.waitForFinished() ||
        process.exitStatus() != QProcess::NormalExit ||
        process.exitCode() != 0) {
        std::cerr << "mango-context-menu: failed to get MangoWM cursor position\n";
        return std::nullopt;
    }

    QJsonParseError parseError;
    const QJsonDocument document =
        QJsonDocument::fromJson(process.readAllStandardOutput(), &parseError);

    if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
        std::cerr << "mango-context-menu: invalid cursor position response from mmsg\n";
        return std::nullopt;
    }

    const QJsonObject object = document.object();
    const QJsonValue x = object.value(QStringLiteral("x"));
    const QJsonValue y = object.value(QStringLiteral("y"));
    const QJsonValue monitor = object.value(QStringLiteral("monitor"));

    if (!x.isDouble() || !y.isDouble() || !monitor.isString() ||
        monitor.toString().isEmpty()) {
        std::cerr << "mango-context-menu: cursor response is missing coordinates or monitor\n";
        return std::nullopt;
    }

    return CursorLocation{
        QPoint(qRound(x.toDouble()), qRound(y.toDouble())),
        monitor.toString(),
    };
}

QScreen *findScreen(const QString &monitorName)
{
    for (QScreen *screen : QGuiApplication::screens()) {
        if (screen->name() == monitorName)
            return screen;
    }

    std::cerr << "mango-context-menu: no Qt screen matches MangoWM monitor '"
              << monitorName.toStdString() << "'\n";
    return nullptr;
}

QPoint menuPosition(const QPoint &globalCursor,
                    const QRect &screenGeometry,
                    const QSize &menuSize)
{
    const int maxX = std::max(0, screenGeometry.width() - menuSize.width());
    const int maxY = std::max(0, screenGeometry.height() - menuSize.height());

    const int x = std::clamp(globalCursor.x() - screenGeometry.x(), 0, maxX);
    const int y = std::clamp(globalCursor.y() - screenGeometry.y(), 0, maxY);

    return {x, y};
}

void configureLayerShell(QWidget &overlay, QScreen *screen)
{
    overlay.setScreen(screen);
    overlay.setGeometry(QRect(QPoint(0, 0), screen->geometry().size()));

    // Create the native Wayland surface before assigning its layer-shell role.
    overlay.winId();

    auto *layer = LayerShellQt::Window::get(overlay.windowHandle());
    layer->setScope("mango-context-menu");
    layer->setScreen(screen);
    layer->setLayer(LayerShellQt::Window::LayerOverlay);
    layer->setAnchors({
        LayerShellQt::Window::AnchorTop,
        LayerShellQt::Window::AnchorBottom,
        LayerShellQt::Window::AnchorLeft,
        LayerShellQt::Window::AnchorRight,
    });
    layer->setMargins(QMargins(0, 0, 0, 0));
    // A negative exclusive zone requests the full output area, including reserved areas.
    layer->setExclusiveZone(-1);
    layer->setKeyboardInteractivity(
        LayerShellQt::Window::KeyboardInteractivityExclusive);
}

void configureIconThemePaths()
{
    QStringList paths = QIcon::themeSearchPaths();
    const QStringList dataDirs =
        qEnvironmentVariable("XDG_DATA_DIRS")
            .split(QLatin1Char(':'), Qt::SkipEmptyParts);

    for (const QString &dataDir : dataDirs) {
        const QString iconDir = QDir(dataDir).filePath(QStringLiteral("icons"));
        if (QDir(iconDir).exists() && !paths.contains(iconDir))
            paths.append(iconDir);
    }

    QIcon::setThemeSearchPaths(paths);
}

bool isEmoji(const QString &text)
{
    for (uint codepoint : text.toUcs4()) {
        if ((codepoint >= 0x1F000 && codepoint <= 0x1FAFF) ||
            (codepoint >= 0x2600 && codepoint <= 0x27BF) ||
            (codepoint >= 0x2300 && codepoint <= 0x23FF)) {
            return true;
        }
    }

    return false;
}

class FallbackIconMenuStyle final : public QProxyStyle {
public:
    explicit FallbackIconMenuStyle(QStyle *baseStyle = nullptr)
        : QProxyStyle(baseStyle)
    {
    }

    void drawControl(ControlElement element,
                     const QStyleOption *option,
                     QPainter *painter,
                     const QWidget *widget = nullptr) const override
    {
        if (element != CE_MenuItem || !option || !painter || !widget) {
            QProxyStyle::drawControl(element, option, painter, widget);
            return;
        }

        const auto *menuOption =
            qstyleoption_cast<const QStyleOptionMenuItem *>(option);
        const auto *menu = qobject_cast<const QMenu *>(widget);
        if (!menuOption || !menu) {
            QProxyStyle::drawControl(element, option, painter, widget);
            return;
        }

        QAction *fallbackAction = nullptr;
        for (QAction *candidate : menu->actions()) {
            if (candidate->text() == menuOption->text &&
                candidate->property("fallbackGlyph").isValid()) {
                fallbackAction = candidate;
                break;
            }
        }

        const QString glyph = fallbackAction
            ? fallbackAction->property("fallbackGlyph").toString()
            : QString();
        if (glyph.isEmpty()) {
            QProxyStyle::drawControl(element, option, painter, widget);
            return;
        }

        QStyleOptionMenuItem adjusted(*menuOption);
        adjusted.icon = QIcon();
        QProxyStyle::drawControl(element, &adjusted, painter, widget);

        const int extent = pixelMetric(PM_SmallIconSize, &adjusted, widget);
        const QRect glyphRect(adjusted.rect.left() + 7, // Nobody knows why 7
                              adjusted.rect.center().y() - extent / 2,
                              extent, extent);
        const QPalette::ColorRole role =
            adjusted.state & State_Selected
                ? QPalette::HighlightedText
                : QPalette::Text;

        QFont font(QStringLiteral("Symbols Nerd Font"));
        font.setPixelSize(isEmoji(glyph) ? 16 : 24);

        painter->save();
        painter->setFont(font);
        painter->setPen(adjusted.palette.color(role));
        painter->drawText(glyphRect, Qt::AlignCenter, glyph);
        painter->restore();
    }
};

class ContextOverlay final : public QWidget {
public:
    ContextOverlay(QScreen *screen,
                   const QPoint &globalCursor,
                   const QStringList &options,
                   std::optional<QString> &selection)
        : QWidget(nullptr),
          m_selection(selection)
    {
        setObjectName(QStringLiteral("ContextMenuOverlay"));
        setWindowTitle(QStringLiteral("ContextMenuOverlay"));
        setWindowFlags(Qt::FramelessWindowHint);
        setAttribute(Qt::WA_TranslucentBackground);
        setAttribute(Qt::WA_NoSystemBackground);
        setFocusPolicy(Qt::StrongFocus);

        configureLayerShell(*this, screen);
        createMenu(screen, globalCursor, options);
    }

protected:
    void mousePressEvent(QMouseEvent *event) override
    {
        // Clicks outside the child menu dismiss the overlay.
        close();
        event->accept();
    }

    bool eventFilter(QObject *watched, QEvent *event) override
    {
        if (watched == m_menu && event->type() == QEvent::KeyPress) {
            const auto *keyEvent = static_cast<QKeyEvent *>(event);
            if (keyEvent->key() == Qt::Key_Escape) {
                close();
                return true;
            }
        }

        return QWidget::eventFilter(watched, event);
    }

private:
    void createMenu(QScreen *screen,
                    const QPoint &globalCursor,
                    const QStringList &options)
    {
        // Keep QMenu inside the overlay to avoid creating a separate Wayland popup.
        m_menu = new QMenu(this);
        m_menu->setWindowFlags(Qt::Widget);
        m_menu->setFocusPolicy(Qt::StrongFocus);
        m_menu->setStyle(new FallbackIconMenuStyle(m_menu->style()));

        for (const QString &option : options) {
            // Syntax: "icon-name|Label". Without '|', the argument is plain text.
            const qsizetype separator = option.indexOf(QLatin1Char('|'));
            QString label = option;
            QIcon icon;

            if (separator >= 0) {
                const QString iconName = option.left(separator);
                label = option.mid(separator + 1);
                if (!iconName.isEmpty()) {
                    icon = QIcon::fromTheme(iconName);

                    if (icon.isNull()) {
                        // Reserve the standard icon slot; the menu style draws the
                        // fallback glyph itself using the current state color.
                        icon = QIcon(QPixmap(24, 24));
                    }
                }
            }

            QAction *action = m_menu->addAction(icon, label);
            if (separator >= 0) {
                const QString iconName = option.left(separator);
                if (!iconName.isEmpty() && QIcon::fromTheme(iconName).isNull())
                    action->setProperty("fallbackGlyph", iconName);
            }
            connect(action, &QAction::triggered, this, [this, label] {
                m_selection = label;
                close();
                QCoreApplication::quit();
            });
        }

        m_menu->adjustSize();
        const QSize menuSize = m_menu->sizeHint();
        const QPoint position =
            menuPosition(globalCursor, screen->geometry(), menuSize);
        m_menu->setGeometry(QRect(position, menuSize));
        m_menu->installEventFilter(this);
    }

    QMenu *m_menu = nullptr;
    std::optional<QString> &m_selection;
};

void printUsage(const char *program)
{
    std::cerr << "Usage: " << program << " OPTION [OPTION ...]\n"
              << "       command | " << program << "\n"
              << "Show a menu at the cursor and print the selected option to stdout.\n"
              << "Use \"icon-name|Label\" to display a system theme icon.\n"
              << "Arguments without '|' are displayed as plain text.\n"
              << "With no arguments, read one option per line from stdin when piped.\n"
              << "Escape or clicking outside the menu cancels the selection.\n";
}

} // namespace

int main(int argc, char *argv[])
{
    qputenv("QT_QPA_PLATFORM", "wayland");
    QApplication app(argc, argv);
    configureIconThemePaths();

    QStringList options;
    for (int i = 1; i < argc; ++i) {
        const QString option = QString::fromUtf8(argv[i]);
        if (option == QStringLiteral("--help") || option == QStringLiteral("-h")) {
            printUsage(argv[0]);
            return 0;
        }
        if (option.isEmpty()) {
            std::cerr << "mango-context-menu: options must not be empty\n";
            return 2;
        }
        options.append(option);
    }

    // With no arguments, accept newline-delimited options from a pipe.
    // Avoid blocking when launched interactively without arguments.
    if (options.isEmpty()) {
        if (isatty(STDIN_FILENO)) {
            printUsage(argv[0]);
            return 2;
        }

        std::string line;
        while (std::getline(std::cin, line)) {
            if (line.empty())
                continue;

            options.append(QString::fromUtf8(
                line.data(), static_cast<qsizetype>(line.size())));
        }

        if (std::cin.bad()) {
            std::cerr << "mango-context-menu: failed to read options from stdin\n";
            return 2;
        }
    }

    if (options.isEmpty()) {
        std::cerr << "mango-context-menu: no options provided\n";
        return 2;
    }

    const auto cursor = getCursorLocation();
    if (!cursor)
        return 1;

    QScreen *screen = findScreen(cursor->monitorName);
    if (!screen)
        return 1;

    std::optional<QString> selection;
    ContextOverlay overlay(screen, cursor->position, options, selection);
    overlay.show();
    overlay.raise();
    overlay.activateWindow();

    app.exec();

    if (!selection)
        return 1;

    // stdout contains only the selected option, suitable for shell command substitution.
    std::cout << selection->toStdString() << '\n';
    return 0;
}
