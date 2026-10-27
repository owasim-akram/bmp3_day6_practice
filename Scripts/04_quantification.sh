#!/bin/bash
set -euo pipefail

# Always run from the project root, no matter where the script is called from
cd "$(dirname "$0")/.."

salmon_index="./inputs/human_salmon_index"
fastq_dir="./fastq"
output_dir="./outputs/salmon_out"

command -v salmon >/dev/null || { echo "ERROR: salmon not found (run inside 'pixi shell')"; exit 1; }
[[ -d "$salmon_index" ]] || { echo "ERROR: Salmon index not found: $salmon_index"; exit 1; }

mkdir -p "$output_dir"

shopt -s nullglob
r1_files=("$fastq_dir"/SRR*_1.fastq.gz)
[[ ${#r1_files[@]} -gt 0 ]] || { echo "ERROR: No R1 files in $fastq_dir"; exit 1; }

for r1_file in "${r1_files[@]}"; do
    samp=$(basename "$r1_file" _1.fastq.gz)
    r2_file="${fastq_dir}/${samp}_2.fastq.gz"
    [[ -f "$r2_file" ]] || { echo "ERROR: R2 file not found: $r2_file"; exit 1; }

    echo "Processing sample: $samp"
    salmon quant \
        -i "$salmon_index" \
        -l A \
        -1 "$r1_file" \
        -2 "$r2_file" \
        -p 8 \
        -o "${output_dir}/${samp}"
    echo "Completed sample: $samp"
done

echo "Quantification completed successfully!"