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