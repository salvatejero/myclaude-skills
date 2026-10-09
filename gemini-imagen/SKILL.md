---
name: gemini-imagen
description: Pide a Gemini una imagen a partir de un prompt de texto y la deja en disco. Úsala cuando pidan «genera una imagen», «pide una ilustración a Gemini», «necesito un logo/boceto/foto de X» o similar.
---

# Pedir una imagen a Gemini

Lo hace `gemini_imagen.py`, junto a este fichero. Es un REST directo al modelo
de imagen de Gemini (`gemini-2.5-flash-image`), solo con la biblioteca
estándar de Python.

```bash
S=<directorio de esta skill>
python3 $S/gemini_imagen.py "un gato astronauta, foto realista"
python3 $S/gemini_imagen.py "logo minimalista en azul" -o logo.png
python3 $S/gemini_imagen.py "boceto de un robot" -n 3 --ratio 16:9
python3 $S/gemini_imagen.py "la misma escena, de noche" -r referencia.jpg -o noche.png
```

- **Hace falta `GEMINI_API_KEY`** (se saca en https://aistudio.google.com/apikey).
  Se lee de la variable de entorno o, si no está, de un `.env` en el directorio
  actual. Si falta, el script se para y lo dice. No la escribas tú en ningún
  sitio ni la repitas en la conversación.
- Cada imagen cuesta unos 4 céntimos y el script avisa antes de pedirla. Si son
  muchas (más de 3 o 4), confírmalo antes con quien esté delante.
- Sin `-o`, guarda `imagen-1.png`, `imagen-2.png`... en el directorio actual.
  Con `-o` y varias (`-n`), añade el índice al nombre.
- `--ratio` acepta los valores que admite la API (`1:1`, `16:9`, `4:3`...). Por
  defecto, cuadrada.
- `-r/--referencia` (repetible) adjunta imágenes para que Gemini imite su estilo
  o sus personajes. Para series con estilo fijo, mira la skill
  `vineta-con-referencias`.
- Si la respuesta no trae imagen (la ha parado el filtro de seguridad del
  modelo), el script se para y muestra el trozo de respuesta que llegó.
