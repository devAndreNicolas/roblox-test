# 006 — Matriz de validação: UI Studio-managed

**Status:** Planejada; nenhuma tela desta spec foi migrada ou validada ainda.  
**Importante:** esta matriz deve ser executada no Studio após cada corte de tela. Não substituir a validação real de UI por leitura do `.rbxmx` ou comparação de screenshot isolada.

## Fluxo de edição e sincronização

| Cenário | Ação | Resultado esperado |
| --- | --- | --- |
| Export inicial | Salvar root do template do Studio como `.rbxmx` no caminho mapeado | Root mantém nome/classe e aparece uma única vez após Rojo sync |
| Edição visual | Alterar cor, imagem, texto estático, posição ou dimensão em Studio; salvar root | Mudança persiste em arquivo e reaparece após reconectar Rojo |
| Proteção contra sobrescrita | Desconectar Rojo, editar, exportar e inspecionar diff antes de sincronizar | Nenhuma alteração Studio não exportada é perdida |
| Rollback | Reverter o commit do pacote e sincronizar o arquivo anterior | Layout anterior volta e controllers ainda abrem a tela |
| Root ausente | Iniciar cliente sem template migrado | Fallback da tela abre sem travar outras features |

## Matriz de tela/estado

| Área | Viewports | Estados/caminhos | Critério |
| --- | --- | --- | --- |
| HUD compartilhado | desktop e mobile | saldo carregando/pronto; milestone; loja aberta; áudio on/off | Valores são atuais, controles visíveis e layout sem sobreposição |
| Lobby | desktop e mobile | desconectado, fila vazia, enfileirado, contagem, match em andamento, erro/retry | Ação e estado correspondem ao servidor; safe area livre |
| Intro | desktop e mobile | falas/timing, skip, preview com tema equipado | Texto não corta; skip continua a mesma ação |
| Cartela | 360×640 e viewport desktop | normal, chamado, marcável, marcado, free, foco, tema e fallback | 25 números corretos; número, letra e marca continuam nativos e legíveis |
| Match call | desktop e mobile | ready, letra/número, countdown, pause de Suborno | Chamada coincide com estado público; relógio e ação de marcação preservados |
| Bingo Race e history | desktop e mobile | collapsed/expanded, até oito players, empate, near-win, vazio | Ordem/dados atuais; sem clipping e com foco funcional |
| Results | desktop e mobile | vitória, derrota, empate, detalhes e skip | Copy/título correspondem ao resultado authoritative e ação permanece |
| Shop/rewards | desktop e mobile | 4 tabs; preço dinâmico; insuficiente; owned/equipped; erro/sucesso/pendente | Navegação e prompts atuais funcionam; texto e preço continuam dinâmicos |
| World UI | range de distância real do mundo | portal, queue prompt, dialogue, call display, poster | Leitura à distância; labels e Adornee atuais; prompt mantém ação |

## Contratos de regressão

- [ ] Compra em Fichas usa o mesmo evento/catálogo e rejeita saldo insuficiente como antes.
- [ ] Prompt Robux usa o mesmo adapter/platform price; botão desabilitado não abre prompt indevido.
- [ ] Equipamento/ownership de tema persiste e muda a mesma moldura na prévia e cartela ativa/próxima conforme regra existente.
- [ ] Recompensas diárias continuam mostrando estado autoritativo; abrir HUD não concede recompensa.
- [ ] Convite continua usando atribuição válida do Roblox e mesma entrega idempotente.
- [ ] Ativação do Suborno mantém fase, limites, chamada pública, pausa e consumo atuais.
- [ ] Fila, sequência de estados da partida e marcação continuam com os mesmos contratos e remotes.
- [ ] World prompts e texto dinâmico continuam atribuídos por `BingoWorld`.
- [ ] Nenhum asset runtime referencia `figma.com/api/mcp/asset/` ou URL temporária de exportação.
- [ ] GuiObject e assets aparecem uma vez, nomes de binding não faltam e nenhuma tela é duplicada.

## Registro por pacote

Ao terminar um pacote, registrar data, commit, frame/viewport inspecionado, caminho do Studio, cenários funcionais percorridos, problemas restantes e fallback mantido/removido. Até esse registro existir, o status daquela tela permanece **não verificada**.
