# SUI Fungile Token 的所有基本操作行為

### Step1: 建立專案指令：
```shell=
sui move new fungible_token
```
### Step2: 於Move.toml加入sui依賴。
```yml=
[package]
name = "fungible_token"
version = "0.0.1"

[dependencies]
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "devnet" }

[addresses]
fungible_token = "0x0"
sui = "0x2"
```
### Step3: 建立fungible token合約程式：
```rust=
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


```
### Step4: 部署合約，指令：
```shell=
sui client publish {專案路徑} --gas {付款object Id} --gas-budget 3000000 --skip-fetch-latest-git-deps
```
Ex: 
```shell=
sui client publish ~/Desktop/moveLearning/fungible_token/ --gas 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7 --gas-budget 30000000 --skip-fetch-latest-git-deps
```

執行結果：
```
INCLUDING DEPENDENCY Sui
INCLUDING DEPENDENCY MoveStdlib
BUILDING fungible_token
Successfully verified dependencies on-chain against source.
----- Transaction Digest ----
D9uQ29pEh2m4tng1n4tXFyzQtzD7y2khN11nbWvmZybc
----- Transaction Data ----
Transaction Signature: [Signature(Ed25519SuiSignature(Ed25519SuiSignature([0, 252, 110, 205, 233, 245, 52, 208, 91, 80, 167, 26, 180, 98, 51, 244, 184, 55, 179, 242, 114, 3, 112, 73, 2, 228, 99, 174, 212, 202, 55, 243, 8, 129, 162, 20, 75, 17, 218, 68, 99, 243, 219, 89, 250, 55, 107, 4, 92, 247, 92, 84, 35, 185, 167, 113, 181, 237, 242, 133, 4, 159, 207, 255, 13, 122, 215, 253, 243, 200, 216, 66, 159, 251, 165, 215, 225, 202, 7, 72, 94, 0, 137, 18, 86, 172, 206, 68, 83, 222, 183, 28, 46, 185, 141, 41, 248])))]
Transaction Kind : Programmable
Inputs: [Pure(SuiPureValue { value_type: Some(Address), value: "0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d" })]
Commands: [
  Publish(<modules>,0x0000000000000000000000000000000000000000000000000000000000000001,0x0000000000000000000000000000000000000000000000000000000000000002),
  TransferObjects([Result(0)],Input(0)),
]

Sender: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Payment: Object ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7, version: 0x15ee, digest: H5mH5EXKRo1NjtJfSY1tJ2r4JeY3MS4sZRuwknB7VgzF
Gas Owner: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Price: 1000
Gas Budget: 30000000

----- Transaction Effects ----
Status : Success
Created Objects:
  - ID: 0x4974470ae66dee060b7f89bb9af85f3c21e8ec8db13c8ff82600820759d9c80a , Owner: Immutable
  - ID: 0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b , Owner: Immutable
  - ID: 0xa5316a94740a17ed4f68d538c3a18ed85381f7b377faa20ebd241006d5d1d031 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
  - ID: 0xafb984ab9f846cb7f27ac4ad7a5543d9a687216fb6726afbc921ec32de7a33a5 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
Mutated Objects:
  - ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )

----- Events ----
Array []
----- Object changes ----
Array [
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x2::sui::SUI>"),
        "objectId": String("0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7"),
        "version": String("5615"),
        "previousVersion": String("5614"),
        "digest": String("HgfNhL5TvriyfiaBzJGYspi9TJxq8GykRGHt6GCCMCc3"),
    },
    Object {
        "type": String("created"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": String("Immutable"),
        "objectType": String("0x2::coin::CoinMetadata<0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x4974470ae66dee060b7f89bb9af85f3c21e8ec8db13c8ff82600820759d9c80a"),
        "version": String("5615"),
        "digest": String("nGSFmLSdJqC9AzPFzKueAvqAzcV36Gq8iTPKUeskDKY"),
    },
    Object {
        "type": String("published"),
        "packageId": String("0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b"),
        "version": String("1"),
        "digest": String("Hfx9ntdQ284r25skqKfxSvFs185xdzE338V64nNaiY9w"),
        "modules": Array [
            String("fungible_token"),
        ],
    },
    Object {
        "type": String("created"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::package::UpgradeCap"),
        "objectId": String("0xa5316a94740a17ed4f68d538c3a18ed85381f7b377faa20ebd241006d5d1d031"),
        "version": String("5615"),
        "digest": String("4CaBXNdbyVRTkJjXwstW61Eh55m9n24ruSTXw9UXjmbK"),
    },
    Object {
        "type": String("created"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::TreasuryCap<0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0xafb984ab9f846cb7f27ac4ad7a5543d9a687216fb6726afbc921ec32de7a33a5"),
        "version": String("5615"),
        "digest": String("2VtQCWARnivCnEVDEicLomN6vsPy6WKUTheKUVA3cB1L"),
    },
]
----- Balance changes ----
Array [
    Object {
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "coinType": String("0x2::sui::SUI"),
        "amount": String("-17600680"),
    },
]
```

### Step5: 透過指令執行mint指令：
```shell=
sui client call --package 0x71a1cb5c35d9ceb9fbfe359cc58ee28e1a469a5f545f1bfa9edd66b415cc8d20 --module "fungible_token" --function "mint" --args 0x58e86775c82dafd446420e3759d6a284939582d1ef71cb585c0515c7cf0ae438 500 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d --gas-budget 3000000
```

執行結果：
```
----- Transaction Digest ----
FH3AozYttxg2hvaZ8tmvFzu4ynbp1WfN1uGrTnYQGFks
----- Transaction Data ----
Transaction Signature: [Signature(Ed25519SuiSignature(Ed25519SuiSignature([0, 248, 189, 166, 132, 140, 144, 175, 9, 179, 12, 95, 58, 58, 117, 7, 117, 154, 228, 28, 234, 178, 151, 100, 149, 89, 93, 87, 242, 168, 165, 192, 124, 193, 71, 174, 191, 95, 51, 224, 99, 58, 4, 30, 14, 224, 44, 185, 210, 124, 223, 231, 62, 242, 118, 198, 133, 181, 30, 246, 103, 226, 198, 90, 9, 122, 215, 253, 243, 200, 216, 66, 159, 251, 165, 215, 225, 202, 7, 72, 94, 0, 137, 18, 86, 172, 206, 68, 83, 222, 183, 28, 46, 185, 141, 41, 248])))]
Transaction Kind : Programmable
Inputs: [Object(ImmOrOwnedObject { object_id: 0xafb984ab9f846cb7f27ac4ad7a5543d9a687216fb6726afbc921ec32de7a33a5, version: SequenceNumber(5616), digest: o#9F8hHj8CKLieNE8X8JGQvdYZeDVcNhjKUodwaebNkA8d }), Pure(SuiPureValue { value_type: Some(U64), value: "10000" }), Pure(SuiPureValue { value_type: Some(Address), value: "0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d" })]
Commands: [
  MoveCall(0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::mint(Input(0),Input(1),Input(2))),
]

Sender: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Payment: Object ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7, version: 0x15f0, digest: 5tbaynxzxphZk5dkKeqRwXNcFDkxPpavqhVox2H6gUFE
Gas Owner: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Price: 1000
Gas Budget: 3000000

----- Transaction Effects ----
Status : Success
Created Objects:
  - ID: 0x2e194037263ae64ef389f3eb75f0fd0f3f8a144c79534ac90071d28179d73b8c , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
Mutated Objects:
  - ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
  - ID: 0xafb984ab9f846cb7f27ac4ad7a5543d9a687216fb6726afbc921ec32de7a33a5 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )

----- Events ----
Array []
----- Object changes ----
Array [
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x2::sui::SUI>"),
        "objectId": String("0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7"),
        "version": String("5617"),
        "previousVersion": String("5616"),
        "digest": String("ADsaXetnjh5Ud2Dx5rJtSP5xUNx5vFuVFkMazDeEdNnN"),
    },
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::TreasuryCap<0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0xafb984ab9f846cb7f27ac4ad7a5543d9a687216fb6726afbc921ec32de7a33a5"),
        "version": String("5617"),
        "previousVersion": String("5616"),
        "digest": String("Cz1ccxexymXHTH4XEhT9fuD8mnBtCqqRh119Q6VnGSzG"),
    },
    Object {
        "type": String("created"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x2e194037263ae64ef389f3eb75f0fd0f3f8a144c79534ac90071d28179d73b8c"),
        "version": String("5617"),
        "digest": String("AomxGbimYuFNL2Eek7ksEnzHgZ25f6YotEurArCkCWdi"),
    },
]
----- Balance changes ----
Array [
    Object {
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "coinType": String("0x2::sui::SUI"),
        "amount": String("-2502824"),
    },
    Object {
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "coinType": String("0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::FUNGIBLE_TOKEN"),
        "amount": String("10000"),
    },
]
```
SUI Explorer畫面：

![](https://hackmd.io/_uploads/B1-JNwkI3.png)


### Step6: 執行split，將100顆幣拆出2顆，最終變成2個object，一個是原本的100顆，他會變成98顆，另一個object會被生成，並存放2顆剛剛拆出來的幣：
```shell=
sui client call --package 0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b --module "fungible_token" --function "split" --args 0x2e194037263ae64ef389f3eb75f0fd0f3f8a144c79534ac90071d28179d73b8c 200 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d --gas-budget 3000000
```

執行結果：
```
----- Transaction Digest ----
6CNwjNMQrYMobXQ3rw7TrzHMdJuEgioWiMeo9az3ccMe
----- Transaction Data ----
Transaction Signature: [Signature(Ed25519SuiSignature(Ed25519SuiSignature([0, 218, 111, 151, 189, 241, 177, 236, 225, 247, 235, 121, 124, 88, 141, 97, 247, 176, 163, 236, 85, 160, 186, 172, 31, 178, 84, 28, 149, 86, 48, 150, 101, 22, 137, 39, 3, 4, 137, 186, 160, 28, 85, 63, 92, 5, 97, 136, 191, 156, 32, 141, 16, 247, 81, 109, 119, 36, 138, 1, 17, 135, 180, 34, 11, 122, 215, 253, 243, 200, 216, 66, 159, 251, 165, 215, 225, 202, 7, 72, 94, 0, 137, 18, 86, 172, 206, 68, 83, 222, 183, 28, 46, 185, 141, 41, 248])))]
Transaction Kind : Programmable
Inputs: [Object(ImmOrOwnedObject { object_id: 0x2e194037263ae64ef389f3eb75f0fd0f3f8a144c79534ac90071d28179d73b8c, version: SequenceNumber(5617), digest: o#AomxGbimYuFNL2Eek7ksEnzHgZ25f6YotEurArCkCWdi }), Pure(SuiPureValue { value_type: Some(U64), value: "200" }), Pure(SuiPureValue { value_type: Some(Address), value: "0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d" })]
Commands: [
  MoveCall(0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::split(Input(0),Input(1),Input(2))),
]

Sender: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Payment: Object ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7, version: 0x15f1, digest: ADsaXetnjh5Ud2Dx5rJtSP5xUNx5vFuVFkMazDeEdNnN
Gas Owner: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Price: 1000
Gas Budget: 3000000

----- Transaction Effects ----
Status : Success
Created Objects:
  - ID: 0x1f4fd8ce2126ebb5b193c17b6b1f92ee346932ccec5d20341f20ff9a1fe8f35e , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
Mutated Objects:
  - ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
  - ID: 0x2e194037263ae64ef389f3eb75f0fd0f3f8a144c79534ac90071d28179d73b8c , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )

----- Events ----
Array []
----- Object changes ----
Array [
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x2::sui::SUI>"),
        "objectId": String("0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7"),
        "version": String("5618"),
        "previousVersion": String("5617"),
        "digest": String("HP1TqJTy3yNtrteKeE2Pc14B6dcUCs9NQhg7NQ2zUEMM"),
    },
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x2e194037263ae64ef389f3eb75f0fd0f3f8a144c79534ac90071d28179d73b8c"),
        "version": String("5618"),
        "previousVersion": String("5617"),
        "digest": String("7t9TLDhiRuhRScvqXCuc3zWVXZuW8dHaEGUpqJBi1N77"),
    },
    Object {
        "type": String("created"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x1f4fd8ce2126ebb5b193c17b6b1f92ee346932ccec5d20341f20ff9a1fe8f35e"),
        "version": String("5618"),
        "digest": String("9ZKn9Wt33hTwj9EYcRhWHu1H1DjtPuYqwSf5fHG3Q3Fb"),
    },
]
----- Balance changes ----
Array [
    Object {
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "coinType": String("0x2::sui::SUI"),
        "amount": String("-2499024"),
    },
]
```

SUI Explorer畫面：

![](https://hackmd.io/_uploads/rkjANwkI2.png)

重複執行5次：

![](https://hackmd.io/_uploads/Hk3QrvyL3.png)

### Step7: 執行join，將剛剛拆出來的2個object合併成1個object：
```shell=
sui client call --package 0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b --module "fungible_token" --function "join" --args 0x220a96f1b7c3f9206e7b85eab14294f5d92aaeaaa723aa01990b2a15aefbec75 0x1f4fd8ce2126ebb5b193c17b6b1f92ee346932ccec5d20341f20ff9a1fe8f35e --gas-budget 3000000
```
* 執行結果：
```
----- Transaction Digest ----
7UfgJfNmxCbVMy199BbZ4ZdhQ8BEy1W5Wq9QkFWARvXM
----- Transaction Data ----
Transaction Signature: [Signature(Ed25519SuiSignature(Ed25519SuiSignature([0, 224, 160, 58, 22, 169, 173, 226, 13, 165, 176, 68, 61, 45, 196, 35, 77, 204, 104, 73, 29, 233, 85, 14, 26, 141, 247, 200, 75, 134, 71, 142, 18, 146, 156, 135, 159, 95, 161, 77, 133, 147, 227, 47, 188, 103, 13, 159, 177, 172, 206, 1, 51, 177, 8, 73, 110, 179, 202, 203, 101, 15, 130, 71, 4, 122, 215, 253, 243, 200, 216, 66, 159, 251, 165, 215, 225, 202, 7, 72, 94, 0, 137, 18, 86, 172, 206, 68, 83, 222, 183, 28, 46, 185, 141, 41, 248])))]
Transaction Kind : Programmable
Inputs: [Object(ImmOrOwnedObject { object_id: 0x220a96f1b7c3f9206e7b85eab14294f5d92aaeaaa723aa01990b2a15aefbec75, version: SequenceNumber(5622), digest: o#JAdYbRsoNXub3YKPWgZyNum2dpMm5HJtN5oJLMiY2yjt }), Object(ImmOrOwnedObject { object_id: 0x1f4fd8ce2126ebb5b193c17b6b1f92ee346932ccec5d20341f20ff9a1fe8f35e, version: SequenceNumber(5618), digest: o#9ZKn9Wt33hTwj9EYcRhWHu1H1DjtPuYqwSf5fHG3Q3Fb })]
Commands: [
  MoveCall(0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::join(Input(0),Input(1))),
]

Sender: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Payment: Object ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7, version: 0x15f6, digest: 5AXacZghsyjzfXkWNVaQwV8UHNJfDpzY5m2TTh1yEcPk
Gas Owner: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Price: 1000
Gas Budget: 3000000

----- Transaction Effects ----
Status : Success
Mutated Objects:
  - ID: 0x220a96f1b7c3f9206e7b85eab14294f5d92aaeaaa723aa01990b2a15aefbec75 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
  - ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
Deleted Objects:
  - ID: 0x1f4fd8ce2126ebb5b193c17b6b1f92ee346932ccec5d20341f20ff9a1fe8f35e

----- Events ----
Array []
----- Object changes ----
Array [
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x220a96f1b7c3f9206e7b85eab14294f5d92aaeaaa723aa01990b2a15aefbec75"),
        "version": String("5623"),
        "previousVersion": String("5622"),
        "digest": String("FFaF7xpQhUFCfNjVknAKXvsNvyTe9PH6SFgNcwt29CCc"),
    },
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x2::sui::SUI>"),
        "objectId": String("0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7"),
        "version": String("5623"),
        "previousVersion": String("5622"),
        "digest": String("FHXRYSajNxdjKQfsRZvrswPdiEoES2FQA4DQxv6KtFRP"),
    },
]
----- Balance changes ----
Array [
    Object {
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "coinType": String("0x2::sui::SUI"),
        "amount": String("435032"),
    },
]
```
* SUI Explorer:

![](https://hackmd.io/_uploads/BkAiwwkU3.png)

### Step8: 執行burn，燃燒剛剛合併為4顆代幣的object。
```shell=
sui client call --package 0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b --module "fungible_token" --function "burn" --args 0xafb984ab9f846cb7f27ac4ad7a5543d9a687216fb6726afbc921ec32de7a33a5 0x220a96f1b7c3f9206e7b85eab14294f5d92aaeaaa723aa01990b2a15aefbec75 --gas-budget 3000000
```
* 執行結果：
```
----- Transaction Digest ----
7pVRLdmAjB1cKytzAcfqdaf4mWGd51Z1dgX3ixs1dW7q
----- Transaction Data ----
Transaction Signature: [Signature(Ed25519SuiSignature(Ed25519SuiSignature([0, 68, 32, 183, 93, 223, 235, 179, 186, 98, 136, 251, 40, 49, 40, 214, 64, 131, 203, 143, 92, 132, 95, 214, 150, 42, 176, 85, 46, 68, 79, 111, 181, 34, 80, 188, 23, 31, 217, 196, 142, 167, 218, 157, 120, 2, 182, 22, 166, 180, 134, 15, 166, 76, 15, 55, 70, 174, 73, 140, 44, 21, 182, 254, 13, 122, 215, 253, 243, 200, 216, 66, 159, 251, 165, 215, 225, 202, 7, 72, 94, 0, 137, 18, 86, 172, 206, 68, 83, 222, 183, 28, 46, 185, 141, 41, 248])))]
Transaction Kind : Programmable
Inputs: [Object(ImmOrOwnedObject { object_id: 0xafb984ab9f846cb7f27ac4ad7a5543d9a687216fb6726afbc921ec32de7a33a5, version: SequenceNumber(5617), digest: o#Cz1ccxexymXHTH4XEhT9fuD8mnBtCqqRh119Q6VnGSzG }), Object(ImmOrOwnedObject { object_id: 0x220a96f1b7c3f9206e7b85eab14294f5d92aaeaaa723aa01990b2a15aefbec75, version: SequenceNumber(5623), digest: o#FFaF7xpQhUFCfNjVknAKXvsNvyTe9PH6SFgNcwt29CCc })]
Commands: [
  MoveCall(0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::burn(Input(0),Input(1))),
]

Sender: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Payment: Object ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7, version: 0x15f7, digest: FHXRYSajNxdjKQfsRZvrswPdiEoES2FQA4DQxv6KtFRP
Gas Owner: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Price: 1000
Gas Budget: 3000000

----- Transaction Effects ----
Status : Success
Mutated Objects:
  - ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
  - ID: 0xafb984ab9f846cb7f27ac4ad7a5543d9a687216fb6726afbc921ec32de7a33a5 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
Deleted Objects:
  - ID: 0x220a96f1b7c3f9206e7b85eab14294f5d92aaeaaa723aa01990b2a15aefbec75

----- Events ----
Array []
----- Object changes ----
Array [
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x2::sui::SUI>"),
        "objectId": String("0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7"),
        "version": String("5624"),
        "previousVersion": String("5623"),
        "digest": String("Aab96bdgB9JD5zR6c8iH4vnnL2xSr921d7qskPFMtzxR"),
    },
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::TreasuryCap<0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0xafb984ab9f846cb7f27ac4ad7a5543d9a687216fb6726afbc921ec32de7a33a5"),
        "version": String("5624"),
        "previousVersion": String("5617"),
        "digest": String("7AhC6gKhxf9gCMdVVcdPvHQKmLeW2GHcmM5zDbu4Cr8e"),
    },
]
----- Balance changes ----
Array [
    Object {
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "coinType": String("0x2::sui::SUI"),
        "amount": String("431232"),
    },
    Object {
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "coinType": String("0x82f11088bc209ebcf5876ea0556ac8f26b95ed6cf0a83a55e6c8c7d88f48134b::fungible_token::FUNGIBLE_TOKEN"),
        "amount": String("-400"),
    },
]
```

* SUI Explorer: 

![](https://hackmd.io/_uploads/rk8ouwyIh.png)


### Step9: 執行update_name，更改幣名。

```shell=
sui client call --package 0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0 --module "fungible_token" --function "update_name" --args 0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92 0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524 "UPAULWU" --gas-budget 3000000
```

* 執行結果：
```
----- Transaction Digest ----
2t5kCodHwHmMD4W4TnVBMpsfPKZJMJYwG7oedprLYXCp
----- Transaction Data ----
Transaction Signature: [Signature(Ed25519SuiSignature(Ed25519SuiSignature([0, 76, 181, 231, 82, 216, 193, 97, 250, 204, 55, 195, 88, 98, 176, 14, 32, 171, 234, 107, 205, 231, 233, 212, 183, 5, 193, 196, 72, 54, 110, 32, 91, 94, 131, 151, 246, 244, 82, 236, 244, 103, 125, 195, 50, 42, 31, 220, 27, 42, 20, 103, 53, 61, 81, 176, 21, 25, 171, 237, 172, 154, 97, 25, 4, 122, 215, 253, 243, 200, 216, 66, 159, 251, 165, 215, 225, 202, 7, 72, 94, 0, 137, 18, 86, 172, 206, 68, 83, 222, 183, 28, 46, 185, 141, 41, 248])))]
Transaction Kind : Programmable
Inputs: [Object(ImmOrOwnedObject { object_id: 0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92, version: SequenceNumber(5638), digest: o#CQXoVeVhvYcn7FGns6qm7VNhAS5KceaiS91UDi51GV4a }), Object(SharedObject { object_id: 0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524, initial_shared_version: SequenceNumber(5635), mutable: true }), Pure(SuiPureValue { value_type: Some(Struct(StructTag { address: 0000000000000000000000000000000000000000000000000000000000000001, module: Identifier("string"), name: Identifier("String"), type_params: [] })), value: "UPAULWU" })]
Commands: [
  MoveCall(0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0::fungible_token::update_name(Input(0),Input(1),Input(2))),
]

Sender: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Payment: Object ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7, version: 0x1606, digest: AwqcWjQcutDUxem5TG4kJhNUz4E8WzmSUVD8jjbEPdGY
Gas Owner: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Price: 1000
Gas Budget: 3000000

----- Transaction Effects ----
Status : Success
Mutated Objects:
  - ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
  - ID: 0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524 , Owner: Shared
  - ID: 0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )

----- Events ----
Array []
----- Object changes ----
Array [
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x2::sui::SUI>"),
        "objectId": String("0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7"),
        "version": String("5639"),
        "previousVersion": String("5638"),
        "digest": String("8jjx3RYFpb2XyyNsavDqzbo4dz71KYaq1m2f2VThyRbF"),
    },
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "Shared": Object {
                "initial_shared_version": Number(5635),
            },
        },
        "objectType": String("0x2::coin::CoinMetadata<0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524"),
        "version": String("5639"),
        "previousVersion": String("5638"),
        "digest": String("9sT3XZM67V9W3RMVe1iDwVuXBW2ffTcTMGejJivRSAGS"),
    },
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::TreasuryCap<0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92"),
        "version": String("5639"),
        "previousVersion": String("5638"),
        "digest": String("GSmheYjwP36gs7L39YRLy3rb9YEEtKgLLZzLiAhNZ821"),
    },
]
----- Balance changes ----
Array [
    Object {
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "coinType": String("0x2::sui::SUI"),
        "amount": String("-1085424"),
    },
]
```

* SUI Explorer:

![](https://hackmd.io/_uploads/ry1Q52yU2.png)

### Step10: 執行update_symbol，更改symbol。
```shell=
sui client call --package 0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0 --module "fungible_token" --function "update_symbol" --args 0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92 0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524 "UPW" --gas-budget 3000000
```

* 執行結果：
```
----- Transaction Digest ----
8zP5jkq8Li7dZuDdxeRdG1joFVTUDiARUr9MeUARwUs8
----- Transaction Data ----
Transaction Signature: [Signature(Ed25519SuiSignature(Ed25519SuiSignature([0, 150, 138, 26, 88, 222, 84, 65, 132, 15, 44, 234, 80, 55, 119, 202, 73, 173, 71, 33, 208, 248, 185, 122, 241, 205, 50, 31, 247, 136, 126, 223, 163, 56, 89, 137, 216, 195, 147, 222, 202, 107, 10, 13, 227, 93, 162, 201, 77, 81, 194, 47, 222, 178, 77, 67, 201, 96, 85, 116, 31, 173, 215, 197, 6, 122, 215, 253, 243, 200, 216, 66, 159, 251, 165, 215, 225, 202, 7, 72, 94, 0, 137, 18, 86, 172, 206, 68, 83, 222, 183, 28, 46, 185, 141, 41, 248])))]
Transaction Kind : Programmable
Inputs: [Object(ImmOrOwnedObject { object_id: 0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92, version: SequenceNumber(5639), digest: o#GSmheYjwP36gs7L39YRLy3rb9YEEtKgLLZzLiAhNZ821 }), Object(SharedObject { object_id: 0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524, initial_shared_version: SequenceNumber(5635), mutable: true }), Pure(SuiPureValue { value_type: Some(Struct(StructTag { address: 0000000000000000000000000000000000000000000000000000000000000001, module: Identifier("ascii"), name: Identifier("String"), type_params: [] })), value: "UPW" })]
Commands: [
  MoveCall(0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0::fungible_token::update_symbol(Input(0),Input(1),Input(2))),
]

Sender: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Payment: Object ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7, version: 0x1607, digest: 8jjx3RYFpb2XyyNsavDqzbo4dz71KYaq1m2f2VThyRbF
Gas Owner: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Price: 1000
Gas Budget: 3000000

----- Transaction Effects ----
Status : Success
Mutated Objects:
  - ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
  - ID: 0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524 , Owner: Shared
  - ID: 0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )

----- Events ----
Array []
----- Object changes ----
Array [
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x2::sui::SUI>"),
        "objectId": String("0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7"),
        "version": String("5640"),
        "previousVersion": String("5639"),
        "digest": String("5CXmSdWGfF59E3gZQBmc9acqrfxcfwKyYDGzvNQkpBre"),
    },
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "Shared": Object {
                "initial_shared_version": Number(5635),
            },
        },
        "objectType": String("0x2::coin::CoinMetadata<0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524"),
        "version": String("5640"),
        "previousVersion": String("5639"),
        "digest": String("Ha9MMLvAtPvnd8tD6YBwZ9NJRr6hVaeRasy9q72ofMAV"),
    },
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::TreasuryCap<0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92"),
        "version": String("5640"),
        "previousVersion": String("5639"),
        "digest": String("6fAZ5ovD4JoWgiAPFsrfGfxdB5tGDCXgvarheiqotSM9"),
    },
]
----- Balance changes ----
Array [
    Object {
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "coinType": String("0x2::sui::SUI"),
        "amount": String("-1025004"),
    },
]
```
* SUI Explorer: 

![](https://hackmd.io/_uploads/r15Wshk82.png)

![](https://hackmd.io/_uploads/Hyvro3kL3.png)

### Step11: 執行update_description，更新描述
```shell=
sui client call --package 0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0 --module "fungible_token" --function "update_description" --args 0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92 0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524 "Updated Paul Token" --gas-budget 3000000
```

* 執行結果：
```
----- Transaction Digest ----
6rWDX4bj3Y7SkC1PtJv21TvUKNRCrn6UW6RrWmU31qLZ
----- Transaction Data ----
Transaction Signature: [Signature(Ed25519SuiSignature(Ed25519SuiSignature([0, 12, 30, 247, 83, 138, 254, 51, 184, 0, 134, 102, 166, 199, 205, 14, 233, 134, 96, 164, 41, 54, 18, 33, 231, 78, 64, 80, 198, 211, 120, 205, 56, 0, 99, 187, 173, 92, 110, 229, 12, 177, 46, 163, 242, 40, 39, 170, 105, 220, 175, 71, 26, 95, 211, 88, 118, 136, 169, 226, 207, 10, 186, 86, 5, 122, 215, 253, 243, 200, 216, 66, 159, 251, 165, 215, 225, 202, 7, 72, 94, 0, 137, 18, 86, 172, 206, 68, 83, 222, 183, 28, 46, 185, 141, 41, 248])))]
Transaction Kind : Programmable
Inputs: [Object(ImmOrOwnedObject { object_id: 0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92, version: SequenceNumber(5641), digest: o#HyEUCutFLJkfWQHxZZvcj42CE1wQVGTrKNT225h4Leug }), Object(SharedObject { object_id: 0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524, initial_shared_version: SequenceNumber(5635), mutable: true }), Pure(SuiPureValue { value_type: Some(Struct(StructTag { address: 0000000000000000000000000000000000000000000000000000000000000001, module: Identifier("string"), name: Identifier("String"), type_params: [] })), value: "Updated Paul Token" })]
Commands: [
  MoveCall(0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0::fungible_token::update_description(Input(0),Input(1),Input(2))),
]

Sender: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Payment: Object ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7, version: 0x1609, digest: 4Cai7LSCWS1qbaUqoJ9fVZNGgKbVHfnW9Vo1zBcYoMaG
Gas Owner: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Price: 1000
Gas Budget: 3000000

----- Transaction Effects ----
Status : Success
Mutated Objects:
  - ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
  - ID: 0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524 , Owner: Shared
  - ID: 0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )

----- Events ----
Array []
----- Object changes ----
Array [
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x2::sui::SUI>"),
        "objectId": String("0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7"),
        "version": String("5642"),
        "previousVersion": String("5641"),
        "digest": String("8UXtfrByGDWUYL3Z6CniKNq5ce93CgF3TjXqTDqaf7Vv"),
    },
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "Shared": Object {
                "initial_shared_version": Number(5635),
            },
        },
        "objectType": String("0x2::coin::CoinMetadata<0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524"),
        "version": String("5642"),
        "previousVersion": String("5641"),
        "digest": String("5ZxX3EvddVUXbCthqGo8DjpiUb1D5vu9BbJ9bU6vwqh4"),
    },
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::TreasuryCap<0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92"),
        "version": String("5642"),
        "previousVersion": String("5641"),
        "digest": String("CF2ooKaVvZYMeiAJyCJiKTXkx5c2dVWeBkTiir3D2TDA"),
    },
]
----- Balance changes ----
Array [
    Object {
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "coinType": String("0x2::sui::SUI"),
        "amount": String("-1161804"),
    },
]
```

* SUI Explorer:

![](https://hackmd.io/_uploads/BkEJn2yIn.png)

### Step12: 執行update_icon_url，更新表示代幣的圖示。
```shell=
sui client call --package 0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0 --module "fungible_token" --function "update_icon_url" --args 0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92 0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524 "https://hackmd.io/_uploads/HJvu2hkI3.png" --gas-budget 3000000
```

* 執行結果：
```
----- Transaction Digest ----
6GvRTV7Cb33Xob2xt6HV6Du7re8hV7hC6YnQtowXXA4F
----- Transaction Data ----
Transaction Signature: [Signature(Ed25519SuiSignature(Ed25519SuiSignature([0, 184, 105, 125, 81, 186, 120, 44, 192, 224, 249, 124, 173, 36, 211, 10, 106, 249, 89, 125, 96, 21, 118, 105, 0, 64, 239, 36, 43, 159, 171, 22, 45, 126, 249, 197, 251, 171, 130, 168, 65, 85, 88, 241, 127, 232, 97, 48, 54, 166, 157, 42, 203, 24, 53, 215, 95, 157, 95, 241, 219, 252, 49, 107, 2, 122, 215, 253, 243, 200, 216, 66, 159, 251, 165, 215, 225, 202, 7, 72, 94, 0, 137, 18, 86, 172, 206, 68, 83, 222, 183, 28, 46, 185, 141, 41, 248])))]
Transaction Kind : Programmable
Inputs: [Object(ImmOrOwnedObject { object_id: 0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92, version: SequenceNumber(5642), digest: o#CF2ooKaVvZYMeiAJyCJiKTXkx5c2dVWeBkTiir3D2TDA }), Object(SharedObject { object_id: 0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524, initial_shared_version: SequenceNumber(5635), mutable: true }), Pure(SuiPureValue { value_type: Some(Struct(StructTag { address: 0000000000000000000000000000000000000000000000000000000000000001, module: Identifier("ascii"), name: Identifier("String"), type_params: [] })), value: "https://hackmd.io/_uploads/HJvu2hkI3.png" })]
Commands: [
  MoveCall(0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0::fungible_token::update_icon_url(Input(0),Input(1),Input(2))),
]

Sender: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Payment: Object ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7, version: 0x160a, digest: 8UXtfrByGDWUYL3Z6CniKNq5ce93CgF3TjXqTDqaf7Vv
Gas Owner: 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d
Gas Price: 1000
Gas Budget: 3000000

----- Transaction Effects ----
Status : Success
Mutated Objects:
  - ID: 0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )
  - ID: 0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524 , Owner: Shared
  - ID: 0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92 , Owner: Account Address ( 0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d )

----- Events ----
Array []
----- Object changes ----
Array [
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::Coin<0x2::sui::SUI>"),
        "objectId": String("0x2ace08422be2206ca40f01c726a28c192b1c8f62c14a1c5fd92a1bb5e1dda5d7"),
        "version": String("5643"),
        "previousVersion": String("5642"),
        "digest": String("7JkAkgtVZXaLhgB18KBVRNFJskEjNUcnWhXEEgHN6gB6"),
    },
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "Shared": Object {
                "initial_shared_version": Number(5635),
            },
        },
        "objectType": String("0x2::coin::CoinMetadata<0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x537be0440e4cc8276d24d6ca1c573c72984f73616cb3ba63cd973efc0e21f524"),
        "version": String("5643"),
        "previousVersion": String("5642"),
        "digest": String("5oadU3ktbLuBJUYQ8eSfPQpJ6cZMmDeMnccAhbmRfiFK"),
    },
    Object {
        "type": String("mutated"),
        "sender": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "objectType": String("0x2::coin::TreasuryCap<0xdca58a672c11ab5a2d8118577003f4563c0bd3e2d67ed5be74e41186368901b0::fungible_token::FUNGIBLE_TOKEN>"),
        "objectId": String("0x7cea9b8495e1009067eb0a81b7c768908b30ff1df02ede2a8d5b437170f1bc92"),
        "version": String("5643"),
        "previousVersion": String("5642"),
        "digest": String("6KypQgXeVexH4HEjuWU74uDngdKy9LcHcaCSi2m59zEi"),
    },
]
----- Balance changes ----
Array [
    Object {
        "owner": Object {
            "AddressOwner": String("0xef32396006366e438353131f58c750c135e963efef0303c42d89e9961e722f4d"),
        },
        "coinType": String("0x2::sui::SUI"),
        "amount": String("-1360544"),
    },
]
```

* SUI Explorer: 

![](https://hackmd.io/_uploads/rkJO6n18n.png)
