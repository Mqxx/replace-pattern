param (
  [string]$rootDirectory,
  [string]$patternToReplace,
  [string]$replacementString,
  [switch]$verboseOutput = $true
)

if (-not $rootDirectory -or -not $patternToReplace -or -not $replacementString) {
  Write-Host @"
Missing parameter.

DESCRIPTION
    Replace pattern in files, the file content and directories recursively.

PARAMETERS
    -rootDirectory      Specifies the root directory to start the replacement process.
    -patternToReplace   Specifies the pattern to be replaced in directory names, file names, and file contents.
    -replacementString  Specifies the string that will replace the specified pattern.
    -verboseOutput      Switch to enable verbose output showing what is being replaced.

EXAMPLE
    Replace-Pattern -rootDirectory "C:\Example" -patternToReplace "PATTERN" -replacementString "Replacement" -verboseOutput
"@
  Exit
}

if (-not (Test-Path -Path $rootDirectory -PathType Container)) {
  Write-Host ("Replace-Pattern: ") -NoNewline
  Write-Host ("'$rootDirectory'") -ForegroundColor Cyan -NoNewline
  Write-Host ": No such file or directory."
  Exit
}

Get-ChildItem -Path $rootDirectory -Recurse | ForEach-Object {
  $currentItem = $_

  if ($currentItem -is [System.IO.DirectoryInfo]) {
    $newDirectoryName = $currentItem.FullName -replace $patternToReplace, $replacementString
    if ($currentItem.FullName -ne $newDirectoryName) {
      if ($verboseOutput) {
        Write-Host ("Replace-Pattern: ") -NoNewline
        Write-Host ("'$($currentItem.FullName)'") -ForegroundColor Cyan -NoNewline
        Write-Host (": Renaming ") -NoNewline
        Write-Host ("'$($currentItem.Name)'") -ForegroundColor Cyan -NoNewline
        Write-Host (" to ") -NoNewline
        Write-Host ("'$($currentItem.Name -replace $patternToReplace, $replacementString)'") -ForegroundColor Cyan
      }

      Rename-Item -Path $currentItem.FullName -NewName $newDirectoryName -ErrorAction SilentlyContinue
      $currentItem = Get-Item -LiteralPath $newDirectoryName
    }
  }

  elseif ($currentItem -is [System.IO.FileInfo]) {
    $newFileName = $currentItem.FullName -replace $patternToReplace, $replacementString
    if ($currentItem.FullName -ne $newFileName) {
      if ($verboseOutput) {
        Write-Host ("Replace-Pattern: ") -NoNewline
        Write-Host ("'$($currentItem.FullName)'") -ForegroundColor Cyan -NoNewline
        Write-Host (": Renaming ") -NoNewline
        Write-Host ("'$($currentItem.Name)'") -ForegroundColor Cyan -NoNewline
        Write-Host (" to ") -NoNewline
        Write-Host ("'$($currentItem.Name -replace $patternToReplace, $replacementString)'") -ForegroundColor Cyan
      }

      Rename-Item -Path $currentItem.FullName -NewName $newFileName -ErrorAction SilentlyContinue
      $currentItem = Get-Item -LiteralPath $newFileName
    }

    $fileContent = Get-Content -Path $currentItem.FullName
    $newFileContent = $fileContent -replace $patternToReplace, $replacementString
    Set-Content -Path $currentItem.FullName -Value $newFileContent 

    if (($fileContent.Length -ne 0) -and $fileContent -ne $newFileContent -and $verboseOutput) {
      Write-Host ("Replace-Pattern: ") -NoNewline
      Write-Host ("'$($currentItem.FullName)'") -ForegroundColor Cyan -NoNewline
      Write-Host (": Replacing pattern ") -NoNewline
      Write-Host ("'$patternToReplace'") -ForegroundColor Green -NoNewline
      Write-Host (" in file content with ") -NoNewline
      Write-Host ("'$replacementString'") -ForegroundColor Green
    }
  }
}
