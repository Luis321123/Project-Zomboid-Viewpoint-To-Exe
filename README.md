# Integración de **ZombieBuddy + Project Viewpoint (3D)** en Project Zomboid

> Documentación de la instalación, automatización y compatibilidad multiplataforma
> (Windows nativo y Linux/Wine) del mod de cámara en primera persona **Project Viewpoint**
> y de su dependencia **ZombieBuddy**, sobre **Project Zomboid Build 42.21**.

---

## Índice

1. [Resumen](#1-resumen)
2. [Estado final / matriz de versiones](#2-estado-final--matriz-de-versiones)
3. [Qué se descargó](#3-qué-se-descargó)
4. [Qué se creó](#4-qué-se-creó)
5. [Qué se adaptó / parcheó](#5-qué-se-adaptó--parcheó)
6. [Cómo funciona](#6-cómo-funciona)
7. [Instalación — Linux / Wine](#7-instalación--linux--wine)
8. [Instalación — Windows](#8-instalación--windows)
9. [Compatibilidad](#9-compatibilidad)
10. [Verificación realizada](#10-verificación-realizada)
11. [Riesgos y notas](#11-riesgos-y-notas)
12. [Reversión](#12-reversión)
13. [Reproducción desde cero](#13-reproducción-desde-cero)
14. [Árbol de archivos](#14-árbol-de-archivos)
15. [Aviso legal](#15-aviso-legal)

> 🚀 **¿No sabes programar?** Ve directo a la
> **[Guía paso a paso](#0-guía-paso-a-paso-para-no-programadores)**.

---

## 0. Guía paso a paso (para no programadores)

> Aquí tienes **todo lo que tienes que hacer, en orden**, con comandos listos para
> copiar y pegar. No necesitas saber programar.

### ✅ Qué necesitas antes de empezar
1. **Una copia de Project Zomboid Build 42.21** — tu carpeta del juego, la que
   contiene `projectzomboid.jar` y `ProjectZomboid64.exe`.
2. **Los mods ZombieBuddy y Viewpoint**:
   - **Con Steam (recomendado):** suscríbete en el Workshop a
     [`ZombieBuddy` (ID `3619862853`)](https://steamcommunity.com/sharedfiles/filedetails/?id=3619862853)
     y [`Viewpoint` (ID `3809306528`)](https://steamcommunity.com/sharedfiles/filedetails/?id=3809306528).
     Se descargan solos y los scripts los encuentran automáticamente.
   - **Sin Steam:** pon las carpetas de los mods en un carpeta llamada `mods`:
     - Linux → `mods/` junto al script: `<dónde-descomprimiste-esto>/scripts/mods/`
     - Windows → `mods/` **dentro de la carpeta del juego**: `<juego>\mods\`

### 🔵 En Linux (con Wine)
```bash
# 1) Descomprime el repo (el .zip descargado de GitHub) en tu carpeta personal.

# 2) Instala mods + agente (cambia TU-CARPETA por la ruta real de tu juego):
bash ~/PZ-Viewpoint/scripts/aplicar_viewpoint_zb.sh "TU-CARPETA-DEL-JUEGO"

# 3) Copia el lanzador a la carpeta del juego y ve allí:
cp ~/PZ-Viewpoint/launcher/arrancar_pz.sh "TU-CARPETA-DEL-JUEGO/"
cd "TU-CARPETA-DEL-JUEGO"

# 4) ¡A jugar!
bash arrancar_pz.sh            # normal · -c: con consola · -d: debug OpenGL
```

### 🟢 En Windows
1. Descomprime el repo.
2. Copia la carpeta `windows/` **dentro de la carpeta del juego** →
   `<juego>\windows\INSTALAR_VIEWPOINT_WINDOWS.bat`.
3. Comprueba los mods (ver requisitos: en `<juego>\mods\` o suscritos en Steam).
4. Haz **doble clic** en `INSTALAR_VIEWPOINT_WINDOWS.bat` (copiará mods y
   parcheará el lanzador automáticamente).
5. Arranca `ProjectZomboid64.exe` (o `<juego>\windows\Arrancar_PZ.bat`).

### 🕹️ En el juego (ambos sistemas)
1. Menú **Mods** → activa **ZombieBuddy**.
2. Menú **Mods** → activa **Viewpoint** (justo después).
3. Acepta el diálogo de aprobación de los **JAR** (normal: usar hash SHA-256) → **Sí**.
4. Crea o carga una partida. Pulsa **`O`** → cámara en primera persona.

### ❓ Problemas comunes
| Síntoma | Solución |
|---|---|
| *"No encuentro el mod..."* | Pon los mods en `mods/` (ver requisitos) o suscríbete en Steam. |
| El juego no arranca / se cierra | Tu copia debe ser **Build 42.21** (Viewpoint no funciona en 42.20). |
| Cámara inestable o baja FPS | Usa el preset **"Vanilla"** de Viewpoint (tecla `Delete`). |
| Se acaba la memoria | Sube la RAM: en `projectzomboid64.bat` usa `-Xmx4096m` (o más). |

> Además tienes un script de **actualización** a 42.21 (`scripts/actualizar_b4221.sh`)
> y la **documentación técnica completa** en `docs/`.

---

## 1. Resumen

**Objetivo:** dejar funcionando el mod **Project Viewpoint** (render 3D en primera persona
para la Build 42) y su dependencia **ZombieBuddy** (framework de *bytecode manipulation*
en runtime), tanto en **Windows nativo** como en **Linux mediante Wine**.

**Problema inicial:** Viewpoint `0.1.6` declara `versionMin=42.21`, pero la copia disponible
era `42.20.4`. Se podía forzar el arranque, pero con riesgo de *crash* del motor (Viewpoint
parchea clases del renderizador). La solución correcta es **actualizar a 42.21** y volver a
`versionMin=42.21`, que es lo que se acabó haciendo.

**Solución entregada:**

- Instalación manual y automatizada de los mods (Workshop → local) en **todas** las
  ubicaciones que Project Zomboid consulta.
- Agente Java **ZombieBuddy** cargado al arrancar (`-agentlib:zbNative`) en JSON y `.bat`.
- Actualización a **Build 42.21** conservando el *crack* y los datos de usuario.
- **Lanzadores** para Linux (script + `.desktop`) y **paquetes** para Windows (`.zip`).
- **Utilidades idempotentes** de instalación, actualización y reversión.

---

## 2. Estado final / matriz de versiones

| Componente | Versión / Build | Notas |
|---|---|---|
| Project Zomboid (destino) | **42.21.0** (`build 25485521`, rev. `4a0e9546ec`) | Rama `public` = `unstable` |
| Project Zomboid (origen) | 42.20.4 (repack `0xdeadcode`) | Crack **OnlineFix** (`RealAppId=108600`, `FakeAppId=480`) |
| Repack 42.21 | 42.21.0 (IGG-GAMES) | Crack **Goldberg** (`steam_settings/`) |
| ZombieBuddy | **2.3.4** (Workshop `3619862853`) | Mod ID `ZombieBuddy` |
| Project Viewpoint | **0.1.6** (Workshop `3809306528`) | Mod ID `Viewpoint` |
| Java Runtime | **Zulu 25.0.1** (`jre64` incluido en el juego) | No requiere Java del sistema |
| Wine | 10.0 (CachyOS / Arch) | Prueba de compatibilidad Linux |

**Rutas de datos de usuario**

| | Windows | Linux (Wine) |
|---|---|---|
| Perfil | `%USERPROFILE%\Zomboid` | `~/.wine/drive_c/users/<usuario>/Zomboid` |
| Mods | `<juego>\mods` y `%USERPROFILE%\Zomboid\mods` | `<juego>/mods` y `.../Zomboid/mods` |
| Log del juego | `%USERPROFILE%\Zomboid\console.txt` | `.../Zomboid/console.txt` |

---

## 3. Qué se descargó

| Recurso | Origen | Destino | Método |
|---|---|---|---|
| `steamcmd` | Valve (tarball oficial) | `~/steamcmd` | Descarga directa |
| ZombieBuddy | Steam Workshop `3619862853` | `~/.local/share/Steam/steamapps/workshop/content/108600/3619862853/` | `steamcmd +login anonymous +workshop_download_item 108600 3619862853` |
| Project Viewpoint | Steam Workshop `3809306528` | `.../workshop/content/108600/3809306528/` | `steamcmd +login anonymous +workshop_download_item 108600 3809306528` |
| Repack 42.21 | Fuente del usuario | `~/Descargas/Project.Zomboid.v42.21.rar` → `.../Project.Zomboid.v42.21/ProjectZomboid` | Manual |

> Los mods del Workshop son contenido **gratuito** y se pueden obtener de forma anónima.
> El juego base **no** (ver §10: `app_update` anónimo baja 0 bytes).

**Mod opcional (no instalado):** *3D model pack* — Workshop `3810302175`
(requiere Build 42.21 y ≥ 4 GB de RAM; subir `-Xmx` a `4096m` o más).

---

## 4. Qué se creó

### 4.1 Kit de instalación / actualización — `_actualizacion_b42.21/`

| Archivo | Rol |
|---|---|
| `aplicar_viewpoint_zb.sh` | Instala/repara ZombieBuddy + Viewpoint y parchea lanzadores en cualquier carpeta de PZ. **Idempotente**. |
| `actualizar_b4221.sh` | Fusiona una fuente 42.21 sobre la copia actual: respaldo rápido (`cp -al`), `rsync --delete` protegiendo el *crack* y los mods, reinstala todo. Simulación por defecto (`--aplicar` para ejecutar). |
| `actualizar_por_steam.sh` | Descarga 42.21 con `steamcmd` (requiere cuenta propietaria) y llama a `actualizar_b4221.sh`. |
| `README_ACTUALIZACION_B42.21.md` | Guía de actualización y reversión. |
| `instalar_viewpoint_windows.ps1` | Instalador nativo de Windows (equivalente a `aplicar_viewpoint_zb.sh`). Soporta BOM UTF-8. |
| `INSTALAR_VIEWPOINT_WINDOWS.bat` | Wrapper de doble clic para el `.ps1`. |
| `Arrancar_PZ.bat` | Lanzador de Windows. |

### 4.2 Integración en el escritorio (Linux)

| Elemento | Ruta |
|---|---|
| Script lanzador | `<juego>/arrancar_pz.sh` |
| Enlace en `PATH` | `~/.local/bin/arrancar_pz` |
| Acceso de menú | `~/.local/share/applications/pz-viewpoint.desktop` |
| Acceso de escritorio | `~/Escritorio/pz-viewpoint.desktop` |
| Icono | `~/.local/share/icons/hicolor/{128x128,256x256}/apps/pz-viewpoint.png` |

### 4.3 Paquetes para Windows

| Archivo | Tamaño | Contenido |
|---|---|---|
| `ProjectZomboid_42.21_Viewpoint_Windows.zip` | ~5,0 GB | Juego 42.21 completo + agente + mods + instalador + crack |
| `PZ42.21_Viewpoint_overlay.zip` | ~46 MB | Solo mods + agente + instalador (para añadir a un PZ 42.21 existente) |

### 4.4 Copias de seguridad

- `_viewpoint_backup_20261012_123857/` — lanzadores originales de 42.20.4 + `README_instalacion_viewpoint.txt`.
- `../_backup_b42.20.4_<fecha>/` — respaldo instantáneo por enlaces duros (`cp -al`) previo a cada actualización.

---

## 5. Qué se adaptó / parcheó

| Archivo | Cambio | Motivo |
|---|---|---|
| `ProjectZomboid64.json` | Se añadió `"-agentlib:zbNative"` como **primer** elemento de `vmArgs` | Cargar el agente ZombieBuddy al arrancar (`pzexe`). Se respetan los saltos **CRLF**. |
| `ProjectZomboid64.bat`<br>`ProjectZomboid64ShowConsole.bat`<br>`ProjectZomboidOpenGLDebug64.bat` | `SET _JAVA_OPTIONS=-agentlib:zbNative` | Alternativa de arranque vía `.bat` / consola. |
| `mods/Viewpoint/common/mod.info` | `versionMin` `42.21 → 42.20` *(en 42.20.4)* y de vuelta a **`42.21`** *(tras actualizar)* | Levantar la restricción de versión que impedía cargar el mod en 42.20.4. |
| Raíz del juego | Copia de `ZombieBuddy.jar` + `zbNative.dll` | El agente y su librería nativa deben estar en el *classpath*/`java.library.path`. |
| `<juego>/mods/` **y** `.../Zomboid/mods/` | Mods duplicados | Garantizar la detección en todas las ubicaciones que PZ escanea. |
| Crack | **Preservado** (`OnlineFix64.dll`, `steam_api64.of`, `steam_appid.txt`…); en 42.21 se mantiene el **Goldberg** propio del repack | El *merge* nunca sobrescribe los archivos del *crack*. |

**Detalle técnico del parche del JSON** (inserción preservando CRLF):

```text
	"vmArgs": [
		"-agentlib:zbNative",
		"-Djava.awt.headless=true",
		...
```

**Detalle del agente:** `ProjectZomboid64.exe` es un *launcher* (`pzexe`) que lee
`ProjectZomboid64.json` y arranca el JVM **empaquetado** (`jre64`, Zulu 25.0.1). Por eso
el agente se instala con la variante de **Windows** (`zbNative.dll`, PE32+ x86-64), incluso
bajo Wine, ya que el juego ejecuta su JRE de Windows.

---

## 6. Cómo funciona

```text
ProjectZomboid64.exe (pzexe)
   └─ lee ProjectZomboid64.json  →  vmArgs: -agentlib:zbNative
        └─ jre64/bin/java.exe (Zulu 25.0.1)
             ├─ agent ZombieBuddy (ZombieBuddy.jar)  → transforma clases del juego en runtime
             └─ classpath: . ; projectzomboid.jar
```

- **ZombieBuddy** engancha el arranque (Java Instrumentation), aplica *advice* sobre clases
  del juego (`zombie.GameWindow.init`, `DoLoadingText`, `DebugLog`…) y permite cargar mods
  con `javaJarFile` (`Viewpoint.jar`).
- **Project Viewpoint** usa ese framework para parchear el renderizador y ofrecer cámara en
  1ª persona. Registra en `console.txt` con el prefijo `[Viewpoint]`.
- Los mods se activan **en el juego** (Mod Manager) y el JAR debe **aprobarse** una vez
  (hash SHA-256). Eso **no** es automatizable de forma segura.

**Controles de Viewpoint:** `O` = 1ª persona · `Shift+O` = alternar 1ª/3ª ·
`Insert+O` = free cam · `Shift+Insert+O` = free cam física · `Delete` = ajustes.

---

## 7. Instalación — Linux / Wine

**Requisitos:** `bash`, `rsync`, `unzip`/`7z`, `python3`, `wine`, `ImageMagick` (solo para el icono).

```bash
# Instalar o reparar mods + agente en una carpeta de PZ (por defecto asume 42.21)
./_actualizacion_b42.21/aplicar_viewpoint_zb.sh "/ruta/a/ProjectZomboid"
# Para 42.20.x usa el segundo argumento:
./_actualizacion_b42.21/aplicar_viewpoint_zb.sh "/ruta/a/ProjectZomboid" 42.20

# Actualizar a 42.21 desde un repack nuevo (simulación, luego --aplicar)
./_actualizacion_b42.21/actualizar_b4221.sh --fuente "/ruta/a/PZ42.21"
./_actualizacion_b42.21/actualizar_b4221.sh --fuente "/ruta/a/PZ42.21" --aplicar

# Actualizar desde Steam (requiere cuenta propietaria)
./_actualizacion_b42.21/actualizar_por_steam.sh TU_USUARIO_STEAM --aplicar
```

**Arranque:**

```bash
arrancar_pz            # normal
arrancar_pz -c         # con consola
arrancar_pz -d         # debug OpenGL
arrancar_pz -h         # ayuda
# o desde el menú / escritorio: "Project Zomboid 42.21 (Viewpoint)"
```

---

## 8. Instalación — Windows

La carpeta preparada es **portable**: `zbNative.dll`, el *crack* y el juego son binarios de
Windows x86-64 y el `.jar` es multiplataforma.

1. Copia la carpeta del juego (o usa el `.zip` completo) a, por ejemplo,
   `C:\Games\ProjectZomboid`.
2. Ejecuta `_instalar_viewpoint_windows\INSTALAR_VIEWPOINT_WINDOWS.bat`
   (copia los mods a `%USERPROFILE%\Zomboid\mods` y re-parchea lanzadores).
3. Arranca `ProjectZomboid64.exe` (o `_instalar_viewpoint_windows\Arrancar_PZ.bat`).
4. En el juego: **Mods → ZombieBuddy y después Viewpoint → aprobar los JAR**.

> **No** hace falta instalar Java (el repack trae `jre64`). Sí conviene tener los
> **VC++ Redistributable** (incluidos en `_CommonRedist` de los repacks).

---

## 9. Compatibilidad

### 9.1 Matriz

| Aspecto | Windows nativo | Linux (Wine) | Estado |
|---|---|---|---|
| Juego base 42.21 | ✅ | ✅ | Verificado |
| `jre64` incluido (Zulu 25.0.1) | ✅ | ✅ | Verificado |
| Agente `-agentlib:zbNative` | ✅ | ✅ | Verificado (`[ZB] activating ZombieBuddy v2.3.4`) |
| ZombieBuddy 2.3.4 | ✅ | ✅ | Verificado (transforma clases en arranque) |
| Viewpoint 0.1.6 | ✅ | ⚠️ | Requiere activación + aprobación de JAR *in-game* |
| Lanzadores JSON / `.bat` | ✅ | ✅ | Parche idempotente, CRLF preservado |
| Scripts `bash` / `.sh` | ❌ | ✅ | Solo Linux/macOS |
| Instalador `.ps1` / `.bat` | ✅ | ❌ | Solo Windows |
| `.desktop` / icono hicolor | ❌ | ✅ | Solo Linux |
| Crack OnlineFix | ✅ | ✅ | Preservado |
| Crack Goldberg | ✅ | ✅ | Propio del repack 42.21 |

### 9.2 Notas por sistema

**Linux / Wine**
- Probado con **Wine 10.0** en **CachyOS (Arch)**.
- El JVM de Windows corre bajo Wine; **no** se usa un JDK del sistema.
- GPU de la prueba: **Intel UHD Graphics (CML GT2)** — iGPU, rendimiento limitado.
- Gestor de ventanas: los `.desktop` requieren permisos de ejecución; en GNOME puede
  pedir *"Permitir lanzar"* (clic derecho).

**Windows**
- Todo nativo; sin necesidad de Wine, Java ni dependencias adicionales.
- El menú/inicio usa `console.txt` en `%USERPROFILE%\Zomboid`.

### 9.3 Requisitos de hardware (según autor de Viewpoint)
- **GPU dedicada recomendada.** En iGPU (Intel) o AMD antiguas puede ir lento/inestable:
  usar el preset **"Vanilla"**.
- **RAM:** el juego arranca con `-Xmx3072m`; para el *model pack* 3D, `4096m` o más.

---

## 10. Verificación realizada

**Carga del agente** (`wine jre64/bin/java.exe … -agentlib:zbNative -version`):

```text
[ZB] activating ZombieBuddy v2.3.4
openjdk version "25.0.1" 2025-10-21 LTS
```

**Arranque real (42.21)** — extracto de `console.txt`:

```text
version=42.21.0 4a0e9546ec demo=false
revision=4a0e9546ec pzbullet=1.0.0.28
[ZB] patching zombie.GameWindow.init with 1 advice(s)
OpenGL version: 4.6 (Compatibility Profile) Mesa 26.2.4
Display mode changed to 1920x1080 freq=60 fullScreen=true
```

**Sin errores/excepciones** durante el arranque; agente activo parcheando clases del juego.

**Probed with `steamcmd`:**

```text
app_info_print 108600 (anónimo)  → OK (metadatos: ramas public/unstable = build 25485521)
app_update 108600   (anónimo)  → 0 bytes  (requiere una cuenta que posea el juego)
```

---

## 11. Riesgos y notas

| Tema | Detalle |
|---|---|
| `versionMin` forzado | Forzarlo en **42.20.4** permite cargar Viewpoint pero puede crashear el motor (parchea el render). **Solución real: actualizar a 42.21** (aplicada). |
| Aprobación de JAR | Obligatoria, una vez, en el juego. No automatizable. |
| GPU integrada | Rendimiento inestable; usar preset **"Vanilla"**; el autor advierte de *crashes* en iGPU/AMD. |
| RAM | Subir `-Xmx` si se usa el *model pack* 3D. |
| Guardados | 42.20.4 → 42.21 mantiene compatibilidad, pero conviene copiar `Zomboid/Saves`. |
| Servidor | `ProjectZomboidServer.bat` **no** lleva el agente; si se monta servidor con Viewpoint, añadirlo a mano. |
| Espacio | Repack 42.21 ≈ 10 GB; ZIP completo ≈ 5 GB; respaldo ≈ instantáneo (enlaces duros). |

---

## 12. Reversión

**Restaurar una actualización** (respaldo por enlaces duros):

```bash
rsync -a --delete "../_backup_b42.20.4_<fecha>/" .
```

**Quitar mods + agente** (Linux):

```bash
rm -f  <juego>/ZombieBuddy.jar <juego>/zbNative.dll
rm -rf <juego>/mods/ZombieBuddy <juego>/mods/Viewpoint
rm -rf ~/.wine/drive_c/users/<usuario>/Zomboid/mods/ZombieBuddy \
       ~/.wine/drive_c/users/<usuario>/Zomboid/mods/Viewpoint
# restaurar lanzadores desde _viewpoint_backup_20261012_123857/
```

---

## 13. Reproducción desde cero

```bash
# 1) steamcmd (si no está)
mkdir -p ~/steamcmd && cd ~/steamcmd
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# 2) Descargar los mods (anónimo, contenido gratuito)
./steamcmd.sh +login anonymous \
  +workshop_download_item 108600 3619862853 \
  +workshop_download_item 108600 3809306528 +quit

# 3) Instalar en una copia de PZ 42.21
/path/a/_actualizacion_b42.21/aplicar_viewpoint_zb.sh "/ruta/a/ProjectZomboid" 42.21

# 4) Arrancar y activar los mods en el juego
```

---

## 14. Árbol de archivos

```text
Project.Zomboid.v42.21/
└── ProjectZomboid/                      # ← carpeta del juego (portable a Windows)
    ├── ProjectZomboid64.exe
    ├── ProjectZomboid64.json            #   + -agentlib:zbNative
    ├── ProjectZomboid64(ShowConsole|OpenGLDebug64).bat   # + SET _JAVA_OPTIONS
    ├── projectzomboid.jar               #   Build 42.21
    ├── ZombieBuddy.jar                  #   agente (raíz)
    ├── zbNative.dll                     #   librería nativa (PE32+ x64)
    ├── steam_api64.dll / .bak           #   crack Goldberg
    ├── steam_settings/                  #   crack Goldberg
    ├── steam_appid.txt
    ├── arrancar_pz.sh                   #   lanzador Linux
    ├── mods/
    │   ├── ZombieBuddy/
    │   └── Viewpoint/                   #   versionMin=42.21
    └── _instalar_viewpoint_windows/
        ├── INSTALAR_VIEWPOINT_WINDOWS.bat
        ├── instalar_viewpoint_windows.ps1
        └── Arrancar_PZ.bat

_actualizacion_b42.21/                   # kit Linux/actualización
├── aplicar_viewpoint_zb.sh
├── actualizar_b4221.sh
├── actualizar_por_steam.sh
├── instalar_viewpoint_windows.ps1
├── INSTALAR_VIEWPOINT_WINDOWS.bat
├── Arrancar_PZ.bat
└── README_ACTUALIZACION_B42.21.md
```

---

## 15. Licencia y aviso legal

### Licencia de este repositorio

- Los **scripts y la documentación propios** de este repositorio se distribuyen bajo
  **MIT License** (ver `LICENSE`). Copyright (c) 2026.
- Las dependencias de terceros conservan **sus** licencias (ver `NOTICE`).

### Aviso legal

- **Project Zomboid** es propiedad de *The Indie Stone*. Este repositorio/documentación
  **no** redistribuye archivos del juego.
- **ZombieBuddy** (© Zed, `github.com/zed-0xff/ZombieBuddy`, GPL-3.0) y **Project Viewpoint**
  y su *model pack* pertenecen a sus autores; se obtienen gratuitamente desde Steam Workshop.
- Los *scripts* y la documentación aquí descritos son utilidades de instalación/automatización.
  Cada usuario debe **poseer una licencia legítima** del juego para usarlo.
