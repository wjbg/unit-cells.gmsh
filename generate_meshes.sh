#!/bin/bash

# Configuration
GEO_FILE="2D_unstructured_quarter_fiber.geo"
VF_VALUES=(0.4 0.45 0.5 0.55 0.6 0.65)
N_ELEMENTS=${1:-5} # Use first argument as 'n', default to 5

echo "Generating unstructured meshes with n=$N_ELEMENTS elements in the gap..."

# Loop through each volume fraction
for vf in "${VF_VALUES[@]}"; do
    OUTPUT_MSH="2D_unstructured_quarter_fiber_vf${vf}_n${N_ELEMENTS}.msh"
    
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

echo "Batch generation complete."
