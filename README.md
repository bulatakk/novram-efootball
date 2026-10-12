# NOVRAM for eFootball

NOVRAM removes the recurring **"GPU: VRAM 4GB"** startup warning from supported PC builds of eFootball.

> NOVRAM does **not** add VRAM, spoof your GPU, unlock graphics settings, or improve performance. It bypasses only the startup warning dialog on builds whose binary signature is explicitly supported.

## Why this exists

Some integrated GPUs can run eFootball acceptably while Windows reports a small amount of **dedicated** VRAM and a much larger pool of shared system memory. On affected systems, eFootball may still show the minimum-spec warning on every launch.

NOVRAM was created to remove that repeated startup dialog without changing gameplay or renderer settings.

## Current compatibility

Tested on:

- **eFootball 6.1.0.0 (Windows / Steam)**
- Clean `eFootball.exe` SHA-256:
  `44E3D76605C91A0E9530AB868BA6F1D3654ACB6BFAC27F45C1ECFF1B46E21180`

The first confirmed test system used an **AMD Radeon 680M iGPU** with approximately 512 MB hardware-reserved/dedicated VRAM reported by Windows.

After an eFootball update, NOVRAM should be treated as **unsupported until verified again**.

## What the patch changes

NOVRAM identifies the specific startup `TaskDialog` call-site using a byte signature plus surrounding control-flow context.

On the supported build, it replaces the 10-byte dialog call/result-load sequence with a small sequence that returns the same result as pressing **OK**, so the warning dialog is never created.

The patcher:

1. refuses to patch while eFootball is running;
2. searches for the supported signature;
3. requires **exactly one** matching call-site;
4. detects whether the game is already patched;
5. creates a backup before modifying the executable;
6. verifies the written bytes afterwards;
7. refuses to write anything if the signature does not match the supported layout.

## Important safety notes

- This tool modifies `eFootball.exe`. Use it at your own risk.
- Steam **Verify integrity of game files** or a game update may restore the original executable.
- Anti-cheat/integrity behavior can change at any time. A build working today does not guarantee compatibility with future versions.
- Do not use an old NOVRAM build after an eFootball update unless that version is explicitly listed as supported.
- Backups are created automatically by the patch script before a write.

## Download

Prebuilt Windows binaries will be published under **GitHub Releases**.

Until a release is available, the source implementation is available in [`src/`](src/).

## Source

The repository contains the original PowerShell patch implementation and the Windows launcher source used for the desktop build.

The patch is intentionally signature-based rather than hard-coded to a naked file offset, so an unexpected binary layout causes a safe failure instead of blindly writing bytes.

## Disclaimer

NOVRAM is an unofficial community utility. It is **not affiliated with, endorsed by, or supported by KONAMI**. eFootball and related trademarks belong to their respective owners.

## License

The NOVRAM source code in this repository is released under the MIT License. The license applies to NOVRAM source code only and does not grant rights to any KONAMI/eFootball assets or binaries.
