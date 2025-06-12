/*
 * Gridfinity Sample Box Generator
 * Converted from Python script to OpenSCAD for MakerWorld customization
 * Uses gridfinity-rebuilt-openscad library for proper gridfinity base generation
 */

// Include the gridfinity library (MakerWorld compatible paths)
include <gridfinity-rebuilt-openscad/standard.scad>
use <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>
use <gridfinity-rebuilt-openscad/generic-helpers.scad>

/* [Box Dimensions] */
// Width of the box in gridfinity units (42mm each)
sh_box_width = 1; // [1:1:10]
// Depth of the box in gridfinity units (42mm each)  
sh_box_depth = 4; // [1:1:10]
// Total height of the box in millimeters
sh_box_height = 21; // [15:1:50]

/* [Sample Dimensions] */
// Width of each sample card in millimeters
sh_sample_width = 76; // [50:1:100]
// Height of each sample card in millimeters (for reference only)
sh_sample_height = 15; // [10:1:25]
// Thickness of each sample card in millimeters
sh_sample_thickness = 2.4; // [1:0.1:5]

/* [Gridfinity Settings] */
// Grid unit size in mm (standard gridfinity is 42mm)
l_grid = 42; // [35:1:50]
// Base height in mm (standard gridfinity is 5mm)
h_base = 5; // [3:0.5:8]
// Bottom thickness in mm (standard gridfinity is 2.2mm)
h_bot = 2.2; // [1.5:0.1:4]
// Base hole style for baseplate compatibility
style_hole = 0; // [0:No holes, 1:Magnet holes only, 2:Magnet and screw holes, 3:Magnet and screw holes with printable slit, 4:Refined holes (no glue needed)]
// Lip style for stacking compatibility
style_lip = 0; // [0:Regular lip, 1:Remove lip subtractively, 2:Remove lip and retain height]

/* [Advanced Settings] */
// Wall thickness for calculating interior space
sh_wall_thickness = 3.6; // [2:0.1:6]
// Side wall thickness for calculating interior space
sh_side_wall_thickness = 3.75; // [2:0.1:6]
// Minimum spacing between sample cutouts
sh_min_spacing = 1.0; // [0.5:0.1:3]
// Height from bottom where sample cutouts start
sh_cutout_start_z = 6.0; // [4:0.1:10]

// Use gridfinity standard constants from library

// Main model - create solid gridfinity box without lip, then subtract cutouts
color("lightgray") 
difference() {
    // Create solid gridfinity box cut to exact height
    intersection() {
        // Create a tall gridfinity box with solid infill
        union() {
            gridfinityInit(sh_box_width, sh_box_depth, height(10, 0, style_lip, false), 0, l_grid, style_lip) {
                // Make solid infill by not adding any cuts
            }
            gridfinityBase(sh_box_width, sh_box_depth, l_grid, 0, 0, style_hole);
        }
        
        // Cut to exact height with flat top
        translate([0, 0, sh_box_height/2])
            cube([sh_box_width * l_grid + 10, sh_box_depth * l_grid + 10, sh_box_height], center=true);
    }
    
    // Subtract sample cutouts from the top
    sample_cutouts();
}


module sample_cutouts() {
    // Calculate interior dimensions based on gridfinity standard
    interior_width = (sh_box_width * l_grid) - (2 * sh_wall_thickness);
    interior_depth = (sh_box_depth * l_grid) - (2 * sh_side_wall_thickness);
    
    echo(str("Interior space: ", interior_width, " x ", interior_depth, " mm"));
    echo(str("Sample size: ", sh_sample_thickness, " x ", sh_sample_width, " mm"));
    
    // Calculate optimal layout
    layout = calculate_sample_layout(interior_width, interior_depth, sh_sample_width, sh_sample_thickness);
    samples_across = layout[0];
    samples_along = layout[1]; 
    is_rotated = layout[2];
    total_samples = samples_across * samples_along;
    
    echo(str("Layout: ", samples_across, " x ", samples_along, " = ", total_samples, " samples"));
    if (is_rotated) echo("Cutouts will be rotated 90° for better fit");
    
    // Calculate and display actual spacing
    cutout_x_size = is_rotated ? sh_sample_width : sh_sample_thickness;
    cutout_y_size = is_rotated ? sh_sample_thickness : sh_sample_width;
    total_cutout_width = samples_across * cutout_x_size;
    total_cutout_depth = samples_along * cutout_y_size;
    actual_spacing_x = samples_across > 1 ? 
        max(sh_min_spacing, (interior_width - total_cutout_width) / (samples_across - 1)) : 0;
    actual_spacing_y = samples_along > 1 ? 
        max(sh_min_spacing, (interior_depth - total_cutout_depth) / (samples_along - 1)) : 0;
    
    echo(str("Wall thickness between samples: X=", actual_spacing_x, "mm, Y=", actual_spacing_y, "mm"));
    
    // Generate positions and create cutouts
    positions = generate_sample_positions(samples_across, samples_along, is_rotated, 
                                        interior_width, interior_depth);
    
    // Create sample cutouts at each position from the top surface
    for (i = [0:len(positions)-1]) {
        pos = positions[i];
        translate([pos[0], pos[1], sh_box_height - (sh_box_height - sh_cutout_start_z)]) 
            sample_cutout_shape(is_rotated);
    }
}

function calculate_sample_layout(interior_width, interior_depth, sample_w, sample_t) = 
    let(
        // Calculate maximum possible samples in each direction for both orientations
        // Include minimum spacing in calculations
        
        // Normal orientation: sample_t (narrow) across width, sample_w (long) along depth  
        max_across_normal = max(1, floor((interior_width + sh_min_spacing) / (sample_t + sh_min_spacing))),
        max_along_normal = max(1, floor((interior_depth + sh_min_spacing) / (sample_w + sh_min_spacing))),
        
        // Rotated orientation: sample_w (long) across width, sample_t (narrow) along depth
        max_across_rotated = max(1, floor((interior_width + sh_min_spacing) / (sample_w + sh_min_spacing))), 
        max_along_rotated = max(1, floor((interior_depth + sh_min_spacing) / (sample_t + sh_min_spacing))),
        
        // Generate test arrangements for both orientations (with bounds checking)
        normal_arrangements = max_across_normal >= 1 && max_along_normal >= 1 ? [
            for (across = [1:max_across_normal])
                for (along = [1:max_along_normal])
                    [across, along, false, across * along]
        ] : [],
        
        rotated_arrangements = max_across_rotated >= 1 && max_along_rotated >= 1 ? [
            for (across = [1:max_across_rotated]) 
                for (along = [1:max_along_rotated])
                    [across, along, true, across * along]
        ] : [],
        
        // Combine all arrangements
        all_arrangements = concat(normal_arrangements, rotated_arrangements),
        
        // Find best fitting arrangement
        best = find_best_arrangement(all_arrangements, interior_width, interior_depth, sample_w, sample_t)
    ) best;

function find_best_arrangement(arrangements, interior_width, interior_depth, sample_w, sample_t) =
    let(
        // Filter for arrangements that actually fit WITH minimum spacing
        valid_arrangements = [
            for (arr = arrangements)
                let(
                    across = arr[0],
                    along = arr[1], 
                    rotated = arr[2],
                    total = arr[3],
                    
                    // Calculate space needed based on orientation
                    cutout_width = rotated ? sample_w : sample_t,
                    cutout_depth = rotated ? sample_t : sample_w,
                    
                    // Calculate space needed including minimum spacing
                    width_needed = across * cutout_width + (across - 1) * sh_min_spacing,
                    depth_needed = along * cutout_depth + (along - 1) * sh_min_spacing,
                    
                    fits = (width_needed <= interior_width) && (depth_needed <= interior_depth)
                )
                if (fits) arr
        ],
        
        // Find arrangement with most samples
        best_idx = len(valid_arrangements) > 0 ? find_max_index([for (arr = valid_arrangements) arr[3]]) : 0,
        best_arrangement = len(valid_arrangements) > 0 ? valid_arrangements[best_idx] : [1, 1, false, 1]
    ) [best_arrangement[0], best_arrangement[1], best_arrangement[2]];

function find_max_index(arr) = 
    len(arr) == 0 ? 0 :
    let(
        max_val = max(arr),
        indices = [for (i = [0:len(arr)-1]) if (arr[i] == max_val) i]
    ) indices[0];

function generate_sample_positions(samples_across, samples_along, is_rotated, interior_width, interior_depth) =
    let(
        // Get cutout dimensions based on rotation
        cutout_x_size = is_rotated ? sh_sample_width : sh_sample_thickness,
        cutout_y_size = is_rotated ? sh_sample_thickness : sh_sample_width,
        
        // Calculate spacing - use minimum spacing or distribute extra space evenly
        total_cutout_width = samples_across * cutout_x_size,
        total_cutout_depth = samples_along * cutout_y_size,
        
        spacing_x = samples_across > 1 ? 
            max(sh_min_spacing, (interior_width - total_cutout_width) / (samples_across - 1)) : 0,
        spacing_y = samples_along > 1 ? 
            max(sh_min_spacing, (interior_depth - total_cutout_depth) / (samples_along - 1)) : 0,
            
        // Calculate actual total width/depth used
        actual_width_used = total_cutout_width + (samples_across - 1) * spacing_x,
        actual_depth_used = total_cutout_depth + (samples_along - 1) * spacing_y,
        
        // Center the layout in available space
        start_x = -actual_width_used/2 + cutout_x_size/2,
        start_y = -actual_depth_used/2 + cutout_y_size/2,
        
        // Generate all positions
        positions = [
            for (row = [0:samples_along-1])
                for (col = [0:samples_across-1])
                    [
                        start_x + col * (cutout_x_size + spacing_x),
                        start_y + row * (cutout_y_size + spacing_y)
                    ]
        ]
    ) positions;

module sample_cutout_shape(is_rotated) {
    // Get dimensions based on rotation
    width = is_rotated ? sh_sample_width : sh_sample_thickness;
    depth = is_rotated ? sh_sample_thickness : sh_sample_width; 
    
    // Calculate cutout height - from top surface down to sh_cutout_start_z
    cutout_height = sh_box_height - sh_cutout_start_z;
    
    // Create cutout extending downward from top surface
    translate([-width/2, -depth/2, 0])
        cube([width, depth, cutout_height + 1]); // +1 for clean boolean operation
}


// Display information
echo("=== Gridfinity Sample Box Generator ===");
echo(str("Box: ", sh_box_width, "x", sh_box_depth, " gridfinity units"));  
echo(str("Dimensions: ", sh_box_width * l_grid, " x ", sh_box_depth * l_grid, " x ", sh_box_height, " mm"));
echo(str("Sample: ", sh_sample_thickness, " x ", sh_sample_width, " x ", sh_sample_height, " mm"));
echo(str("Cutout depth: ", sh_cutout_start_z, " mm"));
echo(str("Minimum wall thickness: ", sh_min_spacing, " mm"));