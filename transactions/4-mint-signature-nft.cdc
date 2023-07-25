import "Signatures"
import "NonFungibleToken"

/// This transaction mints a new YearBlocks NFT and saves it in the signer's Collection
///
transaction (id: UInt64, comment: String, image: String, name: String)  {

    let collectionRef: &{Signatures.CollectionPublic}

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's YearBlocks Collection
        self.collectionRef = signer.getCapability<&{Signatures.CollectionPublic}>(
               Signatures.CollectionPublicPath
            ).borrow()
            ?? panic("Signer does not have a CollectionPublic Capability configured")
    }

    execute {
        // Deposit a newly minted NFT
        self.collectionRef.deposit(
            token: <-Signatures.mintNFT(id: id, comment: comment, image: image, name: name)
        )
    }
}
 