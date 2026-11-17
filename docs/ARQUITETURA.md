# Arquitetura da Aplicação

Este documento descreve como a aplicação de monitoramento está
organizada, do CLP até a tela do usuário.

---

## Visão geral

CLP ──▶ Node RED ──▶ InfluxDB 3 ──▶ Grafana ──▶ Smartphone


---

## Componentes em detalhe

### 1. CLPs (Controladores Lógicos Programáveis)

5 CLPs Citrino FX da FERTRON, distribuídos pelos setores da usina:

| Setor 	| IP 		| Nome no projeto |
| Caldeira 	| 192.168.6.220 | Caldeira |
| Moenda 	| 192.168.6.224 | Moenda |
| Evaporação 	| 192.168.6.228 | Evaporacao |
| Fábrica 	| 192.168.6.231 | Fabrica |
| Gerador 	| 192.168.6.65 	| Gerador |

Todos respondem a Modbus/TCP na porta 502, com Unit ID 255.

### 2. Node-RED (coleta)

**O que faz:** pergunta periodicamente ao CLP quais são os valores
atuais das variáveis (polling). Transforma os dados brutos em
mensagens organizadas e envia para o InfluxDB.

**Como acessar:** http://localhost:1880

**Organização do fluxo (padrão):**

- Uma **aba** por setor (Caldeira, Moenda, Fabrica, etc.)
- Uma **aba "Shared"** com funções comuns reutilizáveis
- **Subflows** para operações repetitivas

**Periodicidade:** cada variável é lida a cada 2 segundos, mas
o polling é escalonado para não sobrecarregar o CLP.

### 3. InfluxDB 3 Core (armazenamento)

**O que faz:** armazena todos os dados com data/hora.

**Configuração:**
- Versão: 3.11.4
- Banco: `usina`
- Retenção: **2 anos** (para comparação entre safras)
- Precisa de token de admin (guardado na raiz da pasta da aplicação)

**Porta de acesso:** 8181

### 4. Grafana (visualização)

**O que faz:** exibe os dados em dashboards web.

**Como acessar:** http://localhost:3000 (admin / usina@2025)

**Fonte de dados:** conectada ao InfluxDB via SQL + Flight SQL,
com **Insecure Connection** habilitado (TLS desligado na rede
interna do Docker — ver MANUTENCAO.md para justificativa).

### 5. InfluxDB Explorer (administração)

**O que faz:** interface web para consultar e gerenciar o banco.

**Como acessar:** http://localhost:8080

**Uso:** testar consultas SQL antes de montá-las no Grafana,
gerenciar tokens, visualizar estruturas.

---

## Fluxo do dado em detalhe

Vamos seguir o caminho de uma **única medição de temperatura**:

1. **Sensor PT-100** mede a temperatura física da caldeira.
2. **CLP Citrino** lê o sinal 4-20mA, converte para escala de
   engenharia (°C) e armazena na memória interna em AI001.
3. **Node-RED** (mestre Modbus) envia requisição FC 3 lendo o
   registrador correspondente a AI001.
4. **CLP responde** com um número de 16 bits representando a
   temperatura.
5. **Node-RED** formata a mensagem (measurement, tags, fields) e
   envia ao InfluxDB.
6. **InfluxDB armazena** o ponto com timestamp.
7. **Grafana** consulta o InfluxDB a cada X segundos e renderiza
   o gráfico na tela.
8. **Operador** visualiza a temperatura em tempo real.

Tempo total do ciclo: **menos de 500 ms**.

---

## Decisões de arquitetura (e por quê)

### Por que Docker?

- **Isolamento:** se um serviço quebrar, não afeta os outros.
- **Portabilidade:** fácil migrar para outro computador.
- **Reprodutibilidade:** o `docker-compose.yml` documenta toda a
  configuração em um arquivo.
- **Rollback:** se uma versão nova der problema, voltar é trivial.

### Por que bind mounts em vez de volumes nomeados?

- **Visibilidade:** os dados ficam em pastas comuns do Windows,
  visíveis no Explorer.
- **Backup:** é só copiar a pasta.
- **Controle:** mais fácil de migrar e inspecionar.

O contraponto: exige atenção às permissões (UID 1500 para InfluxDB
e UID 1000 para Node-RED).

### Por que healthcheck + depends_on?

Após queda de energia, os contêineres sobem simultaneamente. Sem
healthcheck, o Node-RED tentaria conectar ao InfluxDB antes dele
estar pronto, gerando erros `ECONNREFUSED`.

Com healthcheck + `condition: service_healthy`, a ordem é
garantida: InfluxDB sobe, fica saudável, e só então Node-RED,
Grafana e Explorer sobem.

### Por que Unit ID 255?

O supervisório da usina já usa 255, e o Citrino aceita esse valor
como "qualquer um". Mantemos a mesma convenção para padronizar.

### Por que float32 com ordem CDAB?

O Citrino FX usa ordem **word-swapped** (CDAB) para floats de 32
bits. Descobrimos empiricamente em 30/09/2026 comparando com os
valores do supervisório. Outros CLPs podem usar ordem diferente —
**testar novamente se trocar de modelo**.

---

## Melhorias planejadas

| Melhoria 					| Prazo estimado	| Impacto |
|
| Nobreak (UPS) no computador industrial 	| Curto prazo 		| Alto |
| Backup automático diário | Curto prazo 	| Alto |
| Repositório Git local | Curto prazo 		| Médio |
| Reverse proxy com HTTPS para acesso remoto 	| Médio prazo 		| Alto |
| Alertas via Telegram/E-mail 			| Médio prazo 		| Médio |
| Documentação dos POPs completa 		| Contínuo 		| Alto |

---

**Última atualização:** 30/09/2026
**Responsável:** Rodrigo Dos Santos Honda