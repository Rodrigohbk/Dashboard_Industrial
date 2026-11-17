# Manual de Manutenção

Este documento explica como manter a aplicação em funcionamento
no dia a dia, incluindo operações básicas, resolução de problemas
e procedimentos de emergência.

---

## Operações básicas

### Ligar a aplicação

```bash
cd C:\usina-monitor
docker compose up -d

##O Docker sobe os 4 serviços na ordem correta:

- InfluxDB primeiro (espera ficar saudável)

- Node-RED, Grafana e Explorer depois

- Aguarde 1 a 3 minutos.


## Desligar a Aplicação

cd C:\usina-monitor
docker compose down

Os dados são preservados nas pastas de bind mount. Nada é perdido.


## Verificar se está tudo rodando

```bash
cd C:\usina-monitor
docker compose ps

Todos devem aparecer com status Up ou Up (healthy).


## Ver os logs de um serviço

```bash
cd C:\usina-monitor
docker compose logs <nome> --tail 50

Substitua <nome> por: influxdb3-core, nodered, grafana ou influxdb3-explorer.

Para ver em tempo real (atualiza conforme saem mensagens):

```bash
cd C:\usina-monitor
docker compose logs <nome> --tail 50

Substitua <nome> por: influxdb3-core, nodered, grafana ou influxdb3-explorer.


### Procedimentos de emergência
## Após queda de energia
Cenário: o computador desligou sem aviso.

Ação:

Ao religar, aguarde 3 minutos sem fazer nada. O Docker
iniciará automaticamente e o InfluxDB recuperará o WAL
(registro de operações pendentes).

Verifique o status:
```bash
cd C:\usina-monitor
docker compose ps

Se todos estiverem Up (healthy), está tudo certo.

Se algum estiver reiniciando em loop, ver POP-002

### Serviço que não sabe

Cenário: um dos contêineres fica em Restarting.

Ação:

Verifique os logs:

bash
docker compose logs <nome> --tail 100
Procure por ERROR, panic, Permission denied, corrupt.

Consulte o POP correspondente em docs/POPs/.

### Acesso ao Grafana mostra erro

Cenário: Grafana abre, mas os painéis dizem "no data".

Ação:

1. Verifique se o InfluxDB está saudável:

bash
docker compose ps

2. Teste a conexão do Grafana com o InfluxDB:

Abra http://localhost:3000

Vá em Connections → Data sources → InfluxDB Usina

Clique em "Save & test"

3. Se falhar, reinicie o Grafana:

bash
docker compose restart grafana


Manutenção preventiva
Semanal
□ Verificar espaço em disco disponível (C:\usina-monitor\)
□ Verificar se os logs não têm erros repetitivos
□ Confirmar que os dashboards do Grafana atualizam
Mensal
□ Fazer backup manual das pastas de dados
□ Atualizar a tabela de variáveis em MAPA_VARIAVEIS.md
□ Revisar senhas e tokens (ver seção de segurança abaixo)
Anual
□ Comparar tamanho das pastas com o limite do disco
□ Revisar a política de retenção de dados (atualmente 2 anos)
□ Atualizar imagens Docker (com cuidado e teste prévio)


Segurança
Senhas e tokens
Item					Onde está					Como trocar
Senha do Grafana			docker-compose.yml (GF_SECURITY_ADMIN_PASSWORD)	Editar arquivo, docker compose up -d
Token do InfluxDB			Nos nós do Node-RED				Ver POP-003
Chave de credenciais do Node-RED	settings.js + docker-compose.yml		NÃO TROCAR sem orientação

### Trocar senha do Grafana

1. Abra docker-compose.yml

2. Localize GF_SECURITY_ADMIN_PASSWORD=usina@2025

3. Substitua pela senha nova

4. docker compose up -d grafana

A troca de senha é feita só na primeira vez que o contêiner
sobe. Depois disso, a senha fica gravada na pasta grafana-data/.
Para forçar, é necessário apagar a pasta (o que perde dashboards).

### Manutenção corretiva (avaliações futuras)
Estes procedimentos ainda não precisam ser feitos, mas ficam
registrados para quando forem necessários:

## Atualizar uma imagem Docker
1. Fazer backup completo.

2. Anotar a versão atual.

3. Editar a tag no docker-compose.yml.

4. docker compose pull

5. docker compose up -d

6. Testar tudo.

7. Se falhar, voltar à tag anterior e reportar.

### Migrar para outro computador

1. docker compose down no computador antigo.

2. Copiar C:\usina-monitor\ inteiro (incluindo bind mounts).

3. Instalar Docker Desktop no novo computador.

4. Copiar a pasta para o mesmo caminho.

5. docker compose up -d.

### POPs disponíveis

POP-001 — Ligar/desligar a aplicação

POP-002 — Recuperar de WAL corrompido

POP-003 — Trocar token do InfluxDB

POP-004 — Configurar backup automático

(Serão criados na Fase 4)

Última atualização: 30/09/2026
Responsável: [seu nome]