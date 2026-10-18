---
name: slides-plantillas
description: Crea slides o carruseles de Instagram (1080×1350) sobre las plantillas de una marca —portada, texto y cierre— con sus colores y tipografías, sin ilustraciones ni IA de imágenes. Úsala cuando pidan un post, carrusel o slides «con las plantillas de la marca», «sin viñetas», de texto o de datos.
---

# Slides sobre plantillas

Lo hace `slides.py`, junto a este fichero: lee un JSON con los slides y pinta
cada uno sobre la plantilla PNG que toque. Sin IA y sin coste; cambiar un
texto es editar el JSON y relanzar. Necesita Pillow (`pip install pillow`).

```bash
S=<directorio de esta skill>
python3 $S/slides.py posts/<tema>/slides.json marca.json
```

Los PNG salen junto al JSON (`slide-1.png`, `slide-2.png`…). El formato del
JSON y los bloques están en el docstring del script.

## La marca

`marca.json` es del proyecto, no de la skill: plantillas (tres PNG de
1080×1350), fuentes (`.ttf`, `.otf` o `.woff2`), colores claro y oscuro, y
la altura a la que empieza el texto en cada plantilla, por debajo del logo.
Si no existe, cópialo de `marca.ejemplo.json` y rellénalo con los valores de
la marca (tokens, guía de estilo); no inventes colores.

## Plantillas

- **portada**: primer slide. Antetítulo y título.
- **texto**: el cuerpo del carrusel.
- **cierre**: último slide, fondo oscuro. Una frase, como mucho dos bloques.

## Bloques

`antetitulo` (color de acento, pequeño) · `titulo` · `parrafo` · `cifra` +
`etiqueta` · `codigo` + `pie` (comentario de código en mono, con su fichero
debajo) · `nota` (nota al pie en mono y gris).

## Reglas

- **Un antetítulo por slide** como mucho: es el único acento de color.
- **Datos reales y comprobados.** Cifras sacadas del repo o de la fuente, no
  de memoria. Cuenta lo que dices que cuentas.
- **Tono:** el de la guía del proyecto. Sin jerga de startup.
- **Una idea por slide.** Si el script avisa de que el texto se sale de la
  plantilla, se parte en dos slides; no se encoge la letra.
- **Revisar cada PNG** antes de darlo por bueno (lectura, cortes de línea,
  ortografía).
- Junto al carrusel, un brief con la tabla de slides, de dónde sale cada dato,
  caption y CTA.
