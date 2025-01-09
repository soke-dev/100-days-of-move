# Building a To-Do List DApp on Aptos

## Introduction
This guide walks you through creating a To-Do List decentralized application (dApp) on the Movement  blockchain. It is divided into two main parts:

1. **Smart Contract Development**: Writing the Move contract to handle the to-do list logic.
2. **Frontend Development**: Building a React-based user interface to interact with the smart contract.

---

## Part 1: Smart Contract Development

### Setting Up the Project

#### Create a New Move Project
1. Navigate to your project root and create a directory for the Move project:
   ```bash
   mkdir my_todo_list
   cd my_todo_list
   movement move init --name my_todo_list
   ```
2. Your directory structure should now include:
   ```
   my_todo_list/
     ├── Move.toml
     └── sources/
   ```

#### Initialize Aptos Account
1. Run the following command to create a new account:
   ```bash
   movement init --network testnet
   ```
2. This will generate a `.movement` folder with a `config.yaml` file containing your account details.

#### Update Move.toml
1. Open `Move.toml` and add your account address:
   ```toml
   [addresses]
   todolist_addr = "<your_account_address>"
   ```

### Writing the Contract

#### Define the Module
Create a `todolist.move` file in the `sources` directory and define the basic module structure:
```move
module todolist_addr::todolist {

}
```

#### Define Structs
Add the following structs:
```move
struct TodoList has key {
    tasks: Table<u64, Task>,
    set_task_event: event::EventHandle<Task>,
    task_counter: u64
}

struct Task has store, drop, copy {
    task_id: u64,
    address: address,
    content: String,
    completed: bool
}
```
These structs store the to-do list, tasks, and events.

#### Entry Functions
##### Create List
```move
public entry fun create_list(account: &signer) {
    let tasks_holder = TodoList {
        tasks: table::new(),
        set_task_event: account::new_event_handle<Task>(account),
        task_counter: 0
    };
    move_to(account, tasks_holder);
}
```

##### Create Task
```move
public entry fun create_task(account: &signer, content: String) acquires TodoList {
    let signer_address = signer::address_of(account);
    let todo_list = borrow_global_mut<TodoList>(signer_address);
    let counter = todo_list.task_counter + 1;
    let new_task = Task {
        task_id: counter,
        address: signer_address,
        content,
        completed: false
    };
    table::upsert(&mut todo_list.tasks, counter, new_task);
    todo_list.task_counter = counter;
    event::emit_event(&mut todo_list.set_task_event, new_task);
}
```

##### Complete Task
```move
public entry fun complete_task(account: &signer, task_id: u64) acquires TodoList {
    let signer_address = signer::address_of(account);
    let todo_list = borrow_global_mut<TodoList>(signer_address);
    let task_record = table::borrow_mut(&mut todo_list.tasks, task_id);
    assert!(!task_record.completed, 1);
    task_record.completed = true;
}
```

### Compile and Test
1. Compile the smart contract:
   ```bash
   movement move compile
   ```
2. Publish the contract:
   ```bash
   movement move test
   ```

---

## Part 2: Frontend Development

### Setting Up the React App

#### Initialize React App
1. Create a React app:
   ```bash
   npx create-react-app client --template typescript
   ```
2. Navigate into the `client` directory and start the server:
   ```bash
   cd client
   npm start
   ```

#### Install Dependencies
1. Install necessary packages:
   ```bash
   npm install antd @aptos-labs/wallet-adapter-react @aptos-labs/wallet-adapter-ant-design @aptos-labs/ts-sdk petra-plugin-wallet-adapter
   ```

#### Set Up Wallet Integration
1. Wrap your app with the Aptos wallet provider in `index.tsx`:
   ```tsx
   import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
   import { PetraWallet } from "petra-plugin-wallet-adapter";

   const wallets = [new PetraWallet()];

   ReactDOM.render(
       <AptosWalletAdapterProvider plugins={wallets} autoConnect={true}>
           <App />
       </AptosWalletAdapterProvider>,
       document.getElementById("root")
   );
   ```

### Fetch Data from Chain
Use the Aptos SDK to fetch tasks:
```tsx
import { Aptos } from "@aptos-labs/ts-sdk";

const aptos = new Aptos();

const fetchTasks = async (account: string) => {
    const resource = await aptos.getAccountResource({
        accountAddress: account,
        resourceType: `${moduleAddress}::todolist::TodoList`,
    });
    return resource;
};
```

### Build UI Components
1. Use Ant Design components for layout and inputs.
2. Add buttons for creating lists and tasks.
3. Use a list to display tasks and checkboxes to mark them as completed.

### Submit Data to Chain
Create a function to submit transactions to create tasks:
```tsx
const addNewTask = async (taskContent: string) => {
    const transaction = {
        data: {
            function: `${moduleAddress}::todolist::create_task`,
            functionArguments: [taskContent],
        },
    };
    const response = await signAndSubmitTransaction(transaction);
    await aptos.waitForTransaction(response.hash);
};
```

---

## Full Source Code Availability
The complete source code for both the smart contract and frontend application is available in the project repository. You can explore, clone, and use it as a reference for your own projects.


---

## Conclusion
You’ve successfully built a full-stack To-Do List dApp on Movement, complete with a smart contract and frontend integration. This guide showcased:

- Writing a Move smart contract.
- Setting up a React frontend.
- Fetching and submitting data to the blockchain.

Feel free to enhance the app further by adding more features or improving the UI!