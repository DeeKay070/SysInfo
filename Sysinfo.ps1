# PowerShell script to set WMI permissions and run the application with elevated privileges

# Function to set WMI permissions
function Set-WMIPermissions {
    param (
        [string]$namespace = "root\cimv2",
        [string]$account = "Everyone"
    )

    $security = Get-WmiObject -Namespace "root" -Class "__SystemSecurity"
    $securityDescriptor = $security.GetSecurityDescriptor().Descriptor

    $ace = New-Object System.Management.ManagementBaseObject -ArgumentList (New-Object System.Management.ManagementClass -ArgumentList "Win32_Ace")
    $ace.Properties["AccessMask"].Value = 2035711 # Full Control
    $ace.Properties["AceFlags"].Value = 3 # OBJECT_INHERIT_ACE | CONTAINER_INHERIT_ACE
    $ace.Properties["AceType"].Value = 0 # ACCESS_ALLOWED_ACE_TYPE
    $ace.Properties["Trustee"].Value = New-Object System.Management.ManagementBaseObject -ArgumentList (New-Object System.Management.ManagementClass -ArgumentList "Win32_Trustee")
    $ace.Properties["Trustee"].Value.Properties["Domain"].Value = ""
    $ace.Properties["Trustee"].Value.Properties["Name"].Value = $account
    $ace.Properties["Trustee"].Value.Properties["SID"].Value = (New-Object System.Security.Principal.SecurityIdentifier("S-1-1-0")).BinaryForm

    $securityDescriptor.DACL += $ace

    $security.SetSecurityDescriptor($securityDescriptor)
}

# Function to run the application with elevated privileges
function Run-Application {
    param (
        [string]$applicationPath
    )

    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $applicationPath
    $processInfo.Verb = "runas"
    $processInfo.UseShellExecute = $true

    try {
        [System.Diagnostics.Process]::Start($processInfo)
    } catch {
        Write-Error "Failed to start the application with elevated privileges: $_"
    }
}

# Set WMI permissions
Set-WMIPermissions

# Run the application with elevated privileges
$applicationPath = "C:\Users\user\Desktop\Remote Management\SysInfo\SysInfo.sln"
Run-Application -applicationPath $applicationPath
