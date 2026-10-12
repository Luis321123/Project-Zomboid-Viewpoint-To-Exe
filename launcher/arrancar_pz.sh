#!/usr/bin/env bash
# ============================================================================
#  arrancar_pz.sh  -  Lanza Project Zomboid Build 42.21 (ZombieBuddy + Viewpoint)
#  bajo Wine. Se autolocaliza: puede ejecutarse desde cualquier sitio.
#
#  Uso:
#     ./arrancar_pz.sh              # arranque normal (ProjectZomboid64.exe)
#     ./arrancar_pz.sh -c           # con consola (ProjectZomboid64ShowConsole.bat)
#     ./arrancar_pz.sh -d           # debug OpenGL (ProjectZomboidOpenGLDebug64.bat)
#     ./arrancar_pz.sh -h           # ayuda
#
#  Variables:
#     PZ_WINEDEBUG   por defecto "-all" (silencio de Wine)
# ============================================================================
set -euo pipefail

SELF="$(readlink -f "${BASH_SOURCE[0]}")"
GAMEDIR="$(dirname "$SELF")"
cd "$GAMEDIR"

print_help(){
  cat <<'EOF'
Uso: arrancar_pz.sh [opción]

  (sin opción)     Arranque normal (ProjectZomboid64.exe).
  -c, --consola    Arranque con consola (ProjectZomboid64ShowConsole.bat).
  -d, --debug      Arranque con debug de OpenGL (ProjectZomboidOpenGLDebug64.bat).
  -h, --help       Muestra esta ayuda.

Detalles:
  * Juego 42.21 con ZombieBuddy + Viewpoint, sobre Wine.
  * Log del juego:  ~/.wine/drive_c/users/<usuario>/Zomboid/console.txt
  * Log de Wine (sin terminal): .../Zomboid/wine_launch.log
EOF
}

case "${1:-}" in
  -h|--help) print_help; exit 0;;
esac

export WINEDEBUG="${PZ_WINEDEBUG:--all}"

# Si no hay terminal (lanzado desde el menú/.desktop), guarda el log de Wine.
if [ ! -t 1 ]; then
  LOG="$HOME/.wine/drive_c/users/$(id -un)/Zomboid/wine_launch.log"
  mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
  exec >>"$LOG" 2>&1
  echo "===== $(date) ====="
fi

case "${1:-}" in
  -c|--consola)
    shift
    echo ">> con consola: ProjectZomboid64ShowConsole.bat"
    exec wine cmd /c ProjectZomboid64ShowConsole.bat "$@";;
  -d|--debug)
    shift
    echo ">> debug OpenGL: ProjectZomboidOpenGLDebug64.bat"
    exec wine cmd /c ProjectZomboidOpenGLDebug64.bat "$@";;
  *)
    exec wine ProjectZomboid64.exe "$@";;
esac
