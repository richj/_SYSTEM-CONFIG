$one = "\one\two"
$two = "d:\one\two"

function test-please
{
    param([string]$myString)

    if($myString.indexOf(":") -gt 0)
    {
        write-host "got a colon"
    }
}
