# POP-003 — Trocar ou Regenerar o Token do InfluxDB

**Objetivo:** criar um novo token de acesso ao InfluxDB e atualizar
os serviços que dependem dele.
**Quando usar:**
- Após um reset completo do InfluxDB (POP-002).
- Após migrar para outro computador (POP-004).
- Se o token atual foi perdido ou comprometido.
**Tempo estimado:** 15 minutos.
**Responsável:** pessoa treinada.

---

## O que é o token

É como uma senha especial que permite escrever e ler no banco de
dados. Sem ele, o Node-RED não consegue gravar e o Grafana não
consegue ler.

O InfluxDB **só mostra o token uma vez**, no momento da criação.
Por isso, é fundamental guardar em local seguro (cofre de senhas
ou arquivo protegido).

---

## Procedimento: Gerar um novo token

1. Abra o PowerShell e navegue até a pasta:
cd C:\usina-monitor

2. Verifique se o InfluxDB está rodando:
docker compose ps 

3. Se não estiver, suba primeiro:
docker compose up -d influxdb3-core

4. Aguarde 1 minuto até o InfluxDB ficar `healthy`.

5. Gere o token de admin:
docker exec -it influxdb3-core influxdb3 create token --admin

6. Copie o valor retornado (algo como
`apiv3_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx...`).
**Guarde-o em local seguro AGORA.**

---

## Procedimento: Atualizar o Node-RED

1. Abra o Node-RED: http://localhost:1880
2. Procure o nó de configuração `influxdb3-config` (geralmente
aparece como um nó cinza com "InfluxDB" escrito).
3. Dê duplo clique nele.
4. Substitua o campo **Token** pelo novo valor colado.
5. Clique em **Done**.
6. Clique em **Deploy** (canto superior direito).
7. Observe o Debug: as mensagens devem voltar a aparecer sem erro.

---

## Procedimento: Atualizar o Grafana

1. Abra o Grafana: http://localhost:3000
2. Faça login (`admin` / `usina@2025`).
3. Menu lateral → **Connections** → **Data sources**.
4. Clique em **InfluxDB Usina**.
5. Procure o campo **Token** e substitua pelo novo valor.
6. Clique em **Save & test**.
7. Deve aparecer "Data source is working".

---

## Procedimento: Atualizar o Explorer

1. Abra o Explorer: http://localhost:8080
2. Vá em **Settings** ou **Connections**.
3. Atualize o token do banco `usina`.
4. Salve.

---

## Como saber se deu certo

- [ ] O Node-RED mostra mensagens de sucesso no Debug
- [ ] O Grafana exibe "Data source is working"
- [ ] O Explorer consegue consultar o banco `usina`
- [ ] Os painéis do Grafana voltam a atualizar

---

## Onde guardar o token com segurança

**Opção recomendada:** cofre de senhas digital (Bitwarden, KeePass).

**Opção aceitável:** arquivo `.txt` criptografado com senha, guardado
em pendrive ou pasta protegida.

**Evite:** deixar em texto plano em `README` ou `docs/` do projeto,
pois isso derrota o propósito do token.