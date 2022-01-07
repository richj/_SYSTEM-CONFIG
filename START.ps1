#Assumes Powershell 3.0

<# START LOADER
    
    NOTES:
    9/22/2015     Added Notes



    TODO:

    PRE-DEPLOY




    FUTURE RELEASES

        ********************CODE RELATED 
        version check all components, cmdlets etc - find version checking tool
        redo functions as advanced functions

        *******************FUNCTIONALITY
        Check to see if process is running before re-launching
#>


#region Functions

function main
{
    [CmdletBinding()]
    Param
    (
        # hostname help description
        [Parameter( Mandatory=$false, Position=0)]
        $hostname = $ENV:COMPUTERNAME,

        # docked help description
        [Parameter( Mandatory=$false, Position=1)]
        [boolean]
        $docked = $False
    )

    Write-Verbose "Initializing Variables"
    $startupDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $thisPath    = split-path $MyInvocation.PSCommandPath
    $thisFile    = Get-Info
    $startpath   =  $(convert-path -path "$thisPath\..") + "\_HOSTS"
    $targetPath  = "$startpath\$hostname\STARTUP"
    $dockedPath  = "$startpath\$hostname\STARTUP-DOCKED"
    $appDataPath = "$startpath\$hostname\APPDATA"
    $archivePath = "$startpath\$hostname\ARCHIVE"


    Write-Verbose "Creating or launching base directories"
    initialize-path -pathname $targetPath  -invoke $true
    initialize-path -pathname $dockedPath  -invoke $docked
    initialize-path -pathname $appDataPath -invoke $false
    initialize-path -pathname $archivePath -invoke $false

    #Create a startup shortcut to run the files in the startup directory if it doesn't exist
    if(!(test-Path -Path "$startupDir\$hostname.lnk"))
    {  
       write-verbose "Startup Link for $hostname not found.  Creating."
       make-shortcut -linkFile "$startupDir\$hostname" -targetFile 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -workingDir "$StartupDir" -arguments "-NonInteractive -windowStyle HIDDEN -FILE $thisFile" -windowStyle 7
    }
}

function initialize-path
{
    [CmdletBinding()]
    Param
    (
        [Parameter( Mandatory=$true,Position=0)]
        $pathname,
        [Parameter( Mandatory=$false,Position=1)]
        $invoke = $false
    )


    Write-Verbose "Testing $pathname"
    if(test-path -Path  $pathname)
    {
        if($invoke){
            Write-Verbose "Invoking $pathname"
            invoke-path $pathname -Verbose
        }
    } 
    else
    {
        Write-verbose "Couldn't find $pathname - Creating"
        new-item -path $pathname -ItemType "directory" | out-null
    }

}

function Invoke-path #good candidate to upgrade to advanced function
{
    [CmdletBinding()]
    Param
    (
        [Parameter( Mandatory=$true,Position=0)]
        $pathName
    )

    foreach($item in (Get-ChildItem (get-item $pathName)))
    {
        write-verbose "running $pathName\$item"  
	    &$item.FullName 
    }
} 

function Get-ScriptName{
    split-path $MyInvocation.PSCommandPath -Leaf
}

function Get-Info
{
    $MyInvocation.PSCommandPath
}

function make-shortcut
{
    [CmdletBinding()]
    Param
    (
        # linkFile help description
        [Parameter( Mandatory=$true, Position=0)]
        $linkFile,
        
        # targetFile help description
        [Parameter( Mandatory=$true, Position=1)]
        $targetFile,
         
        # workingDir help description
        [Parameter( Mandatory=$false, Position=2)]
        $workingDir,

        # arguments help description
        [Parameter( Mandatory=$false, Position=3)]
        $arguments,

        # windowStyle help description
        [Parameter( Mandatory=$false, Position=4)]
        $windowStyle = 1
    )

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$linkFile.lnk")
    $Shortcut.TargetPath = $targetfile
    $Shortcut.WorkingDirectory = $workingDir
    $Shortcut.windowstyle = $windowStyle
    $Shortcut.Arguments = $arguments
    $Shortcut.save()
}

#endregion


main -verbose
