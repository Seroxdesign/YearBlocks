import "NonFungibleToken"
import "YearBlocks"
import "Signatures"

/// This transaction attaches a Signatures NFT to a YearBlocks NFT and puts it back in the signer's YearBlocks
/// Collection
///
transaction(signatureID: UInt64, yearblockID: UInt64) {

    let yearblocksCollectionRef: &YearBlocks.Collection
    let signaturesCollectionRef: &Signatures.Collection

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's YearBlocks Collection
        self.yearblocksCollectionRef = signer.borrow<&YearBlocks.Collection>(
                from: YearBlocks.CollectionStoragePath
            ) ?? panic("Signer does not have a YearBlocks Collection in storage")
        // Get a reference to the signer's Signatures Collection
        self.signaturesCollectionRef = signer.borrow<&Signatures.Collection>(
                from: Signatures.CollectionStoragePath
            ) ?? panic("Signer does not have a Signatures Collection in storage")
    }

    execute {
        // Withdraw the YearBlocks NFT we want to put a signature on
        let YearBlocksNFT: @YearBlocks.NFT <- self.yearblocksCollectionRef.withdraw(withdrawID: yearblockID) as! @YearBlocks.NFT

        // Put the hat on the cat
        let yearblockWithSignature: @NonFungibleToken.NFT <- self.signaturesCollectionRef.attachSignatureToYearBlock(signatureId: signatureID toYearBlocks: <- YearBlocksNFT)

        // Deposit the KittyVerse NFT back into the Collection
        self.signaturesCollectionRef.deposit(token: <-catWithHat)
    }
}
 