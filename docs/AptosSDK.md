# Interacting with Move Contracts Using the Aptos TypeScript SDK

## Introduction
Over the past few tutorials, we’ve focused on writing Move contracts. Now, let’s explore how to interact with those contracts using the Aptos TypeScript SDK. While we’re building on the **Movement Network**, meaning you can leverage the Aptos TypeScript SDK to communicate with the chain.

This guide explains how to set up the SDK, configure it for Movement’s Bardock Testnet, and execute common operations such as reading on-chain data and submitting transactions. For more details on available functions, consult the specific SDK version’s reference documentation.

---

## Installation

Choose one of your preferred package managers to install the SDK:

```bash
# npm
npm install @aptos-labs/aptos-ts-sdk

# pnpm
pnpm add @aptos-labs/aptos-ts-sdk

# yarn
yarn add @aptos-labs/aptos-ts-sdk

# bun
bun add @aptos-labs/aptos-ts-sdk
```

---

## Imports

To begin, import the necessary components from the SDK:

```js
const {
  Account,
  Aptos,
  AptosConfig,
  Network,
  Ed25519PrivateKey
} = require("@aptos-labs/aptos-ts-sdk");
```

---

## Configuration

Set up the SDK to connect to **Movement’s Bardock Testnet** (or your preferred endpoint).

```js
const config = new AptosConfig({
  network: Network.CUSTOM,
  fullnode: "https://aptos.testnet.bardock.movementlabs.xyz/v1",
  faucet: "https://faucet.testnet.bardock.movementnetwork.xyz/"
});

// Initialize the Aptos client
const aptos = new Aptos(config);
```

> **Note**: Refer to the [Movement documentation](https://docs.movementnetwork.xyz/devs/networkEndpoints) for a list of available endpoints.

---

## Interacting with the Chain

### 1. Account Setup

Create or load an account using your private key:
```js
const privateKey = new Ed25519PrivateKey("YOUR_PRIVATE_KEY");
const account = Account.fromPrivateKey({ privateKey });
```

Be sure to replace `"YOUR_PRIVATE_KEY"` with your actual private key. Never commit or share private keys publicly.

---

### 2. Reading Data

Here’s an example of using a **view function** to read on-chain data:
```js
const viewPayload = {
  function: "0x1::message::get_message",
  functionArguments: [accountAddress]
};

const result = await aptos.view({ payload: viewPayload });
console.log("On-chain message:", result);
```

---

### 3. Sending Transactions

#### Build and Submit a Transaction

1. **Build** the transaction:
   ```js
   const transaction = await aptos.transaction.build.simple({
     sender: accountAddress,
     data: {
       function: "0x1::message::set_message",
       functionArguments: ["Hello Movement!"]
     },
   });
   ```

2. **Sign** it:
   ```js
   const signature = aptos.transaction.sign({
     signer: account,
     transaction
   });
   ```

3. **Submit** the signed transaction:
   ```js
   const committedTxn = await aptos.transaction.submit.simple({
     transaction,
     senderAuthenticator: signature
   });
   ```

4. **Wait** for completion:
   ```js
   const response = await aptos.waitForTransaction({
     transactionHash: committedTxn.hash
   });
   console.log("Transaction response:", response);
   ```
   
> **Tip**: Always confirm the transaction is executed successfully before fetching new on-chain data.

---

## Example Code

Below is a more comprehensive script based on the “Your First Move Contract” tutorial. It shows how to:

- Configure the SDK for Movement’s Porto Testnet  
- Create an account from a private key  
- Build and submit transactions  
- Read on-chain data

```js
const {
  Account,
  Aptos,
  AptosConfig,
  Network,
  Ed25519PrivateKey
} = require("@aptos-labs/aptos-ts-sdk");

// Define the custom network configuration
const config = new AptosConfig({
  network: Network.CUSTOM,
  fullnode: "https://aptos.testnet.bardock.movementlabs.xyz/v1",
  faucet: "https://faucet.testnet.bardock.movementnetwork.xyz/"
});

// Define the module address and functions
const MODULE_ADDRESS = "";
const SET_MESSAGE_FUNCTION = `${MODULE_ADDRESS}::message::set_message`;
const GET_MESSAGE_FUNCTION = `${MODULE_ADDRESS}::message::get_message`;

const PRIVATE_KEY = "YOUR_PRIVATE_KEY"; // Replace with your private key
const MESSAGE = "gmove";

const setMessage = async () => {
  // Setup the client
  const aptos = new Aptos(config);

  // Create an account from the provided private key
  const privateKey = new Ed25519PrivateKey(PRIVATE_KEY);
  const account = Account.fromPrivateKey({ privateKey });
  const accountAddress = account.accountAddress;

  console.log(`Using account: ${accountAddress}`);

  // Build the transaction payload
  const payload = {
    function: SET_MESSAGE_FUNCTION,
    type_arguments: [],
    arguments: [MESSAGE],
  };

  // Optionally, view the current message
  const viewPayload = {
    function: GET_MESSAGE_FUNCTION,
    functionArguments: [accountAddress]
  };
  try {
    const message = await aptos.view({ payload: viewPayload });
    console.log("Existing message:", message);
  } catch (error) {
    console.error("Error reading existing message:", error);
  }

  // Build a transaction to set a new message
  const transaction = await aptos.transaction.build.simple({
    sender: accountAddress,
    data: {
      function: SET_MESSAGE_FUNCTION,
      functionArguments: [MESSAGE]
    },
  });

  // Sign the transaction
  const signature = aptos.transaction.sign({ signer: account, transaction });

  // Submit the transaction to chain
  const committedTxn = await aptos.transaction.submit.simple({
    transaction,
    senderAuthenticator: signature,
  });

  console.log(`Submitted transaction: ${committedTxn.hash}`);
  const response = await aptos.waitForTransaction({ transactionHash: committedTxn.hash });
  console.log("Transaction response:", response);

  // View the updated on-chain message
  const newMessage = await aptos.view({ payload: viewPayload });
  console.log("New message:", newMessage);
};

setMessage().catch((err) => {
  console.error("Error setting message:", err);
});
```

---

## Conclusion

You’ve now seen how to leverage the Aptos TypeScript SDK on the **Movement Network**. From account management and viewing on-chain data to building, signing, and submitting transactions—this guide should help you get started.  

For more detailed usage of the SDK, refer to the official SDK documentation or examples provided within Movement’s ecosystem.

Happy building on **Movement**!