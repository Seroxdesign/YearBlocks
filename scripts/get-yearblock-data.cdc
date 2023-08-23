import "NonFungibleToken"
import "YearBlocks"


pub struct MetaDataStruct {
  pub var name: String?
  pub var allowList: [String]?
  pub var link: String?
  pub var thumbnail: String?
  pub var description: String?

  init(_ id: UInt64, _ NFT: &YearBlocks.NFT?) {
    self.thumbnail = NFT?.getThumbnail()
    self.description = NFT?.getDescription()
    self.name = NFT?.getName()
    self.allowList = NFT?.getAllowList()
    self.link = NFT?.getLink()
  }
}
/// This script returns the IDs of the KittyVerse NFTs in the Collection of the given Address
///
pub fun main(address: Address): {UInt64: MetaDataStruct} {

    var nftDataMap: {UInt64: MetaDataStruct} = {}
    // Get a reference to the CollectionPublic Capability from the specified Address
    let collectionPublicRef = getAccount(address).getCapability<&{YearBlocks.CollectionPublic}>(
      YearBlocks.CollectionPublicPath 
    ).borrow()
    ?? panic("Couldn't find CollectionPublic Capability at given Address!")
    let ids = collectionPublicRef.getIDs()
    for id in ids {
      let NFT: &YearBlocks.NFT? = collectionPublicRef.borrowYearBlockNFT(id: id)
      nftDataMap[id] = MetaDataStruct(id, NFT)
    }

    return nftDataMap
}