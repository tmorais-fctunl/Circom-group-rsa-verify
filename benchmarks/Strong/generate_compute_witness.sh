#!/bin/bash

# List of folder names
folders=(Strong_5 Strong_10 Strong_20)

# Base script content, but with placeholders for folder-specific values
script_content='#!/bin/bash
echo "Computing the witness. If the input fails any assertation it will fail. Valid proofs only. Might take some time..."
START="$(date -u +%s.%N)"
/usr/bin/time -v node --trace-gc --trace-gc-ignore-scavenger --max-old-space-size=2048000 --initial-old-space-size=2048000 --no-global-gc-scheduling --no-incremental-marking --max-semi-space-size=1024 --initial-heap-size=2048000 --expose-gc {folder}_js/generate_witness.js {folder}_js/{folder}.wasm input.json witness.wtns
END="$(date -u +%s.%N)"
DIFF=$(echo "$END - $START" | bc)
echo "Whole process finished in $DIFF seconds"'

# Loop through each folder and generate the script
for folder in "${folders[@]}"; do
  # Replace placeholders in the script content with the actual folder name
  folder_script="${script_content//\{folder\}/$folder}"

  # Create the script file inside the folder
  echo "$folder_script" > "$folder/computewitness.sh"

  # Make the script executable
  chmod +x "$folder/computewitness.sh"

  echo "Script created in $folder/computewitness.sh"
done
