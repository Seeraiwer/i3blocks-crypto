Voici le texte complet du **README.md** que tu peux **copier-coller directement** :

---

```markdown
# 🪙 i3blocks Crypto Prices

A simple script that displays the real-time prices of **Bitcoin (BTC), Ethereum (ETH), Monero (XMR), and Solana (SOL)** in the **i3blocks bar** under **i3WM**.

📈 **Fetches live prices from CoinGecko API** and displays them with **FontAwesome 4.7.0** icons.

---

## 📌 Features

✔ **Displays prices in EUR**  
✔ **Auto-updates every hour**  
✔ **Uses FontAwesome 4.7.0 for clean visuals**  
✔ **Optimized requests with caching**  
✔ **Fully compatible with i3blocks**

---

## 🛠 Installation

### 1️⃣ **Clone the repository**
```bash
git clone https://github.com/your-username/i3blocks-crypto-prices.git
cd i3blocks-crypto-prices
```

### 2️⃣ **Install dependencies**
Ensure that **FontAwesome 4.7.0**, **jq**, and **curl** are installed:
```bash
sudo pacman -S ttf-font-awesome jq curl
```

### 3️⃣ **Copy the script to `/usr/local/bin/`**
```bash
sudo cp crypto_prices.sh ~/.config/i3/scripts/crypto_prices.sh
sudo chmod +x ~/.config/i3/scripts/crypto_prices.sh
```

### 4️⃣ **Add to i3blocks**
Edit your `~/.config/i3blocks/config` file and add:
```ini
[crypto_prices]
command=~/.config/i3/scripts/crypto_prices.sh
interval=3600
label=₿
font=pango:FontAwesome 10
```

### 5️⃣ **Reload i3blocks**
```bash
pkill -SIGUSR1 i3blocks
```
Or restart i3WM:
```bash
i3-msg restart
```

---

## ⚡ Preview

Example of the display in i3blocks:

```
 42000 € |  3000 € |  160 € |  90 €
```
🔹 **Icons used**:  
- **Bitcoin** → `` (fa-btc)  
- **Ethereum** → `` (fa-file-code-o)  
- **Monero** → `` (fa-monero)  
- **Solana** → `` (fa-scribd)

---

## 🔗 API Used

This script fetches real-time prices using the **CoinGecko API**.

📌 **CoinGecko API Documentation**: [CoinGecko API](https://www.coingecko.com/en/api)

Make sure to replace `YOUR_API_KEY` in `crypto_prices.sh` with your CoinGecko API key.

---

## 📜 License

This project is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for more details.

---

## 🚀 Contributing

Contributions are welcome!  
- Fork the project 🍴  
- Create a branch 🛠️ (`git checkout -b feature-my-new-feature`)  
- Submit a PR 🚀  

---

## 📩 Contact

💬 **Have suggestions or questions?** Open an [Issue](https://github.com/your-username/i3blocks-crypto-prices/issues)  
```

---

### **📌 Next Steps**
1. **Copy all the text above** and save it as **`README.md`** in your project folder.
2. **Add it to your GitHub repository**:
   ```bash
   git add README.md
   git commit -m "Added README"
   git push origin main
   ```
3. **Done! 🎉** Your GitHub repository now has a well-structured README.

Let me know if you need any modifications! 🚀😎
