# Monitorización-hardware-Powershell

Este es un pequeño proyecto que consiste en un script de PowerShell diseñado para monitorear el hardware de un sistema. El script recopila información sobre el uso de la CPU, la memoria RAM, el espacio en disco y otros componentes del hardware, lo que permite observar el rendimiento del sistema. Por el momento está en desarrollo ya que falta automatización no solo que muestre la información.

## Código

```powershell
##Obtener info general del sistema
Get-ComputerInfo | Select-Object OsName, OsVersion, OsArchitecture | Format-Table -AutoSize

##Obtener info de la placa base
Get-CimInstance Win32_BaseBoard | Format-Table -AutoSize

##Obtener info del CPU
Get-CimInstance -ClassName Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed, L2CacheSize, L3CacheSize | Format-Table -AutoSize

##Obtener info de la RAM
Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, Capacity, Speed | Format-Table -AutoSize

##Estado del disco
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object DeviceId, ReadErrorsTotal, Temperature | Format-Table -AutoSize

##Numero de serie BIOS
Get-CimInstance Win32_BIOS | Select-Object SerialNumber | Format-Table -AutoSize

##Dispositivos de entrada 
Get-PnpDevice -Class Mouse, Keyboard -PresentOnly | Format-Table -AutoSize

##Dispositivos de salida (audio)
Get-CimInstance Win32_SoundDevice | Select-Object Name, Status | Format-Table -AutoSize

##Obtener info de la GPU
Get-CimInstance Win32_VideoController | Select-Object Name, VideoProcessor, AdapterRAM | Format-Table -AutoSize

##Dispositivos de salida
Get-PnpDevice | Where-Object {
    $_.Class -in @('Monitor','Printer','Media')
} | Select-Object Class, FriendlyName, Status

##Detectar dispositivos con problemas
$errores = Get-PnpDevice | Where-Object { $_.Status -eq 'Error' }

if ($errores) {
    Write-Host "Dispositivos con errores detectados:" -ForegroundColor Red
    $errores | Select-Object Class, FriendlyName | Format-Table -AutoSize
} else {
    Write-Host "Dispositivos sin errores" -ForegroundColor Green
}

##Tarjetas de red
Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.NetEnabled -eq $true } |
Select-Object Name, MACAddress, Speed | Format-Table -AutoSize

##Memoria total del sistema
Get-CimInstance Win32_ComputerSystem | Select-Object @{Name="RAM_Total_GB";Expression={[math]::round($_.TotalPhysicalMemory/1GB,2)}} | Format-Table -AutoSize

##Uso de disco
Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } |
Select-Object DeviceID, 
@{Name="Total(GB)";Expression={[math]::round($_.Size/1GB,2)}}, 
@{Name="Libre(GB)";Expression={[math]::round($_.FreeSpace/1GB,2)}} |
Format-Table -AutoSize

```

### Información del sistema

```powershell
Get-ComputerInfo | Select-Object OsName, OsVersion, OsArchitecture | Format-Table -AutoSize
```

Este comando obtiene información básica del sistema operativo, como:

Nombre del sistema operativo
Versión
Arquitectura (32 o 64 bits)

---

### CPU

```powershell
Get-CimInstance -ClassName Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed | Format-Table -AutoSize
```

Permite obtener información del procesador:

Modelo del CPU
Número de núcleos
Frecuencia máxima


Esto es útil para evaluar el rendimiento del sistema.


---


### Memoria RAM

```powershell
Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, Capacity, Speed | Format-Table -AutoSize
```

Obtiene información de la memoria RAM:

Fabricante
Capacidad
Velocidad


---

### Disco


```powershell
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object DeviceId, ReadErrorsTotal, Temperature | Format-Table -AutoSize
```

Permite monitorizar el estado del disco:

Número de errores de lectura
Temperatura

---

###  Dispositivos de entrada y salida

```powershell
Get-PnpDevice -Class Mouse, Keyboard -PresentOnly | Format-Table -AutoSize
```
Este comando muestra los dispositivos de entrada (ratón y teclado) que están actualmente conectados al sistema.

```powershell
Get-PnpDevice | Where-Object {
    $_.Class -in @('Monitor','Printer','Media')
} | Select-Object Class, FriendlyName, Status
```
Este comando muestra los dispositivos de salida (monitor, impresora, medios) conectados al sistema, junto con su estado.

---

### Detección de errores

```powershell
$errores = Get-PnpDevice | Where-Object { $_.Status -eq 'Error' }

if ($errores) {
    Write-Host "Dispositivos con errores detectados:" -ForegroundColor Red
    $errores | Select-Object Class, FriendlyName | Format-Table -AutoSize
} else {
    Write-Host "Dispositivos sin errores" -ForegroundColor Green
}
```
Este comando permite identificar dispositivos que presentan fallos o no funcionan correctamente.


### Tarjetas de red

```powershell
Get-CimInstance Win32_NetworkAdapter | 
Where-Object { $_.NetEnabled -eq $true } |
Select-Object Name, MACAddress, Speed |
Format-Table -AutoSize
```
Este comando muestra las tarjetas de red activas, su dirección MAC y velocidad.

### Memoria total del sistema

```powershell
Get-CimInstance Win32_ComputerSystem | 
Select-Object @{Name="RAM_Total_GB";Expression={[math]::round($_.TotalPhysicalMemory/1GB,2)}} |
Format-Table -AutoSize
```
Este comando muestra la cantidad total de memoria RAM instalada en el sistema, convertida a gigabytes

### Uso de disco

```powershell
Get-CimInstance Win32_LogicalDisk | 
Where-Object { $_.DriveType -eq 3 } |
Select-Object DeviceID, 
@{Name="Total(GB)";Expression={[math]::round($_.Size/1GB,2)}}, 
@{Name="Libre(GB)";Expression={[math]::round($_.FreeSpace/1GB,2)}} |
Format-Table -AutoSize
```
Este comando muestra el uso de los discos duros, indicando el espacio total y el espacio libre.

Respecto a los buses sigo investigando