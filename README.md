## YearBlocks Smart Contract Documentation Overview

The YearBlocks smart contract enables the minting and management of YearBlock NFTs. A YearBlock NFT serves as a resource for educational institutions like schools or universities to host their yearbooks on the Flow blockchain. Users, in conjunction with the Signatures contract, can sign these yearblocks.
Contract Structure

The YearBlocks smart contract extends NonFungibleToken and contains several essential components:

    Paths for NFT Storage:
        CollectionStoragePath: Storage path for NFTs.
        CollectionPublicPath: Public path for NFTs.
        CollectionPrivatePath: Private path for NFTs.

    Variables:
        totalSupply: Total number of YearBlock NFTs of this type.

    Events:
        ContractInitialized: Signals the initialization of the contract.
        Withdraw: Indicates a withdrawal of an NFT.
        Deposit: Signals a deposit of an NFT.
        YearBlockMinted: Notifies when a YearBlock NFT is minted.

    Interfaces:
        CollectionPublic: Defines an interface for public access to collections.
        ExtendedINFT: Extends the INFT interface and includes additional properties specific to YearBlock NFTs.

    Resources:
        NFT: Defines the structure and behavior of a YearBlock NFT.
        Collection: Manages the collection of NFTs.

    Functions:
        createEmptyCollection: Creates an empty collection of NFTs.
        mintNFT: Mints a new YearBlock NFT.

### YearBlock NFTs

YearBlock NFTs are instances of the NFT resource. They possess various properties, including:

    id: Unique identifier for the NFT.
    link: URL or link associated with the yearblock.
    allowList: List of allowed entities.
    name: Name of the yearblock.
    thumbnail: Thumbnail image or representation.
    description: Description of the yearblock.
    districtName: Name of the educational district.
    schoolName: Name of the educational institution (school or university).
    schoolYear: Academic year.

YearBlock NFTs can be minted using the mintNFT function, providing the necessary information for initialization.
Collection Management

The Collection resource manages the collection of NFTs and provides functions to interact with them. These functions include:

    deposit: Adds a new NFT to the collection.
    withdraw: Removes an NFT from the collection.
    getIDs: Returns all NFT IDs in the collection.
    borrowNFT: Retrieves a reference to a specific NFT by its ID.
    borrowYearBlockNFT: Retrieves a reference to a YearBlock NFT by its ID.
    borrowNFTSafe: Retrieves a reference to an NFT by its ID safely.

### Usage

To utilize the smart contract effectively, follow these steps:

    Initialize the contract using the init function.
    Mint new YearBlock NFTs using the mintNFT function.
    Manage the collection of NFTs using the Collection resource functions.

------------------------------------------------------------------------------------

## Signatures Smart Contract Documentation Overview

The Signatures smart contract is designed to manage the minting and association of Signature NFTs. It allows users to mint Signature NFTs and subsequently attach them to YearBlock NFTs.
Contract Structure

### The Signatures smart contract extends NonFungibleToken and contains several essential components:

    Events:
        ContractInitialized: Signals the initialization of the contract.
        SignatureMinted: Indicates the minting of a new Signature NFT.
        SignatureAddedToYearBlock: Notifies when a Signature NFT is added to a YearBlock NFT.
        removeSignatureFromYearBlock: Notifies when a Signature NFT is removed from a YearBlock NFT.
        Withdraw: Indicates a withdrawal of an NFT.
        Deposit: Signals a deposit of an NFT.

    Interfaces:
        ExtendedINFT: Extends the INFT interface and adds properties specific to Signature NFTs.

    Resources:
        NFT: Defines the structure and behavior of a Signature NFT.
        SignatureAttachment: Enables attachment of Signature NFTs to YearBlock NFTs.
        CollectionPublic: Defines an interface for public access to collections.
        Collection: Manages the collection of NFTs.

    Functions:
        createEmptyCollection: Creates an empty collection of NFTs.
        mintNFT: Mints a new Signature NFT.

### Signature NFTs

Signature NFTs are instances of the NFT resource. They have the following properties:

    id: Unique identifier for the NFT.
    digiComment: A comment associated with the signature.
    digiSig: Image or signature data.
    digiName: Name associated with the signature.

Signature NFTs can be minted using the mintNFT function, which initializes a new NFT with the provided comment, image, and name.
Collection Management

The Collection resource manages the collection of NFTs and provides functions to interact with them. It includes functions to deposit, withdraw, and attach Signature NFTs to YearBlock NFTs.

    getIDs: Returns all NFT IDs in the collection.
    borrowNFT: Retrieves a reference to a specific NFT by its ID.
    deposit: Adds a new NFT to the collection.
    withdraw: Removes an NFT from the collection.
    attachSignatureToYearBlock: Attaches a Signature NFT to a YearBlock NFT.
    removeSignatureFromYearBlock: Removes a Signature NFT from a YearBlock NFT.

### Usage

To use the smart contract, follow these steps:

    Initialize the contract using the init function.
    Mint new Signature NFTs using the mintNFT function.
    Manage the collection of NFTs using the Collection resource functions.
    Attach Signature NFTs to YearBlock NFTs using the attachSignatureToYearBlock function.
    Remove Signature NFTs from YearBlock NFTs using the removeSignatureFromYearBlock function.

----------------------------------------------------------------------------------

## Account Creator Smart Contract Documentation Overview

The Account Creator smart contract provides the functionality to create wallets/accounts for users in the background. It also funds these accounts with an initial amount to allow users to mint yearblocks and signatures without having to manually create accounts.
Contract Structure

The AccountCreator smart contract imports the FungibleToken and FlowToken contracts. It defines various components to manage account creation and funding, including:

    Paths for Storage:
        CreatorStoragePath: Storage path for account creator.
        CreatorPublicPath: Public path for account creator.

    Events:
        AccountCreated: Notifies when a new account is created.

    Interfaces:
        CreatorPublic: Defines an interface for public access to account creation.

    Resources:
        Creator: Manages account creation and maintains a mapping of public keys to addresses.

    Functions:
        createNewAccount: Creates a new account and funds it with an initial amount of Flow.
        isKeyActiveOnAccount: Determines if a public key is active on an account.
        createNewCreator: Creates a new account creator.

### Account Creation and Funding

The createNewAccount function creates a new account, funds it with Flow, and associates a public key with the account. It takes the signer account, initial funding amount, and originating public key as parameters.
Usage

To use the smart contract effectively, follow these steps:

    Initialize the contract using the init function.
    Create a new account creator using the createNewCreator function.
    Create new accounts and fund them using the createNewAccount function.

### Note

This smart contract is primarily intended for prototyping and is in Beta, thus it may not be suitable for production environments due to certain limitations and anti-patterns.
