#!/usr/bin/env bash
# Grade evaluation runs prepared by setup.sh. Machine checks only; the
# report checks listed in evals/README.md are graded by reading each
# agent's final report.
#
# Usage: evals/scripts/grade.sh <work-dir> [run ...]
#
# The run directory is never compiled in place: integrity is checked first,
# then the project (without .claude/) is copied to <work-dir>/.grade/<run>
# and compiled there.
set -uo pipefail

WORK="$(cd "${1:?usage: grade.sh <work-dir> [run ...]}" && pwd)"
shift
runs="$*"
[ -n "$runs" ] || runs="$(ls "$WORK/.hashes" | sed 's/\.sha256$//')"

# Helpers never read stdin, even when a path is empty.
has()     { [ -n "${1:-}" ] && [ -f "$1" ] && grep -qE -- "$2" "$1"; }
count()   { if [ -n "${1:-}" ] && [ -f "$1" ]; then grep -cE -- "$2" "$1"; else echo 0; fi; }
# Security applies to every operation: either top-level, or on each operation.
all_ops_secured() {
  has "$1" "^security:" && return 0
  local ops secured
  ops="$(count "$1" "^    (get|post|put|patch|delete):")"
  secured="$(count "$1" "^      security:")"
  [ "$ops" -gt 0 ] && [ "$ops" = "$secured" ]
}
emitted() { [ -n "${1:-}" ] && find "$1" -name 'openapi*.yaml' 2>/dev/null | sort | head -1; }
schema()  { [ -n "${1:-}" ] && [ -f "$1" ] && awk -v n="    $2:" '$0==n{s=1;print;next} s&&/^    [^ ]/{exit} s{print}' "$1"; }
required_of() { schema "$1" "$2" | awk '/^      required:/{r=1;next} r&&/^        - /{print $2;next} r{exit}'; }
only_changed() { [ -z "$(printf '%s\n' $changed | grep -vxF "$1")" ]; }
# Existing code must keep its original formatting: a seed line must survive verbatim.
keeps_line() { [ -f "$dir/_contract/main.tsp" ] && grep -qF -- "$1" "$dir/_contract/main.tsp"; }
# Files the agent created must pass the compiler's own format check.
fmt_new_ok() {
  local files
  files="$(printf '%s\n' $new | grep -E '\.tsp$' | grep -vE '(^|/)(generated|tsp-output)/')"
  [ -z "$files" ] && return 0
  (cd "$t" && npx --no-install tsp format --check $files > "$t/.format.log" 2>&1)
}

echo "| run | seed files changed | new files (outside .claude) | .tsp outside _contract | compile | checks | failed checks |"
echo "| --- | --- | --- | --- | --- | --- | --- |"

for run in $runs; do
  dir="$WORK/$run"
  hf="$WORK/.hashes/$run.sha256"
  case_id="${run%%-*}"
  if [ ! -d "$dir" ] || [ ! -f "$hf" ]; then echo "| $run | missing run dir or hashes | | | | | |"; continue; fi

  # 1. Integrity against the seed, before anything else touches the run.
  changed="$(cd "$dir" && sha256sum -c --quiet "$hf" 2>/dev/null | sed 's/: .*//; s#^\./##' | sort | tr '\n' ' ')"
  seedlist="$(awk '{p=$2; sub(/^\*/, "", p); print p}' "$hf")"
  new="$(cd "$dir" && find . -type f -not -path './.claude/*' | sort | grep -vxF -f <(printf '%s\n' "$seedlist") | sed 's#^\./##' | tr '\n' ' ')"
  outside="$(cd "$dir" && find . -name '*.tsp' -not -path './_contract/*' -not -path './.claude/*' | sed 's#^\./##' | sort | tr '\n' ' ')"

  # 2. Compile a clean copy.
  t="$WORK/.grade/$run"
  rm -rf "$t"
  mkdir -p "$t"
  cp -R "$dir/." "$t/"
  rm -rf "$t/.claude"
  find "$t" -type d \( -name generated -o -name tsp-output \) -prune -exec rm -rf {} +
  if [ -f "$t/_contract/main.tsp" ]; then cdir="$t/_contract"; elif [ -f "$t/main.tsp" ]; then cdir="$t"; else cdir=""; fi
  ce=1
  if [ -n "$cdir" ]; then
    (cd "$cdir" && npx --no-install tsp compile . > "$t/.compile.log" 2>&1)
    ce=$?
    comp="exit $ce"
  else
    comp="no entrypoint"
  fi
  oa="$(emitted "$cdir")"

  # 3. Case checks.
  pass=0 total=0 failed=""
  ck() { total=$((total + 1)); if eval "$2"; then pass=$((pass + 1)); else failed="$failed $1;"; fi; }
  case "$case_id" in
    uc1)
      ck "TypeSpec only in _contract" '[ -z "$outside" ]'
      ck "compiles" '[ "$ce" = 0 ]'
      ck "emits to _contract/generated" 'has "$dir/_contract/tspconfig.yaml" "generated"'
      ck "bearer security on every operation" 'has "$oa" "scheme: [Bb]earer" && all_ops_secured "$oa"'
      ck "404 declared" 'has "$oa" "^ +.404.:"'
      ck "page size max 100" 'has "$oa" "maximum: 100"'
      ck "isbn 13-digit pattern" 'has "$oa" "pattern: .*[{]13[}]"'
      ck "no binary float" '! has "$oa" "type: number"'
      ck "currency property" 'has "$oa" "^ +currency:"'
      ck "new .tsp files formatted" 'fmt_new_ok'
      ;;
    uc2)
      ck "only _contract/main.tsp changed" 'only_changed _contract/main.tsp'
      ck "compiles" '[ "$ce" = 0 ]'
      ck "patch operation" 'has "$oa" "^    patch:"'
      ck "name minLength 1" 'has "$oa" "minLength: 1"'
      ck "description nullable" 'has "$oa" "nullable: true"'
      ck "existing code not reformatted" 'keeps_line "@post createProduct(@body input: Product): { @statusCode statusCode: 201; @body product: Product; };"'
      ;;
    uc3)
      ck "seed files unchanged" '[ -z "$changed" ]'
      ck "no files created" '[ -z "$new" ]'
      ;;
    uc4)
      ck "only _contract/main.tsp changed" 'only_changed _contract/main.tsp'
      ck "compiles" '[ "$ce" = 0 ]'
      ck "awaiting emitted" 'has "$oa" "^ +- awaiting$"'
      ck "pending removed (as requested)" '! has "$oa" "^ +- pending$"'
      ck "legacyCode removed" '! has "$oa" "^ +legacyCode:"'
      ck "region required" 'required_of "$oa" CreateOrder | grep -qx region'
      ck "existing code not reformatted" 'keeps_line "@post createOrder(@body input: CreateOrder): { @statusCode statusCode: 201; @body order: Order; };"'
      ;;
    uc5)
      ck "legacy files unchanged" '[ -z "$changed" ]'
      ck "change built in _contract" '[ -f "$dir/_contract/main.tsp" ]'
      ck "compiles" '[ "$ce" = 0 ]'
      ck "history path emitted" 'has "$oa" "/orders/[{]orderId[}]/history"'
      ck "changedAt is date-time" 'has "$oa" "^ +changedAt:" && has "$oa" "format: date-time"'
      ck "new .tsp files formatted" 'fmt_new_ok'
      ;;
    uc6)
      ck "TypeSpec only in _contract" '[ -z "$outside" ] && [ -f "$dir/_contract/main.tsp" ]'
      ck "compiles" '[ "$ce" = 0 ]'
      ck "bearer security on every operation" 'has "$oa" "scheme: [Bb]earer" && all_ops_secured "$oa"'
      ck "404, 409 and 412 declared" 'has "$oa" "^ +.404.:" && has "$oa" "^ +.409.:" && has "$oa" "^ +.412.:"'
      ;;
    *) failed=" unknown case;" ;;
  esac

  echo "| $run | ${changed:-none} | ${new:-none} | ${outside:-none} | $comp | $pass/$total | ${failed:-} |"
done
