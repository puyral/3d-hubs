// --- Customizable Parametric Hub ---

// [Dimensions]
// Diameter of the tubes (in mm)
tube_diameter = 20.0; 
// Length of each branch extending from the center (in mm)
branch_length = 40.0; 
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


/* [Hidden] */
// Increase this number for smoother cylinders (e.g., 64 or 100)
$fn = 50; 

module branch(diameter=tube_diameter, length=branch_length) {
    cylinder(d=diameter, h=length);
}

module parametric_hub() {
    union() {
        // Central hub to create a clean, slightly reinforced intersection
        sphere(d=hub_diameter);
        
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
}

// Render the model
parametric_hub();