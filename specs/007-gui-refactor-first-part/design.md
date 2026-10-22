# 007 — Design da primeira etapa

**Status:** proposta para aprovação. Medidas em pixels de interface Roblox, sujeitas apenas a ajustes de área segura/escala durante a integração.

## Direção visual

**Bingo Noir cartoon:** palco azul escuro, bilhete creme e foco dourado. Superfícies planas com contorno de 2 px, raios de 12 px nos cartões e 16 px no modal. Um pequeno recorte/perfuração de bilhete identifica o progresso; o resto da interface usa formas simples para não competir com o mundo e com a arte das cartelas. Ícones e imagens são `ImageLabel`/`ImageButton` dentro de prefabs editáveis no Studio; nenhum deles substitui texto de preço, número ou ação.

## Paleta: seis cores e funções

| Cor | Hex | Uso permitido |
| --- | --- | --- |
| Night | `#101A33` | contorno, fundo de modal, texto sobre creme |
| Stage Blue | `#233B68` | painéis elevados e abas inativas |
| Ticket Cream | `#FFF4D8` | texto sobre azul, cartões claros e área de catálogo |
| Spotlight Gold | `#F2B84B` | ação principal, aba selecionada, progresso/marco |
| Mark Green | `#17775B` | sucesso, item equipado e marca confirmada |
| Alert Rose | `#D6485C` | erro, falha e ação inválida |

Não usar uma cor diferente por categoria. Estados neutros e indisponíveis derivam dessas cores por transparência/opacidade. Imagens de temas de cartela podem ter cores próprias dentro do recorte da arte; moldura, preço e botões permanecem nesta paleta. Contraste de texto será verificado no Studio; se uma combinação falhar, troca-se a cor de texto por Night ou Ticket Cream, sem criar nova cor.

## Tipografia e elementos

| Elemento | Fonte | Tamanho alvo |
| --- | --- | --- |
| Títulos, saldo e números grandes | Fredoka One | 20–24 |
| Nome de item e preço | Builder Sans Bold | 15–17 |
| Botão e aba | Builder Sans Bold | 13–15 |
| Descrição curta e estado | Builder Sans | 13–14 |
| Nota auxiliar indispensável | Builder Sans | 12–13 |

Usar `TextScaled`/constraints somente para limites reais de tela e evitar reduzir texto normal abaixo de 12 px. Botões de toque: altura mínima de 44 px. O estado selecionado combina contorno/ícone/texto com Spotlight Gold; disponibilidade não depende só da cor.

## Tela 1: lobby inicial

### Desktop (referência: viewport ≥ 900 px)

```text
┌──────────────────────────────────────────────────────────────────────┐
│ [QUEUE: status + players + Join/Leave]     [Tickets 000] [Open Shop]│
│                                         [Milestone 3/7 ▰▰▰□□□□]      │
│                                                                      │
│                  mundo 3D e personagens livres                       │
└──────────────────────────────────────────────────────────────────────┘
```

- `QueueStatus`: topo esquerdo, largura até 340 px, altura alvo 112 px; título de estado, uma linha explicativa, contagem e ação de fila. Eliminar masthead, selo `LIVE` e barra decorativa que repetem informação. Estados de fila atuais continuam.
- `TicketBalance`: topo direito, pill de aproximadamente 138 × 48 px; ícone de ticket opcional, número e `TICKETS`.
- `OpenShopButton`: ao lado do saldo, aproximadamente 132 × 48 px, texto `SHOP` com ícone opcional. A ação existente continua.
- `MilestoneProgress`: logo abaixo do par saldo/loja, aproximadamente 278 × 58 px; `DAILY MILESTONE`, `3/7`, barra e próximo prêmio em uma linha curta. Dados reais substituem os exemplos.
- Margens externas alvo de 20–24 px; espaçamento de 8 px. O centro da tela não recebe overlay.

### Telefone (referência: 360 × 740 px e largura mínima de 320 px)

```text
┌─────────────────────────────────┐
│ [Tickets 000]      [SHOP]       │
│ [Milestone 3/7 ▰▰▰□□□□]         │
│ [QUEUE: status + count + Join]  │
│                                 │
│          mundo 3D               │
└─────────────────────────────────┘
```

- Margem lateral de 12 px dentro da área segura. Primeira linha com dois botões/pills de pelo menos 44 px de altura. Milestone com 52–60 px; QueueStatus compacto de 96–118 px.
- O conteúdo interno adapta largura; nada depende de coordenadas absolutas de viewport. Se o texto de fila crescer, o painel pode aumentar em altura sem cobrir os controles de topo.
- Elementos de áudio e outros HUDs atuais mantêm suas funções; a implementação verifica conflitos de posição antes de mover qualquer um.

## Tela 2: loja aberta

### Desktop (referência: viewport ≥ 900 px)

```text
┌──────────────────────────────────────────────────────────────┐
│ SHOP                                                   [X]  │
│ [Tickets 000]                     [Daily milestone 3/7 ▰▰▰] │
│ [ TICKETS ] [ CARDS ] [ BOOSTS ] [ INVITE ]                  │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ Item + informação essencial            Preço   [Action] │ │
│ │ Item + informação essencial            Preço   [Action] │ │
│ │ ... conteúdo rolável                                     │ │
│ └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

- Modal central: largura máxima de 800 px e altura máxima de 560 px; margens de pelo menos 20 px em telas menores. Contorno Night de 2 px, fundo Stage Blue e catálogo em Ticket Cream.
- Header de 48–52 px: somente `SHOP` (22–24 px) e `Close` (44 × 44 px). Remover `BINGO NOIR / SHOP` e `THE STAGE SHOP` da composição nova.
- Resumo de 52–60 px: saldo e progresso, sem repetir instruções longas. Abas com altura 44 px e vão de 6–8 px. A barra de abas é única; não usar grande título e subtítulo em cada categoria.
- Catálogo com padding de 12–16 px e intervalo de 8 px. Linhas de pacotes de Tickets: 88–96 px; linha de ganhar jogando: até 76 px; cards de tema: 112–128 px; Boost: até 156 px; Invite: até 144 px. Uma imagem de cartela usa a arte real já disponível; não substituí-la por bloco de cor.
- Estrutura de item: imagem ou ícone à esquerda, nome + uma frase curta no centro, estado/preço e CTA à direita. Se houver duas opções de compra, ambas aparecem com rótulos claros `TICKETS` e `ROBUX`/ícone oficial Robux conforme o contrato atual; o preço real vem da lógica atual. Não prometer preço fictício.

### Telefone (referência: 360 × 740 px e largura mínima de 320 px)

- Modal ocupa a área segura com inset lateral de 8–12 px. Header e resumo fixos; catálogo rola dentro do modal. `Close` sempre acessível.
- Em 360 px, quatro abas em uma linha se cada alvo mantiver ao menos 44 px de altura e rótulo legível. Em 320 px, reorganizar em grade 2 × 2; não reduzir o toque para caber.
- Os cartões usam imagem pequena e texto curto; botões de compra ficam em uma linha inferior quando o espaço horizontal faltar. Altura pode crescer nesse caso. Informação obrigatória e condições de compra permanecem visíveis.
- A coluna de catálogo é única; não criar uma tela mobile duplicada inteira. Só o arranjo das abas e ações de item muda quando necessário.

## Copy proposta, sujeita aos dados reais

| Contexto | Texto estático curto |
| --- | --- |
| Título | `SHOP` |
| Abas | `TICKETS`, `CARDS`, `BOOSTS`, `INVITE` |
| Ganhar Tickets | `Play matches to earn Tickets.` |
| Tema de cartela | `Choose a look for your Bingo card.` |
| Boost | `One bonus call for everyone. Limited per match.` |
| Convite | `Invite a friend. Play together to unlock a reward.` |
| Ações | `BUY`, `EQUIP`, `EQUIPPED`, `INVITE FRIEND` |

Os detalhes exatos de recompensa, limite e condição continuam vindos das regras existentes; a copy final não pode contradizer o comportamento real. Mensagens de compra simulada/indisponível permanecem quando aplicáveis, próximas ao botão afetado.

## Edição no Studio

`QueueStatus`, `TicketBalance`, `MilestoneProgress`, `OpenShopButton` e `ShopModal` são roots separados/identificáveis no template. O usuário arrasta os roots ou seus slots para ajustar posição e redimensiona os filhos visuais no Studio. Prefabs de item ficam numa pasta `Prefabs`, com variantes de estado editáveis; o controller clona e preenche dados.

`UIListLayout` e `UIGridLayout` podem controlar a posição dos filhos; nesses grupos, mudar a ordem é feito por `LayoutOrder`, e mover o grupo é feito pelo parent/slot. Onde o ajuste livre de um item é requisito, esse item não ficará sob um layout que sobrescreva `Position`. O controller não define cores, fontes, bordas, imagens ou coordenadas finais dos elementos migrados.
