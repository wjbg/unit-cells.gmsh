# Meshes: Quarter Fiber RVE Generation

This repository contains Gmsh scripts for generating Representative Volume Element (RVE) meshes of a quarter fiber in a square domain. It supports both structured (mapped) and unstructured (Delaunay) meshing strategies for 2D and 3D simulations.

## Project Structure

- `2D_structured_symmetric_quarter_fiber.geo`: High-quality transfinite (mapped) mesh. Symmetric distribution between top and right boundaries.
- `3D_structured_symmetric_quarter_fiber.geo`: Extruded version of the structured 2D mesh.
- `2D_unstructured_quarter_fiber.geo`: Unstructured mesh designed for flow simulations with local refinement in high-shear zones.
- `generate_meshes.sh`: Automation script for batch generating unstructured meshes across various volume fractions.
- `structured_symmetric_quarter_fiber.svg`: Visual representation of the geometry.

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
