# Actualización a Project Zomboid Build 42.21

Preparado el **2026-10-12** para el repack:
`/home/home/Descargas/Project.Zomboid.v42.20.4-0xdeadcode`

---

## 1. Situación

| Cosa | Estado |
|---|---|
| Tu copia | **42.20.4** (repack `0xdeadcode`) |
| Última estable en Steam | **42.21** (liberada el **28-sep-2026**) |
| Rama Steam a usar | `public` (y `unstable`, misma build `25485521`) |
| Viewpoint 0.1.6 | requiere `versionMin=42.21` → hoy forzado a 42.20 (parche temporal) |
| Crack | OnlineFix (`RealAppId=108600`, `FakeAppId=480`) → **hay que conservar** `steam_api64.dll`, `OnlineFix64.dll`, `steam_appid.txt`, `OnlineFix.ini` |

**Por qué actualizar:** al subir a 42.21 el parche de `versionMin` deja de ser
necesario y desaparece el riesgo de crash del motor de Viewpoint. Además ya
podrás instalar el pack de modelos 3D (Workshop `3810302175`).

---

## 2. Cómo conseguir los archivos de 42.21 (elige UNA)

### Opción A — Repack nuevo  `(RECOMENDADA y más fácil)`
Descarga de tu fuente habitual la versión **`Project.Zomboid.v42.21.x-0xdeadcode`**
(y sus actualizaciones). Descomprímela en una carpeta nueva y verás dentro
`projectzomboid.jar` y `ProjectZomboid64.exe`.

- **Camino simple:** juega directamente desde esa carpeta nueva y pásale el
  instalador de mods:
  ```bash
  ./aplicar_viewpoint_zb.sh "/ruta/a/Project.Zomboid.v42.21.x-0xdeadcode"
  ```
  y lanza desde ahí (te ahorras fusionar nada). Puedes borrar el viejo después.

- **Camino "fusionar en la carpeta actual"** (si quieres mantener un único dir):
  ```bash
  ./actualizar_b4221.sh --fuente "/ruta/a/Project.Zomboid.v42.21.x-0xdeadcode" --aplicar
  ```

### Opción B — Cuenta de Steam que POSEA el juego
```bash
./actualizar_por_steam.sh TU_USUARIO_STEAM --aplicar
```
Descarga 42.21 (~10 GB, build `25485521`) a `/tmp/opencode/pz_steam` y lo fusiona.
> La descarga **anónima NO funciona**: Steam devuelve 0 bytes (ya verificado).
> Hace falta una cuenta con el juego comprado.

### Opción C — Ya tienes los archivos
Si tienes un ZIP o una carpeta con la build 42.21:
```bash
./actualizar_b4221.sh --fuente /ruta/al/PZ42.21.zip --aplicar
```

---

## 3. Los scripts (en `_actualizacion_b42.21/`)

| Script | Para qué |
|---|---|
| `actualizar_b4221.sh` | Fusiona una fuente 42.21 en tu carpeta. **Respalda**, hace `rsync`, protege crack+mods y reinstala todo. |
| `aplicar_viewpoint_zb.sh` | (Re)instala ZombieBuddy + Viewpoint y parchea los lanzadores en cualquier carpeta. Idempotente. |
| `actualizar_por_steam.sh` | Descarga con steamcmd (Opción B) y llama al anterior. |

### Flujo recomendado (por defecto es SIMULACIÓN, no toca nada)

```bash
cd "/home/home/Descargas/Project.Zomboid.v42.20.4-0xdeadcode/_actualizacion_b42.21"

# 1) ver el plan (sin cambios)
./actualizar_b4221.sh --fuente "/ruta/a/PZ42.21"

# 2) aplicarlo
./actualizar_b4221.sh --fuente "/ruta/a/PZ42.21" --aplicar
```

Opciones útiles:
- `--no-borrar` → no elimina archivos obsoletos (más conservador).
- `--usar-crack-nuevo` → deja que la fuente sobrescriba el crack (solo si el
  repack nuevo trae su propio OnlineFix ya probado).
- `--sin-mods` → solo fusiona el juego, no reinstala mods.
- `--probar` → comprueba que el agente ZombieBuddy carga bajo Wine.

### Qué se PROTEGE (nunca se sobrescribe ni se borra)
```
mods/ZombieBuddy, mods/Viewpoint, mods/loaded.txt
ZombieBuddy.jar, zbNative.dll
OnlineFix64.dll, OnlineFix.ini, OnlineFix.url
steam_api64.dll, steam_api64.of, steam_appid.txt, SKIDROWRELOADED.COM.txt
_actualizacion_b42.21, _viewpoint_backup_*, _backup_*
```

### Respaldo y reversión
Antes de fusionar se crea un respaldo **instantáneo** por enlaces duros en
`../_backup_b42.20.4_<fecha>` (ocupa casi 0; es una copia real de los inodos).
Para revertir:
```bash
rsync -a --delete "../_backup_b42.20.4_<fecha>/" .
```

---

## 4. Después de actualizar (en el juego, una vez)

1. Arranca el juego y comprueba en `<Zomboid>/console.txt`:
   `Build 42.21` y `[ZB] activating ZombieBuddy`.
2. **Mods → activa primero `ZombieBuddy` y después `Viewpoint`.** Aplica.
3. Aprueba los diálogos de JAR (SHA-256) → *Yes* (marca persistir).
4. Controles Viewpoint: `O` 1ª persona · `Shift+O` alterna 1ª/3ª ·
   `Insert+O` free cam · `Delete` ajustes.
5. (Opcional) pack de modelos 3D: Workshop `3810302175`.
   Sube memoria en `ProjectZomboid64.json`: `-Xmx4096m` o más.

---

## 5. Avisos

- **GPU Intel UHD (CML GT2):** Viewpoint es un motor PBR pesado; usa el preset
  **"Vanilla"** y espera ir lento/inestable. El autor avisa de crashes en iGPU.
- **Guardados:** la actualización de 42.20.4 → 42.21 mantiene saves, pero haz
  copia de `<Zomboid>/Saves` antes por seguridad.
- **Espacio:** necesitas ~10 GB libres para el respaldo + la fuente (tienes 173 GB).
- **Servidor:** `ProjectZomboidServer.bat` **no** lleva el agente. Si montas un
  servidor con Viewpoint, hay que añadirlo a mano ahí también.

---

## 6. Comprobación técnica que ya se hizo

- `steamcmd` anónimo: `app_info_print 108600` OK (metadatos), pero
  `app_update 108600` descarga **0 bytes** → imposible sin cuenta propietaria.
- Rama `public` = build `25485521` (28-sep-2026) = **Build 42.21 Stable**.
- El respaldo de los lanzadores originales ya está en `_viewpoint_backup_20261012_123857/`.

---

## 7. Usar en Windows (en vez de Wine/Linux)

La carpeta que preparé es **portable**: ya lleva el agente (`ZombieBuddy.jar` +
`zbNative.dll`, ambos PE de Windows x86-64), los mods en `<juego>\mods\` y el
crack Goldberg (`steam_api64.dll` + `steam_settings\`). Todo es nativo Windows.

### Pasos
1. Copia **toda** la carpeta del juego a Windows, p. ej.:
   `~/Descargas/Project.Zomboid.v42.21/ProjectZomboid`  →  `C:\Games\ProjectZomboid`
2. (Opcional, recomendado) ejecuta el instalador nativo que copia los mods a la
   carpeta de usuario y re-parchea lanzadores:
   **`_actualizacion_b42.21\INSTALAR_VIEWPOINT_WINDOWS.bat`** (doble clic).
3. Arranca con **`ProjectZomboid64.exe`** (o `_actualizacion_b42.21\Arrancar_PZ.bat`).
4. En el juego: **Mods → ZombieBuddy y luego Viewpoint → aprueba los JAR**.

> El instalador `.ps1`/`.bat` es el equivalente Windows de `aplicar_viewpoint_zb.sh`.

### Diferencias Linux → Windows
| | Linux (Wine) | Windows |
|---|---|---|
| Perfil/saves | `~/.wine/drive_c/users/<u>/Zomboid` | `%USERPROFILE%\Zomboid` |
| Mods | `<juego>/mods/` y `.../Zomboid/mods/` | `<juego>\mods\` y `%USERPROFILE%\Zomboid\mods\` |
| Arranque | `arrancar_pz` / `.desktop` | `ProjectZomboid64.exe` / `.bat` |
| Log | `console.txt` / `wine_launch.log` | `%USERPROFILE%\Zomboid\console.txt` |

- Para llevarte tus **partidas**: copia `Zomboid\Saves` (y `options.ini`, `mods\`)
  del prefijo Wine a `%USERPROFILE%\Zomboid\`.
- En Windows **no** hacen falta `arrancar_pz.sh` ni los `.desktop` (son de Linux).
- Requisitos: **Java no hace falta instalarlo** (el repack trae su `jre64`), pero
  sí los **VC++ Redistributable** (vienen en `_CommonRedist` del repack viejo) y
  unos drivers gráficos decentes.
