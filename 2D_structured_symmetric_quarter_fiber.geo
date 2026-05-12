/*
 * Gmsh script for generating a 2D structured, symmetric mesh of a quarter fiber in a unit cell.
 *
 * This script defines the geometry and meshing parameters for a representative
 * volume element (RVE) containing a quarter of a circular fiber. The domain
 * is subdivided into several surfaces to allow for a high-quality transfinite
 * quadrilateral mesh. The layout is symmetric, ensuring the top boundary
 * distribution mirrors the right boundary.
 *
 * Parameters:
 * - R: Radius of the fiber.
 * - vf: Fiber volume fraction (controls the domain width W).
 * - phi: Geometric parameter controlling the internal subdivision points.
 *
 */


// --- Parameters ---

// Geometry
R = 3.5E-6;   // Radius of the fiber [um]
vf = 0.65;    // Fiber volume fraction
phi = 0.7;    // Vary this value to change the size of the square

// Mesh density parameters
nn = 7;                 // Number of points on radial/vertical divisions
nn_sq = 5;               // Number of points on the internal square boundary
                         // Roughly nn/1.4
nn_arc = nn + 1 - nn_sq; // Remaining points for the arc transition
n1 = 7;                 // Points for first sector
n2 = 5;                 // Points for second sector
n3 = 10;                 // Points for third/transition sector

// Calculated parameters
W = Sqrt(Pi*R*R/4/vf);  // Width of the domain (calculated from volume fraction)
H = W;                  // Height of the domain
d = W*(1-phi) + (phi/2)*Sqrt(2)*R;  // Intermediate coordinate for transition points

L = W;                  // Length of the domain (for 3D extrusion)
lc = W/10;              // Default characteristic length (transfinite overrides this)

// Sector angles control meshing distribution along the arc
s1 = Pi/16;
s2 = Pi/8;

// --- Geometry Definition ---

// Points on the outer boundary and transition zones
Point(1) = {0, H, 0, lc};             // Top-left corner
Point(2) = {H*Tan(s1), H, 0, lc};      // Top boundary transition 1
Point(3) = {R*Sin(s1), R*Cos(s1), 0, lc}; // Fiber arc transition 1
Point(4) = {0, R, 0, lc};             // Top-left point of fiber arc

Point(5) = {H*Tan(s2), H, 0, lc};      // Top boundary transition 2
Point(6) = {R*Sin(s2), R*Cos(s2), 0, lc}; // Fiber arc transition 2

Point(7) = {d, H, 0, lc};             // Top transition to outer square
Point(8) = {d, d, 0, lc};             // Internal transition point (square corner)
Point(9) = {Sqrt(2)*R/2, Sqrt(2)*R/2, 0, lc}; // 45-degree point on fiber arc

Point(10) = {W, H, 0, lc};            // Top-right corner
Point(11) = {W, d, 0, lc};            // Right boundary transition
Point(12) = {W, W*Tan(s2), 0, lc};    // Right boundary transition 2
Point(13) = {R*Cos(s2), R*Sin(s2), 0, lc}; // Fiber arc transition 3

Point(14) = {W, W*Tan(s1), 0, lc};    // Right boundary transition 1
Point(15) = {R*Cos(s1), R*Sin(s1), 0, lc}; // Fiber arc transition 4

Point(16) = {W, 0, 0, lc};            // Bottom-right corner
Point(17) = {R, 0, 0, lc};            // Bottom-right point of fiber arc

Point(19) = {0, 0, 0, 0};             // Center of the fiber (for arc definitions)

// --- Topology Definition (Lines & Surfaces) ---

Line(1) = {1, 2};  // First sector (top-left)
Line(2) = {2, 3};
Circle(3) = {3, 19, 4};
Line(4) = {4, 1};
Line Loop(51) = {1, 2, 3, 4};

Line(5) = {2, 5};  // Second sector
Line(6) = {5, 6};
Circle(7) = {6, 19, 3};
Line Loop(52) = {5, 6, 7, -2};

Line(8) = {5, 7};  // Third sector (transition to square corner)
Line(9) = {7, 8};
Line(10) = {8, 9};
Circle(11) = {9, 19, 6};
Line Loop(53) = {8, 9, 10, 11, -6};

Line(12) = {7, 10};  // Top-right corner square
Line(13) = {10, 11};
Line(14) = {11, 8};
Line Loop(54) = {12, 13, 14, -9};

Line(15) = {11, 12}; // Right sector transition
Line(16) = {12, 13};
Circle(17) = {13, 19, 9};
Line Loop(55) = {15, 16, 17, -10, -14};

Line(18) = {12, 14}; // Right sector
Line(19) = {14, 15};
Circle(20) = {15, 19, 13};
Line Loop(56) = {18, 19, 20, -16};

Line(21) = {14, 16}; // Bottom-right sector
Line(22) = {16, 17};
Circle(23) = {17, 19, 15};
Line Loop(57) = {21, 22, 23, -19};

// Define Surfaces from Loops
Plane Surface(61) = {51};
Plane Surface(62) = {52};
Plane Surface(63) = {53};
Plane Surface(64) = {54};
Plane Surface(65) = {55};
Plane Surface(66) = {56};
Plane Surface(67) = {57};

// --- Mesh Configuration ---

// Setup Transfinite (structured) meshing for all surfaces
Transfinite Curve{1, 3} = n1;  // Sector 1
Transfinite Curve{2, 4} = nn;
Transfinite Surface{61} = {1, 2, 3, 4};

Transfinite Curve{5, 7} = n2;  // Sector 2
Transfinite Curve{6} = nn;
Transfinite Surface{62} = {2, 5, 6, 3};

Transfinite Curve{8, -11} = n3 Using Progression 1.05; // Sector 3 (refined towards fiber)
Transfinite Curve{9} = nn_sq;
Transfinite Curve{10} = nn_arc;
Transfinite Surface{63} = {6, 5, 7, 9};

Transfinite Curve{12, 13, 14} = nn_sq; // Top-right corner
Transfinite Surface{64} = {7, 10, 11, 8};

Transfinite Curve{-15, 17} = n3 Using Progression 1.05; // Transition sector
Transfinite Curve{16} = nn;
Transfinite Surface{65} = {9, 11, 12, 13};

Transfinite Curve{18, 20} = n2; // Right sector
Transfinite Curve{19} = nn;
Transfinite Surface{66} = {12, 14, 15, 13};

Transfinite Curve{21, 23} = n1; // Bottom-right sector
Transfinite Curve{22} = nn;
Transfinite Surface{67} = {15, 14, 16, 17};

// Make a quadrilateral 2D mesh
// Recombine Surface{61, 62, 63, 64, 65, 66, 67};
