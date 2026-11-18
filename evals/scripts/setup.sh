#!/usr/bin/env bash
# Prepare evaluation runs from the case seeds.
#
# Usage: evals/scripts/setup.sh <work-dir>
# Environment (optional):
#   CASES="uc1-bookstore uc2-patch"  cases to prepare (default: all under evals/cases)
#   VARIANTS="base skill"            base = no skill, skill = skill installed in .claude/skills
#   RUNS=1                           runs per case and variant
#   SKIP_INSTALL=1                   do not install the pinned TypeSpec packages
#
# Creates, for each run:
#   <work-dir>/<case>-<variant>-<n>/   the project the agent works in
#   <work-dir>/.hashes/<run>.sha256    seed hashes used by grade.sh
#   <work-dir>/prompts/<run>.md        the prompt to give the agent
set -euo pipefail

EVALS="$(cd "$(dirname "$0")/.." && pwd)"
REPO="$(cd "$EVALS/.." && pwd)"
SKILL_SRC="$REPO/skills/typespec-contract-practices"
WORK="${1:?usage: setup.sh <work-dir>}"
mkdir -p "$WORK/.hashes" "$WORK/prompts"
WORK="$(cd "$WORK" && pwd)"
CASES="${CASES:-$(ls "$EVALS/cases")}"
VARIANTS="${VARIANTS:-base skill}"
RUNS="${RUNS:-1}"

# Agents on Windows need native paths in their prompt.
winpath() { if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi; }

# Pinned toolchain, shared by every run through Node's parent-directory resolution.
if [ "${SKIP_INSTALL:-0}" != 1 ] && [ ! -d "$WORK/node_modules/@typespec/compiler" ]; then
  cat > "$WORK/package.json" <<'EOF'
{
  "name": "typespec-skill-evals",
  "private": true,
  "dependencies": {
    "@typespec/compiler": "1.18.0",
    "@typespec/http": "1.18.0",
    "@typespec/openapi": "1.18.0",
    "@typespec/openapi3": "1.18.0",
    "@typespec/versioning": "0.88.0"
  }
}
EOF
  (cd "$WORK" && npm install --no-audit --no-fund)
fi

for c in $CASES; do
  [ -d "$EVALS/cases/$c/seed" ] || { echo "unknown case: $c" >&2; exit 1; }
  for v in $VARIANTS; do
    for n in $(seq 1 "$RUNS"); do
      run="$c-$v-$n"
      dir="$WORK/$run"
      rm -rf "$dir"
      mkdir -p "$dir"
      cp -R "$EVALS/cases/$c/seed/." "$dir/"
      (cd "$dir" && find . -type f | sort | xargs -r sha256sum) > "$WORK/.hashes/$run.sha256"

      note="" scope="" report=""
      if [ "$v" = skill ]; then
        mkdir -p "$dir/.claude/skills"
        cp -R "$SKILL_SRC" "$dir/.claude/skills/"
        note="此專案已安裝 agent skill：$(winpath "$dir/.claude/skills/typespec-contract-practices/SKILL.md") ，需要時可以讀取。"
        scope="與 skill 目錄"
        report="並列出你實際讀過的 skill 檔案（沒有讀就寫「無」）。"
      fi

      t="$(cat "$EVALS/cases/$c/prompt.md")"
      t="${t//'{{PROJECT_DIR}}'/"$(winpath "$dir")"}"
      t="${t//'{{SKILL_NOTE}}'/"$note"}"
      t="${t//'{{SKILL_SCOPE}}'/"$scope"}"
      t="${t//'{{SKILL_REPORT}}'/"$report"}"
      printf '%s\n' "$t" > "$WORK/prompts/$run.md"
      echo "prepared $run"
    done
  done
done
