#!/bin/bash
#requires a contribution string as the first argument
#requires r1cs file as second argument
#requires a contribution string as the third argument

echo "Starting powers of tau cerimony and proof verification. Might take some time..."
START="$(date -u +%s.%N)"

#First, we start a new "powers of tau" ceremony:
snarkjs powersoftau new bn128 21 pot21_0000.ptau -v

END_0="$(date -u +%s.%N)"

DIFF_0="$(bc <<<"$END_0-$START")"

echo "1st step finished in $DIFF_0 seconds"

START_1="$(date -u +%s.%N)"

#Then, we contribute to the ceremony:
snarkjs powersoftau contribute pot21_0000.ptau pot21_0001.ptau --name=${1} -v

END_1="$(date -u +%s.%N)"

DIFF_1="$(bc <<<"$END_1-$START_1")"

echo "2nd step finished in $DIFF_1 seconds"

START_2="$(date -u +%s.%N)"

#Start the generation of phase 2:
snarkjs powersoftau prepare phase2 pot21_0001.ptau pot21_final.ptau -v

END_2="$(date -u +%s.%N)"

DIFF_2="$(bc <<<"$END_2-$START_2")"

echo "3rd step finished in $DIFF_2 seconds"

START_3="$(date -u +%s.%N)"

#Next, we generate a .zkey file that will contain the proving and verification keys together with all phase 2 contributions. 
#Execute the following command to start a new zkey:
snarkjs groth16 setup ${2} pot21_final.ptau circuit_0000.zkey

END_3="$(date -u +%s.%N)"

DIFF_3="$(bc <<<"$END_3-$START_3")"

echo "4th step finished in $DIFF_3 seconds"

START_4="$(date -u +%s.%N)"

#Contribute to the phase 2 of the ceremony:
snarkjs zkey contribute circuit_0000.zkey circuit_0001.zkey --name=${2} -v

END_4="$(date -u +%s.%N)"

DIFF_4="$(bc <<<"$END_4-$START_4")"

echo "5th step finished in $DIFF_4 seconds"

START_5="$(date -u +%s.%N)"


#Export the verification key:
snarkjs zkey export verificationkey circuit_0001.zkey verification_key.json

END_5="$(date -u +%s.%N)"

DIFF_5="$(bc <<<"$END_5-$START_5")"

echo "6th step finished in $DIFF_5 seconds"

START_6="$(date -u +%s.%N)"

#Once the witness is computed and the trusted setup is already executed, 
#we can generate a zk-proof associated to the circuit and the witness:
snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json

END_6="$(date -u +%s.%N)"

DIFF_6="$(bc <<<"$END_6-$START_6")"

echo "4th step finished in $DIFF_6 seconds"

START_7="$(date -u +%s.%N)"

#Proof verification
snarkjs groth16 verify verification_key.json public.json proof.json

END_7="$(date -u +%s.%N)"

DIFF_7="$(bc <<<"$END_7-$START_7")"

echo "7th step finished in $DIFF_7 seconds"

END="$(date -u +%s.%N)"

DIFF="$(bc <<<"$END-$START")"

echo "Whole process finished in $DIFF seconds"