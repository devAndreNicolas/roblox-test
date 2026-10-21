# 005 — Plano de Validação

**Status:** regras de trilha verificadas isoladamente em Studio Edit; Loja inspecionada em desktop e simulação visual de 360 × 640. Cinco assets de cartela carregaram no cliente de Studio. Nove ofertas e nove ícones criados; preços/status/IDs de ícones conferidos pela API. Uma compra simulada do pacote +120 creditou 120 Fichas em memória. Partida multiplayer, DataStore real, demais compras simuladas, compra real e conferência em dispositivo real ainda pendentes.

**Ambientes separados:** com acesso à API **desligado**, o Studio usa perfil temporário e simula compras sem cobrar Robux. Developer Products usam o prompt simulado; passes usam `tests/studio/StudioPassPurchase.server.luau`, montado apenas por `studio.project.json`, porque a conta criadora já possui os passes na plataforma. Com acesso à API **ligado**, usar o DataStore `BingoNoirPlayer_Studio_v1` para conferir persistência de recompensas e compras com Fichas; os prompts simulados ficam bloqueados para não gravar compras fictícias. Para verificar pagamento real e persistência juntos, usar conta de teste no aplicativo Roblox com acesso Playtest restrito. Ver [setup.md](setup.md).

## Checagens funcionais em Studio

| Área | Cenário | Resultado esperado |
|---|---|---|
| Conclusão | participante, vencedor, empate, desconexão e evento duplicado | 5 Fichas para elegível; +2 só vencedor; no máximo uma transação por partida/jogador |
| Perfil | sair/entrar, migração, erro de leitura/escrita | estado persiste; migração mantém itens; sem perfil confiável não permite gastar nem ativar poder |
| Trilha | completar duas partidas no mesmo dia UTC; completar em dias diferentes; marcos 7/14/21/28 | uma etapa por dia, partida extra recebe só Fichas base, não reseta; temas giram Estrela/Selo/Dossiê e duplicata vira 50 Fichas |
| Duplicata | já possui Estrela/Selo quando recebe trilha/referral | mostra conversão e credita 50 Fichas uma vez |
| Loja | Fichas insuficientes, skin própria, preço de plataforma diferente, compra cancelada | nenhuma cobrança/concessão incorreta; preços/efeitos claros; sem prompt desnecessário para ownership já adquirido |
| Recibo | repetir mesmo PurchaseId, falhar persistência, ProductId inválido | sem duplicação; pendente em falha; ID inválido não concede item |
| Pacotes de Fichas | cada pacote, preço ausente, recibo repetido e saída após comprar | mostra quantidade e preço real; credita 120/350/800 uma vez; compra pendente não some |
| Referral | fluxo válido; conta não atribuída; jogador tenta forjar nome/código | somente sinal de plataforma elegível concede após a primeira partida; forja não recompensa |
| Skin | cada PNG, PNG ausente, contraste de chamadas/marcações | números continuam legíveis; fallback Clássico funciona |
| Suborno | estoque vazio, saldo baixo, fase incorreta, limite individual/global, sem número elegível | solicitação recusada sem perda/efeito parcial |
| Suborno | ativação válida por 2 players em sala multiplayer | servidor publica próxima chamada igual; ninguém auto-marca; cena e relógio sincronizam; máximo de dois usos |
| Cancelamento | rodada acaba ou player sai durante apresentação | reserva não commitada é devolvida; não surge chamada após o fim |

Verificação isolada em Studio Edit (sem DataStore): módulos foram carregados; dias 1 e 2 avançaram, segunda partida no mesmo dia pagou apenas 7 Fichas de partida por vitória; marcos 7/14/21/28 concederam Estrela/Selo/Dossiê e, na repetição, 50 Fichas. Isso valida as funções puras usadas pela feature, não a integração da partida.

Inspeção visual da Loja: abas Fichas e Cartelas abertas no playtest desktop após reunir saldo, trilha e categorias no topo. A cartela de amostra combina os PNGs publicados com números nativos. O Dossiê Azul apareceu na captura; `ContentProvider:PreloadAsync` devolveu `Success` para Selo do Clube, No Ar e Veludo de Gala, e os cinco `ImageLabel` ficaram `IsLoaded = true` no cliente. O painel também foi inspecionado com contêiner de 360 × 640; isso não substitui emulação de toque/dispositivo. Depois da criação das ofertas, um playtest novo exibiu seus preços reais, o ícone de Punhado/Pacote e todas as cinco cartelas sem botão Equipar no perfil inicial. A compra simulada de Punhado creditou +120 Fichas. Um segundo clique automatizado creditou +800 de outra oferta, então não consideramos a repetição da mesma compra validada; conferir manualmente o fluxo antes de marcar a matriz como concluída.

`UserOwnsGamePassAsync` retornou `true` para os cinco passes da conta criadora no Studio. Antes de mover a simulação para `tests/studio/`, a ação de teste de Dossiê Azul liberou apenas esse tema em memória, ocultou o botão Robux e mostrou Equipar; Estrela de Palco continuou bloqueada. Após a separação, os projetos Rojo de produção e Studio foram compilados. O script de teste na nova montagem ainda precisa ser exercitado no Studio conectado a `studio.project.json`.

## Usabilidade e produto

Com jogadores que ainda não conhecem o recurso, observar sem explicar primeiro:

1. A pessoa consegue identificar como ganhar Fichas e qual é o próximo prêmio?
2. Entende que “diária” não perde progresso quando deixa de entrar um dia?
3. Antes de comprar, consegue explicar o que recebe, por qual preço e se é permanente ou consumível?
4. Depois do anúncio do Suborno, entende quem pode marcar o número e quais limites se aplicam?
5. Jogaria outra partida por vontade própria? Por quê?

Registrar resultados separados para crianças (faixas 5–8 e 9–12 quando viável) e adolescentes 13–17. Pesquisa com menores requer consentimento adequado do responsável; não coletar dados pessoais desnecessários. Observar também se alguém sente que precisa gastar ou entrar diariamente para não perder algo.

## Métricas de decisão

- **Primária:** retorno D1 e D7 entre primeiros jogadores elegíveis, comparado com o baseline disponível.
- **Secundárias:** partidas concluídas por sessão, escolha espontânea de outra rodada, progresso/conclusão de marcos, cosméticos equipados e conversão por método de obtenção.
- **Proteção:** desistência antes da partida, confusão de preço/efeito, reclamação de vantagem injusta, proporção de vitória de usuários do Suborno vs. sem Suborno, falha ou atraso de concessão.

Leitura inicial é descritiva; volume baixo não autoriza declarar causalidade nem sucesso estatístico. Ajustar uma variável por vez após a primeira rodada de observações. Se não há baseline ou amostra, documentar limitação em vez de inventar meta numérica.
