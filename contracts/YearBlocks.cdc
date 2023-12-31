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
        pub var thumbnail: String
        pub var allowList: [String] // New
        pub let name: String // New
        pub let description: String
        pub var districtName: String
        pub var schoolName: String
        pub var schoolYear: String
    }

    pub resource NFT: NonFungibleToken.INFT, ExtendedINFT {
        pub let id: UInt64
        pub var link: String
        pub var allowList: [String]
        pub let name: String
        pub var thumbnail: String
        pub let description: String
        pub var districtName: String
        pub var schoolName: String
        pub var schoolYear: String

        init(id: UInt64, link: String, allowList: [String], name: String, thumbnail: String, description: String, districtName: String, schoolName: String, schoolYear: String) {
            self.id = id
            self.link = link
            self.allowList = allowList
            self.name = name
            self.thumbnail = thumbnail
            self.description = description
            self.districtName = districtName
            self.schoolName = schoolName
            self.schoolYear = schoolYear
        }

        access(all) fun getDistrictName(): String {
            return self.districtName
        }

        access(all) fun getSchoolName(): String {
            return self.schoolName
        }

        access(all) fun getSchoolYear(): String {
            return self.schoolYear
        }

        access(all) fun getName(): String {
            return self.name
        }

        access(all) fun getThumbnail(): String {
            return self.thumbnail
        }

        access(all) fun getDescription(): String {
            return self.description
        }

        access(all) fun getId(): UInt64 {
            return self.id
        }
        
        access(all) fun getAllowList(): [String] {
            return self.allowList
        } 

        access(all) fun getLink(): String {
            return self.link
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

        pub fun borrowYearBlockNFT(id: UInt64): &YearBlocks.NFT? {
            // **Optional Binding** - Assign if the value is not nil for given ID
            if let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT? {
                // Create an authorized reference to allow downcasting
                return ref as! &YearBlocks.NFT
            }
            // Otherwise return nil
            return nil
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

    access(all) fun mintNFT(link: String, allowList: [String], name: String, thumbnail: String, description: String, districtName: String, schoolName: String, schoolYear: String): @NFT {
        let yearblockID = self.totalSupply + 1
        self.totalSupply = yearblockID
        let nft <- create NFT(id: yearblockID, link: link, allowList: allowList, name: name, thumbnail: thumbnail, description: description, districtName: districtName, schoolName: schoolName, schoolYear: schoolYear)
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