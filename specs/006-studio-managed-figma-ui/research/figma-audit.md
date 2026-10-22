# Auditoria inicial do arquivo Figma

**Data:** 2026-10-22  
**Arquivo:** `fQwb2sLFJWrImkI0HcwBNf` — BINGO NOIR UI kit.  
**Método:** Figma MCP: `whoami`, metadata, screenshot e contexto de componente.

## Acesso

- A autenticação Figma respondeu e permitiu leitura de metadata, screenshot e contexto do HUD.
- O plano retornado pelo Figma era Starter; o limite de chamadas MCP foi atingido durante a extração detalhada. IDs ainda não conhecidos ficam pendentes; não devem ser presumidos.

## Quadros localizados

| Nome | Node ID | Leitura inicial |
| --- | --- | --- |
| BINGO NOIR · Desktop shared HUD | `6:9554` | HUD desktop, MC Bribe, loja e toggles de áudio como referência de composição |
| BINGO NOIR · Mobile shared HUD | `6:9616` | composição compartilhada adaptada para 390×844 |
| BINGO NOIR · Production & accessibility | `6:9432` | contrastes, safe area e orientações de produção/acessibilidade |
| BINGO NOIR · Feedback & audio artwork | `6:9189` | assets de áudio, ícones, notificações, loading e erro |
| BINGO NOIR · Component specimens | `6:8857` | botões, painéis, elegibilidade, tabs, scroll e foco |
| BINGO NOIR · Foundations | `6:8664` | paleta, tipografia e tokens |
| BINGO NOIR · Native component library | `6:10107` | masters e variantes nativas reutilizáveis |

## Componentes confirmados no contexto legível

| Componente | Node ID | Propriedade visual observada |
| --- | --- | --- |
| Primary button | `6:10855` | abrir loja, variante desktop |
| Audio Music On | `6:10868` | ícone e rótulo Music / ON |
| Audio Effects Off | `6:10883` | ícone e rótulo Effects / OFF |
| MC Bribe HUD | `6:11347` | texto de efeito compartilhado e limite de uso |
| MC Bribe button | `6:10126` | controle visual da ação |

## Limites da leitura

- A composição shared HUD foi lida em desktop e mobile. O Figma contém bibliotecas e guias de componentes para cobrir outros elementos.
- Não foram encontrados quadros de composição completa para cada tela de lobby, intro, match, resultados e loja na listagem inicial de quadros. A montagem dessas telas deve ser identificada como trabalho de composição com os componentes, e não descrita como layout já presente no arquivo.
- Ainda não existe inventário individual validado de todos os masters/variants ou asset IDs. Completar essa tabela ao recuperar acesso a mais chamadas MCP.

## Relação com o projeto

O projeto já versiona `BingoGuiDesign.rbxmx` e `WorldGuiTemplates.rbxmx`; `VisualDesign` aplica aparência de Studio à GUI construída pelos módulos client e `BingoCard` já clona um prefab `Components > CardCell`. A UI de loja, views de Bingo e interfaces de mundo têm construção Luau ativa. O mapa dos pontos existentes está em [INVENTORY.md](../../../docs/figma-ui-kit/INVENTORY.md); a arquitetura proposta está em [plan.md](../plan.md).
