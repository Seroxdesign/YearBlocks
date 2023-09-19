import "YearBlocks"
import "NonFungibleToken"
import "Signatures"

pub struct MetaDataStruct {
  pub var name: String?
  pub var allowList: [String]?
  pub var link: String?   
  pub var description: String?
  pub var thumbnail: String? 
  pub var districtName: String?
  pub var schoolName: String?
  pub var schoolYear: String?

  init(_ id: UInt64, _ NFT: &YearBlocks.NFT?) {
    self.description = NFT?.getDescription()
    self.thumbnail = NFT?.getThumbnail()
    self.name = NFT?.getName()
    self.allowList = NFT?.getAllowList()
    self.link = NFT?.getLink()
    self.districtName = NFT?.getDistrictName()
    self.schoolName = NFT?.getSchoolName()
    self.schoolYear = NFT?.getSchoolYear()
  }
}
/// This script returns the IDs of the KittyVerse NFTs in the Collection of the given Address
///
pub fun main(address: Address, id: UInt64): MetaDataStruct {

    // Get a reference to the CollectionPublic Capability from the specified Address
    let collectionPublicRef = getAccount(address).getCapability<&{YearBlocks.CollectionPublic}>(
      YearBlocks.CollectionPublicPath 
    ).borrow()
    ?? panic("Couldn't find CollectionPublic Capability at given Address!")

      let NFT: &YearBlocks.NFT? = collectionPublicRef.borrowYearBlockNFT(id: id)
      let NFTDetails: MetaDataStruct = MetaDataStruct(id, NFT)

    return NFTDetails
}