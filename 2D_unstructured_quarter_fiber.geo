/*
 * Gmsh script for generating a 2D unstructured mesh of a quarter fiber flow domain.
 *
 * This script defines a quarter-fiber RVE for fluid flow simulations.
 * Refinement is applied to the top boundary where shear rates are expected to be highest.
 *
 * Parameters:
 * - R: Radius of the fiber.
 * - vf: Fiber volume fraction (controls the domain width W).
 * - lc_global: Global characteristic length scale for the mesh.
 * - lc_refine: Finer characteristic length scale for the top boundary.
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
W = Sqrt(Pi*R*R/4/vf);  // Width/Height of the domain
H = W;

// Dynamic Mesh Scaling
// The narrowest gap is (H - R). We want n elements there.
lc_refine = (H - R) / n;
lc_global = lc_refine * 4; // Global size is 4x coarser than the gap refinement

// --- Geometry Definition ---

// Center of the fiber arc
Point(1) = {0, 0, 0, lc_global};

// Points on the domain boundary
Point(2) = {0, H, 0, lc_refine}; // Top-left corner (Finest)
Point(3) = {W, H, 0, lc_global}; // Top-right corner (Allowed to be coarser)
Point(4) = {W, 0, 0, lc_global}; // Bottom-right corner

// Points defining the fiber arc (quarter circle)
Point(5) = {R, 0, 0, lc_global}; // Start of arc
Point(6) = {0, R, 0, lc_refine}; // End of arc

// --- Topology Definition ---

// Outer boundaries and symmetry lines
Line(1) = {6, 2}; // Left edge
Line(2) = {2, 3}; // Top edge (Velocity BC)
Line(3) = {3, 4}; // Right edge
Line(4) = {4, 5}; // Bottom edge

// Fiber boundary
Circle(5) = {5, 1, 6};

// Create the surface
Line Loop(1) = {1, 2, 3, 4, 5};
Plane Surface(1) = {1};

// --- Mesh Refinement Gradient ---
// We want the mesh to be fine near the top edge, but only at small X.
// As X increases, the gap between the fiber and the top edge increases,
// so the mesh can become coarser.

// Field 1: Distance to the top edge (Line 2)
Field[1] = Distance;
Field[1].CurvesList = {2};
Field[1].Sampling = 100;

// Field 2: MathEval to create a size gradient based on X and distance to top edge.
// Size increases with X and with distance from the top edge.
Field[2] = MathEval;
Field[2].F = Sprintf("min(%g, %g + (x/%g)*(%g-%g) + F1*1.5)", lc_global, lc_refine, W, lc_global, lc_refine);

// Use the MathEval field as the background field
Background Field = 2;

// --- Physical Groups ---
Physical Point("Top") = {2, 3};
Physical Point("Bottom") = {4, 5, 6};
Physical Curve("Top") = {2};
Physical Curve("Bottom") = {4, 5};
Physical Curve("Left") = {1};
Physical Curve("Right") = {3};
Physical Surface("Fluid_Domain") = {1};

// --- Mesh Settings ---
Mesh.Algorithm = 6; // Frontal-Delaunay for 2D meshes
