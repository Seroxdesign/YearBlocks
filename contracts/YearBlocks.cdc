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

  pub resource YearBlock: NonFungibleToken.INFT {
    pub let id: UInt64
    access(contract) var link: String
    access(contract) var allowList: [String]
    pub let name: String

    init(id: UInt64, link: String, allowList: [String], name: String) {
      self.id = id
      self.link = link
      self.allowList = allowList
      self.name = name
    }
  }

  pub resource interface CollectionPublic {
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowNFTSafe(id: UInt64): &NonFungibleToken.NFT? {
      post {
        result == nil || result!.id == id: "The returned reference's ID does not match the requested ID"
      }
    }
    pub fun borrowYearBlockNFT(id: UInt64): &YearBlock? {
      post {
        (result == nil) || (result?.id == id):
          "Cannot borrow NFT reference: the ID of the returned reference is incorrect"
      }
      return nil
    }
  }

  pub resource Collection : NonFungibleToken.Receiver, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, CollectionPublic {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    init() {
      self.ownedNFTs <-{}
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

    pub fun borrowYearBlockNFT(id: UInt64): &YearBlock? {
      if self.ownedNFTs[id] != nil {
        // Create an authorized reference to allow downcasting
        let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
        return ref as! &YearBlock
      }
      return nil
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      let token <- token as! @YearBlock

      let id: UInt64 = token.id

      // add the new token to the dictionary which removes the old one
      let oldToken <- self.ownedNFTs[id] <- token

      emit Deposit(id: id, to: self.owner?.address)

      destroy oldToken
    }

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

      emit Withdraw(id: token.id, from: self.owner?.address)

      return <-token
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  pub fun createEmptyCollection(): @NonFungibleToken.Collection {
    return <-create Collection()
  }


  access(all) fun mintNFT(id: UInt64, link: String, allowList: [String], name: String): @YearBlock {
    // Increment total supply
    self.totalSupply = self.totalSupply + 1
    // Create the NFT
    let nft <-create YearBlock(id: id, link: link, allowList: allowList, name: name)
    // Emit an event & return the created NFT
    emit YearBlockMinted(id: nft.id, name: name)
    return <- nft
  }

  init() {
    self.totalSupply = 0

    self.CollectionStoragePath = /storage/YearBlocksCollection
    self.CollectionPublicPath = /public/YearBlocksCollectionPublic
    self.CollectionPrivatePath = /private/YearBlocksCollectionPublic

    let collection <-create Collection()
    collection.deposit(token: <-create YearBlock(id: 1, link: "https://drive.google.com/file/d/1ahYRs7qeKMRgZwXMokaGYR6oOtd4Swdk/view?usp=sharing", allowList: ["student.001@steadystudios.org", "student.002@steadystudios.org", "student.003@steadystudios.org", "student.004@steadystudios.org", "student.005@steadystudios.org", "student.006@steadystudios.org", "student.007@steadystudios.org", "student.008@steadystudios.org" ], name: "Genesis YearBlock"))
    self.account.save(<-collection, to: self.CollectionStoragePath)
    self.account.link<&Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, CollectionPublic}>(self.CollectionPublicPath, target: self.CollectionStoragePath)
    self.account.link<&Collection{NonFungibleToken.Receiver, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, CollectionPublic}>(self.CollectionPrivatePath, target: self.CollectionStoragePath)
    
    emit ContractInitialized()
  }
}