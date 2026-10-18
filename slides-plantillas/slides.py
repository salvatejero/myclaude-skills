"""Compone slides de Instagram (1080×1350) sobre las plantillas de una marca.

    python3 slides.py slides.json marca.json

`marca.json` dice dónde están las plantillas y las fuentes, los colores y la
altura a la que empieza el texto en cada plantilla (ver marca.ejemplo.json).
Las rutas son relativas a ese fichero.

`slides.json` es una lista de slides; cada uno, una plantilla (portada, texto o
cierre) y los bloques que se pintan de arriba abajo:

    [{"plantilla": "portada", "bloques": [
        {"antetitulo": "Cómo trabajamos"},
        {"titulo": "Dos skills que usamos en todos los proyectos."}]},
     {"plantilla": "texto", "bloques": [
        {"cifra": "9.924", "etiqueta": "nodos en el repo"},
        {"codigo": "TODO: esto es lineal…", "pie": "fichero.ts"},
        {"parrafo": "…"}, {"nota": "* …"}]}]

Los PNG salen junto a slides.json como slide-1.png, slide-2.png…
"""
import json
import sys
import textwrap
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

M, ANCHO = 72, 1080 - 2 * 72

def parrafo(d, y, texto, fuente, color, interlineado=1.3):
    lineas, linea = [], ""
    for p in texto.split():
        prueba = f"{linea} {p}".strip()
        if d.textlength(prueba, font=fuente) <= ANCHO:
            linea = prueba
        else:
            lineas.append(linea)
            linea = p
    lineas.append(linea)
    for l in lineas:
        d.text((M, y), l, font=fuente, fill=color)
        y += fuente.size * interlineado
    return y

def bloque(d, y, b, c, f, portada):
    if "antetitulo" in b:
        return parrafo(d, y, b["antetitulo"], f("texto_negrita", 34), c["acento"]) + 24
    if "titulo" in b:
        return parrafo(d, y, b["titulo"], f("titulo", 92 if portada else 80), c["tinta"], 1.12) + 48
    if "parrafo" in b:
        return parrafo(d, y, b["parrafo"], f("texto", 40), c["tinta"]) + 40
    if "cifra" in b:
        d.text((M, y), b["cifra"], font=f("titulo", 128), fill=c["tinta"])
        y += 140
        if b.get("etiqueta"):
            d.text((M, y), b["etiqueta"], font=f("texto", 38), fill=c["gris"])
            y += 92
        return y
    if "codigo" in b:
        pad, paso = 36, 40
        lineas = ["// " + l for l in textwrap.wrap(b["codigo"], 48)]
        alto = len(lineas) * paso + 2 * pad
        d.rounded_rectangle((M, y, M + ANCHO, y + alto), radius=16, fill=c["caja"])
        for i, l in enumerate(lineas):
            d.text((M + pad, y + pad + i * paso), l, font=f("mono", 28), fill=c["tinta"])
        y += alto + 20
        if b.get("pie"):
            d.text((M, y), b["pie"], font=f("mono", 22), fill=c["gris"])
            y += 50
        return y + 20
    if "nota" in b:
        return parrafo(d, y, b["nota"], f("mono", 24), c["gris"]) + 20
    raise SystemExit(f"bloque desconocido: {b}")

def main():
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    spec, cfg_path = Path(sys.argv[1]), Path(sys.argv[2])
    cfg = json.loads(cfg_path.read_text())
    base = cfg_path.parent

    def f(nombre, t):
        return ImageFont.truetype(str(base / cfg["fuentes"][nombre]), t)

    for n, s in enumerate(json.loads(spec.read_text()), 1):
        plantilla = s["plantilla"]
        img = Image.open(base / cfg["plantillas"][plantilla]).convert("RGB")
        d = ImageDraw.Draw(img)
        c = cfg["colores"]["oscuro" if plantilla == "cierre" else "claro"]
        y = cfg["inicio"][plantilla]
        for b in s["bloques"]:
            y = bloque(d, y, b, c, f, plantilla == "portada")
        if y > cfg["limite"]:
            raise SystemExit(f"slide {n}: el texto se sale de la plantilla (llega a y={y:.0f}, límite {cfg['limite']})")
        salida = spec.parent / f"slide-{n}.png"
        img.save(salida)
        print(salida)

if __name__ == "__main__":
    main()
