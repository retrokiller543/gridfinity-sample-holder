include <layout_calculator.scad>

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