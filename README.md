# i3blocks Crypto Prices

Script Bash simple pour afficher les prix en temps reel de **Bitcoin (BTC), Ethereum (ETH), Monero (XMR) et Solana (SOL)** dans la barre **i3blocks** (i3WM).

Les donnees proviennent de l'API **CoinGecko** et les icones proviennent de **Nerd Fonts**.

---

## Fonctionnalites

- Affichage en EUR
- Mise en cache locale (1 h) pour limiter les appels API
- Journalisation des erreurs dans le cache
- Compatible i3blocks

---

## Installation

### 1) Cloner le depot
```bash
git clone https://github.com/your-username/i3blocks-crypto-prices.git
cd i3blocks-crypto-prices
```

### 2) Installer les dependances
Requis: `bash`, `curl`, `jq` et une police **Nerd Fonts**.

Exemples:
```bash
# Arch
sudo pacman -S jq curl ttf-nerd-fonts-symbols

# Debian/Ubuntu
sudo apt install jq curl fonts-nerd-fonts

# Fedora
sudo dnf install jq curl nerd-fonts
```

### 3) Installer le script
```bash
mkdir -p ~/.config/i3/scripts
cp crypto_prices.sh ~/.config/i3/scripts/crypto_prices.sh
chmod +x ~/.config/i3/scripts/crypto_prices.sh
```

### 4) Ajouter le module i3blocks
Dans `~/.config/i3blocks/config`:
```ini
[crypto_prices]
command=~/.config/i3/scripts/crypto_prices.sh
interval=3600
label=₿
```

### 5) Recharger i3blocks
```bash
pkill -SIGUSR1 i3blocks
```
Ou redemarrer i3WM:
```bash
i3-msg restart
```

---

## Configuration

- **Cle API CoinGecko**: editer `crypto_prices.sh` et remplacer `API_KEY="API_KEY"` par votre cle.
- **Devises**: modifier `CURRENCY="eur"` si besoin.
- **Cryptos**: modifier le tableau `CRYPTOS=(...)`.

Cache et logs:
- Cache: `~/.cache/crypto_prices/crypto_prices.json`
- Log: `~/.cache/crypto_prices/crypto_prices.log`

---

## Apercu

```
 42000 € |  3000 € |  160 € |  90 €
```

---

## API

Documentation CoinGecko: https://www.coingecko.com/en/api

---

## Licence

Ce projet est distribue sous **GNU AGPL v3**.  
Voir `LICENSE` pour le texte complet.
