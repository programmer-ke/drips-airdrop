# Drips Airdrop
An end-to-end demonstration of ERC20 airdrops.

The aim is to have concrete implementation of the airdrops process
from assigning recipients to making claims.

## How it works

- Assigning ERC20 airdrop token amounts to a list of recipients
- Generate cryptographic proofs that the recipients can use to claim
  airdrops
- Allow recipients to claim airdrops (optionally via intermediaries)

### Assigning token amounts to users

This is implemented by the [GenerateInput.s.sol][geninput] script.

Run `make generate`. The output is found in
`script/target/input.json`.

It creates a JSON structure mapping recipients addresses to ERC20
token amounts (25e18 each).

[geninput]: script/GenerateInput.s.sol

### Generating cryptographic proofs

This is implemented by the [MakeMerkle.s.sol][makemerkle] script.

Run `make make`. The output is found in `script/target/output.json`.

Each user-amount input pair is converted into a bytes hash. The list
of hashes is used to construct a merkle tree and derive a root. For
each hash, a list of peers that is used to reconstruct the root is
extracted as the proof to be submitted in the claiming step.

The output of this step is a JSON file that lists for each input pair,
its matching hash as the relevant leaf of the merkle tree, the proof
needed to reconstruct the root and the root itself.

In a live implementation, the proofs would now be distributed to the
airdrop recipients to allow them to claim their awards.

[makemerkle]: script/MakeMerkle.s.sol

### Allow recipients to claim airdrops

These are implemented by the [DeployMerkleAirdrop.s.sol][deploy] and
[Interact.s.sol][interact] scripts.

Do the following:

- Run `make anvil` in a separate terminal to start the local chain
- Run `make deploy` to deploy the `MerkleAirdrop` and the ERC20 contracts
- Run `make balance` to check balance of user prior to claim
- Run `make sign` to generate the signature to be used for claiming the airdrop
- Run `make claim`. This will use an inbuilt account to initiate a
  claim on behalf of the user using the signature generated previously
- Run `make balance` again. The user's balance should have increased
  by claim amount

The `MerkleAirdrop` contract is used to validate airdrop claims. It is
deployed with the merkle tree root as an immutable attribute. To make
a claim, the recipient gets a hash of their claim by calling the
`getMessageHash` method then signs it. This signature along with the
proof can now be submitted via the `claim` method. If the
claimant does this from their own account, they will be charged
gas. An intermediary can submit the claim on their behalf in
arrangements where the the recipients should not be charged gas.

The contract validates that the signature matches that of the claiming
address. If so, it recreates the leaf (hash of address and amount) and
uses it together with the proof provided to recreate the merkle tree
root.

If successful, then this is recognized as a valid claim. The claimed
ERC20 amount will be transfered to the claiming address.

[deploy]: script/DeployMerkleAirdrop.s.sol
[interact]: script/Interact.s.sol

## Additional Topics

### Merkle Trees

This is a fundamental data structure used in Blockchain systems.

A good introduction is found on the [Cyfrin blog][cybl].

[cybl]: https://www.cyfrin.io/blog/what-is-a-merkle-tree-merkle-proof-and-merkle-root

### Second-Preimage attacks

This is a merkle-tree related attack where an attacker provides an
intermediate node as the leaf to be resolved. Because an intermediate
node with the correct proofs will successfully recreate the root, this
allows the attacker to pass the check.

An easy way to defeat this is to use a different hashing algorithm for
leaf nodes than for intermediate nodes. For the `MerkleAirdrop`
contract, leaves are hashed twice while intermediate nodes are hashed
only once.

This is explained more extensively in the [Rareskills blog][rare].

Note, the name is a misnomer because it has a different meaning in
other contexts.

[rare]: https://rareskills.io/post/merkle-tree-second-preimage-attack

### Using recipient's signature for claims

In a simpler design, a valid proof alone from the claimant would be
sufficient. As long as the proof is valid, the claimed amount is sent
to them. However, this means that they would have to spend gas.

To avoid this, some airdrop arrangements only require a valid
signature from the recipient to award the claims. An intermediary can
then be set up to accept the user's signature and make the claim
transaction on their behalf, freeing them from having to spend gas.

### The EIP 712 standard for hashing and signing

For the airdrop recipient to provide a signature to be used for
claiming rewards, they need to sign a hashed message composed
of their address and the amount awarded.

Prior to the EIP 712 standard, users could only sign an opaque
hexadecimal string they could not understand. With the EIP 712
standard, a human readable message of the data to be signed can be
presented to the user, so that they are aware of what they are
signing.

It does this by combining the domain separator with the hash of a
typed message. The typed message will be a structure of the claim
address and amount. The domain separator consists of a hash of the
contract address, chain id, contract name and version.

In a real user-facing flow, the wallet would sign the data using
the EIP 712 standard, showing the user the structure of the message
being signed. The contract would independently create an EIP 712 hash
that it uses to verify the signature.

`MerkleAirdrop` does this by extending EIP 712 functionality provided
by openzeppelin.


## Development

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
