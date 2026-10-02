# EPITA Ani3D - Lab Code (2026-2027)

Source code for the lab sessions of the **EPITA Ani3D** course (3D Animation), year 2026-2027.

- Course page: https://graphicscomputing.fr/course/2026_2027/epita_ani3d/
- Lab exercises: https://graphicscomputing.fr/course/2026_2027/epita_ani3d/practice/

## Download

Each scene directory contains all the code needed to compile it, including the [CGP library](https://graphicscomputing.fr/cgp/documentation/) in its `cgp/` subdirectory.

```bash
git clone https://github.com/drohmer/epita_ani3d_lab_code-2027.git
```

or use the Github button "Code > Download ZIP".

## Compilation and Installation

Each scene (ex. `scenes_ani3d/00_introduction/`) is an independent project with its own `CMakeLists.txt`, `CMakePresets.json`, `Makefile` and `vscode.code-workspace`. The generated executable is named `project`. A C++17 compiler is required.

### Prerequisites

| Platform | Requirements |
|----------|-------------|
| **Windows** | [CMake](https://cmake.org/download/), [Visual Studio Community](https://visualstudio.microsoft.com/) (with "Desktop development with C++" module) |
| **Mac** | [CMake](https://cmake.org/download/), [VS Code](https://code.visualstudio.com/), [Homebrew](https://brew.sh/) |
| **Linux** | [CMake](https://cmake.org/download/), [VS Code](https://code.visualstudio.com/), build-essential, pkg-config, GLFW |

### Windows

1. Install CMake (enable "Add CMake to the system PATH" during setup).
2. Install Visual Studio Community with the **Desktop development with C++** module.
3. Navigate to the scene directory and run the generation script:
   ```
   scenes_ani3d/00_introduction/scripts/visual-studio-generate.bat
   ```
4. Open the generated `build/project.sln` in Visual Studio.
5. Compile and run using the "Local Windows Debugger" button.

> **Note:** The code directory path must not contain accents or spaces. When adding new `.cpp` files, re-run the generation script.

### Mac

1. Install dependencies:
   ```bash
   brew install cmake pkg-config ninja glfw
   ```
2. Build:
   ```bash
   cd scenes_ani3d/00_introduction
   mkdir build && cd build
   cmake ..
   make -j$(sysctl -n hw.ncpu)
   ./project
   ```

If GLFW is not found, edit `CMakeLists.txt` and set `MACOS_GLFW_PRECOMPILED` to `ON`, then open `cgp/third_party/glfw/macos/lib/libglfw.3.dylib` via Finder (right-click > Open) before recompiling.

### Linux (Ubuntu)

1. Install dependencies:
   ```bash
   sudo apt-get update
   sudo apt-get install build-essential pkg-config cmake libglfw3-dev
   ```
2. Build:
   ```bash
   cd scenes_ani3d/00_introduction
   mkdir build && cd build
   cmake ..
   make -j$(nproc)
   ./project
   ```

### Alternatives

Using the CMake presets (Ninja generator) from the scene directory:
```bash
cmake --preset relwithdebinfo
cmake --build build/relwithdebinfo
./project
```

Using the standalone `Makefile` (requires GLFW available via pkg-config):
```bash
cd scenes_ani3d/00_introduction
make -j$(nproc)
./project
```

### Editing Code

Open the `vscode.code-workspace` file at the root of each scene in VS Code. Select the **RelWithDebInfo** configuration for debug compilation.

## Lab Sessions

| Lab | Directory | Exercise |
|-----|-----------|----------|
| Introduction | `scenes_ani3d/00_introduction/` | [link](https://graphicscomputing.fr/course/2026_2027/epita_ani3d/practice/content/00_introduction/) |
| Procedural animation | `scenes_ani3d/01_procedural/` | [link](https://graphicscomputing.fr/course/2026_2027/epita_ani3d/practice/content/01_procedural_animation/) |
| Sphere collision | `scenes_ani3d/02_sphere_collision/` | [link](https://graphicscomputing.fr/course/2026_2027/epita_ani3d/practice/content/02_sphere_collision/) |
| Cloth simulation | `scenes_ani3d/03_cloth/` | [link](https://graphicscomputing.fr/course/2026_2027/epita_ani3d/practice/content/03_cloth/) |
| Shape matching | `scenes_ani3d/04_shape_matching/` | [link](https://graphicscomputing.fr/course/2026_2027/epita_ani3d/practice/content/04_shape_matching/) |
| Stable fluids | `scenes_ani3d/05_stable_fluids/` | [link](https://graphicscomputing.fr/course/2026_2027/epita_ani3d/practice/content/05_fluids/a_stable_fluids/) |
| SPH fluids | `scenes_ani3d/06_sph/` | [link](https://graphicscomputing.fr/course/2026_2027/epita_ani3d/practice/content/05_fluids/b_sph/) |
| Skinning | `scenes_ani3d/07_skinning/` | [link](https://graphicscomputing.fr/course/2026_2027/epita_ani3d/practice/content/06_character_animation/a_skinning/) |
| Character animation | `scenes_ani3d/08_character_animation/` | [link](https://graphicscomputing.fr/course/2026_2027/epita_ani3d/practice/content/06_character_animation/b_skeleton_animation/) |

## Examples

Additional standalone examples of the CGP library are available in `examples/` (each one with its own README):

| Example | Directory |
|---------|-----------|
| Transparent billboards | `examples/01_transparent_billboards/` |
| Marching cubes (simple, interactive) | `examples/02_marching_cubes/` |
| Shaders (vertex deformation, multiple textures) | `examples/03_shaders/` |
| Sketch of 2D curves | `examples/04_sketch/` |
| Skybox and environment mapping | `examples/05_environment_map/` |
| Multipass rendering (image filters, shadow mapping) | `examples/06_multipass/` |
| Cameras (fly mode, 2D displacement, multiple cameras) | `examples/07_camera/` |
| Instancing | `examples/08_instancing/` |
| Advanced obj mesh loading | `examples/09_mesh_loading/` |

> **Note:** The meshes of `examples/09_mesh_loading/` are provided as `.zip` files in its `assets/` directory: extract them in `assets/` before running the example.

## Links

* [Lab class exercises](https://graphicscomputing.fr/course/2026_2027/epita_ani3d/practice/)
* [Documentation on CGP library](https://graphicscomputing.fr/cgp/documentation/)
