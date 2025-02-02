#!/bin/bash

# Clé API CoinGecko
API_KEY="API_KEY"

# Cryptos à suivre
CRYPTOS=("bitcoin" "ethereum" "monero" "solana")
CURRENCY="eur"
CACHE_FILE="/tmp/crypto_prices_cache"
LOG_FILE="/tmp/crypto_prices.log"

# Icônes Nerd Fonts
BTC_ICON=$'\uf10f  ' # Bitcoin
ETH_ICON=$'\ue656  ' # Ethereum
XMR_ICON=$'\ued0a  ' # Monero
SOL_ICON=$'\uf28a '  # Solana

# Fonction pour récupérer les prix
get_prices() {
    local response
    response=$(curl --request GET \
        --url "https://api.coingecko.com/api/v3/simple/price?ids=$(IFS=,; echo "${CRYPTOS[*]}")&vs_currencies=$CURRENCY" \
        --header "accept: application/json" \
        --header "x-cg-demo-api-key: $API_KEY")

    echo "$(date) - Requête API envoyée" >> "$LOG_FILE"
    echo "$(date) - Réponse brute de l'API : $response" >> "$LOG_FILE"

    if [[ -n "$response" && "$response" != "null" && "$response" != "{}" ]]; then
        echo "$response" > "$CACHE_FILE"
        echo "$(date) - Prix mis à jour avec succès." >> "$LOG_FILE"
    else
        echo "$(date) - Erreur : Impossible de récupérer les prix (réponse vide ou invalide)." >> "$LOG_FILE"
    fi
}

# Vérifie si le cache a plus d'une heure
if [[ ! -f "$CACHE_FILE" || $(find "$CACHE_FILE" -mmin +60) ]]; then
    get_prices
fi

# Lire les prix depuis le cache
if [[ -f "$CACHE_FILE" ]]; then
    PRICE_JSON=$(cat "$CACHE_FILE" 2>/dev/null)

    BTC=$(echo "$PRICE_JSON" | jq -r '.bitcoin.eur' 2>/dev/null)
    ETH=$(echo "$PRICE_JSON" | jq -r '.ethereum.eur' 2>/dev/null)
    XMR=$(echo "$PRICE_JSON" | jq -r '.monero.eur' 2>/dev/null)
    SOL=$(echo "$PRICE_JSON" | jq -r '.solana.eur' 2>/dev/null)

    if [[ -n "$BTC" && -n "$ETH" && -n "$XMR" && -n "$SOL" ]]; then
        echo "$BTC_ICON $BTC € | $ETH_ICON $ETH € | $XMR_ICON $XMR € | $SOL_ICON $SOL €"
    else
        echo "Erreur: Données manquantes"
        echo "$(date) - Erreur : Données JSON invalides -> $PRICE_JSON" >> "$LOG_FILE"
    fi
else
    echo "Erreur: Pas de cache disponible"
    echo "$(date) - Erreur : Aucun fichier de cache trouvé." >> "$LOG_FILE"
fi
