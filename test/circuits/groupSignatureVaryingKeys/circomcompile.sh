#!/bin/bash
#First arg is the name of the circuit, second arg is the folder in which to store the files
echo "Generating r1cs, wasm sym and c files. Might take some time..."
START="$(date -u +%s.%N)"

circom "$1" --r1cs --wasm --sym --c -o "$2"

END="$(date -u +%s.%N)"

DIFF="$(bc <<<"$END-$START")"

echo "Whole process finished in $DIFF seconds"

COMPUTE_WIT_SH=./"${2}"/computewitness.sh

touch $COMPUTE_WIT_SH
echo '#!/bin/bash' > $COMPUTE_WIT_SH
CIRCUIT=${1%.*}
COMP_WIT_PATH="$CIRCUIT"_js


echo 'echo "Computing the witness. If the input fails any assertation it will fail. Valid proofs only. Might take some time..."' >> "$COMPUTE_WIT_SH"
echo 'START="$(date -u +%s.%N)"' >> "$COMPUTE_WIT_SH"
echo "node ./$COMP_WIT_PATH/generate_witness.js ./$COMP_WIT_PATH/$CIRCUIT.wasm input.json witness.wtns" >> "$COMPUTE_WIT_SH"
echo 'END="$(date -u +%s.%N)"' >> "$COMPUTE_WIT_SH"
echo 'DIFF="$(bc <<<"$END-$START")"' >> "$COMPUTE_WIT_SH"
echo 'echo "Whole process finished in $DIFF seconds"' >> "$COMPUTE_WIT_SH"

#Final print
echo "You can generate the witness by running the 'computewitness.sh' script inside the ${2} folder after creating your 'input.json' file inside the same folder"
