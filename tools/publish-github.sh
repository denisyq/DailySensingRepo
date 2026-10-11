#!/usr/bin/env bash
# publish-github.sh — 用 GitHub Contents REST API 把 staging 目录发布到 DailySensingRepo (main)
# 用法: bash tools/publish-github.sh <staging目录> "<commit message>"
# 注意: 不要用 git push（代理拦截 CONNECT，必 502）；只依赖 api.github.com。
set -u
REPO_OWNER="denisyq"
REPO_NAME="DailySensingRepo"
BRANCH="main"
STAGING="${1:-staging}"
MSG="${2:-Update daily sensing reports}"
TOKEN="${GITHUB_TOKEN:?请设置环境变量 GITHUB_TOKEN}"
API="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/contents"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cd "$STAGING" || { echo "[x] staging 目录不存在: $STAGING"; exit 1; }
FILES=$(find . -type f | sed 's|^\./||')
cd - >/dev/null || exit 1
fail=0
for f in $FILES; do
src="${STAGING}/${f}"
sha_json=$(curl -s -H "Authorization: Bearer ${TOKEN}" \
              -H "Accept: application/vnd.github+json" \
              -H "User-Agent: workbuddy" \
              "${API}/${f}?ref=${BRANCH}")
sha=$(printf '%s' "$sha_json" | grep -o '"sha"[[:space:]]*:[[:space:]]*"[a-f0-9]\{40\}"' | head -1 | grep -o '[a-f0-9]\{40\}')
if base64 -w0 "$src" > "${TMP}/b64.txt" 2>/dev/null; then :; else base64 "$src" | tr -d '\n' > "${TMP}/b64.txt"; fi
if [ -n "$sha" ]; then
printf '{"message":"%s","content":"%s","branch":"%s","sha":"%s"}' \
  "$MSG" "$(cat "${TMP}/b64.txt")" "$BRANCH" "$sha" > "${TMP}/body.json"
echo "[>] PUT ${f} (update)"
else
printf '{"message":"%s","content":"%s","branch":"%s"}' \
  "$MSG" "$(cat "${TMP}/b64.txt")" "$BRANCH" > "${TMP}/body.json"
echo "[>] PUT ${f} (create)"
fi
code=$(curl -s -o "${TMP}/resp.json" -w '%{http_code}' -X PUT \
-H "Authorization: Bearer ${TOKEN}" \
-H "Accept: application/vnd.github+json" \
-H "User-Agent: workbuddy" \
--data-binary "@${TMP}/body.json" \
"${API}/${f}")
if [ "$code" = "200" ] || [ "$code" = "201" ]; then
echo "[OK] ${f} -> HTTP ${code}"
else
echo "[FAIL] ${f} -> HTTP ${code}"; head -c 300 "${TMP}/resp.json"; echo
fail=1
fi
done
exit "$fail"
