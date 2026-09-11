# get digest to sign
cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getMessageHash(address,uint256)" 0xF921F4FA82620d8D2589971798c51aeD0C02c81a 25000000000000000000 --rpc-url http://localhost:8545

# 0xf40d46626e1c05ab2d6c9f76ed1ffe621ed4267273a98282944ebedc5a75f2c5

# sign digest (substitute --account for --private-key in real chain)
cast wallet sign --no-hash 0xf40d46626e1c05ab2d6c9f76ed1ffe621ed4267273a98282944ebedc5a75f2c5 --private-key 0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96

# 0x82a92fb5d8f8fe65a15f00e4c3d662bb4dcf70d24f6e8bcc858c26a4017a95ff728b70aa938430f7687cfb9cdd20c633877f28dd94ef4a679d46e7ddeb88caa21b
