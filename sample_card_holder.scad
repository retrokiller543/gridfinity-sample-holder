/*
 * Gridfinity Sample Box Generator
 * Converted from Python script to OpenSCAD for MakerWorld customization
 * Uses gridfinity-rebuilt-openscad library for proper gridfinity base generation
 */

// Include the gridfinity library (MakerWorld compatible paths)
include <gridfinity-rebuilt-openscad/standard.scad>
use <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>
use <gridfinity-rebuilt-openscad/generic-helpers.scad>

// Include our modular components
use <src/gridfinity_box.scad>
use <src/sample_cutouts.scad>
use <src/grouped_sample_cutouts.scad>
use <src/algorithms/grouped_v2.scad>
use <src/label_system.scad>

/* [Box Dimensions] */
// Width of the box in gridfinity units (42mm each)
sh_box_width = 1; // [1:0.5:10]
// Depth of the box in gridfinity units (42mm each)  
sh_box_depth = 4; // [1:0.5:10]
// Total height of the box in millimeters
sh_box_height = 21; // [15:0.2:50]

/* [Sample Dimensions] */
// Width of each sample card in millimeters
sh_sample_width = 76; // [20:1:300]
// Height of each sample card in millimeters (for reference only)
sh_sample_height = 15; // [10:1:25]
// Thickness of each sample card in millimeters
sh_sample_thickness = 2.4; // [1:0.1:10]

/* [Gridfinity Settings] */
// Grid unit size in mm (standard gridfinity is 42mm)
l_grid = 42; // [35:1:50]
// Base height in mm (standard gridfinity is 5mm)
h_base = 5; // [3:0.5:8]
// Bottom thickness in mm (standard gridfinity is 2.2mm)
h_bot = 2.2; // [1.5:0.1:4]
// Base hole style for baseplate compatibility
style_hole = 0; // [0:No holes, 1:Magnet holes only, 2:Magnet and screw holes, 3:Magnet and screw holes with printable slit, 4:Refined holes (no glue needed)]
// Lip style for stacking compatibility
style_lip = 0; // [0:Regular lip, 1:Remove lip subtractively, 2:Remove lip and retain height]

/* [Advanced Settings] */
// X-axis wall thickness for calculating interior space
sh_wall_thickness = 3.6; // [2:0.1:6]
// Y-axis wall thickness for calculating interior space
sh_side_wall_thickness = 3.75; // [2:0.1:6]
// Minimum spacing between sample cutouts
sh_min_spacing = 1.0; // [0.5:0.1:3]
// Height from bottom where sample cutouts start
sh_cutout_start_z = 6.0; // [4:0.1:10]
// Layout algorithm selection
sh_algorithm_type = 2; // [0:Grid Layout, 1:Multi-Pass Grouping, 2:Single-Pass Grouping]
// Row spacing for grouping algorithms (0 = auto-calculate)
sh_row_spacing = 0; // [0:0.1:20]
// Force sample orientation (auto = choose best fit, normal = 2.4mm along X, rotated = 76mm along X)
sh_force_orientation = "auto"; // [auto, normal, rotated]

/* [Grouping Settings] */
// Enable group-based layout (instead of row-based)
sh_enable_grouping = false; // [true, false]
// Number of groups to create (0 = auto-calculate)
sh_group_count = 0; // [0:1:100]
// Number of samples per group (0 = auto-calculate)
sh_samples_per_group = 0; // [0:1:100]
// Spacing between groups in millimeters
sh_group_spacing = 10.0; // [1:0.1:100]

/* [Group Label Settings] */
// === Label System ===
// Enable magnetic removable labels between groups
sh_enable_labels = false; // [true, false]
// Generate separate label objects for printing
sh_generate_labels = false; // [true, false]
// Include label and spacing for the first group in each row. This will reduce the number of samples per row but improve the experience with labels.
sh_include_first_group_label = false; // [true, false]
// Label text mode: auto generates G1, G2, etc., custom uses provided text
sh_label_text_mode = "auto"; // [auto, custom]
// Custom label text (comma-separated for multiple groups, e.g., "Sample A,Sample B,Sample C")
sh_label_custom_text = "Group 1,Group 2,Group 3";
// Label position within group spacing area
sh_label_position = "center"; // [start, center, end]
// Label dimensions in millimeters
sh_label_width = 76.0; // [3:0.5:100]
sh_label_height = 10.0; // [3:0.5:300]
sh_label_thickness = 3.5; // [1.5:0.1:6]

/* [Magnet Settings] */
// Magnet system for removable labels
sh_magnet_diameter = 6.0; // [3:0.5:15]
sh_magnet_thickness = 2.0; // [0.5:0.1:5]
sh_magnet_count = 1; // [1:1:6]

/* [Text Styling] */
// Text style on labels
sh_text_style = "embossed"; // [embossed, debossed, inset]
// Depth/height of text (positive for embossed/debossed, negative for inset)
sh_text_depth = 0.4; // [0.1:0.05:1.0]
// Font size in mm (0 = auto-calculate based on label size)
sh_font_size = 0; // [0:0.5:10]
// Font family and style
sh_font_family = "Liberation Sans:style=Bold";

// Assert validation
assert(sh_min_spacing >= 0.5, "Minimum spacing must be at least 0.5mm to ensure proper cutout separation and ease of printing.");

// Multi-plate 3MF generation modules (following Bambu Lab guide)
module mw_plate_1() {
    // Main gridfinity holder
    color("lightgray") 
    difference() {
        gridfinity_box(sh_box_width, sh_box_depth, sh_box_height, l_grid, style_lip, style_hole, cut_to_height=true);
        
        // Subtract sample cutouts from the top
        if (sh_enable_grouping || sh_algorithm_type == 2) {
            grouped_v2(sh_box_width, sh_box_depth, sh_box_height, l_grid, sh_wall_thickness, 
                       sh_side_wall_thickness, sh_sample_width, sh_sample_thickness, 
                       sh_min_spacing, sh_cutout_start_z, sh_row_spacing, sh_enable_grouping,
                       sh_group_count, sh_samples_per_group, sh_group_spacing,
                       sh_enable_labels, sh_include_first_group_label, sh_label_text_mode, sh_label_custom_text, sh_label_position,
                       sh_label_width, sh_label_height, sh_label_thickness,
                       sh_magnet_diameter, sh_magnet_thickness, sh_magnet_count,
                       sh_text_style, sh_text_depth, sh_font_size, sh_font_family, sh_force_orientation);
        } else if (sh_algorithm_type == 1) {
            grouped_sample_cutouts(sh_box_width, sh_box_depth, sh_box_height, l_grid, sh_wall_thickness, 
                                  sh_side_wall_thickness, sh_sample_width, sh_sample_thickness, 
                                  sh_min_spacing, sh_cutout_start_z, sh_row_spacing, sh_enable_grouping,
                                  sh_group_count, sh_samples_per_group, sh_group_spacing);
        } else {
            sample_cutouts(sh_box_width, sh_box_depth, sh_box_height, l_grid, sh_wall_thickness, 
                          sh_side_wall_thickness, sh_sample_width, sh_sample_thickness, 
                          sh_min_spacing, sh_cutout_start_z);
        }
    }
}

module mw_plate_2() {
    // Label objects for separate printing
    if (sh_enable_labels && (sh_enable_grouping || sh_algorithm_type == 2)) {
        generate_label_objects(sh_box_width, sh_box_depth, sh_box_height, l_grid, sh_wall_thickness, 
                              sh_side_wall_thickness, sh_sample_width, sh_sample_thickness, 
                              sh_min_spacing, sh_cutout_start_z, sh_row_spacing, sh_enable_grouping,
                              sh_group_count, sh_samples_per_group, sh_group_spacing,
                              sh_include_first_group_label, sh_label_text_mode, sh_label_custom_text, sh_label_position,
                              sh_label_width, sh_label_height, sh_label_thickness,
                              sh_magnet_diameter, sh_magnet_thickness, sh_magnet_count,
                              sh_text_style, sh_text_depth, sh_font_size, sh_font_family, sh_force_orientation);
    }
}

module mw_assembly_view() {
    // Combined assembly view for preview
    mw_plate_1();
    
    if (sh_generate_labels && sh_enable_labels && (sh_enable_grouping || sh_algorithm_type == 2)) {
        translate([0, 0, 30]) // Move labels above the main holder for visibility
            mw_plate_2();
    }
}

development_mode = false;

// For development, show both plates in the assembly view
if (development_mode) {
    mw_assembly_view();
}

// Display information
echo("=== Gridfinity Sample Box Generator ===");
echo(str("Algorithm: ", sh_algorithm_type == 0 ? "Grid Layout" : sh_algorithm_type == 1 ? "Multi-Pass Grouping" : "Single-Pass Grouping"));
echo(str("Box: ", sh_box_width, "x", sh_box_depth, " gridfinity units"));  
echo(str("Dimensions: ", sh_box_width * l_grid, " x ", sh_box_depth * l_grid, " x ", sh_box_height, " mm"));
echo(str("Sample: ", sh_sample_thickness, " x ", sh_sample_width, " x ", sh_sample_height, " mm"));
echo(str("Cutout depth: ", sh_cutout_start_z, " mm"));
echo(str("Minimum wall thickness: ", sh_min_spacing, " mm"));