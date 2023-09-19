import "YearBlocks"
import "NonFungibleToken"

/// This transaction mints a new YearBlocks NFT and saves it in the signer's Collection
///
transaction (id: UInt64, link: String, allowList: [String], name: String, thumbnail: String, description: String, districtName: String, schoolName: String, schoolYear: String) {

  let collectionRef: &{YearBlocks.CollectionPublic}

  prepare(signer: AuthAccount) {
    // Get a reference to the signer's YearBlocks Collection
    self.collectionRef = signer.getCapability<&{YearBlocks.CollectionPublic}>(
      YearBlocks.CollectionPublicPath
    ).borrow()
    ?? panic("Signer does not have a CollectionPublic Capability configured")
  }

  execute {
    // Deposit a newly minted NFT
    self.collectionRef.deposit(
      token: <-YearBlocks.mintNFT(id: id, link: link, allowList: allowList, name: name, thumbnail: thumbnail, description: description, districtName: districtName, schoolName: schoolName, schoolYear: schoolYear)
    )
  }
}
