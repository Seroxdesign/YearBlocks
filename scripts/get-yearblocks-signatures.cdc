import "NonFungibleToken"
import "YearBlocks2"
import "Signatures"

pub fun main(address: Address): {String: String?} {

    // Assign a return mapping
    let yearblocksAndSignatures: {String: String?} = {}
    
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
            sig = attachment.borrowSignature()?.getSignatureComment()
        }
        // Add the values to the mapping
        yearblocksAndSignatures.insert(key: name, sig)
    }

    // Return the final mapping
    return yearblocksAndSignatures
}