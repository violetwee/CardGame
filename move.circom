pragma circom 2.0.0;

include "./circomlib/bitify.circom";

/*
    This circuit verifies that a player's move from coordinates A->B->C is valid.
    (1): Check that coordinates B and C (new coordinates) are within the play circle (boundary)
    (2): A->B->C move should lie on a triangle: Check that the area formed by these 3 points is not 0.
    (3): Check that A->B distance is within the energy bounds
    (4): Check that B->C distance is within the energy bounds

    Prove: I know (x1,y1,x2,y2,x3,y3,p2,r2,energy) such that:
    - (1): x2^2 + y2^2 <= r^2 and x3^2 + y3^2 <= r^2
    - (2): x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2) > 0
    - (3): ((x1-x2)^2 + (y1-y2)^2) <= energy^2
    - (4): ((x2-x3)^2 + (y2-y3)^2) <= energy^2
*/

template Boundary() {
    signal input x;
    signal input y;
    signal input r;
    signal output out;

    component comp = LessThan(32);
    signal xSq;
    signal ySq;
    signal rSq;
    xSq <== x * x;
    ySq <== y * y;
    rSq <== r * r;
    comp.in[0] <== xSq + ySq;
    comp.in[1] <== rSq;
    out <== comp.out;
}

template Hop() {
  signal input x1;
  signal input y1;
  signal input x2;
  signal input y2;
  signal input energy;
  signal output out;

  signal diffX;
  signal diffY;
  diffX <== x1 - x2;
  diffY <== y1 - y2;

  component comp = LessEqThan(32);
  signal diffXSq;
  signal diffYSq;
  diffXSq <== diffX * diffX;
  diffYSq <== diffY * diffY;
  comp.in[0] <== diffXSq + diffYSq;
  comp.in[1] <== energy * energy;
  out <== comp.out;
}

template Main() {
  signal input x1;
  signal input y1;
  signal input x2;
  signal input y2;
  signal input x3;
  signal input y3;
  signal input r;
  signal input energy;

  // (1): Check that coordinates B and C (new coordinates) are within the play circle (boundary)
    // check x2^2 + y2^2 <= r^2 and x3^2 + y3^2 <= r^2
  component boundaryB = Boundary();
  boundaryB.x <== x2;
  boundaryB.y <== y2;
  boundaryB.r <== r;
  boundaryB.out === 1;

  component boundaryC = Boundary();
  boundaryC.x <== x3;
  boundaryC.y <== y3;
  boundaryC.r <== r;
  boundaryC.out === 1;

  // (2): A->B->C move should lie on a triangle: Check that the area formed by these 3 points is not 0.
  // check x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2) > 0
  component triangle = GreaterThan(32); 
  signal a1;
  signal a2;
  signal a3;
  a1 <== x1 * (y2 - y3);
  a2 <== x2 * (y3 - y1);
  a3 <== x3 * (y1 - y2);
  triangle.in[0] <== a1 + a2 + a3;
  triangle.in[1] <== 0;
  triangle.out === 1;

  // (3): Check that A->B distance is within the energy bounds
  // check ((x1-x2)^2 + (y1-y2)^2) <= energy^2
  component hopAB = Hop();
  hopAB.x1 <== x1;
  hopAB.y1 <== y1;
  hopAB.x2 <== x2;
  hopAB.y2 <== y2;
  hopAB.energy <== energy;
  hopAB.out === 1;

  // (4): Check that B->C distance is within the energy bounds
  // check ((x2-x3)^2 + (y2-y3)^2) <= energy^2
  component hopBC = Hop();
  hopBC.x1 <== x2;
  hopBC.y1 <== y2;
  hopBC.x2 <== x3;
  hopBC.y2 <== y3;
  hopBC.energy <== energy;
  hopBC.out === 1;
}

component main = Main();