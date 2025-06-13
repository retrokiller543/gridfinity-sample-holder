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
