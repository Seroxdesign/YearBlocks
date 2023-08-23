import "AccountCreator"

transaction(signerPublicKey: String, initialFundingAmount: UFix64) {

    let accountCreatorRef: &AnyResource{AccountCreator.CreatorPublic}
    let signer: AuthAccount

    prepare(signingAccount: AuthAccount) {
        // Get the reference to the Creator resource
        self.accountCreatorRef = signingAccount.getCapability<&AnyResource{AccountCreator.CreatorPublic}>(/public/AccountCreatorPublic)
            .borrow() ?? panic("Unable to borrow reference to Creator resource")

        self.signer = signingAccount
    }

    execute {
        // Call the createNewAccount function to create the new account
        let newAccount = self.accountCreatorRef.createNewAccount(
            signer: self.signer,
            initialFundingAmount: initialFundingAmount,
            originatingPublicKey: signerPublicKey
        )
    }
}
