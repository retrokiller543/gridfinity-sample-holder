// OpenSCAD Bundle - Generated automatically
// Entry point: sample_card_holder.scad
// This file contains all local dependencies bundled together

// ===== Parameter Sections =====

/* [Box Dimensions] */
// Width of the box in gridfinity units (42mm each)
sh_box_width = 1; // [1:0.5:10]
// Depth of the box in gridfinity units (42mm each)  
sh_box_depth = 4; // [1:0.5:10]
// Total height of the box in millimeters
sh_box_height = 21; // [15:0.2:50]

/* [Sample Dimensions] */
// Width of each sample card in millimeters
sh_sample_width = 76; // [20:1:300]
// Height of each sample card in millimeters (for reference only)
sh_sample_height = 15; // [10:1:25]
// Thickness of each sample card in millimeters
sh_sample_thickness = 2.4; // [1:0.1:10]

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
// X-axis wall thickness for calculating interior space
sh_wall_thickness = 3.6; // [2:0.1:6]
// Y-axis wall thickness for calculating interior space
sh_side_wall_thickness = 3.75; // [2:0.1:6]
// Minimum spacing between sample cutouts
sh_min_spacing = 1.0; // [0.5:0.1:3]
// Height from bottom where sample cutouts start
sh_cutout_start_z = 6.0; // [4:0.1:10]
// Layout algorithm selection
sh_algorithm_type = 2; // [0:Grid Layout, 1:Multi-Pass Grouping, 2:Single-Pass Grouping]
// Row spacing for grouping algorithms (0 = auto-calculate)
sh_row_spacing = 0; // [0:0.1:20]
// Force sample orientation (auto = choose best fit, normal = 2.4mm along X, rotated = 76mm along X)
sh_force_orientation = "auto"; // [auto, normal, rotated]

/* [Grouping Settings] */
// Enable group-based layout (instead of row-based)
sh_enable_grouping = false; // [true, false]
// Number of groups to create (0 = auto-calculate)
sh_group_count = 0; // [0:1:100]
// Number of samples per group (0 = auto-calculate)
sh_samples_per_group = 0; // [0:1:100]
// Spacing between groups in millimeters
sh_group_spacing = 10.0; // [1:0.1:100]

/* [Group Label Settings] */
// === Label System ===
// Enable magnetic removable labels between groups
sh_enable_labels = false; // [true, false]
// Generate separate label objects for printing
sh_generate_labels = false; // [true, false]
// Include label and spacing for the first group in each row. This will reduce the number of samples per row but improve the experience with labels.
sh_include_first_group_label = false; // [true, false]
// Label text mode: auto generates G1, G2, etc., custom uses provided text
sh_label_text_mode = "auto"; // [auto, custom]
// Custom label text (comma-separated for multiple groups, e.g., "Sample A,Sample B,Sample C")
sh_label_custom_text = "Group 1,Group 2,Group 3";
// Label position within group spacing area
sh_label_position = "center"; // [start, center, end]
// Label dimensions in millimeters
sh_label_width = 76.0; // [3:0.5:100]
sh_label_height = 10.0; // [3:0.5:300]
sh_label_thickness = 3.5; // [1.5:0.1:6]

/* [Magnet Settings] */
// Magnet system for removable labels
sh_magnet_diameter = 6.0; // [3:0.5:15]
sh_magnet_thickness = 2.0; // [0.5:0.1:5]
sh_magnet_count = 1; // [1:1:6]

/* [Text Styling] */
// Text style on labels
sh_text_style = "embossed"; // [embossed, debossed, inset]
// Depth/height of text (positive for embossed/debossed, negative for inset)
sh_text_depth = 0.4; // [0.1:0.05:1.0]
// Font size in mm (0 = auto-calculate based on label size)
sh_font_size = 0; // [0:0.5:10]
// Font family and style
sh_font_family = "Liberation Sans:style=Bold";

// Assert validation
assert(sh_min_spacing >= 0.5, "Minimum spacing must be at least 0.5mm to ensure proper cutout separation and ease of printing.");

// Multi-plate 3MF generation modules (following Bambu Lab guide)
module mw_plate_1() {
    // Main gridfinity holder
    color("lightgray") 
    difference() {
        gridfinity_box(sh_box_width, sh_box_depth, sh_box_height, l_grid, style_lip, style_hole, cut_to_height=true);
        
        // Subtract sample cutouts from the top
        if (sh_enable_grouping || sh_algorithm_type == 2) {
            grouped_v2(sh_box_width, sh_box_depth, sh_box_height, l_grid, sh_wall_thickness, 
                       sh_side_wall_thickness, sh_sample_width, sh_sample_thickness, 
                       sh_min_spacing, sh_cutout_start_z, sh_row_spacing, sh_enable_grouping,
                       sh_group_count, sh_samples_per_group, sh_group_spacing,
                       sh_enable_labels, sh_include_first_group_label, sh_label_text_mode, sh_label_custom_text, sh_label_position,
                       sh_label_width, sh_label_height, sh_label_thickness,
                       sh_magnet_diameter, sh_magnet_thickness, sh_magnet_count,
                       sh_text_style, sh_text_depth, sh_font_size, sh_font_family, sh_force_orientation);
        } else if (sh_algorithm_type == 1) {
            grouped_sample_cutouts(sh_box_width, sh_box_depth, sh_box_height, l_grid, sh_wall_thickness, 
                                  sh_side_wall_thickness, sh_sample_width, sh_sample_thickness, 
                                  sh_min_spacing, sh_cutout_start_z, sh_row_spacing, sh_enable_grouping,
                                  sh_group_count, sh_samples_per_group, sh_group_spacing);
        } else {
            sample_cutouts(sh_box_width, sh_box_depth, sh_box_height, l_grid, sh_wall_thickness, 
                          sh_side_wall_thickness, sh_sample_width, sh_sample_thickness, 
                          sh_min_spacing, sh_cutout_start_z);
        }
    }
}


// ===== Begin: sample_card_holder.scad =====
// Original: use <src/gridfinity_box.scad>
// Inlining 'use' file (modules/functions only):
  // ===== Begin: gridfinity_box.scad =====
  // External dependency (kept as-is): include <gridfinity-rebuilt-openscad/standard.scad>
  include <gridfinity-rebuilt-openscad/standard.scad>
  // External dependency (kept as-is): use <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>
  use <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>
  // External dependency (kept as-is): use <gridfinity-rebuilt-openscad/generic-helpers.scad>
  use <gridfinity-rebuilt-openscad/generic-helpers.scad>
  
  module gridfinity_box(box_width, box_depth, box_height, l_grid, style_lip, style_hole, cut_to_height=true) {
      if (cut_to_height) {
          intersection() {
              gridfinity_box_base(box_width, box_depth, l_grid, style_lip, style_hole);
              
              translate([0, 0, box_height/2])
                  cube([box_width * l_grid + 10, box_depth * l_grid + 10, box_height], center=true);
          }
      } else {
          gridfinity_box_base(box_width, box_depth, l_grid, style_lip, style_hole);
      }
  }
  
  module gridfinity_box_base(box_width, box_depth, l_grid, style_lip, style_hole) {
      union() {
          gridfinityInit(box_width, box_depth, height(10, 0, style_lip, false), 0, l_grid, style_lip) {
          }
          gridfinityBase(box_width, box_depth, l_grid, 0, 0, style_hole);
      }
  }
  // ===== End: gridfinity_box.scad =====

// Original: use <src/sample_cutouts.scad>
// Inlining 'use' file (modules/functions only):
  // ===== Begin: sample_cutouts.scad =====
    // ===== Begin: layout_calculator.scad =====
    function calculate_sample_layout(interior_width, interior_depth, sample_w, sample_t, min_spacing) = 
        let(
            normal_arrangements = generate_normal_arrangements(interior_width, interior_depth, sample_w, sample_t, min_spacing),
            rotated_arrangements = generate_rotated_arrangements(interior_width, interior_depth, sample_w, sample_t, min_spacing),
            all_arrangements = concat(normal_arrangements, rotated_arrangements),
            best = find_best_arrangement(all_arrangements, interior_width, interior_depth, sample_w, sample_t, min_spacing)
        ) best;
    
    function calculate_max_samples_per_direction(space_size, sample_size, min_spacing) =
        max(1, floor((space_size + min_spacing) / (sample_size + min_spacing)));
    
    function generate_normal_arrangements(interior_width, interior_depth, sample_w, sample_t, min_spacing) =
        let(
            max_across = calculate_max_samples_per_direction(interior_width, sample_t, min_spacing),
            max_along = calculate_max_samples_per_direction(interior_depth, sample_w, min_spacing)
        )
        max_across >= 1 && max_along >= 1 ? [
            for (across = [1:max_across])
                for (along = [1:max_along])
                    [across, along, false, across * along]
        ] : [];
    
    function generate_rotated_arrangements(interior_width, interior_depth, sample_w, sample_t, min_spacing) =
        let(
            max_across = calculate_max_samples_per_direction(interior_width, sample_w, min_spacing),
            max_along = calculate_max_samples_per_direction(interior_depth, sample_t, min_spacing)
        )
        max_across >= 1 && max_along >= 1 ? [
            for (across = [1:max_across]) 
                for (along = [1:max_along])
                    [across, along, true, across * along]
        ] : [];
    
    function find_best_arrangement(arrangements, interior_width, interior_depth, sample_w, sample_t, min_spacing) =
        let(
            valid_arrangements = filter_valid_arrangements(arrangements, interior_width, interior_depth, sample_w, sample_t, min_spacing),
            best_idx = len(valid_arrangements) > 0 ? find_max_index([for (arr = valid_arrangements) arr[3]]) : 0,
            best_arrangement = len(valid_arrangements) > 0 ? valid_arrangements[best_idx] : [1, 1, false, 1]
        ) [best_arrangement[0], best_arrangement[1], best_arrangement[2]];
    
    function filter_valid_arrangements(arrangements, interior_width, interior_depth, sample_w, sample_t, min_spacing) =
        [
            for (arr = arrangements)
                if (arrangement_fits(arr, interior_width, interior_depth, sample_w, sample_t, min_spacing))
                    arr
        ];
    
    function arrangement_fits(arrangement, interior_width, interior_depth, sample_w, sample_t, min_spacing) =
        let(
            across = arrangement[0],
            along = arrangement[1], 
            rotated = arrangement[2],
            cutout_width = rotated ? sample_w : sample_t,
            cutout_depth = rotated ? sample_t : sample_w,
            width_needed = across * cutout_width + (across - 1) * min_spacing,
            depth_needed = along * cutout_depth + (along - 1) * min_spacing
        )
        (width_needed <= interior_width) && (depth_needed <= interior_depth);
    
    function find_max_index(arr) = 
        len(arr) == 0 ? 0 :
        let(
            max_val = max(arr),
            indices = [for (i = [0:len(arr)-1]) if (arr[i] == max_val) i]
        ) indices[0];
    
    function generate_sample_positions(samples_across, samples_along, is_rotated, interior_width, interior_depth, sample_width, sample_thickness, min_spacing) =
        let(
            cutout_dimensions = get_cutout_dimensions(is_rotated, sample_width, sample_thickness),
            cutout_x_size = cutout_dimensions[0],
            cutout_y_size = cutout_dimensions[1],
            
            spacing = calculate_sample_spacing(samples_across, samples_along, cutout_x_size, cutout_y_size, interior_width, interior_depth, min_spacing),
            spacing_x = spacing[0],
            spacing_y = spacing[1],
            
            layout_origin = calculate_layout_origin(samples_across, samples_along, cutout_x_size, cutout_y_size, spacing_x, spacing_y),
            start_x = layout_origin[0],
            start_y = layout_origin[1],
            
            positions = generate_grid_positions(samples_across, samples_along, start_x, start_y, cutout_x_size, cutout_y_size, spacing_x, spacing_y)
        ) positions;
    
    function get_cutout_dimensions(is_rotated, sample_width, sample_thickness) =
        is_rotated ? [sample_width, sample_thickness] : [sample_thickness, sample_width];
    
    function calculate_sample_spacing(samples_across, samples_along, cutout_x_size, cutout_y_size, interior_width, interior_depth, min_spacing) =
        let(
            total_cutout_width = samples_across * cutout_x_size,
            total_cutout_depth = samples_along * cutout_y_size,
            spacing_x = samples_across > 1 ? 
                max(min_spacing, (interior_width - total_cutout_width) / (samples_across - 1)) : 0,
            spacing_y = samples_along > 1 ? 
                max(min_spacing, (interior_depth - total_cutout_depth) / (samples_along - 1)) : 0
        ) [spacing_x, spacing_y];
    
    function calculate_layout_origin(samples_across, samples_along, cutout_x_size, cutout_y_size, spacing_x, spacing_y) =
        let(
            actual_width_used = samples_across * cutout_x_size + (samples_across - 1) * spacing_x,
            actual_depth_used = samples_along * cutout_y_size + (samples_along - 1) * spacing_y,
            start_x = -actual_width_used/2 + cutout_x_size/2,
            start_y = -actual_depth_used/2 + cutout_y_size/2
        ) [start_x, start_y];
    
    function generate_grid_positions(samples_across, samples_along, start_x, start_y, cutout_x_size, cutout_y_size, spacing_x, spacing_y) =
        [
            for (row = [0:samples_along-1])
                for (col = [0:samples_across-1])
                    [
                        start_x + col * (cutout_x_size + spacing_x),
                        start_y + row * (cutout_y_size + spacing_y)
                    ]
        ];
    // ===== End: layout_calculator.scad =====

  
  module sample_cutouts(box_width, box_depth, box_height, l_grid, wall_thickness, side_wall_thickness, 
                       sample_width, sample_thickness, min_spacing, cutout_start_z) {
      interior_width = (box_width * l_grid) - (2 * wall_thickness);
      interior_depth = (box_depth * l_grid) - (2 * side_wall_thickness);
      
      echo(str("Interior space: ", interior_width, " x ", interior_depth, " mm"));
      echo(str("Sample size: ", sample_thickness, " x ", sample_width, " mm"));
      
      layout = calculate_sample_layout(interior_width, interior_depth, sample_width, sample_thickness, min_spacing);
      samples_across = layout[0];
      samples_along = layout[1]; 
      is_rotated = layout[2];
      total_samples = samples_across * samples_along;
      
      echo(str("Layout: ", samples_across, " x ", samples_along, " = ", total_samples, " samples"));
      if (is_rotated) echo("Cutouts will be rotated 90° for better fit");
      
      cutout_x_size = is_rotated ? sample_width : sample_thickness;
      cutout_y_size = is_rotated ? sample_thickness : sample_width;
      total_cutout_width = samples_across * cutout_x_size;
      total_cutout_depth = samples_along * cutout_y_size;
      actual_spacing_x = samples_across > 1 ? 
          max(min_spacing, (interior_width - total_cutout_width) / (samples_across - 1)) : 0;
      actual_spacing_y = samples_along > 1 ? 
          max(min_spacing, (interior_depth - total_cutout_depth) / (samples_along - 1)) : 0;
      
      echo(str("Wall thickness between samples: X=", actual_spacing_x, "mm, Y=", actual_spacing_y, "mm"));
      
      positions = generate_sample_positions(samples_across, samples_along, is_rotated, 
                                          interior_width, interior_depth, sample_width, sample_thickness, min_spacing);
      
      for (i = [0:len(positions)-1]) {
          pos = positions[i];
          translate([pos[0], pos[1], box_height - (box_height - cutout_start_z)]) 
              sample_cutout_shape(is_rotated, sample_width, sample_thickness, box_height, cutout_start_z);
      }
  }
  
  module sample_cutout_shape(is_rotated, sample_width, sample_thickness, box_height, cutout_start_z) {
      width = is_rotated ? sample_width : sample_thickness;
      depth = is_rotated ? sample_thickness : sample_width; 
      
      cutout_height = box_height - cutout_start_z;
      
      translate([-width/2, -depth/2, 0])
          cube([width, depth, cutout_height + 1]);
  }
  // ===== End: sample_cutouts.scad =====

// Original: use <src/grouped_sample_cutouts.scad>
// Inlining 'use' file (modules/functions only):
  // ===== Begin: grouped_sample_cutouts.scad =====
    // ===== Begin: grouping_layout_calculator.scad =====
    // ===== Begin: grouping_layout_calculator.scad (Corrected) =====
    
    // This function calculates the optimal layout for samples, supporting advanced grouping.
    // It determines the best orientation (normal or rotated) and then arranges samples
    // either in simple rows or in spaced-out groups, based on the provided parameters.
    function calculate_grouped_layout(interior_width, interior_depth, sample_w, sample_t, min_spacing, row_spacing, 
                                      enable_grouping=false, group_count=0, samples_per_group=0, group_spacing=3.0) = 
        let(
            // Test both sample orientations to find which one holds more samples.
            normal_layout = test_sample_orientation(interior_width, interior_depth, sample_t, sample_w, min_spacing, false),
            rotated_layout = test_sample_orientation(interior_width, interior_depth, sample_w, sample_t, min_spacing, true),
            
            normal_capacity = normal_layout[0] * normal_layout[1],
            rotated_capacity = rotated_layout[0] * rotated_layout[1],
            
            // Choose the best orientation based on total capacity.
            use_rotated = rotated_capacity > normal_capacity,
            best_layout = use_rotated ? rotated_layout : normal_layout,
            
            samples_per_row = best_layout[0],
            num_rows = best_layout[1],
            spacing_x = best_layout[2],
            spacing_y = best_layout[3]
        ) 
        // Generate the final layout based on whether grouping is enabled.
        samples_per_row > 0 && num_rows > 0 ? 
            (enable_grouping ? 
                generate_group_based_layout(samples_per_row, num_rows, use_rotated, best_layout, interior_width, interior_depth, 
                                            sample_w, sample_t, min_spacing, group_count, samples_per_group, group_spacing) :
                generate_simple_rows(num_rows, samples_per_row, use_rotated, spacing_y, sample_w, sample_t)) : 
        [];
    
    // Tests a single sample orientation to see how many samples can fit.
    function test_sample_orientation(interior_width, interior_depth, sample_width_x, sample_width_y, min_spacing, is_rotated) =
        let(
            samples_x = calculate_max_samples_per_direction(interior_width, sample_width_x, min_spacing),
            samples_y = calculate_max_samples_per_direction(interior_depth, sample_width_y, min_spacing),
            
            fits_x = sample_width_x <= interior_width,
            fits_y = sample_width_y <= interior_depth,
            
            valid_samples_x = fits_x ? samples_x : 0,
            valid_samples_y = fits_y ? samples_y : 0,
            
            actual_spacing_x = valid_samples_x > 1 ? 
                max(min_spacing, (interior_width - valid_samples_x * sample_width_x) / (valid_samples_x - 1)) : 0,
            actual_spacing_y = valid_samples_y > 1 ? 
                max(min_spacing, (interior_depth - valid_samples_y * sample_width_y) / (valid_samples_y - 1)) : 0
        ) 
        [valid_samples_x, valid_samples_y, actual_spacing_x, actual_spacing_y];
    
    // Generates a simple layout of evenly spaced rows without any grouping.
    function generate_simple_rows(num_rows, samples_per_row, is_rotated, row_spacing, sample_w, sample_t) =
        [
            for (row_idx = [0:num_rows-1])
                let(
                    sample_depth = is_rotated ? sample_t : sample_w,
                    row_y = row_idx * (sample_depth + row_spacing)
                )
                [row_y, is_rotated, [samples_per_row], sample_depth]
        ];
    
    // The core function for generating layouts with groups.
    function generate_group_based_layout(samples_per_row, num_rows, use_rotated, best_layout, interior_width, interior_depth, 
                                         sample_w, sample_t, min_spacing, group_count, samples_per_group, group_spacing) =
        let(
            sample_width = use_rotated ? sample_w : sample_t,
            sample_depth = use_rotated ? sample_t : sample_w,
            
            effective_samples_per_group = samples_per_group > 0 ? samples_per_group : 
                max(1, floor(samples_per_row / 4)),
            
            max_possible_groups = floor(samples_per_row / effective_samples_per_group),
            groups_per_row = find_max_groups_that_fit(max_possible_groups, effective_samples_per_group, sample_width, 
                                                      min_spacing, group_spacing, interior_width),
            
            groups_fit = groups_per_row > 0,
            
            grouped_rows = groups_fit ? 
                create_grouped_rows(num_rows, groups_per_row, effective_samples_per_group, use_rotated, 
                                    sample_depth, best_layout[3], 0) :
                generate_simple_rows(num_rows, samples_per_row, use_rotated, best_layout[3], sample_w, sample_t)
        )
        grouped_rows;
    
    function find_max_groups_that_fit(max_groups, samples_per_group, sample_width, min_spacing, group_spacing, interior_width) =
        max_groups <= 0 ? 0 :
        check_groups_fit_in_row(max_groups, samples_per_group, sample_width, min_spacing, group_spacing, interior_width) ? 
            max_groups :
            find_max_groups_that_fit(max_groups - 1, samples_per_group, sample_width, min_spacing, group_spacing, interior_width);
    
    function check_groups_fit_in_row(groups_per_row, samples_per_group, sample_width, min_spacing, group_spacing, interior_width) =
        let(
            samples_width = groups_per_row * samples_per_group * sample_width,
            internal_spacing_width = groups_per_row * (samples_per_group - 1) * min_spacing,
            group_spacing_width = (groups_per_row > 1) ? (groups_per_row - 1) * group_spacing : 0,
            total_width_needed = samples_width + internal_spacing_width + group_spacing_width
        )
        total_width_needed <= interior_width;
    
    function create_grouped_rows(num_rows, groups_per_row, samples_per_group, use_rotated, sample_depth, row_spacing, leftover_samples) =
        [
            for (row_idx = [0:num_rows-1])
                let(
                    row_y = row_idx * (sample_depth + row_spacing),
                    groups = [for (i = [0:groups_per_row-1]) samples_per_group]
                )
                [row_y, use_rotated, groups, sample_depth]
        ];
    
    // **FIXED**: Main position generation function.
    // It now correctly calculates the total vertical depth of the layout and passes the final
    // Y-coordinate down to the helper functions, avoiding scope issues.
    function generate_grouped_positions(row_layouts, interior_width, interior_depth, sample_w, sample_t, min_spacing, group_spacing=3.0) =
        len(row_layouts) == 0 ? [] :
        let(
            num_rows = len(row_layouts),
            // All rows in a layout have the same depth. Get it from the first row.
            layout_sample_depth = row_layouts[0][3], 
            // Calculate the spacing between rows by checking the y-offset of the first two rows.
            spacing_y = num_rows > 1 ? (row_layouts[1][0] - row_layouts[0][0] - layout_sample_depth) : 0,
            
            // Calculate the total vertical space used by all rows and their spacings.
            total_depth_used = (num_rows * layout_sample_depth) + (max(0, num_rows - 1) * spacing_y),
            // Calculate the starting Y position to center the entire block of rows.
            layout_start_y = -total_depth_used / 2
        )
        [
            for (row_idx = [0:len(row_layouts)-1])
                let(
                    row = row_layouts[row_idx],
                    row_y_offset_from_start = row[0],
                    is_rotated = row[1],
                    groups = row[2],
                    
                    has_multiple_groups = len(groups) > 1,
                    
                    sample_width = is_rotated ? sample_w : sample_t,
                    sample_depth = is_rotated ? sample_t : sample_w,
                    
                    // Calculate the final absolute Y coordinate for the center of this row.
                    final_centered_row_y = layout_start_y + row_y_offset_from_start + sample_depth/2,
                    
                    // Generate positions for either a grouped row or a simple, single-group row.
                    group_positions = has_multiple_groups ? 
                        generate_grouped_row_positions(groups, sample_width, min_spacing, group_spacing,
                                                       interior_width, final_centered_row_y) :
                        generate_row_sample_positions(groups[0], sample_width, min_spacing,
                                                      interior_width, final_centered_row_y)
                )
                for (pos = group_positions) 
                    [pos[0], pos[1], is_rotated]
        ];
    
    // **FIXED**: Generates positions for a single row of samples.
    // It now receives the final Y-coordinate directly, eliminating out-of-scope variable access.
    function generate_row_sample_positions(samples_in_row, sample_width, min_spacing,
                                         interior_width, centered_row_y) =
        let(
            // This part handles the X-axis centering for the samples within this row.
            total_samples_width = samples_in_row * sample_width,
            available_spacing = interior_width - total_samples_width,
            spacing_between = samples_in_row > 1 ? max(min_spacing, available_spacing / (samples_in_row - 1)) : 0,
            
            actual_width_used = samples_in_row * sample_width + (samples_in_row > 1 ? (samples_in_row - 1) * spacing_between : 0),
            
            start_x = -actual_width_used/2 + sample_width/2
        )
        [
            for (sample_idx = [0:samples_in_row-1])
                [
                    start_x + sample_idx * (sample_width + spacing_between),
                    centered_row_y // The Y position is now passed in directly.
                ]
        ];
    
    
    // **FIXED**: Generates sample positions for a row with multiple groups.
    // Also receives the final Y-coordinate directly.
    function generate_grouped_row_positions(groups, sample_width, min_spacing, group_spacing,
                                          interior_width, centered_row_y) =
        let(
            // This part handles the X-axis centering for the groups within this row.
            total_samples = sum_array(groups),
            groups_count = len(groups),
            
            samples_width = total_samples * sample_width,
            internal_spacing_width = sum_array([for (group_size = groups) max(0, group_size - 1)]) * min_spacing,
            group_spacing_width = groups_count > 1 ? (groups_count - 1) * group_spacing : 0,
            total_layout_width = samples_width + internal_spacing_width + group_spacing_width,
            
            layout_start_x = -total_layout_width/2
        )
        [
            for (group_idx = [0:len(groups)-1])
                let(
                    group_size = groups[group_idx],
                    samples_before = sum_array_up_to_index(groups, group_idx),
                    
                    group_width_before = samples_before * sample_width + 
                                         sum_array_up_to_index([for(s=groups) max(0,s-1)], group_idx) * min_spacing +
                                         (group_idx > 0 ? group_idx * group_spacing : 0),
    
                    group_start_x = layout_start_x + group_width_before
                )
                for (sample_idx = [0:group_size-1])
                    [
                        group_start_x + sample_idx * (sample_width + min_spacing) + sample_width/2,
                        centered_row_y // The Y position is now passed in directly.
                    ]
        ];
    
    // ===== Helper Functions =====
    
    function calculate_max_samples_per_direction(space_size, sample_size, min_spacing) =
        sample_size <= 0 ? 0 : max(0, floor((space_size + min_spacing) / (sample_size + min_spacing)));
    
    function sum_array(arr) = 
        len(arr) == 0 ? 0 : 
        (arr[0] + sum_array([for (i=[1:len(arr)-1]) arr[i]]));
    
    function sum_array_up_to_index(arr, index) =
        index <= 0 ? 0 : sum_array([for (i = [0:index-1]) arr[i]]);
        
    // ===== End: grouping_layout_calculator.scad (Corrected) =====
    // ===== End: grouping_layout_calculator.scad =====

  
  module grouped_sample_cutouts(box_width, box_depth, box_height, l_grid, wall_thickness, side_wall_thickness, 
                                sample_width, sample_thickness, min_spacing, cutout_start_z, row_spacing=0, 
                                enable_grouping=false, group_count=0, samples_per_group=0, group_spacing=3.0) {
      interior_width = (box_width * l_grid) - (2 * wall_thickness);
      interior_depth = (box_depth * l_grid) - (2 * side_wall_thickness);
      
      // Calculate effective row spacing - will be determined during layout if auto (0)
      effective_row_spacing = row_spacing;
      
      echo(str("=== Advanced Grouping Algorithm ==="));
      echo(str("Interior space: ", interior_width, " x ", interior_depth, " mm"));
      echo(str("Sample size: ", sample_thickness, " x ", sample_width, " mm"));
      echo(str("Row spacing: ", row_spacing > 0 ? str(effective_row_spacing, "mm (manual)") : "auto"));
      echo(str("Grouping mode: ", enable_grouping ? "enabled" : "disabled (row-based)"));
      if (enable_grouping) {
          echo(str("Group count: ", group_count > 0 ? group_count : "auto"));
          echo(str("Samples per group: ", samples_per_group > 0 ? samples_per_group : "auto"));
          echo(str("Group spacing: ", group_spacing, "mm"));
      }
      
      row_layouts = calculate_grouped_layout(interior_width, interior_depth, sample_width, sample_thickness, min_spacing, effective_row_spacing, 
                                             enable_grouping, group_count, samples_per_group, group_spacing);
      
      echo(str("Generated ", len(row_layouts), " rows"));
      display_row_info(row_layouts, sample_width, sample_thickness);
      
      positions = generate_grouped_positions(row_layouts, interior_width, interior_depth, sample_width, sample_thickness, min_spacing);
      total_samples = len(positions);
      
      echo(str("Total samples: ", total_samples));
      
      // Validate all positions are within bounds
      validate_positions(positions, interior_width, interior_depth, sample_width, sample_thickness);
      
      for (i = [0:len(positions)-1]) {
          pos = positions[i];
          pos_x = pos[0];
          pos_y = pos[1];
          is_rotated = pos[2];
          
          translate([pos_x, pos_y, box_height - (box_height - cutout_start_z)]) 
              grouped_sample_cutout_shape(is_rotated, sample_width, sample_thickness, box_height, cutout_start_z);
      }
  }
  
  module display_row_info(row_layouts, sample_width, sample_thickness) {
      if (len(row_layouts) > 0) {
          for (i = [0:len(row_layouts)-1]) {
          row = row_layouts[i];
          row_y = row[0];
          is_rotated = row[1];
          groups = row[2];
          total_in_row = sum_array(groups);
          orientation_text = is_rotated ? "rotated" : "normal";
          
          echo(str("Row ", i+1, " (y=", row_y, "): ", total_in_row, " samples, ", orientation_text, " orientation"));
          echo(str("  Groups: ", groups));
          }
      }
  }
  
  module validate_positions(positions, interior_width, interior_depth, sample_width, sample_thickness) {
      if (len(positions) > 0) {
          for (i = [0:len(positions)-1]) {
          pos = positions[i];
          pos_x = pos[0];
          pos_y = pos[1];
          is_rotated = pos[2];
          
          width = is_rotated ? sample_width : sample_thickness;
          depth = is_rotated ? sample_thickness : sample_width;
          
          // Calculate sample bounds
          left_bound = pos_x - width/2;
          right_bound = pos_x + width/2;
          front_bound = pos_y - depth/2;
          back_bound = pos_y + depth/2;
          
          // Assert bounds are within interior limits
          assert(left_bound >= -interior_width/2, 
                 str("Sample ", i, " left bound (", left_bound, ") exceeds interior width limit (", -interior_width/2, ")"));
          assert(right_bound - 0.05 <= interior_width/2, 
                 str("Sample ", i, " right bound (", right_bound, ") exceeds interior width limit (", interior_width/2, ")"));
          assert(front_bound >= -interior_depth/2, 
                 str("Sample ", i, " front bound (", front_bound, ") exceeds interior depth limit (", -interior_depth/2, ")"));
          assert(back_bound <= interior_depth/2, 
                 str("Sample ", i, " back bound (", back_bound, ") exceeds interior depth limit (", interior_depth/2, ")"));
          }
      }
  }
  
  
  module grouped_sample_cutout_shape(is_rotated, sample_width, sample_thickness, box_height, cutout_start_z) {
      width = is_rotated ? sample_width : sample_thickness;
      depth = is_rotated ? sample_thickness : sample_width; 
      
      cutout_height = box_height - cutout_start_z;
      
      translate([-width/2, -depth/2, 0])
          cube([width, depth, cutout_height + 1]);
  }
  // ===== End: grouped_sample_cutouts.scad =====

// Original: use <src/algorithms/grouped_v2.scad>
// Inlining 'use' file (modules/functions only):
  // ===== Begin: grouped_v2.scad =====
  // Original: use <../vallidation.scad>
  // Inlining 'use' file (modules/functions only):
    // ===== Begin: vallidation.scad =====
    module validate_positions(positions, interior_width, interior_depth, sample_width, sample_thickness) {
        if (len(positions) > 0) {
            for (i = [0:len(positions)-1]) {
              pos = positions[i];
    
              pos_x = pos[0];
              pos_y = pos[1];
              is_rotated = pos[2];
    
              validate_position(pos_x = pos_x, pos_y = pos_y, is_rotated = is_rotated, sample_width = sample_width, sample_thickness = sample_thickness, interior_width = interior_width, interior_depth = interior_depth);
            }
        }
    }
    
    module validate_position(pos_x, pos_y, is_rotated, sample_width, sample_thickness, interior_width, interior_depth) {
        pos_x = pos[0];
        pos_y = pos[1];
        is_rotated = pos[2];
        
        width = is_rotated ? sample_width : sample_thickness;
        depth = is_rotated ? sample_thickness : sample_width;
        
        left_bound = pos_x - width/2;
        right_bound = pos_x + width/2;
        front_bound = pos_y - depth/2;
        back_bound = pos_y + depth/2;
        
        assert(left_bound >= -interior_width/2, 
                str("Sample ", i, " left bound (", left_bound, ") exceeds interior width limit (", -interior_width/2, ")"));
        assert(right_bound - 0.05 <= interior_width/2, 
                str("Sample ", i, " right bound (", right_bound, ") exceeds interior width limit (", interior_width/2, ")"));
        assert(front_bound >= -interior_depth/2, 
                str("Sample ", i, " front bound (", front_bound, ") exceeds interior depth limit (", -interior_depth/2, ")"));
        assert(back_bound <= interior_depth/2, 
                str("Sample ", i, " back bound (", back_bound, ") exceeds interior depth limit (", interior_depth/2, ")"));
    }
    // ===== End: vallidation.scad =====

  
  module grouped_v2(box_width, box_depth, box_height, l_grid, wall_thickness, side_wall_thickness, sample_width, sample_thickness, min_spacing, cutout_start_z, row_spacing=0, enable_grouping=false, group_count=0, samples_per_group=0, group_spacing=10.0, enable_labels=false, include_first_group_label=false, label_text_mode="auto", label_custom_text="", label_position="center", label_width=76.0, label_height=10.0, label_thickness=1.5, magnet_diameter=6.0, magnet_thickness=2.0, magnet_count=2, text_style="embossed", text_depth=0.4, font_size=0, font_family="Liberation Sans:style=Bold", force_orientation="auto") {
    
      interior_width = (box_width * l_grid) - (2 * wall_thickness);
      interior_depth = (box_depth * l_grid) - (2 * side_wall_thickness);
  
      echo(str("=== Grouped V2 Single-Pass Algorithm ==="));
      echo(str("Interior space: ", interior_width, " x ", interior_depth, " mm"));
      echo(str("Sample size: ", sample_thickness, " x ", sample_width, " mm"));
      echo(str("Enable grouping: ", enable_grouping));
      echo(str("Group count: ", group_count, ", Samples per group: ", samples_per_group));
      echo(str("Enable labels: ", enable_labels, ", Mode: ", label_text_mode, ", Position: ", label_position));
      echo(str("Sample fits normal (", sample_thickness, "x", sample_width, "): width=", sample_thickness <= interior_width, " depth=", sample_width <= interior_depth));
      echo(str("Sample fits rotated (", sample_width, "x", sample_thickness, "): width=", sample_width <= interior_width, " depth=", sample_thickness <= interior_depth));
  
      // If grouping is disabled or both group parameters are 0, use simple layout
      use_simple_layout = !enable_grouping || (group_count == 0 && samples_per_group == 0);
      
      positions = use_simple_layout ? 
          generate_simple_layout(interior_width, interior_depth, sample_width, sample_thickness, min_spacing, row_spacing, force_orientation) :
          generate_single_pass_layout(interior_width, interior_depth, sample_width, sample_thickness, 
                                    min_spacing, group_count, samples_per_group, group_spacing, row_spacing, include_first_group_label, force_orientation);
      
      echo(str("Generated ", len(positions), " sample positions"));
      
      for (i = [0:len(positions)-1]) {
          pos = positions[i];
          pos_x = pos[0];
          pos_y = pos[1];
          is_rotated = pos[2];
          
          translate([pos_x, pos_y, box_height - (box_height - cutout_start_z)]) 
              sample_cutout_shape(is_rotated, sample_width, sample_thickness, box_height, cutout_start_z);
      }
      
      // Generate label magnet holes if labels are enabled - this is the final step
      if (enable_labels && len(positions) > 0) {
          // Now positions contains ALL final sample positions across all rows
          label_positions = calculate_label_positions(positions, group_spacing, label_position, 
                                                     label_height, label_width, sample_width, sample_thickness, include_first_group_label);
          
          if (len(label_positions) > 0) {
              echo(str("Generated ", len(label_positions), " label positions"));
              
              for (i = [0:len(label_positions)-1]) {
                  label_pos = label_positions[i];
                  label_x = label_pos[0];
                  label_y = label_pos[1];
                  is_rotated = label_pos[2];
                  
                  // Create magnet holes for this label
                  create_label_magnet_holes(label_x, label_y, is_rotated, label_height, label_width, 
                                          magnet_diameter, magnet_thickness, magnet_count, 
                                          box_height, cutout_start_z);
              }
          }
      }
  }
  
  function samples_fit_in_dimension(available_space, sample_size, min_spacing) =
      sample_size > available_space ? 0 :
      1 + floor((available_space - sample_size) / (sample_size + min_spacing));
  
  function generate_simple_layout(interior_width, interior_depth, sample_width, sample_thickness, min_spacing, row_spacing, force_orientation="auto") =
      let(
          // Test both orientations to see which one allows more samples total
          normal_layout = test_simple_orientation(interior_width, interior_depth, sample_thickness, sample_width, min_spacing, row_spacing, false),
          rotated_layout = test_simple_orientation(interior_width, interior_depth, sample_width, sample_thickness, min_spacing, row_spacing, true),
          
          normal_total = len(normal_layout),
          rotated_total = len(rotated_layout),
          
          // Choose orientation based on force_orientation parameter
          use_rotated = force_orientation == "rotated" ? true :
                       force_orientation == "normal" ? false :
                       rotated_total > normal_total,  // auto: choose best fit
          final_layout = use_rotated ? rotated_layout : normal_layout,
          
          orientation_msg = str("Simple orientation selection: force_orientation=", force_orientation, 
                               ", normal_total=", normal_total, ", rotated_total=", rotated_total, 
                               ", use_rotated=", use_rotated)
      )
      echo(orientation_msg)
      final_layout;
  
  function test_simple_orientation(interior_width, interior_depth, sample_w, sample_d, min_spacing, row_spacing, is_rotated) =
      let(
          sample_fits_width = sample_w <= interior_width,
          sample_fits_depth = sample_d <= interior_depth,
          orientation_works = sample_fits_width && sample_fits_depth
      )
      !orientation_works ? [] :
      let(
          // Calculate how many samples fit in each direction
          // First sample takes sample_w, each additional sample takes (sample_w + min_spacing)
          samples_across = samples_fit_in_dimension(interior_width, sample_w, min_spacing),
          samples_along = samples_fit_in_dimension(interior_depth, sample_d, min_spacing),
          
          // Calculate total samples
          total_samples = samples_across * samples_along,
          
          // Calculate actual spacing (spread samples to use full space if row_spacing is 0)
          actual_spacing_x = samples_across > 1 ? 
              (row_spacing == 0 ? (interior_width - samples_across * sample_w) / (samples_across - 1) : 
               max(min_spacing, (interior_width - samples_across * sample_w) / (samples_across - 1))) : 0,
          actual_spacing_y = samples_along > 1 ? 
              (row_spacing == 0 ? (interior_depth - samples_along * sample_d) / (samples_along - 1) : 
               max(min_spacing, (interior_depth - samples_along * sample_d) / (samples_along - 1))) : 0,
               
          // Calculate starting positions to center the layout
          start_x = samples_across > 1 ? 
              -(samples_across - 1) * (sample_w + actual_spacing_x) / 2 : 0,
          start_y = samples_along > 1 ? 
              -(samples_along - 1) * (sample_d + actual_spacing_y) / 2 : 0
      )
      echo(str("Simple layout - orientation ", is_rotated ? "rotated" : "normal", ": ", samples_across, "x", samples_along, " = ", total_samples, " samples"))
      [
          for (y = [0:samples_along-1])
              for (x = [0:samples_across-1])
                  [start_x + x * (sample_w + actual_spacing_x), start_y + y * (sample_d + actual_spacing_y), is_rotated]
      ];
  
  function generate_single_pass_layout(interior_width, interior_depth, sample_width, sample_thickness, 
                                     min_spacing, group_count, samples_per_group, group_spacing, row_spacing, include_first_group_label=false, force_orientation="auto") =
      let(
          // Test both orientations to see which one allows more samples total
          // Normal: thickness along X, width along Y  
          normal_layout = test_orientation_layout(interior_width, interior_depth, sample_thickness, sample_width, 
                                                 min_spacing, group_count, samples_per_group, group_spacing, row_spacing, false, include_first_group_label),
          // Rotated: width along X, thickness along Y
          rotated_layout = test_orientation_layout(interior_width, interior_depth, sample_width, sample_thickness, 
                                                  min_spacing, group_count, samples_per_group, group_spacing, row_spacing, true, include_first_group_label),
          
          normal_total = len(normal_layout),
          rotated_total = len(rotated_layout),
          
          // Choose orientation based on force_orientation parameter
          use_rotated = force_orientation == "rotated" ? true :
                       force_orientation == "normal" ? false :
                       rotated_total > normal_total,  // auto: choose best fit
          final_layout = use_rotated ? rotated_layout : normal_layout,
          
          orientation_msg = str("Orientation selection: force_orientation=", force_orientation, 
                               ", normal_total=", normal_total, ", rotated_total=", rotated_total, 
                               ", use_rotated=", use_rotated)
      )
      echo(orientation_msg)
      final_layout;
  
  function test_orientation_layout(interior_width, interior_depth, sample_w, sample_d, 
                                  min_spacing, group_count, samples_per_group, group_spacing, row_spacing, is_rotated, include_first_group_label=false) =
      let(
          // Check if samples fit in this orientation
          sample_fits_width = sample_w <= interior_width,
          sample_fits_depth = sample_d <= interior_depth,
          
          orientation_works = sample_fits_width && sample_fits_depth,
          
          debug_msg = str("Testing orientation ", is_rotated ? "rotated" : "normal", 
                         " (", sample_w, "x", sample_d, "): fits=", orientation_works)
      )
      echo(debug_msg)
      !orientation_works ? [] :
      let(
          // Determine which dimension should be used for grouping (the one that fits more samples)
          // When grouping along width: samples use min_spacing, rows use row_spacing
          // When grouping along depth: samples use min_spacing, cols use row_spacing  
          samples_along_width = floor(interior_width / (sample_w + min_spacing)),
          samples_along_depth = floor(interior_depth / (sample_d + min_spacing)),
          group_along_width = samples_along_width >= samples_along_depth,
          
          grouping_msg = str("    Grouping analysis: samples_along_width=", samples_along_width, 
                            ", samples_along_depth=", samples_along_depth, 
                            ", grouping_direction=", group_along_width ? "width" : "depth")
      )
      echo(grouping_msg)
      let(
          // Calculate layout based on grouping direction
          layout_data = group_along_width ?
              generate_width_grouped_layout(interior_width, interior_depth, sample_w, sample_d, 
                                          min_spacing, group_count, samples_per_group, group_spacing, row_spacing, is_rotated, include_first_group_label) :
              generate_depth_grouped_layout(interior_width, interior_depth, sample_w, sample_d, 
                                          min_spacing, group_count, samples_per_group, group_spacing, row_spacing, is_rotated, include_first_group_label)
      )
      layout_data;
  
  function generate_width_grouped_layout(interior_width, interior_depth, sample_w, sample_d, 
                                        min_spacing, group_count, samples_per_group, group_spacing, row_spacing, is_rotated, include_first_group_label=false) =
      let(
          // Group across the width (X-axis) - use the correct sample dimension for X-axis
          sample_x_dim = sample_w, // sample_w is already the X-dimension for the given orientation
          first_row_data = generate_first_row_positions(interior_width, sample_x_dim, min_spacing, 
                                                      group_count, samples_per_group, group_spacing, include_first_group_label),
          first_row_positions = first_row_data[0],
          row_width = first_row_data[1],
          
          // Calculate how many rows fit using row_spacing (or auto-calculate if row_spacing is 0)
          rows_that_fit = row_spacing == 0 ? 
              floor(interior_depth / sample_d) :  // Auto: pack as many rows as possible, then distribute spacing
              floor(interior_depth / (sample_d + row_spacing)),
          
          debug_msg2 = str("  Width grouping - First row: ", len(first_row_positions), " positions, rows_fit: ", rows_that_fit)
      )
      echo(debug_msg2)
      let(
          // Generate all positions by copying first row with Y offsets
          all_positions = generate_all_row_positions(first_row_positions, rows_that_fit, sample_d, 
                                                   row_spacing, interior_depth, is_rotated)
      )
      all_positions;
  
  function generate_depth_grouped_layout(interior_width, interior_depth, sample_w, sample_d, 
                                        min_spacing, group_count, samples_per_group, group_spacing, row_spacing, is_rotated, include_first_group_label=false) =
      let(
          // Group across the depth (Y-axis) - for rotated samples, first group label spacing is in Y direction
          // So we need to reduce interior_depth instead of interior_width
          effective_interior_depth = include_first_group_label ? interior_depth - group_spacing : interior_depth,
          first_col_data = generate_first_col_positions(effective_interior_depth, sample_d, min_spacing, 
                                                       group_count, samples_per_group, group_spacing, include_first_group_label),
          first_col_positions = first_col_data[0],
          col_depth = first_col_data[1],
          
          // Calculate how many columns fit using row_spacing (or auto-calculate if row_spacing is 0)
          cols_that_fit = row_spacing == 0 ? 
              floor(interior_width / sample_w) :  // Auto: pack as many cols as possible, then distribute spacing
              floor(interior_width / (sample_w + row_spacing)),
          
          debug_msg2 = str("  Depth grouping - First col: ", len(first_col_positions), " positions, cols_fit: ", cols_that_fit)
      )
      echo(debug_msg2)
      let(
          // Generate all positions by copying first column with X offsets
          all_positions = generate_all_col_positions(first_col_positions, cols_that_fit, sample_w, 
                                                    row_spacing, interior_width, is_rotated)
      )
      all_positions;
  
  function generate_all_col_positions(first_col_y_positions, num_cols, sample_width, row_spacing, interior_width, use_rotated) =
      let(
          // Calculate actual spacing (auto-distribute if row_spacing is 0)
          actual_spacing = row_spacing == 0 && num_cols > 1 ? 
              (interior_width - num_cols * sample_width) / (num_cols - 1) : row_spacing,
          // Calculate X positions for each column
          total_cols_width = num_cols * sample_width + max(0, num_cols - 1) * actual_spacing,
          start_x = -total_cols_width / 2 + sample_width / 2
      )
      [
          for (col_idx = [0:num_cols-1])
              let(
                  col_x = start_x + col_idx * (sample_width + actual_spacing)
              )
              for (y_data = first_col_y_positions)
                  let(
                      y_pos = y_data[0],
                      original_group_id = y_data[1],
                      // Make group_id unique across columns by adding column offset
                      max_groups_per_col = max([for (data = first_col_y_positions) data[1]]) + 1,
                      unique_group_id = original_group_id + (col_idx * max_groups_per_col)
                  )
                  [col_x, y_pos, use_rotated, unique_group_id]
      ];
  
  // Generate positions for the first column (for depth grouping - rotated samples)
  function generate_first_col_positions(interior_depth, sample_depth, min_spacing, group_count, samples_per_group, group_spacing, include_first_group_label=false) =
      let(
          // Reduce available depth if we need to reserve space for first group label
          available_depth = include_first_group_label ? interior_depth - group_spacing : interior_depth,
          max_samples_per_col = floor(available_depth / (sample_depth + min_spacing)),
          
          debug_msg = str("    Max samples per col: ", max_samples_per_col, " (available_depth: ", available_depth, ", interior_depth: ", interior_depth, ", include_first_group_label: ", include_first_group_label, ", group_spacing: ", group_spacing, ")")
      )
      echo(debug_msg)
      let(
          // Auto-calculate group settings if not specified
          grouping_mode_msg = str("    Grouping mode: ", group_count == 0 ? "auto" : "manual", 
                                 " (requested: groups=", group_count, ", samples_per_group=", samples_per_group, ")")
      )
      echo(grouping_mode_msg)
      let(
          auto_data = group_count == 0 ? 
              calculate_auto_grouping(max_samples_per_col, sample_depth, min_spacing, group_spacing, available_depth, samples_per_group) :
              [group_count, samples_per_group > 0 ? samples_per_group : max(1, floor(max_samples_per_col / group_count))],
          
          effective_group_count = auto_data[0],
          effective_samples_per_group = auto_data[1],
          
          debug_msg2 = str("    Effective groups: ", effective_group_count, ", samples per group: ", effective_samples_per_group)
      )
      echo(debug_msg2)
      let(
          // Generate positions for each group - pass original samples_per_group to preserve user intent
          group_data = generate_groups_in_col(effective_group_count, effective_samples_per_group, 
                                            sample_depth, min_spacing, group_spacing, available_depth, samples_per_group, group_count, include_first_group_label),
          positions = group_data[0],
          total_depth = group_data[1]
      )
      [positions, total_depth];
  
  function generate_first_row_positions(interior_width, sample_width, min_spacing, group_count, samples_per_group, group_spacing, include_first_group_label=false) =
      let(
          // Reduce available width if we need to reserve space for first group label
          available_width = include_first_group_label ? interior_width - group_spacing : interior_width,
          max_samples_per_row = floor(available_width / (sample_width + min_spacing)),
          
          debug_msg = str("    Max samples per row: ", max_samples_per_row, " (available_width: ", available_width, ", interior_width: ", interior_width, ", include_first_group_label: ", include_first_group_label, ", group_spacing: ", group_spacing, ")")
      )
      echo(debug_msg)
      let(
          // Auto-calculate group settings if not specified
          grouping_mode_msg = str("    Grouping mode: ", group_count == 0 ? "auto" : "manual", 
                                 " (requested: groups=", group_count, ", samples_per_group=", samples_per_group, ")")
      )
      echo(grouping_mode_msg)
      let(
          auto_data = group_count == 0 ? 
              calculate_auto_grouping(max_samples_per_row, sample_width, min_spacing, group_spacing, available_width, samples_per_group) :
              [group_count, samples_per_group > 0 ? samples_per_group : max(1, floor(max_samples_per_row / group_count))],
          
          effective_group_count = auto_data[0],
          effective_samples_per_group = auto_data[1],
          
          debug_msg2 = str("    Effective groups: ", effective_group_count, ", samples per group: ", effective_samples_per_group)
      )
      echo(debug_msg2)
      let(
          // Generate positions for each group - pass original samples_per_group to preserve user intent
          group_data = generate_groups_in_row(effective_group_count, effective_samples_per_group, 
                                            sample_width, min_spacing, group_spacing, available_width, samples_per_group, group_count, include_first_group_label),
          positions = group_data[0],
          total_width = group_data[1]
      )
      [positions, total_width];
  
  function calculate_auto_grouping(max_samples_per_row, sample_width, min_spacing, group_spacing, interior_width, requested_samples_per_group) =
      requested_samples_per_group > 0 ?
          // If samples_per_group is specified, use it and find max groups
          let(
              max_groups = find_max_fitting_groups_for_size(requested_samples_per_group, sample_width, 
                                                          min_spacing, group_spacing, interior_width)
          )
          [max_groups, requested_samples_per_group] :
          // Auto mode: maximize number of groups by starting with 1 sample per group
          maximize_group_count(max_samples_per_row, sample_width, min_spacing, group_spacing, interior_width);
  
  function maximize_group_count(max_samples_per_row, sample_width, min_spacing, group_spacing, interior_width) =
      let(
          // Start with 1 sample per group and find maximum groups
          max_groups_with_1 = find_max_fitting_groups_for_size(1, sample_width, min_spacing, group_spacing, interior_width),
          
          // Check if we can fit more samples per group while maintaining good group count
          samples_per_group = max_groups_with_1 > 1 ? 
              // If we have multiple groups, try to balance groups vs samples per group
              find_optimal_samples_per_group(max_groups_with_1, max_samples_per_row, sample_width, min_spacing, group_spacing, interior_width) :
              // If only 1 group fits, put all samples in it
              max_samples_per_row,
              
          final_groups = samples_per_group == max_samples_per_row ? 1 : max_groups_with_1
      )
      [final_groups, samples_per_group];
  
  function find_optimal_samples_per_group(preferred_group_count, max_samples_per_row, sample_width, min_spacing, group_spacing, interior_width) =
      let(
          // Try 2 samples per group, then 3, etc., but prioritize keeping the group count high
          samples_with_2 = check_groups_fit_in_row(preferred_group_count, 2, sample_width, min_spacing, group_spacing, interior_width) ? 2 : 1,
          samples_with_3 = samples_with_2 == 2 && check_groups_fit_in_row(preferred_group_count, 3, sample_width, min_spacing, group_spacing, interior_width) ? 3 : samples_with_2
      )
      samples_with_3;
  
  function find_max_fitting_groups_for_size(samples_per_group, sample_width, min_spacing, group_spacing, interior_width) =
      let(
          // First check if even one group with this many samples fits
          single_group_width = samples_per_group * sample_width + max(0, samples_per_group - 1) * min_spacing,
          one_group_fits = single_group_width <= interior_width
      )
      !one_group_fits ? 
          // If the requested samples_per_group doesn't fit in one group, find max that does fit and try with that
          let(
              max_samples_that_fit = floor((interior_width + min_spacing) / (sample_width + min_spacing)),
              adjusted_samples = max(1, max_samples_that_fit)
          )
          find_max_fitting_groups_for_size(adjusted_samples, sample_width, min_spacing, group_spacing, interior_width) :
          // If it fits, calculate how many such groups we can have
          let(
              // Estimate maximum possible groups
              max_possible_groups = floor(interior_width / (single_group_width + group_spacing)) + 1
          )
          find_max_fitting_groups(max_possible_groups, samples_per_group, sample_width, min_spacing, group_spacing, interior_width);
  
  // Generate groups in a column (for depth grouping)
  function generate_groups_in_col(group_count, samples_per_group, sample_depth, min_spacing, group_spacing, interior_depth, original_samples_per_group=0, original_group_count=0, include_first_group_label=false) =
      let(
          // Try to fit all requested groups first
          positions_data = try_fit_groups_with_adjustment(group_count, samples_per_group, sample_depth, 
                                                        min_spacing, group_spacing, interior_depth, original_samples_per_group, original_group_count, include_first_group_label),
          positions = positions_data[0],
          actual_group_count = positions_data[1],
          actual_samples_per_group = positions_data[2],
          
          actual_depth = calculate_actual_width(actual_group_count, actual_samples_per_group, sample_depth, 
                                              min_spacing, group_spacing),
          
          // Apply Y-direction offset for column grouping when first group label is enabled
          final_positions = include_first_group_label ? 
              [for (pos = positions) [pos[0], pos[1] + group_spacing/2]] : positions
      )
      [final_positions, actual_depth];
  
  function generate_groups_in_row(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group=0, original_group_count=0, include_first_group_label=false) =
      let(
          // Try to fit all requested groups first
          positions_data = try_fit_groups_with_adjustment(group_count, samples_per_group, sample_width, 
                                                        min_spacing, group_spacing, interior_width, original_samples_per_group, original_group_count, include_first_group_label),
          positions = positions_data[0],
          actual_group_count = positions_data[1],
          actual_samples_per_group = positions_data[2],
          
          actual_width = calculate_actual_width(actual_group_count, actual_samples_per_group, sample_width, 
                                              min_spacing, group_spacing)
      )
      [positions, actual_width];
  
  function try_fit_groups_with_adjustment(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group=0, original_group_count=0, include_first_group_label=false) =
      let(
          // First try with requested settings
          fits_as_requested = check_groups_fit_in_row(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width),
          
          total_width_needed = group_count * samples_per_group * sample_width + 
                             group_count * max(0, samples_per_group - 1) * min_spacing + 
                             max(0, group_count - 1) * group_spacing,
          
          fit_msg = str("      Initial fit check: groups=", group_count, ", samples_per_group=", samples_per_group, 
                       ", width_needed=", total_width_needed, ", available=", interior_width, ", fits=", fits_as_requested)
      )
      echo(fit_msg)
      fits_as_requested ? 
          // If it fits, check if we should try to add partial groups (when group_count was auto-calculated)
          let(
              auto_group_mode = original_group_count == 0,
              success_msg = str("      ✓ Groups fit as requested - auto_group_mode=", auto_group_mode)
          )
          echo(success_msg)
          auto_group_mode ?
              // In auto-group mode, try to add one more group (will create partial group if space allows)
              let(
                  auto_partial_msg = str("      Auto-group mode: trying ", group_count + 1, " groups to maximize usage")
              )
              echo(auto_partial_msg)
              fit_partial_groups(group_count + 1, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group, original_group_count, include_first_group_label) :
              // In manual mode, just generate positions as requested
              [apply_first_group_offset(generate_group_positions(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width), include_first_group_label, group_spacing), 
               group_count, samples_per_group] :
          // If it doesn't fit, try reducing samples per group first, then group count
          let(
              adjust_msg = str("      ✗ Groups don't fit - starting adjustment process")
          )
          echo(adjust_msg)
          adjust_to_fit(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group, original_group_count);
  
  function adjust_to_fit(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group=0, original_group_count=0) =
      let(
          // When user specifies samples_per_group > 0, respect it and go directly to partial groups
          // Only allow reduction of samples_per_group when it was auto-calculated (samples_per_group == 0 originally)
          respect_user_samples = original_samples_per_group > 0,
          
          respect_msg = str("        Original samples_per_group=", original_samples_per_group, ", effective=", samples_per_group, ", respect_user_samples=", respect_user_samples)
      )
      echo(respect_msg)
      respect_user_samples ?
          // User specified samples per group - go directly to partial groups to maintain sample count
          let(
              partial_msg = str("        ✗ Respecting user's samples_per_group=", samples_per_group, " - using partial groups")
          )
          echo(partial_msg)
          fit_partial_groups(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group, original_group_count) :
          // Auto-calculated samples per group - we can adjust it
          let(
              adjusted_samples = find_max_samples_per_group_for_groups(group_count, sample_width, min_spacing, group_spacing, interior_width),
              
              adjust_samples_msg = str("        Auto-calculated mode: trying to keep all ", group_count, " groups: max_samples_per_group=", adjusted_samples)
          )
          echo(adjust_samples_msg)
          adjusted_samples > 0 ?
              // If we can fit all groups with fewer samples per group, do that
              let(
                  samples_adjust_msg = str("        ✓ Adjusted samples per group from ", samples_per_group, " to ", adjusted_samples, " - keeping all ", group_count, " groups")
              )
              echo(samples_adjust_msg)
              [apply_first_group_offset(generate_group_positions(group_count, adjusted_samples, sample_width, min_spacing, group_spacing, interior_width), include_first_group_label, group_spacing),
               group_count, adjusted_samples] :
              // If groups don't fit, find how many complete groups + partial group we can fit
              let(
                  partial_msg = str("        ✗ Can't fit all ", group_count, " groups - trying partial groups")
              )
              echo(partial_msg)
              fit_partial_groups(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group, original_group_count, include_first_group_label);
  
  function fit_partial_groups(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group=0, original_group_count=0, include_first_group_label=false) =
      let(
          // Find the maximum number of complete groups that fit
          max_complete_groups = find_max_fitting_groups(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width),
          
          complete_groups_msg = str("          Max complete groups that fit: ", max_complete_groups, " out of ", group_count, " requested")
      )
      echo(complete_groups_msg)
      let(
          // Calculate space used by complete groups
          complete_groups_width = max_complete_groups > 0 ? 
              calculate_actual_width(max_complete_groups, samples_per_group, sample_width, min_spacing, group_spacing) : 0,
          
          // Calculate remaining space for partial group
          remaining_width = interior_width - complete_groups_width - (max_complete_groups > 0 ? group_spacing : 0),
          
          space_calc_msg = str("          Space calculation: complete_groups_width=", complete_groups_width, 
                              ", remaining_width=", remaining_width, " (interior=", interior_width, ")")
      )
      echo(space_calc_msg)
      let(
          // Calculate how many samples fit in the remaining space (partial group)
          partial_group_samples = remaining_width > sample_width ? 
              samples_fit_in_dimension(remaining_width, sample_width, min_spacing) : 0,
          
          partial_calc_msg = str("          Partial group calculation: remaining_width=", remaining_width, 
                                ", sample_width=", sample_width, ", partial_samples=", partial_group_samples)
      )
      echo(partial_calc_msg)
      let(
          // Total groups (complete + partial if any)
          total_groups = max_complete_groups + (partial_group_samples > 0 ? 1 : 0),
          
          debug_msg = str("          Final partial fit: ", max_complete_groups, " complete groups (", samples_per_group, " each), ", 
                         partial_group_samples, " in partial group = ", total_groups, " total groups")
      )
      echo(debug_msg)
      total_groups > 0 ?
          // Generate positions for complete groups + partial group
          let(
              generation_msg = str("          Generating mixed positions: ", max_complete_groups, " complete + ", 
                                  (partial_group_samples > 0 ? 1 : 0), " partial = ", total_groups, " groups")
          )
          echo(generation_msg)
          [apply_first_group_offset(generate_mixed_group_positions(max_complete_groups, samples_per_group, partial_group_samples, 
                                                                   sample_width, min_spacing, group_spacing, interior_width), include_first_group_label, group_spacing),
           total_groups, samples_per_group] :
          // If nothing fits, return empty
          let(
              fail_msg = str("          ✗ No groups fit at all - returning empty")
          )
          echo(fail_msg)
          [[], 0, 0];
  
  function generate_individual_sample_positions(num_samples, sample_width, min_spacing, interior_width) =
      let(
          // Calculate positions for individual samples (not grouped)
          total_width = num_samples * sample_width + max(0, num_samples - 1) * min_spacing,
          start_x = -total_width / 2 + sample_width / 2
      )
      [
          for (i = [0:num_samples-1])
              [start_x + i * (sample_width + min_spacing), 0]  // group_id = 0 for individual samples
      ];
  
  function generate_mixed_group_positions(complete_groups, samples_per_group, partial_group_samples, sample_width, min_spacing, group_spacing, interior_width) =
      let(
          // Generate complete groups first - but need to recalculate their positions to account for partial group
          complete_width = complete_groups > 0 ? 
              calculate_actual_width(complete_groups, samples_per_group, sample_width, min_spacing, group_spacing) : 0,
          
          // Calculate partial group width
          partial_width = partial_group_samples > 0 ? 
              partial_group_samples * sample_width + max(0, partial_group_samples - 1) * min_spacing : 0,
          
          // Calculate total layout width including group spacing
          total_group_spacing = (complete_groups > 0 && partial_group_samples > 0) ? group_spacing : 0,
          total_layout_width = complete_width + total_group_spacing + partial_width,
          
          layout_msg = str("            Layout widths: complete=", complete_width, ", partial=", partial_width, 
                          ", spacing=", total_group_spacing, ", total=", total_layout_width)
      )
      echo(layout_msg)
      let(
          // Center the entire layout
          layout_start_x = -total_layout_width / 2,
          
          positioning_msg = str("            Positioning: layout_start_x=", layout_start_x)
      )
      echo(positioning_msg)
      let(
          // Generate complete groups with adjusted positioning
          complete_positions = complete_groups > 0 ? 
              generate_group_positions_at_offset(complete_groups, samples_per_group, sample_width, min_spacing, group_spacing, layout_start_x) : [],
          
          complete_msg = str("            Generated ", len(complete_positions), " positions from ", complete_groups, " complete groups")
      )
      echo(complete_msg)
      let(
          // Calculate partial group start position
          partial_start_x = layout_start_x + complete_width + total_group_spacing + sample_width/2,
          
          // Generate partial group positions
          partial_positions = partial_group_samples > 0 ? 
              [for (i = [0:partial_group_samples-1])
                  [partial_start_x + i * (sample_width + min_spacing), complete_groups]  // group_id = complete_groups
              ] : [],
          
          partial_msg = str("            Generated ", len(partial_positions), " positions from partial group (", 
                           partial_group_samples, " samples, start_x=", partial_start_x, ")")
      )
      echo(partial_msg)
      let(
          final_positions = concat(complete_positions, partial_positions),
          
          final_msg = str("            Total positions generated: ", len(final_positions))
      )
      echo(final_msg)
      final_positions;
  
  function generate_group_positions_at_offset(group_count, samples_per_group, sample_width, min_spacing, group_spacing, start_x_offset) =
      [
          for (group_idx = [0:group_count-1])
              let(
                  // Calculate X offset for this group
                  samples_before = group_idx * samples_per_group,
                  spacing_before = group_idx * max(0, samples_per_group - 1) * min_spacing,
                  group_spacing_before = group_idx * group_spacing,
                  group_start_x = start_x_offset + samples_before * sample_width + spacing_before + group_spacing_before
              )
              for (sample_idx = [0:samples_per_group-1])
                  [group_start_x + sample_idx * (sample_width + min_spacing) + sample_width/2, group_idx]
      ];
  
  function find_max_samples_per_group_for_groups(group_count, sample_width, min_spacing, group_spacing, interior_width) =
      group_count <= 0 ? 0 :
      let(
          // Calculate available width per group
          group_spacing_total = max(0, group_count - 1) * group_spacing,
          available_width = interior_width - group_spacing_total,
          available_per_group = available_width / group_count,
          
          // Calculate max samples that fit in this width
          max_samples = floor((available_per_group + min_spacing) / (sample_width + min_spacing))
      )
      max(0, max_samples);
  
  function check_groups_fit_in_row(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width) =
      let(
          samples_width = group_count * samples_per_group * sample_width,
          internal_spacing_width = group_count * max(0, samples_per_group - 1) * min_spacing,
          group_spacing_width = (group_count > 1) ? (group_count - 1) * group_spacing : 0,
          total_width_needed = samples_width + internal_spacing_width + group_spacing_width
      )
      total_width_needed <= interior_width;
  
  function find_max_fitting_groups(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width) =
      group_count <= 0 ? 0 :
      let(
          samples_width = group_count * samples_per_group * sample_width,
          internal_spacing = group_count * max(0, samples_per_group - 1) * min_spacing,
          group_spacings = max(0, group_count - 1) * group_spacing,
          total_width = samples_width + internal_spacing + group_spacings
      )
      total_width <= interior_width ? group_count :
      find_max_fitting_groups(group_count - 1, samples_per_group, sample_width, min_spacing, group_spacing, interior_width);
  
  function generate_group_positions(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width) =
      let(
          total_width = calculate_actual_width(group_count, samples_per_group, sample_width, min_spacing, group_spacing),
          start_x = -total_width / 2,
          
          gen_msg = str("            Generating regular group positions: groups=", group_count, ", samples_per_group=", samples_per_group, 
                       ", total_width=", total_width, ", start_x=", start_x)
      )
      echo(gen_msg)
      [
          for (group_idx = [0:group_count-1])
              let(
                  // Calculate X offset for this group
                  samples_before = group_idx * samples_per_group,
                  spacing_before = group_idx * max(0, samples_per_group - 1) * min_spacing,
                  group_spacing_before = group_idx * group_spacing,
                  group_start_x = start_x + samples_before * sample_width + spacing_before + group_spacing_before
              )
              for (sample_idx = [0:samples_per_group-1])
                  [group_start_x + sample_idx * (sample_width + min_spacing) + sample_width/2, group_idx]
      ];
  
  function calculate_actual_width(group_count, samples_per_group, sample_width, min_spacing, group_spacing) =
      group_count <= 0 ? 0 :
      group_count * samples_per_group * sample_width + 
      group_count * max(0, samples_per_group - 1) * min_spacing + 
      max(0, group_count - 1) * group_spacing;
  
  function generate_all_row_positions(first_row_x_positions, num_rows, sample_depth, row_spacing, interior_depth, use_rotated) =
      let(
          // Calculate actual spacing (auto-distribute if row_spacing is 0)
          actual_spacing = row_spacing == 0 && num_rows > 1 ? 
              (interior_depth - num_rows * sample_depth) / (num_rows - 1) : row_spacing,
          // Calculate Y positions for each row
          total_rows_depth = num_rows * sample_depth + max(0, num_rows - 1) * actual_spacing,
          start_y = -total_rows_depth / 2 + sample_depth / 2
      )
      [
          for (row_idx = [0:num_rows-1])
              let(
                  row_y = start_y + row_idx * (sample_depth + actual_spacing)
              )
              for (x_data = first_row_x_positions)
                  let(
                      x_pos = x_data[0],
                      original_group_id = x_data[1],
                      // Make group_id unique across rows by adding row offset
                      max_groups_per_row = max([for (data = first_row_x_positions) data[1]]) + 1,
                      unique_group_id = original_group_id + (row_idx * max_groups_per_row)
                  )
                  [x_pos, row_y, use_rotated, unique_group_id]
      ];
  
  module sample_cutout_shape(is_rotated, sample_width, sample_thickness, box_height, cutout_start_z) {
      width = is_rotated ? sample_width : sample_thickness;
      depth = is_rotated ? sample_thickness : sample_width; 
      
      cutout_height = box_height - cutout_start_z;
      
      translate([-width/2, -depth/2, 0])
          cube([width, depth, cutout_height + 1]);
  }
  
  // Calculate label positions based on group positions and spacing
  function calculate_label_positions(positions, group_spacing, label_position, label_height, label_width, sample_width, sample_thickness, include_first_group_label=false) =
      let(
          // Extract groups from positions - positions format: [x, y, is_rotated, group_id]
          groups_info = extract_group_info(positions),
          
          label_calc_msg = str("Label calculation: ", len(groups_info), " groups found, group_spacing=", group_spacing)
      )
      echo(label_calc_msg)
      len(groups_info) < 1 ? [] :  // Need at least 1 group to have labels
      let(
          // Group by rows (groups with similar Y coordinates are in the same row)
          rows_with_groups = group_by_rows(groups_info),
          
          // Calculate label positions for each row - flatten manually
          all_labels = [
              for (row = rows_with_groups)
                  if (len(row) >= 1)  // Need at least 1 group in a row for potential labels
                      each concat(
                          // Optional: label for the first group in the row
                          include_first_group_label && len(row) >= 1 ? 
                              let(
                                  first_group = row[0],
                                  // Calculate label position before the first group
                                  label_pos = calculate_first_group_label_position(first_group, group_spacing, 
                                                                                 label_position, label_height, label_width,
                                                                                 sample_width, sample_thickness)
                              )
                              label_pos != undef ? [label_pos] : [] : [],
                          
                          // Labels between adjacent groups (existing logic)
                          len(row) >= 2 ? [
                              for (i = [0:len(row)-2])  // Between each pair of adjacent groups in this row
                                  let(
                                      group1 = row[i],
                                      group2 = row[i+1],
                                      
                                      // Calculate label position between these groups in this row
                                      label_pos = calculate_single_label_position(group1, group2, group_spacing, 
                                                                                 label_position, label_height, label_width,
                                                                                 sample_width, sample_thickness)
                                  )
                                  if (label_pos != undef) label_pos  // Only include if label fits
                          ] : []
                      )
          ],
          label_positions = all_labels
      )
      label_positions;
  
  // Extract group information from positions array
  function extract_group_info(positions) =
      let(
          // Group positions by group_id (positions format: [x, y, is_rotated, group_id])
          grouped_positions = group_positions_by_id(positions),
          
          // Calculate bounds for each group
          groups_info = [
              for (group_id = [0:len(grouped_positions)-1])
                  if (len(grouped_positions[group_id]) > 0)
                      let(
                          group_positions = grouped_positions[group_id],
                          first_pos = group_positions[0],
                          is_rotated = first_pos[2],
                          
                          // Calculate group bounds
                          x_coords = [for (pos = group_positions) pos[0]],
                          y_coords = [for (pos = group_positions) pos[1]],
                          
                          min_x = min(x_coords),
                          max_x = max(x_coords),
                          min_y = min(y_coords),
                          max_y = max(y_coords),
                          
                          center_x = (min_x + max_x) / 2,
                          center_y = (min_y + max_y) / 2
                      )
                      [group_id, center_x, center_y, min_x, max_x, min_y, max_y, is_rotated]
          ]
      )
      groups_info;
  
  // Group positions by their group_id
  function group_positions_by_id(positions) =
      let(
          max_group_id = max([for (pos = positions) len(pos) > 3 ? pos[3] : 0]),
          grouped = [
              for (group_id = [0:max_group_id])
                  [for (pos = positions) if (len(pos) > 3 && pos[3] == group_id) pos]
          ]
      )
      grouped;
  
  // Group groups by rows (axis-aware based on sample orientation)
  function group_by_rows(groups_info) =
      len(groups_info) == 0 ? [] :
      let(
          // Check sample orientation from first group
          first_group = groups_info[0],
          is_rotated = first_group[7],
          
          // Sort groups by primary coordinate (Y for normal, X for rotated), then by secondary coordinate
          sorted_groups = sort_groups_by_position(groups_info, is_rotated),
          
          // Group by similar coordinates along the secondary axis (within tolerance)
          row_tolerance = 1.0,  // Groups within 1mm distance are considered same row
          rows = is_rotated ? 
              group_by_x_coordinate(sorted_groups, row_tolerance) :  // When rotated, group by X (columns become rows)
              group_by_y_coordinate(sorted_groups, row_tolerance),   // When normal, group by Y (rows)
          
          row_debug_msg = str("Grouped into ", len(rows), " ", is_rotated ? "columns" : "rows"),
          
          // Debug: show all group coordinates for diagnosis
          debug_coordinates = [for (g = groups_info) [g[0], g[1], g[2]]]  // [group_id, center_x, center_y]
      )
      echo(row_debug_msg)
      echo(str("All group coordinates: ", debug_coordinates))
      rows;
  
  // Sort groups by position (axis-aware)
  function sort_groups_by_position(groups_info, is_rotated) =
      // Simple bubble sort for groups - [group_id, center_x, center_y, min_x, max_x, min_y, max_y, is_rotated]
      len(groups_info) <= 1 ? groups_info :
      let(
          sorted = bubble_sort_groups(groups_info, len(groups_info), is_rotated)
      )
      sorted;
  
  // Bubble sort implementation for groups (axis-aware) - simple non-recursive  
  function bubble_sort_groups(groups, n, is_rotated) =
      n <= 1 ? groups :
      len(groups) <= 6 ?
          // For small arrays, just do a single sorting pass
          bubble_sort_pass(groups, n-1, is_rotated) :
      // For larger arrays, just return unsorted
      groups;
  
  // Single pass of bubble sort (axis-aware) - manual for small arrays
  function bubble_sort_pass(groups, n, is_rotated) =
      n <= 0 ? groups :
      len(groups) == 2 ? sort_2_groups(groups, is_rotated) :
      len(groups) == 3 ? sort_3_groups(groups, is_rotated) :
      len(groups) <= 6 ? sort_up_to_6_groups(groups, is_rotated) :
      groups;
  
  // Sort 2 groups
  function sort_2_groups(groups, is_rotated) =
      let(
          g0 = groups[0], g1 = groups[1],
          primary0 = is_rotated ? g0[1] : g0[2],
          primary1 = is_rotated ? g1[1] : g1[2],
          should_swap = primary0 > primary1
      )
      should_swap ? [g1, g0] : groups;
  
  // Sort 3 groups  
  function sort_3_groups(groups, is_rotated) =
      let(
          g0 = groups[0], g1 = groups[1], g2 = groups[2],
          p0 = is_rotated ? g0[1] : g0[2],
          p1 = is_rotated ? g1[1] : g1[2], 
          p2 = is_rotated ? g2[1] : g2[2]
      )
      (p0 <= p1 && p1 <= p2) ? [g0, g1, g2] :
      (p0 <= p2 && p2 <= p1) ? [g0, g2, g1] :
      (p1 <= p0 && p0 <= p2) ? [g1, g0, g2] :
      (p1 <= p2 && p2 <= p0) ? [g1, g2, g0] :
      (p2 <= p0 && p0 <= p1) ? [g2, g0, g1] :
      [g2, g1, g0];
  
  // Sort up to 6 groups - simple approach
  function sort_up_to_6_groups(groups, is_rotated) =
      // For larger arrays, just return original order for simplicity
      groups;
  
  // Check if two arrays are equal - simple comparison for small arrays
  function arrays_equal(a, b) =
      len(a) != len(b) ? false :
      len(a) == 0 ? true :
      len(a) == 1 ? a[0] == b[0] :
      len(a) == 2 ? (a[0] == b[0] && a[1] == b[1]) :
      len(a) == 3 ? (a[0] == b[0] && a[1] == b[1] && a[2] == b[2]) :
      // For larger arrays, assume they're different (conservative)
      false;
  
  // Group groups by Y coordinate within tolerance - manual grouping for common cases
  function group_by_y_coordinate(sorted_groups, tolerance) =
      len(sorted_groups) == 0 ? [] :
      len(sorted_groups) <= 3 ? 
          group_up_to_3_by_y(sorted_groups, tolerance) :
      len(sorted_groups) <= 6 ?
          group_up_to_6_by_y(sorted_groups, tolerance) :
      // For more than 6 groups, use a more robust grouping approach
      group_many_by_y_coordinate(sorted_groups, tolerance);
  
  // Robust grouping function for many groups by Y coordinate
  function group_many_by_y_coordinate(groups, tolerance) =
      len(groups) == 0 ? [] :
      let(
          // Start with the first group as the first row
          first_group = groups[0],
          first_y = first_group[2],
          
          // Find all groups with similar Y coordinate (same row)
          first_row = [for (g = groups) if (abs(g[2] - first_y) <= tolerance) g],
          
          // Find remaining groups (different rows)
          remaining = [for (g = groups) if (abs(g[2] - first_y) > tolerance) g],
          
          // Sort the first row by X coordinate for consistency
          sorted_first_row = sort_row_by_x(first_row)
      )
      len(remaining) == 0 ? 
          [sorted_first_row] :  // Only one row
          concat([sorted_first_row], group_many_by_y_coordinate(remaining, tolerance));  // Recursively group remaining
  
  // Group up to 3 groups by Y coordinate
  function group_up_to_3_by_y(groups, tolerance) =
      len(groups) == 1 ? [[groups[0]]] :
      len(groups) == 2 ? 
          (abs(groups[0][2] - groups[1][2]) <= tolerance ? [groups] : [[groups[0]], [groups[1]]]) :
      // 3 groups
      let(
          y0 = groups[0][2], y1 = groups[1][2], y2 = groups[2][2],
          g01_same = abs(y0 - y1) <= tolerance,
          g12_same = abs(y1 - y2) <= tolerance,
          g02_same = abs(y0 - y2) <= tolerance
      )
      (g01_same && g12_same) ? [groups] :  // All same row
      g01_same ? [[groups[0], groups[1]], [groups[2]]] :  // 0,1 together
      g12_same ? [[groups[0]], [groups[1], groups[2]]] :  // 1,2 together  
      g02_same ? [[groups[0], groups[2]], [groups[1]]] :  // 0,2 together
      [[groups[0]], [groups[1]], [groups[2]]];  // All separate
  
  // Group up to 6 groups by Y coordinate
  function group_up_to_6_by_y(groups, tolerance) =
      // Use the robust recursive function instead of the limited 2-row approach
      group_many_by_y_coordinate(groups, tolerance);
  
  // Group groups by X coordinate within tolerance (for rotated samples) - manual grouping
  function group_by_x_coordinate(sorted_groups, tolerance) =
      len(sorted_groups) == 0 ? [] :
      len(sorted_groups) <= 3 ? 
          group_up_to_3_by_x(sorted_groups, tolerance) :
      len(sorted_groups) <= 6 ?
          group_up_to_6_by_x(sorted_groups, tolerance) :
      // For more than 6 groups, use a more robust grouping approach
      group_many_by_x_coordinate(sorted_groups, tolerance);
  
  // Robust grouping function for many groups by X coordinate
  function group_many_by_x_coordinate(groups, tolerance) =
      len(groups) == 0 ? [] :
      let(
          // Start with the first group as the first column
          first_group = groups[0],
          first_x = first_group[1],
          
          // Find all groups with similar X coordinate (same column)
          first_col = [for (g = groups) if (abs(g[1] - first_x) <= tolerance) g],
          
          // Find remaining groups (different columns)
          remaining = [for (g = groups) if (abs(g[1] - first_x) > tolerance) g],
          
          // Sort the first column by Y coordinate for consistency
          sorted_first_col = sort_col_by_y(first_col),
          
          // Debug output
          debug_msg = str("X grouping: first_x=", first_x, ", first_col_count=", len(first_col), ", remaining_count=", len(remaining))
      )
      echo(debug_msg)
      len(remaining) == 0 ? 
          [sorted_first_col] :  // Only one column
          concat([sorted_first_col], group_many_by_x_coordinate(remaining, tolerance));  // Recursively group remaining
  
  // Group up to 3 groups by X coordinate
  function group_up_to_3_by_x(groups, tolerance) =
      len(groups) == 1 ? [[groups[0]]] :
      len(groups) == 2 ? 
          (abs(groups[0][1] - groups[1][1]) <= tolerance ? [groups] : [[groups[0]], [groups[1]]]) :
      // 3 groups
      let(
          x0 = groups[0][1], x1 = groups[1][1], x2 = groups[2][1],
          g01_same = abs(x0 - x1) <= tolerance,
          g12_same = abs(x1 - x2) <= tolerance,
          g02_same = abs(x0 - x2) <= tolerance
      )
      (g01_same && g12_same) ? [groups] :  // All same column
      g01_same ? [[groups[0], groups[1]], [groups[2]]] :  // 0,1 together
      g12_same ? [[groups[0]], [groups[1], groups[2]]] :  // 1,2 together  
      g02_same ? [[groups[0], groups[2]], [groups[1]]] :  // 0,2 together
      [[groups[0]], [groups[1]], [groups[2]]];  // All separate
  
  // Group up to 6 groups by X coordinate
  function group_up_to_6_by_x(groups, tolerance) =
      // Use the robust recursive function instead of the limited 2-column approach
      group_many_by_x_coordinate(groups, tolerance);
  
  // Sort a column of groups by Y coordinate (for rotated samples) - simple sort
  function sort_col_by_y(col_groups) =
      len(col_groups) <= 1 ? col_groups :
      len(col_groups) == 2 ? 
          (col_groups[0][2] <= col_groups[1][2] ? col_groups : [col_groups[1], col_groups[0]]) :
      len(col_groups) == 3 ?
          sort_3_groups_by_y(col_groups) :
      // For more than 3 groups, fall back to built-in sorting if available, or just return unsorted
      col_groups;
  
  // Sort exactly 3 groups by Y coordinate
  function sort_3_groups_by_y(groups) =
      let(
          g0 = groups[0], g1 = groups[1], g2 = groups[2],
          y0 = g0[2], y1 = g1[2], y2 = g2[2]
      )
      // All 6 permutations of 3 elements
      (y0 <= y1 && y1 <= y2) ? [g0, g1, g2] :
      (y0 <= y2 && y2 <= y1) ? [g0, g2, g1] :
      (y1 <= y0 && y0 <= y2) ? [g1, g0, g2] :
      (y1 <= y2 && y2 <= y0) ? [g1, g2, g0] :
      (y2 <= y0 && y0 <= y1) ? [g2, g0, g1] :
      [g2, g1, g0];
  
  // Find insertion point for Y coordinate - simple linear search
  function find_insertion_point_y(sorted, y_coord) =
      len(sorted) == 0 ? 0 :
      len(sorted) == 1 ? (sorted[0][2] > y_coord ? 0 : 1) :
      len(sorted) == 2 ? (sorted[0][2] > y_coord ? 0 : (sorted[1][2] > y_coord ? 1 : 2)) :
      // For larger arrays, just return middle position
      len(sorted) / 2;
  
  // Sort a row of groups by X coordinate - simple sort
  function sort_row_by_x(row_groups) =
      len(row_groups) <= 1 ? row_groups :
      len(row_groups) == 2 ? 
          (row_groups[0][1] <= row_groups[1][1] ? row_groups : [row_groups[1], row_groups[0]]) :
      len(row_groups) == 3 ?
          sort_3_groups_by_x(row_groups) :
      // For more than 3 groups, fall back to unsorted
      row_groups;
  
  // Sort exactly 3 groups by X coordinate
  function sort_3_groups_by_x(groups) =
      let(
          g0 = groups[0], g1 = groups[1], g2 = groups[2],
          x0 = g0[1], x1 = g1[1], x2 = g2[1]
      )
      // All 6 permutations of 3 elements
      (x0 <= x1 && x1 <= x2) ? [g0, g1, g2] :
      (x0 <= x2 && x2 <= x1) ? [g0, g2, g1] :
      (x1 <= x0 && x0 <= x2) ? [g1, g0, g2] :
      (x1 <= x2 && x2 <= x0) ? [g1, g2, g0] :
      (x2 <= x0 && x0 <= x1) ? [g2, g0, g1] :
      [g2, g1, g0];
  
  // Find insertion point for X coordinate - simple linear search
  function find_insertion_point(sorted, x_coord) =
      len(sorted) == 0 ? 0 :
      len(sorted) == 1 ? (sorted[0][1] > x_coord ? 0 : 1) :
      len(sorted) == 2 ? (sorted[0][1] > x_coord ? 0 : (sorted[1][1] > x_coord ? 1 : 2)) :
      // For larger arrays, just return middle position
      len(sorted) / 2;
  
  // Calculate position for a label before the first group in a row
  function calculate_first_group_label_position(group, group_spacing, label_position, label_height, label_width, sample_width, sample_thickness) =
      let(
          group_id = group[0],
          group_center_x = group[1],
          group_center_y = group[2],
          group_min_x = group[3],
          group_min_y = group[5],
          group_is_rotated = group[7],
          
          // The logic is:
          // 1. We reduced available space by group_spacing
          // 2. We offset all sample positions by group_spacing/2 to center the layout
          // 3. The reserved space is from the edge of the container to the start of the first group
          //    This space should be group_spacing wide
          
          // The logic should be much simpler:
          // - Look at all groups in the same row/column as this group
          // - Find which groups have the same Y coordinate (for width grouping) or same X coordinate (for depth grouping)
          // - The spacing for the first group should be in the direction where groups are arranged
          
          // From the algorithm, I know that:
          // - generate_width_grouped_layout groups along X-axis (samples fit along width)
          // - generate_depth_grouped_layout groups along Y-axis (samples fit along depth)
          
          // But I need to determine this from the group positions. 
          // Since group_id=0 should be the first in its row/column, I can use the grouping axis.
          // For normal samples: if grouping along width, spacing is in X direction  
          // For rotated samples: if grouping along depth, spacing is in X direction
          
          // Determine the grouping direction based on sample orientation:
          // - Normal samples (2.4mm along X): grouping_direction=width -> groups along X-axis -> first group spacing in X
          // - Rotated samples (76mm along X): grouping_direction=depth -> groups along Y-axis -> first group spacing in Y
          
          // For rotated samples, groups are in columns (Y direction), so spacing should be in Y
          // For normal samples, groups are in rows (X direction), so spacing should be in X
          use_y_for_spacing = group_is_rotated,  // rotated uses Y, normal uses X
          
          spacing_end = use_y_for_spacing ? group_min_y : group_min_x,
          spacing_start = spacing_end - group_spacing,
          available_spacing = group_spacing,
          
          spacing_msg = str("First group ", group_id, ": group_min=[", group_min_x, ",", group_min_y, "], use_y_for_spacing=", use_y_for_spacing, ", spacing=", available_spacing, ", label_height=", label_height, ", spacing_start=", spacing_start, ", spacing_end=", spacing_end)
      )
      echo(spacing_msg)
      available_spacing < label_height ? undef :  // Label doesn't fit
      let(
          // Calculate label position within the reserved spacing (axis-aware)
          label_primary_pos = (spacing_start + spacing_end) / 2,  // Center of reserved spacing
          
          // Place label in the correct direction based on grouping
          label_x = use_y_for_spacing ? group_center_x : label_primary_pos,
          label_y = use_y_for_spacing ? label_primary_pos : group_center_y,
          
          // Use the same rotation as the samples
          label_is_rotated = group_is_rotated,
          
          final_msg = str("First group ", group_id, " label position: [", label_x, ", ", label_y, "], rotated=", label_is_rotated)
      )
      echo(final_msg)
      [label_x, label_y, label_is_rotated];
  
  // Calculate position for a single label between two groups
  function calculate_single_label_position(group1, group2, group_spacing, label_position, label_height, label_width, sample_width, sample_thickness) =
      let(
          group1_id = group1[0],
          group1_center_x = group1[1],
          group1_center_y = group1[2],
          group1_max_x = group1[4],
          group1_is_rotated = group1[7],
          
          group2_id = group2[0],
          group2_center_x = group2[1], 
          group2_center_y = group2[2],
          group2_min_x = group2[3],
          group2_is_rotated = group2[7],
          
          // Calculate spacing between groups (axis-aware)
          // For normal samples: groups are horizontally adjacent, spacing is in X direction
          // For rotated samples: groups are vertically adjacent, spacing is in Y direction
          spacing_start = group1_is_rotated ? group1[6] : group1[4],  // max_y for rotated, max_x for normal
          spacing_end = group1_is_rotated ? group2[5] : group2[3],    // min_y for rotated, min_x for normal
          available_spacing = spacing_end - spacing_start,
          
          spacing_msg = str("Groups ", group1_id, "-", group2_id, ": spacing=", available_spacing, ", label_height=", label_height)
      )
      echo(spacing_msg)
      available_spacing < label_height ? undef :  // Label doesn't fit
      let(
          // Calculate label position within the spacing (axis-aware)
          label_primary_pos = (spacing_start + spacing_end) / 2,  // Center of spacing
          
          // For normal samples: label X is in the spacing, Y is row center
          // For rotated samples: label Y is in the spacing, X is column center  
          label_x = group1_is_rotated ? group1_center_x : label_primary_pos,
          label_y = group1_is_rotated ? label_primary_pos : group1_center_y,
          
          // Use the same rotation as the samples
          label_is_rotated = group1_is_rotated
      )
      [label_x, label_y, label_is_rotated];
  
  // Create magnet holes for a label at the specified position
  module create_label_magnet_holes(label_x, label_y, is_rotated, label_height, label_width, magnet_diameter, magnet_thickness, magnet_count, box_height, cutout_start_z) {
      
      // Calculate magnet positions within the label
      magnet_positions = calculate_magnet_positions(label_height, label_width, magnet_count, is_rotated, magnet_diameter);
      
      for (i = [0:len(magnet_positions)-1]) {
          magnet_pos = magnet_positions[i];
          magnet_x_offset = magnet_pos[0];
          magnet_y_offset = magnet_pos[1];
          
          translate([label_x + magnet_x_offset, label_y + magnet_y_offset, box_height - magnet_thickness]) {
              cylinder(d=magnet_diameter, h=magnet_thickness + 1);
          }
      }
  }
  
  // Calculate positions for magnets within a label
  function calculate_magnet_positions(label_height, label_width, magnet_count, is_rotated, magnet_diameter=6.0) =
      let(
          // Label width (76mm) is longer than label height (10mm), so use width as primary dimension
          primary_dimension = label_width,  // Always use label width as the long side
          // Account for magnet radius to ensure holes don't exceed label bounds
          magnet_radius = magnet_diameter / 2,
          // Maximum safe position (half label width minus magnet radius)
          max_safe_offset = (primary_dimension / 2) - magnet_radius,
          // Use the safe offset with some additional margin (95% of safe area)
          usable_length = max_safe_offset * 2 * 0.95,
          // Maximum offset from center
          max_offset = usable_length / 2,
          
          // Calculate positions based on magnet count
          positions = magnet_count == 1 ? 
              [[0, 0]] :  // Single magnet at center
          magnet_count == 2 ?
              // For 2 magnets: place at start and end (maximum separation)
              [[-max_offset, 0], [max_offset, 0]] :
              // For 3+ magnets: evenly distribute across full usable length
              let(
                  spacing = usable_length / (magnet_count - 1),
                  start_pos = -max_offset
              )
              [for (i = [0:magnet_count-1]) [start_pos + i * spacing, 0]],
              
          // Final positioning based on orientation
          final_positions = is_rotated ?
              // When rotated: use X coordinates, Y=0
              positions :
              // When normal: use Y coordinates, X=0 (swap X and Y)
              [for (pos = positions) [0, pos[0]]],
              
          // Debug messages
          debug_msg = magnet_count == 1 ? 
              str("Magnet positioning: 1 magnet at center [0,0]") :
          magnet_count == 2 ?
              str("Magnet positioning: 2 magnets at start/end, label_width=", label_width, "mm, magnet_diameter=", magnet_diameter, "mm, safe_usable_length=", usable_length, "mm, max_offset=±", max_offset, "mm") :
              str("Magnet positioning: ", magnet_count, " magnets evenly spaced, label_width=", label_width, "mm, magnet_diameter=", magnet_diameter, "mm, safe_usable_length=", usable_length, "mm, spacing=", usable_length / (magnet_count - 1), "mm, range=±", max_offset, "mm"),
              
          orientation_msg = str("Final magnet positions (", is_rotated ? "rotated" : "normal", " orientation): ", final_positions)
      )
      echo(debug_msg)
      echo(orientation_msg)
      final_positions;
  
  // Apply offset to all positions when first group label is enabled
  function apply_first_group_offset(positions, include_first_group_label, group_spacing) =
      !include_first_group_label ? positions :
      len(positions) == 0 ? [] :
      let(
          // Determine if we should offset in X or Y based on the sample orientation
          // Look at the first position to determine rotation
          first_pos = positions[0],
          is_rotated = len(first_pos) > 2 ? first_pos[2] : false,
          
          // For rotated samples: groups along Y, so offset in Y direction
          // For normal samples: groups along X, so offset in X direction  
          use_y_offset = is_rotated
      )
      [for (pos = positions) 
          use_y_offset ? 
              [pos[0], pos[1] + group_spacing/2] :  // Offset in Y for rotated
              [pos[0] + group_spacing/2, pos[1]]    // Offset in X for normal
      ];
  // ===== End: grouped_v2.scad =====

// Original: use <src/label_system.scad>
// Inlining 'use' file (modules/functions only):
  // ===== Begin: label_system.scad =====
  // Original: use <algorithms/grouped_v2.scad>
  // Inlining 'use' file (modules/functions only):
// Circular dependency detected: /Users/emil/projects/openscad/gridfinity-ffs-holder/src/algorithms/grouped_v2.scad
  // Label System for Gridfinity Sample Holder
  // Generates physical 3D label objects with magnets for removable labeling
  
  
  // Generate physical 3D label objects for printing
  module generate_label_objects(box_width, box_depth, box_height, l_grid, wall_thickness, side_wall_thickness, sample_width, sample_thickness, min_spacing, cutout_start_z, row_spacing=0, enable_grouping=false, group_count=0, samples_per_group=0, group_spacing=10.0, include_first_group_label=false, label_text_mode="auto", label_custom_text="", label_position="center", label_width=76.0, label_height=10.0, label_thickness=1.5, magnet_diameter=6.0, magnet_thickness=2.0, magnet_count=2, text_style="embossed", text_depth=0.4, font_size=0, font_family="Liberation Sans:style=Bold", force_orientation="auto") {
      
      interior_width = (box_width * l_grid) - (2 * wall_thickness);
      interior_depth = (box_depth * l_grid) - (2 * side_wall_thickness);
  
      echo("=== Generating Physical Label Objects ===");
      
      // Generate the same layout as the main holder to get label positions
      positions = generate_single_pass_layout(interior_width, interior_depth, sample_width, sample_thickness, 
                                            min_spacing, group_count, samples_per_group, group_spacing, row_spacing, include_first_group_label, force_orientation);
      
      if (len(positions) > 0) {
          // Calculate label positions using the same logic as the main holder
          label_positions = calculate_label_positions(positions, group_spacing, label_position, 
                                                     label_height, label_width, sample_width, sample_thickness, include_first_group_label);
          
          if (len(label_positions) > 0) {
              echo(str("Generating ", len(label_positions), " physical labels"));
              
              // Parse custom text if provided
              custom_texts = label_text_mode == "custom" ? parse_custom_text(label_custom_text) : [];
              
              for (i = [0:len(label_positions)-1]) {
                  label_pos = label_positions[i];
                  label_x = label_pos[0];
                  label_y = label_pos[1];
                  is_rotated = label_pos[2];
                  
                  // Determine label text
                  label_text = label_text_mode == "auto" ? 
                      str("G", i + 1) :  // G1, G2, G3, etc.
                      (i < len(custom_texts) ? custom_texts[i] : str("G", i + 1));  // Fallback to auto if not enough custom texts
                  
                  // Create the physical label at the calculated position
                  translate([label_x, label_y, 0]) 
                      create_physical_label(label_text, is_rotated, label_height, label_width, label_thickness,
                                          magnet_diameter, magnet_thickness, magnet_count,
                                          text_style, text_depth, font_size, font_family);
              }
          } else {
              echo("No label positions found - check grouping settings");
          }
      } else {
          echo("No sample positions found - cannot generate labels");
      }
  }
  
  // Create a single physical label with text and magnet holes
  module create_physical_label(text, is_rotated, label_height, label_width, label_thickness, magnet_diameter, magnet_thickness, magnet_count, text_style="embossed", text_depth=0.4, font_size=0, font_family="Liberation Sans:style=Bold") {
      
      // Adjust label dimensions based on rotation
      // When samples are normal: label is 10mm(X) × 76mm(Y) to align with sample orientation  
      // When samples are rotated: label is 76mm(X) × 10mm(Y) to align with sample orientation
      actual_width = is_rotated ? label_width : label_height;
      actual_height = is_rotated ? label_height : label_width;
      
      // Calculate font size if auto (0)
      calculated_font_size = font_size > 0 ? font_size : min(actual_width * 0.15, actual_height * 0.3);
      
      // Fix text rotation - invert the rotation for better readability
      // When samples are rotated (wide along X), text should NOT be rotated
      // When samples are normal (narrow along X), text should be rotated 90 degrees
      text_rotation = is_rotated ? 0 : 90;
      
      echo(str("Label: text='", text, "', is_rotated=", is_rotated, ", text_rotation=", text_rotation, ", style=", text_style));
      
      color("orange", 0.8) 
      union() {
          // Main label body
          difference() {
              translate([-actual_width/2, -actual_height/2, 0])
                  cube([actual_width, actual_height, label_thickness]);
              
              // Subtract magnet holes
              magnet_positions = calculate_magnet_positions(label_height, label_width, magnet_count, is_rotated, magnet_diameter);
              
              for (i = [0:len(magnet_positions)-1]) {
                  magnet_pos = magnet_positions[i];
                  magnet_x_offset = magnet_pos[0];
                  magnet_y_offset = magnet_pos[1];
                  
                  translate([magnet_x_offset, magnet_y_offset, -0.1]) {
                      cylinder(d=magnet_diameter, h=magnet_thickness + 0.2);
                  }
              }
              
              // Debossed text (carved into surface)
              if (text_style == "debossed") {
                  translate([0, 0, label_thickness - text_depth + 0.01]) {
                      linear_extrude(height = text_depth + 0.1) {
                          rotate([0, 0, text_rotation]) {
                              text(text, size = calculated_font_size, 
                                   halign = "center", valign = "center", 
                                   font = font_family);
                          }
                      }
                  }
              }
              
              // Inset text (cutout for different colored insert)
              if (text_style == "inset") {
                  translate([0, 0, label_thickness - text_depth + 0.01]) {
                      linear_extrude(height = text_depth + 0.1) {
                          rotate([0, 0, text_rotation]) {
                              text(text, size = calculated_font_size, 
                                   halign = "center", valign = "center", 
                                   font = font_family);
                          }
                      }
                  }
              }
          }
          
          // Embossed text (raised above surface)
          if (text_style == "embossed") {
              translate([0, 0, label_thickness]) {
                  linear_extrude(height = text_depth) {
                      rotate([0, 0, text_rotation]) {
                          text(text, size = calculated_font_size, 
                               halign = "center", valign = "center", 
                               font = font_family);
                      }
                  }
              }
          }
          
          // Inset text as a separate colored object (for multi-material printing)
          if (text_style == "inset") {
              color("white") 
              translate([0, 0, label_thickness - text_depth]) {
                  linear_extrude(height = text_depth) {
                      rotate([0, 0, text_rotation]) {
                          text(text, size = calculated_font_size, 
                               halign = "center", valign = "center", 
                               font = font_family);
                      }
                  }
              }
          }
      }
  }
  
  // Parse comma-separated custom text into array
  function parse_custom_text(text_string) =
      len(text_string) == 0 ? [] :
      let(
          // Simple comma parsing - split on commas and trim spaces
          parts = split_string_on_comma(text_string)
      )
      [for (part = parts) trim_string(part)];
  
  // Simple string splitting on comma (basic implementation)
  function split_string_on_comma(str) =
      len(str) == 0 ? [] :
      let(
          comma_pos = find_first_comma(str, 0)
      )
      comma_pos == -1 ? [str] :  // No comma found, return whole string
      concat([substr(str, 0, comma_pos)], split_string_on_comma(substr(str, comma_pos + 1)));
  
  // Find first comma in string starting from position
  function find_first_comma(str, start_pos) =
      start_pos >= len(str) ? -1 :
      str[start_pos] == "," ? start_pos :
      find_first_comma(str, start_pos + 1);
  
  // Extract substring (basic implementation)
  function substr(str, start, length = -1) =
      let(
          actual_length = length == -1 ? len(str) - start : min(length, len(str) - start),
          end_pos = start + actual_length
      )
      start >= len(str) || actual_length <= 0 ? "" :
      string_slice(str, start, end_pos - 1);
  
  // Extract character range from string (OpenSCAD compatible)
  function string_slice(str, start_idx, end_idx) = 
      start_idx > end_idx ? "" :
      let(
          chars = [for (i = [start_idx:end_idx]) str[i]]
      )
      concat_chars(chars);
  
  // Concatenate character array into string
  function concat_chars(chars) =
      len(chars) == 0 ? "" :
      len(chars) == 1 ? chars[0] :
      str(chars[0], concat_chars([for (i = [1:len(chars)-1]) chars[i]]));
  
  // Trim whitespace from string
  function trim_string(str) =
      len(str) == 0 ? "" :
      let(
          first_non_space = find_first_non_space(str, 0),
          last_non_space = find_last_non_space(str, len(str) - 1)
      )
      first_non_space == -1 ? "" :  // All spaces
      substr(str, first_non_space, last_non_space - first_non_space + 1);
  
  // Find first non-space character
  function find_first_non_space(str, pos) =
      pos >= len(str) ? -1 :
      str[pos] != " " && str[pos] != "\t" ? pos :
      find_first_non_space(str, pos + 1);
  
  // Find last non-space character
  function find_last_non_space(str, pos) =
      pos < 0 ? -1 :
      str[pos] != " " && str[pos] != "\t" ? pos :
      find_last_non_space(str, pos - 1);
  // ===== End: label_system.scad =====

/*
 * Gridfinity Sample Box Generator
 * Converted from Python script to OpenSCAD for MakerWorld customization
 * Uses gridfinity-rebuilt-openscad library for proper gridfinity base generation
 */

// Include the gridfinity library (MakerWorld compatible paths)
// External dependency (kept as-is): include <gridfinity-rebuilt-openscad/standard.scad>
include <gridfinity-rebuilt-openscad/standard.scad>
// External dependency (kept as-is): use <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>
use <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>
// External dependency (kept as-is): use <gridfinity-rebuilt-openscad/generic-helpers.scad>
use <gridfinity-rebuilt-openscad/generic-helpers.scad>

// Include our modular components

module mw_plate_2() {
    // Label objects for separate printing
    if (sh_enable_labels && (sh_enable_grouping || sh_algorithm_type == 2)) {
        generate_label_objects(sh_box_width, sh_box_depth, sh_box_height, l_grid, sh_wall_thickness, 
                              sh_side_wall_thickness, sh_sample_width, sh_sample_thickness, 
                              sh_min_spacing, sh_cutout_start_z, sh_row_spacing, sh_enable_grouping,
                              sh_group_count, sh_samples_per_group, sh_group_spacing,
                              sh_include_first_group_label, sh_label_text_mode, sh_label_custom_text, sh_label_position,
                              sh_label_width, sh_label_height, sh_label_thickness,
                              sh_magnet_diameter, sh_magnet_thickness, sh_magnet_count,
                              sh_text_style, sh_text_depth, sh_font_size, sh_font_family, sh_force_orientation);
    }
}

module mw_assembly_view() {
    // Combined assembly view for preview
    mw_plate_1();
    
    if (sh_generate_labels && sh_enable_labels && (sh_enable_grouping || sh_algorithm_type == 2)) {
        translate([0, 0, 30]) // Move labels above the main holder for visibility
            mw_plate_2();
    }
}

development_mode = false;

// For development, show both plates in the assembly view
if (development_mode) {
    mw_assembly_view();
}

// Display information
echo("=== Gridfinity Sample Box Generator ===");
echo(str("Algorithm: ", sh_algorithm_type == 0 ? "Grid Layout" : sh_algorithm_type == 1 ? "Multi-Pass Grouping" : "Single-Pass Grouping"));
echo(str("Box: ", sh_box_width, "x", sh_box_depth, " gridfinity units"));  
echo(str("Dimensions: ", sh_box_width * l_grid, " x ", sh_box_depth * l_grid, " x ", sh_box_height, " mm"));
echo(str("Sample: ", sh_sample_thickness, " x ", sh_sample_width, " x ", sh_sample_height, " mm"));
echo(str("Cutout depth: ", sh_cutout_start_z, " mm"));
echo(str("Minimum wall thickness: ", sh_min_spacing, " mm"));
// ===== End: sample_card_holder.scad =====
