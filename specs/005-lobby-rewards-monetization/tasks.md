# 005 — Tarefas

**Fonte:** [Spec](spec.md) · [Plano técnico](plan.md) · [Validação](validation.md).

## Produto e dados

- [ ] Confirmar spec e regras com o proprietário antes de integrar em partidas.
- [ ] Definir schemaVersion, default do perfil, migração, lock/sessão e política de lista de recibos/transações.
- [ ] Configurar IDs reais de assets e produtos no Creator Dashboard; registrar preço-alvo e preço mostrado pela plataforma.
- [ ] Validar disponibilidade e sinal confiável do fluxo de convite Roblox para este experience/conta antes de codificar a recompensa REF.

## Implementação em fatias

- [ ] Criar carregamento/persistência de perfil servidor-autoritativo, indisponibilidade segura e grants/spends idempotentes.
- [ ] Implementar Fichas e pagamento de encerramento de partida exatamente uma vez (5 participação, +2 vencedor).
- [ ] Implementar inventário, catálogo compartilhado e equipar/fallback de temas.
- [ ] Implementar trilha de sete marcos e conversão de tema duplicado.
- [ ] Implementar Loja de Fichas e prompts Robux de ownership permanente para temas.
- [ ] Implementar Developer Product do Suborno com processamento de recibos idempotente.
- [ ] Implementar vínculo/validação de referral e payout pós-primeira partida elegível; omitir o botão de convite se o fluxo não puder ser verificado.
- [ ] Estender a máquina de estado autoritativa com `SubornAnnouncement`, reserva/commit/refund e broadcast compartilhado.
- [ ] Construir UI móvel e desktop para saldo, trilha, catálogo, ownership, detalhes de preço e estoque do Suborno.
- [ ] Integrar imagens finais de card skin depois de aprovada a direção e importados/moderados os assets.

## Verificação

- [ ] Percorrer cada cenário da matriz em [validação](validation.md) em Studio, incluindo perfil indisponível e recibo repetido simulado com harness interno apropriado.
- [ ] Inspecionar Output e comportamento em sessão solo e em multiplayer; confirmar servidor como autoridade.
- [ ] Playtestar com newcomers, crianças e adolescentes separadamente quando viável, com permissão apropriada para pesquisa com menores.
- [ ] Registrar compreensão, diversão, retorno voluntário, justiça percebida e pontos de pressão/confusão em `research/`.
- [ ] Não marcar como validado sem evidência; revisar economia e conteúdo da spec antes de expandir a monetização.
