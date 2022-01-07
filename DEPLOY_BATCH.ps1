
    ###########################################################################
#
# NAME: DEPLOY_BATCH.PS1
#
# AUTHOR:  Rich Jackman (RCJ)
#
# COMMENT: Script to deploy batch service updates to the batch servers
#
# VERSION HISTORY: RCJ 0.1 5/7/15  RCJ
# 
###########################################################################




#CONSTANTS
#region ############################# CONSTANTS 

If (!(Test-Path -path variable:dir_SOURCE))	{Set-Variable 	-name dir_SOURCE 	-Option Constant -Value "E:\RM\DEPLOY"}
If (!(Test-Path -path variable:dir_LOGS))	{Set-Variable 	-name dir_LOGS 	    -Option Constant -Value "E:\RM\LOGS"}
If (!(Test-Path -path variable:dir_TEMP))	{Set-Variable 	-name dir_TEMP 		-Option Constant -Value "E:\RM\TEMP"}
If (!(Test-Path -path variable:dir_BACKUP))	{Set-Variable 	-name dir_BACKUP 	-Option Constant -Value "C:\RM\BACKUP"}
If (!(Test-Path -path variable:dir_APPS))	{Set-Variable 	-name dir_APPS		-Option Constant -Value "C:\Program Files\Pulte"}

#endregion

#FUNCTIONS
#region ############################# FUNCTIONS 

function Expand-ZIPFile($file, $destination){
	$shell = new-object -com shell.application
	$zip = $shell.NameSpace($file)
	foreach($item in $zip.items())
	{
		$shell.Namespace($destination).copyhere($item)
	}
}

#ERROR HANDLING FUNCTION
function send-error{
    <#
        .Synopsis
            Error Handling function
        .DESCRIPTION
            This function will be called when an error is trapped or thrown and will handle the logging of the error, displaying of any text and if necessary exiting the program
        .EXAMPLE
            process-error -type "Fatal" -text "Encountered a problem: execution halted"
        .EXAMPLE
            process-error -type "warning" -text "No backup exists.  Creating first backup"
    #>

    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$type = "Warning",

		[Parameter(Position=1)]
		[ValidateNotNull()]
		[System.String]
		$Text = "Warning"
    )
        
    Begin
    {
    }
    Process
    {
        try 
        {
		    if ($type.ToUpper() -eq "FATAL")
		    {
			    Write-Host -object "ERROR: $Text"
			    exit 21
		    }
	    }
	    catch {
		    throw
	    }

    }
    End
    {
    }
}



#endregion

######################      Main Screen Turn On      ######################
#Let's Verify some things
$TEST = Test-Path -Path "$dir_SOURCE"
If (!(Test-Path -Path $dir_SOURCE)) {send-error -type fatal -text "Source directory not found"}

#BIGLOOP
#region bigLoop
##########################################  START BIG LOOP - go through all files in FILE-SOURCE
$files = Get-ChildItem -path $dir_SOURCE
$files.Length

ForEach ($file in $files)
{
	Write-Host -object $file.fullname
}
###### GET FILE SECTION
#Get Filename
#Lookup Filename in database/file/xml to get attributes
#If file doesn't exist in database, throw error
#If it DOES exist, create object and populate properties with DB fields

###### VERIFICATION SESSION
#Double check object.directory property against file system directory - error if wrong 
#Double check object.serviceName property against services - error if wrong

###### PROCESS SERVICE
#EXTRACT FILE to temp directory
#Double check extracted directory against object.directory property - error if wrong (cleanup files)

#BACKUP existing files to BACKUP directory (overwrite) (trap errors)
#TURN OFF SERVICE (trap error)

#COPY new files to target directory (trap errors)

#TURN ON SERVICE (trap error - fatal- checkitout)

###### Cleanup & Prep session
#DELETE TEMP FILES (trap errors)
#Write out log entry - success

##########################################  END   BIG LOOP
#endregion