module 0xYourAddress::NftContract {
    use moovement_token_objects::collection;
    use moovement_token_objects::token;
    use aptos_framework::object::{self, Object};
    use aptos_framework::account;
    use aptos_framework::timestamp;
    use aptos_framework::error;
    use aptos_framework::signer;
    use aptos_framework::debug::print;
    
    /// Optional: Additional data to attach to the token object.
    struct MyTokenData has key {
        special_attribute: u64
    }

    /// Creates an **unlimited** collection named `collection_name`
    /// with the given description, URI, and optional royalty.
    /// Returns the `collection::ConstructorRef` (non-storable).
    public entry fun create_unlimited_collection(
        creator: &signer,
        collection_name: String,
        description: String,
        uri: String,
        royalty: u64,
    ) {
        // Create unlimited collection
        let constructor_ref = &collection::create_unlimited_collection(
            creator,
            description,
            collection_name,
            royalty,
            uri,
        );

        // Example: Generate a signer for the collection object
        // to attach custom resources if needed
        let coll_signer = &object::generate_signer(constructor_ref);
        // Optionally store more data on the collection object here
        // e.g. creation time
        move_to(coll_signer, MyCollectionMetadata {
            creation_timestamp_secs: timestamp::now_seconds()
        });
    }

    /// Metadata structure for a collection, just as an example
    struct MyCollectionMetadata has key {
        creation_timestamp_secs: u64
    }

    /// Mints a new token under an existing collection named `collection_name`.
    /// This uses `token::create` (unnamed token) which does not produce
    /// deterministic addresses. You can also use `create_named_token` if needed.
    public entry fun mint_token(
        creator: &signer,
        collection_name: String,
        token_name: String,
        description: String,
        uri: String,
        royalty: u64
    ) {
        // Create a new token object
        let token_constructor_ref = &token::create(
            creator,
            collection_name,
            description,
            token_name,
            royalty,
            uri
        );

        // Optional: attach custom data
        let token_signer = &object::generate_signer(token_constructor_ref);
        move_to(token_signer, MyTokenData { special_attribute: 42 });

        // Example: If you want to burn later, create a burn_ref now
        let burn_ref = token::generate_burn_ref(token_constructor_ref);
        // You'd store burn_ref somewhere safe, e.g. in a resource
        // This code just prints it (not recommended for production)
        print(&burn_ref);
    }

    /// Burns the specified token object if you have a previously generated BurnRef.
    /// If using unnamed tokens, this will fully delete the token object.
    /// If it's a named token, the object remains but becomes a defunct "burned" token.
    public entry fun burn_token(
        burner: &signer,
        token_to_burn: Object<token::Token>,
        burn_ref: token::BurnRef
    ) {
        // Before burning, remove any custom data from the token object
        let token_addr = object::object_address(&token_to_burn);
        // If MyTokenData is present, remove it
        if exists<MyTokenData>(token_addr) {
            let _data = move_from<MyTokenData>(token_addr);
            // optionally handle or store `_data` if needed
        }

        // Now burn using the burn_ref
        token::burn(burn_ref);
    }
}
