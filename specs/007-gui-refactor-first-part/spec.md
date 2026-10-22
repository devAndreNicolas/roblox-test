# 007 — Primeira etapa do refactor visual da GUI

**Status:** aprovada pelo usuário; implementação integrada ao template, aguardando playtest visual e funcional.
**Origem:** [feedback do playtest](research/playtest-feedback.md).
**Decisões visuais:** [design.md](design.md). **Sequência técnica:** [plan.md](plan.md). **Checklist:** [tasks.md](tasks.md).

## Problema

O lobby reúne progresso, saldo e acesso à loja num bloco visual grande. A loja aberta repete o nome da loja, usa abas e cartões altos, textos longos e cores concorrentes. O resultado ocupa espaço demais e dificulta entender onde clicar. Parte da apresentação é recalculada por Luau, por isso arrastar elementos no Studio não produz uma edição persistente.

## Objetivo

No lobby, mostrar fila e três componentes visuais independentes: **Milestone Progress**, **Ticket Balance** e **Open Shop**. Na loja, dar prioridade aos itens e às ações de compra/equipar com uma composição compacta. As duas interfaces devem usar a mesma linguagem 2D cartoon e ser ajustáveis visualmente no Studio.

## Escopo desta etapa

1. Refatorar somente a apresentação do HUD do lobby e da loja aberta, com responsividade para desktop e telefone.
2. Criar três prefabs visuais nomeados para progresso, saldo e botão de abrir loja. O saldo e o progresso podem ter instâncias nas duas telas; o botão de abrir loja aparece no lobby.
3. Migrar layout, cor, tipografia, bordas, imagens e textos estáticos desses elementos para templates editáveis no Studio. Luau continua responsável por valores dinâmicos, visibilidade de estados e callbacks.
4. Compactar cabeçalho, abas, resumo e entradas de catálogo da loja; manter as quatro categorias e todas as ofertas existentes.
5. Preservar tema da cartela, prévia, preço, propriedade, compra, equipamento, convite e estados informativos existentes. Apenas a forma de apresentar esses dados muda.
6. Manter o visual anterior como fallback até a nova apresentação passar pelos cenários de aceite.

## Fora de escopo

- Alterar regras de Bingo, fila, moeda, preços, recompensas, inventário, compras, recibos, convites, dados salvos ou contratos de rede.
- Redesenhar cartela de partida, telas de introdução/resultado ou mundo 3D nesta etapa.
- Voltar a importar arte ou composições do Figma. O design desta etapa é definido nesta spec e feito com elementos nativos do Studio; a arte das cartelas existente permanece.
- Remover fallback ou módulos antigos no mesmo passo da primeira integração.

## Requisitos de produto

- **GUI-01 — Lobby legível:** fila/estado de partida ficam visíveis sem um grande painel envolvendo saldo, progresso e loja. A ação de entrar/sair da fila continua no local de contexto da fila.
- **GUI-02 — Componentes separados:** os três componentes têm roots independentes e nomes estáveis no Explorer. É possível mover, redimensionar, trocar fonte, texto estático, imagem, cor e borda deles com o mouse ou pelo painel Properties do Studio, sem editar Luau.
- **GUI-03 — Loja compacta:** o header contém somente `SHOP` e `Close`. Um resumo fino mostra saldo e progresso. Quatro abas `TICKETS`, `CARDS`, `BOOSTS`, `INVITE` selecionam as categorias existentes. O catálogo mostra texto curto, preço/estado e ação principal sem esconder informação necessária ao jogador.
- **GUI-04 — Paleta controlada:** somente as seis cores de interface de [design.md](design.md) podem aparecer no chrome novo. Temas de cartela podem usar sua própria arte. Estados desabilitados usam transparência, não uma sétima cor fixa.
- **GUI-05 — Estilo:** formas planas, contorno escuro, cantos arredondados e motivo discreto de bilhete. Sem gradientes, brilho metálico ou sombra realista.
- **GUI-06 — Responsividade:** a mesma hierarquia atende desktop e telefone quando possível. Reorganização por layout/constraints nativos; variantes somente para composição que não cabe no telefone. Nenhum texto ou botão essencial fica sob áreas reservadas da tela.
- **GUI-07 — Dados e ações:** números, preços, progresso, itens possuídos, seleção e disponibilidade continuam sendo preenchidos pelo cliente a partir dos contratos atuais. O servidor continua autoritativo. Os nomes de binding e a adaptação necessária serão documentados no plano técnico.
- **GUI-08 — Editabilidade real:** após exportar `.rbxmx`, sincronizar pelo Rojo e abrir o Studio, a posição e a aparência salvas no template reaparecem. O controller não as sobrescreve durante a abertura nem no respawn.
- **GUI-09 — Estados compreensíveis:** selecionado, indisponível, compra em andamento, sucesso e erro são distinguíveis por texto/ícone além de cor. Áreas clicáveis em telefone têm pelo menos 44 px de altura.
- **GUI-10 — Idioma:** textos exibidos ao jogador ficam em inglês.

## Aceite visual e funcional

1. Lobby desktop e telefone mostram separadamente fila, milestone, saldo e loja, sem sobreposição e com o centro do mundo livre para jogar.
2. Loja aberta cabe em desktop e telefone; `SHOP` é o único título de cabeçalho; abas e cartões seguem as medidas de [design.md](design.md); o conteúdo principal continua rolável no telefone.
3. Em cada aba, o jogador entende item, custo/estado e ação. Todos os produtos, métodos de compra, cartão equipado e convite continuam acessíveis.
4. Alterar no Studio a posição do botão `Open Shop`, a fonte de um título e a imagem de um prefab, exportar e sincronizar mantém exatamente essas alterações após reabrir a loja e após respawn.
5. Comprar com Tickets, comprar com Robux no ambiente aplicável, equipar cartela, ver progresso/recompensa, convidar e navegar nas quatro abas continua com o comportamento anterior.
6. Se o novo template estiver ausente ou inválido, o fallback anterior abre a interface e registra o motivo para diagnóstico, sem duplicar a GUI.

## Gate de decisão

O usuário aprovou a spec antes da implementação. A validação em jogo permanece registrada em [tasks.md](tasks.md).
