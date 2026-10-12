# ZombieBuddy + Project Viewpoint (3D) for Project Zomboid 42.21

Installer and documentation for running the **first-person 3D camera mod
Project Viewpoint** and its dependency **ZombieBuddy** on **Project Zomboid
Build 42.21**, on both **native Windows** and **Linux/Wine**.

> This repo contains **only scripts and documentation**. It does **not**
> include any game files, cracks or mods. See [NOTICE](NOTICE).
> You need a legitimate copy of Project Zomboid.

## TL;DR
- 🎥 **Viewpoint 0.1.6** (Workshop `3809306528`) — 3D / first-person camera.
- 🧩 **ZombieBuddy 2.3.4** (Workshop `3619862853`) — Java instrumentation framework.
- ⚙️ Agent loaded via `-agentlib:zbNative` in `ProjectZomboid64.json` and the `.bat` files.
- ✅ **Idempotent** installers for Linux (`aplicar_viewpoint_zb.sh`) and Windows
  (`INSTALAR_VIEWPOINT_WINDOWS.bat`).
- 📦 No system Java required (the game bundles its own `jre64`).
- 🖥️ Linux desktop launcher + portable setup for Windows.

## Requirements
- Project Zomboid **Build 42.21** (Viewpoint ≥ 0.1.6 requires `versionMin=42.21`).
- Dedicated GPU recommended; on iGPU use the **"Vanilla"** preset.
- RAM: `-Xmx3072m` by default; **4096m+** if you use the 3D *model pack*.

## Install

**Linux / Wine**
```bash
./scripts/aplicar_viewpoint_zb.sh "/path/to/ProjectZomboid" 42.21
arrancar_pz
```

**Windows**
1. Copy the game folder (portable) to e.g. `C:\Games\ProjectZomboid`.
2. Run `windows\INSTALAR_VIEWPOINT_WINDOWS.bat`.
3. Launch `ProjectZomboid64.exe`.

Then, **in game**: Mods → enable **ZombieBuddy**, then **Viewpoint** → approve
the JAR dialogs.

## Controls (Viewpoint)
`O` first person · `Shift+O` toggle 1st/3rd · `Insert+O` free cam · `Delete` settings.

## Compatibility
| Area | Windows | Linux (Wine) |
|---|---|---|
| Game 42.21 | ✅ | ✅ |
| ZombieBuddy agent | ✅ | ✅ |
| Viewpoint | ✅ | ✅ (enable mod + approve JAR *in-game*) |
| `.sh` scripts / `.desktop` | ❌ | ✅ |
| `.ps1` / `.bat` installer | ✅ | ❌ |

Verified on **Wine 10.0 (CachyOS)** and **Intel UHD (CML GT2)**; log shows
`version=42.21.0 4a0e9546ec` + `[ZB] activating ZombieBuddy v2.3.4`.

## Directory layout
```
scripts/   aplicate/viewpoint & update utils (bash, idempotent)
windows/   native Windows installer (.ps1/.bat) + launcher
launcher/  Linux launcher script, .desktop + icons
docs/      full setup documentation (EN/ES)
LICENSE    MIT (original scripts & docs)
NOTICE     third-party components (game, mods) keep their licenses
```

## License
- **MIT** for the scripts and docs in this repo — see [LICENSE](LICENSE).
- Third-party components (game (c) The Indie Stone; ZombieBuddy (c) Zed, GPL-3.0;
  Viewpoint (c) its authors) keep their own licenses — see [NOTICE](NOTICE).