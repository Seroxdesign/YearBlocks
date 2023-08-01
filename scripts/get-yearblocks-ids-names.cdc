import "NonFungibleToken"
import "YearBlocks"

/// This script returns the IDs of the KittyVerse NFTs in the Collection of the given Address
///
pub fun main(address: Address): {UInt64: String?} {

    var idsToNames: {UInt64: String?} = {}
    // Get a reference to the CollectionPublic Capability from the specified Address
    let collectionPublicRef = getAccount(address).getCapability<&{YearBlocks.CollectionPublic}>(
      YearBlocks.CollectionPublicPath 
    ).borrow()
    ?? panic("Couldn't find CollectionPublic Capability at given Address!")
    let ids = collectionPublicRef.getIDs()
    for id in ids {
      let NFT: &YearBlocks.NFT? = collectionPublicRef.borrowYearBlockNFT(id: id)
      let name = NFT?.getName()
      idsToNames.insert(key: id, name)
    }

    return idsToNames
}