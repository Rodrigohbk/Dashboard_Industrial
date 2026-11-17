# Mapa de Variáveis

Este documento é o **catálogo completo** das variáveis que a
aplicação coleta dos CLPs. Serve tanto para entender o que já
está mapeado quanto para consultar endereços e unidades.

---

## Regras de nomenclatura (UNS)

Todas as variáveis seguem o padrão **Unified Namespace (UNS)**: Setor.Equipamento.Grandeza


Exemplos:
- Fabrica.Cristalizador_A.nivel
- Caldeira.Caldeira_01.temperatura_vapor
- Moenda.Moenda_01.rotacao

---

## Convenções de endereçamento

Após os primeiros testes, estabelecemos as seguintes convenções:

| Parâmetro 			| Valor 			| Observação |

| **Protocolo** 		| Modbus/TCP 			| Sobre Ethernet |
| **Porta** 			| 502 				| Padrão Modbus/TCP |
| **Unit ID** 			| 255 				| Confirmado pelo supervisório existente |
| **Function Code** 		| 3 (Read Holding Registers) 	| Somente leitura |
| **Convenção de endereço** 	| CSV - 1 (0-based) 		| Ex: CSV `FP:52007` → protocol `52006` |
| **Ordem de float32** 		| CDAB (word-swapped) 		| `reg2` = palavra alta, `reg1` = palavra baixa |
| **Polling** 			| 2 segundos 			| Escalonado entre variáveis |

---

## Tipos de endereço no CSV do supervisório

O CSV exportado do supervisório usa dois prefixos:

| Prefixo 	| Significado 					| Conversão |

| `FP:` 	| Float Point (32 bits = 2 registradores) 	| Protocol = valor - 1 |
| `4X:` 	| Holding Register (16 bits = 1 registrador) 	| Protocol = valor - 1 |
| `4X:xxxx.y` 	| Bit `y` dentro do registrador `xxxx` 		| Protocol = xxxx - 1, extrair bit `y` |

---

## Variáveis já validadas (teste de 29-30/09/2026)

| Tag UNS | Measurement | Endereço CSV | Protocol | Tipo | Unidade | Testado em |
|---|---|---|---|---|---|---|
| `Fabrica.CPU_Fabrica.hora` | `hora_clp` | ST 28, 29, 30 | 28 | int16 ×3 | HH:MM:SS | 30/09/2026 ✅ |
| `Fabrica.Cristalizador_A.nivel` | `nivel` | FP:52007 | 52006 | float32 | % | 30/09/2026 ✅ |
| `Fabrica.KONT_2.auto_manual` | `auto_manual` | 4X:7518.5 | 7517 bit 5 | int16 | 0/1 | 30/09/2026 ✅ |

---

## Variáveis a mapear (por setor)

Esta seção será preenchida conforme o mapeamento avançar.

### Fábrica (192.168.6.231)

| Tag Supervisório | Tag UNS proposta | Endereço CSV | Tipo | Unidade |
|---|---|---|---|---|
| *(a preencher)* | | | | |

### Caldeira (192.168.6.220)

| Tag Supervisório | Tag UNS proposta | Endereço CSV | Tipo | Unidade |
|---|---|---|---|---|
| *(a preencher)* | | | | |

### Moenda (192.168.6.224)

| Tag Supervisório | Tag UNS proposta | Endereço CSV | Tipo | Unidade |
|---|---|---|---|---|
| *(a preencher)* | | | | |

### Evaporação (192.168.6.228)

| Tag Supervisório | Tag UNS proposta | Endereço CSV | Tipo | Unidade |
|---|---|---|---|---|
| *(a preencher)* | | | | |

### Gerador (192.168.6.65)

| Tag Supervisório | Tag UNS proposta | Endereço CSV | Tipo | Unidade |
|---|---|---|---|---|
| *(a preencher)* | | | | |

---

## Variáveis descartadas ou com problema

Registre aqui as variáveis que apresentaram problema durante o
mapeamento, para não perder o histórico.

| Tag | Problema | Ação tomada |
|---|---|---|
| *(a preencher)* | | |

---

## Procedimento para adicionar nova variável

1. Localizar a tag no CSV do supervisório.
2. Identificar o IP do CLP e o endereço (`FP:` ou `4X:`).
3. Aplicar a conversão (subtrair 1 do valor).
4. Definir a tag UNS (`Setor.Equipamento.Grandeza`).
5. Criar a função no Node-RED (seguir o padrão existente).
6. Testar por 1 minuto e comparar com o supervisório.
7. Adicionar à tabela acima, com a data do teste.

---

**Última atualização:** 30/09/2026
**Responsável:** Rodrigo Dos Santos Honda