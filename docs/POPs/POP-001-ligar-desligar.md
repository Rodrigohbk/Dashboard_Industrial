# POP-001 — Ligar, Desligar e Verificar a Aplicação

**Objetivo:** executar as operações básicas do dia a dia.
**Quando usar:** sempre que precisar ligar, desligar ou checar a aplicação.
**Tempo estimado:** 3 minutos.
**Responsável:** qualquer pessoa com acesso ao computador.

---

## Pré-requisitos

- Docker Desktop instalado e rodando (verificar ícone da baleia
  na bandeja do sistema, próximo ao relógio do Windows).
- Terminal (PowerShell ou CMD) aberto.

---

## Procedimento: Ligar a aplicação

1. Abra o **PowerShell** (menu Iniciar → digite `powershell`).
2. Navegue até a pasta do projeto:
	cd c:\usina-monitor
3. Escreve "CMD" na barra de endereço do explorador de arquivos

4. Execute:
docker compose up -d

5. Aguarde as mensagens. Você verá algo como:
✔ Container influxdb3-core Healthy
✔ Container nodered Started
✔ Container grafana Started
✔ Container influxdb3-explorer Started

## Procedimento: Verificar se está tudo funcionando

1. No mesmo terminal, execute:

docker compose ps

2. Confira o resultado:

2. Confira o resultado:

| O que você vê 		| O que significa |
| `Up (healthy)` 		| ✅ Serviço funcionando perfeitamente |
| `Up (health: starting)` 	| ⏳ Ainda iniciando, aguarde 1 min |
| `Up` (sem health) 		| ✅ Rodando (o Explorer não tem healthcheck) |
| `Restarting` 			| 🚨 Problema — ver POP-002 |
| `Exited` ou nada 		| 🚨 Problema — ver POP-002 |

3. Teste o acesso aos serviços no navegador:

| Serviço 	| Endereço 		| O que deve aparecer |
| Node-RED 	| http://localhost:1880 | Tela com os fluxos |
| Grafana 	| http://localhost:3000 | Tela de login |
| Explorer 	| http://localhost:8080 | Tela inicial |


## Procedimento para desligar a aplicação

1. Abra o PowerShell e navegue até a pasta:

cd C:\usina-monitor

2. Execute:

docker compose down

3. Aguarde 5 a 10 segundos. Todos os contêineres serão
removidos, mas **os dados são preservados** nas pastas de
bind mount.

> ⚠️ **Importante:** sempre que possível, use `docker compose down`
> antes de desligar o computador. Isso evita corrupção de WAL.
> Se a energia cair sem aviso, siga o POP-002.

## Como saber se deu certo

- [ ] Os 4 serviços aparecem como `Up` no `docker compose ps`
- [ ] O Node-RED abre no navegador
- [ ] O Grafana mostra os dashboards normalmente
- [ ] Os dados continuam chegando (checar via Node-RED Debug ou Grafana)

## Se não funcionou

| Sintoma 					| Onde procurar |

| Docker Desktop não abre 			| Reinstalar ou reiniciar o Windows |
| `docker compose up` dá erro de porta 		| Verificar se outro programa usa a mesma porta |
| Contêiner em `Restarting` 			| Ver POP-002 |
| Interface abre mas sem dados 			| Ver POP-003 |