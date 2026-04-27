Check Polkadot's docs on [the XCM precompile](https://docs.polkadot.com/smart-contracts/precompiles/xcm/).

```solidity
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import { VersionedXcmCodec } from "solidity-scale-codec/src/Xcm/VersionedXcm/VersionedXcmCodec.sol";
import {
  VersionedXcm,
  v5
} from "solidity-scale-codec/src/Xcm/VersionedXcm/VersionedXcm.sol";
import { IXcm, XCM_PRECOMPILE_ADDRESS } from "./IXcm.sol";
import "solidity-scale-codec/src/Xcm/v5/v5.sol";

contract XcmCaller {
  IXcm xcmPrecompile = IXcm(XCM_PRECOMPILE_ADDRESS);

  using XcmBuilder for Xcm;

  function callPrecompile() external {
    Asset memory asset = Asset({
      id: AssetId({ location: parent() }),
      fungibility: fungible(FungibleParams({ amount: 1200000000 }))
    });

    AssetFilter memory filter = wild(
      WildParams({
        wildAsset: allOf(
          AllOfParams({
            id: AssetId({ location: parent() }),
            fun: WildFungibility.Fungible
          })
        )
      })
    );

    Location memory beneficiary = Location({
      parents: 0,
      interior: fromJunction(
        accountId32(
          AccountId32Params({
            hasNetwork: false,
            network: polkadot(),
            id: hex"368e8759910dab756d344995f1d3c79374ca8f70066d3a709e48029f6bf0ee7e"
          })
        )
      )
    });

    bytes memory encodedCall = VersionedXcmCodec.encode(
      v5(
        XcmBuilder
          .create()
          .withdrawAsset(WithdrawAssetParams({ assets: fromAsset(asset) }))
          .buyExecution(
            BuyExecutionParams({ fees: asset, weightLimit: unlimited() })
          )
          .depositAsset(
            DepositAssetParams({ assets: filter, beneficiary: beneficiary })
          )
      )
    );

    xcmPrecompile.execute(
      encodedCall,
      IXcm.Weight({ refTime: 1000000000, proofSize: 1000000000 })
    );
  }
}
```
