use <../vallidation.scad>

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
        
        grouping_msg = str("    Grouping analysis: samples_along_width=", samples_along_width, 
                          ", samples_along_depth=", samples_along_depth, 
                          ", grouping_direction=", group_along_width ? "width" : "depth")
    )
    echo(grouping_msg)
    let(
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
        
        debug_msg = str("    Max samples per row: ", max_samples_per_row, " (width: ", interior_width, ", sample: ", sample_width, ", min_spacing: ", min_spacing, ")")
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
            calculate_auto_grouping(max_samples_per_row, sample_width, min_spacing, group_spacing, interior_width, samples_per_group) :
            [group_count, samples_per_group > 0 ? samples_per_group : max(1, floor(max_samples_per_row / group_count))],
        
        effective_group_count = auto_data[0],
        effective_samples_per_group = auto_data[1],
        
        debug_msg2 = str("    Effective groups: ", effective_group_count, ", samples per group: ", effective_samples_per_group)
    )
    echo(debug_msg2)
    let(
        // Generate positions for each group - pass original samples_per_group to preserve user intent
        group_data = generate_groups_in_row(effective_group_count, effective_samples_per_group, 
                                          sample_width, min_spacing, group_spacing, interior_width, samples_per_group),
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

function generate_groups_in_row(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group=0) =
    let(
        // Try to fit all requested groups first
        positions_data = try_fit_groups_with_adjustment(group_count, samples_per_group, sample_width, 
                                                      min_spacing, group_spacing, interior_width, original_samples_per_group),
        positions = positions_data[0],
        actual_group_count = positions_data[1],
        actual_samples_per_group = positions_data[2],
        
        actual_width = calculate_actual_width(actual_group_count, actual_samples_per_group, sample_width, 
                                            min_spacing, group_spacing)
    )
    [positions, actual_width];

function try_fit_groups_with_adjustment(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group=0) =
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
        // If it fits, generate positions as requested
        let(
            success_msg = str("      ✓ Groups fit as requested - generating positions")
        )
        echo(success_msg)
        [generate_group_positions(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width), 
         group_count, samples_per_group] :
        // If it doesn't fit, try reducing samples per group first, then group count
        let(
            adjust_msg = str("      ✗ Groups don't fit - starting adjustment process")
        )
        echo(adjust_msg)
        adjust_to_fit(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group);

function adjust_to_fit(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group=0) =
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
        fit_partial_groups(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group) :
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
            [generate_group_positions(group_count, adjusted_samples, sample_width, min_spacing, group_spacing, interior_width),
             group_count, adjusted_samples] :
            // If groups don't fit, find how many complete groups + partial group we can fit
            let(
                partial_msg = str("        ✗ Can't fit all ", group_count, " groups - trying partial groups")
            )
            echo(partial_msg)
            fit_partial_groups(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group);

function fit_partial_groups(group_count, samples_per_group, sample_width, min_spacing, group_spacing, interior_width, original_samples_per_group=0) =
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
        [generate_mixed_group_positions(max_complete_groups, samples_per_group, partial_group_samples, 
                                       sample_width, min_spacing, group_spacing, interior_width),
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