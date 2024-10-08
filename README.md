# TokenResurrection

### deploy command

```shell
forge script script/TokenResurrection.s.sol --rpc-url $OP_RPC_URL --private-key $PVT_KEY --verify --broadcast --etherscan-api-key $ETHERSCAN_KEY
```

### Test

```shell
forge test -vv
```


references:
https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol
https://github.com/AngleProtocol/merkl-contracts/blob/main/contracts/Distributor.sol
