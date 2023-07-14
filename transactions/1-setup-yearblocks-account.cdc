import "YearBlocks"
import "NonFungibleToken"

/// This transaction sets up the signer with a YearBlocks Collection
///
transaction {
  prepare(signer: AuthAccount) {
    // Check if a Collection is already in Storage where expected
    if signer.type(at: YearBlocks.CollectionStoragePath) == nil {
      // Create and save
      signer.save(<-YearBlocks.createEmptyCollection(), to: YearBlocks.CollectionStoragePath)
    }

    // Prepare to link PublicPath
    signer.unlink(YearBlocks.CollectionPublicPath)
    // Link public Capabilities
    signer.link<&{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, YearBlocks.CollectionPublic}>(
      YearBlocks.CollectionPublicPath,
      target: YearBlocks.CollectionStoragePath
    )

    // Prepare to link PrivatePath
    signer.unlink(YearBlocks.ProviderPrivatePath)
    // Link private Capabilities
    signer.link<&{NonFungibleToken.Receiver}>(
      YearBlocks.ProviderPrivatePath,
      target: YearBlocks.CollectionStoragePath
    )
  }
}
 