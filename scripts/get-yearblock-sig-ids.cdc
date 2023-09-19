import "YearBlocks"
import "NonFungibleToken"
import "Signatures"

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

pub fun main(address: Address):{String: [MetaDataStruct]?} {

    // Assign a return mapping
    let yearblocksAndSignatures:{String: [MetaDataStruct]} = {"start": []}
    
    // Get a reference to the CollectionPublic Capability from the specified Address
    let collectionPublicRef = getAccount(address).getCapability<&{YearBlocks.CollectionPublic}>(
        YearBlocks.CollectionPublicPath
    ).borrow()
    ?? panic("Couldn't find CollectionPublic Capability at given Address!")

    for id in collectionPublicRef.getIDs() {
        let yearblockNFTRef: &YearBlocks.NFT = collectionPublicRef.borrowYearBlockNFT(id: id)!
        // Assign our initial return mapping values
        let name: String = yearblockNFTRef.getName()
        var sig: String? = nil
        // Reference the KittyHats attachment if there is one
        if let attachment = yearblockNFTRef[Signatures.SignatureAttachment] {
        // Get the name of the hat in the attachment if one exists
        yearblocksAndSignatures[name] = []
        if let attachment = yearblockNFTRef[Signatures.SignatureAttachment] {
            // Get the name of the hat in the attachment if one exists
          for _id in attachment.getIDsFromAttachment() {
              let sig: &Signatures.NFT? = attachment.borrowSignature(id: _id) 
              yearblocksAndSignatures[name]?.append(MetaDataStruct(sig))
          }
        }
        }
    }

    // Return the final mapping
    return yearblocksAndSignatures
}