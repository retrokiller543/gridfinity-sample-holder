function calculate_grouped_layout(interior_width, interior_depth, sample_w, sample_t, min_spacing, row_spacing) = 
    let(
        // Test both sample orientations
        normal_layout = test_sample_orientation(interior_width, interior_depth, sample_t, sample_w, min_spacing, false),
        rotated_layout = test_sample_orientation(interior_width, interior_depth, sample_w, sample_t, min_spacing, true),
        
        normal_capacity = normal_layout[0] * normal_layout[1],
        rotated_capacity = rotated_layout[0] * rotated_layout[1],
        
        // Choose best orientation
        use_rotated = rotated_capacity > normal_capacity,
        best_layout = use_rotated ? rotated_layout : normal_layout,
        
        samples_per_row = best_layout[0],
        num_rows = best_layout[1],
        spacing_x = best_layout[2],
        spacing_y = best_layout[3]
    ) 
    // Generate rows of samples
    samples_per_row > 0 && num_rows > 0 ? 
        generate_simple_rows(num_rows, samples_per_row, use_rotated, spacing_y, sample_w, sample_t) : 
    [];

function test_sample_orientation(interior_width, interior_depth, sample_width_x, sample_width_y, min_spacing, is_rotated) =
    let(
        // Calculate how many samples fit along each axis using standard formula
        samples_x = calculate_max_samples_per_direction(interior_width, sample_width_x, min_spacing),
        samples_y = calculate_max_samples_per_direction(interior_depth, sample_width_y, min_spacing),
        
        // Check if samples actually fit physically in both dimensions
        fits_x = sample_width_x <= interior_width,
        fits_y = sample_width_y <= interior_depth,
        
        // Only allow valid combinations
        valid_samples_x = fits_x ? samples_x : 0,
        valid_samples_y = fits_y ? samples_y : 0,
        
        // Calculate actual spacing that will be used
        actual_spacing_x = valid_samples_x > 1 ? 
            max(min_spacing, (interior_width - valid_samples_x * sample_width_x) / (valid_samples_x - 1)) : 0,
        actual_spacing_y = valid_samples_y > 1 ? 
            max(min_spacing, (interior_depth - valid_samples_y * sample_width_y) / (valid_samples_y - 1)) : 0
    ) 
    [valid_samples_x, valid_samples_y, actual_spacing_x, actual_spacing_y];

function generate_simple_rows(num_rows, samples_per_row, is_rotated, row_spacing, sample_w, sample_t) =
    [
        for (row_idx = [0:num_rows-1])
            let(
                sample_depth = is_rotated ? sample_t : sample_w,
                row_y = row_idx * (sample_depth + row_spacing)
            )
            [row_y, is_rotated, [samples_per_row], sample_depth]
    ];

function generate_grouped_positions(row_layouts, interior_width, interior_depth, sample_w, sample_t, min_spacing) =
    len(row_layouts) == 0 ? [] :
    [
        for (row_idx = [0:len(row_layouts)-1])
            let(
                row = row_layouts[row_idx],
                row_y_offset = row[0],
                is_rotated = row[1],
                groups = row[2],
                row_depth = row[3],
                
                samples_in_row = groups[0], // Simple: each row has one group
                
                // Calculate sample dimensions
                sample_width = is_rotated ? sample_w : sample_t,
                sample_depth = is_rotated ? sample_t : sample_w,
                
                // Calculate spacing to center samples in row
                total_samples_width = samples_in_row * sample_width,
                available_spacing = interior_width - total_samples_width,
                spacing_between = samples_in_row > 1 ? available_spacing / (samples_in_row - 1) : 0,
                
                // Start position for centered layout
                start_x = -interior_width/2 + sample_width/2,
                centered_row_y = -interior_depth/2 + row_y_offset + sample_depth/2
            )
            for (sample_idx = [0:samples_in_row-1])
                [
                    start_x + sample_idx * (sample_width + spacing_between),
                    centered_row_y,
                    is_rotated
                ]
    ];

// Essential helper functions for the simplified algorithm
function calculate_max_samples_per_direction(space_size, sample_size, min_spacing) =
    max(1, floor((space_size + min_spacing) / (sample_size + min_spacing)));

function sum_array(arr) = 
    len(arr) == 0 ? 0 : 
    len(arr) == 1 ? arr[0] :
    len(arr) > 1 ? arr[0] + sum_array([for (i = [1:len(arr)-1]) arr[i]]) : 0;