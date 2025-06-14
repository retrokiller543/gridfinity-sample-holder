// Label System for Gridfinity Sample Holder
// Generates physical 3D label objects with magnets for removable labeling

use <algorithms/grouped_v2.scad>

// Generate physical 3D label objects for printing
module generate_label_objects(box_width, box_depth, box_height, l_grid, wall_thickness, side_wall_thickness, sample_width, sample_thickness, min_spacing, cutout_start_z, row_spacing=0, enable_grouping=false, group_count=0, samples_per_group=0, group_spacing=3.0, label_text_mode="auto", label_custom_text="", label_position="center", label_width=20.0, label_height=8.0, label_thickness=1.5, magnet_diameter=6.0, magnet_thickness=2.0, magnet_count=2) {
    
    interior_width = (box_width * l_grid) - (2 * wall_thickness);
    interior_depth = (box_depth * l_grid) - (2 * side_wall_thickness);

    echo("=== Generating Physical Label Objects ===");
    
    // Generate the same layout as the main holder to get label positions
    positions = generate_single_pass_layout(interior_width, interior_depth, sample_width, sample_thickness, 
                                          min_spacing, group_count, samples_per_group, group_spacing, row_spacing);
    
    if (len(positions) > 0) {
        // Calculate label positions using the same logic as the main holder
        label_positions = calculate_label_positions(positions, group_spacing, label_position, 
                                                   label_width, label_height, sample_width, sample_thickness);
        
        if (len(label_positions) > 0) {
            echo(str("Generating ", len(label_positions), " physical labels"));
            
            // Parse custom text if provided
            custom_texts = label_text_mode == "custom" ? parse_custom_text(label_custom_text) : [];
            
            for (i = [0:len(label_positions)-1]) {
                label_pos = label_positions[i];
                label_x = label_pos[0];
                label_y = label_pos[1];
                is_rotated = label_pos[2];
                
                // Determine label text
                label_text = label_text_mode == "auto" ? 
                    str("G", i + 1) :  // G1, G2, G3, etc.
                    (i < len(custom_texts) ? custom_texts[i] : str("G", i + 1));  // Fallback to auto if not enough custom texts
                
                // Create the physical label at the calculated position
                translate([label_x, label_y, 0]) 
                    create_physical_label(label_text, is_rotated, label_width, label_height, label_thickness,
                                        magnet_diameter, magnet_thickness, magnet_count);
            }
        } else {
            echo("No label positions found - check grouping settings");
        }
    } else {
        echo("No sample positions found - cannot generate labels");
    }
}

// Create a single physical label with text and magnet holes
module create_physical_label(text, is_rotated, label_width, label_height, label_thickness, magnet_diameter, magnet_thickness, magnet_count) {
    
    // Adjust label dimensions based on rotation
    actual_width = is_rotated ? label_height : label_width;
    actual_height = is_rotated ? label_width : label_height;
    
    color("orange", 0.8) 
    difference() {
        // Main label body
        translate([-actual_width/2, -actual_height/2, 0])
            cube([actual_width, actual_height, label_thickness]);
        
        // Subtract magnet holes
        magnet_positions = calculate_magnet_positions(label_width, label_height, magnet_count, is_rotated);
        
        for (i = [0:len(magnet_positions)-1]) {
            magnet_pos = magnet_positions[i];
            magnet_x_offset = magnet_pos[0];
            magnet_y_offset = magnet_pos[1];
            
            translate([magnet_x_offset, magnet_y_offset, -0.1]) {
                cylinder(d=magnet_diameter, h=magnet_thickness + 0.2);
            }
        }
        
        // Add text (embossed/raised text on top surface)
        translate([0, 0, label_thickness - 0.3]) {
            linear_extrude(height = 0.4) {
                rotate([0, 0, is_rotated ? 90 : 0]) {
                    text(text, size = min(actual_width * 0.15, actual_height * 0.3), 
                         halign = "center", valign = "center", 
                         font = "Liberation Sans:style=Bold");
                }
            }
        }
    }
}

// Parse comma-separated custom text into array
function parse_custom_text(text_string) =
    len(text_string) == 0 ? [] :
    let(
        // Simple comma parsing - split on commas and trim spaces
        parts = split_string_on_comma(text_string)
    )
    [for (part = parts) trim_string(part)];

// Simple string splitting on comma (basic implementation)
function split_string_on_comma(str) =
    len(str) == 0 ? [] :
    let(
        comma_pos = find_first_comma(str, 0)
    )
    comma_pos == -1 ? [str] :  // No comma found, return whole string
    concat([substr(str, 0, comma_pos)], split_string_on_comma(substr(str, comma_pos + 1)));

// Find first comma in string starting from position
function find_first_comma(str, start_pos) =
    start_pos >= len(str) ? -1 :
    str[start_pos] == "," ? start_pos :
    find_first_comma(str, start_pos + 1);

// Extract substring (basic implementation)
function substr(str, start, length = -1) =
    let(
        actual_length = length == -1 ? len(str) - start : min(length, len(str) - start),
        end_pos = start + actual_length
    )
    start >= len(str) || actual_length <= 0 ? "" :
    string_slice(str, start, end_pos - 1);

// Extract character range from string (OpenSCAD compatible)
function string_slice(str, start_idx, end_idx) = 
    start_idx > end_idx ? "" :
    let(
        chars = [for (i = [start_idx:end_idx]) str[i]]
    )
    concat_chars(chars);

// Concatenate character array into string
function concat_chars(chars) =
    len(chars) == 0 ? "" :
    len(chars) == 1 ? chars[0] :
    str(chars[0], concat_chars([for (i = [1:len(chars)-1]) chars[i]]));

// Trim whitespace from string
function trim_string(str) =
    len(str) == 0 ? "" :
    let(
        first_non_space = find_first_non_space(str, 0),
        last_non_space = find_last_non_space(str, len(str) - 1)
    )
    first_non_space == -1 ? "" :  // All spaces
    substr(str, first_non_space, last_non_space - first_non_space + 1);

// Find first non-space character
function find_first_non_space(str, pos) =
    pos >= len(str) ? -1 :
    str[pos] != " " && str[pos] != "\t" ? pos :
    find_first_non_space(str, pos + 1);

// Find last non-space character
function find_last_non_space(str, pos) =
    pos < 0 ? -1 :
    str[pos] != " " && str[pos] != "\t" ? pos :
    find_last_non_space(str, pos - 1);