import "NonFungibleToken"
import "Signatures"

///

pub struct MetaDataStruct {
  pub var name: String?
  pub var comment: String?
  pub var signature: String?
 
  init(_ NFT: &Signatures.NFT?) {
    self.name = NFT?.getSignatureName()
    self.comment = NFT?.getSignatureComment()
    self.signature = NFT?.getSignature()
  }
}

pub fun main(address: Address): {UInt64: MetaDataStruct?} {
    
    var nftDataMap: {UInt64: MetaDataStruct?} = {}
    // Get a reference to the CollectionPublic Capability from the specified Address
    let signaturesCollectionRef = getAccount(address).getCapability<&{Signatures.CollectionPublic}>(
        Signatures.CollectionPublicPath
    ).borrow() ?? panic("Couldn't find CollectionPublic Capability at given Address!")

    // Return the IDs of the NFTs in the KittyHats Collection
    let ids = signaturesCollectionRef.getIDs()
    for id in ids {
        let NFT: &Signatures.NFT? = signaturesCollectionRef.borrowSignatureNFT(id: id)
        let comment: String? = NFT?.getSignatureComment()
        nftDataMap[id] = MetaDataStruct(NFT)
    }

    // Return the final mapping
    return nftDataMap
}