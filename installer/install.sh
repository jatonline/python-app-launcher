#!/bin/sh
set -eu

APP="python-app-launcher"
URL="https://github.com/jatonline/python-app-launcher/archive/refs/heads/main.tar.gz"
BASE="$HOME/$APP"

echo "This is the installer for $APP"

echo "Downloading prerequisites..."
mkdir -p "$BASE/utils"
curl -LsSf https://astral.sh/uv/install.sh | env UV_UNMANAGED_INSTALL="$BASE/utils" INSTALLER_PRINT_QUIET="1" sh
UV="$BASE/utils/uv"

echo "Downloading app..."
mkdir -p "$BASE/app"
curl -LsSf "$URL" | tar xz --strip-components=1 -C "$BASE/app"

echo "Installing dependencies..."
rm -rf "$BASE/app/app/.venv"
"$UV" sync -q --project "$BASE/app/app"

cat << 'EOF' > "$BASE/launch"
#!/bin/sh
BASE="$(dirname "$0")"
"$BASE/utils/uv" run --directory "$BASE/app/app" streamlit run app.py
EOF
chmod +x "$BASE/launch"

echo "Completed installation, run $APP/launch to start the app."
