# Function to authenticate and get access token
Function Get-AccessToken {
    $tokenUrl = 'https://api.us-2.crowdstrike.com/oauth2/token'
    $clientId = '000'
    $clientSecret = '000'

    $payload = @{
        'grant_type' = 'client_credentials'
        'client_id' = $clientId
        'client_secret' = $clientSecret
    }

    try {
        $response = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $payload
        Write-Host "Authentication successful"
    } 
    
    catch {
        Write-Host "Failed to obtain the access token: $($_.Exception.Response.StatusCode.value__)"
        exit
    }

    return $response.access_token
}

# Function to get sensor installer SHA256
Function Get-InstallerSHA256 {
    param (
        [string]$Token
    )
    
    $installerUrl = "https://api.us-2.crowdstrike.com/sensors/combined/installers/v2?limit=1&sort=version%7Cdesc&filter=platform%3A%22windows%22"

    $response = Invoke-RestMethod -Method Get -Uri $installerUrl -Headers @{Authorization = "Bearer $Token"}

    if ($response.resources.Count -eq 0) {
        Write-Host "No installer found"
        exit
    }

    return $response.resources[0].sha256
}

# Function to download and install the sensor
Function Install-Sensor {
    $accessToken = Get-AccessToken
    $sha256 = Get-InstallerSHA256 $accessToken
    $downloadUrl = "https://api.us-2.crowdstrike.com/sensors/entities/download-installer/v2?id=$sha256"

    $fileName = "WindowsSensor.MaverickGyr.exe"
    $response = Invoke-WebRequest -Uri $downloadUrl -Headers @{Authorization = "Bearer $accessToken"} -OutFile $fileName

    # Run the installer
    Start-Process -FilePath $fileName -ArgumentList "/install /quiet /norestart CID=000"
}

# Call the function to install the sensor
Install-Sensor
