#!/bin/bash
source venv/bin/activate
# Using gunicorn for production-grade stability
# --timeout 300: Allow up to 5 minutes for heavy OCR tasks
# --bind 0.0.0.0:5000: Listen on all interfaces
# --workers 1: Keep it simple for local CPU processing
echo "Starting Backend with Gunicorn (Timeout: 300s)..."
exec gunicorn --timeout 300 --bind 0.0.0.0:5000 app:app
