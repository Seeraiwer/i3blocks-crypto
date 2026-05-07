#!/usr/bin/env bash
# i3blocks — prix crypto (CoinGecko). Clé : COINGECKO_API_KEY ou ~/.config/i3/secrets/coingecko_apikey
# Le fichier peut avoir des commentaires (#) : la première ligne non vide et non commentaire = clé.
set -euo pipefail

if [[ -z "${HOME:-}" || "$HOME" == "/" ]]; then
    _u="${USER:-${LOGNAME:-}}"
    [[ -z "$_u" ]] && _u=$(id -un 2>/dev/null)
    HOME=$(getent passwd "$_u" 2>/dev/null | cut -d: -f6)
fi
if [[ -z "$HOME" || ! -d "$HOME" ]]; then
    HOME=$(eval echo ~"$(id -un 2>/dev/null)" 2>/dev/null)
fi
[[ -z "$HOME" || ! -d "$HOME" ]] && HOME="/tmp"

_script_path="${BASH_SOURCE[0]:-$0}"
[[ -z "$_script_path" ]] && _script_path="$0"
case "$_script_path" in
    "~"|"~"/*) _script_path="$HOME/${_script_path#~/}" ;;
esac
if [[ "$_script_path" != /* ]]; then
    _script_path="$(cd "$(dirname "$_script_path")" && pwd)/$(basename "$_script_path")"
fi
_SCRIPT_REAL=$(readlink -f "$_script_path" 2>/dev/null || realpath "$_script_path" 2>/dev/null || echo "$_script_path")
_SCRIPT_DIR=$(dirname "$_SCRIPT_REAL")
_CFG_SECRETS="${XDG_CONFIG_HOME:-$HOME/.config}/i3/secrets"
I3_SECRETS="${I3_SECRETS:-$HOME/.config/i3/secrets}"

resolve_coingecko_key() {
    [[ -n "${COINGECKO_API_KEY:-}" ]] && { printf '%s' "$COINGECKO_API_KEY"; return 0; }
    local kf="${COINGECKO_KEYFILE:-}"
    case "$kf" in "~"|"~"/*) kf="$HOME/${kf#~/}" ;; esac
    local f k line
    for f in \
        "$kf" \
        "$HOME/.config/i3/secrets/coingecko_apikey" \
        "$I3_SECRETS/coingecko_apikey" \
        "$_CFG_SECRETS/coingecko_apikey" \
        "$_SCRIPT_DIR/../secrets/coingecko_apikey"
    do
        [[ -z "$f" ]] && continue
        [[ -r "$f" ]] || continue
        while IFS= read -r line || [[ -n "$line" ]]; do
            line="${line//$'\r'/}"
            line="${line#$'\xef\xbb\xbf'}"
            line="${line#"${line%%[![:space:]]*}"}"
            line="${line%"${line##*[![:space:]]}"}"
            [[ -z "$line" || "$line" == \#* ]] && continue
            k="${line%%#*}"
            k="${k#"${k%%[![:space:]]*}"}"
            k="${k%"${k##*[![:space:]]}"}"
            [[ -n "$k" ]] && { printf '%s' "$k"; return 0; }
        done <"$f"
    done
    return 1
}

set +e
API_KEY="$(resolve_coingecko_key)"
set -euo pipefail
CRYPTOS=("bitcoin" "bitcoin-cash" "monero")
CURRENCY="${CRYPTO_CURRENCY:-eur}"
[[ "$CURRENCY" =~ ^[a-zA-Z]{3}$ ]] || CURRENCY="eur"
CURRENCY_LC="${CURRENCY,,}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/crypto_prices"
CACHE_FILE="$CACHE_DIR/crypto_prices.json"
LOG_FILE="$CACHE_DIR/crypto_prices.log"
LOG_VERBOSE="${CRYPTO_LOG_VERBOSE:-0}"
CACHE_MIN="${CRYPTO_CACHE_MIN:-60}"

BTC_ICON=$'\uf10f  '
BCH_ICON=$'\U000f0813  '
XMR_ICON=$'\ued0a  '

mkdir -p "$CACHE_DIR"
chmod 700 "$CACHE_DIR" 2>/dev/null || true

if ! command -v jq >/dev/null 2>&1; then
    echo "jq manquant"
    exit 1
fi

if [[ -z "$API_KEY" ]]; then
    echo "CoinGecko : pas de clé (~/.config/i3/secrets/ ou à côté du script)"
    exit 0
fi

if [[ -f "$LOG_FILE" ]] && [[ $(wc -c < "$LOG_FILE" 2>/dev/null || echo 0) -gt 1048576 ]]; then
    : > "$LOG_FILE"
fi

log_msg() {
    echo "$(date -Iseconds) $1" >> "$LOG_FILE"
}

get_prices() {
    local response url
    url="https://api.coingecko.com/api/v3/simple/price?ids=$(IFS=,; echo "${CRYPTOS[*]}")&vs_currencies=${CURRENCY_LC}"
    response=$(curl --fail --silent --show-error --max-time 15 --connect-timeout 8 \
        -H "accept: application/json" \
        -H "x-cg-demo-api-key: $API_KEY" \
        "$url") || {
        log_msg "curl failed"
        return 1
    }
    log_msg "API OK"
    [[ "$LOG_VERBOSE" == "1" ]] && log_msg "body: ${response:0:500}"

    local ok
    ok=$(echo "$response" | jq -e \
        'has("bitcoin") and has("bitcoin-cash") and has("monero")' 2>/dev/null) || ok=fail
    if [[ "$ok" != "true" ]]; then
        log_msg "invalid JSON structure"
        return 1
    fi
    printf '%s' "$response" > "$CACHE_FILE"
    log_msg "cache updated"
}

need_fetch=true
if [[ -f "$CACHE_FILE" ]]; then
    age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
    (( age < CACHE_MIN * 60 )) && need_fetch=false
fi

if $need_fetch; then
    get_prices || true
fi

if [[ ! -f "$CACHE_FILE" ]]; then
    echo "Pas de cache (API / clé ?)"
    log_msg "no cache"
    exit 0
fi

PRICE_JSON=$(<"$CACHE_FILE")
BTC=$(echo "$PRICE_JSON" | jq -r ".bitcoin.${CURRENCY_LC} // empty" 2>/dev/null)
BCH=$(echo "$PRICE_JSON" | jq -r ".\"bitcoin-cash\".${CURRENCY_LC} // empty" 2>/dev/null)
XMR=$(echo "$PRICE_JSON" | jq -r ".monero.${CURRENCY_LC} // empty" 2>/dev/null)

sym="€"
[[ "$CURRENCY_LC" == "usd" ]] && sym="\$"

if [[ -n "$BTC" && -n "$BCH" && -n "$XMR" ]]; then
    echo "$BTC_ICON$BTC $sym | $BCH_ICON$BCH $sym | $XMR_ICON$XMR $sym"
else
    echo "Données incomplètes"
    log_msg "incomplete display"
fi
