
cmake_minimum_required(VERSION 3.21)
project(mango-context-menu LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets)
find_package(LayerShellQt REQUIRED)

qt_standard_project_setup()

qt_add_executable(mango-context-menu main.cpp)

target_link_libraries(mango-context-menu PRIVATE
    Qt6::Widgets
    LayerShellQt::Interface
)

install(TARGETS mango-context-menu
    RUNTIME DESTINATION bin
)
