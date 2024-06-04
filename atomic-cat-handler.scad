tolerance = 0.1;
epsilon = 0.01;

// Casing
casing_width = 170;
casing_thickness = 3;
casing_outer_edge = 15;
casing_honeycomb_diameter = 20;
casing_honeycomb_thickness = 3;

// Filter
filter_thickness = 10;
filter_grid_thickness = 5;

// Fan frame
fan_width = 140;
fan_height = 25;
fan_screw_spacing = 124.5;

// Magnet
magnet_diameter = 8;
magnet_thickness = 1.7;

// Screw
screw_radius = 1.5;
screw_head_thickness = 1;
screw_head_diameter = 8;

// Computed
casing_height = filter_thickness + filter_grid_thickness + fan_height;
casing_inner_edge = (casing_width - fan_width - 2 * tolerance) / 2;
magnet_hole_radius = magnet_diameter / 2 + tolerance;
magnet_hole_thickness = magnet_thickness + 2 * tolerance;

screw_hole_radius = screw_radius + tolerance;
screw_head_hole_thickness = screw_head_thickness + 2 * tolerance;
screw_head_hole_radius = screw_head_diameter / 2 + tolerance;


module screw_hole() {
                cylinder(h = screw_head_hole_thickness, r = screw_head_hole_radius, $fn= 100);
            translate([0,0,-casing_thickness]) cylinder(h = 2 * casing_thickness, r = screw_hole_radius, $fn= 100);
}

module magnet_hole() {
            cylinder(h = magnet_hole_thickness, r = magnet_hole_radius, $fn= 100);
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
        cube([casing_width, casing_width, casing_height]); // base rectangle
        translate([casing_inner_edge, casing_inner_edge, -epsilon]) cube([fan_width + 2 * tolerance, fan_width + 2 * tolerance, casing_height + 2 * epsilon]); // casing main hole
        difference() { // rectangular outer ring built by making the difference between a wider rectangle and the target outer size
            translate([-epsilon, -epsilon, -epsilon]) cube([casing_width + 2 * epsilon, casing_width + 2 * epsilon, casing_height - casing_thickness + epsilon]);
            translate([casing_inner_edge - casing_thickness, casing_inner_edge - casing_thickness]) cube([fan_width + 2 * casing_thickness + 2 * tolerance, fan_width + 2 * casing_thickness + 2 * tolerance, casing_height - casing_thickness]);
        }
        // making the holes for the magnets and the screw heads
        translate([casing_inner_edge / 2, casing_inner_edge / 2, casing_height - magnet_hole_thickness + epsilon]) magnet_hole();
        translate([casing_width - casing_inner_edge / 2, casing_inner_edge / 2, casing_height - magnet_hole_thickness + epsilon]) magnet_hole();
        translate([casing_width - casing_inner_edge / 2, casing_width - casing_inner_edge / 2, casing_height - magnet_hole_thickness + epsilon]) magnet_hole();
        translate([casing_inner_edge / 2, casing_width - casing_inner_edge / 2, casing_height - magnet_hole_thickness + epsilon]) magnet_hole();
        
        // making the holes for the magnets and the screw heads
        translate([casing_inner_edge / 2, casing_width / 2, casing_height - screw_head_hole_thickness + epsilon]) screw_hole();
        
        translate([casing_width / 2, casing_inner_edge / 2, casing_height - screw_head_hole_thickness + epsilon]) screw_hole();
        
        translate([casing_width - casing_inner_edge / 2, casing_width / 2, casing_height - screw_head_hole_thickness + epsilon]) screw_hole();
        
        translate([casing_width / 2, casing_width - casing_inner_edge / 2, casing_height - screw_head_hole_thickness + epsilon]) screw_hole();
    }

    intersection() { // making the bottom honeycomb adjusted to size
        linear_extrude(casing_thickness)hex_grid(casing_honeycomb_diameter, casing_honeycomb_thickness, fan_width / casing_honeycomb_diameter * 2, fan_width / casing_honeycomb_diameter * 2);
        translate([casing_inner_edge, casing_inner_edge]) cube([fan_width, fan_width, casing_height]);
        
    }
    
    translate([casing_inner_edge - epsilon, casing_inner_edge -epsilon, 0]) difference()  {  // making the circular edge around the honeycomb
        cube([fan_width + 2 * tolerance + 2 * epsilon, fan_width + 2 * tolerance + 2 * epsilon, casing_thickness]);
        translate([fan_width / 2, fan_width / 2, -casing_thickness]) cylinder(h = 3 * casing_thickness , r = fan_width / 2);
    }
}

module frame() {
    difference () {
        union () {
            difference() {
                cube([casing_width, casing_width, casing_thickness]); // rectangular frame
                translate([casing_inner_edge,casing_inner_edge, -epsilon]) cube([fan_width + 2 * tolerance, fan_width + 2 * tolerance, casing_thickness + 2 * epsilon]); // inner hole
                 // magnet holes
                translate([casing_inner_edge / 2 , casing_inner_edge / 2, -epsilon]) magnet_hole();
                translate([casing_width - casing_inner_edge / 2, casing_inner_edge / 2, -epsilon]) magnet_hole();
                translate([casing_width - casing_inner_edge / 2, casing_width - casing_inner_edge / 2, -epsilon]) magnet_hole();
                translate([casing_inner_edge / 2, casing_width - casing_inner_edge / 2, -epsilon]) magnet_hole();
            }
    
            translate([casing_inner_edge - epsilon, casing_inner_edge -epsilon, 0]) difference()  { // round hole
                cube([fan_width + 2 * tolerance + 2 * epsilon, fan_width + 2 * tolerance + 2 * epsilon, casing_thickness]);
                translate([fan_width / 2, fan_width / 2, -casing_thickness]) cylinder(h = 3 * casing_thickness , r = fan_width / 2);
            }

            intersection() { // honeycomb grid
                linear_extrude(casing_thickness)hex_grid(casing_honeycomb_diameter, casing_honeycomb_thickness, fan_width / casing_honeycomb_diameter * 2, fan_width / casing_honeycomb_diameter * 2);
                translate([casing_inner_edge, casing_inner_edge]) cube([fan_width, fan_width, casing_height]);
            }
        }
        
        // fan mounting screws
        translate([(casing_width - fan_screw_spacing) / 2, (casing_width - fan_screw_spacing) / 2, casing_thickness - screw_head_thickness])  screw_hole();
        translate([casing_width - (casing_width - fan_screw_spacing) / 2, (casing_width - fan_screw_spacing) / 2, casing_thickness - screw_head_thickness])  screw_hole();
        translate([casing_width - (casing_width - fan_screw_spacing) / 2, casing_width - (casing_width - fan_screw_spacing) / 2, casing_thickness - screw_head_thickness])  screw_hole();
        translate([(casing_width - fan_screw_spacing) / 2, casing_width - (casing_width - fan_screw_spacing) / 2, casing_thickness - screw_head_thickness]) screw_hole();
    }
}

casing();

translate([0,0,2 * casing_height]) frame();

