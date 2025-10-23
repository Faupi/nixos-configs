// Dynamic window opacity (Plasma 6)
// Runs as a single instance under KWin's script manager.

const ACTIVE_OPACITY = 0.85;
const INACTIVE_OPACITY = 0.75;
const MAXIMIZED_OPACITY = 0.95;
const FULLSCREEN_OPACITY = 1.0;

function eligible(w) {
  return w && !w.deleted && !w.internal && !w.specialWindow;
}

function isFullyMaximized(w) {
  try {
    const g = w.frameGeometry; // QRectF
    if (!g) return false;
    const area = workspace.clientArea(KWin.MaximizeArea, w); // QRectF
    const tol = 1; // px tolerance
    return (
      Math.abs(g.x - area.x) <= tol &&
      Math.abs(g.y - area.y) <= tol &&
      Math.abs(g.width - area.width) <= tol &&
      Math.abs(g.height - area.height) <= tol
    );
  } catch (_) {
    return false;
  }
}

function windowState(w) {
  if (!w) return "windowed";
  if (w.fullScreen) return "fullscreen";
  if (isFullyMaximized(w)) return "maximized";
  return "windowed";
}

function desiredOpacity(w) {
  if (!eligible(w)) return null;
  const state = windowState(w);
  if (state === "fullscreen") return FULLSCREEN_OPACITY;
  if (state === "maximized") return MAXIMIZED_OPACITY;
  return w === workspace.activeWindow ? ACTIVE_OPACITY : INACTIVE_OPACITY;
}

const hooked = new Set();

function apply(w) {
  try {
    const want = desiredOpacity(w);
    if (want == null) return;
    if (w.opacity !== want) w.opacity = want; // qreal 0..1
  } catch (e) {
    print("apply error:", e);
  }
}

function applyAll() {
  const list = workspace.stackingOrder || [];
  for (let i = 0; i < list.length; ++i) apply(list[i]);
}

function hookWindow(w) {
  if (!eligible(w) || hooked.has(w)) return;
  hooked.add(w);

  const H = w.__opacityHandlers || (w.__opacityHandlers = {});
  H.onFSChanged = H.onFSChanged || (() => apply(w));
  H.onGeomChanged = H.onGeomChanged || (() => apply(w));
  H.onMaxChanged = H.onMaxChanged || (() => apply(w));
  H.onShown = H.onShown || (() => apply(w));
  H.onHidden = H.onHidden || (() => apply(w));
  H.onOpacityCh = H.onOpacityCh || (() => apply(w));
  H.onDesksCh = H.onDesksCh || (() => applyAll());

  try {
    if (w.fullScreenChanged) w.fullScreenChanged.connect(H.onFSChanged);
    if (w.frameGeometryChanged) w.frameGeometryChanged.connect(H.onGeomChanged);
    if (w.maximizedChanged) w.maximizedChanged.connect(H.onMaxChanged);
    if (w.windowShown) w.windowShown.connect(H.onShown);
    if (w.windowHidden) w.windowHidden.connect(H.onHidden);
    if (w.opacityChanged) w.opacityChanged.connect(H.onOpacityCh);
    if (w.desktopsChanged) w.desktopsChanged.connect(H.onDesksCh);
  } catch (e) {
    print("hook connect error:", e);
  }

  apply(w);
}

function unhookWindow(w) {
  if (!w || !hooked.has(w)) return;
  const H = w.__opacityHandlers || {};
  try {
    if (w.fullScreenChanged && H.onFSChanged)
      w.fullScreenChanged.disconnect(H.onFSChanged);
    if (w.frameGeometryChanged && H.onGeomChanged)
      w.frameGeometryChanged.disconnect(H.onGeomChanged);
    if (w.maximizedChanged && H.onMaxChanged)
      w.maximizedChanged.disconnect(H.onMaxChanged);
    if (w.windowShown && H.onShown) w.windowShown.disconnect(H.onShown);
    if (w.windowHidden && H.onHidden) w.windowHidden.disconnect(H.onHidden);
    if (w.opacityChanged && H.onOpacityCh)
      w.opacityChanged.disconnect(H.onOpacityCh);
    if (w.desktopsChanged && H.onDesksCh)
      w.desktopsChanged.disconnect(H.onDesksCh);
  } catch (_) {}
  hooked.delete(w);
  w.__opacityHandlers = null;
}

function init() {
  const list = workspace.stackingOrder || [];
  for (let i = 0; i < list.length; ++i) hookWindow(list[i]);

  workspace.windowAdded.connect((w) => {
    hookWindow(w);
    apply(w);
  });
  workspace.windowRemoved.connect((w) => {
    unhookWindow(w);
  });

  workspace.windowActivated.connect((w) => {
    // Simple: recalc everything on focus change
    applyAll();
    if (w) apply(w);
  });

  if (workspace.desktopsChanged) workspace.desktopsChanged.connect(applyAll);
  if (workspace.screensChanged) workspace.screensChanged.connect(applyAll);

  applyAll();
  print("window-opacity: initialized");
}

init();
