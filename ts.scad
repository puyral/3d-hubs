// --- Customizable Parametric Hub ---

// [Dimensions]
// Diameter of the tubes (in mm)
tube_diameter = 20.0; 
// Length of each branch extending from the center (in mm)
branch_length = 45.0; 
// Size of the central intersection block (in mm)
hub_diameter = 24.0;  

// [Branch Toggles]
// Change to 'false' to remove a specific branch
enable_x_pos = true;  // Right (+X)
enable_x_neg = true;  // Left (-X)

enable_y_pos = true;  // Back (+Y)
enable_y_neg = true;  // Front (-Y)

enable_z_pos = true;  // Top (+Z)
enable_z_neg = true;  // Bottom (-Z)

auto_rotate = true;

// [Branch Param]
// n edges
n_edges = 15;
size_edges = 3.0;
// extra_length = 5.0;


/* [Hidden] */
// Increase this number for smoother cylinders (e.g., 64 or 100)
$fn = 10; 

function mk_vec (angle, length) = [
    cos(angle)*length,
    sin(angle)*length,
    0.0
];

module branch() {
    angle = 360.0/n_edges;
    
    // intersection() {
    union() {
        for (i = [1: n_edges]) {
            translate(mk_vec(i*angle, (tube_diameter - size_edges)/2)) 
                cylinder(d=size_edges, h=branch_length);
        }
        cylinder(d=tube_diameter - size_edges/2, h=branch_length);
    }
}

module boundingbox() {
    radius = branch_length - size_edges; // Distance from the origin to each summit in mm

    // $fn=4 forces the cylinder to have a square base with vertices on the X and Y axes
    hull() {
        // Top half (pointing up the +Z axis)
        cylinder(r1=radius, r2=0, h=radius, $fn=4);
        
        // Bottom half (mirrored to point down the -Z axis)
        mirror([0, 0, 1])
            cylinder(r1=radius, r2=0, h=radius, $fn=4);
    }
}

module parametric_hub() {
    intersection() {
        union() {
            // Central hub to create a clean, slightly reinforced intersection
            sphere(d=hub_diameter, $fn=50);
            // cube(hub_diameter, center=true);
            
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
    
        boundingbox();
    }
}

// Render the model
if (auto_rotate) rotate( [45, atan(1/sqrt(2)), 0]) parametric_hub();
if (!auto_rotate)  parametric_hub();