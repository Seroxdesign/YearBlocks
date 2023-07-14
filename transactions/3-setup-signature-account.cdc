import "NonFungibleToken"
import "Signatures"

/// This transaction sets up the signer with a Signatures Collection
///
transaction {
  prepare(signer: AuthAccount) {
    // Check if a Collection is already in Storage where expected
    if signer.type(at: Signatures.CollectionStoragePath) == nil {
      // Create and save
      signer.save(<-Signatures.createEmptyCollection(), to: Signatures.CollectionStoragePath)
      
      // Prepare to link PublicPath
      signer.unlink(Signatures.CollectionPublicPath)
      // Link public Capabilities
      signer.link<&{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver,Signatures.CollectionPublic}>(
        Signatures.CollectionPublicPath,
        target: Signatures.CollectionStoragePath
      )

      // Prepare to link PrivatePath
      signer.unlink(Signatures.ProviderPrivatePath)
      // Link private Capabilities
      signer.link<&{NonFungibleToken.Receiver}>(
        Signatures.ProviderPrivatePath,
        target: Signatures.CollectionStoragePath
      )
    }
  }
}
 