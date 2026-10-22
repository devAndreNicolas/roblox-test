# 006 — Plano técnico: UI gerenciada pelo Roblox Studio

**Status:** Proposto, derivado dos requisitos da [spec](spec.md).  
**Contrato:** [Tarefas](tasks.md) · [Validação](validation.md).

## Arquitetura e responsabilidades

### Fontes de verdade

- **Figma:** referência aprovada para visuais, componentes, variantes e assets de origem.
- **Studio-authored `.rbxmx`:** fonte de verdade da hierarquia, layout, fontes, imagens, decoração e propriedades visuais executadas no jogo.
- **Luau client:** binding de ações, aplicação de dados dinâmicos, seleção de estado visual e clonagem de prefabs visuais.
- **Luau server:** autoridade existente para partidas, fila, recompensas, inventário, moeda e monetização. Esta feature não muda sua lógica.
- **Git/Rojo:** versionam e entregam os `.rbxmx`; Rojo não exporta de volta edições do Studio.

### Fluxo alvo

```text
Figma (origem e variantes aprovadas)
  -> inspecionar estrutura, node IDs e assets
  -> importar/representar em Roblox GuiObjects
  -> editar e conferir no Roblox Studio
  -> salvar explicitamente os roots como .rbxmx
  -> revisar diff e commitar
  -> Rojo sincroniza o modelo versionado
  -> controller clona template e conecta estado/ações existentes
```

O método de importação é escolhido na tarefa do asset spike. Pode usar FigBloxUI ou construção/editoração nativa no Studio, conforme a saída mantenha hierarquia editável, `GuiButton` funcional e propriedades que o Roblox aceita. O MCP Figma é usado para descobrir e conferir os nós e descrever assets; ele não substitui exportação e persistência dos modelos no repositório.

## Estado atual do projeto

```text
default.project.json
  StarterGui/BingoGuiDesign -> assets/ui/BingoGuiDesign.rbxmx
  ReplicatedStorage/WorldGuiTemplates -> assets/ui/WorldGuiTemplates.rbxmx
  StarterPlayerScripts/Client -> src/client
  ReplicatedStorage/Shared -> src/shared

runtime atual
  BingoController
    cria Content e compõe LobbyView, IntroView, MatchView, ResultsView
    cria RewardsShop via RewardShopController
    instancia VisualDesign e aplica propriedades do template por caminho/nome
  BingoCard
    clona Components/CardCell para suas 25 células quando disponível
  BingoWorld
    clona WorldGuiTemplates e atribui dados/Adornee às instâncias vivas
```

O `VisualDesign` atual é uma ponte visual: os módulos de view ainda criam instâncias vivas em código e a ponte copia propriedades das instâncias de mesmo caminho no modelo Studio. Isto permite personalizar elementos existentes, mas um objeto novo no `.rbxmx` não vira automaticamente parte da tela ativa. O alvo final é controller baseado em template por tela. A mudança deve ocorrer tela por tela.

## Mapeamento de projeto

```text
specs/006-studio-managed-figma-ui/
  spec.md                     # comportamento e limites
  plan.md                     # arquitetura da migração
  tasks.md                    # entregas/checklist
  validation.md               # matriz de teste no Studio
  research/figma-audit.md     # evidência e nós Figma identificados

docs/figma-ui-kit/
  INVENTORY.md                # famílias de UI e alvos existentes
  01-buttons.md               # requisitos visuais dos botões
  02-elements.md              # requisitos visuais dos elementos

assets/ui/
  BingoGuiDesign.rbxmx        # templates de ScreenGui, prefabs e tokens
  WorldGuiTemplates.rbxmx     # templates de UI no mundo
  README.md                   # exportação Studio -> Git -> Rojo

src/client/
  UI/StudioTemplate.luau      # resolve/clona templates visuais editáveis no Studio
  UI/VisualDesign.luau        # ponte de compatibilidade enquanto migra
  Features/Bingo/             # controllers/views de lobby, intro, match e results
  Features/RewardsShop/        # binding de loja e recompensas
src/server/Features/Bingo/     # mundo e UI de mundo; lógica server preservada
```

Não alterar os mapeamentos de `default.project.json` nesta migração salvo se a tarefa de um pacote demonstrar uma necessidade concreta e revisada. O projeto já monta ambos os roots de template.

## Estratégia de migração

1. **Inventariar:** acrescentar ao inventário os node IDs exatos, variantes, assets, nomes de destino e estados dinâmicos para BTN-01..16 e EL-01..16.
2. **Resolver foundations/assets:** mapear tokens do Figma a `VisualStates`/`Theme`; confirmar fontes; registrar IDs Roblox permanentes e fallbacks de imagens.
3. **Preparar prefabs:** importar componentes como hierarquias nativas em `BingoGuiDesign > Components` ou no root da tela correspondente. Os componentes clicáveis continuam `TextButton`/`ImageButton` e têm elementos de decoração como filhos.
4. **Migrar primeiro shared HUD e componentes de baixo acoplamento:** HUD desktop/mobile, recursos, progresso, OpenShop e toggles de áudio. Manter os caminhos de ação atuais.
5. **Migrar a cartela e suas composições:** CardCell é prefab; `BingoCard` recebe números/estado e clona exatamente 25 células. Tema usa assets decorativos compartilhados entre preview, intro e match.
6. **Migrar views restantes:** lobby, intro, match, results e shop; montar layouts com componentes aprovados e ajustar responsividade no Studio.
7. **Migrar world UI:** usar os templates existentes de portal, prompt, diálogo MC, chamada, instruções e cartaz.
8. **Retirar duplicação por tela:** só depois de inspeção manual em Studio, trocar o construtor da view por `Clone()` do template, adicionar controller binding e então remover o construtor duplicado daquela tela.

## Contrato controller/template

- O controller recebe `ScreenGui`/root já instanciado e resolve nós por uma função de binding tipada que falha com nome/caminho claro.
- A hierarquia preserva semântica e nomes usados atualmente. Renomes exigem alteração atômica do template, binding e validação daquela tela.
- Render atualiza apenas propriedades de dados/estados dinâmicos. Aparência de cada estado é especificada por nós nomeados/atributos/cores definidos no template.
- Template pode expor prefabs ocultos numa pasta `Components`; runtime clona e preenche os dados, sem reconstruir a identidade visual em Luau.
- Controles recebem handlers existentes via `Activated`; foco/seleção do gamepad é preservado. O controller não substitui controle por `ImageLabel` clicável.
- Repetições (cartela, lista de jogadores, ofertas) clonam um prefab de Studio e setam `Text`, imagens dinâmicas, visibilidade e estado.
- `VisualDesign` permanece ativo como adaptador temporário das views que ainda são code-built; não deve sobrepor a tela já migrada.
- Templates não devem incluir código/script, chamadas de rede ou decisões de negócio.

## Dados dinâmicos e contratos preservados

| Elemento visual | Fonte de estado atual | Regra de migração |
| --- | --- | --- |
| Fase, fila e contagem | Snapshot do Bingo e queue state | Controller mostra o mesmo estado e ações existentes |
| Números, chamadas e marcações | Estado autoritativo recebido do servidor | Só texto/estilo de célula é atualizado; regra de marcar não muda |
| Fichas, inventário, daily reward e preço | API/snapshot do RewardsShop | Não alterar catálogo, remotes ou transação |
| Robux e ownership | `RewardShopPlatformAdapter` e validação server | Botões mantêm prompt e estados existentes |
| Convite e Suborno | Contratos existentes de referral/Bingo | Imagem/UI não envia valores de grant, alvo ou número decidido pelo cliente |
| Dialogue/call display world | `BingoWorld` e `BingoService` | Servidor continua preenchendo rótulos dinâmicos |

## Assets

- Manter fontes originais exportadas em diretórios versionados por categoria, com nome estável e registro de Figma node ID, tipo, dimensões, ID publicado no Roblox e fallback.
- Salvar um asset map legível, por exemplo `assets/ui/asset-manifest.json`, quando o primeiro asset do Figma for aprovado para runtime.
- Confirmar imagem no cliente Studio antes da remoção do fallback; moderação ou asset indisponível não pode impedir o jogo.
- Arte estática pode conter decoração e ícones. Não deve conter valores, texto de compra, número ou marca de cartela, texto de botão, estado de seleção, nem informação variável.

## Responsividade

- Usar componentes nativos do Roblox como `UIListLayout`, `UIGridLayout`, `UIPadding`, `UISizeConstraint`, `UIAspectRatioConstraint` e escala apropriada.
- Aplicar o HUD de referência `6:9554` como viewport desktop e `6:9616` como viewport mobile.
- Reusar a mesma hierarquia quando as diferenças couberem em layout nativo. Criar variantes quando densidade, navegação ou ordem de conteúdo mudarem de verdade.
- Controlar safe area da plataforma no root ScreenGui e validar dispositivo em Device Emulator; layout em Figma é referência de medidas, não substituto de inspeção em Roblox.

## Falhas e reversão

- Template ausente/incompatível: fallback daquela view continua disponível e registra diagnóstico com tela/caminho; não bloquear o join ou partida.
- Binding de objeto obrigatório ausente: não ocultar erro silenciosamente; usar fallback da tela toda até corrigir o template.
- Imagem inválida/não moderada: tema/fundo nativo aprovado aparece.
- Export de Studio com diff inesperado: restaurar o `.rbxmx` via Git antes de reconectar/sincronizar Rojo.
- Regressão funcional após migração: restaurar binding/construtor legado apenas para a tela afetada; preservar migrações já validadas.

## Decisões para validar no spike

- Se FigBloxUI produz objetos que preservam Auto Layout, variants e estilos em forma editável no Studio para as famílias necessárias.
- Qual família de fontes do Roblox substitui com fidelidade aceitável as fontes Figma, caso as originais não possam ser usadas.
- Quais assets ficam como imagens e quais são reconstruídos com objetos nativos para preservar edição de layout e texto.
- Qual formato/pasta de `.rbxmx` dá o menor diff revisável por lote sem duplicar roots já montados por Rojo.
