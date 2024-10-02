#!/bin/bash

# List of folder names
folders=(Strong/Strong_5 Strong/Strong_10 Strong/Strong_20 Efficient/Efficient_500 Efficient/Efficient_5000 Efficient/Efficient_50000)

# Base script content, but with placeholders for folder-specific values
script_content='#!/bin/bash
echo "Verifying the proof. Might take some time..."
START="$(date -u +%s.%N)"
/usr/bin/time -v node $(which snarkjs) groth16 verify verification_key.json public.json proof.json 2>&1 | tee proofVerification.txt   
END="$(date -u +%s.%N)"
DIFF=$(echo "$END - $START" | bc)
echo "Whole process finished in $DIFF seconds"'

# Loop through each folder and generate the script
for folder in "${folders[@]}"; do
  # Replace placeholders in the script content with the actual folder name
  folder_script="${script_content//\{folder\}/$folder}"

  # Create the script file inside the folder
  echo "$folder_script" > "$folder/verifyproof.sh"

  # Make the script executable
  chmod +x "$folder/verifyproof.sh"

  echo "Script created in $folder/verifyproof.sh"
done




