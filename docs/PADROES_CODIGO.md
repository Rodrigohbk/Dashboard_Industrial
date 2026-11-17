# Padrões de Código

Este documento descreve como escrevemos o código JavaScript dentro
do Node-RED. Seguir este padrão garante que qualquer pessoa da equipe
consiga entender, manter e evoluir a aplicação.

---

## Por que ter um padrão?

Sem padrão, cada função fica escrita de um jeito. Quem chega depois
precisa "adivinhar" o que cada parte faz. Com padrão:

- Quem lê encontra as mesmas seções nos mesmos lugares
- Quem escreve sabe o que precisa documentar
- Quem conserta localiza o problema em segundos

---

## Cabeçalho obrigatório de toda função

Toda função do Node-RED **começa** com este cabeçalho:

```javascript
/**
 * ============================================================
 *  FUNÇÃO: <nome curto da função>
 * ============================================================
 *  AUTOR:      <nome do autor>
 *  DATA:       <data de criação>
 *  VERSÃO:     <versão semântica, ex: 1.0, 1.1, 2.0>
 *
 *  O QUE FAZ:
 *    <descrição em 1 ou 2 frases>
 *
 *  POR QUE ESTÁ ASSIM:
 *    <contexto histórico ou decisões importantes>
 *
 *  ENTRADA:   msg.payload = <formato esperado>
 *  SAÍDA:     msg.payload = <formato retornado>
 * ============================================================
 */

### Regras
Campo			Obrigatório?	Observações
FUNÇÃO			✅ Sim		Nome curto e descritivo
AUTOR			✅ Sim		Nome de quem criou
DATA			✅ Sim		Formato AAAA-MM-DD
VERSÃO			✅ Sim		Alterar a cada mudança relevante
O QUE FAZ		✅ Sim		Linguagem simples, sem jargão
POR QUE ESTÁ ASSIM	✅ Sim		O mais importante — evita "arqueologia"
ENTRADA			✅ Sim		O que a função espera receber
SAÍDA			✅ Sim		O que a função devolve

### Regras gerais de escrita

1. Nomes de variáveis em português claro
Prefira:

javascript
const temperaturaCaldeira = msg.payload[0];

Evite:

javascript
const t = msg.payload[0];   // o que é "t"?

2. Comentários em português
O time todo é brasileiro. Todos os comentários e nomes significativos são em português.

3. Verificar dados antes de usar

Sempre validar o que chega, antes de processar:

javascript
if (!Array.isArray(msg.payload) || msg.payload.length < 2) {
    node.warn('Payload inesperado: ' + JSON.stringify(msg.payload));
    return null;
}
node.warn é uma ferramenta importante — mostra um aviso amarelo
no nó quando algo não vem como esperado, sem derrubar o fluxo.


4. Nunca usar console.log

O console.log escreve no log do Docker (difícil de ver no dia a
dia). No Node-RED, use:

node.warn(msg) — aviso amarelo no nó

node.error(msg) — erro vermelho no nó

node.status({...}) — texto abaixo do nó

5. Comentar o óbvio que não é óbvio

javascript
// ❌ Comentário inútil
// soma 1 ao contador
contador = contador + 1;

// ✅ Comentário útil
// O bit 5 do registrador 7517 indica auto(1)/manual(0) do KONT 2,
// conforme mapa de variáveis do supervisório. Ver MAPA_VARIAVEIS.md
const modoAutoManual = (word >> 5) & 1;

### Versionamento semântico simplificado
Mudança						Versão		Exemplo
Correção de bug ou ajuste de comentário		1.0 → 1.1	1.0 → 1.1
Nova funcionalidade sem quebrar			1.1 → 1.2	1.1 → 1.2
Mudança que quebra quem usa			1.2 → 2.0	1.2 → 2.0

### Exemplo completo

/**
 * ============================================================
 *  FUNÇÃO: Extrai bit de um registrador Modbus
 * ============================================================
 *  AUTOR:      João Silva
 *  DATA:       30/09/2026
 *  VERSÃO:     1.0
 *
 *  O QUE FAZ:
 *    Recebe uma palavra de 16 bits (vinda de um Holding Register
 *    do CLP) e devolve o valor do bit 5.
 *
 *  POR QUE ESTÁ ASSIM:
 *    O CLP Citrino FX guarda o estado auto/manual do controlador
 *    KONT 2 no bit 5 do registrador 7517. Descobrimos esse
 *    endereço consultando o mapa do supervisório da usina.
 *    Se trocar o CLP, TESTAR NOVAMENTE.
 *
 *  ENTRADA:   msg.payload = [word]         (word = int16)
 *  SAÍDA:     msg.payload.bit_5 = 0 ou 1
 * ============================================================
 */

// 1. Validação
if (!Array.isArray(msg.payload) || msg.payload.length < 1) {
    node.warn('Payload inesperado: ' + JSON.stringify(msg.payload));
    return null;
}

// 2. Extrai o valor
const word = msg.payload[0];
const bit5 = (word >> 5) & 1;

// 3. Devolve o resultado
msg.payload = {
    word_hex: '0x' + (word & 0xFFFF).toString(16).padStart(4, '0').toUpperCase(),
    bit_5: bit5
};
return msg;

Última atualização: 30/09/2026
Responsável: Rodrigo Dos Santos Honda