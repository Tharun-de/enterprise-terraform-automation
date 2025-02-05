# Check if 'requests' module is installed
try {
    python -c "import requests"
    Write-Output "Requests module is already installed."
} catch {
    Write-Output "Installing requests module..."
    pip install requests
}
