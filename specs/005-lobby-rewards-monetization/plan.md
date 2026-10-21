# 005 — Plano Técnico: Recompensas, Coleção e Loja

**Status:** Implementado em fonte como protótipo; cinco imagens de cartela e nove ícones de oferta enviados, com nove ofertas Robux criadas na experiência experimental. Uma compra simulada de Fichas confirmada; compras restantes e validação multiplayer pendentes.
**Contrato:** [Spec](spec.md) · [Tarefas](tasks.md) · [Validação](validation.md).

## Limites de arquitetura

Toda concessão, gasto, ownership, progresso, estoque, vínculo de convite e efeito de partida é validado no servidor. UI apenas apresenta catálogo/estado e envia intents. `BingoService` permanece dono do ciclo de partida e expõe uma operação interna limitada para pedir/confirmar o `SubornAnnouncement`; a feature de economia não altera chamadas diretamente.

Separar responsabilidades por feature, reutilizando os padrões atuais do repositório e sem adicionar framework:

- `PlayerDataService`: carrega e persiste perfil versionado, sessão e transações idempotentes. Não contém regras de Bingo.
- `EconomyService`: operações primitivas de crédito e gasto de Fichas. A deduplicação por partida/recibo fica na mutação atômica do perfil que chama essas operações. Saldo não é editável pelo cliente.
- `DailyRewardsService`: progresso e payout de marcos; consome conclusão confiável da partida, delega transação ao Economy e concessão de tema ao Inventory.
- `InventoryService`: ownership/equipamento de temas e conversão de duplicata; o estoque de Subornos fica no perfil e é alterado pelo serviço de recompensas/loja. Não toma decisão de vitória.
- `ShopService`: consulta catálogo, valida ownership/fundos e coordena compra em Fichas. Não controla APIs de recibo.
- `ReferralService`: valida atribuição compatível com convite da plataforma, registra vínculo e entrega prêmio idempotente quando a primeira partida elegível é concluída.
- `ReceiptService`: recebe recibos, mapeia IDs de produtos configurados e coordena concessões persistentes idempotentes por `PurchaseId`.
- `BingoService`: valida fase/limites e resolve reserva do Suborno, anúncio compartilhado, tempo de pausa e refund de reserva não commitada.
- `RewardShopController`/views: telas de lobby, catálogo, detalhe/compra, trilha, inventário e feedback. Não leem DataStore nem decidem concessões.

Cada módulo é inicializado pelo composition root atual de forma explícita e possui contratos tipados no Shared quando cliente e servidor precisam deles. Nunca replicar números de cartela ou estado privado de outros jogadores para implementar uma loja/estandarte.

## Mapeamento proposto

```text
src/
  client/Features/RewardsShop/
    RewardShopController.luau
  server/Features/
    PlayerData/PlayerDataService.luau
    Economy/EconomyService.luau
    Rewards/DailyRewardsService.luau
    Rewards/ReferralService.luau
    Rewards/RewardsService.luau
    Inventory/InventoryService.luau
    Shop/ShopService.luau
    Monetization/ReceiptService.luau
    Bingo/BingoService.luau                    # integração pequena, não duplicar máquina de estado
  shared/Features/RewardsShop/
    RewardCatalog.luau
assets/
  bingo/card-skins/concept-sheet.png            # prancha de referência, não runtime
  bingo/card-skins/source/                      # PNGs originais por skin, aguardando importação
```

IDs de assets aprovados no Roblox são configuração de runtime em `RewardCatalog.luau`; arquivos de origem permanecem sob `assets/`. O `ImageLabel` da moldura vai para uma camada atrás da grade nativa. Enquanto IDs estiverem vazios, cada tema usa fundo, faixa e borda nativos distintos. Nada de achatamento de números, letra BINGO, checkmarks, texto ou estados na imagem.

## Perfil e transações

Perfil inicial versionado: `schemaVersion`, `revision`, `fichas`, `dailyIndex` (0–6), `dailyCycles`, `lastDailyDay`, `ownedThemes`, `equippedTheme`, `suborns`, `processedMatches`, `referralRewards` e `processedPurchases`. Campos ausentes recebem defaults na leitura; novas versões de esquema exigirão migrações próprias. Definir retenção/compactação das chaves de idempotência antes de escala ampla. Perfil indisponível bloqueia compra ou poder e não apresenta concessões como persistidas.

O protótipo usa DataStore no servidor com chamadas protegidas e escrita atômica via `UpdateAsync` para cada mutação. Não há flush de perfil em cache no fim da sessão: operações concorrentes passam pelo mesmo `UpdateAsync`, inclusive de outro servidor, evitando sobrescrita por snapshot antigo. O cache serve à UI e só aceita revisão igual ou mais nova; pedido periódico de estado atualiza recompensas de convites vindos de outro servidor. Callbacks não podem yield. Cada operação de economia tem identidade deduplicável e commit único; para recibos, `PurchaseId` e concessão ficam na mesma transação. As tabelas de idempotência crescem com o uso; definir política de escala antes de produção ampla sem reabrir recibos antigos.

O perfil usa uma interface pequena de armazenamento (`Read`, `Update`, `PurchaseMode`, `CanGrantReceipt`, `ShouldReconcilePasses`). `default.project.json` monta o adaptador de DataStore real; `studio.project.json` acrescenta o adaptador temporário e a simulação de passe em `tests/studio/`. O projeto publicado não contém scripts de simulação, e o adaptador real recusa acesso quando aberto no Studio sem a montagem de teste. O cliente lê `purchaseMode` do snapshot e só usa o evento opcional de simulação quando o adaptador de teste está presente.

Fluxo de Developer Product:

```text
prompt no cliente -> recibo no servidor -> validar ProductId/PurchaseId
 -> mutação idempotente no perfil -> confirmação de concessão -> PurchaseGranted
```

Falha/indisponibilidade antes de gravar devolve decisão de tentar novamente. Um callback repetido encontra o mesmo `PurchaseId` e não aumenta estoque novamente. ID desconhecido não concede nada e permanece visível em log operacional para corrigir configuração.

## Fluxo do Suborno

1. UI pede ativação sem parâmetros de número/alvo.
2. Servidor verifica participante, fase `Calling`, saldo/estoque, limite pessoal/global, pausa concorrente e número elegível.
3. Reservar uma unidade em `UpdateAsync` com token de operação; após confirmação, iniciar `SubornAnnouncement` com snapshot público sem expor cartão completo. A partida continua enquanto a escrita está em andamento; antes do anúncio, validar novamente fase, participante e números elegíveis.
4. MC apresenta o número por dois segundos; todos ficam sem marcação; relógio preserva o intervalo normal de 5s.
5. Publicar a chamada comum para todos, marcar a reserva como resolvida e permitir que jogadores marquem normalmente.
6. Se operação for invalidada antes do commit, cancelar apresentação e reverter a reserva usando token idempotente.

Todos os passos críticos de validar fase, contador e chamada final são serializados no dono da máquina de estado; não ceder execução entre validar e reservar. `SubornAnnouncement` deve ser adicionado à máquina de estado explícita do Bingo e a todos os consumidores de snapshots/UI/relógio.

## Catálogo e apresentação

Catálogo central define `itemId`, nome, tipo, métodos de obtenção, custo em Fichas, product/pass ID configurado, asset ID, ordem, ownership permanente ou consumível e fallback. Ele inclui três pacotes repetíveis de Fichas (+120/+350/+800) como Developer Products. O único `ProcessReceipt` encaminha cada Product ID configurado à concessão correspondente e grava `PurchaseId` junto com Fichas ou estoque na mesma mutação atômica. Vistas recebem catálogo + saldo + ownership; preços Robux exibidos vêm da informação atual da plataforma. Nunca confiar em preço, nome ou ProductId enviado pelo cliente.

Skin usa superfície sob grade e números dinâmicos. A imagem deve ter área central transparente/limpa, margem segura e detalhes somente nas bordas para não competir com 25 células. Se `ImageLabel` falhar, imagem não moderada ou asset ID vazio, aplicar frame Clássico sem bloquear a partida. Testar tema em 360×640 e 1280×720 com número maior, célula marcada, célula chamada e FREE.

## Falhas e observabilidade mínima

- DataStore falha: bloquear gasto/grant não confirmado, preservar compra pendente e dar estado/mensagem recuperável.
- Recibo repetido: retornar sucesso sem repetir a concessão.
- Cartela/partida encerra antes do Suborno resolver: liberar reserva e não publicar chamada extra.
- Referral sem sinal confiável da plataforma: não recompensar nem aceitar campo vindo do cliente como substituto.
- Skin inválida: fallback local Clássico; jogo continua.
- Registrar logs de servidor com IDs de transação, não expor token/estado privado. Métricas do MVP podem ser contadores internos/eventos já disponíveis: partida concluída, marco reclamado, compra confirmada, Suborno ativado/resolvido/refundado, retorno D1/D7 conforme dados de produto acessíveis. Evitar construir pipeline analítico antes de existir uma decisão que ele responda.

## Decisões abertas para evidência

- Testar se Fichas por partida tornam skins de 700 Fichas alcançáveis sem deslocar a atenção da partida.
- Testar entendimento, justiça percebida e uso do Suborno, especialmente entre as personas criança e adolescente.
- Observar se as quatro categorias da Loja permanecem claras em telefone e se as prévias de cartela ajudam a escolha.
- Ajustar a coleção depois de observar quais temas são equipados, sem tratar compra Robux como proxy de diversão.
