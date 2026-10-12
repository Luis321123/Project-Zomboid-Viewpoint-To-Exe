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

## Step-by-step (for non-programmers)

> Everything you need to do, in order, with copy-paste commands.

### Before you start
1. **A copy of Project Zomboid Build 42.21** — your game folder, the one with
   `projectzomboid.jar` and `ProjectZomboid64.exe`.
2. **The two mods** (ZombieBuddy + Viewpoint):
   - **With Steam (recommended):** subscribe on the Workshop to
     [ZombieBuddy (`3619862853`)](https://steamcommunity.com/sharedfiles/filedetails/?id=3619862853)
     and [Viewpoint (`3809306528`)](https://steamcommunity.com/sharedfiles/filedetails/?id=3809306528).
     They download automatically and the scripts find them.
   - **Without Steam:** put the mods in a `mods` folder:
     Linux → `mods/` next to the script (`<unzip-location>/scripts/mods/`) ·
     Windows → `mods/` inside the game folder (`<game>\mods\`).

### 🟦 Linux (Wine)
```bash
# 1) Unzip the repo (the GitHub .zip) into your home folder.

# 2) Install mods + agent (replace YOUR-GAME-FOLDER):
bash ~/PZ-Viewpoint/scripts/aplicar_viewpoint_zb.sh "YOUR-GAME-FOLDER"

# 3) Copy the launcher into the game folder and go there:
cp ~/PZ-Viewpoint/launcher/arrancar_pz.sh "YOUR-GAME-FOLDER/"
cd "YOUR-GAME-FOLDER"

# 4) Play!
bash arrancar_pz.sh            # normal · -c: console · -d: OpenGL debug
```

### 🟩 Windows
1. Unzip the repo.
2. Copy the `windows/` folder **inside the game folder** →
   `<game>\windows\INSTALAR_VIEWPOINT_WINDOWS.bat`.
3. Make sure you have the mods (see "Before you start").
4. **Double-click** `INSTALAR_VIEWPOINT_WINDOWS.bat` (copies mods + patches the
   launcher automatically).
5. Launch `ProjectZomboid64.exe` (or `<game>\windows\Arrancar_PZ.bat`).

### 🎮 In game (both systems)
1. Menu **Mods** → enable **ZombieBuddy**.
2. Menu **Mods** → enable **Viewpoint** (right after).
3. Approve the **JAR** dialogs (SHA-256) → **Yes**.
4. Start or load a game. Press **`O`** → first-person camera.

### ❓ Common problems
| Symptom | Fix |
|---|---|
| *"Mod not found..."* | Put the mods in `mods/` or subscribe on Steam. |
| Game won't start / crashes | Your copy must be **Build 42.21** (Viewpoint needs it). |
| Camera stutters / low FPS | Use Viewpoint's **"Vanilla"** preset (press `Delete`). |
| Out of memory | Raise RAM: in `projectzomboid64.bat` use `-Xmx4096m` (or more). |

> There is also a script to **update** an older copy to 42.21
> (`scripts/actualizar_b4221.sh`) and the **full technical docs** in `docs/`.

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