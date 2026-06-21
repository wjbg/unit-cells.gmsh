/*
 * Gmsh script for generating a mirrored 2D mesh with two quarter fibers.
 * One fiber at bottom-left, one at top-left.
 */

// --- Parameters ---
R = 3.5E-6;

If(!Exists(vf))
  vf = 0.65;
EndIf

If(!Exists(n))
  n = 5;
EndIf

// --- Calculated Parameters ---
W = Sqrt(Pi*R*R/4/vf);
H = W;
Htot = 2*H;

// Gap now identical top and bottom
lc_refine = (H - R) / n;
lc_global = lc_refine * 4;

// --- Geometry Definition ---

// Domain corners
Point(1) = {0,    0, 0, lc_global};        // Bottom-left corner + center of lower fiber
Point(2) = {W,    0, 0, lc_global};        // Bottom-right corner
Point(3) = {W, Htot, 0, lc_global};        // Top-right corner
Point(4) = {0, Htot, 0, lc_refine};        // Top-left corner + center of upper fiber

// Lower fiber arc
Point(5) = {R, 0, 0, lc_global};
Point(6) = {0, R, 0, lc_refine};

// Upper fiber arc
Point(7)  = {R, Htot, 0, lc_global};
Point(8) = {0, Htot - R, 0, lc_refine};

// Boundary
Circle(1) = {6, 1, 5}; // bottom fiber
Line(2) = {5, 2};      // bottom
Line(3) = {2, 3};      // right
Line(4) = {3, 7};      // top
Circle(5) = {7, 4, 8};  // top fiber
Line(6) = {8, 6};      // left


// Surface loop
Line Loop(1) = {1, 2, 3, 4, 5, 6};
Plane Surface(1) = {1};

// // --- Mesh field (reuse logic, symmetric) ---

// Field[1] = Distance;
// Field[1].CurvesList = {2, 8}; // top and bottom edges
// Field[1].Sampling = 100;

// Field[2] = MathEval;
// Field[2].F = Sprintf(
//   "min(%g, %g + (x/%g)*(%g-%g) + F1*1.5)",
//   lc_global, lc_refine, W, lc_global, lc_refine
// );

// Background Field = 2;

// --- Physical Groups ---

// Bottom: bottom edge + lower fiber arc + corner points
Physical Point("Bottom") = {6, 5, 2};
Physical Curve("Bottom") = {1, 2};

// Top: top edge + upper fiber arc + corner points
Physical Point("Top") = {3, 7, 8};
Physical Curve("Top") = {4, 5};

Physical Curve("Left") = {6};
Physical Curve("Right") = {3};

Physical Surface("Fluid_Domain") = {1};

// --- Mesh Settings ---
Mesh.Algorithm = 6;
