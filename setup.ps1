#
# setup.ps1
#
param(
	[string]$packageName,
	[string]$projectFolder = ".",
	[string]$placeHolder = "nothing"
)

function Main 
{
	if (!$packageName) 
	{
		$packageName = Read-Host "Please enter a package name (ex: SuperAwesomePackage, no abbreviations please) in PascalCase"
	}
	
	$slnFiles = Get-ChildItem -Path $projectFolder -Filter *.solutiontemplate
	foreach($sln in $slnFiles)
	{
		Rename-Item -path $sln.FullName -newName "$packageName.sln"
		Write-Host "Renamed " $sln.FullName " to $packageName.sln"
	}
	
	$include = @('*.cs', '*.sln', '*.csproj')
	$folders = Get-ChildItem -Path $projectFolder -Recurse  | sort @{expression = {$_.fullname.length}} -descending | ?{ $_.PSIsContainer }
	$check = $false

	foreach($folder in $folders) 
	{
		if ($folder.Name -match $placeHolder)
		{
			$oldFolderName = $folder.Name
			$newFolderName = $oldFolderName.Replace($placeHolder, $packageName)
			$newFolderPath = $folder.FullName.Replace($oldFolderName, $newFolderName)						
			Rename-Item -path $folder.FullName -newName $newFolderName
			Write-Host "Moved " $folder.FullName " to " $newFolderPath			
		}
	}

	$files = Get-ChildItem -Path $projectFolder -Recurse -Include $include

	foreach($file in $files) 
	{
		if ($file.FullName -notmatch '\\obj\\')
		{
		    Write-Host "Patching file: " $file.fullname    
			$content = Get-Content $file.fullname
			$newContent = $content.Replace($placeHolder, $packageName)

			if ($file.Name -match $placeHolder)
			{
				$oldFileName = $file.Name
				$newFileName = $oldFileName.Replace($placeHolder, $packageName)
				$newFilePath = $file.FullName.Replace($oldFileName, $newFileName)
				$newContent | Set-Content $newFilePath
				# delete old file
				Remove-Item -path $file.FullName

				Write-Host "Renamed " $file.FullName " to " $newFilePath

				$check = $true
			}
			else
			{
				$newContent | Set-Content $file.fullname
			}
		}
	}

	if(!$check) {
		Write-Host "$packageName failed!" -ForegroundColor Red
	}
	else {
		Write-Host "$packageName passed!" -foregroundcolor DarkGreen
	}
}

Main