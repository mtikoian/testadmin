[Object] $net = New-Object -com WScript.Network
$pass = "01000000d08c9ddf0115d1118c7a00c04fc297eb010000000dcaa3600ad120449bfe837962a22660000000000200000000001066000000010000200000009a2b5752021f4b5290de2ecb49b42fa860bc1255b5941f7f61b7f38724c5fab6000000000e80000000020000200000004b2f06439e93ca54b29467aa3a7f2bd296445254ab473ddc2597c64a896003d92000000092515a67b8a9b36859522dc1d3d302cc9e32de6309971153ab09e1fefd999bcf4000000007b8be2dabbfa43d03da9c6db8209e2e57830c49eeefc74dc42aabf9ac4532c55de59d9e32d81a3474c1c8929d99a7d1e1c86c3114e5c4fe04addf389e5ed840"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist "dbdom\SQLBackup", ($pass | ConvertTo-SecureString)
$net.MapNetworkDrive("R:", "\\192.168.1.99\SQLBackups", "true", $Cred.get_UserName(), $Cred.GetNetworkCredential().Password)

#$net.RemoveNetworkDrive("R:", $true, $true)