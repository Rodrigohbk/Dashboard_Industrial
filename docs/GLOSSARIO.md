# Glossário de Termos Técnicos

Este documento explica, em linguagem simples, os termos técnicos
usados na nossa aplicação de monitoramento.

Foi escrito pensando em quem vem da área de elétrica e automação
industrial, mas nunca trabalhou com Docker, banco de dados ou
desenvolvimento de software.

> **Como usar este documento:** sempre que aparecer uma palavra que
> você não conhece no código, na documentação ou nos logs, procure
> aqui primeiro.

---

## Índice

- [Termos de infraestrutura](#termos-de-infraestrutura)
- [Termos de banco de dados](#termos-de-banco-de-dados)
- [Termos de comunicação industrial](#termos-de-comunicação-industrial)
- [Termos de redes](#termos-de-redes)
- [Termos de software](#termos-de-software)

---

## Termos de infraestrutura

### Docker

Uma ferramenta que cria "caixas isoladas" onde programas rodam.
Pense em cada caixa como um **computador independente dentro do
computador real**: cada caixa tem seu próprio sistema operacional
(mínimo), seus próprios arquivos e sua própria rede.

**Por que usar Docker?** Se um programa der problema, ele não
afeta os outros. Se quisermos migrar tudo para outro computador,
é só copiar as caixas.

### Contêiner

Cada "caixa" criada pelo Docker. Nossa aplicação tem 4 contêineres:

- `influxdb3-core` — o banco de dados
- `nodered` — o coletor de dados
- `grafana` — a tela de visualização
- `influxdb3-explorer` — o administrador do banco

Um contêiner é diferente de uma **imagem**: a imagem é o "molde"
(fica guardado no disco), e o contêiner é o "bolo assado" (roda na
memória). Podemos ter vários contêineres feitos a partir da mesma
imagem.

### Imagem

O "molde" a partir do qual um contêiner é criado. É como um **CD de
instalação**: tem tudo que o programa precisa, congelado em uma
versão específica.

Exemplo: `influxdb:3.11-core` é a imagem do InfluxDB versão 3.11.

### Docker Compose

Uma ferramenta que lê um arquivo de texto (o `docker-compose.yml`)
e sobe todos os contêineres de uma vez, já conectados entre si.

Sem o Compose, teríamos que digitar um comando `docker run` enorme
para cada serviço. Com o Compose, é só `docker compose up -d`.

### Bind mount

Uma pasta do computador real que é "emprestada" para dentro de um
contêiner. Tudo que o contêiner grava nela fica salvo no disco do
computador, mesmo se o contêiner for apagado.

**Por que é importante:** nossos dados ficam salvos em pastas do
Windows (`influxdb3-data/`, `nodered-data/`, etc). Se algo der
errado e a caixa for destruída, os dados continuam lá.

### Healthcheck

Um teste automático que o Docker faz periodicamente para verificar
se um serviço está realmente funcionando (não só ligado).

Exemplo: o InfluxDB tem um healthcheck que testa se a porta 8181
está respondendo. Quando passa, o Docker marca o serviço como
"healthy" e libera a inicialização dos outros.

### Restart policy (política de reinício)

Regra que diz o que fazer se um contêiner parar. Usamos
`unless-stopped`, que significa: "se cair por qualquer motivo,
suba automaticamente — a menos que alguém tenha desligado de
propósito".

### Log

Mensagem que um programa escreve para contar o que está fazendo.
Pode ser informativa ("iniciado com sucesso"), de aviso ("cuidado,
memória baixa") ou de erro ("falhou ao conectar").

Os logs ficam armazenados pelo Docker e podem ser vistos com
`docker compose logs <nome-do-serviço>`.

---

## Termos de banco de dados

### Banco de dados

Local onde as informações são guardadas de forma organizada, para
poderem ser consultadas depois. É como uma **prateleira com pastas
etiquetadas**.

### InfluxDB

O banco de dados que usamos. É especializado em **séries temporais**:
dados que têm valor + data/hora, como temperatura às 14h32, pressão
às 14h33, etc.

**Por que não usar Excel?** O InfluxDB é centenas de vezes mais
rápido para consultar "mostre a temperatura da última hora". E
aguenta milhões de linhas sem travar.

### Série temporal (time series)

Conjunto de valores medidos ao longo do tempo. Exemplo: as leituras
de temperatura da caldeira das 8h às 18h formam uma série temporal.

### Measurement

Equivalente a uma "tabela" no InfluxDB. Cada grandeza física tem
sua própria measurement: `temperatura`, `pressao`, `nivel`, etc.

### Tag

Etiqueta que identifica **de onde** veio o dado. É sempre texto.
Exemplos: `setor=Caldeira`, `equipamento=Caldeira_01`.

Tags são usadas para **filtrar** consultas: "mostre só o que é da
Caldeira".

### Field

O **valor medido** em si. É numérico (float, integer) ou booleano.
Exemplo: a temperatura 78.5 ou a pressão 4.2.

### Timestamp

Data e hora em que a medição foi feita. O InfluxDB armazena sempre
em UTC (horário universal), e o Grafana converte para o horário de
Brasília na hora de exibir.

### Retenção

Período pelo qual os dados são mantidos antes de serem apagados
automaticamente. No nosso caso: **2 anos** (para comparação entre
safras).

### Token

"Chave de acesso" do banco de dados. Funciona como uma senha
especial. Quem tem o token pode ler e escrever.

---

## Termos de comunicação industrial

### Modbus

Protocolo de comunicação industrial criado nos anos 70, ainda
amplamente usado. Funciona no modelo **Mestre-Escravo**: o mestre
pergunta, o escravo responde.

No nosso caso: o Node-RED é o mestre, o CLP é o escravo.

### Modbus/TCP

Variante do Modbus que roda sobre rede Ethernet (cabo de rede),
em vez de cabo serial. Usa a porta **502**.

### Modbus RTU

Variante do Modbus que roda sobre cabo serial (RS-485 ou RS-232).
Não usamos no momento.

### Unit ID

Número de identificação do escravo no barramento Modbus. Vai de
1 a 247. O valor 255 é usado em Modbus/TCP como "qualquer um".

### Holding Register

Um dos 4 tipos de dado Modbus. É uma "gaveta" que guarda um valor
de 16 bits. Pode ser lido e escrito.

### Function Code (FC)

Número que diz ao escravo qual operação o mestre quer fazer. Os
mais comuns:

- **FC 1** — ler bits (bobinas)
- **FC 3** — ler registradores (nossa operação principal)
- **FC 5** — escrever 1 bit
- **FC 6** — escrever 1 registrador

**Importante:** nosso fluxo só usa FC 3 (leitura). Nunca escreve
no CLP, mesmo que haja um bug no código.

### Escala de engenharia

Valor já convertido para a unidade física real (°C, bar, m³/h), em
vez do sinal bruto do sensor. O CLP Citrino já entrega em escala
de engenharia, então não precisamos converter no Node-RED.

### Float32

Número decimal de 32 bits (4 bytes). Ocupa **2 registradores Modbus**
consecutivos. Usado para temperatura, pressão, vazão, etc.

### Word-swapped (CDAB)

Ordem específica como o CLP Citrino organiza os 4 bytes de um
float32. Descobrimos empiricamente que o Citrino usa esta ordem,
não a big-endian padrão.

**Se um dia trocar o CLP, TESTAR NOVAMENTE** — pode ser que o novo
use outra ordem.

---

## Termos de redes

### IP

Endereço único de um dispositivo na rede. Nossos CLPs têm IPs como
`192.168.6.220`, `192.168.6.224`, etc.

### Porta

"Número do apartamento" dentro de um IP. Um mesmo IP pode ter vários
serviços rodando, cada um em uma porta diferente.

Exemplos: Modbus/TCP usa a porta **502**; Grafana usa a **3000**;
Node-RED usa a **1880**.

### Bridge (rede bridge)

Tipo de rede virtual criada pelo Docker. Os contêineres se enxergam
pelo nome (ex: `influxdb3-core`) sem precisar saber o IP.

### Localhost

"Este computador aqui". Quando o navegador acessa `localhost:3000`,
está falando com o próprio computador onde está rodando.

### DNS interno

Serviço do Docker que traduz nomes (ex: `influxdb3-core`) para IPs.
Funciona só dentro da rede bridge.

---

## Termos de software

### Node-RED

Ferramenta de programação visual. Em vez de escrever linhas de
código, arrastamos **nós** (blocos) e ligamos com fios.

Cada nó faz uma coisa: ligar a um CLP, ler um valor, transformar,
enviar para o banco, etc.

### Fluxo (flow)

Conjunto de nós ligados. Cada aba do Node-RED é um fluxo.

### Nó (node)

Bloco individual no Node-RED. Existem centenas de tipos: injeção,
função, debug, Modbus, InfluxDB, etc.

### msg (mensagem)

Objeto que os nós passam entre si. É como um "envelope" com
informações dentro: `payload` (o conteúdo), `topic` (o assunto),
`error` (erro, se houver).

### Payload

O "conteúdo" da mensagem. É o dado em si — pode ser um número,
um texto, um array, um objeto.

### JavaScript

Linguagem de programação usada nos nós "function" do Node-RED.
Não precisa ser expert — nosso código é simples e comentado.

### Variável de ambiente

Configuração passada para um contêiner na hora de subir, sem estar
dentro do código. Exemplo: `TZ=America/Sao_Paulo` diz ao contêiner
para usar o horário de Brasília.

### Token de acesso

Chave que permite acesso a um serviço. No nosso caso, o Node-RED
usa um token para escrever no InfluxDB.

### UTC

Horário universal, padrão usado pelo InfluxDB para armazenar dados.
Brasília é UTC-3 (3 horas atrás).

### Endpoint

"Endereço" de uma API. Ex: `http://influxdb3-core:8181/health` é
o endpoint que testa se o InfluxDB está saudável.

---

## Termos específicos do nosso projeto

### UNS (Unified Namespace)

Padrão de nomenclatura usado para organizar as tags do banco de
dados, na forma: Setor.Equipamento.Grandeza
Exemplo: `Fabrica.Cristalizador_A.nivel`

### POP (Procedimento Operacional Padrão)

Documento que descreve "se acontecer X, faça Y". Usamos para
registrar as ações de manutenção mais comuns.

Ficam em `docs/POPs/`.

---

## Termos que ainda não apareceram, mas podem aparecer

Este documento será atualizado conforme a aplicação crescer.
Se você encontrar um termo técnico que não está aqui, avise o
responsável para que seja adicionado.

---

**Última atualização:** 30/09/2026
**Responsável:** Rodrigo Dos Santos Honda