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