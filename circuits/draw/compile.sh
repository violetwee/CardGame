echo "-- Compiling Circom Circuit --"
# Process args for circom file and input.json file
# This allows script to be reused for other circom programs
while getopts f:j: flag
do 
  case "${flag}" in
        f) filename=${OPTARG};; # circom filename, exclude extension. ie. merkle_circuit
        j) json=${OPTARG};; # json input file ie. input.json
    esac
done

# Compile circom circuit and generate files needed for witness generation later
circom ${filename}.circom --r1cs --wasm --sym --c
# Copy input.json to js folder to be used for witness generation
cp $json ${filename}_js
cd ${filename}_js
# Geneate witness file
node generate_witness.js ${filename}.wasm $json witness.wtns
# Copy witness file to parent directory
cp witness.wtns ../witness.wtns

# SnarkJS - Generate a trusted setup for Groth16 
cd ..
# Phase 1 - Power of Tau
# Start new "powers of tau" ceremony
snarkjs powersoftau new bn128 14 pot12_0000.ptau -v
# Contribute to the ceremony
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# Phase 2 (Circuit Specific)
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
# Generate a zkey file that will contain the proving and verification keys together with all phase 2 contributions
snarkjs groth16 setup ${filename}.r1cs pot12_final.ptau ${filename}_0000.zkey
# Contribute to phase 2 of the ceremony
snarkjs zkey contribute ${filename}_0000.zkey ${filename}_0001.zkey --name="1st Contributor Name" -v
# Export the verification key
snarkjs zkey export verificationkey ${filename}_0001.zkey verification_key.json

# Generate a zk-proof (Groth16) associated to the circuit and the witness
# Outputs proof.json: contains the proof
# Outputs public.json: contains the values of the public inputs and outputs
snarkjs groth16 prove ${filename}_0001.zkey witness.wtns proof.json public.json

# Verify proof
snarkjs groth16 verify verification_key.json public.json proof.json

# Generate solidity verifier 
snarkjs zkey export solidityverifier ${filename}_0001.zkey verifier.sol