@echo off
chcp 65001 >nul
title NOVRAM Patcher - eFootball
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0NOVRAM_Patcher.ps1"
echo.
pause
