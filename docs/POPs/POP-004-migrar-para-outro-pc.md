# POP-004 — Migrar a Aplicação para Outro Computador

**Objetivo:** transferir a aplicação completa (código + dados) de
um computador para outro.
**Quando usar:**
- Quando a aplicação sair do computador de desenvolvimento e for
  para o computador definitivo de produção.
- Quando o computador atual precisar ser trocado ou reformado.
**Tempo estimado:** 30 a 60 minutos.
**Responsável:** pessoa treinada.

---

## Pré-requisitos no computador novo

Antes de começar, o computador de destino deve ter:

- [ ] Docker Desktop instalado
- [ ] Backend WSL2 ativado (Settings → General → "Use the WSL 2 based engine")
- [ ] Acesso à rede dos CLPs (mesma sub-rede, ex: 192.168.6.0/24)
- [ ] Espaço em disco: ~20 GB livres
- [ ] Portas 1880, 3000, 8080 e 8181 livres

---

## Parte 1 — Preparar o computador antigo

1. Abra o PowerShell e vá para a pasta pai:
cd C:\

2. Desligue a Aplicação.

cd C:\usina-monitor
docker compose down


3. **Compacte a pasta inteira:**
Comando Power Shell: 
Compress-Archive -Path C:\usina-monitor -DestinationPath C:\usina-monitor-$(Get-Date -Format 'yyyy-MM-dd').zip


4. Copie o arquivo `.zip` para um pendrive ou pasta de rede.

> ⚠️ **Verifique o tamanho** antes de copiar. Se tiver muitos meses
> de dados, o arquivo pode ter vários GB. Nesse caso, considere
> copiar em partes ou usar robocopy direto pela rede.

---

## Parte 2 — Instalar no computador novo

1. No computador novo, copie o arquivo `.zip` para `C:\`.

2. Descompacte:
Comando Power Shell:	
Expand-Archive -Path C:\usina-monitor-AAAA-MM-DD.zip -DestinationPath C:\

3. Verifique se a estrutura ficou correta:
Comando Power Shell:
dir C:\usina-monitor

Deve mostrar: `docs\`, `nodered-data\`, `influxdb3-data\`,
`docker-compose.yml`, `README.md`, etc.

4. **Ajuste as permissões das pastas** (elas vêm do outro PC e
podem ter UID errado):

	docker run --rm --user root ^
	--mount type=bind,source="C:\usina-monitor\influxdb3-data",target=/mnt/data ^
	influxdb:3.11-core ^
	chown -R 1500:1500 /mnt/data

Faça o mesmo para `nodered-data` (UID 1000), `grafana-data` e
`explorer-db`.

5. Suba a aplicação:cd C:\usina-monitor
	Executar o comando com uma CLI dentro da pasta reiz do projeto:
	docker compose up -d

6. Aguarde 3 minutos.

7. Verifique:

Executar o comando com uma CLI dentro da pasta reiz do projeto:
docker compose ps 

Todos devem estar `Up (healthy)`.

## Parte 3 — Configurar início automático (Windows)

Para a aplicação subir junto com o Windows:

1. Abra o **Agendador de Tarefas** (menu Iniciar → "Agendador").
2. Clique em **Criar Tarefa Básica**.
3. **Nome:** `Iniciar Monitoramento Usina`
4. **Gatilho:** "Ao fazer logon no computador"
5. **Ação:** "Iniciar um programa"
- **Programa:** `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
- **Argumentos:** `-Command "cd C:\usina-monitor; docker compose up -d"`
6. Salve e teste reiniciando o computador.


---

## Parte 4 — Testes pós-migração

- [ ] Os 4 contêineres estão `Up (healthy)`
- [ ] O Node-RED abre e mostra os fluxos preservados
- [ ] O Node-RED consegue ler o CLP (mensagens aparecem no Debug)
- [ ] O Grafana abre e mostra os dashboards
- [ ] Os painéis do Grafana atualizam com dados recentes
- [ ] O computador reinicia e a aplicação sobe sozinha

---

## Se algo deu errado

| Sintoma 				| Causa provável 					| Solução |

| InfluxDB reinicia em loop 		| Permissões erradas 					| Executar o `chown` novamente |
| Node-RED abre sem os fluxos 		| Pasta `nodered-data/` vazia 				| Reimportar o `.zip` |
| Token do InfluxDB não funciona 	| Token expirou ou o `.zip` não tem a versão certa 	| Regenerar (POP-003) |
| Grafana sem dashboards 		| Pasta `grafana-data/` vazia 				| Verificar o `.zip` original |

---

## Observações sobre a versão de produção

Quando a aplicação estiver em produção e estável, é recomendado:

1. Inicializar um repositório **Git local** para versionar
apenas o código (não os dados).
2. Configurar **backup automático** diário.
3. Ativar **nobreak (UPS)** com comunicação USB para desligamento
automático.

Esses itens serão detalhados em um POP futuro.
