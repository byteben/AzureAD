<#
.Disclaimer
	This scripts is provided AS IS without warranty of any kind.
	In no event shall the author be liable for any damages whatsoever 
	(including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss)
	arising out of the use of or inability to use script,
	even if the Author has been advised of the possibility of such damages

.Author
	Ben Whitmore

.Created
	16/04/2019

.DESCRIPTION
 	Script to monitor and return large number of user devices in Azure AD. The default limit in Azure is 20 devices
 
.PARAMETER MaxResults
	Enter the Maximum number of results to be returned by the script    

.PARAMETER HighDeviceCount
    Enter the threshold for devices that you want to return
 
.EXAMPLE
	Get-UserDevices.ps1 -MaxResults 1000 -HighDeviceCount 15

#>

#Set Default parameters if none passed
Param (
	[Parameter(Mandatory = $False)]
	[string]$MaxResults = '1000',
	[Parameter(Mandatory = $False)]
	[string]$HighDeviceCount = '15'
)
#Initialize Array to hold users and number of devices
$DeviceCountHigh = @()

#Get list of users from AzureAD
$Users = Get-MsolUser -MaxResults $MaxResults | Select UserPrincipalName


ForEach ($User in $Users)
{
	#For each user returned, count their Registered Devices
	$Devices = Get-MsolDevice -RegisteredOwnerUPN $User.UserPrincipalName | Measure
	
	ForEach ($Device in $Devices)
	{
		#If the number of registered devices measured is high, create a new PSObject
		If ($Device.Count -ge $HighDeviceCount)
		{
			$DeviceCountMember = @()
			$DeviceCountMember = New-Object PSObject
			$DeviceCountMember | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $User.UserPrincipalName
			$DeviceCountMember | Add-Member -MemberType NoteProperty -Name 'DeviceCount' -Value $Device.Count
			$DeviceCountHigh += $DeviceCountMember
		}
	}
}
#Display Users with high number of devices
$DeviceCountHigh | Sort-Object DeviceCount -Descending