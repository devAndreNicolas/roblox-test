# 005 — Plano de Validação

**Status:** Planejado; nenhum comportamento deste spec foi implementado ou verificado ainda.

## Checagens funcionais em Studio

| Área | Cenário | Resultado esperado |
|---|---|---|
| Conclusão | participante, vencedor, empate, desconexão e evento duplicado | 5 Fichas para elegível; +2 só vencedor; no máximo uma transação por partida/jogador |
| Perfil | sair/entrar, migração, erro de leitura/escrita | estado persiste; migração mantém itens; sem perfil confiável não permite gastar nem ativar poder |
| Trilha | completar 1, 6 e 7 marcos; voltar após dias | avança um por partida, não reseta; marco 7 dá tema e próxima etapa corretamente |
| Duplicata | já possui Estrela/Selo quando recebe trilha/referral | mostra conversão e credita 50 Fichas uma vez |
| Loja | Fichas insuficientes, skin própria, preço de plataforma diferente, compra cancelada | nenhuma cobrança/concessão incorreta; preços/efeitos claros; sem prompt desnecessário para ownership já adquirido |
| Recibo | repetir mesmo PurchaseId, falhar persistência, ProductId inválido | sem duplicação; pendente em falha; ID inválido não concede item |
| Referral | fluxo válido; conta não atribuída; jogador tenta forjar nome/código | somente sinal de plataforma elegível concede após a primeira partida; forja não recompensa |
| Skin | cada PNG, PNG ausente, contraste de chamadas/marcações | números continuam legíveis; fallback Clássico funciona |
| Suborno | estoque vazio, saldo baixo, fase incorreta, limite individual/global, sem número elegível | solicitação recusada sem perda/efeito parcial |
| Suborno | ativação válida por 2 players em sala multiplayer | servidor publica próxima chamada igual; ninguém auto-marca; cena e relógio sincronizam; máximo de dois usos |
| Cancelamento | rodada acaba ou player sai durante apresentação | reserva não commitada é devolvida; não surge chamada após o fim |

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
