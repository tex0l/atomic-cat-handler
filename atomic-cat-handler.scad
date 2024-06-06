$fa = 2;
$fs= 0.2;

tolerance = 0.1;
epsilon = 0.01;

/// START Diagram
///
/// Frame
/// ______ _ _ _ _ _ _ _ _ _ _ _ ______
///     |                        |
///     |                        |
///     |                        |
///
/// Fan
///      ________________________
///     |                        |
///     |          FAN           |
///     |________________________|
///
/// Grid
///
///     __ _ _ _ _ _ _ _ _ _ _ _ _
///
///
/// Filter
///      ________________________
///     |         Filter         |
///      ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
///
/// Casing
/// _____                        ______
///     |                        |
///     |                        |
///     |                        |
///     |_ _ _ _ _ _ _ _ _ _ _ _ |
///
///  END Diagram

// Casing
casing_width = 170;
casing_walls_thickness = 2.5;
casing_honeycomb_diameter = 20;
casing_honeycomb_thickness = 2.5;

// Filter
filter_thickness = 10;

// Grid
grid_thickness = 2.5;
grid_honeycomb_diameter = 20;
grid_honeycomb_thickness = 2.5;

// Fan
fan_width = 140;
fan_height = 27.5;
fan_screw_spacing = 124.5;
fan_wire_x= 107.8;
fan_wire_cutting_width = 6;
fan_wire_cutting_depth = 1.8;
fan_walls_thickness = 1;
fan_width_tolerance = 2;

// Frame
frame_walls_thickness = 2.5;

// Magnet
magnet_diameter = 8.1;
magnet_thickness = 1.8;

// Screw
screw_diameter = 4;
screw_head_thickness = 1.6;
screw_head_diameter = 9;

// Computed
frame_height = 2 * frame_walls_thickness + fan_height + 2 * tolerance;
frame_hole_inner_width = fan_width + fan_width_tolerance + 2 * tolerance;
frame_hole_outer_width = frame_hole_inner_width + 2 * frame_walls_thickness;

casing_height = casing_walls_thickness + filter_thickness + grid_thickness + frame_height - frame_walls_thickness;
casing_hole_inner_width = frame_hole_outer_width + 10 * tolerance;
casing_hole_outer_width = casing_hole_inner_width + 2 * casing_walls_thickness;

magnet_hole_radius = magnet_diameter / 2 + tolerance;
magnet_hole_thickness = magnet_thickness + 2 * tolerance;

screw_hole_radius = screw_diameter / 2 + tolerance;
screw_head_hole_thickness = screw_head_thickness + 2 * tolerance;
screw_head_hole_radius = screw_head_diameter / 2 + tolerance;

module screw_head_hole() {
    translate([0, 0, -screw_head_hole_thickness + epsilon]) union() {
        cylinder(h = screw_head_hole_thickness, r = screw_head_hole_radius, $fn= 100);
    }
}

module screw_hole() {
    translate([0, 0, -screw_head_hole_thickness + epsilon]) union() {
        cylinder(h = screw_head_hole_thickness, r = screw_head_hole_radius, $fn= 100);
        translate([0,0,- 2 * casing_walls_thickness + screw_head_hole_thickness]) cylinder(h = 4 * casing_walls_thickness, r = screw_hole_radius, $fn= 100);
    }
}

module magnet_hole() {
    translate([0, 0, -magnet_hole_thickness + epsilon]) cylinder(h = magnet_hole_thickness, r = magnet_hole_radius, $fn= 100);
}


module hex(diameter, thickness) {
    difference() {
        circle(d=diameter,$fn=6);
        circle(d=diameter - thickness * 2,$fn=6);
    }
}


function compute_x_delta(outer_radius,inner_radius) = (outer_radius + inner_radius) * 0.5 * (1 + cos(60));
function compute_y_delta(outer_radius,inner_radius) = (outer_radius + inner_radius) * 0.5 * sin(60);


module hex_grid(diameter, thickness, rows, columns) {


    outer_radius = diameter / 2;
    inner_radius = outer_radius - thickness;

    x_delta = compute_x_delta(outer_radius,inner_radius);

    y_delta = compute_y_delta(outer_radius,inner_radius);

    union() {
        for (r=[0:1:rows - 1]) {
            translate([0, 2 * y_delta * r, 0]) {
                for (c=[0:2:columns - 1]) {
                    translate([x_delta * c, 0, 0]) hex(diameter, thickness);
                }

                for (c=[1:2:columns - 1]) {
                    translate([x_delta * c, y_delta, 0]) hex(diameter, thickness);
                }
            }
        }
    }
}

module casing() {
    difference() {
        union() {
            difference() {
                cube([casing_width, casing_width, casing_height], center = true);
                translate([0, 0, -epsilon]) cube([casing_hole_inner_width, casing_hole_inner_width, 2 * casing_height], , center = true);
                translate([0, 0, - casing_walls_thickness / 2]) difference() {
                    cube([casing_width + 2 * tolerance, casing_width + 2 * tolerance, casing_height - frame_walls_thickness + epsilon], center = true);
                    cube([casing_hole_outer_width, casing_hole_outer_width, 2 * casing_height], center = true);
                }
            }

            translate([0,0, -casing_height / 2 + casing_walls_thickness / 2]) union() {
                    intersection() { // making the bottom honeycomb adjusted to size
                    translate([-casing_hole_inner_width / 2, -casing_hole_inner_width/2, -casing_walls_thickness / 2]) linear_extrude(casing_walls_thickness) hex_grid(casing_honeycomb_diameter, casing_honeycomb_thickness, fan_width / casing_honeycomb_diameter * 2, casing_hole_outer_width / casing_honeycomb_diameter * 2);
                    cube([casing_hole_inner_width, casing_hole_inner_width, casing_height], center = true);
                }

                difference()  {  // making the circular edge around the honeycomb
                    cube([casing_hole_inner_width + 2 * tolerance + 2 * epsilon, casing_hole_inner_width + 2 * tolerance + 2 * epsilon, casing_walls_thickness], center= true);
                    translate([0,0,-casing_walls_thickness]) cylinder(h = 3 * casing_walls_thickness , r = casing_hole_inner_width / 2 - fan_walls_thickness);
                }
            }
        }
        translate([(casing_width + casing_hole_inner_width) / 4  , 0, casing_height / 2]) screw_hole();
        translate([-(casing_width + casing_hole_inner_width) / 4  , 0, casing_height / 2]) screw_hole();
        translate([0, (casing_width + casing_hole_inner_width) / 4, casing_height / 2]) screw_hole();
        translate([0, -(casing_width + casing_hole_inner_width) / 4, casing_height / 2]) screw_hole();
        translate([(casing_width + casing_hole_inner_width) / 4, (casing_width + casing_hole_inner_width) / 4, casing_height / 2]) magnet_hole();
        translate([-(casing_width + casing_hole_inner_width) / 4, (casing_width + casing_hole_inner_width) / 4, casing_height / 2]) magnet_hole();
        translate([(casing_width + casing_hole_inner_width) / 4, -(casing_width + casing_hole_inner_width) / 4, casing_height / 2]) magnet_hole();
        translate([-(casing_width + casing_hole_inner_width) / 4,
        -(casing_width + casing_hole_inner_width) / 4, casing_height / 2]) magnet_hole();

        translate([frame_hole_inner_width / 2 + casing_walls_thickness / 2, frame_hole_inner_width / 2 - fan_wire_x, casing_height / 2 - fan_wire_cutting_depth / 2 + epsilon ]) cube([casing_width / 2, fan_wire_cutting_width, fan_wire_cutting_depth], center= true);
    }
}

module grid() {
    difference () {
        union() {
            intersection() { // making the bottom honeycomb adjusted to size
            translate([-fan_width / 2, -fan_width / 2, -frame_walls_thickness / 2]) linear_extrude(frame_walls_thickness) hex_grid(casing_honeycomb_diameter, casing_honeycomb_thickness, fan_width / casing_honeycomb_diameter * 2, frame_hole_outer_width / casing_honeycomb_diameter * 2);
            cube([fan_width + 2 * frame_walls_thickness , fan_width + 2 * frame_walls_thickness , casing_height], center = true);
        }

            difference()  {  // making the circular edge around the honeycomb
                cube([fan_width + 2 * frame_walls_thickness , fan_width + 2 * frame_walls_thickness, frame_walls_thickness], center= true);
                translate([0,0,-frame_walls_thickness]) cylinder(h = 3 * frame_walls_thickness , r = fan_width / 2 - fan_walls_thickness);
            }
        }

       translate([fan_screw_spacing / 2 , -fan_screw_spacing / 2, - frame_walls_thickness / 2 + screw_head_hole_thickness - 2 * epsilon]) screw_hole();
       translate([-fan_screw_spacing / 2 , fan_screw_spacing / 2, - frame_walls_thickness / 2 + screw_head_hole_thickness - 2 * epsilon]) screw_hole();
       translate([-fan_screw_spacing / 2 , -fan_screw_spacing / 2, - frame_walls_thickness / 2 + screw_head_hole_thickness - 2 * epsilon]) screw_hole();
       translate([fan_screw_spacing / 2, fan_screw_spacing / 2, - frame_walls_thickness / 2 + screw_head_hole_thickness - 2 * epsilon]) screw_hole();
    }

}

module frame() {
    difference () {
        union() {
            difference() {
                cube([casing_width, casing_width, frame_height], center = true);
                translate([0, 0, -epsilon]) cube([frame_hole_inner_width, frame_hole_inner_width, 2 * frame_height], , center = true);
                translate([0, 0, - frame_walls_thickness / 2]) difference() {
                    cube([casing_width + 2 * tolerance, casing_width + 2 * tolerance, frame_height - frame_walls_thickness + epsilon ], center = true);
                    cube([frame_hole_outer_width, frame_hole_outer_width, 2 * frame_height], center = true);
                }
            }

            translate([0,0, frame_height / 2 - frame_walls_thickness / 2]) union() {
                    intersection() { // making the bottom honeycomb adjusted to size
                    translate([-frame_hole_inner_width / 2, -frame_hole_inner_width/2, -frame_walls_thickness / 2]) linear_extrude(frame_walls_thickness) hex_grid(casing_honeycomb_diameter, casing_honeycomb_thickness, fan_width / casing_honeycomb_diameter * 2, frame_hole_outer_width / casing_honeycomb_diameter * 2);
                    cube([frame_hole_inner_width, frame_hole_inner_width, casing_height], center = true);
                }

                difference()  {  // making the circular edge around the honeycomb
                    cube([frame_hole_inner_width + 2 * tolerance + 2 * epsilon, frame_hole_inner_width + 2 * tolerance + 2 * epsilon, frame_walls_thickness], center= true);
                    translate([0,0,-frame_walls_thickness]) cylinder(h = 3 * frame_walls_thickness , r = frame_hole_inner_width / 2 - fan_walls_thickness);
                }
            }
        }
       translate([fan_screw_spacing / 2 , -fan_screw_spacing / 2, frame_height / 2]) screw_hole();
       translate([-fan_screw_spacing / 2 , fan_screw_spacing / 2, frame_height / 2]) screw_hole();
       translate([-fan_screw_spacing / 2 , -fan_screw_spacing / 2, frame_height / 2]) screw_hole();
       translate([fan_screw_spacing / 2, fan_screw_spacing / 2, frame_height / 2]) screw_hole();
       translate([(casing_width + casing_hole_inner_width) / 4, (casing_width + casing_hole_inner_width) / 4, frame_height / 2 - frame_walls_thickness + magnet_hole_thickness - 2 * epsilon]) magnet_hole();
       translate([-(casing_width + casing_hole_inner_width) / 4, (casing_width + casing_hole_inner_width) / 4, frame_height / 2 - frame_walls_thickness + magnet_hole_thickness - 2 * epsilon]) magnet_hole();
       translate([(casing_width + casing_hole_inner_width) / 4, -(casing_width + casing_hole_inner_width) / 4, frame_height / 2 - frame_walls_thickness + magnet_hole_thickness - 2 * epsilon]) magnet_hole();
       translate([-(casing_width + casing_hole_inner_width) / 4, -(casing_width + casing_hole_inner_width) / 4, frame_height / 2 - frame_walls_thickness + magnet_hole_thickness - 2 * epsilon]) magnet_hole();


        translate([(casing_width + casing_hole_inner_width) / 4  , 0, frame_height / 2 + screw_head_thickness - frame_walls_thickness - 2 * epsilon]) screw_head_hole();
        translate([-(casing_width + casing_hole_inner_width) / 4  , 0, frame_height / 2 + screw_head_thickness - frame_walls_thickness - 2 * epsilon]) screw_head_hole();
        translate([0, (casing_width + casing_hole_inner_width) / 4, frame_height / 2 + screw_head_thickness - frame_walls_thickness - 2 * epsilon]) screw_head_hole();
        translate([0, -(casing_width + casing_hole_inner_width) / 4, frame_height / 2 + screw_head_thickness - frame_walls_thickness - 2 * epsilon]) screw_head_hole();

        translate([frame_hole_inner_width / 2 + frame_walls_thickness / 2, fan_width / 2 - fan_wire_x, - frame_walls_thickness  / 2 - epsilon]) cube([frame_walls_thickness + 2 * epsilon, fan_wire_cutting_width, frame_height - frame_walls_thickness], center= true);
    }
}


casing();

translate([0,0, casing_height]) grid();

translate([0,0,2 * casing_height]) frame();

