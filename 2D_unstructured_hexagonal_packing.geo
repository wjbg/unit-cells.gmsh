/*
 * Gmsh script for generating a 2D unstructured mesh of a hexagonal packing flow domain.
 *
 * This script defines a reduced (quarter-cell) unit cell for a hexagonal fiber packing arrangement.
 * The cell contains two quarter-fibers at opposite corners (bottom-right and top-left),
 * which represents a quarter of the full periodic unit cell.
 * Refinement is applied near the fiber boundaries where high shear rates are expected.
 *
 * Parameters:
 * - R: Radius of the fiber.
 * - vf: Fiber volume fraction (controls the domain width W and height H).
 * - n: Target number of elements in the narrowest gap.
 *
 */

// --- Parameters ---
R = 3.5E-6;      // Radius of the fiber [m]

// Allow vf to be set from the command line (-setnumber vf 0.65)
If(!Exists(vf))
  vf = 0.65;     // Default Fiber volume fraction
EndIf

// Target number of elements in the narrowest section (gap)
If(!Exists(n))
  n = 5;         // Default: 5 elements in the gap
EndIf

// --- Calculated Parameters ---
// For hexagonal packing, the volume fraction is:
// vf = (2 * Pi * R^2) / (W_full * H_full) where H_full = W_full * Sqrt(3)
// Here we use a quarter of the full cell: W = W_full / 2, H = H_full / 2
P = Sqrt(2 * Pi * R * R / (Sqrt(3) * vf)); // Pitch (distance between fiber centers)
W = P / 2;
H = P * Sqrt(3) / 2;

// Dynamic Mesh Scaling
// The narrowest gap distance between the fiber centers is P - 2*R.
// We want n elements in this gap.
gap = P - 2 * R;
lc_refine = gap / n;
lc_global = lc_refine * 4; // Global size is 4x coarser than the gap refinement

// Default characteristic length for points
lc = lc_global;

// --- Geometry Definition ---

// Points
Point(1) = {0,     0,     0, lc}; // Bottom-left corner
Point(2) = {W - R, 0,     0, lc}; // Start of bottom-right arc
Point(3) = {W,     0,     0, lc}; // Center of bottom-right arc (corner)
Point(4) = {W,     R,     0, lc}; // End of bottom-right arc

Point(5) = {W,     H,     0, lc}; // Top-right corner
Point(6) = {R,     H,     0, lc}; // Start of top-left arc
Point(7) = {0,     H,     0, lc}; // Center of top-left arc (corner)
Point(8) = {0,     H - R, 0, lc}; // End of top-left arc

// --- Topology Definition ---

// Bottom boundary
Line(1) = {1, 2};
Circle(2) = {2, 3, 4};

// Right boundary
Line(3) = {4, 5};

// Top boundary
Line(4) = {5, 6};
Circle(5) = {6, 7, 8};

// Left boundary
Line(6) = {8, 1};

// Create the surface
Line Loop(1) = {1, 2, 3, 4, 5, 6};
Plane Surface(1) = {1};

// --- Mesh Refinement Gradient ---
// Field 1: Distance to the fiber boundaries (Circles 2 and 5)
Field[1] = Distance;
Field[1].CurvesList = {2, 5};
Field[1].Sampling = 100;

// Field 2: MathEval to scale element sizes from lc_refine near the fibers
// up to lc_global in the bulk fluid regions.
Field[2] = MathEval;
Field[2].F = Sprintf("min(%g, %g + F1 * 0.5)", lc_global, lc_refine);

// Use the MathEval field as the background field
Background Field = 2;

// --- Physical Groups ---
Physical Point("Top") = {5, 6, 8};
Physical Point("Bottom") = {1, 2, 4};
Physical Curve("Bottom") = {1, 2};
Physical Curve("Right") = {3};
Physical Curve("Top") = {4, 5};
Physical Curve("Left") = {6};
Physical Surface("Fluid_Domain") = {1};

// --- Mesh Settings ---
Mesh.Algorithm = 6; // Frontal-Delaunay for 2D meshes
