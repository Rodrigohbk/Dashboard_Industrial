# Monitoramento do Processo Produtivo — Usina VHP

Aplicação de coleta, armazenamento e visualização dos dados de processo
da usina, rodando em Docker no computador industrial da sala de controle.

**Status atual:** em desenvolvimento (fase de mapeamento de variáveis)
**Última atualização:** 30/09/2026

---

## 📖 Índice

1. [O que essa aplicação faz](#o-que-essa-aplicação-faz)
2. [Para quem está chegando agora](#para-quem-está-chegando-agora)
3. [Pré-requisitos](#pré-requisitos)
4. [Início rápido](#início-rápido)
5. [Comandos do dia a dia](#comandos-do-dia-a-dia)
6. [Acessos e credenciais](#acessos-e-credenciais)
7. [Estrutura de pastas](#estrutura-de-pastas)
8. [Solução rápida de problemas](#solução-rápida-de-problemas)
9. [Documentação detalhada](#documentação-detalhada)
10. [Histórico de mudanças](#histórico-de-mudanças)
11. [Contato](#contato)

---

## O que essa aplicação faz

1. **Lê** dados de 5 CLPs da usina via Modbus/TCP (protocolo industrial).
2. **Armazena** os dados com data e hora em um banco de dados
   (InfluxDB 3 Core), com retenção de 2 anos.
3. **Exibe** gráficos e painéis no Grafana, acessíveis na rede local e,
   futuramente, de forma remota.

### Fluxo resumido

CLP (Modbus/TCP) → Node-RED → InfluxDB 3 Core → Grafana → Tela


---

## Para quem está chegando agora

Se você **nunca mexeu** com Docker, Node-RED ou InfluxDB, siga esta ordem:

1. Leia o **[GLOSSARIO.md](docs/GLOSSARIO.md)** — explica os termos técnicos
   em linguagem simples, sem jargão. Feito especialmente para a equipe
   de elétrica e manutenção.
2. Leia o **[ARQUITETURA.md](docs/ARQUITETURA.md)** — mostra o desenho da
   aplicação e o papel de cada componente.
3. Leia o **[MANUTENCAO.md](docs/MANUTENCAO.md)** — ensina a ligar, desligar
   e resolver os problemas mais comuns.
4. Consulte os **[POPs](docs/POPs/)** — procedimentos operacionais passo a
   passo, no formato "se acontecer X, faça Y".

---

## Pré-requisitos

Para a aplicação rodar, é necessário:

| Item | Requisito mínimo | Observação |
|---|---|---|
| **Sistema operacional** | Windows 10 ou superior | Testado em Windows 10 |
| **Docker Desktop** | Versão mais recente | Com backend WSL2 ativado |
| **Espaço em disco** | ~10 GB livres | Cresce conforme os dados acumulam |
| **Memória RAM** | 4 GB disponíveis | Recomendado 8 GB |
| **Rede** | Acesso à rede dos CLPs | Ex: 192.168.6.0/24 |
| **Nobreak (UPS)** | Recomendado | Evita corrupção de dados em quedas |

**Docker Desktop deve estar rodando** antes de executar qualquer comando
abaixo. Ele pode ser configurado para iniciar automaticamente com o Windows
(ver `MANUTENCAO.md`).

---

## Início rápido

Abra o **PowerShell** ou **CMD** e execute:

```bash
cd C:\usina-monitor
docker compose up -d

## Após 1 a 2 minutos, os serviços estarão disponíveis. Para verificar:

```bash
cd C:\usina-monitor
docker compose ps

## Todos os contêineres devem aparecer com status Up ou Up (healthy).

## Para desligar tudo:

```bash
cd C:\usina-monitor
docker compose down

## Comandos do dia a dia


O que você quer fazer			Comando

Ligar a aplicação			docker compose up -d
Desligar a aplicação			docker compose down
Ver se está tudo rodando		docker compose ps
Reiniciar um serviço			docker compose restart <nome>
Ver logs de um serviço			docker compose logs <nome> --tail 50
Ver logs em tempo real			docker compose logs -f <nome>
Validar o docker-compose.yml		docker compose config
Atualizar uma imagem			docker compose pull && docker compose up -d

## Substitua <nome> por um dos quatro serviços:
influxdb3-core, nodered, grafana, influxdb3-explorer.


## Acessos e credenciais

Serviço	Endereço		Usuário	Senha

Node-RED			http://localhost:1880	—	—
Grafana				http://localhost:3000	admin	usina@2025
InfluxDB Explorer		http://localhost:8080	—	—
InfluxDB API			http://localhost:8181	—	token de admin
Token do InfluxDB: 		gerado uma única vez e armazenado em local seguro. 

Se perdido, um novo token pode ser gerado com:
"docker exec -it influxdb3-core influxdb3 create token --admin"

## Estrutura de pastas
Pasta			O que tem dentro			Backup necessário?
docs/			Documentação deste projeto		✅ Sim (está no Git)
scripts/		Scripts de automação e backup		✅ Sim (está no Git)
nodered-data/		Fluxos e credenciais do Node-RED	✅ Sim
influxdb3-data/		Todos os dados históricos		✅ Sim
influxdb3-plugins/	Plugins Python do InfluxDB		✅ Sim
grafana-data/		Dashboards e conexões do Grafana	✅ Sim
explorer-db/		Configurações do InfluxDB Explorer	✅ Sim


## Solução rápida de problemas
Sintoma							Causa provável				Solução rápida
docker compose up reclama que a porta está em uso	Outro programa usando a mesma porta	netstat -ano | findstr :3000 (troque 3000 pela porta)
Nenhum contêiner sobe					Docker Desktop não está rodando	Abrir Docker Desktop, aguardar 1 min, tentar novamente
InfluxDB reinicia em loop				WAL corrompido após queda de energia	Ver docs/POPs/POP-002-recuperar-wal.md
Node-RED perdeu os fluxos				Bind mount desconectado			Verificar se nodered-data/ tem arquivos
Grafana sem dados					Fonte de dados desconectada		Reiniciar: docker compose restart grafana
"Permission denied" em algum serviço			Pasta com UID incorreto	Ver docs/MANUTENCAO.md, seção de permissões

Detalhamento completo em MANUTENCAO.md.

Documentação detalhada
📐 Arquitetura técnica

📋 Mapa de variáveis dos CLPs

🔧 Manual de manutenção

📚 Glossário de termos

⚙️ Procedimentos operacionais (POPs)