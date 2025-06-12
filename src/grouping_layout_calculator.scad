function calculate_grouped_layout(interior_width, interior_depth, sample_w, sample_t, min_spacing) = 
    let(
        orientation_capacities = calculate_orientation_capacities(interior_width, sample_w, sample_t, min_spacing),
        row_layouts = pack_rows_optimally(interior_width, interior_depth, sample_w, sample_t, min_spacing, orientation_capacities)
    ) row_layouts;

function calculate_orientation_capacities(interior_width, sample_w, sample_t, min_spacing) =
    let(
        normal_capacity = calculate_max_samples_per_direction(interior_width, sample_t, min_spacing),
        rotated_capacity = calculate_max_samples_per_direction(interior_width, sample_w, min_spacing),
        normal_row_width = normal_capacity * sample_t + (normal_capacity - 1) * min_spacing,
        rotated_row_width = rotated_capacity * sample_w + (rotated_capacity - 1) * min_spacing
    ) [
        [false, normal_capacity, sample_w, normal_row_width],   // [is_rotated, count, depth, total_width]
        [true, rotated_capacity, sample_t, rotated_row_width]   // [is_rotated, count, depth, total_width]
    ];

function pack_rows_optimally(interior_width, interior_depth, sample_w, sample_t, min_spacing, orientations) =
    pack_rows_recursive(interior_width, interior_depth, sample_w, sample_t, min_spacing, orientations, 0, []);

function pack_rows_recursive(interior_width, interior_depth, sample_w, sample_t, min_spacing, orientations, current_y, rows_so_far) =
    let(
        best_orientation = choose_best_orientation_for_row(orientations),
        is_rotated = best_orientation[0],
        max_samples_per_row = best_orientation[1],
        row_depth = best_orientation[2],
        
        new_y = current_y + (len(rows_so_far) > 0 ? row_depth + min_spacing : 0),
        
        fits_vertically = (new_y + row_depth) <= interior_depth
    )
    !fits_vertically ? rows_so_far :
    let(
        row_groups = generate_row_groups(interior_width, max_samples_per_row, is_rotated, sample_w, sample_t, min_spacing),
        new_row = [new_y, is_rotated, row_groups, row_depth],
        updated_rows = concat(rows_so_far, [new_row])
    )
    pack_rows_recursive(interior_width, interior_depth, sample_w, sample_t, min_spacing, orientations, new_y, updated_rows);

function choose_best_orientation_for_row(orientations) =
    let(
        normal = orientations[0],
        rotated = orientations[1],
        normal_count = normal[1],
        rotated_count = rotated[1]
    )
    normal_count >= rotated_count ? normal : rotated;

function generate_row_groups(interior_width, max_samples_per_row, is_rotated, sample_w, sample_t, min_spacing) =
    let(
        sample_width = is_rotated ? sample_w : sample_t,
        single_sample_space = sample_width + min_spacing,
        
        full_groups_count = floor(interior_width / (max_samples_per_row * sample_width + (max_samples_per_row - 1) * min_spacing)),
        remaining_width_after_full_groups = interior_width - (full_groups_count * (max_samples_per_row * sample_width + (max_samples_per_row - 1) * min_spacing)),
        
        partial_group_samples = remaining_width_after_full_groups > 0 ? 
            max(0, floor((remaining_width_after_full_groups + min_spacing) / single_sample_space)) : 0,
        
        full_groups = full_groups_count > 0 ? [for (i = [0:full_groups_count-1]) max_samples_per_row] : [],
        all_groups = partial_group_samples > 0 ? concat(full_groups, [partial_group_samples]) : full_groups
    ) all_groups;

function generate_grouped_positions(row_layouts, interior_width, interior_depth, sample_w, sample_t, min_spacing) =
    let(
        total_layout_depth = calculate_total_layout_depth(row_layouts, min_spacing),
        layout_start_y = -total_layout_depth/2
    )
    [
        for (row_idx = [0:len(row_layouts)-1])
            let(
                row = row_layouts[row_idx],
                row_y_offset = row[0],
                is_rotated = row[1],
                groups = row[2],
                row_depth = row[3],
                sample_width = is_rotated ? sample_w : sample_t,
                centered_row_y = layout_start_y + row_y_offset + row_depth/2
            )
            for (group_idx = [0:len(groups)-1])
                let(
                    group_size = groups[group_idx],
                    group_start_x = calculate_group_start_x(groups, group_idx, sample_width, min_spacing, interior_width)
                )
                for (sample_idx = [0:group_size-1])
                    [
                        group_start_x + sample_idx * (sample_width + min_spacing),
                        centered_row_y,
                        is_rotated
                    ]
    ];

function calculate_group_start_x(groups, group_idx, sample_width, min_spacing, interior_width) =
    let(
        all_groups_total_samples = sum_array(groups),
        all_groups_total_width = all_groups_total_samples * sample_width + (all_groups_total_samples - 1) * min_spacing,
        
        total_samples_before = sum_array_up_to_index(groups, group_idx),
        
        layout_start_x = -all_groups_total_width/2 + sample_width/2,
        group_start_x = layout_start_x + total_samples_before * (sample_width + min_spacing)
    ) group_start_x;

function sum_array(arr) = 
    len(arr) == 0 ? 0 : 
    len(arr) == 1 ? arr[0] :
    arr[0] + sum_array([for (i = [1:len(arr)-1]) arr[i]]);

function sum_array_up_to_index(arr, index) =
    index <= 0 ? 0 : sum_array([for (i = [0:index-1]) arr[i]]);

function calculate_max_samples_per_direction(space_size, sample_size, min_spacing) =
    max(1, floor((space_size + min_spacing) / (sample_size + min_spacing)));

function calculate_total_layout_depth(row_layouts, min_spacing) =
    len(row_layouts) == 0 ? 0 :
    let(
        last_row = row_layouts[len(row_layouts)-1],
        last_row_y_offset = last_row[0],
        last_row_depth = last_row[3]
    ) last_row_y_offset + last_row_depth;