This README was last updated on October 2nd 2024.

This project is built on top of [circom-rsa-verify](https://github.com/zkp-application/circom-rsa-verify/tree/9b2f35842705455e3a57c44cda6cf70a3aceeb31) by @zkp-application @jacksoom .
It was developed as part of a research dissertation at NOVA SST/FCT.

# How to use this program:
Pre Requisites: You need to have Circom and snarkJS installed in your machine. There is an helpful guide on [Circom's Website](https://docs.circom.io/getting-started/installation/) to achieve this

Head over to the benchmarks folder where you can find scripts used to compile the circuits, generate the witnesses, generate the proving/generation keys and to generate/verify the proofs.

## Circuit Compilation
Use the circomcompile.sh script to compile a chosen circuit and choose its destination folder. This will output a "_js" folder and the .R1CS file needed to generate the keys.
```sh circomcompile.sh {circuit.circom} {destination} 2>&1 | tee {destination}/circomCompileLog.txt```

## Witness Generation
Inside the destination folder use the computewitness.sh script
```sh computewitness.sh 2>&1 | tee computeWitnessLog.txt```

## Generate the proving/generation keys
Return to the benchmarks folder and use the ppowersoftau_optimized.sh or ppowersoftau.sh script. You also need to provide the destination folder the circuit was compiled to andthe .R1CS file inside it.
You also need to provide an appropriate .ptau file that can withstand the number of constraints the circuit has. You can find several pptau files at the [Perpetual Powers of Tau](https://github.com/privacy-scaling-explorations/perpetualpowersoftau?tab=readme-ov-file) repository.
``` sh ppowersoftau_optimized.sh {destination}/{file.r1cs} {file.ptau} {destination} 2>&1 | tee {destination}/ptauphase2.txt```

## Generate the witness
Return to the destination folder where you will find an additonal "_js" folder. Once inside it, you will need to provide the input.json with the signals. This will output the witness .WTNS file
```sh computewitness.sh 2>&1 | tee computeWitnessLog.txt```

## Generate the proof
Inside the benchmarks folder you will find the generate_generate_proof.sh script which creates an executable script called generateproof.sh inside the destination folders listed in the script (You can and should edit this to include your destination folder).
Onde this script is present in your desired destination folder, return to that destination and execute it.
```sh generateproof.sh```

## Verify the proof
Inside the benchmarks folder you will find the generate_verify_proof.sh script which creates an executable script called verifyproof.sh inside the destination folders listed in the script (You can and should edit this to include your destination folder).
Onde this script is present in your desired destination folder, return to that destination and execute it.
```sh verifyproof.sh```
