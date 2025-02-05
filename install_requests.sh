#!/bin/bash
# Create a virtual environment if not exists
if [ ! -d "${path.module}/venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv ${path.module}/venv
fi

# Activate the virtual environment
source ${path.module}/venv/bin/activate

# Install the requests module
if ! ${path.module}/venv/bin/python -c "import requests" &> /dev/null; then
    echo "Installing requests module..."
    ${path.module}/venv/bin/pip install requests
else
    echo "Requests module already installed."
fi
