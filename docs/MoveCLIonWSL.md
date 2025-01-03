# **Installing Move CLI on Windows Using WSL**

## **Welcome to 100 Days of Move!**  
In this journey, we will dive deep into the Move language—learning everything from the basics to advanced concepts. This series aims to help you understand Move, develop innovative projects, and contribute to the ecosystem.

Move is a powerful programming language designed for secure and efficient blockchain development. It emphasizes safety, expressiveness, and modularity, making it an excellent choice for building smart contracts and decentralized applications.

For Windows users, running Move CLI can be challenging, especially if you’re on a lightweight machine that struggles with running Linux in virtual environments. However, with Windows Subsystem for Linux (WSL), you can seamlessly install and run the Move CLI directly on your Windows machine, enabling you to start writing Move code without limitations.

---

## **Getting Started: Install WSL**

If you haven’t set up WSL yet, follow the [official guide here](https://learn.microsoft.com/en-us/windows/wsl/install) to install WSL on your Windows machine. Choose **Ubuntu** as your Linux distribution.

Alternatively, watch this step-by-step video tutorial:  
[Installing WSL Ubuntu on Windows](https://youtu.be/HrAsmXy1-78?si=7cG44sUbzNnsm79n)

---

## **Installing Movement CLI**

Once you have WSL Ubuntu set up, follow the steps below to install Move CLI using Ubuntu.
If you encounter any issues during the installation, refer to the [Common Errors and Solutions](#common-errors-and-solutions) section below for fixes.

---

### **Installation Steps**

#### **Step 1: Clone the Aptos-Core Repository**
Run the following command to clone the `aptos-core` repository and navigate into the directory:  
```bash
git clone https://github.com/movementlabsxyz/aptos-core.git && cd aptos-core
```

#### **Step 2: Install Prerequisites**
Use the automatic script provided in the repository to install all the necessary prerequisites:  
```bash
./scripts/dev_setup.sh
```  
### **Prerequisites**
1. **Rust Programming Language**  
2. **Git**  
3. **CMake**  
4. **LLVM**  
5. **libssl-dev**  
6. **libclang-dev**

After the script completes, update your shell environment:  
```bash
source ~/.cargo/env
```  
Verify that `cargo` is installed:  
```bash
cargo --version
```

#### **Step 3: Build the Move CLI Tool**
Build the CLI tool using the following command:  
```bash
cargo build -p movement
```  
The binary will be generated at:  
```bash
target/debug/movement
```
Kindly note that for the initial build, the time taken could be significant. However, with subsequent builds, it shouldn't take as long.

#### **Step 4: Add the Move CLI to Your PATH**
Move the executable to a directory in your PATH:  
```bash
sudo cp target/debug/movement /usr/local/bin/
```  
Alternatively, if you prefer using a custom directory:  
```bash
mkdir -p $HOME/.local/bin
cp target/debug/movement $HOME/.local/bin/
export PATH=$PATH:$HOME/.local/bin
```  
Make the PATH change permanent by adding it to `~/.bashrc` or `~/.zshrc`.

#### **Step 5: Verify Installation**
Run the following command to confirm the installation:  
```bash
movement --help
```

**Result**:  
```plaintext
Command Line Interface (CLI) for developing and interacting with the Movement blockchain

Usage: movement <COMMAND>

Commands:
  account     Tool for interacting with accounts
  config      Tool for interacting with configuration of the Movement CLI tool
  genesis     Tool for setting up an Movement chain Genesis transaction
  governance  Tool for on-chain governance
  info        Show build information about the CLI
  init        Tool to initialize current directory for the movement tool
  key         Tool for generating, inspecting, and interacting with keys
  move        Tool for Move smart contract related operations
  multisig    Tool for interacting with multisig accounts
  node        Tool for operations related to nodes
  stake       Tool for manipulating stake and stake pools
  update      Update the CLI or other tools it depends on
  help        Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version
```

If you see the above output, congratulations! You have successfully installed Move CLI.

---

## **Follow-Up Instructions**

Now that Move CLI is installed, you can now build and publish your first Move code (hello_movement). Follow the instructions in the [Movement Developer Portal](https://developer.movementnetwork.xyz/learning-paths/basic-concepts/01-install-movement-cli) to get started.

---

## **Common Errors and Solutions**

As you go through the installation steps, you might come across some common errors. Below are the fixes for them:

---

### **1. Missing Prerequisites**
- **Error**: `Could not find libssl-dev` or `libclang-dev`.  
- **Solution**: Install them manually using the following commands:  
  ```bash
  sudo apt-get update
  sudo apt-get install -y libssl-dev libclang-dev cmake llvm
  ```

---

### **2. `cp: cannot create regular file`**
- **Error**: Copying the binary to `/opt/homebrew/bin` fails because the directory does not exist.  
- **Solution**: Use a standard directory like `/usr/local/bin` or create a custom directory in your PATH:  
  ```bash
  mkdir -p $HOME/.local/bin
  cp target/debug/movement $HOME/.local/bin/
  export PATH=$PATH:$HOME/.local/bin
  echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.bashrc
  ```

---

### **3. `API error: AccountNotFound`**
- **Error**: Occurs when trying to publish without a valid account.  
- **Solution**: Ensure the account exists and has been initialized properly on the network: 
  ```bash
  movement account create
  ```

---


### **4. `EOF while parsing a value`**
- **Error**: Configuration file issues.  
- **Solution**: Check your `config.yaml` for missing or incorrect values.  

---


## **Additional Resources**

- **Official Movement Developer Portal**: [https://developer.movementnetwork.xyz/](https://developer.movementnetwork.xyz/)  
- **WSL Documentation**: [https://learn.microsoft.com/en-us/windows/wsl](https://learn.microsoft.com/en-us/windows/wsl)  

---

## **Need Help?**

If you encounter any issues not covered in this guide, feel free to join the [100 days of move Telegram](https://t.co/5BB0TGRHmG) and reach out for assistance.

