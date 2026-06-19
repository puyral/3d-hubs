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

/* [Batch Printing] */
// Render a batch instead of a single hub
batch_enabled = false;
// Number of hubs in the X direction
batch_count_x = 2;
// Number of hubs in the Y direction
batch_count_y = 2;
// Number of stacked hubs in the Z direction
batch_count_z = 1;
// Extra XY clearance between neighbouring hubs (used when pitch override is 0)
batch_clearance = 5.0;
// Vertical air gap between stacked hubs, bridged by breakaway supports (used when Z pitch override is 0)
batch_layer_gap = 0.8;
// Override X pitch, or 0 for automatic tight spacing
batch_pitch_x_override = 0;
// Override Y pitch, or 0 for automatic tight spacing
batch_pitch_y_override = 0;
// Override Z pitch, or 0 for automatic stacking spacing
batch_pitch_z_override = 0;
// Center the X/Y batch around the origin
batch_center_xy = true;

/* [Batch Breakaway Supports] */
// Add tiny breakaway pillars between stacked hubs
batch_add_supports = true;
// Rotate every other Z layer by 180 degrees so upper bottom faces line up with lower top faces
batch_alternate_layer_rotation = true;
// How far each support contact is inset from the point of the branch tip face
batch_support_face_inset = 4.0;
// Posts per branch-tip contact face: 1 = center only, 2 = pair, 3 = triangle, 4 = center + triangle
batch_support_post_count = 1;
// Radial spread of extra posts around each branch-tip contact face, or 0 for automatic
batch_support_spread = 3.0;
// Main diameter of breakaway support pillars
batch_support_diameter = 1.2;
// Narrow contact diameter at the top and bottom of each support pillar
batch_support_tip_diameter = 0.65;
// Height of each narrow contact/taper zone
batch_support_tip_height = 0.45;
// How far support tips penetrate into the neighbouring hubs
batch_support_overlap = 0.15;

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
function rotate_x(v, a) = [v[0], v[1]*cos(a) - v[2]*sin(a), v[1]*sin(a) + v[2]*cos(a)];
function rotate_y(v, a) = [v[0]*cos(a) + v[2]*sin(a), v[1], -v[0]*sin(a) + v[2]*cos(a)];
function rotate_z(v, a) = [v[0]*cos(a) - v[1]*sin(a), v[0]*sin(a) + v[1]*cos(a), v[2]];
function rotate_vec(v, r) = rotate_z(rotate_y(rotate_x(v, r[0]), r[1]), r[2]);

function hub_bound_radius() = branch_length - size_edges;
function rotated_axis(v) = rotate_vec(v, rotation);
function rotate_z_180_if(v, do_rotate) = do_rotate ? [-v[0], -v[1], v[2]] : v;
function inset_towards_center(v, inset) =
    let(xy_len = sqrt(v[0]*v[0] + v[1]*v[1]), scale_xy = xy_len > 0 ? max(0, xy_len-inset)/xy_len : 1)
    [v[0]*scale_xy, v[1]*scale_xy, v[2]];
function top_contact_points() =
    let(r = hub_bound_radius())
    [
        inset_towards_center(rotated_axis([-r, 0, 0]), batch_support_face_inset),
        inset_towards_center(rotated_axis([0, r, 0]), batch_support_face_inset),
        inset_towards_center(rotated_axis([0, 0, r]), batch_support_face_inset)
    ];
function hub_half_extent(dim) =
    let(r = hub_bound_radius())
    max(
        abs(rotated_axis([r, 0, 0])[dim]),
        abs(rotated_axis([0, r, 0])[dim]),
        abs(rotated_axis([0, 0, r])[dim])
    );

lowest_point =  ([0, 1, 1]*tube_diameter/2);
lowest_z = rotate_vec(lowest_point, rotation)[2];

module printable_hub() {
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
}

function support_offsets(n, spread) =
    n <= 1 ? [[0, 0]] :
    n == 2 ? [[-spread/2, 0], [spread/2, 0]] :
    n == 3 ? [for (i = [0:2]) [cos(90 + 120*i)*spread, sin(90 + 120*i)*spread]] :
             concat([[0, 0]], [for (i = [0:2]) [cos(90 + 120*i)*spread, sin(90 + 120*i)*spread]]);

module breakaway_post(h) {
    tip_h = min(batch_support_tip_height, h/2);
    if (batch_support_tip_diameter > 0 && batch_support_tip_diameter < batch_support_diameter && h > 2*tip_h) {
        cylinder(d1=batch_support_tip_diameter, d2=batch_support_diameter, h=tip_h, $fn=12);
        translate([0, 0, tip_h])
            cylinder(d=batch_support_diameter, h=h-2*tip_h, $fn=12);
        translate([0, 0, h-tip_h])
            cylinder(d1=batch_support_diameter, d2=batch_support_tip_diameter, h=tip_h, $fn=12);
    } else {
        cylinder(d=batch_support_diameter, h=h, $fn=12);
    }
}

module layer_supports(gap_h) {
    spread = batch_support_spread > 0 ? batch_support_spread : min(hub_half_extent(0), hub_half_extent(1))/4;
    for (p = support_offsets(batch_support_post_count, spread)) {
        translate([p[0], p[1], 0]) breakaway_post(gap_h);
    }
}

module hub_batch() {
    half_x = hub_half_extent(0);
    half_y = hub_half_extent(1);
    half_z = hub_half_extent(2);

    pitch_x = batch_pitch_x_override > 0 ? batch_pitch_x_override : 2*half_x + batch_clearance;
    pitch_y = batch_pitch_y_override > 0 ? batch_pitch_y_override : 2*half_y + batch_clearance;
    pitch_z = batch_pitch_z_override > 0 ? batch_pitch_z_override : 2*half_z + batch_layer_gap;
    gap_z = pitch_z - 2*half_z;

    x0 = batch_center_xy ? -(batch_count_x-1)*pitch_x/2 : 0;
    y0 = batch_center_xy ? -(batch_count_y-1)*pitch_y/2 : 0;

    union() {
        for (ix = [0:batch_count_x-1])
            for (iy = [0:batch_count_y-1])
                for (iz = [0:batch_count_z-1])
                    translate([x0 + ix*pitch_x, y0 + iy*pitch_y, iz*pitch_z])
                        rotate([0, 0, (batch_alternate_layer_rotation && (iz % 2 == 1)) ? 180 : 0])
                            printable_hub();

        if (batch_add_supports && batch_count_z > 1 && gap_z > 0) {
            support_h = gap_z + 2*batch_support_overlap;
            for (ix = [0:batch_count_x-1])
                for (iy = [0:batch_count_y-1])
                    for (iz = [1:batch_count_z-1])
                        for (p = top_contact_points())
                            translate([
                                x0 + ix*pitch_x + rotate_z_180_if(p, batch_alternate_layer_rotation && ((iz-1) % 2 == 1))[0],
                                y0 + iy*pitch_y + rotate_z_180_if(p, batch_alternate_layer_rotation && ((iz-1) % 2 == 1))[1],
                                (iz-1)*pitch_z + half_z - batch_support_overlap
                            ]) layer_supports(support_h);
        }
    }
}

if (batch_enabled) {
    hub_batch();
} else {
    printable_hub();
}