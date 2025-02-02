#!/bin/bash

# CoinGecko API Key
API_KEY="API_KEY"

# Cryptos to track
CRYPTOS=("bitcoin" "ethereum" "monero" "solana")
CURRENCY="eur"
CACHE_FILE="/tmp/crypto_prices_cache"
LOG_FILE="/tmp/crypto_prices.log"

# Nerd Fonts Icons
BTC_ICON=$'\uf10f  ' # Bitcoin
ETH_ICON=$'\ue656  ' # Ethereum
XMR_ICON=$'\ued0a  ' # Monero
SOL_ICON=$'\uf28a '  # Solana

# Function to fetch prices
get_prices() {
    local response
    response=$(curl --request GET \
        --url "https://api.coingecko.com/api/v3/simple/price?ids=$(IFS=,; echo "${CRYPTOS[*]}")&vs_currencies=$CURRENCY" \
        --header "accept: application/json" \
        --header "x-cg-demo-api-key: $API_KEY")

    echo "$(date) - API request sent" >> "$LOG_FILE"
    echo "$(date) - Raw API response: $response" >> "$LOG_FILE"

    if [[ -n "$response" && "$response" != "null" && "$response" != "{}" ]]; then
        echo "$response" > "$CACHE_FILE"
        echo "$(date) - Prices updated successfully." >> "$LOG_FILE"
    else
        echo "$(date) - Error: Unable to fetch prices (empty or invalid response)." >> "$LOG_FILE"
    fi
}

# Check if the cache is older than one hour
if [[ ! -f "$CACHE_FILE" || $(find "$CACHE_FILE" -mmin +60) ]]; then
    get_prices
fi

# Read prices from cache
if [[ -f "$CACHE_FILE" ]]; then
    PRICE_JSON=$(cat "$CACHE_FILE" 2>/dev/null)

    BTC=$(echo "$PRICE_JSON" | jq -r '.bitcoin.eur' 2>/dev/null)
    ETH=$(echo "$PRICE_JSON" | jq -r '.ethereum.eur' 2>/dev/null)
    XMR=$(echo "$PRICE_JSON" | jq -r '.monero.eur' 2>/dev/null)
    SOL=$(echo "$PRICE_JSON" | jq -r '.solana.eur' 2>/dev/null)

    if [[ -n "$BTC" && -n "$ETH" && -n "$XMR" && -n "$SOL" ]]; then
        echo "$BTC_ICON $BTC € | $ETH_ICON $ETH € | $XMR_ICON $XMR € | $SOL_ICON $SOL €"
    else
        echo "Error: Missing data"
        echo "$(date) - Error: Invalid JSON data -> $PRICE_JSON" >> "$LOG_FILE"
    fi
else
    echo "Error: No cache available"
    echo "$(date) - Error: No cache file found." >> "$LOG_FILE"
fi
