# STM libraries for STM32F407 target.

include(FetchContent)

FetchContent_Declare(stm32cubef4
    GIT_REPOSITORY https://github.com/STMicroelectronics/STM32CubeF4.git
    GIT_TAG        master
)
FetchContent_MakeAvailable(stm32cubef4)

add_library(stm32_hal STATIC)

file(GLOB STM32_HAL_SOURCES
    ${stm32cubef4_SOURCE_DIR}/Drivers/STM32F4xx_HAL_Driver/Src/*.c
)

target_sources(stm32_hal PRIVATE ${STM32_HAL_SOURCES})

target_include_directories(stm32_hal PUBLIC
    ${CMAKE_SOURCE_DIR}/inc
    ${stm32cubef4_SOURCE_DIR}/Drivers/CMSIS/Include
    ${stm32cubef4_SOURCE_DIR}/Drivers/CMSIS/Device/ST/STM32F4xx/Include
    ${stm32cubef4_SOURCE_DIR}/Drivers/STM32F4xx_HAL_Driver/Inc
)

target_compile_definitions(stm32_hal PUBLIC
    -DSTM32F407xx
    -DUSE_HAL_DRIVER
)

function(AddSTLinkTarget TARGET)
    # Convert ELF to binary
    add_custom_command(
        OUTPUT ${TARGET}.bin
        COMMAND ${CMAKE_OBJCOPY} -O binary ${TARGET}.elf ${TARGET}.bin
        DEPENDS ${TARGET}
        COMMENT "Generating binary from ELF"
        VERBATIM
    )

    add_custom_target(${TARGET}-bin ALL DEPENDS ${TARGET}.bin)

    # Flash with st-flash
    add_custom_target(${TARGET}-stlink-flash
        COMMAND st-flash write ${TARGET}.bin 0x8000000
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        DEPENDS ${TARGET}-bin
        COMMENT "Flashing ${TARGET}.bin using st-flash"
        VERBATIM
    )

    add_custom_target(${TARGET}-stlink-openocd
      bash -c "openocd -f /usr/local/share/openocd/scripts/interface/stlink.cfg \
                -f /usr/share/openocd/scripts/target/stm32f4x.cfg \
                -c 'reset_config none; program ${TARGET}.elf verify reset exit'"
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      DEPENDS ${TARGET}
      VERBATIM
    )
endfunction()