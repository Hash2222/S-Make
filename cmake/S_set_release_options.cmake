# Enable optimizations for non-debug builds
function(S_set_release_optimizations)
    # Optional parameters with default values
    set(options ENABLE_AGGRESSIVE_OPTS)
    set(oneValueArgs MSVC_TARGET_ARCH)  # Only for MSVC
    set(multiValueArgs EXTRA_COMPILE_OPTS EXTRA_LINK_OPTS)
    cmake_parse_arguments(OPT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Enable optimizations for non-debug builds
    if(NOT CMAKE_BUILD_TYPE MATCHES Debug)
        if(MSVC)
            # MSVC flags
            message(STATUS "Configuring MSVC release optimizations...")

            set(MSVC_COMPILE_OPTS
                    /O2          # maximize speed
                    /Ob2         # inline any suitable function
                    /Ot          # favor speed
                    /Oi          # intrinsic functions
                    /Oy          # omit frame pointers
                    /GL          # whole program optimization
                    /fp:precise  # safe floating-point
            )

            # Add target architecture if specified, otherwise use default
            if(OPT_MSVC_TARGET_ARCH)
                list(APPEND MSVC_COMPILE_OPTS /arch:${OPT_MSVC_TARGET_ARCH})
            else()
                # Default to AVX2 if not specified
                list(APPEND MSVC_COMPILE_OPTS /arch:AVX2)
            endif()

            # Add aggressive options if requested
            if(OPT_ENABLE_AGGRESSIVE_OPTS)
                list(APPEND MSVC_COMPILE_OPTS
                        /fp:fast       # aggressive floating-point optimizations
                        /GS-           # disable buffer security checks
                )
            endif()

            # Add any extra compile options
            if(OPT_EXTRA_COMPILE_OPTS)
                list(APPEND MSVC_COMPILE_OPTS ${OPT_EXTRA_COMPILE_OPTS})
            endif()

            add_compile_options(${MSVC_COMPILE_OPTS})

            # Enable link-time code generation for release builds
            set(LINKER_OPTS /LTCG)
            if(OPT_EXTRA_LINK_OPTS)
                list(APPEND LINKER_OPTS ${OPT_EXTRA_LINK_OPTS})
            endif()

            set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} ${LINKER_OPTS}" PARENT_SCOPE)
            set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} ${LINKER_OPTS}" PARENT_SCOPE)

        elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
            # GCC/Clang flags
            message(STATUS "Configuring GCC/Clang release optimizations...")

            set(GCC_COMPILE_OPTS
                    -O3           # max optimization
                    -march=native # target local CPU (auto-detected)
                    -flto         # link-time optimization
                    -funroll-loops # loop unrolling
                    -fomit-frame-pointer # omit frame pointers
                    -ffast-math    # safe fast math
            )

            # Add aggressive options if requested
            if(OPT_ENABLE_AGGRESSIVE_OPTS)
                list(APPEND GCC_COMPILE_OPTS
                        -Ofast          # ignores strict standard compliance
                        -funsafe-math-optimizations
                        -funroll-all-loops
                        -fstrict-aliasing
                        -ffp-contract=fast
                )
            endif()

            # Add any extra compile options
            if(OPT_EXTRA_COMPILE_OPTS)
                list(APPEND GCC_COMPILE_OPTS ${OPT_EXTRA_COMPILE_OPTS})
            endif()

            add_compile_options(${GCC_COMPILE_OPTS})

            # Link-time optimization for GCC/Clang
            set(LINKER_OPTS -flto)
            if(OPT_EXTRA_LINK_OPTS)
                list(APPEND LINKER_OPTS ${OPT_EXTRA_LINK_OPTS})
            endif()

            set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} ${LINKER_OPTS}" PARENT_SCOPE)
            set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} ${LINKER_OPTS}" PARENT_SCOPE)

        endif()
    endif()
endfunction()

function(S_set_windows_subsystem target_name)
    if(WIN32)
        set_target_properties(${target_name} PROPERTIES
                LINK_FLAGS "/SUBSYSTEM:WINDOWS"
        )
    endif()
endfunction()