# FreeRTOS injection.
include(FetchContent)

add_library(freertos_config INTERFACE)
target_include_directories(freertos_config SYSTEM INTERFACE ${CMAKE_SOURCE_DIR}/inc)
target_compile_definitions(freertos_config INTERFACE projCOVERAGE_TEST=0)

FetchContent_Declare(FreeRTOS
    GIT_REPOSITORY https://github.com/FreeRTOS/FreeRTOS-Kernel.git
    GIT_TAG        main
)
FetchContent_MakeAvailable(FreeRTOS)

add_library(FreeRTOS)

target_sources(FreeRTOS PUBLIC
    ${freertos_SOURCE_DIR}/list.c
    ${freertos_SOURCE_DIR}/queue.c
    ${freertos_SOURCE_DIR}/tasks.c
    ${freertos_SOURCE_DIR}/timers.c
    ${freertos_SOURCE_DIR}/event_groups.c
    ${freertos_SOURCE_DIR}/stream_buffer.c
    ${freertos_SOURCE_DIR}/portable/MemMang/heap_4.c
    ${freertos_SOURCE_DIR}/portable/GCC/ARM_CM4F/port.c
)

target_include_directories(FreeRTOS PUBLIC
    ${freertos_SOURCE_DIR}/include
    ${freertos_SOURCE_DIR}/portable/GCC/ARM_CM4F
    ${CUBEF4_DIR}/Drivers/CMSIS/Include
    ${CUBEF4_DIR}/Drivers/CMSIS/Device/ST/STM32F4xx/Include
)

target_link_libraries(FreeRTOS PUBLIC freertos_config)
