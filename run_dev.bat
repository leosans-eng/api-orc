@echo off
REM Producao — servidor Windows (Docker Desktop): sobe Postgres + API.
REM Equivalente: docker compose up -d --build
REM Checklist: LANCAMENTO.md
cd /d "%~dp0"

if not exist ".env" (
  copy ".env.example" ".env"
  echo Arquivo .env criado a partir de .env.example
  echo.
  echo IMPORTANTE: edite .env agora — SECRET_KEY, ADMIN_PASSWORD e POSTGRES_PASSWORD.
  echo Depois execute run_dev.bat de novo.
  echo.
  notepad ".env"
  pause
  exit /b 0
)

if not exist "dados_usuario\composicoes_proprias.json" (
  echo ERRO: falta dados_usuario\ com os JSON de seed.
  echo Copie a pasta dados_usuario completa deste repositorio para o servidor.
  pause
  exit /b 1
)

findstr /C:"troque-esta-chave-em-producao" ".env" >nul 2>&1
if not errorlevel 1 (
  echo AVISO: SECRET_KEY ainda esta com o valor de exemplo. Altere em .env antes de liberar aos clientes.
  echo.
)

findstr /C:"ADMIN_PASSWORD=password" ".env" >nul 2>&1
if not errorlevel 1 (
  echo AVISO: ADMIN_PASSWORD ainda e "password". Altere em .env antes de liberar aos clientes.
  echo.
)

where docker >nul 2>&1
if errorlevel 1 (
  echo Docker nao encontrado no PATH.
  echo Instale e abra o Docker Desktop, depois execute este arquivo de novo.
  pause
  exit /b 1
)

docker compose up -d --build
if errorlevel 1 (
  echo.
  echo Falha ao subir os containers. Verifique se o Docker Desktop esta em execucao.
  pause
  exit /b 1
)

echo.
echo API:      http://localhost:8000/docs
echo Health:   http://localhost:8000/api/health
echo Rede:     http://IP_DO_SERVIDOR:8000
echo Logs:     docker compose logs -f api
echo Parar:    docker compose down
echo Checklist: LANCAMENTO.md
echo.
pause
