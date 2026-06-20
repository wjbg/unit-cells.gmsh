/*
 * Gmsh script for generating a 2D unstructured mesh of a half-fiber square packing flow domain.
 *
 * This script defines a half-cell RVE containing a half-fiber on the top boundary.
 * Refinement is applied near the fiber boundary where shear rates are highest.
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
// For a half-cell of square packing (fiber on top boundary):
// W = P, H = P / 2, where P = R * Sqrt(Pi / vf)
P = R * Sqrt(Pi / vf); // Pitch (distance between fiber centers)
W = P;
H = P / 2;

// Dynamic Mesh Scaling
// The gap in this half cell is (H - R). We want n/2 elements there.
gap = H - R;
lc_refine = gap / (n / 2);
lc_global = lc_refine * 4; // Global size is 4x coarser than the gap refinement

// Default characteristic length for points
lc = lc_global;

// --- Geometry Definition ---

// Points
Point(1) = {0,     0,     0, lc}; // Bottom-left corner
Point(2) = {0,     H,     0, lc}; // Top-left corner
Point(3) = {W/2 - R, H,   0, lc}; // Start of top arc
Point(4) = {W/2,   H,     0, lc}; // Center of top arc
Point(5) = {W/2 + R, H,   0, lc}; // End of top arc
Point(6) = {W,     H,     0, lc}; // Top-right corner
Point(7) = {W,     0,     0, lc}; // Bottom-right corner

// --- Topology Definition ---

// Left boundary
Line(1) = {1, 2};

// Top boundary
Line(2) = {2, 3};
Circle(3) = {3, 4, 5};
Line(4) = {5, 6};

// Right boundary
Line(5) = {6, 7};

// Bottom boundary
Line(6) = {7, 1};

// Create the surface
Line Loop(1) = {1, 2, 3, 4, 5, 6};
Plane Surface(1) = {1};

// --- Mesh Refinement Gradient ---
// Field 1: Distance to the fiber boundary (Circle 3)
Field[1] = Distance;
Field[1].CurvesList = {3};
Field[1].Sampling = 100;

// Field 2: MathEval to scale element sizes from lc_refine near the fiber
// up to lc_global in the bulk fluid regions.
Field[2] = MathEval;
Field[2].F = Sprintf("min(%g, %g + F1 * 1.5)", lc_global, lc_refine);

// Use the MathEval field as the background field
Background Field = 2;

// --- Physical Groups ---
Physical Point("Top") = {2, 3, 5, 6};
Physical Point("Bottom") = {1, 7};
Physical Curve("Left") = {1};
Physical Curve("Top") = {2, 3, 4}; // Top flat parts + top fiber arc
Physical Curve("Right") = {5};
Physical Curve("Bottom") = {6};
Physical Surface("Fluid_Domain") = {1};

// --- Mesh Settings ---
Mesh.Algorithm = 6; // Frontal-Delaunay for 2D meshes
