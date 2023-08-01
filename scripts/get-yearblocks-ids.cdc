import "NonFungibleToken"
import "YearBlocks"

/// This script returns the IDs of the KittyVerse NFTs in the Collection of the given Address
///
pub fun main(address: Address): [UInt64] {
    // Get a reference to the CollectionPublic Capability from the specified Address
    let collectionPublicRef = getAccount(address).getCapability<&{YearBlocks.CollectionPublic}>(
      YearBlocks.CollectionPublicPath 
    ).borrow()
    ?? panic("Couldn't find CollectionPublic Capability at given Address!")

    // Return the IDs of the NFTs in the KittyVerse Collection
    return collectionPublicRef.getIDs()
}