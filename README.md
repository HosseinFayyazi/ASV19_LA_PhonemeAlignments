# ASVspoof 2019 LA Phoneme Alignments & Transcriptions (Allosaurus & Whisper+MFA)

[![Dataset: ASVspoof 2019 LA](https://img.shields.io/badge/Dataset-ASVspoof_2019_LA-blue.svg)](https://www.asvspoof.org/index2019.html)

This repository provides precomputed, frame-level phoneme transcriptions and alignment boundaries for the **ASVspoof 2019 Logical Access (LA)** dataset across the `train`, `dev`, and `eval` subsets using two distinct modeling paradigms:

1. **Whisper + MFA (Montreal Forced Aligner):** Lexicon-constrained canonical forced alignment. Audio transcripts generated via OpenAI Whisper are aligned against pronunciation dictionaries using MFA.
2. **Allosaurus:** Universal acoustic-to-phone recognition. Frame-level phoneme sequence inference operating in open-vocabulary acoustic IPA space without text conditioning.

This resource is designed to support acoustic anti-spoofing analysis and phonetic artifact detection in synthetic speech.

---

## 📂 Repository Structure
```text
.
├── ASVspoof2019_LA_train/
│   ├── mfa_aligned.zip/            # Praat TextGrid files (*.TextGrid)
│   ├── allosaurus.zip/             # PHN files (*.phn: <start> <duration> <phone>)
│   ├── whisper_transcripts.zip/    # Whisper transcript files (*.txt)
├── ASVspoof2019_LA_dev/
│   ├── mfa_aligned.zip/            # Praat TextGrid files (*.TextGrid)
│   ├── allosaurus.zip/             # PHN files (*.phn: <start> <duration> <phone>)
│   ├── whisper_transcripts.zip/    # Whisper transcript files (*.txt)
├── ASVspoof2019_LA_eval/
│   ├── mfa_aligned.zip/            # Praat TextGrid files (*.TextGrid)
│   ├── allosaurus.zip/             # PHN files (*.phn: <start> <duration> <phone>)
│   ├── whisper_transcripts.zip/    # Whisper transcript files (*.txt)
└── README.md
