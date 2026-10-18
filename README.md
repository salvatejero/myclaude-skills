# myclaude-skills

Skills para [Claude Code](https://claude.com/claude-code).

| Skill | Qué hace |
|---|---|
| [`gemini-imagen`](gemini-imagen/SKILL.md) | Pide una imagen a Gemini desde un prompt, con imágenes de referencia opcionales. Solo usa la biblioteca estándar de Python. |
| [`vineta-con-referencias`](vineta-con-referencias/SKILL.md) | Viñetas en serie con estilo y personajes fijos, y lo que hay que decirle a Gemini para que no se desmande. |
| [`brief-vinetas-comic`](brief-vinetas-comic/SKILL.md) | Prepara el brief en Markdown de una serie de viñetas: hojas de personaje, referencias y el prompt de cada escena. No genera imágenes. |
| [`slides-plantillas`](slides-plantillas/SKILL.md) | Carruseles de Instagram de texto y datos sobre las plantillas PNG de tu marca, sin IA. Necesita Pillow y un `marca.json` propio. |

## Instalación

```bash
git clone https://github.com/salvatejero/myclaude-skills.git
cp -r myclaude-skills/{gemini-imagen,vineta-con-referencias,brief-vinetas-comic,slides-plantillas} ~/.claude/skills/
export GEMINI_API_KEY=...   # https://aistudio.google.com/apikey
```

Cada imagen cuesta unos 4 céntimos de dólar en la API de Gemini.
