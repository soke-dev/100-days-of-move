# Movement Digital Asset Standard

## Table of Contents
1. [Overview of NFTs](#overview-of-nfts)
2. [Design Principles](#design-principles)
3. [Collections and Tokens as Objects](#collections-and-tokens-as-objects)
4. [Royalties](#royalties)
5. [Token Lifecycle](#token-lifecycle)
   - [Collection Creation](#collection-creation)
   - [Collection Customization](#collection-customization)
   - [Token Creation](#token-creation)
   - [Token Properties](#token-properties)
   - [Token Customization](#token-customization)
   - [Token Burn](#token-burn)
   - [Token Transfer](#token-transfer)
6. [Aptos Token ("No Code" Solution)](#aptos-token-no-code-solution)
   - [Property Map](#property-map)
   - [Creator Management](#creator-management)
   - [Further Customization](#further-customization)
7. [Fungible Token (Semi-Fungible Support)](#fungible-token-semi-fungible-support)
8. [Resources & References](#resources-references)
9. [usage](#Usage-Notes)

---

## Overview of NFTs
A **Non-Fungible Token (NFT)** is a unique digital asset stored on a blockchain. Each NFT has:
- **Name**: Uniquely identifies the asset within a collection.
- **Description**: Explains the NFT’s purpose or story.
- **URI**: Points to off-chain data (e.g., media, extended metadata).
- **Supply**: Number of editions (1 for one-of-a-kind, >1 for multi-edition NFTs).

Most NFTs belong to a **Collection**. A collection defines:
- **Name**: Must be unique within the creator’s account.
- **Description**: Explains the collection’s theme or purpose.
- **URI**: Points to collection-level off-chain data.
- **Supply / Maximum**: Tracks how many NFTs exist or can exist in the collection. If `maximum` is 0, supply is untracked.

---

## Design Principles
The Movement Digital Asset Standard aims for:
1. **Flexibility** – Highly customizable NFTs to suit any creative design.
2. **Composability** – Multiple NFTs can easily be combined to form new, more complex objects.
3. **Scalability** – Emphasizes parallelism and performance for large-scale use.

All base token functionalities in Movement are non-entry, meaning they **cannot** be called directly from off-chain. Creators either:
- Write their own modules that build on top of the base functionalities.
- Use a “no code” solution like **aptos_token** for features like custom metadata or soul-bound tokens.

---

## Collections and Tokens as Objects
In this standard, **collections** and **tokens** each exist as separate on-chain **objects**. They have distinct addresses, which can be referenced:
- **On-chain** via references in Move structs (e.g., `Object<Collection>`).
- **Off-chain** by passing object addresses into entry functions or API calls.

Each object can store multiple resources, letting creators add custom logic or data without altering the framework.

---

## Royalties
Royalties are added to collections or tokens as separate resources, managed by a **royalty module**. They can be updated if a **MutatorRef** (a storable permission structure) is generated at creation time. A token can have different royalty settings than its collection.

---

### Collection Creation
A **collection** is a set of NFTs with a shared theme. You can choose **fixed supply** or **unlimited supply**.

```move
// Example: fixed supply collection
public entry fun create_collection(creator: &signer) {
    let max_supply = 1000;
    collection::create_fixed_collection(
        creator,
        "My Collection Description",
        max_supply,
        "My Collection",
        royalty,
        "https://mycollection.com",
    );
}

// Example: unlimited supply collection
public entry fun create_collection(creator: &signer) {
    collection::create_unlimited_collection(
        creator,
        "My Collection Description",
        "My Collection",
        royalty,
        "https://mycollection.com",
    );
}
```

**Attributes**:
- **Collection name** (unique within the creator’s account).
- **Description** (updatable if `MutatorRef` is created).
- **URI** (updatable via `MutatorRef`, max 512 characters).
- **Royalty** (changeable via `MutatorRef` if created).

You can also retrieve a **`MutatorRef`** to mutate the collection’s description and URI after creation:

```move
let collection_constructor_ref = &collection::create_unlimited_collection(...);
let mutator_ref = collection::get_mutator_ref(collection_constructor_ref);
// Store mutator_ref for future updates
```

---

### Collection Customization
You can add custom resources and logic to a collection. For instance:

```move
struct MyCollectionMetadata has key {
    creation_timestamp_secs: u64,
}

public entry fun create_collection(creator: &signer) {
    let collection_constructor_ref = &collection::create_unlimited_collection(...);
    let collection_signer = &object::generate_signer(collection_constructor_ref);
    move_to(collection_signer, MyCollectionMetadata { creation_timestamp_secs: timestamp::now_seconds() });
}
```

This approach allows you to store additional data (e.g., creation time, special rules).

---

### Token Creation
Tokens also exist as **separate objects**. You can choose:
1. **Named tokens** (`create_named_token`):  
   - Deterministic addresses (based on hashing the creator, collection name, token name).  
   - Deleting ("burning") a named token removes its data but leaves a defunct object.

```move
public entry fun mint_token(creator: &signer) {
    token::create_named_token(
        creator,
        "My Collection",
        "My named Token description",
        "My named token",
        royalty,
        "https://mycollection.com/my-named-token.jpeg",
    );
}
```

2. **Unnamed tokens** (`create`):  
   - Uses a GUID from the creator’s account, resulting in a unique but non-deterministic address.  
   - Typically recommended unless you specifically need deterministic addresses.

```move
public entry fun mint_token(creator: &signer) {
    token::create(
        creator,
        "My Collection",
        "My named Token description",
        "My named token",
        royalty,
        "https://mycollection.com/my-named-token.jpeg",
    );
}
```

### Token Properties
Each token can have:
- **Name** (unique within a collection),
- **Description** (updatable via `MutatorRef`),
- **URI** (updatable via `MutatorRef`),
- **Royalty** (can differ from collection royalty).

You can retrieve a `MutatorRef` at creation time:

```move
let token_constructor_ref = &token::create(...);
let mutator_ref = token::generate_mutator_ref(token_constructor_ref);
```

---

### Token Customization
Similar to collections, you can attach additional resources or data to tokens:

```move
struct CustomTokenData has key {
    special_attribute: u64,
}

public entry fun mint_token(creator: &signer) {
    let token_constructor_ref = &token::create(...);
    let token_signer = &object::generate_signer(token_constructor_ref);
    move_to(token_signer, CustomTokenData { special_attribute: 42 });
}
```

---

### Token Burn
Creators can **burn** tokens if they generated a `BurnRef` during creation:

```move
public entry fun mint_token(creator: &signer) {
    let token_constructor_ref = &token::create(...);
    let burn_ref = token::generate_burn_ref(token_constructor_ref);
    // Store burn_ref for future burning
}

public entry fun burn_token(token: Object<Token>) {
    // Remove all custom data
    let token_address = object::object_address(&token);
    let CustomData { ... } = move_from<CustomData>(token_address);

    // Retrieve the stored burn_ref
    token::burn(burn_ref);
}
```

- **Named Tokens**: The object remains as a “burned” placeholder but is defunct.
- **Unnamed Tokens**: Burn fully deletes the token’s object.

---

### Token Transfer
Tokens can be transferred by simply moving them as objects:

```move
object::transfer(&signer, recipient_address, token_object);
```

---

## Movement Token ("No Code" Solution)
**Movement Token** is a convenience layer on top of the Digital Asset Standard, providing entry functions for common scenarios:

- **Soul bound tokens** (non-transferable by holders).
- **PropertyMap** for custom key-value metadata.
- **Freezing/Unfreezing** tokens.
- **Creator management** for updating token/collection metadata.

### Property Map
Property maps allow storing custom typed data. Example usage:

```move
public entry fun mint(
    creator: &signer,
    collection: String,
    description: String,
    name: String,
    uri: String,
    property_keys: vector<String>,
    property_types: vector<String>,
    property_values: vector<vector<u8>>,
) acquires AptosCollection, AptosToken
```

### Creator Management
By default, the creator can:
- **Mint** or **burn** tokens (including soul bound tokens).
- **Freeze** or **unfreeze** token transfers.
- **Update** collection or token metadata, including royalty, name, description, and URI.
- **Add/Remove** properties from a token’s property map.

### Further Customization
If you need more advanced logic (e.g., force transferring a soul bound token), you must implement your own module on top of the base standard rather than rely on `aptos_token`’s entry functions.

---

## Fungible Token (Semi-Fungible Support)
Similar to **EIP-1155**, this standard also supports fungible or semi-fungible tokens. For example, if you have an “Armor” collection, each armor type can be minted multiple times.

```move
public entry fun create_armor_type(creator: &signer, armor_type: String) {
    let new_armor_type_constructor_ref = &token::create(
        creator,
        "Armor",
        "Armor description",
        armor_type,
        royalty,
        "https://myarmor.com/my-named-token.jpeg",
    );
    // Make it fungible
    primary_fungible_store::create_primary_store_enabled_fungible_asset(
        new_armor_type_constructor_ref,
        maximum_number_of_armors,
        armor_type,
        "ARMOR",
        0, // No decimals
        "https://mycollection.com/armor-icon.jpeg",
        "https://myarmor.com",
    );
    // Optionally add more properties (durability, defense, etc.)
}
```
## Usage Notes

1. **Named Address**:  
   - Replace `0xYourAddress` with your actual deployment address or use a named address (e.g., `nft_contract = "_"` in your `Move.toml`) and publish 


2. **Publish**:
   ```bash
   movementmove publish
   ```
3. **Collection Creation**:
   - Call `create_unlimited_collection(creator, "My Collection", "A cool collection", "https://example.com", 5)` to create an unlimited collection with 5% royalty, for instance.

4. **Mint Token**:
   - Call `mint_token(creator, "My Collection", "TokenName", "My NFT Desc", "https://example.com/token.png", 5)` to create a new token.

5. **Burn Token**:
   - You need the `BurnRef` from the time of minting. Then call `burn_token(burner, token_object, burn_ref)`.

---


This approach allows multiple instances of the same item (type of armor) under one token definition, effectively making it a **DFA** (Digital and Fungible Asset).


**Enjoy building with the Movement Digital Asset Standard!** Its flexibility, composability, and scalability allow you to create powerful NFTs, collections, and fungible assets. Feel free to extend the base standard with custom data and logic to meet any project requirements.