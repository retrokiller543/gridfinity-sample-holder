include <gridfinity-rebuilt-openscad/standard.scad>
use <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>
use <gridfinity-rebuilt-openscad/generic-helpers.scad>

module gridfinity_box(box_width, box_depth, box_height, l_grid, style_lip, style_hole, cut_to_height=true) {
    if (cut_to_height) {
        intersection() {
            gridfinity_box_base(box_width, box_depth, l_grid, style_lip, style_hole);
            
            translate([0, 0, box_height/2])
                cube([box_width * l_grid + 10, box_depth * l_grid + 10, box_height], center=true);
        }
    } else {
        gridfinity_box_base(box_width, box_depth, l_grid, style_lip, style_hole);
    }
}

module gridfinity_box_base(box_width, box_depth, l_grid, style_lip, style_hole) {
    union() {
        gridfinityInit(box_width, box_depth, height(10, 0, style_lip, false), 0, l_grid, style_lip) {
        }
        gridfinityBase(box_width, box_depth, l_grid, 0, 0, style_hole);
    }
}