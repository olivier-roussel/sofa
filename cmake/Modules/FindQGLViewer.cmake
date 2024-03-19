# Find the QGLViewer headers and libraries
# Behavior is to first look for config files.
# If no config files were found, tries to find
# the library by looking at headers / lib file.
#
# Defines:
#   QGLViewer_FOUND : True if QGLViewer is found
#
# Provides target QGLViewer.

message("======= entering QGLviewer find module ======")
message("======= trying QGLViewer in config mode... ======")
find_package(QGLViewer NO_MODULE QUIET)
message("======= trying QGLViewer in config mode DONE ======")

if(TARGET QGLViewer)
  message("======= QGLViewer found in config mode ======")
else()
  message("======= QGLViewer NOT found in config mode ======")
  message("======= trying to find qglviewer.h in suffix: include/QGViewer ======")

  if(NOT QGLViewer_INCLUDE_DIR)
    find_path(QGLViewer_INCLUDE_DIR
      NAMES qglviewer.h
      PATH_SUFFIXES include/QGLViewer
    )
  endif()
  message("======= found: QGLViewer_INCLUDE_DIR = ${QGLViewer_INCLUDE_DIR} ======")

  message("======= trying to find qglviewer.h in suffix: include/QGViewer ======")
  if(NOT QGLViewer_LIBRARY)
    find_library(QGLViewer_LIBRARY
      NAMES QGLViewer QGLViewer-qt5
      PATH_SUFFIXES lib
    )
  endif()
  message("======= found: QGLViewer_LIBRARY = ${QGLViewer_LIBRARY} ======")

  if(QGLViewer_INCLUDE_DIR AND QGLViewer_LIBRARY)
    message("======= found lib and include -> QGLlib found ======")
    set(QGLViewer_FOUND TRUE)
  else()
    if(QGLViewer_FIND_REQUIRED)
      message(FATAL_ERROR "Cannot find QGLViewer")
    endif()
  endif()

  # Same checks as Sofa.GUI.Qt
  # i.e find Qt5, then if not, Qt6, then if not error
  find_package(Qt5 COMPONENTS Core QUIET)
  if (NOT Qt5Core_FOUND)
      if(${CMAKE_VERSION} VERSION_GREATER "3.16.0")
          find_package(Qt6 COMPONENTS Core CoreTools QUIET)
      endif()
  endif()

  if (Qt5Core_FOUND)
      find_package(Qt5 COMPONENTS Core Charts Gui Xml OpenGL Widgets REQUIRED)
      set(QT_TARGETS Qt5::Core Qt5::Charts Qt5::Gui Qt5::Xml Qt5::OpenGL Qt5::Widgets)
  elseif (Qt6Core_FOUND)
      find_package(Qt6 COMPONENTS Gui Charts GuiTools Widgets WidgetsTools OpenGLWidgets Xml REQUIRED)
      set(QT_TARGETS ${QT_TARGETS} Qt::Core Qt::Charts Qt::Gui Qt::Widgets Qt::OpenGLWidgets Qt::Xml)
  endif()

  if(QGLViewer_FOUND)
    set(QGLViewer_LIBRARIES ${QGLViewer_LIBRARY})
    set(QGLViewer_INCLUDE_DIRS ${QGLViewer_INCLUDE_DIR})

    if(NOT QGLViewer_FIND_QUIETLY)
      message(STATUS "Found QGLViewer: ${QGLVIEWER_LIBRARIES}")
    endif(NOT QGLViewer_FIND_QUIETLY)

    if(NOT TARGET QGLViewer)
      add_library(QGLViewer INTERFACE IMPORTED)
      set_property(TARGET QGLViewer PROPERTY INTERFACE_LINK_LIBRARIES "${QGLViewer_LIBRARIES}" ${QT_TARGETS})
      set_property(TARGET QGLViewer PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${QGLViewer_INCLUDE_DIR}")
    endif()
  endif()
  mark_as_advanced(QGLViewer_INCLUDE_DIR QGLViewer_LIBRARY)
endif()
