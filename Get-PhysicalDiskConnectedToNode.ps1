function Get-PhysicalDiskConnectedToNode{
    <#
    .AUTHOR
        Simon Jones - simon.jones@hackersploit.co.uk
    .SYNOPSIS
        This function will return what server a physical disk is connected to.
    .EXAMPLE
        Get-PhysicalDiskConnectedToNode -SerialNumber 123456789101112
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SerialNumber        

    )
    process {
        try {
               #Find the disk in the storage pool
               $oDisk = Get-PhysicalDisk | Where-Object SerialNumber -EQ $SerialNumber
                
               if($oDisk -eq $null)
               {
                    Write-Error 'No valid disk found'
               }
               else
               {

                   $oDiskConnected = Get-PhysicalDiskStorageNodeView -PhysicalDisk $oDisk | ? IsPhysicallyConnected -EQ $true
                   $sStorageNode = $oDiskConnected.StorageNodeObjectId.Split(":")[2]
                   $sNode = $sStorageNode.TrimEnd('"')
                   $oNode = Get-ClusterNode $sNode
                   
                   $output = @(
                       @{FriendleyName=$oDisk.FriendlyName;SerialNumber=$oDisk.SerialNumber;ConnectedTo=$oNode.Name}
                   ) | % {New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }
                   
                   $output | select FriendleyName, SerialNumber, ConnectedTo
                   
               }
           } 
           catch 
           {
           Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
       }
    }
}