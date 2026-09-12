#!/usr/bin/env bash
set -euo pipefail

export LD_LIBRARY_PATH="$CONDA_PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Optional: choose GPU 0 explicitly.
export CUDA_VISIBLE_DEVICES=0

INPUT_DIR="/mnt/f/ASVspoof2019/LA/ASVspoof2019_LA_eval/flac"
OUTPUT_DIR="/mnt/f/ASVspoof2019/LA/ASVspoof2019_LA_eval/whisper_transcripts"

mkdir -p "$OUTPUT_DIR"

find "$INPUT_DIR" -maxdepth 1 -type f -iname "*.flac" -print0 | \
while IFS= read -r -d '' audio; do
    basename_file="$(basename "$audio")"
    utt_id="${basename_file%.*}"
    transcript="$OUTPUT_DIR/${utt_id}.txt"

    # Skip files that have already been transcribed.
    if [[ -f "$transcript" ]]; then
        echo "[SKIP] Transcript already exists: $transcript"
        continue
    fi

    echo "=================================================="
    echo "[WHISPER-GPU] Transcribing: $basename_file"
    echo "=================================================="

    whisper "$audio" \
      --model base.en \
      --language en \
      --task transcribe \
      --output_format txt \
      --output_dir "$OUTPUT_DIR" \
      --device cuda \
      --fp16 True
done

echo "Finished. Transcripts are in: $OUTPUT_DIR"
