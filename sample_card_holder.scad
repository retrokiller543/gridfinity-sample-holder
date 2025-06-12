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

/* [Box Dimensions] */
// Width of the box in gridfinity units (42mm each)
sh_box_width = 1; // [1:0.5:10]
// Depth of the box in gridfinity units (42mm each)  
sh_box_depth = 4; // [1:0.5:10]
// Total height of the box in millimeters
sh_box_height = 21; // [15:0.2:50]

/* [Sample Dimensions] */
// Width of each sample card in millimeters
sh_sample_width = 76; // [50:1:100]
// Height of each sample card in millimeters (for reference only)
sh_sample_height = 15; // [10:1:25]
// Thickness of each sample card in millimeters
sh_sample_thickness = 2.4; // [1:0.1:5]

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
sh_algorithm_type = 1; // [0:Simple Layout, 1:Advanced Grouping]
// Row spacing for advanced grouping algorithm (0 = auto-calculate)
sh_row_spacing = 0; // [0:0.1:20]

// Main model - create solid gridfinity box without lip, then subtract cutouts
color("lightgray") 
difference() {
    gridfinity_box(sh_box_width, sh_box_depth, sh_box_height, l_grid, style_lip, style_hole, cut_to_height=true);
    
    // Subtract sample cutouts from the top
    if (sh_algorithm_type == 0) {
        sample_cutouts(sh_box_width, sh_box_depth, sh_box_height, l_grid, sh_wall_thickness, 
                      sh_side_wall_thickness, sh_sample_width, sh_sample_thickness, 
                      sh_min_spacing, sh_cutout_start_z);
    } else {
        grouped_sample_cutouts(sh_box_width, sh_box_depth, sh_box_height, l_grid, sh_wall_thickness, 
                              sh_side_wall_thickness, sh_sample_width, sh_sample_thickness, 
                              sh_min_spacing, sh_cutout_start_z, sh_row_spacing);
    }
}



// Display information
echo("=== Gridfinity Sample Box Generator ===");
echo(str("Algorithm: ", sh_algorithm_type == 0 ? "Simple Layout" : "Advanced Grouping"));
echo(str("Box: ", sh_box_width, "x", sh_box_depth, " gridfinity units"));  
echo(str("Dimensions: ", sh_box_width * l_grid, " x ", sh_box_depth * l_grid, " x ", sh_box_height, " mm"));
echo(str("Sample: ", sh_sample_thickness, " x ", sh_sample_width, " x ", sh_sample_height, " mm"));
echo(str("Cutout depth: ", sh_cutout_start_z, " mm"));
echo(str("Minimum wall thickness: ", sh_min_spacing, " mm"));