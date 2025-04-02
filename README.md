# 🚀 Gensyn AI Node - 1-Click Node Run Toolkit

Gensyn AI Node is a simple one-click toolkit to set up and run your AI node effortlessly.

## 🔥 Requirements
- **GPU Required**
- **FOR GPU Users CUDA must be installed**
- **If It's running Fine with CPU VPS Users - It'll be shared with you soon**

---

## 🔹 Step 1: Run the Toolkit
Run the following command in your terminal:
```bash
bash <(curl -sSL https://raw.githubusercontent.com/abhiag/gensyn-ai/main/g.sh)
```

### 📌 Node Installation Options
1️⃣ Press **1** to install the node  
2️⃣ Press **2** to start the node  
3️⃣ Keep it running until you see: **"Waiting for userdata.json to be created"**

---

## 🔹 Running the Node on WSL or Local Ubuntu
1. Open this link in your browser: [http://localhost:3000/](http://localhost:3000/)
2. Log in with your email  
3. Go back to the terminal and wait a few minutes  
4. When prompted for an access token:  
   - Sign up/login here: [Generate Hugging Face Token](https://huggingface.co/settings/tokens/new?tokenType=write)
   - Generate a **Write access token**

---

## 🔹 Running the Node on a VPS
1. Open **PowerShell, WSL, or Termux Mobile App**  
2. Run the following command:
```bash
ssh -L 3000:localhost:3000 root@your_vps_ip -P 22
```
📌 Replace `your_vps_ip` with your actual VPS IP and update the port `22` if necessary.

3. Open this link in your browser: [http://localhost:3000/](http://localhost:3000/)
4. Log in with your email  
5. Go back to the terminal and wait a few minutes  
6. When prompted for an access token:  
   - Sign up/login here: [Generate Hugging Face Token](https://huggingface.co/settings/tokens/new?tokenType=write)
   - Generate a **Write access token**  
7. Enter the token when prompted and **you're done!** 🎉

---

## ✅ You're All Set!
Keep your node running and start earning rewards. 🚀

