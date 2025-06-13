include <grouping_layout_calculator.scad>

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