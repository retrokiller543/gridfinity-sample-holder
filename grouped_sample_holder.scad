/*
 * Gridfinity Sample Box Generator with Grouping Support
 * Enhanced version with filament grouping and text labels
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

/* [Grouping Settings] */
// Enable grouping feature
enable_grouping = true; // [true:false]
// Number of samples per group (0 = use all available space without grouping)
samples_per_group = 8; // [0:1:50]
// Space between groups in millimeters
group_spacing = 8; // [5:1:20]
// Enable text labels between groups
enable_group_labels = true; // [true:false]
// Text height for group labels in millimeters
label_text_height = 3; // [2:0.5:8]
// Text depth (how deep to emboss/extrude)
label_text_depth = 0.8; // [0.2:0.1:2]
// Label style: 0=embossed (raised), 1=debossed (inset)
label_style = 1; // [0:Embossed, 1:Debossed]

/* [Grouping Settings/Group Labels] */
// Group 1 label text
group1_label = "PLA"; // Group 1 name
// Group 2 label text  
group2_label = "PETG"; // Group 2 name
// Group 3 label text
group3_label = "ABS"; // Group 3 name
// Group 4 label text
group4_label = "TPU"; // Group 4 name
// Group 5 label text
group5_label = "Wood"; // Group 5 name

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

// Group label array
group_labels = [group1_label, group2_label, group3_label, group4_label, group5_label];

// Main model
color("lightgray") 
difference() {
    // Create solid gridfinity box cut to exact height
    intersection() {
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
    
    // Subtract sample cutouts and labels
    if (enable_grouping && samples_per_group > 0) {
        grouped_sample_cutouts();
        if (enable_group_labels) {
            group_text_labels();
        }
    } else {
        sample_cutouts();
    }
}

// Preview group labels if embossed style
if (enable_grouping && enable_group_labels && label_style == 0) {
    color("blue") group_text_labels();
}

module grouped_sample_cutouts() {
    // Calculate interior dimensions
    interior_width = (sh_box_width * l_grid) - (2 * sh_wall_thickness);
    interior_depth = (sh_box_depth * l_grid) - (2 * sh_side_wall_thickness);
    
    echo(str("Interior space: ", interior_width, " x ", interior_depth, " mm"));
    echo(str("Sample size: ", sh_sample_thickness, " x ", sh_sample_width, " mm"));
    
    // Calculate what orientation works best
    layout = calculate_sample_layout(interior_width, interior_depth, sh_sample_width, sh_sample_thickness);
    is_rotated = layout[2];
    
    // Get cutout dimensions based on rotation
    cutout_x_size = is_rotated ? sh_sample_width : sh_sample_thickness;
    cutout_y_size = is_rotated ? sh_sample_thickness : sh_sample_width;
    
    if (samples_per_group <= 0) {
        // Use normal layout when grouping disabled
        sample_cutouts();
    } else {
        // Calculate how many samples fit across the width
        max_samples_across = floor((interior_width + sh_min_spacing) / (cutout_x_size + sh_min_spacing));
        samples_per_row = min(samples_per_group, max_samples_across);
        
        // Calculate how many rows we need per group
        rows_per_group = ceil(samples_per_group / samples_per_row);
        
        // Calculate spacing within each group
        group_cutout_width = samples_per_row * cutout_x_size + (samples_per_row - 1) * sh_min_spacing;
        group_cutout_depth = rows_per_group * cutout_y_size + (rows_per_group - 1) * sh_min_spacing;
        
        // Calculate how many groups can fit vertically
        max_groups = floor((interior_depth + group_spacing) / (group_cutout_depth + group_spacing));
        
        echo(str("Group layout: ", samples_per_row, " samples across, ", rows_per_group, " rows per group"));
        echo(str("Max groups that fit: ", max_groups));
        echo(str("Group dimensions: ", group_cutout_width, " x ", group_cutout_depth, " mm"));
        
        // Calculate total layout dimensions
        total_layout_width = group_cutout_width;
        total_layout_depth = max_groups * group_cutout_depth + (max_groups - 1) * group_spacing;
        
        // Center the entire layout
        layout_start_x = -total_layout_width / 2;
        layout_start_y = -total_layout_depth / 2;
        
        // Create groups
        for (group_idx = [0:max_groups-1]) {
            // Calculate group position
            group_y_offset = layout_start_y + group_idx * (group_cutout_depth + group_spacing);
            
            // Create samples within this group
            for (sample_idx = [0:samples_per_group-1]) {
                row = floor(sample_idx / samples_per_row);
                col = sample_idx % samples_per_row;
                
                if (row < rows_per_group) {
                    // Calculate sample position within group
                    sample_x = layout_start_x + col * (cutout_x_size + sh_min_spacing) + cutout_x_size/2;
                    sample_y = group_y_offset + row * (cutout_y_size + sh_min_spacing) + cutout_y_size/2;
                    
                    translate([sample_x, sample_y, sh_box_height - (sh_box_height - sh_cutout_start_z)]) 
                        sample_cutout_shape(is_rotated);
                }
            }
        }
    }
}

module group_text_labels() {
    // Calculate interior dimensions
    interior_width = (sh_box_width * l_grid) - (2 * sh_wall_thickness);
    interior_depth = (sh_box_depth * l_grid) - (2 * sh_side_wall_thickness);
    
    layout = calculate_sample_layout(interior_width, interior_depth, sh_sample_width, sh_sample_thickness);
    samples_across = layout[0];
    samples_along = layout[1]; 
    is_rotated = layout[2];
    total_samples = samples_across * samples_along;
    
    // Only create labels if grouping is enabled and we have multiple groups
    if (enable_grouping && samples_per_group > 0 && samples_per_group < total_samples) {
        num_groups = ceil(total_samples / samples_per_group);
        
        cutout_x_size = is_rotated ? sh_sample_width : sh_sample_thickness;
        samples_per_row = is_rotated ? 
            floor(interior_width / (sh_sample_width + sh_min_spacing)) : 
            floor(interior_width / (sh_sample_thickness + sh_min_spacing));
        
        group_width = min(samples_per_group, samples_per_row) * cutout_x_size + 
                     (min(samples_per_group, samples_per_row) - 1) * sh_min_spacing;
        
        total_groups_width = num_groups * group_width + (num_groups - 1) * group_spacing;
        actual_group_spacing = total_groups_width > interior_width ? 
            max(2, (interior_width - num_groups * group_width) / max(1, num_groups - 1)) : 
            group_spacing;
        
        // Recalculate total width with actual spacing
        actual_total_width = num_groups * group_width + (num_groups - 1) * actual_group_spacing;
        
        // Place labels at center of each group
        for (group_idx = [0:num_groups-1]) {
            group_offset_x = group_idx * (group_width + actual_group_spacing) - actual_total_width/2 + group_width/2;
            
            label_x = group_offset_x;
            label_y = 0;
            label_z = label_style == 0 ? sh_box_height : sh_box_height - label_text_depth;
            
            // Get label text for this group
            label_text = group_idx < len(group_labels) ? group_labels[group_idx] : str("G", group_idx + 1);
            
            translate([label_x, label_y, label_z]) {
                linear_extrude(height = label_text_depth, center = label_style == 1) {
                    text(
                        label_text, 
                        size = label_text_height, 
                        halign = "center", 
                        valign = "center",
                        font = "Liberation Sans:style=Bold"
                    );
                }
            }
        }
    }
}

// Original sample cutouts module (unchanged)
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
echo("=== Gridfinity Sample Box Generator with Grouping ===");
echo(str("Box: ", sh_box_width, "x", sh_box_depth, " gridfinity units"));  
echo(str("Dimensions: ", sh_box_width * l_grid, " x ", sh_box_depth * l_grid, " x ", sh_box_height, " mm"));
echo(str("Sample: ", sh_sample_thickness, " x ", sh_sample_width, " x ", sh_sample_height, " mm"));
echo(str("Grouping enabled: ", enable_grouping));
if (enable_grouping) {
    echo(str("Samples per group: ", samples_per_group));
    echo(str("Group spacing: ", group_spacing, " mm"));
    echo(str("Labels enabled: ", enable_group_labels));
}