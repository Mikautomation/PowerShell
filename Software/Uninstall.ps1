<#
.Synopsis
   Uninstall Programs 
.DESCRIPTION
   Find Uninstall Strings in the Registry and Uninstall Program.
   Default Log Location C:\temp
  
.PARAMETER Invoke-Uninstall
    
.NOTES
  Version:        1.0
  Author:         Michael Anderson
  Creation Date:  30/08/2019
  GitHub:         https://github.com/Mike-T-Anderson/PowerShell
  Purpose/Change: Initial script development
.EXAMPLE
   Invoke-Uninstall "Revit 2018" -Log C:\temp\
.EXAMPLE
   Invoke-Uninstall "Revit 2018" -passive 
   (this will make the uninstaller Passive with Prompts Default is silent)
.EXAMPLE
   Invoke-Uninstall "Revit 2018" -logpath C:\path\Path
#>

Function Invoke-Uninstall {

    Param(
        
        [Parameter(Mandatory = $true, Position = 0)][string] $App,
        [Parameter(Mandatory = $false)][Switch]$Passive,
        [Parameter(Mandatory = $false)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string[]]$logPath
                   
    )
          
    # ------------------------------------------[ Variables ] --------------------------------- #

    $software = $App.Replace(' ', '*')
    $productNames = "*$software*"

    if ($passive)
    { $Method = "passive" }
    else { $Method = "quiet" }
    
    # ------------------------------------------ [Logging ]  ------------------------------------------ #
      
    $log = ("C:\temp\$app" + "_" + [string](Get-Date -Format s).Replace(":","-")).Replace(' ', '') + '.txt.'

    if ($logPath)
        {
            $Log = ($logPath + "\$app" + "_" + [string](Get-Date -Format s).Replace(":","-")).Replace(' ','') + '.txt.'

        }
      
    # ------------------------------------------[ Find Uninstall Key, String] --------------------------------- #

    $UninstallKeys = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )

    $uninstallKeys = foreach ($key in (Get-ChildItem $UninstallKeys) ) {

        foreach ($product in $productNames) {
            if ($key.GetValue("DisplayName") -like "$product") {
                [pscustomobject]@{
                    KeyName         = $key.Name.split('\')[-1];
                    DisplayName     = $key.GetValue("DisplayName");
                    UninstallString = $key.GetValue("UninstallString");
                    Publisher       = $key.GetValue("Publisher");
                }
            }
        }
    }

    # ------------------------------------------ [Uninstall Software ]  ------------------------------------------ #

    foreach ($key in $uninstallkeys) {

    
    $guid = $key.keyname

        if ($guid.StartsWith("{")) {
            $uninstallString = "MsiExec.exe /X $guid /$method /norestart /L*V $log"

            #Uncomment to Run
         cmd /c "$uninstallString"

        }
        else {
            if ($key.UninstallString -ne $null -and $key.UninstallString -notlike "*{*}*") {
            
                $uninstallString = $key.UninstallString
       
                if ($key.UninstallString -notlike '"*') {
                    $uninstallString = $uninstallString.Replace('C:\', '"C:\')
                    $uninstallString = $uninstallString.Replace('.exe', '.exe"')
                }                
        
              
            }

        }
    
    }
if($UninstallKeys -eq $Null)

{
Write-Host ""
Write-Host "$App" -ForegroundColor Red -NoNewline;
Write-Host " not found" -ForegroundColor Yellow}

}
