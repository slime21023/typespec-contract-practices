#!/usr/bin/env bash
# Conformance check for a TypeSpec contract against SKILL.md section 2.
# Usage: evals/check.sh [path/to/_contract]      Exit code 1 if any check fails.
# Static checks need only bash, grep and awk. Compile, format and operationId
# checks run when a TypeSpec compiler is found (PATH, $TSP, or node_modules/.bin/tsp
# in the contract's parent directories); otherwise they are reported as NOT RUN.
C="${1:-_contract}"; fails=0
bad() { echo "FAIL     $*"; fails=$((fails + 1)); }
ok()  { echo "ok       $*"; }
skip(){ echo "NOT RUN  $*"; }
[ -d "$C" ] || { echo "no such directory: $C"; exit 2; }
C=$(cd "$C" && pwd); ROOT=$(dirname "$C")
pascal() { echo "$1" | awk -F- '{for(i=1;i<=NF;i++) printf "%s", toupper(substr($i,1,1)) substr($i,2)}'; }
files=$(cd "$C" && find . -name '*.tsp' -not -path './generated/*' -not -path './node_modules/*' | sed 's#^\./##' | sort)
decl='^(@[A-Za-z.]+(\(.*\))? *)*(model|op|interface|union|scalar|alias|enum) '

# Layout
[ -f "$C/main.tsp" ] && ok "main.tsp is the entrypoint" || bad "missing _contract/main.tsp"
[ -f "$C/tspconfig.yaml" ] && ok "tspconfig.yaml present" || bad "missing _contract/tspconfig.yaml"
out=$(cd "$ROOT" && find . -name '*.tsp' -not -path './_contract/*' -not -path '*/node_modules/*' -not -path './.git/*' | head -5)
[ -z "$out" ] && ok "no TypeSpec outside _contract/" || bad "TypeSpec outside _contract/: $(echo $out)"
extra=$(cd "$C" && find . -mindepth 2 -path './modules/*' -name '*.tsp' | awk -F/ '{print $NF}' | sort -u | grep -vxE 'main.tsp|resource.tsp|requests.tsp|responses.tsp|operations.tsp')
[ -z "$extra" ] && ok "module files use the five responsibility names" || bad "unexpected module file names: $(echo $extra)"
for m in $(cd "$C" && ls -d modules/*/ 2>/dev/null); do
  [ -f "$C/${m}main.tsp" ] || bad "${m} has no main.tsp"
  [ -f "$C/${m}operations.tsp" ] || bad "${m} has no operations.tsp"
done

# Entry point and namespaces
svc=$(grep -hE '^namespace [A-Za-z0-9.]+;' "$C/main.tsp" 2>/dev/null | head -1 | sed -E 's/namespace ([^;]+);/\1/')
[ -n "$svc" ] && ok "service namespace: $svc" || bad "main.tsp declares no file-level service namespace"
n=$(cd "$C" && cat $files | grep -c '^@service'); [ "$n" = 1 ] && ok "one @service" || bad "@service count is $n"
extraDecl=$(grep -E "$decl" "$C/main.tsp" | grep -vcE 'enum Versions')
[ "$extraDecl" = 0 ] && ok "main.tsp holds no models or operations" || bad "main.tsp declares $extraDecl models/operations"
n=$(cd "$C" && cat $files | grep -cE '^namespace [^;]*\{'); [ "$n" = 0 ] && ok "no block namespaces" || bad "$n block namespace(s)"
before=$fails
for f in $files; do
  ns=$(grep -hE '^namespace ' "$C/$f" | sed -E 's/namespace ([^;{ ]+).*/\1/' | tr '\n' ' ' | sed 's/ $//')
  case "$f" in modules/*/*) exp="$svc.$(pascal "$(echo "$f" | cut -d/ -f2)")";; *) exp="$svc";; esac
  [ -z "$ns" ] && ! grep -qE "$decl" "$C/$f" && continue
  [ "$ns" = "$exp" ] || bad "$f: namespace '${ns:-none}', expected '$exp'"
  first=$(grep -nE '^(import|using|namespace) ' "$C/$f" | head -1)
  case "$first" in *:import*) ;; *) [ -n "$first" ] && grep -q '^import ' "$C/$f" && bad "$f: import after using/namespace";; esac
done
[ "$fails" = "$before" ] && ok "namespaces match directories; imports come first"

# Dependencies and library imports
for m in $(cd "$C" && ls -d modules/*/ 2>/dev/null); do
  grep -q 'responses.tsp' "$C/${m}requests.tsp" 2>/dev/null && bad "${m}requests.tsp imports responses.tsp"
  grep -q 'requests.tsp' "$C/${m}responses.tsp" 2>/dev/null && bad "${m}responses.tsp imports requests.tsp"
done
for f in $files; do
  grep -qE '@(route|get|post|put|patch|delete|path|query|header|body|statusCode|useAuth)\b' "$C/$f" && ! grep -q 'import "@typespec/http"' "$C/$f" && bad "$f uses HTTP decorators without importing @typespec/http"
  grep -qE '@(operationId|info|extension)\b' "$C/$f" && ! grep -q 'import "@typespec/openapi"' "$C/$f" && bad "$f uses OpenAPI decorators without importing @typespec/openapi"
  grep -qE '@(versioned|added|removed|renamedFrom)\b' "$C/$f" && ! grep -q 'import "@typespec/versioning"' "$C/$f" && bad "$f uses versioning decorators without importing @typespec/versioning"
done
reqresp=$(cd "$C" && grep -lE '@(statusCode|error)\b' modules/*/requests.tsp 2>/dev/null)
[ -z "$reqresp" ] && ok "requests and responses stay separate (no cross imports, no status codes in requests)" || bad "@statusCode/@error in requests: $(echo $reqresp)"

# Compiler checks
TSPBIN="${TSP:-}"; [ -z "$TSPBIN" ] && command -v tsp >/dev/null 2>&1 && TSPBIN=tsp
d="$C"; while [ -z "$TSPBIN" ] && [ "$d" != "/" ] && [ "$d" != "." ]; do
  [ -f "$d/node_modules/.bin/tsp" ] && TSPBIN="$d/node_modules/.bin/tsp"; d=$(dirname "$d"); done
if [ -z "$TSPBIN" ]; then skip "compile, format check, operationId check: no TypeSpec compiler found"
else
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  if (cd "$C" && "$TSPBIN" compile . --option "@typespec/openapi3.emitter-output-dir=$tmp") >"$tmp.log" 2>&1; then ok "tsp compile"
    ids=$(find "$tmp" -name 'openapi*.yaml' | head -1 | xargs grep -ohE 'operationId: [A-Za-z0-9_.]+' | sed 's/operationId: //')
    [ -n "$ids" ] && prefixed=$(echo "$ids" | grep -E '^[A-Z][A-Za-z0-9]*_') || prefixed=""
    [ -z "$prefixed" ] && ok "operationIds are explicit, with no Interface_ prefix" || bad "default operationIds: $(echo $prefixed) (add @operationId; existing contracts that already use this style are exempt)"
  else bad "tsp compile"; sed -E 's/[[0-9;]*m//g; s/^/         /' "$tmp.log" | head -15; fi
  if (cd "$C" && "$TSPBIN" format --check "**/*.tsp") >"$tmp.fmt" 2>&1; then ok "tsp format --check"
  else bad "tsp format --check"; sed -E 's/[[0-9;]*m//g; s/^/         /' "$tmp.fmt" | head -8; fi
  rm -f "$tmp.log" "$tmp.fmt"
fi
echo; [ "$fails" = 0 ] && echo "RESULT: PASS" || echo "RESULT: FAIL ($fails)"
exit $([ "$fails" = 0 ] && echo 0 || echo 1)
