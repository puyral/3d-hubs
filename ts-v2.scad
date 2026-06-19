include <BOSL2/std.scad>
// --- Customizable Parametric Hub ---

/* [Basics] */
// Diameter of the tubes (in mm)
tube_diameter = 5.6; 
// Length of each branch extending from the center (in mm, including the tip)
branch_length = 45.0; 
// Size of the central intersection block (in mm)
hub_diameter = 24.0;  
// Auto rotate for impression (also removes the bottom of the hub)
auto_rotate = true;

/* [Matrix Parameters] */
// Enable grid matrix of hubs
enable_matrix = true;
// Number of rows (Y) in the matrix
matrix_rows = 2;
// Number of columns (X) in the matrix
matrix_cols = 2;
// Number of layers (Z) in the matrix
matrix_layers = 1;
// Spacing between hubs (center to center)
matrix_spacing = 100.0;
// Diameter of the connecting tubes
connector_diameter = 1.5;

/* [Branch Toggles] */
enable_x_pos = true;  // Right (+X)
enable_x_neg = true;  // Left (-X)

enable_y_pos = true;  // Back (+Y)
enable_y_neg = true;  // Front (-Y)

enable_z_pos = true;  // Top (+Z)
enable_z_neg = true;  // Bottom (-Z)


/* [Branch Parameters] */
// How many grooves
n_edges = 15;
// diameter of said grooves
size_edges = 3.0;

/* [Hidden] */
// Effective length of the branch after bounding box clipping
tip_dist = branch_length - size_edges;
// Small overlap to ensure the connector is merged into the branch
overlap = 0.5;

// Increase this number for smoother cylinders (e.g., 64 or 100)
$fn = 10; 
rotation = auto_rotate ? [45, atan(1/sqrt(2)), 0] : [0,0,0];

function mk_vec (angle, length) = [
    cos(angle)*length,
    sin(angle)*length,
    0.0
];

module branch() {
    angle = 360.0/n_edges;
    cylinder(d=tube_diameter, h=branch_length);
}

module boundingbox() {
    // $fn=4 forces the cylinder to have a square base with vertices on the X and Y axes
    hull() {
        // Top half (pointing up the +Z axis)
        cylinder(r1=tip_dist, r2=0, h=tip_dist, $fn=4);

        // Bottom half (mirrored to point down the -Z axis)
        mirror([0, 0, 1])
            cylinder(r1=tip_dist, r2=0, h=tip_dist, $fn=4);
    }
}

module branches() {
    // X-Axis branches
    if (enable_x_pos) rotate([0, 90, 0]) branch();
    if (enable_x_neg) rotate([0, -90, 0]) branch();
    
    // Y-Axis branches
    if (enable_y_pos) rotate([-90, 0, 0]) branch();
    if (enable_y_neg) rotate([90, 0, 0]) branch();
    
    // Z-Axis branches
    if (enable_z_pos) branch();
    if (enable_z_neg) rotate([180, 0, 0]) branch();
}

module base_stopper() {
    module c() { cylinder(d=hub_diameter, h=hub_diameter/2, $fn=50); }
    union() {
        // X-Axis branches
        if (enable_x_pos) rotate([0, 90, 0]) c();
        if (enable_x_neg) rotate([0, -90, 0]) c();
        
        // Y-Axis branches
        if (enable_y_pos) rotate([-90, 0, 0]) c();
        if (enable_y_neg) rotate([90, 0, 0]) c();
        
        // Z-Axis branches
        if (enable_z_pos) c();
        if (enable_z_neg) rotate([180, 0, 0]) c();
    };

}

lowest_point =  ([0, 1, 1]*tube_diameter/2);
lowest_z = apply(rot(rotation), lowest_point)[2];

module single_hub() {
    z_shift = auto_rotate ? -lowest_z : 0;
    translate([0, 0, z_shift])
    union() {
        rotate(rotation) intersection() {
            branches();
            boundingbox();
        };
        difference() {
            rotate(rotation) base_stopper();
            if (auto_rotate) {
                translate([0,0,-lowest_z])
                    scale(2*hub_diameter) 
                    translate([0,0,-0.5]) 
                    cube(1, center=true);
            }
        }
    }
}

module tube_between(p1, p2, d) {
    hull() {
        translate(p1) sphere(d=d, $fn=8);
        translate(p2) sphere(d=d, $fn=8);
    }
}

module hub_matrix() {
    z_shift = auto_rotate ? -lowest_z : 0;
    
    // Original branch directions
    branch_vecs = [
        [1, 0, 0],  [-1, 0, 0], // X+, X-
        [0, 1, 0],  [0, -1, 0], // Y+, Y-
        [0, 0, 1],  [0, 0, -1]  // Z+, Z-
    ];
    
    enables = [
        enable_x_pos, enable_x_neg,
        enable_y_pos, enable_y_neg,
        enable_z_pos, enable_z_neg
    ];

    for (l = [0 : matrix_layers-1]) {
        for (r = [0 : matrix_rows-1]) {
            for (c = [0 : matrix_cols-1]) {
                pos = [c * matrix_spacing, r * matrix_spacing, l * matrix_spacing];
                translate(pos) single_hub();
                
                // For each enabled branch, find which neighbor it points to
                for (i = [0 : 5]) {
                    if (enables[i]) {
                        // Current branch vector in rotated space
                        rv = apply(rot(rotation), branch_vecs[i]);
                        u = unit(rv);
                        
                        // Find neighbor offset [dc, dr, dl] by rounding the direction
                        d = [round(u.x), round(u.y), round(u.z)];
                        
                        nc = c + d.x;
                        nr = r + d.y;
                        nl = l + d.z;
                        
                        // Check if neighbor is within matrix bounds
                        if (nc >= 0 && nc < matrix_cols &&
                            nr >= 0 && nr < matrix_rows &&
                            nl >= 0 && nl < matrix_layers) {
                            
                            // To avoid double drawing connections between two hubs,
                            // only draw if the neighbor has a higher coordinate index.
                            if (nl > l || (nl == l && nr > r) || (nl == l && nr == r && nc > c)) {
                                p1 = pos + [0, 0, z_shift] + rv * tip_dist - rv * overlap;
                                
                                // Tip of the corresponding branch on the neighbor
                                npos = [nc * matrix_spacing, nr * matrix_spacing, nl * matrix_spacing];
                                p2 = npos + [0, 0, z_shift] - rv * tip_dist + rv * overlap;
                                
                                // tube_between(p1, p2, connector_diameter);
                            }
                        }
                    }
                }
            }
        }
    }
}

// Render the matrix or a single hub
if (enable_matrix) {
    hub_matrix();
} else {
    single_hub();
}