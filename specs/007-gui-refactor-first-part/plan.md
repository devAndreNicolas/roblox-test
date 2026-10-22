# 007 — Plano técnico e de validação

**Status:** planejado, não autorizado para implementação. [Spec](spec.md) · [Design](design.md) · [Tarefas](tasks.md).

## Base existente

- `studio.project.json` já mapeia `StarterGui.BingoGuiDesign` para `assets/ui/BingoGuiDesign.rbxmx`; o cliente atual vive em `src/client`.
- `RewardShopController.luau` usa `RewardsShop.RewardsHud` do template quando encontra `Fichas`, `NextReward` e `OpenShop`, mas ainda define posições, tamanhos, cores e textos em código. Se o template não está disponível, gera a interface antiga. A loja usa as categorias internas `Fichas`, `Cartelas`, `Poderes`, `Convites`.
- `LobbyView.luau` também usa o template quando encontra a hierarquia esperada e possui fallback criado por código. Os estados de fila atuais dependem dos bindings existentes.
- O `.rbxmx` é a fonte versionada para Rojo. Alterações visuais feitas no Studio precisam de exportação explícita; conectar o Rojo não salva mudanças locais automaticamente.

## Integração proposta

1. Criar/organizar no `.rbxmx` roots de lobby e loja com slots visuais independentes e prefabs reutilizáveis. Cada prefab tem objetos de texto/imagem/botão nomeados para binding; não contém scripts.
2. Manter adaptadores de binding nos controllers. Eles encontram instâncias pelo caminho e classe, atualizam somente texto dinâmico, progresso, `Visible`, estado interativo e eventos. A aparência/posição/escala vêm do template. Contratos internos de tab e ações permanecem iguais.
3. Para loja: separar dados de oferta da criação da superfície, clonar uma linha visual do tipo necessário e preencher campos. Não migrar lógica de compra, moeda, recibo, ownership ou recompensa para o template.
4. Para lobby: clonar/referenciar `TicketBalance`, `MilestoneProgress` e `OpenShopButton` em slots independentes. Fila continua com seu binding atual. Remover o HUD antigo do caminho novo somente depois que o novo template estiver carregado, evitando duas cópias.
5. Usar um caminho explícito de seleção entre template novo validado e fallback antigo. Caso falte qualquer binding essencial ou classe esperada, a interface antiga aparece e registra um aviso diagnóstico. Não apagar o caminho antigo na primeira entrega.
6. Centralizar apenas utilitários de binding/estado realmente compartilhados. Não criar um framework geral de UI para esta etapa.

## Contratos que não mudam

- Categorias internas: `Fichas`, `Cartelas`, `Poderes`, `Convites`; só os rótulos visuais mudam.
- Ações de comprar por Tickets/Robux, equipar tema, abrir/fechar loja, trocar aba e convidar amigos continuam chamando os mesmos handlers atuais.
- Dados de saldo, catálogo, marcos/recompensas, propriedade, preço e disponibilidade continuam nas fontes e fluxos atuais. Nenhuma mudança de RemoteEvent/RemoteFunction, payload, persistência ou regra de servidor faz parte da 007.
- `ResetOnSpawn`, ciclo de criação/remoção e abertura/fechamento serão preservados; o novo template não pode criar telas duplicadas após respawn.

## Sequência após aprovação

1. **Template visual isolado:** preparar os cinco roots e prefabs no Studio conforme [design.md](design.md), sem tocar nas regras. Exportar `BingoGuiDesign.rbxmx`; revisar hierarquia e diff.
2. **Lobby:** integrar os três componentes e `QueueStatus` usando os bindings atuais. Fallback antigo continua. Conferir desktop e telefone, abertura da loja e respawn.
3. **Loja:** integrar shell, resumo, abas e entradas de catálogo compactas uma categoria de cada vez; cada etapa preserva compra/equipar e o fallback da tela antiga.
4. **Ajuste visual:** fazer playtest de todas as abas, revisar legibilidade e corrigir apenas medidas e copy dentro dos limites da spec.
5. **Entrega:** registrar capturas de lobby e loja abertos em desktop/telefone, resultado da reexportação e verificação funcional. Só considerar remoção de fallback em uma decisão separada.

Mudanças devem ser pequenas e separadas em Git (template, binding do lobby, binding da loja e ajustes de copy/estado), permitindo rollback pontual. Não fazer commit que misture lógica econômica com visual.

## Fluxo seguro de edição visual

1. Anotar/confirmar a versão do `.rbxmx` no Git e desconectar a sincronização Rojo antes de editar o root no Studio.
2. Editar o root ou prefab no Studio; conferir Explorer e Properties, incluindo variantes de estado.
3. Exportar o root inteiro com **Save to File** para `assets/ui/BingoGuiDesign.rbxmx`. Conferir que o arquivo mudou e revisar o diff antes de religar Rojo.
4. Conectar Rojo ao projeto correto, sincronizar e reabrir o Studio. Conferir que a mesma posição, fonte e imagem persistiram e que não há GUI duplicada.
5. Se o template local tiver sido alterado por outro trabalho, reconciliar essa diferença antes de exportar para não sobrescrever uma edição aprovada.

## Verificações planejadas para a implementação

- **Visual:** capturas de lobby e loja em desktop e 320/360 px; sem sobreposição, texto cortado ou botão abaixo da área segura.
- **Studio → arquivo → Studio:** mover `OpenShopButton`, trocar uma fonte e uma imagem; exportar, sincronizar e confirmar persistência após reabrir, jogar e respawn.
- **Navegação:** abrir/fechar loja por botão e `Close`; trocar as quatro abas; rolar lista; voltar ao lobby sem cópias extras.
- **Economia:** saldo antes/depois de compra com Tickets; preços e disponibilidade de Robux no ambiente aplicável; sucesso, falha e compra pendente visíveis sem alterar resultados existentes.
- **Recompensas e itens:** progresso diário, recompensa, prévia e equipamento da cartela, Boost e convite com estados corretos.
- **Fallback:** retirar temporariamente um binding essencial do template em ambiente local e conferir a interface antiga sem erro/duplicação; restaurar o template antes de entregar.

Nenhuma dessas verificações foi executada nesta fase de especificação.

## Referências técnicas

- [Roblox: positioning and sizing GuiObjects](https://create.roblox.com/docs/building-and-visuals/ui/positioning-and-sizing-guiobjects)
- [Roblox: UI list and flex layouts](https://create.roblox.com/docs/ui/list-flex-layouts)
- [Roblox: Font datatype](https://create.roblox.com/docs/reference/engine/datatypes/Font)
