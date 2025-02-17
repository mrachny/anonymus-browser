# Disposable-Private-Browser.ps1
# One-click solution to launch disposable private Firefox in Docker
# Save this as a .ps1 file and run it with PowerShell

# Ensure Docker is running
$dockerStatus = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    pause
    exit
}

# Create temporary directory for X11 socket
$tempDir = "$env:TEMP\docker-firefox-tmp"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

# Check if VcXsrv is installed and running
$vcxsrvPath = "${env:ProgramFiles}\VcXsrv\vcxsrv.exe"
$vcxsrvAltPath = "${env:ProgramFiles(x86)}\VcXsrv\vcxsrv.exe"
$vcxsrvInstalled = (Test-Path $vcxsrvPath) -or (Test-Path $vcxsrvAltPath)

if (-not $vcxsrvInstalled) {
    # Download and install VcXsrv if not present
    Write-Host "VcXsrv not found. Downloading and installing..." -ForegroundColor Yellow
    $installer = "$tempDir\vcxsrv_installer.exe"
    $downloadUrl = "https://sourceforge.net/projects/vcxsrv/files/latest/download"
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $installer
        Start-Process -FilePath $installer -ArgumentList "/silent" -Wait
        Write-Host "VcXsrv installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Error downloading or installing VcXsrv. Please install it manually." -ForegroundColor Red
        Start-Process "https://sourceforge.net/projects/vcxsrv/"
        pause
        exit
    }
}

# Start VcXsrv if it's not already running
$vcxsrvRunning = Get-Process -Name vcxsrv -ErrorAction SilentlyContinue
if (-not $vcxsrvRunning) {
    if (Test-Path $vcxsrvPath) {
        Start-Process -FilePath $vcxsrvPath -ArgumentList "-multiwindow -ac -clipboard -wgl"
    }
    elseif (Test-Path $vcxsrvAltPath) {
        Start-Process -FilePath $vcxsrvAltPath -ArgumentList "-multiwindow -ac -clipboard -wgl"
    }
    Write-Host "Started VcXsrv X Server..." -ForegroundColor Green
    # Wait for X server to initialize
    Start-Sleep -Seconds 2
}

# Get Windows IP for X display
$hostIP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "*(Ethernet|WiFi|Wireless)*" -ErrorAction SilentlyContinue | Select-Object -First 1).IPAddress
if (-not $hostIP) {
    $hostIP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "vEthernet*" -ErrorAction SilentlyContinue | Select-Object -First 1).IPAddress
}
if (-not $hostIP) {
    $hostIP = "localhost"
}

# Run Firefox in Docker
Write-Host "Starting disposable Firefox browser..." -ForegroundColor Cyan
Write-Host "This browser session is completely isolated and will be destroyed when closed." -ForegroundColor Yellow
Write-Host "Any downloads can be saved to the /downloads folder in the container." -ForegroundColor Yellow

$displayEnv = "DISPLAY=$($hostIP):0.0"

# Instead of mounting the X11 socket directory, we'll use host networking
# This avoids the "Resource busy" error when cleaning up
<# docker run --rm -it `
    -e $displayEnv `
    -e "PULSE_SERVER=tcp:$($hostIP):4713" `
    --network host `
    --security-opt seccomp=unconfined `
    --name disposable-firefox `
    jlesage/firefox:latest #>

docker run --rm -it `
    -p 5800:5800 `
    -p 5900:5900 `
    --name disposable-firefox `
    jlesage/firefox:latest

# Cleanup
Write-Host "Browser session ended. All browsing data has been destroyed." -ForegroundColor Green # Disposable-Private-Browser.ps1
# One-click solution to launch disposable private Firefox in Docker
# Save this as a .ps1 file and run it with PowerShell

# Ensure Docker is running
$dockerStatus = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    pause
    exit
}

# Create temporary directory for X11 socket
$tempDir = "$env:TEMP\docker-firefox-tmp"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

# Check if VcXsrv is installed and running
$vcxsrvPath = "${env:ProgramFiles}\VcXsrv\vcxsrv.exe"
$vcxsrvAltPath = "${env:ProgramFiles(x86)}\VcXsrv\vcxsrv.exe"
$vcxsrvInstalled = (Test-Path $vcxsrvPath) -or (Test-Path $vcxsrvAltPath)

if (-not $vcxsrvInstalled) {
    # Download and install VcXsrv if not present
    Write-Host "VcXsrv not found. Downloading and installing..." -ForegroundColor Yellow
    $installer = "$tempDir\vcxsrv_installer.exe"
    $downloadUrl = "https://sourceforge.net/projects/vcxsrv/files/latest/download"
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $installer
        Start-Process -FilePath $installer -ArgumentList "/silent" -Wait
        Write-Host "VcXsrv installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Error downloading or installing VcXsrv. Please install it manually." -ForegroundColor Red
        Start-Process "https://sourceforge.net/projects/vcxsrv/"
        pause
        exit
    }
}

# Start VcXsrv if it's not already running
$vcxsrvRunning = Get-Process -Name vcxsrv -ErrorAction SilentlyContinue
if (-not $vcxsrvRunning) {
    if (Test-Path $vcxsrvPath) {
        Start-Process -FilePath $vcxsrvPath -ArgumentList "-multiwindow -ac -clipboard -wgl"
    }
    elseif (Test-Path $vcxsrvAltPath) {
        Start-Process -FilePath $vcxsrvAltPath -ArgumentList "-multiwindow -ac -clipboard -wgl"
    }
    Write-Host "Started VcXsrv X Server..." -ForegroundColor Green
    # Wait for X server to initialize
    Start-Sleep -Seconds 2
}

# Get Windows IP for X display
$hostIP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "*(Ethernet|WiFi|Wireless)*" -ErrorAction SilentlyContinue | Select-Object -First 1).IPAddress
if (-not $hostIP) {
    $hostIP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "vEthernet*" -ErrorAction SilentlyContinue | Select-Object -First 1).IPAddress
}
if (-not $hostIP) {
    $hostIP = "localhost"
}

# Run Firefox in Docker
Write-Host "Starting disposable Firefox browser..." -ForegroundColor Cyan
Write-Host "This browser session is completely isolated and will be destroyed when closed." -ForegroundColor Yellow
Write-Host "Any downloads can be saved to the /downloads folder in the container." -ForegroundColor Yellow

$displayEnv = "DISPLAY=$($hostIP):0.0"

# Instead of mounting the X11 socket directory, we'll use host networking
# This avoids the "Resource busy" error when cleaning up
docker run --rm -it `
    -e $displayEnv `
    -e "PULSE_SERVER=tcp:$($hostIP):4713" `
    --network host `
    --security-opt seccomp=unconfined `
    --name disposable-firefox `
    jlesage/firefox:latest

# Cleanup
Write-Host "Browser session ended. All browsing data has been destroyed." -ForegroundColor Green