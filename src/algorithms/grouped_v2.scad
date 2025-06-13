use <../vallidation.scad>

module grouped_v2(box_width, box_depth, box_height, l_grid, wall_thickness, side_wall_thickness, sample_width, sample_thickness, min_spacing, cutout_start_z, row_spacing=0, enable_grouping=false, group_count=0, samples_per_group=0, group_spacing=3.0) {
  
    interior_width = (box_width * l_grid) - (2 * wall_thickness);
    interior_depth = (box_depth * l_grid) - (2 * side_wall_thickness);

    echo(str("=== Grouped V2 Single-Pass Algorithm ==="));
    echo(str("Interior space: ", interior_width, " x ", interior_depth, " mm"));
    echo(str("Sample size: ", sample_thickness, " x ", sample_width, " mm"));
    echo(str("Sample fits normal (", sample_thickness, "x", sample_width, "): width=", sample_thickness <= interior_width, " depth=", sample_width <= interior_depth));
    echo(str("Sample fits rotated (", sample_width, "x", sample_thickness, "): width=", sample_width <= interior_width, " depth=", sample_thickness <= interior_depth));

    positions = generate_single_pass_layout(interior_width, interior_depth, sample_width, sample_thickness, 
                                          min_spacing, group_count, samples_per_group, group_spacing);
    
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

function generate_single_pass_layout(interior_width, interior_depth, sample_width, sample_thickness, 
                                   min_spacing, group_count, samples_per_group, group_spacing) =
    let(
        // Test both orientations to see which one allows more samples total
        // Normal: thickness along X, width along Y  
        normal_layout = test_orientation_layout(interior_width, interior_depth, sample_thickness, sample_width, 
                                               min_spacing, group_count, samples_per_group, group_spacing, false),
        // Rotated: width along X, thickness along Y
        rotated_layout = test_orientation_layout(interior_width, interior_depth, sample_width, sample_thickness, 
                                                min_spacing, group_count, samples_per_group, group_spacing, true),
        
        normal_total = len(normal_layout),
        rotated_total = len(rotated_layout),
        
        // Choose the orientation that gives us more samples
        use_rotated = rotated_total > normal_total,
        final_layout = use_rotated ? rotated_layout : normal_layout
    )
    final_layout;

function test_orientation_layout(interior_width, interior_depth, sample_w, sample_d, 
                                min_spacing, group_count, samples_per_group, group_spacing, is_rotated) =
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
        samples_along_width = floor(interior_width / (sample_w + min_spacing)),
        samples_along_depth = floor(interior_depth / (sample_d + min_spacing)),
        group_along_width = samples_along_width >= samples_along_depth,
        
        // Calculate layout based on grouping direction
        layout_data = group_along_width ?
            generate_width_grouped_layout(interior_width, interior_depth, sample_w, sample_d, 
                                        min_spacing, group_count, samples_per_group, group_spacing, is_rotated) :
            generate_depth_grouped_layout(interior_width, interior_depth, sample_w, sample_d, 
                                        min_spacing, group_count, samples_per_group, group_spacing, is_rotated)
    )
    layout_data;

function generate_width_grouped_layout(interior_width, interior_depth, sample_w, sample_d, 
                                      min_spacing, group_count, samples_per_group, group_spacing, is_rotated) =
    let(
        // Group across the width (X-axis) - use the correct sample dimension for X-axis
        sample_x_dim = sample_w, // sample_w is already the X-dimension for the given orientation
        first_row_data = generate_first_row_positions(interior_width, sample_x_dim, min_spacing, 
                                                    group_count, samples_per_group, group_spacing),
        first_row_positions = first_row_data[0],
        row_width = first_row_data[1],
        
        // Calculate how many rows fit
        rows_that_fit = floor(interior_depth / (sample_d + min_spacing)),
        
        debug_msg2 = str("  Width grouping - First row: ", len(first_row_positions), " positions, rows_fit: ", rows_that_fit)
    )
    echo(debug_msg2)
    let(
        // Generate all positions by copying first row with Y offsets
        all_positions = generate_all_row_positions(first_row_positions, rows_that_fit, sample_d, 
                                                 min_spacing, interior_depth, is_rotated)
    )
    all_positions;

function generate_depth_grouped_layout(interior_width, interior_depth, sample_w, sample_d, 
                                      min_spacing, group_count, samples_per_group, group_spacing, is_rotated) =
    let(
        // Group across the depth (Y-axis) - swapped logic
        first_col_data = generate_first_row_positions(interior_depth, sample_d, min_spacing, 
                                                     group_count, samples_per_group, group_spacing),
        first_col_positions = first_col_data[0],
        col_depth = first_col_data[1],
        
        // Calculate how many columns fit
        cols_that_fit = floor(interior_width / (sample_w + min_spacing)),
        
        debug_msg2 = str("  Depth grouping - First col: ", len(first_col_positions), " positions, cols_fit: ", cols_that_fit)
    )
    echo(debug_msg2)
    let(
        // Generate all positions by copying first column with X offsets
        all_positions = generate_all_col_positions(first_col_positions, cols_that_fit, sample_w, 
                                                  min_spacing, interior_width, is_rotated)
    )
    all_positions;

function generate_all_col_positions(first_col_y_positions, num_cols, sample_width, min_spacing, interior_width, use_rotated) =
    let(
        // Calculate X positions for each column
        total_cols_width = num_cols * sample_width + max(0, num_cols - 1) * min_spacing,
        start_x = -total_cols_width / 2 + sample_width / 2
    )
    [
        for (col_idx = [0:num_cols-1])
            let(
                col_x = start_x + col_idx * (sample_width + min_spacing)
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
        // Always try to keep all groups, reduce samples per group to fit
        adjusted_samples = find_max_samples_per_group_for_groups(group_count, sample_width, min_spacing, group_spacing, interior_width)
    )
    adjusted_samples > 0 ?
        // If we can fit all groups with fewer samples per group, do that
        [generate_group_positions(group_count, adjusted_samples, sample_width, min_spacing, group_spacing, interior_width),
         group_count, adjusted_samples] :
        // If even 1 sample per group doesn't fit, then we truly can't fit any groups
        [[], 0, 0];

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

function generate_all_row_positions(first_row_x_positions, num_rows, sample_depth, min_spacing, interior_depth, use_rotated) =
    let(
        // Calculate Y positions for each row
        total_rows_depth = num_rows * sample_depth + max(0, num_rows - 1) * min_spacing,
        start_y = -total_rows_depth / 2 + sample_depth / 2
    )
    [
        for (row_idx = [0:num_rows-1])
            let(
                row_y = start_y + row_idx * (sample_depth + min_spacing)
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