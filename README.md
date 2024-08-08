This README was last updated on August 4th 2024.

This project is built on top of [circom-rsa-verify](https://github.com/zkp-application/circom-rsa-verify/tree/9b2f35842705455e3a57c44cda6cf70a3aceeb31) by @zkp-application @jacksoom .

There is a limit of 1000000ms for the tests.
A guide is in works to run the prover/verifier algorithm outside of the test environment, as a way of resolving this limitation.

Running circom with the 50 public keys circuit, to generate the r1cs, sym and wasm files takes 25min:55s on a Macbook Air M1 2020 w/ 16 RM RAM. The total space required to compute the files is 9,6GB. Details about the circuit:
    
    non-linear constraints: 26835020
    linear constraints: 0
    public inputs: 3204
    private inputs: 32
    public outputs: 1
    wires: 26558006
    labels: 29234428 

Wasm calculator with 50 Public keys took 11min:27s to generate the witness (Failed tho...).
