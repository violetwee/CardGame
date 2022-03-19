# Fairness in Card Games

This is a submission for zku.ONE Assignment 3.

## Question 2.2:

Card commitment - In DarkForest, players commit to a location by submitting a location hash. It is hard to brute force a location hash since there can be so many possible coordinates.
In a card game, how can a player commit to a card without revealing what the card is? A naive protocol would be to map all cards to a number between 0 and 51 and then hash this number to get a commitment. This won’t actually work as one could easily brute force the 52 hashes.

To prevent players from changing the card we need to store some commitment on-chain. How would you design this commitment? Assume each player has a single card that needs to be kept secret. Modify the naive protocol so that brute force doesn’t work.

Now assume that the player needs to pick another card from the same suite. Design a circuit that can prove that the newly picked card is in the same suite as the previous one. Can the previous state be spoofed? If so, what mechanism is needed in the contracts to verify this?
Design a contract, necessary circuits, and verifiers to achieve this. You may need to come up with an appropriate representation of cards as integers such that the above operations can be done easily.

## Organization

In circuits directory, `init` circuit verifies that the card is valid (ie. card_value is between 1-13, and card_suit is between 1-4). `draw` verifies that the card is valid and is also the same suit as the previous card. `lib` contains useful circom libraries that are used in this project, and a custom built Range circuit.

In eth/contracts directory, Verifier.sol is a compilation of `init` and `draw` verifiers. CardGame.sol simulates verification of inputs through zero-knowledge proofs.

## Testing

### Compile and test the `init` circuit.

From the init directory, run:
`./compile.sh -f init -j input.json`.
Then run `snarkjs generatecall` to obtain test inputs for the verifier.

### Compile and test the `draw` circuit

From the draw directory, run:
`./compile.sh -f draw -j input.json`.
Then run `snarkjs generatecall` to obtain test inputs for the verifier.

To test that invalid inputs should fail the circuit, replace the input.json parameter with input_diff_suit.json, input_invalid_suit.json or input_invalid_card.json.

### Compile and test the smart contracts

1. Copy and paste the code from Verifier.sol to Remix. Compile and deploy the Verifier.
2. Copy and paste the code from CardGame.sol to Remix. Compile and deploy the CardGame contract using the Verifier's contract address from Step 1.
3. Copy and paste the test inputs from `init` circuit's `snarkjs generatecall` to the `initializePlayer` field and click on `initializePlayer`.
4. Click `getPlayerCards`. There should be one card hash.
5. Copy and paste the test inputs from `draw` circuit's `snarkjs generatecall` to the `drawCard` field and click on `drawCard`.
6. Click `getPlayerCards`. There should now be two card hashes.

## Libraries

The circom circuit uses the following circuits from the circomlib repo (https://github.com/iden3/circomlib):

- aliascheck
- binsum
- bitify
- comparators
- compconstant
- mimcsponge

Custom circom library:

- range

## Resources

- [Circom](https://docs.circom.io/getting-started/writing-circuits/)
- [CircomLib](https://github.com/iden3/circomlib)
- [DarkForest](https://github.com/darkforest-eth/darkforest-v0.3)
- [Remix](https://remix.ethereum.org/)
