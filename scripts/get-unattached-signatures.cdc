import "NonFungibleToken"
import "Signatures"

///
pub fun main(address: Address): {UInt64: String?} {
    
    var idsToComments: {UInt64: String?} = {}
    // Get a reference to the CollectionPublic Capability from the specified Address
    let signaturesCollectionRef = getAccount(address).getCapability<&{Signatures.CollectionPublic}>(
        Signatures.CollectionPublicPath
    ).borrow() ?? panic("Couldn't find CollectionPublic Capability at given Address!")

    // Return the IDs of the NFTs in the KittyHats Collection
    let ids = signaturesCollectionRef.getIDs()
    for id in ids {
        let NFT: &Signatures.NFT? = signaturesCollectionRef.borrowSignatureNFT(id: id)
        let comment: String? = NFT?.getSignatureComment()
        idsToComments.insert(key: id, comment)
    }

    // Return the final mapping
    return idsToComments
}