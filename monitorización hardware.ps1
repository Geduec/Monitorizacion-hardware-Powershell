## Código

Clear-Host
##Obtener info general del sistema
Write-Host "=== INFORMACIÓN DEL SISTEMA ===" -ForegroundColor Cyan
Get-ComputerInfo | Select-Object OsName, OsVersion, OsArchitecture | Format-Table -AutoSize

##Obtener info de la placa base
Write-Host "`n=== PLACA BASE ===" -ForegroundColor Cyan
Get-CimInstance Win32_BaseBoard | Format-Table -AutoSize

##Obtener info del CPU
Write-Host "`n=== CPU ===" -ForegroundColor Cyan
Get-CimInstance -ClassName Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed, L2CacheSize, L3CacheSize | Format-Table -AutoSize

##Obtener info de la RAM
Write-Host "`n=== MEMORIA RAM ===" -ForegroundColor Cyan
Get-CimInstance Win32_ComputerSystem | 
Select-Object @{Name="RAM_Total_GB";Expression={[math]::round($_.TotalPhysicalMemory/1GB,2)}} |
Format-Table -AutoSize

##Estado del disco
Write-Host "`n=== DISCO ===" -ForegroundColor Cyan

Write-Host "`n-- Salud del disco --" -ForegroundColor Yellow
Get-PhysicalDisk | 
Get-StorageReliabilityCounter | 
Select-Object DeviceId, ReadErrorsTotal, Temperature | 
Format-Table -AutoSize

Write-Host "`n-- Uso del disco --" -ForegroundColor Yellow
Get-CimInstance Win32_LogicalDisk | 
Where-Object { $_.DriveType -eq 3 } |
Select-Object DeviceID, 
@{Name="Total(GB)";Expression={[math]::round($_.Size/1GB,2)}}, 
@{Name="Libre(GB)";Expression={[math]::round($_.FreeSpace/1GB,2)}},
@{Name="Usado(GB)";Expression={[math]::round(($_.Size - $_.FreeSpace)/1GB,2)}} |
Format-Table -AutoSize

##Numero de serie BIOS
Write-Host "`n=== BIOS ===" -ForegroundColor Cyan
Get-CimInstance Win32_BIOS | Select-Object SerialNumber | Format-Table -AutoSize

##Obtener info de la GPU
Write-Host "`n=== GPU ===" -ForegroundColor Cyan
Get-CimInstance Win32_VideoController | Select-Object Name, VideoProcessor, AdapterRAM | Format-Table -AutoSize

##Dispositivos de entrada 
Write-Host "`n=== DISPOSITIVOS DE ENTRADA ===" -ForegroundColor Cyan
Get-PnpDevice -Class Mouse, Keyboard -PresentOnly | Format-Table -AutoSize

##Dispositivos de salida
Write-Host "`n=== DISPOSITIVOS DE SALIDA ===" -ForegroundColor Cyan
Get-PnpDevice | Where-Object {
    $_.Class -in @('Monitor','Printer','Media')
} | Select-Object Class, FriendlyName, Status | Format-Table -AutoSize

##Detectar dispositivos con problemas
Write-Host "`n=== ERRORES DEL SISTEMA ===" -ForegroundColor Cyan
$errores = Get-PnpDevice | Where-Object { $_.Status -eq 'Error' }

if ($errores) {
    Write-Host "Dispositivos con errores detectados:" -ForegroundColor Red
    $errores | Select-Object Class, FriendlyName | Format-Table -AutoSize
} else {
    Write-Host "Dispositivos sin errores" -ForegroundColor Green
}

##Tarjetas de red
Write-Host "`n=== RED ===" -ForegroundColor Cyan
Get-CimInstance Win32_NetworkAdapter | 
Where-Object { $_.NetEnabled -eq $true } |
Select-Object Name, MACAddress, Speed |
Format-Table -AutoSize