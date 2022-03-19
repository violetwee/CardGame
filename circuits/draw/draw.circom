pragma circom 2.0.0;

include "../lib/bitify.circom";
include "../lib/mimcsponge.circom";
include "../lib/range.circom";
/*
    This circuit verifies that the card_suit2 is the same as card_suit1.

    Prove: I know (card_value1, card_suit1, card_value2, card_suit2, salt) such that:
    - (1): card_value1 and card_value2 are between 1 and 13, where Ace=1 and King=13
    - (2): card_suit1 and card_suit2 are between 1 and 4, where spades=1, hearts=2, club=3 and diamond=4 
    - (3): salt is a random generated value
*/

template Main() {
  signal input card_value1;
  signal input card_suit1;
  signal input card_value2;
  signal input card_suit2;
  signal input salt;
  signal output card_value_hash;
  signal output card_suit_hash;
  signal output card;

  // verify card values are in proper range (1-13)
  component rp1 = Range(32, 1, 13);
  rp1.in <== card_value1;

  component rp2 = Range(32, 1, 13);
  rp2.in <== card_value2;

  // verify that card suits are in proper range (1-4)
  component rp_suit1 = Range(32, 1, 4);
  rp_suit1.in <== card_suit1;

  component rp_suit2 = Range(32, 1, 4);
  rp_suit2.in <== card_suit2;

  // hash card_value1 and card_suit1, and compare if it is 
  // equal to hash of card_value1 and card_suit2
  // if it is, they are of the same suit
  signal card1;
  component mimc1 = MiMCSponge(2, 220, 1);
  mimc1.ins[0] <== card_value1;
  mimc1.ins[1] <== card_suit1;
  mimc1.k <== salt;
  card1 <== mimc1.outs[0];

  signal card1_2;
  component mimc1_2 = MiMCSponge(2, 220, 1);
  mimc1_2.ins[0] <== card_value1;
  mimc1_2.ins[1] <== card_suit2;
  mimc1_2.k <== salt;
  card1_2 <== mimc1_2.outs[0];

  card1 === card1_2;

  // card is from the same suit, 
  // we hash card2 data and use for commitment
  component mimc_value = MiMCSponge(2, 220, 1);
  mimc_value.ins[0] <== card_value2;
  mimc_value.ins[1] <== salt;
  mimc_value.k <== 0;
  card_value_hash <== mimc_value.outs[0];

  component mimc_suit = MiMCSponge(2, 220, 1);
  mimc_suit.ins[0] <== card_suit2;
  mimc_suit.ins[1] <== salt;
  mimc_suit.k <== 0;
  card_suit_hash <== mimc_suit.outs[0];

  component mimc = MiMCSponge(2, 220, 1);
  mimc.ins[0] <== card_value_hash;
  mimc.ins[1] <== card_suit_hash;
  mimc.k <== 0;
  card <== mimc.outs[0];
}

component main = Main();