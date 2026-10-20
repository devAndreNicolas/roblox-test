# Direção e prompt pack — temas de cartela

**Status:** prancha gerada para revisão de direção; não são os PNGs finais.  
**Arquivo da prancha:** [`assets/concept-sheet.png`](../../../assets/bingo/card-skins/concept-sheet.png).

## O que o asset faz

Cada skin dá à cartela uma moldura e uma identidade completa. O centro continua sendo UI Roblox: letra BINGO, números, grade, FREE, feedback, estado chamado e marcação são construídos em Luau. Isso mantém contraste, localização, acessibilidade e dados sempre corretos. O arquivo é uma camada de fundo/decorativa, não uma cartela achatada.

## Coleção

| ID | Nome | Direção visual | Disponibilidade |
|---|---|---|---|
| `classic` | Clássico | Papel marfim limpo, contorno de tinta azul, sem ornamentação premium | Grátis e fallback |
| `dossier_blue` | Dossiê Azul | Pasta/dossiê azul meia-noite, borda de papel marfim, acentos de evidência âmbar | 300 Fichas / 49 Robux; marco 7 da 3ª rotação |
| `stage_star` | Estrela de Palco | Programa teatral vinho e marfim, estrela âmbar central pequena | Marco 7 / 700 Fichas / 99 Robux |
| `club_seal` | Selo do Clube | Cartão marfim e azul escuro com um selo circular dourado | Indicação válida / marco 7 da 2ª rotação / 700 Fichas / 99 Robux |
| `on_air` | No Ar | Moldura de transmissão azul-marinho com luz ciano e magenta | 99 Robux |
| `velvet_gala` | Veludo de Gala | Veludo vinho, detalhes geométricos Art Deco em dourado discreto | 149 Robux |

## Prompt mestre para cada PNG final

Substituir somente `[TEMA E DETALHES]` pela linha correspondente da coleção e manter o resto do prompt igual para consistência:

> Create one original 2D decorative UI frame for a Roblox Bingo card skin, intended to sit behind live UI elements. Near-square portrait-friendly composition matching a roughly 1:1.08 card aspect ratio. Transparent PNG with real alpha transparency. Keep the entire large central panel and a 10% safe inset empty and transparent for a dynamically rendered 5×5 Bingo grid, heading, numbers, marks and states. Confine all ornament to the outer 8–10% frame and corners. Theme: [TEMA E DETALHES]. Bingo Noir live-show identity, playful and welcoming for children and teenagers, crisp readable silhouette at small mobile size, restrained texture, strong contrast with dark ink text and ivory card cells. Flat front view, no perspective, no cast shadow outside the frame. No words, letters, numbers, grid, symbols resembling game states, character, hand, logo, watermark, checkerboard, playing-card suit symbols, casino imagery, or background. Deliver a clean isolated frame with no crop of its outer border.

### Substituições do tema

- Dossiê Azul: `midnight navy dossier folder, ivory paper edge, one restrained amber evidence-tab accent`.
- Estrela de Palco: `deep burgundy theater-program frame with ivory inner edge and one small amber five-point star ornament centered on the top border`.
- Selo do Clube: `elegant dark-blue and ivory club-card border, one simple circular gold seal ornament centered on the top border`.
- No Ar: `midnight broadcast frame with vivid cyan and magenta light accents and tiny abstract signal bars confined to the outer border`.
- Veludo de Gala: `deep wine-red velvet-like frame with restrained gold Art Deco corner geometry`.

## Processo de produção e integração

1. Revisar primeiro `concept-sheet.png`: avaliar silhueta, unidade da coleção, contraste e se cada tema comunica seu nome. Escolher correções antes de gerar arquivos individuais.
2. Gerar uma imagem por tema aprovado usando o prompt mestre; pedir alpha real, área central transparente e sem texto. Não cortar a prancha em cinco “assets finais”, porque fundo, escala e enfeites de conceito não têm alpha/layout confiáveis para runtime.
3. Revisar o alpha sobre a UI marfim e azul-escuro; verificar borda não cortada, celular pequeno e estado de cartela marcado.
4. Salvar os originais em `assets/bingo/card-skins/source/<id>.png`. Importar no Roblox Asset Manager, aguardar moderação e registrar IDs reais na configuração. PNG de origem no repo não equivale a asset publicado.
5. Renderizar imagem atrás da grade via `ImageLabel`/camada de fundo. Fallback Clássico se asset falhar. Nunca depender da imagem para comunicar número, chamada, marca, preço, raridade ou instrução.

Geração do conceito e arquivos finais usa ferramenta de imagem; Studio/Roblox faz importação, moderação e exibição. Não é necessário ferramenta externa para desenhar números e estados, nem plugin de UI para o MVP.

## Referências consultadas

Há templates públicos genéricos de prompts para UI Roblox, mas não encontramos um prompt pronto para uma moldura de cartela com centro reservado para UI dinâmica. O prompt mestre acima foi escrito para este layout e para nossa identidade visual.

- [Roblox UI labels](https://create.roblox.com/docs/ui/labels) — uso de ImageLabel para imagens na interface.
- [Importing assets](https://create.roblox.com/docs/projects/assets) — importar assets e considerar moderação/publicação.
- [Texture Generator](https://create.roblox.com/docs/studio/texture-generator) — voltado a texturas de meshes; não substitui uma moldura PNG de UI.
- [Template público genérico de prompts de UI Roblox](https://github.com/anthonybone/roblox-dev-prompts-free/blob/main/prompts/ui-design/README.md) — referência de formato, não asset pronto para este projeto.
- [OpenAI Image Generation prompting](https://openai.com/academy/image-generation/) — estrutura de prompt e processo de iteração.