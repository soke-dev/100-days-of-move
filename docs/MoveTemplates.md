# Building on Movement with Aptos Templates

## Introduction
Over the past tutorials, we've explored how to write Move contracts and interact with them using the Aptos TypeScript SDK. Now, let's streamline development even further by using **Aptos Templates** to quickly build decentralized applications (dApps) on the **Movement Network**. 

### Why Use Aptos Templates?
Using **create-aptos-dapp**, developers can generate complete end-to-end dApp templates, including both the frontend and smart contract components, with minimal setup. This tool makes it easier to deploy smart contracts, interact with them from a frontend, and follow best development practices.

### Benefits of Using Templates:
- **Faster Development**: Pre-configured templates save time in setting up Move contracts and frontend integration.
- **Best Practices**: Ensures you follow Aptos-recommended structures and design principles.
- **Built-in Move Commands**: Simplifies initializing, compiling, and publishing contracts.
- **Pre-styled UI Components**: Uses **shadcn/ui** and **TailwindCSS** for a professional look.
- **Multiple dApp Types**: Choose from various templates suited for different blockchain use cases.

---

## Setting Up **create-aptos-dapp**

### Prerequisites
Ensure you have the following installed:
- **Node.js** (npm ≥ 5.2.0)
- **Python 3.6+**

### Installation
Navigate to your working directory and run:
```bash
npx create-aptos-dapp@latest
```
Follow the CLI prompts to configure your project:
- Set a **project name**
- Choose a **template**
- Select between **Mainnet** or **Devnet** for testing

---

## Tools Used in These Templates
Each template includes:
- **React Framework** for frontend development
- **Vite** for fast build times and development
- **shadcn/ui + TailwindCSS** for styling
- **Aptos TypeScript SDK** for blockchain interactions
- **Aptos Wallet Adapter** for wallet connectivity
- **Node-based Move Commands** for smart contract handling


## Available Templates

**create-aptos-dapp** offers multiple templates, each designed for a specific blockchain use case:

### **Boilerplate Template**
A simple starter dApp template with a structured project setup and basic wallet integration.

### **NFT Minting Template**
A complete **NFT minting dApp**, pre-configured with a UI, smart contract, and wallet integration for easy deployment.

### **Token Minting Template**
This template enables quick **fungible token creation** with a built-in UI and interaction tools.

### **Token Staking Template**
Provides a ready-made **token staking dApp** for projects that want to implement staking mechanisms.

### **Telegram Mini dApp Template**
A **mini dApp** optimized for Telegram, featuring a clicker game with blockchain interactions.

### **Custom Indexer Template**
This template includes a **custom blockchain indexer** to efficiently process on-chain data and display real-time insights.


---

## How to Use Templates
### Selecting a Template
Once **create-aptos-dapp** is installed, choose a template by running:
```bash
npx create-aptos-dapp@latest
```
After selection, navigate to your project folder:
```bash
cd my-project
```
Install dependencies:
```bash
npm install
```
Start the development server:
```bash
npm run dev
```

---

## Customizing Templates
### Modifying the Theme
- Edit `tailwind.config.js` to modify theme colors and typography.
- Update `frontend/index.css` to change light/dark mode styles.

### Adding Components
Run the following to add UI components using **shadcn-ui**:
```bash
npx shadcn-ui@latest add component_name
```

### Deploying Your dApp
To publish your project to a live server, ensure your root route is correctly configured. If hosting on GitHub Pages:
- Update the root route in `vite.config.ts`.

---

## Conclusion
By leveraging **create-aptos-dapp**, developers can quickly scaffold dApps, integrate Move smart contracts, and follow best practices when building on the **Movement Network**. This tool simplifies the development process and reduces setup complexity, allowing you to focus on building innovative blockchain applications.

## Reference
https://aptos.dev/en/build/create-aptos-dapp
