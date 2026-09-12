#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Activate the MFA Conda environment
# ------------------------------------------------------------
source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate mfa

# Retain the Conda C++ runtime preference used in your setup.
export LD_LIBRARY_PATH="$CONDA_PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# ------------------------------------------------------------
# Input folders (WSL versions of your F:\ paths)
# ------------------------------------------------------------
FLAC_DIR="/mnt/f/ASVspoof2019/LA/ASVspoof2019_LA_eval/flac"
TRANSCRIPT_DIR="/mnt/f/ASVspoof2019/LA/ASVspoof2019_LA_eval/whisper_transcripts"

# MFA corpus: matching audio + transcript files will be linked here.
MFA_CORPUS="/mnt/f/ASVspoof2019/LA/ASVspoof2019_LA_eval/mfa_corpus"

# MFA TextGrid output folder
MFA_OUTPUT="/mnt/f/ASVspoof2019/LA/ASVspoof2019_LA_eval/mfa_aligned"

# Use installed MFA model names.
DICTIONARY_MODEL="english_us_mfa"
ACOUSTIC_MODEL="english_mfa"

# ------------------------------------------------------------
# Validate input paths
# ------------------------------------------------------------
[[ -d "$FLAC_DIR" ]] || {
    echo "[ERROR] FLAC directory not found: $FLAC_DIR"
    exit 1
}

[[ -d "$TRANSCRIPT_DIR" ]] || {
    echo "[ERROR] Transcript directory not found: $TRANSCRIPT_DIR"
    exit 1
}

mkdir -p "$MFA_CORPUS"
mkdir -p "$MFA_OUTPUT"

# ------------------------------------------------------------
# Create MFA corpus links
# ------------------------------------------------------------
echo "[INFO] Creating MFA corpus links..."

num_audio=0
num_linked=0
num_missing_txt=0
num_empty_txt=0

while IFS= read -r -d '' audio_file; do
    num_audio=$((num_audio + 1))

    filename="$(basename "$audio_file")"
    utt_id="${filename%.*}"
    transcript_file="$TRANSCRIPT_DIR/${utt_id}.txt"

    # MFA must have a matching transcript for every audio file.
    if [[ ! -f "$transcript_file" ]]; then
        echo "[WARNING] Missing transcript: $transcript_file"
        num_missing_txt=$((num_missing_txt + 1))
        continue
    fi

    # Skip blank Whisper outputs.
    if [[ ! -s "$transcript_file" ]]; then
        echo "[WARNING] Empty transcript: $transcript_file"
        num_empty_txt=$((num_empty_txt + 1))
        continue
    fi

    # -s = symbolic link
    # -f = replace old link/file if it already exists
    ln -sfn "$audio_file" "$MFA_CORPUS/${utt_id}.flac"
    ln -sfn "$transcript_file" "$MFA_CORPUS/${utt_id}.txt"

    num_linked=$((num_linked + 1))
done < <(find "$FLAC_DIR" -maxdepth 1 -type f -iname "*.flac" -print0)

echo
echo "[INFO] Audio files found:         $num_audio"
echo "[INFO] Valid MFA pairs created:   $num_linked"
echo "[INFO] Missing transcripts:        $num_missing_txt"
echo "[INFO] Empty transcripts:          $num_empty_txt"
echo

if [[ "$num_linked" -eq 0 ]]; then
    echo "[ERROR] No valid audio/transcript pairs were created."
    exit 1
fi

if [[ "$num_missing_txt" -gt 0 ]] || [[ "$num_empty_txt" -gt 0 ]]; then
    echo "[WARNING] Skipped $num_empty_txt empty transcripts and $num_missing_txt missing files."
    echo "[INFO] Proceeding to align the remaining $num_linked valid pairs..."
fi

# ------------------------------------------------------------
# Run MFA forced alignment
# ------------------------------------------------------------
echo "[INFO] Starting MFA alignment..."

mfa align \
    "$MFA_CORPUS" \
    "$DICTIONARY_MODEL" \
    "$ACOUSTIC_MODEL" \
    "$MFA_OUTPUT" \
    --clean \
    --single_speaker

echo
echo "[DONE] MFA alignment completed."
echo "[DONE] TextGrids saved in:"
echo "       $MFA_OUTPUT"
