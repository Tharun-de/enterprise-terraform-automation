#!/bin/bash
# Check if 'requests' module is installed
if ! python3 -c "import requests" &> /dev/null; then
    echo "Installing requests module..."
    pip3 install requests
else
    echo "Requests module already installed."
fi
