# NOVRAM v1.0.0

First public NOVRAM release.

## What it does
- Removes the recurring **GPU: VRAM 4GB** startup warning on the supported eFootball build.
- Does **not** add VRAM, spoof the GPU, modify gameplay, or improve performance.
- Creates a backup before modifying `eFootball.exe`.
- Refuses to patch if the expected signature is not found exactly once.

## Tested compatibility
- eFootball **6.1.0.0** (Steam / Windows)
- Clean `eFootball.exe` SHA-256: `44E3D76605C91A0E9530AB868BA6F1D3654ACB6BFAC27F45C1ECFF1B46E21180`
- First confirmed system: AMD Radeon 680M iGPU (~512 MB dedicated VRAM reported by Windows)

## Download integrity
`NOVRAM-v1.0.0-win64.zip`

SHA-256: `27D6277E2F14C1482CA7E801D94CF7ABA63120A20A763F4961EAE236097B3FFA`

After an eFootball update, treat this build as unsupported until compatibility is re-verified.
