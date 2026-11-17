# POP-002 — Recuperar de Queda de Energia (WAL Corrompido)

**Objetivo:** recuperar a aplicação após desligamento abrupto.
**Quando usar:** quando o InfluxDB ficar em `Restarting` após queda
de energia, ou quando os logs mostrarem "corrupt WAL file".
**Tempo estimado:** 10 minutos.
**Responsável:** pessoa treinada.

---

## O que é o WAL e por que corrompe

O WAL (Write-Ahead Log) é o "rascunho" do InfluxDB. Antes de gravar
definitivamente, ele anota tudo nesse arquivo. Se a energia cair no
meio de uma anotação, o arquivo fica incompleto ("corrompido").

Na maioria das vezes, o InfluxDB se recupera sozinho ignorando o
arquivo corrompido. Mas, se houver uma colisão (o novo arquivo tem
o mesmo nome do corrompido), ele entra em loop e precisa de
intervenção manual.

---

## Como identificar o problema

Execute:

cd C:\usina-monitor
docker compose logs influxdb3-core --tail 50

Procure por mensagens como:

"ERROR invoking shutdown: a WAL file this process was writing already exists
WARN Skipping corrupt WAL file error=Invalid wal file identifier"


Se aparecer alguma delas e o contêiner estiver reiniciando,
siga este POP.

---

## Procedimento de recuperação

### Etapa 1 — Parar tudo

Execute o comando:
docker compose down

### Etapa 2 — Apagar apenas os WALs corrompidos

> ⚠️ Isso **não apaga** os dados históricos já gravados em Parquet.
> Apenas remove o "rascunho" que ficou corrompido.

No PowerShell:
Remove-Item -Path "C:\usina-monitor\influxdb3-data\node0\wal*" -Force

### Etapa 3 — Ajustar as permissões

O InfluxDB roda como usuário interno UID 1500. Após apagar arquivos,
as permissões da pasta podem ficar inconsistentes.

No PowerShell (uma linha só, com `^` como quebra de linha no CMD):
docker run --rm --user root ^
--mount type=bind,source="C:\usina-monitor\influxdb3-data",target=/mnt/data ^
influxdb:3.11-core ^
chown -R 1500:1500 /mnt/data

> **No PowerShell puro, use acento grave** (`` ` ``) em vez de `^`.
> Ou cole tudo em uma única linha.

### Etapa 4 — Subir novamente

docker compose up -d

### Etapa 5 — Aguardar e verificar

1. Aguarde 2 a 3 minutos.
2. Execute:

docker compose ps

## Se o problema persistir

Delete todo o conteúdo da pasta:
C:\Users\automacao.alianca\Desktop\Usina Aliança\Aplicação Grafana V2.0\influxdb3-data\node0\wal

## Como evitar que isso aconteça

1. **Instalar um nobreak (UPS)** no computador industrial. Um
   modelo de 600 VA é suficiente.
2. Sempre que possível, executar `docker compose down` antes de
   desligar o computador.
3. Configurar desligamento automático no Windows (avançado, só
   com nobreak USB).

---

## Como saber se deu certo

- [ ] `docker compose ps` mostra o InfluxDB como `Up (healthy)`
- [ ] Os logs não mostram mais mensagens de "corrupt WAL"
- [ ] O Node-RED volta a enviar dados normalmente
- [ ] O Grafana volta a exibir os dashboards
