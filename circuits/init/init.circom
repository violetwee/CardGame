pragma circom 2.0.0;

include "../lib/bitify.circom";
include "../lib/mimcsponge.circom";
include "../lib/range.circom";
/*
    This circuit verifies that the first card is a valid card.

    Prove: I know (card_value, card_suit, salt) such that:
    - (1): card_value is between 1 and 13, where Ace=1 and King=13
    - (2): card_suit is between 1 and 4, where spades=1, hearts=2, club=3 and diamond=4 
    - (3): salt is a random generated value that changes for every draw
*/

template Main() {
  signal input card_value;
  signal input card_suit;
  signal input salt;
  signal output card; // hash(card_value, card_suit, salt)

  // verify card values are in proper range (1-13)
  component rp = Range(4, 1, 13);
  rp.in <== card_value;

  // verify that card suits are in proper range (1-4)
  component rp_suit = Range(4, 1, 4);
  rp_suit.in <== card_suit;

  // hash card_value,  card_suit and salt 
  // to be stored as commitment on-chain
  component mimc = MiMCSponge(2, 220, 1);
  mimc.ins[0] <== card_value;
  mimc.ins[1] <== card_suit;
  // mimc.ins[2] <== salt;
  mimc.k <== salt;
  card <== mimc.outs[0];
}

component main {public [card_value, card_suit]} = Main();