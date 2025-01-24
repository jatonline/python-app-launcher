#!/bin/sh
uv run --directory "$(dirname "$0")/app" streamlit run app.py
