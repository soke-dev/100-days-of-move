module coin::goodcoin {
    use std::signer;
    use std::string;
    use aptos_framework::coin;

    const ENOT_ADMIN: u64 = 0;
    const E_ALREADY_HAS_CAPABILITY: u64 = 1;
    const E_DONT_HAVE_CAPABILITY: u64 = 2;

    struct GoodCoin has key {}

    struct CoinCapabilities has key {
        mint_cap: coin::MintCapability<GoodCoin>,
        burn_cap: coin::BurnCapability<GoodCoin>,
        freeze_cap: coin::FreezeCapability<GoodCoin>
    }

    public fun is_admin(addr: address) {
        assert!(addr == @admin, ENOT_ADMIN);
    }

    public fun have_coin_capabilities(addr: address) {
        assert!(exists<CoinCapabilities>(addr), E_DONT_HAVE_CAPABILITY);
    }

    public fun not_have_coin_capabilities(addr: address) {
        assert!(!exists<CoinCapabilities>(addr), E_ALREADY_HAS_CAPABILITY);
    }

    fun init_module_internal(account: &signer) {
        let account_addr = signer::address_of(account);
        is_admin(account_addr);
        not_have_coin_capabilities(account_addr);

        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<GoodCoin>(
            account,
            string::utf8(b"Good Coin"),
            string::utf8(b"GOOD"),
            8,
            true
        );
        move_to(account, CoinCapabilities {mint_cap, burn_cap, freeze_cap});
    }

    public entry fun initialize(account: &signer) {
        init_module_internal(account);
    }

    public entry fun mint(account: &signer, user: address, amount: u64) acquires CoinCapabilities {
        let account_addr = signer::address_of(account);

        is_admin(account_addr);
        have_coin_capabilities(account_addr);

        let mint_cap = &borrow_global<CoinCapabilities>(account_addr).mint_cap;
        let coins = coin::mint<GoodCoin>(amount, mint_cap);
        coin::deposit<GoodCoin>(user, coins);
    }

    public entry fun register(account: &signer) {
        coin::register<GoodCoin>(account);
    }

    public entry fun burn(account: &signer, amount: u64) acquires CoinCapabilities {
        let coins = coin::withdraw<GoodCoin>(account, amount);
        let burn_cap = &borrow_global<CoinCapabilities>(@admin).burn_cap;
        coin::burn<GoodCoin>(coins, burn_cap);
    }
}
