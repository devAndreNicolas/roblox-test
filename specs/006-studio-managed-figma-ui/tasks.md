# 006 — Tarefas: migrar UI do Figma para o Studio

**Fonte:** [Spec](spec.md) e [plano técnico](plan.md).  
**Status:** SDD concluída; piloto Studio → `.rbxmx` → Git → Rojo validado. Importação dos componentes Figma e migração das telas ainda não iniciadas.

## Descoberta e inventário

- [x] Confirmar conexão Figma e acesso a metadados, screenshot e contexto de componentes.
- [x] Identificar os sete frames/boards principais e suas categorias.
- [x] Mapear as famílias de UI atuais do jogo em `docs/figma-ui-kit/INVENTORY.md`.
- [ ] Completar node IDs para cada master e variante BTN-01..BTN-16 e EL-01..EL-16.
- [ ] Registrar arquivo, componente, variantes, assets, node IDs, destino e estado dinâmico no mapa definitivo desta feature.
- [ ] Conferir quais telas existem como composições finais no Figma; manter explícitas as telas que serão montadas usando componentes.

## Pipeline Figma → Studio → Git → Rojo

- [ ] Fazer spike de importação Figma → Roblox de um componente estático e um controle interativo; o piloto já validou o round-trip Studio → `.rbxmx` → Rojo, mas não a fidelidade da importação Figma.
- [ ] Documentar instalação/versão e fluxo de exportação/importação escolhido para cada família.
- [x] Criar manifesto inicial dos assets visuais já publicados e referenciados pelo jogo; associar nodes de origem Figma assim que a cota permitir.
- [ ] Confirmar nomes/classes, constraints e propriedades que sobrevivem a `.rbxmx` → Git → Rojo → Studio.
- [ ] Registrar passo seguro para exportar de volta mudanças visuais do Studio e restaurar fallback após conflito.

## Foundations e prefabs

- [ ] Mapear tokens de cor/tipografia/spacing do Figma para propriedades editáveis em Studio.
- [ ] Validar fontes disponíveis no Roblox e registrar fallback aprovado.
- [ ] Importar botões, painéis, tabs, superfícies, notificações, feedbacks, foco e loading/error states.
- [ ] Importar áudio, ícones, wordmark e ornamentos que forem aprovados para runtime.
- [ ] Criar/atualizar prefabs Studio para CardCell, temas de cartela, linhas de ofertas e linhas de ranking.
- [ ] Revisar legibilidade da cartela, marcação e foco com cada tema.

## Migração por tela

- [ ] Migrar shared HUD (desktop/mobile), saldo, progresso diário, loja e áudio.
  - [x] Fazer o primeiro corte: clonar `RewardsShop > RewardsHud` do template e bindar saldo, marco e ação `OpenShop`, com construtor anterior como fallback.
  - [x] Clonar `MusicToggle` e `EffectsToggle` do template, preservando handlers e estado de áudio existentes.
  - [x] Clonar `RewardsShop > UseSuborn` do template, preservando as validações e a ação existentes.
  - [ ] Validar o corte em Studio desktop/mobile antes de marcar a fatia como migrada.
- [ ] Migrar LobbyView preservando estado de fila e retry.
  - [x] Clonar `Content > LobbyView` do template e bindar textos/status/retry; manter o construtor anterior como fallback.
  - [ ] Validar estados de fila, retry e responsividade em playtest.
- [ ] Migrar IntroView preservando falas, skip e preview da cartela.
  - [x] Clonar `Content > IntroView`, bindar caption/skip e manter cartela dinâmica; manter o construtor anterior como fallback.
  - [ ] Validar falas, skip e cartela com tema equipado em playtest.
- [ ] Migrar MatchView preservando chamadas, marcações, race, history, Suborno e pause.
- [ ] Migrar ResultsView preservando win/loss/draw, detalhes e skip.
  - [x] Clonar `Content > ResultsView` e bindar resultado, animação de entrada e skip; manter o construtor anterior como fallback.
  - [ ] Validar win/loss/draw e skip em playtest.
- [ ] Migrar RewardShopController preservando navegação, preços, prompts, compras, ownership, daily reward e referrals.
- [ ] Migrar `WorldGuiTemplates` e respectivos consumidores preservando texto dinâmico, prompt e `Adornee`.
- [ ] Remover construtores visuais duplicados e fallback só por tela validada; manter fallback para demais telas.

## Verificação e entrega

- [ ] Inspecionar cada tela no Studio em desktop e telefone.
- [ ] Conferir toque, gamepad/teclado, foco, clipping, safe area e ajuste de texto.
- [ ] Conferir estado inicial, transições, visibilidade, loading/success/error e recurso ausente.
- [ ] Verificar que compras, Fichas, recompensas, convites, dados e estado de partida seguem os contratos sem alteração.
- [ ] Salvar `.rbxmx`, revisar diff por lote e registrar commits pequenos.
- [ ] Atualizar status da spec/tasks/validation com evidência real de Studio/playtest.
