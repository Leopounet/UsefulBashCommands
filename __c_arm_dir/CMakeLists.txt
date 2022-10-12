cmake_minimum_required (VERSION 2.8.12)
project (APP)

# VARIABLES

set(FULL_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/")
set(REL_SRC_DIR "src/")
set(C_FILES "")

# allows to loop through all subdirectories

MACRO(SUBDIRLIST result curdir)
FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
SET(dirlist "")
FOREACH(child ${children})
	IF(IS_DIRECTORY ${curdir}/${child})
	LIST(APPEND dirlist ${child})
	ENDIF()
ENDFOREACH()
SET(${result} ${dirlist})
ENDMACRO()

# get all SRC sub directories

SUBDIRLIST(SUBDIRS ${FULL_SRC_DIR})

# get all .c files

FILE(GLOB files ${REL_SRC_DIR}/*.c)
list(APPEND C_FILES ${files})
FILE(GLOB files ${REL_SRC_DIR}/*.h)
list(APPEND C_FILES ${files})

FOREACH(sd ${SUBDIRS})
	FILE(GLOB files ${REL_SRC_DIR}${sd}/*.c)
	list(APPEND C_FILES ${files})
	FILE(GLOB files ${REL_SRC_DIR}${sd}/*.h)
	list(APPEND C_FILES ${files})
ENDFOREACH()

message(STATUS "Files: ")
FOREACH(file ${C_FILES})
	message("		${file}")
ENDFOREACH()

add_custom_target(build COMMAND arm-linux-gnueabi-gcc -mthumb -mcpu=cortex-m3 -march=armv7-m -nostdlib -o main ${C_FILES}
						COMMAND arm-linux-gnueabi-objdump -lSd main > main.s)
