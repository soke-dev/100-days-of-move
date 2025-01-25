module mint_nft::create_nft {
    use std::bcs;
    use std::error;
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use aptos_token::token;
    use aptos_token::token::TokenDataId;

    // This struct stores an NFT collection's relevant information
    struct ModuleData has key {
        token_data_id: TokenDataId,
    }

    /// Action not authorized because the signer is not the admin of this module
    const ENOT_AUTHORIZED: u64 = 1;

    /// `init_module` is automatically called when publishing the module.
    /// In this function, we create an example NFT collection and an example token.
    fun init_module(source_account: &signer) {
        let collection_name = string::utf8(b"Good Collection");
        let description = string::utf8(b"Good NFT");
        let collection_uri = string::utf8(b"https://i.postimg.cc/qRCyPS14/Good-PNG-Transparent.png");
        let token_name = string::utf8(b"GOOD NFT");
        let token_uri = string::utf8(b"https://i.postimg.cc/qRCyPS14/Good-PNG-Transparent.png");
        // This means that the supply of the token will not be tracked.
        let maximum_supply = 0;
        // This variable sets if we want to allow mutation for collection description, uri, and maximum.
        // Here, we are setting all of them to false, which means that we don't allow mutations to any CollectionData fields.
        let mutate_setting = vector<bool>[ false, false, false ];

        // Create the nft collection.
        token::create_collection(source_account, collection_name, description, collection_uri, maximum_supply, mutate_setting);

        // Create a token data id to specify the token to be minted.
        let token_data_id = token::create_tokendata(
            source_account,
            collection_name,
            token_name,
            string::utf8(b""),
            0,
            token_uri,
            signer::address_of(source_account),
            1,
            0,
            // This variable sets if we want to allow mutation for token maximum, uri, royalty, description, and properties.
            // Here we enable mutation for properties by setting the last boolean in the vector to true.
            token::create_token_mutability_config(
                &vector<bool>[ false, false, false, false, true ]
            ),
            // We can use property maps to record attributes related to the token.
            // In this example, we are using it to record the receiver's address.
            // We will mutate this field to record the user's address
            // when a user successfully mints a token in the `mint_nft()` function.
            vector<String>[string::utf8(b"given_to")],
            vector<vector<u8>>[b""],
            vector<String>[ string::utf8(b"address") ],
        );

        // Store the token data id within the module, so we can refer to it later
        // when we're minting the NFT and updating its property version.
        move_to(source_account, ModuleData {
            token_data_id,
        });
    }


    public entry fun delayed_mint_event_ticket(module_owner: &signer, receiver: &signer) acquires ModuleData {
        // Assert that the module owner signer is the owner of this module.
        assert!(signer::address_of(module_owner) == @mint_nft, error::permission_denied(ENOT_AUTHORIZED));

        // Mint token to the receiver.
        let module_data = borrow_global_mut<ModuleData>(@mint_nft);
        let token_id = token::mint_token(module_owner, module_data.token_data_id, 1);
        token::direct_transfer(module_owner, receiver, token_id, 1);

        // Mutate the token properties to update the property version of this token.
        // Note that here we are re-using the same token data id and only updating the property version.
        // This is because we are simply printing edition of the same token, instead of creating
        // tokens with unique names and token uris. The tokens created this way will have the same token data id,
        // but different property versions.
        let (creator_address, collection, name) = token::get_token_data_id_fields(&module_data.token_data_id);
        token::mutate_token_properties(
            module_owner,
            signer::address_of(receiver),
            creator_address,
            collection,
            name,
            0,
            1,
            // Mutate the properties to record the receiveer's address.
            vector<String>[string::utf8(b"given_to")],
            vector<vector<u8>>[bcs::to_bytes(&signer::address_of(receiver))],
            vector<String>[ string::utf8(b"address") ],
        );
    }
}