param (
    [string]$rootDirectory,
    [string]$patternToReplace,
    [string]$replacementString
)

if (-not $rootDirectory -or -not $patternToReplace -or -not $replacementString) {
    Write-Host @"
DESCRIPTION
    Replace pattern in files, the file content and directories recursively.

PARAMETERS
    -rootDirectory      Specifies the root directory to start the replacement process.
    -patternToReplace   Specifies the pattern to be replaced in directory names, file names, and file contents.
    -replacementString  Specifies the string that will replace the specified pattern.

EXAMPLE
    Replace-Pattern -rootDirectory "C:\Example" -patternToReplace "PATTERN" -replacementString "Replacement"
"@
    Exit
}

Get-ChildItem -Path $rootDirectory -Recurse | ForEach-Object {
  $currentItem = $_ 

  if ($currentItem -is [System.IO.DirectoryInfo]) {
    $newDirectoryName = $currentItem.FullName -replace $patternToReplace, $replacementString
    if ($currentItem.FullName -ne $newDirectoryName) {
      Rename-Item -Path $currentItem.FullName -NewName $newDirectoryName -ErrorAction SilentlyContinue
      $currentItem = Get-Item -LiteralPath $newDirectoryName
    }
  }

  elseif ($currentItem -is [System.IO.FileInfo]) {
    $newFileName = $currentItem.FullName -replace $patternToReplace, $replacementString
    if ($currentItem.FullName -ne $newFileName) {
      Rename-Item -Path $currentItem.FullName -NewName $newFileName -ErrorAction SilentlyContinue
      $currentItem = Get-Item -LiteralPath $newFileName
    }

    $fileContent = Get-Content -Path $currentItem.FullName
    $newFileContent = $fileContent -replace $patternToReplace, $replacementString
    Set-Content -Path $currentItem.FullName -Value $newFileContent
  }
}
