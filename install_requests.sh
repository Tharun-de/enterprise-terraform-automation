#!/bin/bash

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Python3 not found, exiting..."
    exit 1
fi

# Check if pip3 is installed
if ! command -v pip3 &> /dev/null; then
    echo "pip3 not found, installing it..."
    apt-get update && apt-get install -y python3-pip
fi

# Check if requests module is installed
if ! python3 -c "import requests" &> /dev/null; then
    echo "Installing requests module..."
    pip3 install requests
else
    echo "Requests module already installed."
fi
