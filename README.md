This README was last updated on August 4th 2024.

This project is built on top of [circom-rsa-verify](https://github.com/zkp-application/circom-rsa-verify/tree/9b2f35842705455e3a57c44cda6cf70a3aceeb31) by @zkp-application @jacksoom .

There is a limit of 1000000ms for the tests.
A guide is in works to run the prover/verifier algorithm outside of the test environment, as a way of resolving this limitation.

Running group signature v1 with the 50 public keys circuit, to generate the r1cs, sym and wasm files takes 25min:55s on a Macbook Air M1 2020 w/ 16 RM RAM. The total space required to compute the files is 9,6GB. Details about the circuit:
    
    non-linear constraints: 26835020
    linear constraints: 0
    public inputs: 3204
    private inputs: 32
    public outputs: 1
    wires: 26558006
    labels: 29234428 

Wasm calculator with 50 Public keys took 11min:27s to generate the witness (Failed tho...).

Even though the witness generation is fast with 2 Public keys,
Computing the proof with the powers of tau reveals to be very time consuming.

Circuit compilation of 2 Public Keys has the following information:
    [INFO]  snarkJS: Curve: bn-128
    [INFO]  snarkJS: # of Wires: 1082630
    [INFO]  snarkJS: # of Constraints: 1093676
    [INFO]  snarkJS: # of Private Inputs: 32
    [INFO]  snarkJS: # of Public Inputs: 132
    [INFO]  snarkJS: # of Labels: 1196572
    [INFO]  snarkJS: # of Outputs: 1
Circuit Compilation and Witness generation is fairly quick but proof generation with Groth16 bn128 21 took ~16h


Running the group signature V2 with the 50 public keys circuit, to generate the r1cs, sym and wasm files takes 10s on a Macbook Air M1 2020 w/ 16 RM RAM. The total space required to compute the files is 222MB. Details about the circuit:

    non-linear constraints: 564032
    linear constraints: 0
    public inputs: 3204
    private inputs: 96
    public outputs: 1
    wires: 561696
    labels: 645210

