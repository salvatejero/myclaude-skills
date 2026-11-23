---
name: macos-dev
description: Bucle barato de compilar, probar y verificar Apps de macOS (Swift, SwiftUI/AppKit, xcodegen, paquetes SwiftPM locales). Úsala siempre que vayas a compilar con xcodebuild, pasar swift test, arrancar la App para ver un cambio, mirar su interfaz, pulsar botones o menús, hacer capturas o leer sus logs, en cualquier repo con .xcodeproj, project.yml o Package.swift para macOS, aunque no se diga "skill".
---

# Desarrollo y pruebas de macOS, baratos

Herramienta: `~/.claude/skills/macos-dev/mac.sh`. Detecta proyecto, esquema y App (`project.yml` → `name:`, si no el `.xcodeproj`). Cambia con `MAC_SCHEME=… MAC_APP=…`. DerivedData fijo en `.build/DerivedData`, así que compila incremental. Solo saca errores, fallos y una línea de resumen.

```sh
M=~/.claude/skills/macos-dev/mac.sh
$M build [Release]           # xcodegen solo si project.yml cambió · errores/avisos únicos · ✓/✗
$M test [auto|all|Pkg] [filtro]  # auto = solo paquetes tocados (git diff + sin seguimiento)
$M run [Release] [ficheros…] # build + cierra la anterior + abre (con documentos) + espera pid + ventanas
$M ui [prof=6] [max=250]     # árbol de accesibilidad de la ventana frontal, como TEXTO
$M click "Nombre"            # pulsa un elemento por nombre o descripción de AX
$M click "Archivo>Guardar"   # ítem de la barra de menús (pone la App delante)
$M key s "command down"      # atajo de teclado
$M shot [ruta] [ancho=800]   # captura SOLO de la ventana, reducida; imprime la ruta
$M logs [seg=60] [líneas=30] # errores y fallos del log unificado de la App
$M windows | stop | changed | info
$M check [--sanitize]        # scripts/check.sh del repo, resumido (solo antes de mergear)
```

## Escalera de verificación: para en el primer peldaño que lo demuestre

Cada peldaño cuesta más tiempo y tokens que el anterior.

1. **Compila**: `$M build`. Agrupa varias ediciones antes de compilar; no compiles tras cada línea.
2. **Test del paquete tocado**: `$M test` (auto), o `$M test Pkg Filtro` cuando sabes qué test toca. Lógica nueva → test en el paquete, no prueba a mano.
3. **Estado de la UI como texto**: `$M run fichero` + `$M ui` + `$M click`. Comprueba textos, botones activos o no ([off]), filas y hojas sin imagen. Sube `max` solo si sale «recortado».
4. **Captura**: `$M shot` solo cuando importa *cómo se ve* (diseño, Liquid Glass, recortes). Lee la imagen una vez; con `-R` o un ancho de 500 basta para un detalle.
5. **Control del escritorio** (computer-use, o checklist a Claude Desktop si el repo lo pide en memoria): solo para lo que AX no hace — arrastrar y soltar, diálogos del sistema (NSOpenPanel), Finder, juicio visual fino. Agrupa los pasos en un `computer_batch` y no pidas captura tras cada clic.

`$M check` (formato + todos los tests + build) va **antes de mergear**, no en cada iteración.

## Reglas que ahorran

- Nunca `xcodebuild` a pelo sin `-derivedDataPath` fijo: un DerivedData nuevo es una compilación entera.
- Nunca vuelques la salida completa de `xcodebuild` o `swift test`; si `mac.sh` no basta, `| grep -E 'error:|✘' | head`.
- No uses `sleep` largos para esperar a la App: `run` ya espera el pid. Para algo asíncrono, sondea `$M ui` o `$M windows` en un bucle corto.
- Datos de prueba en el scratchpad o en las fixtures del repo, nunca en `~/Downloads` del usuario.
- Bucles largos de «compila, falla, corrige» con causa conocida → subagente `sonnet` con los ficheros y el criterio de hecho en el prompt.
- Al acabar: `$M stop` y comprobar que no queda nada (y los simuladores, según CLAUDE.md).

## Límites conocidos

- Con SwiftUI/Liquid Glass, AppleScript `window 1`, `menu bar 1` y `whose` no ven nada; `mac.sh` usa JXA y filtra por rol (`AXWindow`, `AXMenuBar`). Si haces osascript a mano, igual.
- La barra de menús solo existe en AX con la App delante (`click "M>I"` ya la activa).
- Con la pantalla bloqueada, AX devuelve ventanas vacías y la captura sale negra: `ui`, `click`, `shot` y `windows` salen con código 3 y lo dicen. Pide al usuario que desbloquee; no lo tomes por un fallo de la App.
- Un `Button` sin nombre en `ui` no prueba que falte `.accessibilityLabel`: antes de dar de alta un bug, mira el código.
- `ui` necesita permiso de Accesibilidad para la terminal; `shot`, de Grabación de pantalla. Si fallan por permisos, díselo al usuario.
