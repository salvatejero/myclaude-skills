#!/usr/bin/env bash
# Atajos baratos para desarrollar y probar Apps de macOS desde Claude Code.
# Salida mínima: solo errores, fallos y una línea de resumen. Ver SKILL.md.
set -uo pipefail
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd); cd "$ROOT"
DD="$ROOT/.build/DerivedData"
PROJ=$(ls -d *.xcodeproj 2>/dev/null | head -1)
[[ -f project.yml ]] && NAME=$(awk '/^name:/{print $2; exit}' project.yml) || NAME=${PROJ%.xcodeproj}
SCHEME=${MAC_SCHEME:-$NAME}; APP=${MAC_APP:-$NAME}
cfg() { [[ "${1:-}" == R* ]] && echo Release || echo Debug; }
app_path() { echo "$DD/Build/Products/$(cfg "${1:-}")/$APP.app"; }

gen() {  # xcodegen solo si project.yml cambió desde la última generación
  [[ -f project.yml ]] || return 0
  [[ -n "$PROJ" && "$PROJ/project.pbxproj" -nt project.yml ]] && return 0
  xcodegen generate --quiet && PROJ=$(ls -d *.xcodeproj | head -1)
}

build() {
  gen || return 1
  local c; c=$(cfg "${1:-}")
  local out; out=$(xcodebuild -project "$PROJ" -scheme "$SCHEME" -configuration "$c" \
    -destination 'platform=macOS' -derivedDataPath "$DD" build -quiet 2>&1); local rc=$?
  echo "$out" | grep -E '(error|warning):' | grep -v '^ld: warning' | sort -u | cut -c1-260 | head -30
  [[ $rc == 0 ]] && echo "✓ build $c" || { echo "$out" | tail -5; echo "✗ build $c"; return 1; }
}

changed_pkgs() {  # paquetes con ficheros tocados respecto a HEAD (incluye sin seguimiento)
  { git diff --name-only HEAD; git ls-files --others --exclude-standard; } |
    grep -oE '^Packages/[^/]+' | sort -u
}

test_() {
  local pk="${1:-auto}" filter="${2:-}" pkgs rc=0
  if [[ "$pk" == auto ]]; then pkgs=$(changed_pkgs); [[ -z "$pkgs" ]] && { echo "· ningún paquete tocado"; return 0; }
  elif [[ "$pk" == all ]]; then pkgs=$(ls -d Packages/*/ | sed 's:/$::')
  else pkgs=$([[ -d "$pk" ]] && echo "$pk" || echo "Packages/$pk"); fi
  for p in $pkgs; do
    local out; out=$(swift test --package-path "$p" ${filter:+--filter "$filter"} 2>&1) || rc=1
    echo "$out" | grep -E '✘|error:|failed|XCTAssert|Fatal' | grep -v 'passed after' | cut -c1-260 | head -25
    echo "$out" | grep -E '^(✔|✘) Test run|Executed [0-9]+ tests' | tail -2 | sed "s|^|$p: |"
  done
  return $rc
}

pid() { pgrep -x "$APP" | head -1; }
stop() { pkill -x "$APP" 2>/dev/null; for _ in 1 2 3 4 5 6; do pid >/dev/null || { echo "· $APP parada"; return 0; }; sleep 0.5; done; pkill -9 -x "$APP"; echo "· $APP parada (kill -9)"; }

run() {
  local c="Debug"; [[ "${1:-}" == R* || "${1:-}" == D* ]] && { c=$(cfg "$1"); shift; }
  build "$c" || return 1
  stop >/dev/null
  open -a "$(app_path "$c")" "$@"
  for _ in $(seq 20); do pid >/dev/null && break; sleep 0.5; done
  pid >/dev/null || { echo "✗ no arrancó"; return 1; }
  sleep 1; echo "▶ $APP pid $(pid)"; windows
}

windows() { osascript -l JavaScript -e "Application('System Events').processes.byName('$APP').uiElements().filter(e=>e.role()==='AXWindow').map(e=>e.name()+' '+e.position()+' '+e.size()).join('\\n')" 2>&1; }

ui() {  # árbol de accesibilidad de la ventana frontal como texto (sustituye a la captura)
  local depth="${1:-6}" max="${2:-250}"
  osascript -l JavaScript - "$APP" "$depth" "$max" <<'JS'
function run(argv) {
  const [app, depth, max] = [argv[0], +argv[1], +argv[2]];
  const p = Application('System Events').processes.byName(app);
  const w = p.uiElements().filter(e => { try { return e.role() === 'AXWindow'; } catch (x) { return false; } }).slice(0, 1); if (!w.length) return 'sin ventanas';
  let n = 0, out = [];
  const s = (f) => { try { const v = f(); return v == null ? '' : String(v); } catch (e) { return ''; } };
  function walk(e, d) {
    if (n++ >= max) return;
    const role = s(() => e.role()).replace('AX', '');
    // Atributos AX en crudo: name()/description() de System Events no traen la etiqueta de SwiftUI.
    const ax = k => s(() => e.attributes.byName(k).value());
    const txt = ['AXTitle', 'AXDescription', 'AXValue', 'AXHelp'].map(ax)
      .filter((x, i, a) => x && x !== 'missing value' && a.indexOf(x) === i).join(' | ').slice(0, 80);
    const en = s(() => e.enabled()) === 'false' ? ' [off]' : '';
    if (role !== 'Group' || txt) out.push('  '.repeat(d) + role + (txt ? ' «' + txt + '»' : '') + en);
    if (d < depth) { let k = []; try { k = e.uiElements(); } catch (x) {} k.forEach(c => walk(c, d + 1)); }
  }
  w.forEach(x => walk(x, 0));
  if (n > max) out.push('… recortado a ' + max + ' nodos');
  return out.join('\n');
}
JS
}

# JXA, no AppleScript: con SwiftUI/Liquid Glass «window 1», «menu bar 1» y «whose» fallan; se filtra por rol.
jxa() { osascript -l JavaScript - "$APP" "$@" <<<"
function run(a) { const p = Application('System Events').processes.byName(a[0]);
  const top = r => p.uiElements().filter(e => { try { return e.role() === r; } catch (x) { return false; } });
  $JS }"; }

click() {  # pulsa por nombre o descripción; «Menú>Ítem» para la barra de menús
  JS='
  const q = a[1];
  if (q.includes(">")) { const [m, i] = q.split(">");
    Application(a[0]).activate(); delay(0.5);  // la barra de menús solo existe con la App delante
    const by = (l, x) => l.find(e => { try { return e.name() === x; } catch (z) { return false; } });
    const mi = by(top("AXMenuBar")[0].uiElements(), m), it = mi && by(mi.uiElements()[0].uiElements(), i);
    if (!it) return "✗ no encontrado: " + q;
    it.click(); return "· menú " + q; }
  let hit = null, n = 0;
  (function walk(e, d) { if (hit || n++ > 2000) return;
    const ax = k => { try { return String(e.attributes.byName(k).value() || ""); } catch (x) { return ""; } };
    if (d && ["AXTitle", "AXDescription", "AXHelp"].some(k => ax(k) === q)) { hit = e; return; }
    let k = []; try { k = e.uiElements(); } catch (x) {} k.forEach(c => walk(c, d + 1)); })(top("AXWindow")[0], 0);
  if (!hit) return "✗ no encontrado: " + q;
  try { hit.actions.byName("AXPress").perform(); } catch (x) { hit.click(); } return "· pulsado " + q;' jxa "$1"; }

key() { osascript -e "tell application \"$APP\" to activate" -e "tell application \"System Events\" to keystroke \"$1\"${2:+ using {$2}}"; }

shot() {  # captura solo de la ventana frontal, reducida (por defecto 800 px de ancho)
  local out="${1:-${TMPDIR:-/tmp}/mac-shot.png}" w="${2:-800}" g
  JS='const w = top("AXWindow")[0]; return w ? w.position().concat(w.size()).join(",") : "";' g=$(jxa)
  [[ -z "$g" ]] && { echo "✗ sin ventana"; return 1; }
  screencapture -x -o -R"$g" "$out" && sips -Z "$w" "$out" >/dev/null && echo "$out"
}

logs() { log show --last "${1:-60}s" --style compact --predicate "process == \"$APP\" AND messageType >= 16" 2>/dev/null | grep -v '^Timestamp' | cut -c1-240 | tail -"${2:-30}"; }

check() { [[ -x scripts/check.sh ]] || { echo "✗ no hay scripts/check.sh"; return 1; }
  local out; out=$(scripts/check.sh "$@" 2>&1); local rc=$?
  echo "$out" | grep -E '^==|✘|✗|error:|warning:' | cut -c1-260 | tail -30; echo "$out" | tail -1; return $rc; }

locked() { [[ $(ioreg -n Root -d1) == *'"CGSSessionScreenIsLocked"=Yes'* ]] && { echo "✗ pantalla bloqueada: AX y capturas no ven las ventanas. Pide al usuario que la desbloquee." >&2; return 0; }; return 1; }
case "${1:-}" in ui|click|shot|windows) locked && exit 3;; esac
case "${1:-}" in
  build) shift; build "$@";; test) shift; test_ "$@";; run) shift; run "$@";;
  stop) stop;; ui) shift; ui "$@";; click) shift; click "$@";; key) shift; key "$@";;
  shot) shift; shot "$@";; logs) shift; logs "$@";; windows) windows;; check) shift; check "$@";;
  changed) changed_pkgs;; info) echo "proj=$PROJ scheme=$SCHEME app=$(app_path)";;
  *) sed -n '2,3p' "$0"; echo "uso: mac.sh build|test|run|stop|ui|click|key|shot|logs|windows|check|changed|info"; exit 2;;
esac
