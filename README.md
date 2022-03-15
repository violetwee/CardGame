# Dark Forest Move Circuit

This is a submission for zku.ONE Assignment 3.

## Question 1: Dark Forest

In DarkForest the move circuit allows a player to hop from one planet to another.
Consider a hypothetical extension of DarkForest with an additional ‘energy’ parameter. If the energy of a player is 10, then the player can only hop to a planet at most 10 units away. The energy will be regenerated when a new planet is reached.
Consider a hypothetical move called the ‘triangle jump’, a player hops from planet A to B then to C and returns to A all in one move, such that A, B, and C lie on a triangle.

Write a Circom circuit that verifies this move. The coordinates of A, B, and C are private inputs. You may need to use basic geometry to ascertain that the move lies on a triangle. Also, verify that the move distances (A → B and B → C) are within the energy bounds.

## Libraries

The circom circuit uses the following circuits from the circomlib repo (https://github.com/iden3/circomlib):

- aliascheck
- binsum
- bitify
- comparators
- compconstant
- mimcsponge

## Resources

- [Circom](https://docs.circom.io/getting-started/writing-circuits/)
- [CircomLib](https://github.com/iden3/circomlib)
- [DarkForest](https://github.com/darkforest-eth/darkforest-v0.3)
