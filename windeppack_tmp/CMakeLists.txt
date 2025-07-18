cmake_minimum_required(VERSION 3.22)

message("Getting meta-data from Conda external packages: ${SOFA_BUILD_RELEASE_CONDA_PACKAGES}")

find_package(PythonInterp REQUIRED)

execute_process(COMMAND ${PYTHON_EXECUTABLE} "${CMAKE_CURRENT_SOURCE_DIR}/get-conda-package-files.py"
  "headers"
  "${SOFA_BUILD_RELEASE_CONDA_PACKAGES}"
  OUTPUT_VARIABLE SOFA_CONDA_DEPS_HEADERS
  RESULT_VARIABLE SOFA_CONDA_DEPS_SUCCESS
)
if(NOT ${SOFA_CONDA_DEPS_SUCCESS} EQUAL 0)
    message(FATAL_ERROR "Failed to get Conda packages headers")
endif()

execute_process(COMMAND ${PYTHON_EXECUTABLE} "${CMAKE_CURRENT_SOURCE_DIR}/get-conda-package-files.py"
  "shared-libs"
  "${SOFA_BUILD_RELEASE_CONDA_PACKAGES}"
  OUTPUT_VARIABLE SOFA_CONDA_DEPS_SHARED_LIBS
  RESULT_VARIABLE SOFA_CONDA_DEPS_SUCCESS
)
if(NOT ${SOFA_CONDA_DEPS_SUCCESS} EQUAL 0)
    message(FATAL_ERROR "Failed to get Conda packages shared libraries")
endif()

execute_process(COMMAND ${PYTHON_EXECUTABLE} "${CMAKE_CURRENT_SOURCE_DIR}/get-conda-package-files.py"
  "static-libs"
  "${SOFA_BUILD_RELEASE_CONDA_PACKAGES}"
  OUTPUT_VARIABLE SOFA_CONDA_DEPS_STATIC_LIBS
  RESULT_VARIABLE SOFA_CONDA_DEPS_SUCCESS
)
if(NOT ${SOFA_CONDA_DEPS_SUCCESS} EQUAL 0)
    message(FATAL_ERROR "Failed to get Conda packages static libraries")
endif()

execute_process(COMMAND ${PYTHON_EXECUTABLE} "${CMAKE_CURRENT_SOURCE_DIR}/get-conda-package-files.py"
  "exec"
  "${SOFA_BUILD_RELEASE_CONDA_PACKAGES}"
  OUTPUT_VARIABLE SOFA_CONDA_DEPS_EXEC
  RESULT_VARIABLE SOFA_CONDA_DEPS_SUCCESS
)
if(NOT ${SOFA_CONDA_DEPS_SUCCESS} EQUAL 0)
    message(FATAL_ERROR "Failed to get Conda packages executables")
endif()

install(FILES ${SOFA_CONDA_DEPS_HEADERS} DESTINATION include/extlibs/WinDepPack COMPONENT headers)
install(FILES ${SOFA_CONDA_DEPS_SHARED_LIBS} DESTINATION bin COMPONENT applications)
install(FILES ${SOFA_CONDA_DEPS_STATIC_LIBS} DESTINATION lib COMPONENT libraries)
install(FILES ${SOFA_CONDA_DEPS_EXEC} DESTINATION bin COMPONENT applications)
# cmake config ? others ?
# TODO : try to copy directly everything to current dir (not using windeppack)
# install(FILES ${SOFA_CONDA_DEPS_FILES} DESTINATION .)
