/*
 * Gmsh script for generating a 2D structured rectangle mesh (reference geometry).
 *
 * Parameters:
 * - H: Height of the rectangle (default: 10 micrometers).
 * - W: Width of the rectangle (default: 0.1 * H).
 *
 */

// --- Parameters ---
H = 10E-6;       // Height of the rectangle [m]
W = 0.1 * H;     // Width of the rectangle [m]

// Mesh resolution parameters
If(!Exists(nx))
  nx = 5;        // Number of points along the width
EndIf
If(!Exists(ny))
  ny = 50;       // Number of points along the height
EndIf

lc = H / ny;     // Default characteristic length

// --- Geometry Definition ---
Point(1) = {0, 0, 0, lc}; // Bottom-left corner
Point(2) = {W, 0, 0, lc}; // Bottom-right corner
Point(3) = {W, H, 0, lc}; // Top-right corner
Point(4) = {0, H, 0, lc}; // Top-left corner

// --- Topology Definition ---
Line(1) = {1, 2}; // Bottom boundary
Line(2) = {2, 3}; // Right boundary
Line(3) = {3, 4}; // Top boundary
Line(4) = {4, 1}; // Left boundary

Line Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};

// --- Structured Mesh Configuration ---
Transfinite Curve{1, 3} = nx;
Transfinite Curve{2, 4} = ny;
Transfinite Surface{1} = {1, 2, 3, 4};

// Recombine triangles to generate a quadrilateral mesh
// Recombine Surface{1};

// --- Physical Groups ---
Physical Point("Top") = {3, 4};
Physical Point("Bottom") = {1, 2};
Physical Curve("Bottom") = {1};
Physical Curve("Right") = {2};
Physical Curve("Top") = {3};
Physical Curve("Left") = {4};
Physical Surface("Fluid_Domain") = {1};
