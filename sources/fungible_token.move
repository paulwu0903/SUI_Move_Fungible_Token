module fungible_token::fungible_token{
    //import library
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap, CoinMetadata};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string;
    use std::ascii;
    

    // one time witness
    struct FUNGIBLE_TOKEN has drop {}

    //init function, first args is one-time-witness(OTW)
    fun init (witness: FUNGIBLE_TOKEN, ctx: &mut TxContext){
        // create new fungible token instance, and set its information.
        // sui::coin will return two object
        // one is TreasuryCap, another is Metadata
        //TreasuryCap is capability, which reprensent someone has access to operate the this fungible tokens.
        //metadata is the static information of this fungible tokens.
        let (treasury_cap, metadata) = coin::create_currency<FUNGIBLE_TOKEN>(
            witness,
            2,
            b"PAULWU",
            b"PW",
            b"",
            option::none(),
            ctx);
        //metadata are opened to all address.
        //public_freeze_object will make object can not modify in future.
        //transfer::public_freeze_object(metadata);
        transfer::public_share_object(metadata);
        // treasuryCap transfer to creating contract address, then this address can have access to operate contract function.
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    }
    
    // mint the fingible tokens.
    public entry fun mint(treasury_cap: &mut TreasuryCap<FUNGIBLE_TOKEN>, amount: u64, recipient: address, ctx: &mut TxContext){
        //call sui framework coin module to mint this fungible token
        //coin <FUNGIBLE_TOKEN> represent tokens we publish.
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }
    
    //burn the fungible tokens.
    public entry fun burn (treasury_cap: &mut TreasuryCap<FUNGIBLE_TOKEN>, coin: Coin<FUNGIBLE_TOKEN>){
        //call sui framework coin module to burn this fungible token
        //coin <FUNGIBLE_TOKEN> represent tokens we publish.
        coin::burn(treasury_cap, coin);

    }
    //join two coin object to one.
    public entry fun join(self: &mut Coin<FUNGIBLE_TOKEN>, coin: Coin<FUNGIBLE_TOKEN>){
        coin::join(self, coin);
    }
    // split one coin object to two 
    public entry fun split (self: &mut Coin<FUNGIBLE_TOKEN>, amount: u64, recipient: address, ctx: &mut TxContext){
        let new_coin_object = coin::split(self, amount, ctx);

        // coin::split is not an rntry function, it has return object type Coin<T>, so in this function need to transfer return object to owner.
        transfer::public_transfer(new_coin_object, recipient);
    }
    // update name
    public entry fun update_name(treasury_cap: &mut TreasuryCap<FUNGIBLE_TOKEN>, metadata: &mut CoinMetadata<FUNGIBLE_TOKEN>, name: string::String){
        coin::update_name(treasury_cap, metadata, name);
    }

    //update_symbol
    public entry fun update_symbol(treasury_cap: &mut TreasuryCap<FUNGIBLE_TOKEN>, metadata: &mut CoinMetadata<FUNGIBLE_TOKEN>, symbol: ascii::String) {
        coin::update_symbol(treasury_cap, metadata, symbol);
    }
    //update_description 
    public entry fun update_description (treasury_cap: &mut TreasuryCap<FUNGIBLE_TOKEN>, metadata: &mut CoinMetadata<FUNGIBLE_TOKEN>, descrption: string::String){
        coin::update_description(treasury_cap, metadata, descrption);
    }
    //update_icon_url
    public entry fun update_icon_url(treasury_cap: &mut TreasuryCap<FUNGIBLE_TOKEN>, metadata: &mut CoinMetadata<FUNGIBLE_TOKEN>, url: ascii::String){
        coin:: update_icon_url(treasury_cap, metadata, url);
    }

}
