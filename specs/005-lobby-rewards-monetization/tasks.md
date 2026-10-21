# 005 — Tarefas

**Fonte:** [Spec](spec.md) · [Plano técnico](plan.md) · [Validação](validation.md).
**Status:** código, cinco artes, nove ofertas e nove ícones de marketplace integrados; uma compra simulada de Fichas confirmada; validação completa, persistência e jogo publicado pendentes.

## Produto e configuração

- [x] Aplicar as decisões aprovadas ao contrato da feature.
- [x] Criar perfil versionado com migração de campos, mutações atômicas e deduplicação de partidas/recibos.
- [x] Verificar na documentação oficial que `GetJoinData().ReferredByPlayerId` é sinal de indicação da plataforma.
- [x] Criar cinco Game Passes e quatro Developer Products na experiência experimental, conferir preços/estado à venda e preencher IDs no `RewardCatalog.luau`.
- [x] Criar e enviar ícones próprios das nove ofertas, inclusive para os prompts do Roblox; mostrar os ícones de Fichas/Suborno na Loja.
- [x] Enviar os cinco PNGs ao Roblox e preencher seus `rbxassetid://` no `RewardCatalog.luau`.
- [ ] Confirmar moderação/visibilidade em cliente publicado e revisar a franja interna das imagens.
- [ ] Antes de escala ampla, definir política de tamanho/arquivamento das listas de idempotência sem permitir reprocessar recibos antigos.

## Implementação em fonte

- [x] Persistir Fichas, coleção, trilha, estoque e equipamento com autoridade do servidor.
- [x] Pagar 5 Fichas por partida concluída e +2 ao vencedor, uma vez por partida/jogador.
- [x] Avançar um marco da trilha por dia UTC após partida, manter progresso e converter tema duplicado em 50 Fichas.
- [x] Implementar Loja de Fichas, propriedade/equipamento de temas, e UI de saldo/trilha/coleção.
- [x] Implementar prompts de Game Pass, verificação de ownership e restauração ao entrar; IDs reais configurados na experiência experimental.
- [x] Evitar que consulta de ownership da conta criadora libere passes automaticamente no Studio; perfil temporário começa com Clássico.
- [x] Implementar Developer Product consumível com `ProcessReceipt` idempotente; ativação depende do ID real.
- [x] Implementar três pacotes de Fichas com crédito atômico por recibo e preço consultado à plataforma; IDs reais configurados na experiência experimental.
- [x] Permitir compras simuladas no Studio com perfil temporário e impedir que uma simulação seja gravada no DataStore de teste.
- [x] Separar adaptador de perfil temporário e simulação de passe em `tests/studio/`; excluir ambos de `default.project.json` e bloquear acesso ao perfil real ao abrir o projeto de produção no Studio.
- [x] Redesenhar a Loja em quatro seções com placa de saldo, trilha, prévias das artes publicadas e layout adaptável.
- [x] Implementar convite da plataforma, vínculo do primeiro ingresso e prêmio após primeira partida do convidado.
- [x] Estender a máquina de estados com `SubornAnnouncement`, limite individual/global, chamada compartilhada e recuperação/refund de reserva.
- [x] Criar fallback nativo das cinco skins e produzir PNGs individuais de origem com centro transparente.
- [x] Integrar os PNGs enviados à cartela e às prévias da Loja, com fallback nativo se a imagem não carregar.
- [ ] Revisar contraste/layout das cinco imagens em cartelas reais no Studio e em dispositivo.

## Verificação

- [x] Carregar todos os ModuleScripts no Studio Edit sem erros de importação/sintaxe.
- [x] Verificar funções de trilha em perfil de exemplo no Studio Edit: mesmo dia, próximo dia, 7/14/21/28 marcos e duplicata.
- [x] Inspecionar a Loja redesenhada no lobby em playtest desktop e com contêiner de UI a 360 × 640; confirmar a mensagem de perfil sem salvamento em Studio.
- [ ] Percorrer a matriz em [validação](validation.md): compras simuladas no Studio sem API/DataStore e persistência em sessão separada com API habilitada.
- [ ] Conferir layout em telefone e desktop, contraste das imagens publicadas, cenas do Suborno e feedback do MC.
- [ ] Verificar aquisição Robux e repetição de recibo com produtos reais em ambiente controlado.
- [ ] Playtestar com newcomers, crianças e adolescentes separados quando viável; registrar compreensão, justiça percebida e retorno voluntário em `research/`.
