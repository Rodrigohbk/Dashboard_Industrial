# atualizar-portproxy.ps1
$wslIp = (wsl -d docker-desktop -- ip addr show eth0 | Select-String "inet " | ForEach-Object {
    ($_ -split '\s+')[5] -split '/' | Select-Object -First 1
}).Trim()

if (-not $wslIp) {
    Write-Error "Não foi possível obter o IP do WSL2. Verifique se o Docker Desktop está rodando."
    exit 1
}

Write-Host "IP atual do WSL2: $wslIp" -ForegroundColor Cyan

# Remove regra antiga (ignora erro se não existir) e cria a nova
netsh interface portproxy delete v4tov4 listenport=3000 listenaddress=0.0.0.0 2>$null | Out-Null
netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=$wslIp

Write-Host "Portproxy atualizado com sucesso." -ForegroundColor Green
netsh interface portproxy show all