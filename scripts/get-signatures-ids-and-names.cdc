import "NonFungibleToken"
import "Signatures"

///
pub fun main(address: Address): {UInt64: String} {

    // Assign a return mapping
    let idsToComments: {UInt64: String} = {}
    
    // Get a reference to the CollectionPublic Capability from the specified Address
    let collectionPublicRef = getAccount(address).getCapability<&{Signatures.CollectionPublic}>(
        Signatures.CollectionPublicPath
    ).borrow()
    ?? panic("Couldn't find CollectionPublic Capability at given Address!")

    // Return the IDs of the NFTs in the KittyHats Collection
    for id in collectionPublicRef.getIDs() {
        let comment: String = collectionPublicRef.borrowSignatureNFT(id: id)!.getSignatureComment()
        idsToComments.insert(key: id, comment)
    }

    // Return the final mapping
    return idsToComments
}