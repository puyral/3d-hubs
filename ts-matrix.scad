include <BOSL2/std.scad>
// --- Customizable Parametric Hub ---

/* [Basics] */
// Diameter of the tubes (in mm)
tube_diameter = 20.0; 
// Length of each branch extending from the center (in mm, including the tip)
branch_length = 45.0; 
// Size of the central intersection block (in mm)
hub_diameter = 24.0;  
// Auto rotate for impression (also removes the bottom of the hub)
auto_rotate = true;

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
// Increase this number for smoother cylinders (e.g., 64 or 100)
$fn = 50; 
rotation = auto_rotate ? [45, atan(1/sqrt(2)), 0] : [0,0,0];

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
                cylinder(d=size_edges, h=branch_length, $fn=10);
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

module stopper() {
    if (auto_rotate) {
        difference() {
            base_stopper();
            translate([0, -hub_diameter, -hub_diameter]) cube(hub_diameter);
        }
    } else {
        base_stopper();
    }
}

module parametric_hub() {
    intersection() {
        union() {
            stopper();
            branches();
        }
        boundingbox();
    };
}
x = (sqrt(2)*branch_length - 2*sqrt(2)*hub_diameter/2)/2;
lowest_point =  ([0, 1, 1]*tube_diameter/2);
lowest_z = apply(rot(rotation), lowest_point)[2];

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
        } else {};
    }
};
            // translate([0,0,-lowest_z])
            //     scale(hub_diameter) 
            //     translate([0,0,-0.5]) 
            //     cube(1, center=true);
// cube(2*x, center=true);

// Render the model
// rotate( rotation) parametric_hub();