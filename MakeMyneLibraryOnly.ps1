[cmdletbinding()]
param()



#region Functions

function main()
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
 
    Param
    (
	    $myPath     = "D:\MYNE",
	    $cloudPath  = "D:\STRATUS\LOCAL",
        $myItemCollection= 
            @{
            "DeploymentTools" = "DeploymentTools";
            "DEV-Library" = "Dev-Library";
            "Local" = $cloudPath;
            "DOCS"           = "DOCS";
            "MEDIA" = "MEDIA";
            "Install" = "Install";
            "Projects"       = "Projects";
            "Projects_Code"  = "Projects_Code"
            }
    )

    make-myne -cloudPath $cloudPath -collection $myItemCollection -path $myPath -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

}

#        FUNCTIONS
#---------------------------------------------------------------------------------------


#see if an item is a JUNCTION
function Test-ReparsePoint([string]$path) {
  $file = Get-Item $path -Force -ea 0 -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}



#A recursive directory delete that doesn't follow JUNCTIONS 
#to delete their contents, it merely removes their reference 
function wipedir
{
    [CmdletBinding()]
    param([string]$inPath)


	foreach($file in (get-childitem -path $inPath -Recurse -ErrorAction SilentlyContinue))
	{
		if((Test-ReparsePoint($file.fullname)))
		{
            Write-Verbose "removing $($file.fullname)"
			cmd /c rmdir $file.fullname 
		}
	}
	if(!(Test-ReparsePoint($inPath)))
	{	
        Write-Verbose "removing actual path $inPath"
		remove-item -Force -Recurse $inPath
	}
	else
	{
        Write-Verbose "removing reparse path $inPath"
		cmd /c rmdir /s /q $inPath 
	}
}

function make-myne
{
    [CmdletBinding()]
	param ( 
            [string]$path, 
            [hashtable]$collection, 
            [string]$cloudPath 
          )
	if(Test-Path $path)
	{
		wipedir -inPath $path -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
	}

	if(!(Test-Path $path))
    {
		mkdir $path	| out-null
        
		foreach ($h in $collection.GetEnumerator()) 
		{
            Write-Verbose "Making MYNE junction for $($h.Name) to $($h.value)"
            if($h.value.tostring().indexOf(":") -gt 0)
            {
                $source = $h.value.ToString()
            } 
            else
            {
			    $source = "$cloudPath\$($h.value)"
            }
            $target = "$path\$($h.Name)"
            Write-Verbose "Using source:$source and target:$target"
            if(test-path -Path $source)
            {
                make-junction -target $target -source $source -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
            }
            else
            {
                Write-Verbose -Message "Path $source does not exist.  Skipping."
            }
		}	
	} 
}

function make-junction
{
    [CmdletBinding()]
	param ( 
        [string]$source, 
        [string]$target 
    )
    $myParam = "/c mklink /j $target $source"
    &cmd.exe $myParam | out-null
}

function make-profileLinks
{
    [CmdletBinding()]
	param ( 
            [string]$path, 
            [hashtable]$collection, 
            [string]$targetPath,
            [string]$sourcePath
          )

	foreach ($h in $collection.GetEnumerator()) 
	{	
		$profileItemPath="$targetPath\$($h.Name)"
		if(Test-Path -Path $profileItemPath)
		{
			wipedir($profileItemPath);
		}
        Write-Verbose "Making Profile junction for $($h.Name)"
		$myParam = "/c mklink /j $targetPath\$($h.Name) $sourcePath\$($h.value)"
		&cmd.exe $myParam
	}
}





#endregion


main -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)