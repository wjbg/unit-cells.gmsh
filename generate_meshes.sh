#!/bin/bash

# Configuration
GEO_FILES=("2D_unstructured_quarter_fiber.geo" "2D_unstructured_hexagonal_packing.geo" "2D_unstructured_half_fiber.geo" "2D_unstructured_two_quarter_fiber.geo")
VF_VALUES=(0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65)
N_ELEMENTS=${1:-5} # Use first argument as 'n', default to 5
OUTPUT_DIR="meshes"

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

for GEO_FILE in "${GEO_FILES[@]}"; do
    BASE_NAME=$(basename "$GEO_FILE" .geo)
    echo "Generating meshes for $GEO_FILE with n=$N_ELEMENTS elements in the gap..."

    # Loop through each volume fraction
    for vf in "${VF_VALUES[@]}"; do
        OUTPUT_MSH="${OUTPUT_DIR}/${BASE_NAME}_vf${vf}_n${N_ELEMENTS}.msh"

        echo "Processing vf=$vf -> $OUTPUT_MSH"

        # Run Gmsh
        gmsh -2 "$GEO_FILE" \
             -setnumber vf "$vf" \
             -setnumber n "$N_ELEMENTS" \
             -o "$OUTPUT_MSH" \
             -v 0 # Silent mode (level 0)

        if [ $? -eq 0 ]; then
            echo "  [SUCCESS]"
        else
            echo "  [FAILED]"
        fi
    done
done

echo "Batch generation complete."
