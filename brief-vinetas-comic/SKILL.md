---
name: brief-vinetas-comic
description: Genera el briefing en Markdown (.md) para pedir viñetas de cómic con IA de imágenes (Gemini u otra) manteniendo a los personajes iguales en cada imagen. Incluye el estilo (por defecto tebeo español clásico tipo escuela Bruguera), las imágenes de base y cómo usar cada una, las hojas de personaje y el prompt de cada escena, listo para pasárselo a Claude Code. Úsala cuando pidan viñetas, tiras, cómics, escenas ilustradas con personajes recurrentes o imágenes para un carrusel o post con personajes fijos, aunque no digan "briefing" ni "md".
---

# Brief de viñetas de cómic

Convierte una idea de post en un archivo `.md` que Claude Code pueda ejecutar para generar las imágenes. Esta skill **no genera las imágenes**: prepara el plan y los prompts. La generación la hace la skill `gemini-imagen` (`-r` para las referencias, `--ratio 4:5`) siguiendo las reglas de la skill `vineta-con-referencias` (no inventes opciones ni comandos).

## Por qué existe

Los modelos de imagen reinventan la cara de un personaje en cada petición, y copian todo lo que ven en las imágenes de referencia, incluidos personajes que ya no son del reparto. La solución es siempre la misma: primero **hojas de personaje** limpias y después **escenas** que las usan como referencia, con pocos personajes por imagen. El brief fija ese método para que no haya que redescubrirlo.

## Flujo

1. **Entiende la idea.** Mira qué escenas hay (suelen venir de un carrusel o post ya escrito), qué personajes salen en cada una y qué bocadillos o textos llevan. Si falta algo esencial, pregunta una sola cosa; si no, avanza.
2. **Elige personajes y referencias.** Busca en el proyecto las fichas del reparto (formato en `references/personajes.md`). Si no existen, créalas con el usuario antes de seguir. Para cualquier personaje que tenga hoja, la referencia es su hoja, nunca una escena antigua.
3. **Limita a 2 personajes por imagen.** Con más, el modelo los mezcla. Si la idea pide 3 o 4, propón repartirlos en varias viñetas o reducir el elenco, y avisa del cambio.
4. **Escribe el brief** copiando `assets/plantilla-brief.md` y rellenándola. Los prompts siempre empiezan por el bloque base de estilo de `references/estilo-bruguera.md`.
5. **Entrégalo** como archivo `.md` en la carpeta de posts del proyecto. En el mensaje solo resume qué incluye y avisa de los cambios que has hecho a la idea original (por ejemplo, una escena de cuatro personajes reducida a dos). No pegues el brief entero en el chat.

## Reglas que el brief debe incluir siempre

- **Estilo:** el bloque base de `references/estilo-bruguera.md` al principio de cada prompt. Es inspiración de estilo: nunca dibujar ni copiar personajes de otros autores, solo los del reparto.
- **Imágenes de base:** una tabla con cada archivo, qué contiene y cómo usarla. Las imágenes antiguas con personajes de un reparto anterior solo sirven para estilo y ambiente; añadir la coletilla anti-copia de identidad y género de `vineta-con-referencias` (reutilizarla, no reescribirla).
- **Fidelidad numerada:** en cada escena, "La imagen 1 es X y la imagen 2 es Y. Mantén exactamente su cara, su pelo, su cuerpo y su ropa; no cambies ningún rasgo."
- **Texto exacto:** cada bocadillo con "texto exacto: «…»", en el idioma del post, sin ningún otro texto en la imagen.
- **Corregir, no repetir:** si una escena sale bien salvo un detalle, pedir el cambio en la misma conversación ("misma imagen y mismos personajes, cambia solo X"). Regenerar desde cero cambia las caras.
- **Bocadillos deformados:** si el texto sale mal, regenerar la misma escena con bocadillos vacíos y rotular el texto después a mano con la tipografía del proyecto.
- **Colores fijos por personaje:** los de su ficha, siempre los mismos.
- **Entrega:** una carpeta con las hojas aprobadas y otra por post con `slide-N.png` (1080×1350, 4:5 vertical). Pedir a Claude Code que avise de cualquier imagen en la que un personaje no coincida con su ficha antes de seguir con la siguiente.

## Hojas de personaje

Una hoja por personaje, guardada una vez y reutilizada en todos los posts siguientes: un solo personaje, tres vistas (frente, perfil, tres cuartos), cuerpo entero, fondo liso color crema, sin texto ni decorado. Si la hoja ya existe en el proyecto, el brief la reutiliza y se salta este paso.

## Tono

Los chistes siguen el universo del proyecto. No expliques el chiste en el brief. Si el reparto tiene running gags de fondo (un objeto, un cartel), mantenlos cuando quepan.

## Otro estilo

El método es el mismo. Sustituye `references/estilo-bruguera.md` por el bloque base del nuevo estilo y conserva el resto.
