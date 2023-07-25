import NonFungibleToken from "./utils/NonFungibleToken.cdc"

pub contract YearBlocks: NonFungibleToken {

  //paths for storing and retrieving nft
  pub let CollectionStoragePath: StoragePath
  pub let CollectionPublicPath: PublicPath
  pub let CollectionPrivatePath: PrivatePath

  //total YearBlocks of this type
  pub var totalSupply: UInt64

  //Emit event on Contract Init
  pub event ContractInitialized()

  pub event Withdraw(id: UInt64, from: Address?)

  pub event Deposit(id: UInt64, to: Address?)

  pub event YearBlockMinted(id: UInt64, name: String)



  pub resource interface CollectionPublic {
    pub fun getIDs(): [UInt64]
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowNFTSafe(id: UInt64): &NonFungibleToken.NFT? {
      post {
        result == nil || result!.id == id: "The returned reference's ID does not match the requested ID"
      }
    }
    pub fun borrowYearBlockNFT(id: UInt64): &NFT? {
      post {
        (result == nil) || (result?.id == id):
          "Cannot borrow NFT reference: the ID of the returned reference is incorrect"
      }
      return nil
    }
  }

 pub resource interface ExtendedINFT {
        pub let id: UInt64 // From NonFungibleToken.INFT
        pub var link: String // New
        pub var allowList: [String] // New
        pub let name: String // New
    }

    pub resource NFT: NonFungibleToken.INFT, ExtendedINFT {
        pub let id: UInt64
        pub var link: String
        pub var allowList: [String]
        pub let name: String

        init(id: UInt64, link: String, allowList: [String], name: String) {
            self.id = id
            self.link = link
            self.allowList = allowList
            self.name = name
        }
    }

    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, CollectionPublic {

        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init() {
            self.ownedNFTs <- {}
        }

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token: @NonFungibleToken.NFT <- token as! @NonFungibleToken.NFT

            let id: UInt64 = token.id

            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            pre {
                self.ownedNFTs.containsKey(id): "No NFT with given id in Collection!"
            }
            return (&self.ownedNFTs[id] as! &NonFungibleToken.NFT?)!
        }

        pub fun borrowNFTSafe(id: UInt64): &NonFungibleToken.NFT? {
            return &self.ownedNFTs[id] as! &NonFungibleToken.NFT?
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    pub fun createEmptyCollection(): @Collection {
        post {
            result.getIDs().length == 0: "The created collection must be empty!"
        }
        return <-create Collection()
    }

    access(all) fun mintNFT(id: UInt64, link: String, allowList: [String], name: String): @NFT {
        self.totalSupply = self.totalSupply + 1
        let nft <- create NFT(id: id, link: link, allowList: allowList, name: name)
        emit YearBlockMinted(id: nft.id, name: name)
        return <-nft
    }

    init() {
        self.totalSupply = 0
         self.CollectionStoragePath = /storage/YearBlocksCollection
    self.CollectionPublicPath = /public/YearBlocksCollectionPublic
    self.CollectionPrivatePath = /private/YearBlocksCollectionPublic
        emit ContractInitialized()
    }
}