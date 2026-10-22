# 006 — Migração de UI Figma para templates gerenciados no Studio

**Status:** Migracao Studio em andamento: HUD compartilhado e loja usam templates editaveis. A importacao dos componentes individuais do Figma segue bloqueada pela cota MCP do plano Starter.
**Objetivo:** fazer com que toda a aparência da interface do Bingo Noir seja editável no Roblox Studio, preservando a lógica e os contratos atuais em Luau.  
**Relacionados:** [Plano técnico](plan.md) · [Tarefas](tasks.md) · [Validação](validation.md) · [Auditoria Figma](research/figma-audit.md) · [Inventário de UI](../../docs/figma-ui-kit/INVENTORY.md) · [Instruções de assets e exportação](../../assets/ui/README.md).

## Resultado de produto

O time consegue ajustar layout, dimensões, fontes, cores, imagens, superfícies, ícones, decoração e estados visuais no Roblox Studio. Jogadores continuam recebendo os mesmos estados e ações do jogo: fila, partida, cartela, recompensas, loja, compras e feedback.

O Figma define a referência visual aprovada. Os modelos `.rbxmx` exportados e versionados no repositório definem a aparência que Rojo entrega ao Studio. Rojo não deve ser tratado como mecanismo de gravação das alterações visuais feitas no Studio.

## Escopo

### Incluído

- Todos os elementos e estados de UI existentes no cliente: HUD, lobby, introdução, partida, resultados, loja, recompensas, cartela, navegação, áudio, feedback, carregamento e erros.
- Elementos de UI no mundo: sinalização do portal, instruções, cartaz de vitória, letreiro, exibição de chamadas, diálogo do MC e prompt de fila.
- Variantes desktop/mobile quando o layout realmente mudar; adaptação responsiva com componentes nativos sempre que possível.
- Componentes reutilizáveis do arquivo Bingo Noir no Figma: botões, painéis, abas, estados de foco/seleção/erro/sucesso, ícones e artes exportáveis.
- Fluxo versionado Figma → Studio → `.rbxmx` → Git → Rojo → Studio.
- Migração gradual dos controllers para que carreguem hierarquias editáveis do Studio e conectem a lógica existente.

### Fora de escopo

- Mudanças em regras de Bingo, fila, economia, recompensas, compras, convites, dados persistidos ou contratos de RemoteEvents/RemoteFunctions.
- Redesign ou comportamento novo que não esteja aprovado no Figma ou nas specs atuais.
- Substituir texto, números, estado de jogo ou controles interativos por imagens achatadas.
- Importar quadros de referência, tokens e documentação de acessibilidade como telas exibidas ao jogador.
- Reescrever o jogo inteiro ou remover os fallbacks antes da validação individual das telas.

## Termos

- **Template de tela:** hierarquia de `GuiObject` e componentes nativos armazenada em `.rbxmx`, editável visualmente no Studio.
- **Controller:** módulo Luau responsável por conectar ações e representar dados/estados do jogo usando um template.
- **Prefab visual:** componente aprovado e reutilizável, como célula da cartela, botão, linha de oferta ou notificação.
- **Instância de binding:** objeto cujo nome e tipo são lidos por um controller como contrato de integração.
- **Asset runtime:** imagem/modo visual publicado no Roblox e referenciado por ID estável, não por URL temporária do Figma.
- **Fallback:** implementação visual existente que continua disponível enquanto uma tela migra.

## Requisitos

### Propriedade visual e edição

- **UI-01 — Fonte visual:** todo elemento visual enviado ao jogo MUST pertencer a um template editável pelo Studio ou a um prefab visual em um template. O Figma serve como fonte de design e auditoria, não como dependência de runtime.
- **UI-02 — Hierarquia Studio:** telas e componentes MUST preservar uma hierarquia clara e nomes estáveis para que o usuário consiga encontrá-los e editá-los no Explorer.
- **UI-03 — Visual não codificado:** controllers MUST NOT definir identidade visual nova por valores arbitrários de cores, fontes, decoração ou posições. Podem aplicar estado visual definido no template, atualizar propriedades dinâmicas, clonar prefabs e configurar layout necessário para o viewport atual.
- **UI-04 — Editabilidade:** textos estáticos podem ser editados no Studio. Números da cartela, moeda, preços, progresso, timers, nomes, mensagens de estado e demais valores originados do jogo MUST permanecer texto nativo e continuar sendo atualizados pelo controller.
- **UI-05 — Interação nativa:** ações clicáveis MUST permanecer objetos `GuiButton` nativos, acessíveis por mouse/toque e navegação de gamepad/teclado conforme o controle atual. Arte do Figma pode decorar esses botões, mas não substituí-los.
- **UI-06 — Componentes reutilizáveis:** itens repetidos — 25 células de cartela, linhas da loja, linhas de ranking e controles recorrentes — MUST ser clonados de prefabs visuais do Studio, com dados aplicados pelo Luau.

### Escopo de interfaces

- **UI-07 — Cobertura de tela:** a migração MUST cobrir lobby e HUD, introdução, partida, resultados, loja/recompensas, prévias de cartela, áudio e feedback.
- **UI-08 — UI de mundo:** a migração MUST cobrir templates de sinalização e displays de mundo em `WorldGuiTemplates`, preservando texto e comportamento preenchidos pelo servidor.
- **UI-09 — Componentes Figma:** os componentes aprovados MUST ser mapeados aos elementos existentes em `INVENTORY.md`, incluindo variantes necessárias. Cada origem Figma, estado, destino Studio e eventual asset exportado deve constar no mapa de importação dentro desta feature.
- **UI-10 — Cobertura visual real:** o arquivo atual do Figma fornece fundamentos, biblioteca de componentes e estados, artes de feedback/áudio e composições HUD desktop/mobile. Telas sem uma composição completa no Figma MUST ser montadas com componentes aprovados sobre as composições existentes do jogo. Nenhum layout ausente pode ser apresentado como já aprovado pelo Figma.

### Responsividade, leitura e estados

- **UI-11 — Viewports:** as telas MUST funcionar em telefone e desktop. Preferir `UIListLayout`, `UIGridLayout`, `UIPadding`, constraints e tamanhos em escala; manter variantes distintas só quando uma composição comum não atender aos dois contextos.
- **UI-12 — Área segura:** textos, ações essenciais e informação da partida MUST respeitar áreas reservadas pela plataforma e permanecer dentro do viewport.
- **UI-13 — Legibilidade:** números e texto essenciais MUST manter contraste, tamanho e ajuste adequados; estado não pode ser comunicado somente por cor ou som.
- **UI-14 — Estados completos:** controles e superfícies MUST ter os estados aplicáveis (normal, hover, pressionado, foco, selecionado, desabilitado, carregando, sucesso e erro). Estados que não fazem sentido para um elemento não precisam ser artificiais.
- **UI-15 — Cartelas:** a aparência da cartela MUST manter letras, números, marcas, número gratuito e foco como UI nativa. Tema decorativo deve ser consistente na prévia da loja, introdução e partida, com fallback Clássico.

### Compatibilidade, segurança e migração

- **UI-16 — Contratos de jogo:** a migração MUST preservar nomes/classes esperados pelos controllers ou fornecer uma adaptação documentada antes da troca. Não alterar remotes, payloads, fluxo de compras, moeda, recompensa, inventário, fila ou estados de partida como parte da importação visual.
- **UI-17 — Propriedade da lógica:** cliente continua solicitando ações; servidor continua sendo autoridade para partidas, moeda, ownership, recompensas e recibos. Templates não incluem scripts de jogo.
- **UI-18 — Fallback:** implementação antiga MUST permanecer utilizável por tela até a nova integração ser verificada em Studio. A remoção do fallback de uma tela requer conclusão dos critérios dessa tela.
- **UI-19 — Assets:** todo asset estático enviado ao runtime MUST usar ID permanente do Roblox e estar registrado com nome, origem Figma, destino e fallback. URLs temporárias do Figma MUST NOT ser salvas como `Image` de runtime.
- **UI-20 — Exportação:** alterações feitas visualmente no Studio MUST ser salvas explicitamente como `.rbxmx` no caminho Rojo correspondente antes de sincronizar. O fluxo deve verificar diff do Git e evitar sobrescrever uma edição não exportada.
- **UI-21 — Migração gradual:** cada pacote MUST migrar uma tela ou família visual, ter diff revisável e ser revertível sem bloquear as telas que ainda usam o fallback.

## Cenários de aceitação

### Editar aparência no Studio e manter após sincronização

**Dado** um template de tela migrado e versionado  
**Quando** o usuário altera fonte, imagem ou layout no Studio, salva o root como `.rbxmx`, inspeciona o diff e sincroniza pelo Rojo  
**Então** o jogo mantém a edição, ela é visível no Studio e não aparece uma cópia duplicada da tela.

### Preservar dados dinâmicos e ações

**Dado** que uma tela migrada exibe saldo, preço, progresso, número ou estado de partida  
**Quando** o snapshot do jogo muda ou o jogador ativa um botão  
**Então** Luau atualiza o valor correto e mantém a ação existente, sem transformar dados em parte de uma imagem estática.

### Manter a mesma cartela em loja e partida

**Dado** um tema de cartela selecionado  
**Quando** o jogador o vê na prévia da loja, introdução e partida  
**Então** moldura e decoração correspondem, enquanto grade, números, marcas e estado continuam nativos e corretos.

### Preservar compra, economia e recompensa

**Dado** uma tela de loja/recompensas migrada  
**Quando** o jogador navega, compra com Fichas, abre um prompt Robux, equipa um tema ou reclama recompensa  
**Então** os mesmos remotes, validações de servidor e contratos atuais são usados, com os estados visuais correspondentes.

### Adaptar-se a telefone e desktop

**Dado** um telefone ou desktop em viewport suportado  
**Quando** qualquer tela migrada aparece ou redimensiona  
**Então** ações essenciais, textos e informação ficam legíveis, dentro da área segura e sem sobreposição/clipping indevido.

### Recuperar-se de asset ou template ausente

**Dado** que um asset ou template não está disponível  
**Quando** a tela é aberta  
**Então** ela mostra o fallback definido e a lógica de jogo continua funcionando.

## Decisões pendentes

- Completar a lista de IDs de masters/variantes do Figma quando a cota do MCP permitir leitura; não inferir IDs.
- Verificar no Studio se as fontes escolhidas no Figma existem ou precisam de uma substituição equivalente aprovada.
- Determinar por família qual importador gera estruturas nativas mais fáceis de editar e preservar como `.rbxmx`.
- Montar as composições completas de loja, lobby, intro, partida e resultados, pois a leitura atual encontrou composições HUD e bibliotecas, mas não frames completos para todas essas telas.
