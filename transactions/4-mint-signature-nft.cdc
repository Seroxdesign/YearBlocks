import "YearBlocks"
import "NonFungibleToken"

/// This transaction mints a new YearBlocks NFT and saves it in the signer's Collection
///
transaction (comment: String, image: String, name: String)  {

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
            token: <-YearBlocks.mintNFT(comment: comment, image: image, name: name)
        )
    }
}
 