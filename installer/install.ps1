Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$APP = "python-app-launcher"
$URL = "https://github.com/jatonline/python-app-launcher/archive/refs/heads/main.tar.gz"
$BASE = "$Env:UserProfile\$APP"

echo "This is the installer for $APP"
echo "Downloading prerequisites..."
$utilsPath = Join-Path -Path $BASE -ChildPath "utils"
New-Item -ItemType Directory -Path $utilsPath -Force | Out-Null

$env:UV_UNMANAGED_INSTALL = "$BASE\utils"
$env:INSTALLER_PRINT_QUIET = "1"
irm https://astral.sh/uv/install.ps1 | iex
$UV = Join-Path -Path $utilsPath -ChildPath "uv"

Write-Host "Downloading app..."
$appPath = Join-Path -Path $BASE -ChildPath "app"
New-Item -ItemType Directory -Path $appPath -Force | Out-Null
irm $URL -OutFile "$appPath\app.tar.gz"
tar -xzf "$appPath\app.tar.gz" -C $appPath --strip-components=1
del "$appPath\app.tar.gz" -erroraction silentlycontinue

Write-Host "Installing dependencies..."
Remove-Item -Recurse -Force "$appPath\app\.venv" -ErrorAction SilentlyContinue
& "$UV" sync -q --project "$appPath\app"

$launchScript = '
set BASE=%~dp0
"%BASE%\utils\uv" run --directory "%BASE%\app\app" python -m streamlit run app.py
'

Set-Content -Path "$BASE\launch.bat" -Value $launchScript -Force
