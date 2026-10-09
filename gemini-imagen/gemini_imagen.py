#!/usr/bin/env python3
"""Pide a Gemini una imagen a partir de un prompt de texto.

    python3 gemini_imagen.py "un gato astronauta, foto realista"
    python3 gemini_imagen.py "logo minimalista en azul" -o logo.png
    python3 gemini_imagen.py "boceto de un robot" -n 3 --ratio 16:9
    python3 gemini_imagen.py "la misma escena, de noche" -r referencia.jpg -o noche.png

La clave sale de GEMINI_API_KEY, del entorno o de un `.env` en el directorio
actual (que no se versiona). No hay dependencias nuevas: REST directo
con `urllib`.
"""
import argparse
import base64
import json
import os
import pathlib
import urllib.error
import urllib.request

MODELO = "gemini-2.5-flash-image"
API = f"https://generativelanguage.googleapis.com/v1beta/models/{MODELO}:generateContent"
COSTE = 0.04


def clave_api() -> str:
    """La clave de Gemini: del entorno, y si no, del `.env` del directorio actual."""
    if os.environ.get("GEMINI_API_KEY"):
        return os.environ["GEMINI_API_KEY"]
    env = pathlib.Path(".env")
    if env.exists():
        for linea in env.read_text().splitlines():
            nombre, _, valor = linea.strip().removeprefix("export ").partition("=")
            if nombre.strip() == "GEMINI_API_KEY" and valor.strip():
                return valor.strip().strip("\"'")
    raise SystemExit("falta GEMINI_API_KEY: ponla en el entorno "
                     "o en un .env del directorio actual. En el repositorio no va nunca.")


def pedir(prompt: str, ratio: str, referencias: list[pathlib.Path] = ()) -> bytes:
    """Una llamada, una imagen. Devuelve los bytes que vuelven.

    Las referencias van ANTES del texto: es como Gemini interpreta mejor
    «imita el estilo/personajes de estas imágenes» al generar la nueva.
    """
    partes = [{"inline_data": {
        "mime_type": "image/png" if r.suffix.lower() == ".png" else "image/jpeg",
        "data": base64.b64encode(r.read_bytes()).decode(),
    }} for r in referencias]
    partes.append({"text": prompt})
    cuerpo = {
        "contents": [{"parts": partes}],
        "generationConfig": {
            "responseModalities": ["IMAGE"],
            "imageConfig": {"aspectRatio": ratio},
        },
    }
    peticion = urllib.request.Request(
        API,
        data=json.dumps(cuerpo).encode(),
        headers={"Content-Type": "application/json",
                 "x-goog-api-key": clave_api()},
    )
    try:
        with urllib.request.urlopen(peticion, timeout=120) as r:
            respuesta = json.load(r)
    except urllib.error.HTTPError as e:
        raise SystemExit(f"{e.code} {e.read().decode()[:500]}")

    for parte in respuesta["candidates"][0]["content"]["parts"]:
        if "inlineData" in parte:
            return base64.b64decode(parte["inlineData"]["data"])
    # Pasa cuando el filtro de seguridad la para: viene texto y ninguna imagen.
    raise SystemExit(f"la respuesta no trae imagen — {json.dumps(respuesta)[:500]}")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("prompt")
    p.add_argument("-o", "--salida", type=pathlib.Path, default=None,
                   help="ruta del fichero (por defecto imagen-N.png en el directorio actual)")
    p.add_argument("-n", "--cuantas", type=int, default=1)
    p.add_argument("--ratio", default="1:1", help="p.ej. 1:1, 16:9, 4:3")
    p.add_argument("-r", "--referencia", type=pathlib.Path, action="append",
                   default=[], metavar="IMAGEN",
                   help="imagen de referencia (repetible) para estilo/personajes")
    args = p.parse_args()

    faltan = [str(r) for r in args.referencia if not r.exists()]
    if faltan:
        raise SystemExit(f"no existe(n): {', '.join(faltan)}")

    print(f"{args.cuantas} imagen(es) a {MODELO}, unos {args.cuantas * COSTE:.2f} $"
          + (f", con {len(args.referencia)} referencia(s)" if args.referencia else ""))
    for i in range(args.cuantas):
        datos = pedir(args.prompt, args.ratio, args.referencia)
        if args.salida:
            destino = (args.salida if args.cuantas == 1
                      else args.salida.with_stem(f"{args.salida.stem}-{i + 1}"))
        else:
            destino = pathlib.Path(f"imagen-{i + 1}.png")
        destino.write_bytes(datos)
        print(f"  {destino}")


if __name__ == "__main__":
    main()
