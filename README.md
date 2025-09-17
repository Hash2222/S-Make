# S-Make

S-Make is a custom CMake Module that provides a set of utility functions to decrease the severity of your CMake PTSD by approximately 50%. All functions and variables are prefixed with `S_` to avoid conflicts with other CMake code.

---

## Features

- Automatic runtime linkage configuration for MSVC and GCC/Clang.
- Vcpkg triplet generation and toolchain detection.
- Compiler optimization and Windows subsystem configuration.
- Automatic copying of dependencies and asset directories.
- Simplifies repetitive CMake boilerplate in modern C++ projects.
- All of these features are mostly compiler-independent.

---

## Usage

- Add S-Make to your project:

```cmake
add_subdirectory(lib/S_Make)
```

- Call the S-Make functions as needed to configure runtime linkage, vcpkg, optimizations, and asset copying.

---

## Functions

### `S_generate_runtime_linkage_options(<PROJECT_NAME> <OPTION>)`

**Purpose:** Generates runtime linkage options for the project.

**Parameters:**

- `<PROJECT_NAME>`: The target project name.
- `<OPTION>`: `ON` or `OFF` to enable or disable generation.

**Outputs (global variables):**

- `S_MSVC_RUNTIME_LINKAGE` — runtime linkage for MSVC.
- `S_GCC_CLANG_RUNTIME_LINKAGE` — runtime linkage for GCC/Clang.

**Example:**

```cmake
S_generate_runtime_linkage_options(MyProject OFF)
```

---

### `S_generate_vcpkg_triplet(<OUTPUT_VAR> <PROJECT_NAME> LINK_TYPE <static|shared> MSVC_RUNTIME_LINKAGE <VALUE>)`

**Purpose:** Generates a Vcpkg triplet for the current project and build environment.

**Parameters:**

- `<OUTPUT_VAR>`: Variable to store the generated triplet.
- `<PROJECT_NAME>`: Name of the project.
- `LINK_TYPE`: `static` or `shared` linking.
- `MSVC_RUNTIME_LINKAGE`: Use the previously generated `S_MSVC_RUNTIME_LINKAGE`.

**Example:**

```cmake
S_generate_vcpkg_triplet(
    VCPKG_TARGET_TRIPLET MyProject
    LINK_TYPE static
    MSVC_RUNTIME_LINKAGE ${S_MSVC_RUNTIME_LINKAGE}
)
```

---

### `S_detect_vcpkg_toolchain(<OUTPUT_VAR>)`

**Purpose:** Detects the Vcpkg toolchain file path and stores it in the provided variable.

**Parameters:**

- `<OUTPUT_VAR>`: Variable to hold the path to the toolchain file.

**Example:**

```cmake
S_detect_vcpkg_toolchain(VCPKG_TOOLCHAIN_FILE)
include(${VCPKG_TOOLCHAIN_FILE})
```

---

### `S_set_runtime_linkage_options(<PROJECT_NAME> <MSVC_RUNTIME> <GCC_CLANG_RUNTIME>)`

**Purpose:** Sets runtime linkage options for a target.

**Parameters:**

- `<PROJECT_NAME>`: Target project name.
- `<MSVC_RUNTIME>`: Runtime linkage for MSVC.
- `<GCC_CLANG_RUNTIME>`: Runtime linkage for GCC/Clang.

**Example:**

```cmake
S_set_runtime_linkage_options(
    MyProject
    ${S_MSVC_RUNTIME_LINKAGE}
    ${S_GCC_CLANG_RUNTIME_LINKAGE}
)
```

---

### `S_set_release_optimizations(<TARGET_ARCH> <ARCH_OPTION>)`

**Purpose:** Configures compiler optimizations for release builds.

**Parameters:**

- `<TARGET_ARCH>`: Optional, MSVC target architecture for the /arch:\<TARGET_ARCH\> optimization.

**Example:**

```cmake
S_set_release_optimizations(MSVC_TARGET_ARCH "AVX512")
```

---

### `S_set_windows_subsystem(<PROJECT_NAME>)`

**Purpose:** Configures the Windows subsystem for the target to allow usage of `WinMain` and prevent a terminal window from appearing with a GUI application.

**Parameters:**

- `<PROJECT_NAME>`: Target project name.

**Note:** Use pre-processor instructions to conditionally compile `WinMain`, as only `main` works on other operating systems.

**Example:**

```cmake
S_set_windows_subsystem(MyProject)
```

---

### `S_add_copy_target(TARGET_NAME <name> DESTINATION <path> TYPE <FILES|DIRECTORY> [SOURCE <source_path>] GLOB_PATTERNS <patterns> MARK_AS_BYPRODUCTS ON)`

**Purpose:** Creates a custom copy target for assets or shared libraries.

**Parameters:**

- `TARGET_NAME`: Name of the copy target.
- `DESTINATION`: Destination directory.
- `TYPE`: Either `FILES` or `DIRECTORY`. `FILES` will copy all files from the `GLOB_PATTERNS` directly to the `DESTINATION` directory, `DIRECTORY` will copy the directory itself from the `SOURCE` to the `DESTINATION` directory.
- `SOURCE`: Source directory (required for `DIRECTORY` type).
- `GLOB_PATTERNS`: Glob patterns for matching files (used with `FILES` type).
- `MARK_AS_BYPRODUCTS`: Optional, marks files as `BYPRODUCTS` for them to be deleted when you clean.

**Example (copy DLLs):**

```cmake
S_add_copy_target(
    TARGET_NAME copy_dependencies
    DESTINATION "${CMAKE_BINARY_DIR}"
    TYPE FILES
    GLOB_PATTERNS "${CMAKE_BINARY_DIR}/vcpkg_installed/*/bin/*.dll"
    MARK_AS_BYPRODUCTS ON
)
```

**Example (copy assets directory):**

```cmake
S_add_copy_target(
    TARGET_NAME copy_assets
    SOURCE "${CMAKE_SOURCE_DIR}/assets"
    DESTINATION "${CMAKE_BINARY_DIR}/assets"
    TYPE DIRECTORY
    MARK_AS_BYPRODUCTS ON
)
```

---

## License

S-Make is provided as-is under the fact that you can do anything you want with it, who knew avoiding CMake torture could be free, as in freedom.
