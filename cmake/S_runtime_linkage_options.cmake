function(S_generate_runtime_linkage_options TARGET_NAME STATICALLY_LINK_RUNTIME)
    set(S_MSVC_RUNTIME_LINKAGE "NONE" PARENT_SCOPE)
    set(S_GCC_CLANG_RUNTIME_LINKAGE "NONE" PARENT_SCOPE)

    if(STATICALLY_LINK_RUNTIME)
        if(MSVC)
            if(CMAKE_BUILD_TYPE STREQUAL "Debug")
                set(S_MSVC_RUNTIME_LINKAGE "/MTd" PARENT_SCOPE)
            else()
                set(S_MSVC_RUNTIME_LINKAGE "/MT" PARENT_SCOPE)
            endif()
        else()
            # GCC / Clang
            if (${S_CLANG_USE_LIBCXX})
                # Use static libc++ and dependencies
                message(STATUS "Statically linking to libc++ due to S_CLANG_USE_LIBCXX being set to ON and STATICALLY_LINK_RUNTIME being set to ON too.\nIf it fails, try installing libc++ or setting S_CLANG_USE_LIBCXX to OFF.")
                set(S_GCC_CLANG_RUNTIME_LINKAGE
                        -Wl,-Bstatic
                        -lc++
                        -lc++abi
                        -lunwind
                        -Wl,-Bdynamic
                        PARENT_SCOPE
                )
            else()
                set(S_GCC_CLANG_RUNTIME_LINKAGE -static-libgcc -static-libstdc++ PARENT_SCOPE)
            endif()
        endif()
    else()
        if(MSVC)
            if(CMAKE_BUILD_TYPE STREQUAL "Debug")
                set(S_MSVC_RUNTIME_LINKAGE "/MDd" PARENT_SCOPE)
            else()
                set(S_MSVC_RUNTIME_LINKAGE "/MD" PARENT_SCOPE)
            endif()
        else()
            if (${S_CLANG_USE_LIBCXX})
                # Use dynamic libc++ and dependencies
                message(STATUS "Dynamically linking to libc++ due to S_CLANG_USE_LIBCXX being set to ON and STATICALLY_LINK_RUNTIME being set to OFF too.\nIf it fails, try installing libc++ or setting S_CLANG_USE_LIBCXX to OFF.")
                set(S_GCC_CLANG_RUNTIME_LINKAGE
                    -Wl,-Bdynamic
                    -lc++
                    -lc++abi
                    -lunwind
                    PARENT_SCOPE)
            else()
                set(S_GCC_CLANG_RUNTIME_LINKAGE "NONE" PARENT_SCOPE)
            endif()
        endif()
    endif()
endfunction()

function(S_set_runtime_linkage_options TARGET_NAME S_MSVC_RUNTIME_LINKAGE S_GCC_CLANG_RUNTIME_LINKAGE)
    if(MSVC)
        if(NOT ${S_MSVC_RUNTIME_LINKAGE} STREQUAL "NONE")
            target_compile_options(${TARGET_NAME} PRIVATE ${S_MSVC_RUNTIME_LINKAGE})
        else()
            message(STATUS "S_MSVC_RUNTIME_LINKAGE is set to NONE, skipping target_compile_options.")
        endif()
    else()
        if(NOT ${S_GCC_CLANG_RUNTIME_LINKAGE} STREQUAL "NONE")
            target_link_options(${TARGET_NAME} PRIVATE ${S_GCC_CLANG_RUNTIME_LINKAGE})
        else()
            message(STATUS "S_GCC_CLANG_RUNTIME_LINKAGE is set to NONE, skipping target_link_options. This usually happens when you do not want to statically link the runtime on GCC/Clang, but can lead to an error sometimes.")
        endif()
    endif()
endfunction()
