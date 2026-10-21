# 005 — Configuração para publicar

O protótipo já funciona com Fichas. As nove ofertas Robux foram criadas na experiência `BINGO Experimental` em 20/10/2026, ficaram à venda pelos preços-alvo e seus IDs estão no catálogo compartilhado. Cada oferta recebeu um ícone próprio; as cinco imagens de cartela também foram enviadas ao Roblox. A visibilidade no jogo publicado depende da moderação e das permissões do asset. **Publicar a experiência no Roblox não exige abri-la ao público.**

## Como testar sem lançamento público

1. Manter a experiência em acesso **Playtest** e liberar somente as contas de teste em Creator Dashboard → Publish settings → Manage Audience → Manage access. Assim ela fica publicada na plataforma, porém acessível só a colaboradores e convidados de teste.
2. Encerrar o servidor Rojo anterior, iniciar `rojo serve studio.project.json`, conectar o plugin e reiniciar o playtest. `default.project.json` contém apenas o jogo de produção e bloqueia acesso aos perfis reais quando executado no Studio; `studio.project.json` monta os adaptadores em `tests/studio/`. As ferramentas [scripts/sync_monetization.py](../../scripts/sync_monetization.py) e [scripts/upload_offer_icons.py](../../scripts/upload_offer_icons.py) cadastram ofertas e ícones; a chave da API fica fora do repositório, no arquivo informado ao argumento `--key-file`. Não precisa de `.env` para este fluxo.
3. Para testar **compras sem gastar Robux**, deixar **Enable Studio Access to API Services** desligado. O perfil entra em `TESTE SEM SALVAR`. Developer Products (Fichas e Suborno) usam o prompt simulado do Studio; no projeto `studio.project.json`, passes de cartela são concedidos pelo script em `tests/studio/`, pois o Studio reporta que a conta criadora já possui seus passes e bloqueia o prompt nativo. Tudo fica somente na memória da sessão. Reiniciar o playtest zera esse progresso. Usar Test/Play e, para dois jogadores, um teste local com múltiplos clientes.
4. Para testar **persistência**, habilitar Studio Access to API Services somente nesta experiência de teste. Nosso código usa `BingoNoirPlayer_Studio_v1`, separado do perfil do cliente publicado. Nesse modo, os prompts de compra simulada ficam desativados para evitar salvar uma compra fictícia. Ganhar Fichas, comprar com Fichas, sair e reentrar testa a persistência.
5. Para testar **compra e persistência juntos**, entrar pelo aplicativo Roblox na experiência de acesso restrito com uma conta de teste. Ali a compra usa Robux reais; não é um simulador gratuito. Conferir produto barato primeiro, `ProcessReceipt`, inventário e reconexão.

O teste gratuito do Studio valida UI e recibos dos Developer Products; a ação de teste dos passes valida o desbloqueio e equipamento no jogo, mas não o prompt do Roblox. Uma compra real controlada ainda é necessária para confirmar a integração completa do pass. O [guia oficial de publicação](https://create.roblox.com/docs/production/publishing/publish-games-and-places) descreve o acesso Playtest; o [anúncio de mock purchases](https://devforum.roblox.com/t/mock-purchases-in-studio/26974) descreve compras simuladas no Studio; e a [documentação de DataStores](https://create.roblox.com/docs/cloud-services/data-stores) recomenda usar uma experiência separada para acesso do Studio à API.

## Produtos

Na experiência correta do Creator Dashboard, foram criados cinco Game Passes **individuais** e quatro Developer Products **consumíveis**. Os preços e o estado `isForSale=true` foram conferidos pela API após a criação. Os IDs numéricos já constam em [RewardCatalog.luau](../../src/shared/Features/RewardsShop/RewardCatalog.luau):

Experiência atual: universo `10772003576` (`BINGO Experimental`). Abrir [Developer Products](https://create.roblox.com/dashboard/creations/experiences/10772003576/monetization/developer-products) e [Passes](https://create.roblox.com/dashboard/creations/experiences/10772003576/monetization/passes) dessa experiência.

**Primeiro teste mínimo:** no Studio, com API desligada e playtest reiniciado depois da sincronização, abrir Loja → Fichas → Punhado → confirmar a compra simulada. Verificar saldo +120 e repetir a compra para chegar a +240. Depois fechar e reabrir o playtest: o saldo deve voltar ao estado inicial, pois a concessão foi só em memória.

| Campo | Produto | Preço | ID |
|---|---|---:|---:|
| `THEMES.dossier_blue.passId` | Dossiê Azul | 49 Robux | `2044514400` |
| `THEMES.stage_star.passId` | Estrela de Palco | 99 Robux | `2045168372` |
| `THEMES.club_seal.passId` | Selo do Clube | 99 Robux | `2045120362` |
| `THEMES.on_air.passId` | No Ar | 99 Robux | `2045108372` |
| `THEMES.velvet_gala.passId` | Veludo de Gala | 149 Robux | `2045330347` |
| `SUBORN_PRODUCT_ID` | Suborno do MC, uma unidade | 149 Robux | `3720520635` |
| `FICHA_PACKS.fichas_120.productId` | Punhado, +120 Fichas | 29 Robux | `3720520619` |
| `FICHA_PACKS.fichas_350.productId` | Pacote, +350 Fichas | 79 Robux | `3720520624` |
| `FICHA_PACKS.fichas_800.productId` | Maleta, +800 Fichas | 169 Robux | `3720520631` |

Não reutilizar IDs entre produtos. `ProcessReceipt` só concede Product IDs configurados e deve continuar sendo o único handler de recibos da experiência.

Textos sugeridos para o cadastro dos Developer Products:

| Nome | Descrição |
|---|---|
| Punhado de Fichas | Adiciona 120 Fichas ao saldo deste jogo. |
| Pacote de Fichas | Adiciona 350 Fichas ao saldo deste jogo. |
| Maleta de Fichas | Adiciona 800 Fichas ao saldo deste jogo. |
| Suborno do MC | Adiciona uma unidade de Suborno ao estoque. Uso limitado a uma vez por jogador e duas por partida. |

## Imagens

Revisar a franja interna, transparência e contraste dos cinco PNGs em [assets/bingo/card-skins/source](../../assets/bingo/card-skins/source/). Os arquivos já foram enviados à experiência e os IDs abaixo já estão no campo `image` do catálogo. Confirmar moderação e visibilidade em cliente publicado. A cartela usa a moldura PNG somente quando o asset carregou e há largura suficiente; até lá usa a moldura nativa do tema.

| Tema | Arquivo de origem | Asset ID |
|---|---|---|
| Dossiê Azul | `dossier_blue.png` | `122159259437743` |
| Estrela de Palco | `stage_star.png` | `122015776508513` |
| Selo do Clube | `club_seal.png` | `93200620468622` |
| No Ar | `on_air.png` | `129262034393957` |
| Veludo de Gala | `velvet_gala.png` | `112707626474228` |

Os ícones de marketplace dos nove produtos/passes ficam em [assets/bingo/offer-icons](../../assets/bingo/offer-icons/), gerados por [scripts/build_offer_icons.py](../../scripts/build_offer_icons.py) (requer Pillow). São imagens de 512 × 512 px com composição dentro de um círculo seguro. A API de produto/passe recebeu cada PNG por `PATCH`; os IDs resultantes foram conferidos pela API. Os ícones dos três pacotes de Fichas e do Suborno também estão no catálogo compartilhado para uso na Loja. A arte das cartelas continua independente dos ícones comerciais.

## Conferência antes da publicação

1. Sincronizar o código atual com o place de teste restrito. Em Studio, o playtest usa a DataStore separada `BingoNoirPlayer_Studio_v1`; com acesso a API desativado, exibe `Studio: sem salvamento` e perde o progresso ao parar.
2. Percorrer [validation.md](validation.md) com acesso à API habilitado em um ambiente de teste controlado. Confirmar que Fichas, trilha, equipamento e estoque sobrevivem a sair e entrar.
3. Fazer compras de teste de cada Pass e do Developer Product; conferir preço na janela da plataforma, concessão, reconciliação ao entrar e recibo repetido sem estoque duplicado.
4. Conferir as cinco imagens em cartelas reais, no telefone e no desktop, e o Suborno em partida com dois jogadores. Publicar somente após fechar os itens correspondentes de [tasks.md](tasks.md).

Referências Roblox: [passes](https://create.roblox.com/docs/production/monetization/passes), [developer products](https://create.roblox.com/docs/production/monetization/developer-products), [assets](https://create.roblox.com/docs/projects/assets).
