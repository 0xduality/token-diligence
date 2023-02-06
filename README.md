# Token Diligence • ![license](https://img.shields.io/github/license/0xduality/app?label=license) ![solidity](https://img.shields.io/badge/solidity-^0.8.16-lightgrey)

A contract that does due diligence for tokens and token pairs in decentralized exchanges
that are Uniswap-V2 forks. It can detect whether a token cannot be bought, has a tax on 
transfers, cannot be sold, or otherwise behaves differently from a regular ERC20 token.

A companion Python script `call_example.py` shows how to use an existing deployment
of this contract on Avalanche. The basic idea is the contract owner transfers some gas tokens 
to the contract once, then anyone can use the `eth_call` RPC with the owner's address
in the `from` field. A return value greater than 0 means the token does not behave well.
A return value of 0 means the token is likely okay.

## Getting Started

Assuming you have [foundry](https://getfoundry.sh/) installed
```sh
git clone --recursive https://github.com/0xduality/token-diligence
cd token-diligence
```
Copy `.env.example` to `.env`. Then 
``` 
forge test -vv
python call_example.py
```

## Deploying

Fill out the rest of the entries in your `.env` file. Then

```bash
yarn deploy
```

To deploy to a new chain you would need to edit the function `determineRouter` which returns the address of the dex router
given the factory contract (which you can get by calling the `factory()` method on any liquidity pair).
Furthermore, you would need to change the address for the wrapped gas token (WAVAX) to the
appropriate one for the chain your are deploying to.

## Blueprint

```ml
lib
├─ forge-std — https://github.com/foundry-rs/forge-std
├─ solbase — https://github.com/Sol-DAO/solbase
src
├─ Diligence — Main contract 
test
└─ Diligence.t — Tests
```

## License

[AGPL-3.0-only](https://github.com/0xduality/PrimeTime/blob/main/LICENSE)


## Acknowledgements

The following projects had a substantial influence in the development of this project.

- [femplate](https://github.com/abigger87/femplate)
- [foundry](https://github.com/foundry-rs/foundry)
- [solbase](https://github.com/Sol-DAO/solmate)
- [forge-std](https://github.com/brockelmore/forge-std)


## Disclaimer

_These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. The creators are not liable for any of the foregoing. Users should proceed with caution and use at their own risk._
