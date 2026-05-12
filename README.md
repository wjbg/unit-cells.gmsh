# Meshes: Quarter Fiber RVE Generation

This repository contains Gmsh scripts for generating Representative Volume Element (RVE) meshes of a quarter fiber in a square domain. It supports both structured (mapped) and unstructured (Delaunay) meshing strategies for 2D and 3D simulations.

## Project Structure

### 1. Structured Symmetric Meshes
These files are designed for high-precision simulations where a perfectly regular, mapped mesh is required.
- **`2D_structured_symmetric_quarter_fiber.geo`**: 
    - **Strategy**: Uses `Transfinite` curves and surfaces.
    - **Symmetry**: The mesh distribution on the top boundary is a mirror image of the right boundary.
    - **Elements**: Primarily triangles (can be recombined into quadrilaterals by uncommenting the `Recombine` command).
- **`3D_structured_symmetric_quarter_fiber.geo`**: 
    - **Strategy**: Extrusion of the 2D structured face along the Z-axis.
    - **Layers**: Controlled by the `nz` parameter (default: 10).
    - **Volume**: Creates structured prisms/hexahedra.

### 2. Unstructured Flow Meshes
Designed specifically for fluid dynamics (CFD) where shear rates vary across the domain.
- **`2D_unstructured_quarter_fiber.geo`**:
    - **Strategy**: Unstructured Frontal-Delaunay algorithm.
    - **Refinement**: Features a dynamic gradient refinement. The mesh is finest at the narrowest gap (top-left) and coarsens as the gap increases (towards the right) and as you move away from the high-shear boundary.
    - **Physical Groups**:
        - `Top`: The top boundary where velocity is typically applied.
        - `Fiber`: The quarter-circle representing the fiber surface.
        - `Bottom`: The bottom domain boundary.
        - `Left`: The left domain boundary.
        - `Right`: The right domain boundary.
        - `Fluid_Domain`: The entire 2D surface.

### 3. Automation & Assets
- **`generate_meshes.sh`**: A utility script to sweep through different volume fractions (`vf`) while maintaining a constant number of elements (`n`) in the gap.
- **`structured_symmetric_quarter_fiber.svg`**: Geometric schematic of the RVE.

## Getting Started

### Prerequisites

- [Gmsh](https://gmsh.info/) (tested with version 4.15+)

### Generating Meshes

#### Manual Generation
To generate a 2D mesh manually:
```bash
gmsh -2 2D_unstructured_quarter_fiber.geo
```

To override parameters (e.g., Fiber Volume Fraction `vf` or number of elements in the gap `n`):
```bash
gmsh -2 2D_unstructured_quarter_fiber.geo -setnumber vf 0.5 -setnumber n 10 -o output.msh
```

#### Batch Generation
Use the provided bash script to generate a set of unstructured meshes for `vf = [0.4, 0.45, 0.5, 0.55, 0.6, 0.65]`:
```bash
./generate_meshes.sh [n]
```
Where `[n]` is an optional argument for the number of elements in the narrowest gap (default is 5).

## Key Parameters

- `R`: Radius of the fiber (3.5µm).
- `vf`: Fiber volume fraction. Determines the size of the domain.
- `n`: Target number of elements in the narrowest gap (unstructured only).
- `nz`: Number of layers in the Z-direction (3D only).

## License
Created by Gemini CLI for workspace orchestration.
