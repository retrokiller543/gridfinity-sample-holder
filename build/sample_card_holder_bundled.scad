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

/* [Grouping Settings] */
// Enable group-based layout (instead of row-based)
sh_enable_grouping = false; // [true, false]
// Number of groups to create (0 = auto-calculate)
sh_group_count = 0; // [0:1:20]
// Number of samples per group (0 = auto-calculate)
sh_samples_per_group = 0; // [0:1:50]
// Spacing between groups in millimeters
sh_group_spacing = 3.0; // [1:0.1:10]

// Main model - create solid gridfinity box without lip, then subtract cutouts
color("lightgray") 
difference() {
    gridfinity_box(sh_box_width, sh_box_depth, sh_box_height, l_grid, style_lip, style_hole, cut_to_height=true);
    
    // Subtract sample cutouts from the top
    // Use advanced algorithm when grouping is enabled OR when explicitly selected
    if (sh_enable_grouping || sh_algorithm_type == 2) {
        grouped_v2(sh_box_width, sh_box_depth, sh_box_height, l_grid, sh_wall_thickness, 
                   sh_side_wall_thickness, sh_sample_width, sh_sample_thickness, 
                   sh_min_spacing, sh_cutout_start_z, sh_row_spacing, sh_enable_grouping,
                   sh_group_count, sh_samples_per_group, sh_group_spacing);
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

  
  module grouped_v2(box_width, box_depth, box_height, l_grid, wall_thickness, side_wall_thickness, sample_width, sample_thickness, min_spacing, cutout_start_z, row_spacing=0, enable_grouping=false, group_count=0, samples_per_group=0, group_spacing=3.0) {
    
      interior_width = (box_width * l_grid) - (2 * wall_thickness);
      interior_depth = (box_depth * l_grid) - (2 * side_wall_thickness);
  
      echo(str("=== Grouped V2 Single-Pass Algorithm ==="));
      echo(str("Interior space: ", interior_width, " x ", interior_depth, " mm"));
      echo(str("Sample size: ", sample_thickness, " x ", sample_width, " mm"));
      echo(str("Enable grouping: ", enable_grouping));
      echo(str("Group count: ", group_count, ", Samples per group: ", samples_per_group));
      echo(str("Sample fits normal (", sample_thickness, "x", sample_width, "): width=", sample_thickness <= interior_width, " depth=", sample_width <= interior_depth));
      echo(str("Sample fits rotated (", sample_width, "x", sample_thickness, "): width=", sample_width <= interior_width, " depth=", sample_thickness <= interior_depth));
  
      // If grouping is disabled or both group parameters are 0, use simple layout
      use_simple_layout = !enable_grouping || (group_count == 0 && samples_per_group == 0);
      
      positions = use_simple_layout ? 
          generate_simple_layout(interior_width, interior_depth, sample_width, sample_thickness, min_spacing, row_spacing) :
          generate_single_pass_layout(interior_width, interior_depth, sample_width, sample_thickness, 
                                    min_spacing, group_count, samples_per_group, group_spacing, row_spacing);
      
      echo(str("Generated ", len(positions), " sample positions"));
      
      for (i = [0:len(positions)-1]) {
          pos = positions[i];
          pos_x = pos[0];
          pos_y = pos[1];
          is_rotated = pos[2];
          
          translate([pos_x, pos_y, box_height - (box_height - cutout_start_z)]) 
              sample_cutout_shape(is_rotated, sample_width, sample_thickness, box_height, cutout_start_z);
      }
  }
  
  function samples_fit_in_dimension(available_space, sample_size, min_spacing) =
      sample_size > available_space ? 0 :
      1 + floor((available_space - sample_size) / (sample_size + min_spacing));
  
  function generate_simple_layout(interior_width, interior_depth, sample_width, sample_thickness, min_spacing, row_spacing) =
      let(
          // Test both orientations to see which one allows more samples total
          normal_layout = test_simple_orientation(interior_width, interior_depth, sample_thickness, sample_width, min_spacing, row_spacing, false),
          rotated_layout = test_simple_orientation(interior_width, interior_depth, sample_width, sample_thickness, min_spacing, row_spacing, true),
          
          normal_total = len(normal_layout),
          rotated_total = len(rotated_layout),
          
          use_rotated = rotated_total > normal_total,
          final_layout = use_rotated ? rotated_layout : normal_layout
      )
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
                                     min_spacing, group_count, samples_per_group, group_spacing, row_spacing) =
      let(
          // Test both orientations to see which one allows more samples total
          // Normal: thickness along X, width along Y  
          normal_layout = test_orientation_layout(interior_width, interior_depth, sample_thickness, sample_width, 
                                                 min_spacing, group_count, samples_per_group, group_spacing, row_spacing, false),
          // Rotated: width along X, thickness along Y
          rotated_layout = test_orientation_layout(interior_width, interior_depth, sample_width, sample_thickness, 
                                                  min_spacing, group_count, samples_per_group, group_spacing, row_spacing, true),
          
          normal_total = len(normal_layout),
          rotated_total = len(rotated_layout),
          
          // Choose the orientation that gives us more samples
          use_rotated = rotated_total > normal_total,
          final_layout = use_rotated ? rotated_layout : normal_layout
      )
      final_layout;
  
  function test_orientation_layout(interior_width, interior_depth, sample_w, sample_d, 
                                  min_spacing, group_count, samples_per_group, group_spacing, row_spacing, is_rotated) =
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
          
          // Calculate layout based on grouping direction
          layout_data = group_along_width ?
              generate_width_grouped_layout(interior_width, interior_depth, sample_w, sample_d, 
                                          min_spacing, group_count, samples_per_group, group_spacing, row_spacing, is_rotated) :
              generate_depth_grouped_layout(interior_width, interior_depth, sample_w, sample_d, 
                                          min_spacing, group_count, samples_per_group, group_spacing, row_spacing, is_rotated)
      )
      layout_data;
  
  function generate_width_grouped_layout(interior_width, interior_depth, sample_w, sample_d, 
                                        min_spacing, group_count, samples_per_group, group_spacing, row_spacing, is_rotated) =
      let(
          // Group across the width (X-axis) - use the correct sample dimension for X-axis
          sample_x_dim = sample_w, // sample_w is already the X-dimension for the given orientation
          first_row_data = generate_first_row_positions(interior_width, sample_x_dim, min_spacing, 
                                                      group_count, samples_per_group, group_spacing),
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
                                        min_spacing, group_count, samples_per_group, group_spacing, row_spacing, is_rotated) =
      let(
          // Group across the depth (Y-axis) - swapped logic
          first_col_data = generate_first_row_positions(interior_depth, sample_d, min_spacing, 
                                                       group_count, samples_per_group, group_spacing),
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
                      group_id = y_data[1]
                  )
                  [col_x, y_pos, use_rotated, group_id]
      ];
  
  function generate_first_row_positions(interior_width, sample_width, min_spacing, group_count, samples_per_group, group_spacing) =
      let(
          max_samples_per_row = floor(interior_width / (sample_width + min_spacing)),
          
          debug_msg = str("    Max samples per row: ", max_samples_per_row, " (width: ", interior_width, ", sample: ", sample_width, ")")
      )
      echo(debug_msg)
      let(
          // Auto-calculate group settings if not specified
          auto_data = group_count == 0 ? 
              calculate_auto_grouping(max_samples_per_row, sample_width, min_spacing, group_spacing, interior_width, samples_per_group) :
              [group_count, samples_per_group > 0 ? samples_per_group : max(1, floor(max_samples_per_row / group_count))],
          
          effective_group_count = auto_data[0],
          effective_samples_per_group = auto_data[1],
          
          debug_msg2 = str("    Groups: ", effective_group_count, ", samples per group: ", effective_samples_per_group)
      )
      echo(debug_msg2)
      let(
          // Generate positions for each group
          group_data = generate_groups_in_row(effective_group_count, effective_samples_per_group, 
                                            sample_width, min_spacing, group_spacing, interior_width),
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
  
  function generate_groups_in_row(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width) =
      let(
          // Try to fit all requested groups first
          positions_data = try_fit_groups_with_adjustment(group_count, samples_per_group, sample_width, 
                                                        min_spacing, group_spacing, interior_width),
          positions = positions_data[0],
          actual_group_count = positions_data[1],
          actual_samples_per_group = positions_data[2],
          
          actual_width = calculate_actual_width(actual_group_count, actual_samples_per_group, sample_width, 
                                              min_spacing, group_spacing)
      )
      [positions, actual_width];
  
  function try_fit_groups_with_adjustment(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width) =
      let(
          // First try with requested settings
          fits_as_requested = check_groups_fit_in_row(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width)
      )
      fits_as_requested ? 
          // If it fits, generate positions as requested
          [generate_group_positions(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width), 
           group_count, samples_per_group] :
          // If it doesn't fit, try reducing samples per group first, then group count
          adjust_to_fit(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width);
  
  function adjust_to_fit(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width) =
      let(
          // First try to keep all groups, reduce samples per group to fit
          adjusted_samples = find_max_samples_per_group_for_groups(group_count, sample_width, min_spacing, group_spacing, interior_width)
      )
      adjusted_samples > 0 ?
          // If we can fit all groups with fewer samples per group, do that
          [generate_group_positions(group_count, adjusted_samples, sample_width, min_spacing, group_spacing, interior_width),
           group_count, adjusted_samples] :
          // If groups don't fit, find how many complete groups + partial group we can fit
          fit_partial_groups(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width);
  
  function fit_partial_groups(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width) =
      let(
          // Find the maximum number of complete groups that fit
          max_complete_groups = find_max_fitting_groups(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width),
          
          // Calculate space used by complete groups
          complete_groups_width = max_complete_groups > 0 ? 
              calculate_actual_width(max_complete_groups, samples_per_group, sample_width, min_spacing, group_spacing) : 0,
          
          // Calculate remaining space for partial group
          remaining_width = interior_width - complete_groups_width - (max_complete_groups > 0 ? group_spacing : 0),
          
          // Calculate how many samples fit in the remaining space (partial group)
          partial_group_samples = remaining_width > sample_width ? 
              samples_fit_in_dimension(remaining_width, sample_width, min_spacing) : 0,
          
          // Total groups (complete + partial if any)
          total_groups = max_complete_groups + (partial_group_samples > 0 ? 1 : 0),
          
          debug_msg = str("    Partial fit: ", max_complete_groups, " complete groups, ", partial_group_samples, " in partial group")
      )
      echo(debug_msg)
      total_groups > 0 ?
          // Generate positions for complete groups + partial group
          [generate_mixed_group_positions(max_complete_groups, samples_per_group, partial_group_samples, 
                                         sample_width, min_spacing, group_spacing, interior_width),
           total_groups, samples_per_group] :
          // If nothing fits, return empty
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
          
          // Center the entire layout
          layout_start_x = -total_layout_width / 2,
          
          // Generate complete groups with adjusted positioning
          complete_positions = complete_groups > 0 ? 
              generate_group_positions_at_offset(complete_groups, samples_per_group, sample_width, min_spacing, group_spacing, layout_start_x) : [],
          
          // Calculate partial group start position
          partial_start_x = layout_start_x + complete_width + total_group_spacing + sample_width/2,
          
          // Generate partial group positions
          partial_positions = partial_group_samples > 0 ? 
              [for (i = [0:partial_group_samples-1])
                  [partial_start_x + i * (sample_width + min_spacing), complete_groups]  // group_id = complete_groups
              ] : []
      )
      concat(complete_positions, partial_positions);
  
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
          start_x = -total_width / 2
      )
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
                      group_id = x_data[1]
                  )
                  [x_pos, row_y, use_rotated, group_id]
      ];
  
  module sample_cutout_shape(is_rotated, sample_width, sample_thickness, box_height, cutout_start_z) {
      width = is_rotated ? sample_width : sample_thickness;
      depth = is_rotated ? sample_thickness : sample_width; 
      
      cutout_height = box_height - cutout_start_z;
      
      translate([-width/2, -depth/2, 0])
          cube([width, depth, cutout_height + 1]);
  }
  // ===== End: grouped_v2.scad =====

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



// Display information
echo("=== Gridfinity Sample Box Generator ===");
echo(str("Algorithm: ", sh_algorithm_type == 0 ? "Grid Layout" : sh_algorithm_type == 1 ? "Multi-Pass Grouping" : "Single-Pass Grouping"));
echo(str("Box: ", sh_box_width, "x", sh_box_depth, " gridfinity units"));  
echo(str("Dimensions: ", sh_box_width * l_grid, " x ", sh_box_depth * l_grid, " x ", sh_box_height, " mm"));
echo(str("Sample: ", sh_sample_thickness, " x ", sh_sample_width, " x ", sh_sample_height, " mm"));
echo(str("Cutout depth: ", sh_cutout_start_z, " mm"));
echo(str("Minimum wall thickness: ", sh_min_spacing, " mm"));
// ===== End: sample_card_holder.scad =====
