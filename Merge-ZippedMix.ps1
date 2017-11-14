Param( 
    [Parameter(Mandatory=$True)]
    [string]$ZippedMix
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version "Latest"

function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

function Call-Command
{
 [CmdletBinding()]
 param( 
     [Parameter(Mandatory=$True)]
     [string]$Command,
     [Array]$Arguments
 )

 Process
 {
   Write-Host "Executing: $Command $Arguments"
   & $Command $Arguments 2>&1 | tee -Variable output | Write-Host
        
   $stderr = $output | where { $_ -is [System.Management.Automation.ErrorRecord] }
   if ( ($LASTEXITCODE -ne 0) -or $stderr )
   {
       $ex = new-object System.Management.Automation.CmdletInvocationException "Command failed with exit code $LASTEXITCODE and stderr: $stderr"
       $category = [System.Management.Automation.ErrorCategory]::InvalidResult
       $errRecord = new-object System.Management.Automation.ErrorRecord $ex, "CommandFailed", $category, $Command
       $psCmdlet.WriteError($errRecord)
	   return $output
   }

   Write-Host "Command executed successfully"
   return $output
  }
}

echo "Processing file: $ZippedMix"

echo "Creating temporary folder..."
$tempFolder = New-TemporaryDirectory
echo "Created temporary folder: $tempFolder"

try
{
    echo "Expanding archive..."
    Expand-Archive -LiteralPath $ZippedMix -DestinationPath $tempFolder
    
    echo "Locating mp3 folder..."
    $firstMp3 = Get-ChildItem -File -LiteralPath $tempFolder -Recurse -Filter "*.mp3" | select -First 1
    if ($firstMp3)
    {
        echo "MP3 file detected: $firstMp3"
    }
    else
    {
        throw "No mp3 file found in zipped mix file"
    }

    $mp3Folder = $firstMp3.DirectoryName;
    echo "Joining all mp3 files in folder: $mp3Folder"
    Call-Command "mp3cat" @("--tag", "--dir", $mp3Folder, "--out", [io.path]::ChangeExtension($ZippedMix, ".mp3")) | Out-Null

}
catch
{
    echo "Exception: $($_.Exception)" #$_.Exception.Message / $_.Exception.ItemName
	echo "Temporary folder not deleted for easier troubleshooting - make sure you delete it manually!"
    exit 1
}

echo "Deleting temp folder: $tempFolder"
rm -Force -Recurse $tempFolder