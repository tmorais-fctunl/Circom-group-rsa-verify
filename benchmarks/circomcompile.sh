#!/bin/bash
#run like so: sh circomcompile.sh ./Efficient/Efficient_50.circom ./Efficient/Efficient_50 2>&1 | tee ./Efficient/Efficient_50/circomCompileLog.txt
#First arg is the name of the circuit, second arg is the folder in which to store the files
echo "Generating r1cs and wasm. Might take some time..."
START="$(date -u +%s.%N)"

#/usr/bin/time -v circom "$1" --r1cs --wasm -o "$2"
/usr/bin/time -v circom "$1" --O1 --r1cs --c --sym --wasm -o "$2" #for larger circuits

END="$(date -u +%s.%N)"

DIFF=$(echo "$END - $START" | bc)

echo "Whole process finished in $DIFF seconds"

COMPUTE_WIT_SH="${2}"/computewitness.sh

touch $COMPUTE_WIT_SH
echo '#!/bin/bash' > $COMPUTE_WIT_SH
CIRCUIT=$(basename "${1%.*}")
COMP_WIT_PATH="$CIRCUIT"_js


echo 'echo "Computing the witness. If the input fails any assertation it will fail. Valid proofs only. Might take some time..."' >> "$COMPUTE_WIT_SH"
echo 'START="$(date -u +%s.%N)"' >> "$COMPUTE_WIT_SH"
echo "node ./$COMP_WIT_PATH/generate_witness.js ./$COMP_WIT_PATH/$CIRCUIT.wasm input.json witness.wtns" >> "$COMPUTE_WIT_SH"
echo 'END="$(date -u +%s.%N)"' >> "$COMPUTE_WIT_SH"
echo 'DIFF="$(bc <<<"$END-$START")"' >> "$COMPUTE_WIT_SH"
echo 'echo "Whole process finished in $DIFF seconds"' >> "$COMPUTE_WIT_SH"

#Final print
echo "You can generate the witness by running the 'computewitness.sh' script inside the ${2} folder after creating your 'input.json' file inside the same folder"
