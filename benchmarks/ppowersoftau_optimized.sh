#!/bin/bash
#requires r1cs file as 1st argument
#requires a pptau file as 2nd argument
#requires output folder as 3rd argument
#ex: sh ppowersoftau.sh x.r1cs ptau.ptau ~/thesis-tests/.../benchmarks/.../

echo "Starting powers of tau phase 2. Might take some time..."

echo "First step is to create a key with the ptau and r1cs file"
START="$(date -u +%s.%N)"

#Next, we generate a .zkey file that will contain the proving and verification keys together with all phase 2 contributions. 
#Execute the following command to start a new zkey:
#/usr/bin/time -v  snarkjs groth16 setup ${1} ${2} ${3}/circuit_0000.zkey
#/usr/bin/time -v node --max-old-space-size=32768 $(which snarkjs) groth16 setup ${1} ${2} ${3}/circuit_0000.zkey
/usr/bin/time -v node --trace-gc --trace-gc-ignore-scavenger --max-old-space-size=2048000 --initial-old-space-size=2048000 --no-global-gc-scheduling --no-incremental-marking --max-semi-space-size=1024 --initial-heap-size=2048000 --expose-gc $(which snarkjs) groth16 setup ${1} ${2} ${3}/circuit_0000.zkey 
END_1="$(date -u +%s.%N)"
DIFF_1=$(echo "$END_1 - $START" | bc)
echo "1st step finished in $DIFF_1 seconds"

START_2="$(date -u +%s.%N)"
echo "Second step is to contribute to the phase 2 with some random input"
#Contribute to the phase 2 of the ceremony:
/usr/bin/time -v node --trace-gc --trace-gc-ignore-scavenger --max-old-space-size=2048000 --initial-old-space-size=2048000 --no-global-gc-scheduling --no-incremental-marking --max-semi-space-size=1024 --initial-heap-size=2048000 --expose-gc $(which snarkjs) zkey contribute ${3}/circuit_0000.zkey ${3}/circuit_0001.zkey --name="TAMD2024" -v -e="ATDM2024"
END_2="$(date -u +%s.%N)"
DIFF_2=$(echo "$END_2 - $START_2" | bc)
echo "2nd step finished in $DIFF_2 seconds"

echo "Third step is to export the verification key"
START_3="$(date -u +%s.%N)"
#Export the verification key:
/usr/bin/time -v node --trace-gc --trace-gc-ignore-scavenger --max-old-space-size=2048000 --initial-old-space-size=2048000 --no-global-gc-scheduling --no-incremental-marking --max-semi-space-size=1024 --initial-heap-size=2048000 --expose-gc $(which snarkjs) zkey export verificationkey ${3}/circuit_0001.zkey ${3}/verification_key.json
END_3="$(date -u +%s.%N)"
DIFF_3=$(echo "$END_3 - $START_3" | bc)
echo "3rd step finished in $DIFF_3 seconds"

END="$(date -u +%s.%N)"
DIFF=$(echo "$END - $START" | bc)
echo "Whole process finished in $DIFF seconds"