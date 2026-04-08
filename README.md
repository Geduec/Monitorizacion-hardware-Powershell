# Monitorización-hardware-Powershell

Este es un pequeño proyecto que consiste en un script de PowerShell diseñado para monitorear el hardware de un sistema. El script recopila información sobre el uso de la CPU, la memoria RAM, el espacio en disco y otros componentes del hardware, lo que permite observar el rendimiento del sistema. Por el momento está en desarrollo ya que falta automatización no solo que muestre la información.

### Información del sistema

```powershell
Write-Host "=== INFORMACIÓN DEL SISTEMA ===" -ForegroundColor Cyan
Get-ComputerInfo | Select-Object OsName, OsVersion, OsArchitecture | Format-Table -AutoSize
```

Este comando obtiene información básica del sistema operativo, como:

Nombre del sistema operativo
Versión
Arquitectura (32 o 64 bits)

<img src="/img/info_sistema.png" alt="Información del sistema" width="600">

---

### Placa base

```powershell
Write-Host "=== PLACA BASE ===" -ForegroundColor Cyan
Get-CimInstance Win32_BaseBoard | Format-Table -AutoSize
```
Permite obtener información de la placa base, como:

<img src="/img/placa_base.png" alt="Información de la placa base" width="600">


---

### CPU

```powershell
Write-Host "=== CPU ===" -ForegroundColor Cyan
Get-CimInstance -ClassName Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed | Format-Table -AutoSize
```

Permite obtener información del procesador:

Modelo del CPU
Número de núcleos
Frecuencia máxima

<img src="/img/cpu.png" alt="Información del CPU" width="600">>


---


### Memoria RAM

```powershell
Write-Host "=== MEMORIA RAM ===" -ForegroundColor Cyan
Get-CimInstance Win32_ComputerSystem | 
Select-Object @{Name="RAM_Total_GB";Expression={[math]::round($_.TotalPhysicalMemory/1GB,2)}} |
Format-Table -AutoSize
```
Este comando muestra la cantidad total de memoria RAM instalada en el sistema, convertida a gigabytes

<img src="/img/ram.png" alt="Información de la RAM" width="600">

---

### Disco


```powershell
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
```
Este comando muestra tanto la salud del disco (número de errores de lectura y temperatura) como el uso del disco (capacidad total, espacio libre y espacio usado).

<img src="/img/disco.png" alt="Información del disco" width="600">

En este caso la temperatura no se visualiza debido a que es un entorno virtualizado.

---

### BIOS

```powershell
Write-Host "=== BIOS ===" -ForegroundColor Cyan
Get-CimInstance Win32_BIOS | Select-Object SerialNumber | Format-Table -AutoSize
```
Este comando muestra el número de serie del BIOS

<img src="/img/bios.png" alt="Número de serie del BIOS" width="600">


---

### GPU

```powershell
Write-Host "=== GPU ===" -ForegroundColor Cyan
Get-CimInstance Win32_VideoController | Select-Object Name, VideoProcessor, AdapterRAM | Format-Table -AutoSize
```
Permite obtener información de la tarjeta gráfica:

<img src="/img/gpu.png" alt="Información de la GPU" width="600">


---


###  Dispositivos de entrada y salida

```powershell
Write-Host "=== DISPOSITIVOS DE ENTRADA ===" -ForegroundColor Cyan
Get-PnpDevice -Class Mouse, Keyboard -PresentOnly | Format-Table -AutoSize
```
Este comando muestra los dispositivos de entrada (ratón y teclado) que están actualmente conectados al sistema.

```powershell
Write-Host "`n=== DISPOSITIVOS DE SALIDA ===" -ForegroundColor Cyan
Get-PnpDevice | Where-Object {
    $_.Class -in @('Monitor','Printer','Media')
} | Select-Object Class, FriendlyName, Status | Format-Table -AutoSize

```
Este comando muestra los dispositivos de salida conectados al sistema, junto con su estado.

<img src="/img/dispositivos_entrada_salida.png" alt="Dispositivos de entrada y salida" width="600">


---

### Detección de errores

```powershell
Write-Host "=== ERRORES DEL SISTEMA ===" -ForegroundColor Cyan
$errores = Get-PnpDevice | Where-Object { $_.Status -eq 'Error' }

if ($errores) {
    Write-Host "Dispositivos con errores detectados:" -ForegroundColor Red
    $errores | Select-Object Class, FriendlyName | Format-Table -AutoSize
} else {
    Write-Host "Dispositivos sin errores" -ForegroundColor Green
}
```
Este comando permite identificar dispositivos que presentan fallos o no funcionan correctamente.

<img src="/img/errores.png" alt="Detección de errores" width="600">


---


### Tarjetas de red

```powershell
Write-Host "=== RED ===" -ForegroundColor Cyan
Get-CimInstance Win32_NetworkAdapter | 
Where-Object { $_.NetEnabled -eq $true } |
Select-Object Name, MACAddress, Speed |
Format-Table -AutoSize
```
Este comando muestra las tarjetas de red activas, su dirección MAC y velocidad.

<img src="/img/red.png" alt="Información de la red" width="600">


---

Respecto a los buses sigo investigando.