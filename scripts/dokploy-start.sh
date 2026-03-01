#!/bin/bash
# OpenClaw Dokploy entrypoint — runs non-interactive onboarding on first boot.
set -euo pipefail

CONFIG_FILE="${HOME}/.openclaw/openclaw.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "[openclaw] First boot: running non-interactive setup..."

  ONBOARD_ARGS=(
    "onboard"
    "--non-interactive"
    "--accept-risk"
    "--mode" "local"
    "--gateway-port"  "${OPENCLAW_GATEWAY_PORT:-18789}"
    "--gateway-bind"  "${OPENCLAW_GATEWAY_BIND:-lan}"
    "--gateway-auth"  "${OPENCLAW_GATEWAY_AUTH:-token}"
    "--skip-channels"
    "--skip-skills"
    "--skip-health"
  )

  if [ -n "${OPENCLAW_GATEWAY_TOKEN:-}" ]; then
    ONBOARD_ARGS+=("--gateway-token" "$OPENCLAW_GATEWAY_TOKEN")
  fi

  AUTH_CHOICE="${OPENCLAW_AUTH_CHOICE:-openrouter-api-key}"
  ONBOARD_ARGS+=("--auth-choice" "$AUTH_CHOICE")

  case "$AUTH_CHOICE" in
    openrouter-api-key)
      [ -n "${OPENROUTER_API_KEY:-}" ] && ONBOARD_ARGS+=("--openrouter-api-key" "$OPENROUTER_API_KEY") ;;
    apiKey)
      [ -n "${ANTHROPIC_API_KEY:-}" ] && ONBOARD_ARGS+=("--anthropic-api-key" "$ANTHROPIC_API_KEY") ;;
    openai-api-key)
      [ -n "${OPENAI_API_KEY:-}" ]    && ONBOARD_ARGS+=("--openai-api-key"    "$OPENAI_API_KEY") ;;
    gemini-api-key)
      [ -n "${GEMINI_API_KEY:-}" ]    && ONBOARD_ARGS+=("--gemini-api-key"    "$GEMINI_API_KEY") ;;
    mistral-api-key)
      [ -n "${MISTRAL_API_KEY:-}" ]   && ONBOARD_ARGS+=("--mistral-api-key"   "$MISTRAL_API_KEY") ;;
    xai-api-key)
      [ -n "${XAI_API_KEY:-}" ]       && ONBOARD_ARGS+=("--xai-api-key"       "$XAI_API_KEY") ;;
  esac

  openclaw "${ONBOARD_ARGS[@]}"
  echo "[openclaw] Setup complete."
else
  echo "[openclaw] Config already exists — skipping onboarding."
fi

# Allow the Control UI when behind a reverse proxy (e.g. Dokploy/nginx).
# Host-header fallback is safe here because the proxy sets the Host header to the configured domain.
openclaw config set gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback true

echo "[openclaw] Starting gateway on port ${OPENCLAW_GATEWAY_PORT:-18789}..."
exec openclaw gateway \
  --port "${OPENCLAW_GATEWAY_PORT:-18789}" \
  --bind "${OPENCLAW_GATEWAY_BIND:-lan}"
