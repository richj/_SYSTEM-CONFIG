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
	    $cloudPath  = "D:\STRATUS\GDRIVE",
        $hostPath   = "$cloudPath\_SYSTEM\_HOSTS\",
	    $myProfile  = $env:USERPROFILE,
        $hostName   = $env:COMPUTERNAME,
        $localInbox = "d:\_inbox",

        $myItemCollection= 
            @{
                "!-INBOX-!" = "D:\STRATUS\GDrive\!-INBOX-!";
                "Apps" = "d:\STRATUS\GDrive\Apps";
                "Documents" = "C:\users\rich\Documents";
                "NOTES" = "D:\STRATUS\GDrive\NOTES";
                "SCRATCH" = "D:\STRATUS\GDrive\SCRATCH_WORKSPACE";
                "_inbox" = "d:\_inbox";
                "_SYSTEM" = "d:\STRATUS\GDrive\_SYSTEM"
            },
	    $myProfileCollection = 
	    @{
	        "bin"		= "_SYSTEM\BIN";
    	    "Downloads" = "_INBOX";
	    }
    )

    #setup Directories 
    new-item -path "D:\_inbox" -ItemType "directory" -force -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true) | out-null 
    new-item -path "$hostPath\$hostName" -ItemType "directory" -force -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true) | out-null

    make-junctionSet -sourcePath $cloudPath -targetPath $myPath -collection $myItemCollection -wipe -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
	make-profileLinks -collection $myProfileCollection -path $myPath -targetPath $myProfile -sourcePath $myPath
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

    write-verbose "running wipe on $inPath"

	foreach($file in (get-childitem -path $inPath))
	{
		if((Test-ReparsePoint($file.fullname)))
		{
            Write-Verbose "removing Junction $($file.name)"
			remove-reparsepoint -Path $file.Name
		}
        else
        {
            Write-Verbose "removing actual path $file.name"
		    remove-item -Force -Recurse $file.name
        }
	}
write-verbose "breakpoint"
}

function make-junctionSet
{
    [CmdletBinding()]
	param ( 
            [string]$targetPath, 
            [string]$sourcePath,
            [hashtable]$collection,
            [switch]$wipe=$false
          )
	if((Test-Path $targetPath) -AND ($wipe))
	{
		wipedir -inPath $targetPath -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
	}

	if(!(Test-Path $targetPath))
    {
        new-item -path $targetPath -ItemType "directory" -force -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true) | out-null 
   	} 

    if(Test-Path $targetPath)
    { 
	    foreach ($h in $collection.GetEnumerator()) 
	    {
            Write-Verbose "Making $targetPath junction for $($h.Name) to $($h.value)"
            if($h.value.tostring().indexOf(":") -gt 0)
            {
                $source = $h.value.ToString()
            } 
            else
            {
	    	    $source = "$sourcePath\$($h.value)"
            }

            $target = "$targetPath\$($h.Name)"
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
    else
    {
        Write-Warning -Message "$targetPath does not exist - skipping"
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
    $fullCommand = "cmd.exe $myParam"
    write-verbose -Message "running $fullCommand"
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





#endregion


main -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)