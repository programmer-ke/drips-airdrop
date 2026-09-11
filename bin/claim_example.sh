# initiating claim with gas payer different from claimant

forge script script/Interact.s.sol:ClaimAirdrop --rpc-url http://localhost:8545 --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d --broadcast

# confirm claimant's balance

cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "balanceOf(address)" 0xF921F4FA82620d8D2589971798c51aeD0C02c81a

# 0x0000000000000000000000000000000000000000000000015af1d78b58c40000

# convert hex to dec

cast --to-dec 0x0000000000000000000000000000000000000000000000015af1d78b58c40000

# 25000000000000000000
