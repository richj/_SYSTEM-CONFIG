$temp1 = split-path -Parent $MyInvocation.PSCommandPath


$temp2 = $(convert-path -path "$thisPath\..") + "\_HOSTS";

$props = @{
    thisPath    =  $temp1;
    startpath   =  $temp2;
    targetPath  = "$startpath\$hostname\STARTUP";
    dockedPath  = "$startpath\$hostname\STARTUP-DOCKED";
    appDataPath = "$startpath\$hostname\APPDATA";
    archivePath = "$startpath\$hostname\ARCHIVE"
    }