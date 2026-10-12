@echo off
title Instalar ZombieBuddy + Viewpoint (Project Zomboid 42.21)
echo ============================================================
echo   ZombieBuddy + Project Viewpoint  -  instalador (Windows)
echo   Project Zomboid Build 42.21
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalar_viewpoint_windows.ps1" %*
echo.
echo Hecho. Pulsa una tecla para cerrar.
pause >nul
