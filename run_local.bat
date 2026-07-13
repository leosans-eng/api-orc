@echo off
REM Desenvolvimento (PC do Léo, sem Docker Desktop no Windows, com WSL):
REM   1) No WSL: docker compose up -d db   (e docker compose stop api, se a porta 8000 estiver ocupada)
REM   2) Aqui: sobe a API no Windows com --reload
REM Producao no servidor: run_dev.bat
cd /d "%~dp0"

if not exist ".env" (
  copy ".env.example" ".env"
  echo Arquivo .env criado a partir de .env.example
)

echo API Windows ^(uvicorn --reload^) + Postgres em localhost:5432 ^(WSL^)
echo Se falhar a conexao com o banco, no WSL rode: docker compose up -d db
echo.

set "PYTHON=%~dp0.venv\Scripts\python.exe"
if not exist "%PYTHON%" set "PYTHON=python"

REM Codigo importa "api.*"; a pasta do repo pode se chamar API-ORC.
REM Expomos o diretorio atual como pacote "api" via junction em .devpath.
if not exist "%~dp0.devpath\api" (
  mkdir "%~dp0.devpath" 2>nul
  mklink /J "%~dp0.devpath\api" "%~dp0." >nul
  if errorlevel 1 (
    echo Falha ao criar junction .devpath\api. Rode o terminal como usuario normal ^(sem Admin necessario^).
    exit /b 1
  )
)
set "PYTHONPATH=%~dp0.devpath"

"%PYTHON%" -m uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
