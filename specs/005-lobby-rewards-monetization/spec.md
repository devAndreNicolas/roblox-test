# 005 — Recompensas, Coleção e Loja

**Status:** Draft para aprovação antes da implementação.  
**Objetivo de produto:** testar retorno ao jogo e validar se recompensas e compras melhoram a experiência sem esconder regras ou tornar a vitória uma compra.  
**Relacionados:** [Plano técnico](plan.md) · [Tarefas](tasks.md) · [Validação](validation.md) · [Personas](../player-personas.md) · [Feedback de playtest](research/playtest-feedback.md) · [Prompt pack de assets](research/card-skin-art-brief.md).

## Resultado esperado

O jogador entende o que pode ganhar, qual é o próximo marco e o que uma compra faz. Completar partidas avança uma trilha de sete recompensas diárias sem punir dias perdidos. A loja permite gastar Fichas obtidas jogando ou Robux em itens claramente descritos. A partida continua sendo Bingo compartilhado com chamadas iguais para todos; itens de poder têm estoque e limite por partida.

O foco de validação é **retenção primeiro**: observar retorno D1/D7 e escolha espontânea de jogar outra partida. Receita e conversão são medidas secundárias. Os valores e recompensas abaixo são hipóteses de MVP, não promessa de retenção nem alegação de que uma mecânica provoca dopamina.

## Público e princípios

Atender crianças e adolescentes no mesmo jogo, com leitura direta, preços e efeitos explícitos e participação que não dependa de chat. Evitar pressão por sequência diária, cronômetros de compra, roletas, caixas aleatórias, escassez artificial ou punição por não entrar. A vantagem paga é deliberadamente pequena, visível a todos e limitada; o jogo não vende vitória garantida.

## Nomenclatura aprovada

- **Fichas:** moeda ganha jogando.
- **Recompensas Diárias:** trilha de sete etapas de partidas concluídas; não é uma sequência de dias consecutivos.
- **Loja:** tela de compra e catálogo.
- **Coleção:** cosméticos permanentes de tema completo da cartela.
- **Tema de cartela:** moldura e decoração da superfície da cartela; grade, letras, números, estados e marcas continuam sendo UI nativa e legível.
- **Suborno do MC:** item consumível que transforma um número não chamado da cartela do comprador na próxima chamada compartilhada.
- **Estoque:** quantidade de Subornos que o jogador pode ativar numa partida. Comprar ou possuir o item não ignora o limite da partida.

## Escopo

Inclui saldo e gasto de Fichas, recompensa por partida, trilha diária, inventário/equipamento de temas, Loja, compra permanente de temas com Robux, compra consumível do Suborno com Robux, convite de amigos e persistência necessária para esses sistemas.

Não inclui troca entre jogadores, saque ou pagamento de Robux ao jogador, passes de vantagem permanente, assinatura, loot boxes, bônus por streak, recompensas aleatórias, marketplace de UGC, ranking global ou segmentação de preço por usuário.

## Regras de produto

### Fichas e conclusão da partida

- **ECON-01:** cada participante elegível recebe 5 Fichas ao concluir a partida, inclusive em empate. O vencedor recebe mais 2. Um jogador que sai antes do encerramento não recebe recompensa de conclusão.
- **ECON-02:** uma mesma conclusão só pode pagar uma vez por jogador e identificador de partida. Reconexão, snapshot repetido ou disputa de resultado não duplica o pagamento.
- **ECON-03:** toda mudança de saldo é validada e concedida no servidor. Clientes enviam intenção; nunca escolhem valor, item, resultado, jogador indicado ou identificador de recibo.
- **ECON-04:** preço insuficiente, item não possuído, quantidade inválida ou pedido duplicado não altera o saldo/inventário e retorna uma mensagem clara.

### Recompensas Diárias

- **DAILY-01:** sete marcos avançam por partidas concluídas: 10, 15, 20, 25, 30, 35 e 40 Fichas, respectivamente; o sétimo inclui um tema da rotação de marcos, começando por Estrela de Palco.
- **DAILY-02:** progresso persiste entre sessões e dias. Perder um dia não reinicia, remove, expira nem reduz progresso. Um jogador pode avançar no máximo um marco por partida concluída.
- **DAILY-03:** ao concluir o sétimo marco, a trilha volta ao primeiro marco. A rotação inicial de recompensa do sétimo marco é Estrela de Palco, Selo do Clube e Dossiê Azul; ao concluir a rotação, começa novamente por Estrela de Palco. Se o jogador já possuir o tema do ciclo, aplica-se a conversão de duplicata. Progresso nunca é concedido por abrir o lobby ou permanecer AFK.
- **DAILY-04:** se o jogador já possui a skin concedida no marco, recebe 50 Fichas em seu lugar. A UI mostra a conversão antes de reclamar a recompensa.
- **DAILY-05:** a tela mostra marco atual, próximo prêmio, progresso da sessão, e o fato de não haver penalidade por perder um dia. Sem contagem regressiva enganosa.

### Convites

- **REF-01:** um convite é validado pela atribuição de origem da plataforma quando disponível; códigos, nomes digitados e parâmetros vindos do cliente não provam indicação.
- **REF-02:** o vínculo precisa ser criado pelo fluxo suportado de convite do Roblox antes de o convidado jogar; não é possível vincular retroativamente duas contas existentes pelo nome.
- **REF-03:** após o convidado completar sua primeira partida elegível, convidado e indicador recebem Selo do Clube uma única vez para aquele vínculo válido. Se já possuir o tema, recebe 50 Fichas em substituição.
- **REF-04:** não há recompensa por clicar num link, entrar no servidor, convite para conta alternativa ou simplesmente comprar. A recompensa exige partida concluída; abuso e duplicidade não são pagos.
- **REF-05:** apresentar o que cada lado recebe e quando, sem exigir que jogador converse ou revele informação pessoal.

### Loja, Coleção e economia

- **SHOP-01:** catálogo de MVP contém tema Clássico gratuito/equipado, três temas que podem ser obtidos jogando e dois temas premium exclusivos de Robux:

| Tema | Como obter | Preço de Fichas proposto | Preço Robux proposto |
|---|---|---:|---:|
| Dossiê Azul | Comprar | 300 | 49 |
| Estrela de Palco | Marco 7 ou comprar | 700 | 99 |
| Selo do Clube | Convite válido ou comprar | 700 | 99 |
| No Ar | Comprar | — | 99 |
| Veludo de Gala | Comprar | — | 149 |

- **SHOP-02:** preços em Robux são metas de configuração para o experimento. A UI consulta o preço atual apresentado pela plataforma e não fixa números desatualizados no texto. Skins já possuídas não oferecem uma segunda compra Robux.
- **SHOP-03:** preços de Fichas são estáveis e configurados em um único catálogo compartilhado. Para a comparação proposta, 700 Fichas equivalem a 14 recompensas base de partida, sem contar bônus de vitória. A UI deixa lado a lado custo em Fichas e preço Robux quando ambos existem.
- **SHOP-04:** as skins mudam somente identidade visual da cartela; nunca contraste, legibilidade, números, estados de chamada, probabilidade ou velocidade de marcação. Há fallback Clássico caso o asset falhe.
- **SHOP-05:** equipar uma skin é reversível e gratuito. A escolha persiste e aplica-se à próxima apresentação da cartela; não altera a partida ativa.
- **SHOP-06:** duplicata de recompensa obtida por trilha/convite converte a skin duplicada em 50 Fichas. Compra de skin já possuída é bloqueada antes de abrir o prompt Robux.

### Suborno do MC (vantagem limitada)

- **POWER-01:** custa 650 Fichas por unidade ou usa Developer Product consumível com preço-alvo de 149 Robux por unidade. A compra com Robux concede estoque; não ativa automaticamente nem permite ativar depois de esgotado o limite daquela partida.
- **POWER-02:** cada jogador ativa no máximo um Suborno por partida e a partida toda aceita no máximo dois. O servidor reserva o estoque e valida ambos os limites antes de iniciar a apresentação.
- **POWER-03:** quando resolvido, o servidor escolhe uniformemente um número ainda não chamado dentre os números não marcados da cartela do jogador. Esse número passa a ser a próxima chamada pública para todos. Qualquer participante com esse número pode marcar; o comprador não recebe uma marca automática.
- **POWER-04:** se não existir número elegível, a partida não estiver em `Calling`, algum limite estiver atingido ou uma apresentação já estiver em progresso, ativação falha e nenhuma unidade é consumida.
- **POWER-05:** a sequência cria a fase compartilhada `SubornAnnouncement` por 2 segundos. O intervalo normal de 5 segundos da chamada seguinte é pausado/restaurado; ninguém pode marcar durante a cutscene. Todos recebem a mesma fala e o mesmo número, mantendo causa e efeito visíveis.
- **POWER-06:** estoque reservado é consumido somente quando o efeito é commitado pela autoridade da partida. Se a partida terminar, participante sair ou a fase falhar antes de resolver, reserva é devolvida. Recibo pago que chega quando o jogador está offline continua pendente até concessão confirmada.
- **POWER-07:** UI e apresentação declaram antes da compra: “uma ativação por jogador por partida; duas por partida no total; o número é uma próxima chamada para todos; não marca a cartela automaticamente”.
- **POWER-08:** durante o teste, acompanhar taxa de ativação, taxa de vitória de compradores e não compradores, empates, partidas atingindo o limite e reclamações de injustiça. Pausar venda/ajustar custo e regra se vantagem percebida dominar a habilidade/aleatoriedade ou desorganizar o ritmo. É hipótese de design com risco de pay-to-win, não garantia de equilíbrio.

### Robux e recibos

- **MON-01:** temas permanentes são produtos não consumíveis apropriados ao modelo de ownership (Game Passes individuais); Suborno é Developer Product consumível. IDs ficam em configuração do servidor, sem IDs fictícios no build publicado.
- **MON-02:** servidor processa recibo com `PurchaseId` idempotente: grava a concessão e a chave do recibo de forma atômica no perfil; repetição já concedida responde como processada sem duplicar estoque/moeda.
- **MON-03:** falha temporária de persistência não retorna recibo como concedido. O sistema tenta novamente conforme o fluxo de recibos do Roblox; UI não promete concessão até confirmar.
- **MON-04:** oferta, preço, quantidade e efeito estão claros antes do prompt. Nenhum botão usa urgência enganosa, compra em um clique sem confirmação da plataforma, ou faz o item parecer grátis.

## Critérios de aceitação

1. Completar uma partida paga 5 Fichas uma vez; vencedor fica com 7; empate paga 5 a cada elegível; repetir o evento não paga de novo.
2. Completar partida avança exatamente um marco; alternar dias não reinicia; completar etapa 7 concede Estrela ou 50 Fichas por duplicata.
3. Convite válido só recompensa após primeira partida concluída e paga cada lado uma vez; nome/código arbitrário não cria vínculo.
4. Catálogo mostra obtenção, custo, ownership, preço Robux atualizado e efeito do Suborno antes da compra; compra de skin possuída é evitada.
5. Equipar tema altera somente a moldura; números, marcas e contraste mantêm leitura em telefone e desktop; asset quebrado usa Clássico.
6. Suborno respeita 1/jogador e 2/partida, escolhe número elegível no servidor, faz chamada compartilhada a seguir, não auto-marca e devolve estoque em cancelamento pré-commit.
7. Recibo de Developer Product repetido não duplica item; falha temporária não marca compra como concluída antes da concessão durável.
8. Reabrir o jogo restaura saldo, marcos, coleção, equipamento e estoque adquirido; indisponibilidade de perfil bloqueia gasto/ativação com mensagem recuperável, sem inventar saldo local.

## Fora de questão / decisões de validação

Esta spec define a hipótese inicial aprovada para implementação; preços e cadência precisam ser avaliados após dados de sessões reais. Sinal de validação é retorno voluntário e entendimento dos jogadores, não tempo de sessão forçado. Revisitar se os jogadores percebem skin como vantagem, não entendem a regra pública do Suborno, evitam Fichas porque os custos parecem inalcançáveis, ou sentem pressão por login diário.
