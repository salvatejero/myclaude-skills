---
name: vineta-con-referencias
description: Genera viñetas de cómic con Gemini manteniendo un estilo y unos personajes fijos a partir de imágenes de referencia. Úsala cuando pidan «genera la viñeta de...», «dibuja el post con el estilo de siempre» o una serie de ilustraciones que tengan que parecerse entre sí.
---

# Viñetas con estilo fijo

Se apoya en la skill `gemini-imagen` (`gemini_imagen.py -r`). Lo que aporta son
las lecciones de pedirle a Gemini viñetas en serie sin que se desmanden.

## Antes de pedir nada

1. **El prompt, tal cual.** Si viene de un fichero (un `.md` por post, por
   ejemplo), usa el texto exacto: no lo reescribas ni lo resumas. Si no está
   claro qué viñeta se pide, pregunta antes de gastar.
2. **Siempre con referencias.** Adjunta con `-r` imágenes del directorio de
   referencias del proyecto: son el único ancla de estilo, y sin ellas cada
   viñeta sale distinta. Si el proyecto tiene notas sobre qué referencia sirve
   para qué, o fichas de personajes, léelas primero.
3. **Coste.** Si la tanda pasa de 3 o 4 imágenes, di cuánto cuesta y
   confírmalo.

## Coletilla obligatoria

Añádela al final del prompt que se le pasa al script; el fichero original no se
toca:

```
SOBRE LAS IMÁGENES ADJUNTAS: son referencia de ESTILO —trazo, paleta, textura,
formato de viñeta— y del diseño de los personajes fijos si aparecen. NO copies
identidad ni género de ningún otro personaje de las referencias. Los personajes
de esta viñeta son EXACTAMENTE los que describe el texto anterior y deben
aparecer TODOS los que se nombran, ninguno de menos.
```

## Lo que falla, y cómo se arregla

- **El estilo hay que pedirlo con palabras.** Las referencias solo anclan el
  estilo de los personajes que salen en ellas. A cualquier personaje nuevo,
  Gemini lo dibuja en un cómic semirrealista que no pega con el resto. Describe
  el estilo de forma explícita en cada prompt. Por ejemplo, para un tebeo
  español clásico: «rasgos redondeados y exagerados, ojos grandes y simples,
  trazo grueso y limpio, color plano con poca gradación; nada de piel
  renderizada ni de sombreado tipo cómic de superhéroes».
- **Clona referencias parecidas.** Si la escena se parece a un panel de las
  referencias, Gemini copia su maquetado y su bocadillo en lugar de dibujar
  una escena nueva, aunque se le pida lo contrario. Añade «una sola viñeta, un
  único encuadre; no reproduzcas el maquetado ni el bocadillo de las
  referencias». Si sigue pasando, quita de `-r` la referencia más parecida.
- **El texto dibujado sale con erratas** (pizarras, carteles, bocadillos): es
  lo más frágil. Revísalo letra a letra y, si hace falta, regenera solo por
  eso.
- **Faltan personajes o salen con el físico equivocado:** no la des por buena.
  Repite la petición con el mismo prompt y la coletilla, cambiando las
  referencias si hace falta.

Revisa cada imagen contra estas cuatro cosas, no solo contra «¿salen los
personajes correctos?».

## Al terminar

No pises una imagen ya generada sin confirmarlo. Enumera las rutas generadas
para que alguien las mire antes de publicar nada.
