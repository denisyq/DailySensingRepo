#!/usr/bin/env bash
# publish-github.sh — 用 GitHub Contents REST API 把 staging 目录发布到 DailySensingRepo (main)
# 用法: bash tools/publish-github.sh <staging目录> "<commit message>"
# 说明: 本执行环境的 HTTP 代理会拦截 git 的 CONNECT 隧道 (push 一律 502)，
#       但 HTTPS REST API 可正常通过，因此统一走 Contents API，不要用 git push。
# 认证: 优先读环境变量 GITHUB_TOKEN，读不到时用脚本内的备份 token。
set -u

REPO_OWNER="denisyq"
REPO_NAME="DailySensingRepo"
BRANCH="main"
STAGING="${1:-staging}"
MSG="${2:-Update daily sensing reports}"
TOKEN="${GITHUB_TOKEN:-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}"

API="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/contents"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "[i] 目标: ${REPO_OWNER}/${REPO_NAME}@${BRANCH}  staging=${STAGING}"
echo "[i] token 来源: $([ -n "${GITHUB_TOKEN:-}" ] && echo '环境变量 GITHUB_TOKEN' || echo '备份 token')"

# 收集待发布文件（相对 staging 的路径）
cd "$STAGING" || { echo "[x] staging 目录不存在: $STAGING"; exit 1; }
FILES=$(find . -type f | sed 's|^\./||')
cd - >/dev/null || exit 1

fail=0
for f in $FILES; do
  src="${STAGING}/${f}"
  # 1) 取已存在文件的 sha（404 则省略）
  sha_json=$(curl -s -H "Authorization: Bearer ${TOKEN}" \
                  -H "Accept: application/vnd.github+json" \
                  -H "User-Agent: workbuddy" \
                  "${API}/${f}?ref=${BRANCH}")
  sha=$(printf '%s' "$sha_json" | grep -o '"sha"[[:space:]]*:[[:space:]]*"[a-f0-9]\{40\}"' | head -1 | grep -o '[a-f0-9]\{40\}')

  # 2) base64 编码（GNU coreutils 用 -w0；BSD/macOS base64 无 -w，直接调用）
  if base64 -w0 "$src" > "${TMP}/b64.txt" 2>/dev/null; then :; else base64 "$src" | tr -d '\n' > "${TMP}/b64.txt"; fi

  # 3) 组装 body.json（大文件必须走 --data-binary @文件）
  if [ -n "$sha" ]; then
    printf '{"message":"%s","content":"%s","branch":"%s","sha":"%s"}' \
      "$MSG" "$(cat "${TMP}/b64.txt")" "$BRANCH" "$sha" > "${TMP}/body.json"
    echo "[>] PUT ${f} (update, sha=${sha:0:7}…)"
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
    echo "[✓] ${f} → HTTP ${code}"
  else
    echo "[✗] ${f} → HTTP ${code}"
    head -c 300 "${TMP}/resp.json"; echo
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "[✓] 全部文件发布成功"
else
  echo "[!] 存在失败文件"
fi
exit "$fail"
