[cmdletbinding()]
param()



#region Functions

function main()
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
 
    Param ()
	    $myPath     = 'D:\MYNE'
	    $cloudPath  = 'D:\STRATUS\G'
        $hostPath   = "$cloudPath\_SYSTEM\_HOSTS\"
	    $myProfile  = $env:USERPROFILE
        $hostName   = $env:COMPUTERNAME
        $localInbox = 'd:\_inbox'
        $myItemCollection= 
            @{
                '!-INBOX-!' = 'D:\STRATUS\G\!-INBOX-!';
                'Apps' = 'd:\STRATUS\G\Apps';
                'Documents' = '%USERPROFILE%\Documents';
                'NOTES' = 'D:\STRATUS\G\NOTES';
                'SCRATCH' = 'D:\STRATUS\G\SCRATCH_WORKSPACE';
                '_inbox' = 'd:\_inbox';
                '_SYSTEM' = 'd:\STRATUS\G\_SYSTEM'
            }
        $myLOCALCollection= 
            @{
                'DeploymentTools' = 'D:\STRATUS\LOCAL\DeploymentTools';
                'DevLibrary' = 'D:\STRATUS\LOCAL\DEV-Library';
                'DOCS' = 'D:\STRATUS\LOCAL\DOCS';
                'Local' = 'D:\STRATUS\LOCAL';
                'MEDIA' = 'D:\STRATUS\LOCAL\MEDIA';
                'PROJECTS' = 'D:\STRATUS\LOCAL\PROJECTS'
            }
	    $myProfileCollection = 
	    @{
	        'bin'		= '_SYSTEM\BIN';
    	    'Downloads' = '_INBOX';
	    }
 

    #setup Directories 
 
    # if(!test-path -path - new-item -path "D:\_inbox" -ItemType "directory" -force -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true) | out-null 
    # new-item -path "$hostPath\$hostName" -ItemType "directory" -force -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true) | out-null
    make-path -path 'D:\_inbox'
    make-path -path "$hostPath\$hostName"
    make-myne -cloudPath $cloudPath -collection $myItemCollection -path $myPath -Verbose:($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent -eq $true)
    make-myne -cloudPath 'D:\STRATUS\LOCAL' -collection $myLOCALCollection -path $myPath -Verbose:($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent -eq $true)
    make-profileLinks -collection $myProfileCollection -path $myPath -sourcePath $myPath
}

#        FUNCTIONS
#---------------------------------------------------------------------------------------

function make-path 
{
    param
    (
        [Parameter(Mandatory=$True)]
        [string]$path
    )

    if(!(test-path -path $path)){

             new-item -path $path -ItemType 'directory' -Force 
   }
}

#see if an item is a JUNCTION
function Test-ReparsePoint([string]$path) {
<#if($file.Attributes -eq 'Directory')
  {
    write-host "-----------------------------$file--------------------------------"
  }
  else
  {
    write-host $file.name
  }

#>   
  try {
    
    $file = Get-Item $path -Force -ea 0 -Verbose:($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent -eq $true)
    return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
      
   
  } 
  catch 
  {
    write-verbose -message "Caught an exception"
    write-verbose -message $Error[0].Exception
    continue
  }

}


if($file.name -eq 'c[Conflict 1].vim')
{
  $global:tester = $file
  BREAK

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


		make-path $path	| out-null
        
		foreach ($h in $collection.GetEnumerator()) 
		{
            Write-Verbose "Making MYNE junction for $($h.Name) to $($h.value)"
            if($h.value.tostring().indexOf(':') -gt 0)
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
                make-junction -target $target -source $source -Verbose:($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent -eq $true)
            }
            else
            {
                Write-Verbose -Message "Path $source does not exist.  Skipping."
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

  if(Test-Path $target)
	{
		wipedir -inPath $target -Verbose:($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent -eq $true)
	}

    $myParam = "/c mklink /j $target $source"

    &cmd.exe $myParam | out-null
}

function make-profileLinks
{
    [CmdletBinding()]
	param ( 
            [string]$path, 
            [hashtable]$collection, 
            [string]$targetPath = '%USERPROFILE%',
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
		if(!(test-path -path "$sourcePath\$($h.value)")){$myParam = "/c mklink /j $targetPath\$($h.Name) $sourcePath\$($h.value)"}
	}
}





#endregion


main -Verbose:($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent -eq $true)