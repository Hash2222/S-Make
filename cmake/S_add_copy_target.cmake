function(S_add_copy_target)
    set(oneValArgs TARGET_NAME SOURCE DESTINATION TYPE MARK_AS_BYPRODUCTS)
    set(multiValArgs GLOB_PATTERNS)
    cmake_parse_arguments(ARG "" "${oneValArgs}" "${multiValArgs}" ${ARGN})

    # Default MARK_AS_BYPRODUCTS to OFF if not provided
    if(NOT DEFINED ARG_MARK_AS_BYPRODUCTS)
        set(ARG_MARK_AS_BYPRODUCTS OFF)
    endif()

    if(ARG_TYPE STREQUAL "DIRECTORY")
        file(GLOB_RECURSE _files RELATIVE "${ARG_SOURCE}" "${ARG_SOURCE}/*")
        set(_byproducts)
        foreach(_file IN LISTS _files)
            if(NOT IS_DIRECTORY "${ARG_SOURCE}/${_file}")
                list(APPEND _byproducts "${ARG_DESTINATION}/${_file}")
            endif()
        endforeach()

        # Conditionally include BYPRODUCTS
        if(ARG_MARK_AS_BYPRODUCTS)
            add_custom_target(${ARG_TARGET_NAME} ALL
                    COMMAND ${CMAKE_COMMAND} -E copy_directory
                    "${ARG_SOURCE}"
                    "${ARG_DESTINATION}"
                    BYPRODUCTS ${_byproducts}
                    COMMENT "Copying directory: ${ARG_SOURCE} -> ${ARG_DESTINATION}"
            )
        else()
            add_custom_target(${ARG_TARGET_NAME} ALL
                    COMMAND ${CMAKE_COMMAND} -E copy_directory
                    "${ARG_SOURCE}"
                    "${ARG_DESTINATION}"
                    COMMENT "Copying directory: ${ARG_SOURCE} -> ${ARG_DESTINATION}"
            )
        endif()

    elseif(ARG_TYPE STREQUAL "FILES")
        add_custom_target(${ARG_TARGET_NAME} ALL)
        set(_byproducts)
        foreach(_pattern IN LISTS ARG_GLOB_PATTERNS)
            file(GLOB_RECURSE _files "${_pattern}")
            foreach(_file IN LISTS _files)
                get_filename_component(_name "${_file}" NAME)
                set(_dest "${ARG_DESTINATION}/${_name}")
                list(APPEND _byproducts "${_dest}")

                # Conditionally include BYPRODUCTS in custom command
                if(ARG_MARK_AS_BYPRODUCTS)
                    add_custom_command(TARGET ${ARG_TARGET_NAME} POST_BUILD
                            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                            "${_file}"
                            "${_dest}"
                            BYPRODUCTS "${_dest}"
                            COMMENT "Copying ${_name} to ${ARG_DESTINATION}"
                    )
                else()
                    add_custom_command(TARGET ${ARG_TARGET_NAME} POST_BUILD
                            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                            "${_file}"
                            "${_dest}"
                            COMMENT "Copying ${_name} to ${ARG_DESTINATION}"
                    )
                endif()
            endforeach()
        endforeach()

        # Conditionally set target-level BYPRODUCTS property
        if(ARG_MARK_AS_BYPRODUCTS)
            set_target_properties(${ARG_TARGET_NAME} PROPERTIES BYPRODUCTS "${_byproducts}")
        endif()
    endif()

    add_dependencies(${PROJECT_NAME} ${ARG_TARGET_NAME})
endfunction()