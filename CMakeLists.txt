## Main build file for Demo Project.
##
## STM32 Chip is handled my STM32 HAL libraries. Both libraries and FreeRTOS are fetched during build.

cmake_minimum_required(VERSION 3.16)

# Sets required toolchain for STM32 targets. Must be provided before project name.
set(CMAKE_TOOLCHAIN_FILE cmake/toolchain-arm-none-eabi-gcc.cmake)
set(FREERTOS_PORT GCC_ARM_CM4F CACHE STRING "")
set(GDB gdb-multiarch)

option(BUILD_DEBUG "Build with debug info" ON)
# Set the build type based on the option
if(BUILD_DEBUG)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
else()
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

project(
    CortexSTM32F407VGT_FreeRTOS_Demo VERSION 0.1.0 
    LANGUAGES CXX C ASM
)

include(cmake/FreeRTOS.cmake)
include(cmake/stm32.cmake)

add_executable(${PROJECT_NAME}
    # Local
    src/main.cpp

    # FreeRTOS Function Bindings
    src/freeRTOS.c

    # STM32 specific
    stm32/startup_stm32f4xx.s
    stm32/system_stm32f4xx.c
    stm32/syscalls.c
    stm32/stm32f4xx_it.c
)

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_SOURCE_DIR}/inc)
target_link_libraries(${PROJECT_NAME} stm32_hal FreeRTOS)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)

# Linking against required memory layout.
target_link_options(${PROJECT_NAME} PRIVATE -T${CMAKE_SOURCE_DIR}/linker/stm32f4.ld)

# Flashing tool.
AddSTLinkTarget(${PROJECT_NAME})

# Dissasemble target
add_custom_target(objdump
    COMMAND ${CMAKE_OBJDUMP} -d $<TARGET_FILE:${PROJECT_NAME}> > ${PROJECT_NAME}.disasm
    DEPENDS ${PROJECT_NAME}
    COMMENT "Disassembling ${PROJECT_NAME} to ${PROJECT_NAME}.disasm"
)

# Custom target to start st-util in background and launch GDB
add_custom_target(
    debug
    COMMAND st-util &
    COMMAND sleep 2
    COMMAND ${GDB} ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}.elf -ex "target remote localhost:4242" -ex "load" -ex "b main" -ex "monitor reset halt" -ex "continue" -ex "layout src"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    USES_TERMINAL
)
