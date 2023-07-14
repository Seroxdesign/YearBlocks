import "NonFungibleToken"
import "YearBlocks"


pub contract Signatures : NonFungibleToken {
    access(all) var totalSupply: UInt64
    // Define the Signature resource
    access(all) let CollectionStoragePath: StoragePath
    access(all) let CollectionPublicPath: PublicPath
    access(all) let ProviderPrivatePath: PrivatePath

    access(all) event ContractInitialized()

    access(all) event SignatureMinted(id: UInt64, name: String)
    access(all) event SignatureAddedToYearBlock(name: String, comment: String, signature: String)
    access(all) event removeSignatureFromYearBlock(name: String, comment: String, signature: String)

    access(all) event Withdraw(id: UInt64, from: Address?)
    access(all) event Deposit(id: UInt64, to: Address?)

    pub resource Signature {
        pub var digiComment: String
        pub var digiSig: String
        pub var digiName: String

        // Initialize the signature with a comment and an image
        init(comment: String, image: String, name: String) {
            self.digiName = name
            self.digiComment = comment
            self.digiSig = image
        }

        access(all) fun getSignatureName(): String {
            return self.digiName
        }

        access(all) fun getSignatureComment(): String {
            return self.digiComment
        }

        access(all) fun getSignature(): String {
            return self.digiSig
        }

    }

    access(all) attachment SignatureAttachment for YearBlocks.NFT {
        access(self) var signatureNFT: @NFT?
        
        init() {
            self.signatureNFT <- nil
        }

        access(all) fun borrowSignature(): &NFT? {
            return &self.signatureNFT as &NFT?
        }


        access(all) fun addSignatureNFT(_ new: @NFT) {
            pre {
                self.signatureNFT == nil: "Cannot add NFT while assigned - must remove first!"
            }
            self.signatureNFT <-! new
        }

        /// Removes the contained KittyHats.NFT if contained or nil otherwise
        ///
        access(contract) fun removeSignatureNFT(): @NFT? {
            // Cannot move nested resources, so we:
            // Assign a temporary optional resource as nil and swap
            var tmp: @NFT? <- nil
            // Swap nested and temporary resources
            tmp <-> self.signatureNFT
            return <- tmp
        }

        destroy() {
            destroy self.signatureNFT
        }
    }

    access(all) resource interface CollectionPublic {
        access(all) fun deposit(token: @NonFungibleToken.NFT)
        access(all) fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        access(all) fun borrowNFTSafe(id: UInt64): &NonFungibleToken.NFT?
        access(all) fun borrowYearBlocksSignatureNFT(id: UInt64): &KittyHats.NFT?
    }

    /// Allows for storage of any KittyHats NFTs
    ///
    access(all) resource Collection : NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, CollectionPublic {
        /// Dictionary to hold the NFTs in the Collection
        access(all) var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init() {
            self.ownedNFTs <- {}
        }
        
        /// Returns all the NFT IDs in this Collection
        ///
        access(all) fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        /// Returns a reference to the NFT with given ID, panicking if not found
        ///
        access(all) fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            pre {
                self.ownedNFTs.containsKey(id): "NFT with given ID not found in this Collection!"
            }
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        /// Returns a reference to the NFT with given ID or nil if not found
        ///
        access(all) fun borrowNFTSafe(id: UInt64): &NonFungibleToken.NFT? {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT?
        }

        /// Returns a reference to the YearBlocks.NFT with given ID or nil if not found
        ///
        access(all) fun borrowYearBlocksSignatureNFT(id: UInt64): &YearBlocks.NFT? {
            // **Optional Binding** - Assign if the value is not nil for given ID
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &YearBlocks.NFT
            }
            // Otherwise return nil
            return nil
        }
        
        /// Adds the given NFT to the Collection
        ///
        access(all) fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @YearBlocks.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            // **Optional Chaining** - emit the address of the owner if not nil, otherwise emit nil
            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }
        
        /// Returns the contained NFT with given ID, panicking if not found
        ///
        access(all) fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID)
                ?? panic("Invalid ID provided!")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }
        
        access(all) fun attachSignatureToYearBlock(signatureId: UInt64, toYearBlocks: @YearBlocks.NFT): @YearBlocks.NFT {
            pre {
                self.ownedNFTs.containsKey(signatureId): "No signature NFT with given ID in this Collection!"
            }
            // Make sure an attachment is added if need be
            let withAttachment: @YearBlocks.NFT <-self.addAttachment(toNFT: <-toYearBlocks)

        
            let signature  <- self.withdraw(withdrawID: signatureId) as! @NFT

            withAttachment[SignatureAttachment]!.addSignatureNFT(<-signature)

            let sigRef: &NFT = withAttachment[SignatureAttachment]!.borrowSignature()!
            emit SignatureAddedToYearBlock(name: sigRef.getSignatureName, comment: sigRef.getSignatureComment, signature: sigRef.getSignature)
            
            return <- withAttachment
        }

        access(all) fun removeSignatureFromYearBlock(fromYearBlocks: @YearBlocks.NFT): @YearBlocks.NFT {
     
            if let attached: &HatAttachment = fromYearBlocks[SignatureAttachment] {
             
                if let removedSignature: @NFT <- attached.removeSignatureNFT() {
                    emit removeSignatureFromYearBlock(name: removedSignature.getSignatureName, comment: removedSignature.getSignatureComment, signature: removedSignature.getSignature)
                    
                    // Then deposit it back to this Collection
                    self.deposit(token: <- removedSignature)
                }
            }
            return <- fromYearBlocks
        }


        ///
        access(self) fun addAttachment(toNFT: @YearBlocks.NFT): @YearBlocks.NFT {
            // If attachment already exists, return
            if toNFT[SignatureAttachment] != nil {
                return <-toNFT
            }
            // Otherwise, add the attachment
            return <- attach SignatureAttachment() to <- toNFT
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }
   ///
    access(all) fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    // Function to create a new Signature
    access(all) fun mintNFT(comment: String, image: String, name: String): @NFT {
        // Create an NFT
        let nft <- create NFT(comment: comment, image: image, name: name)
        // Emit the relevant event with the new NFT's info & return
        emit SignatureMinted(id: nft.id, name: name)
        return <- nft
    }

      init() {
        // Assign initial supply of 0
        self.totalSupply = 0
        
        // Name canonical paths
        //
        self.CollectionStoragePath = /storage/SignatureCollection
        self.CollectionPublicPath = /public/SignatureCollection
        self.ProviderPrivatePath = /private/SignatureProvider
    }
}