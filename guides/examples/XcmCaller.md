Check Polkadot's docs on [the XCM precompile](https://docs.polkadot.com/smart-contracts/precompiles/xcm/).

```solidity
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import { VersionedXcmCodec } from "solidity-scale-codec/src/Xcm/VersionedXcm/VersionedXcmCodec.sol";
import {
  VersionedXcm,
  v5
} from "solidity-scale-codec/src/Xcm/VersionedXcm/VersionedXcm.sol";
import { Xcm } from "solidity-scale-codec/src/Xcm/v5/Xcm/Xcm.sol";
import { XcmBuilder } from "solidity-scale-codec/src/Xcm/v5/Xcm/XcmBuilder.sol";
import {
  WithdrawAssetParams,
  BuyExecutionParams,
  DepositAssetParams
} from "solidity-scale-codec/src/Xcm/v5/Instruction/Instruction.sol";
import { Asset } from "solidity-scale-codec/src/Xcm/v5/Asset/Asset.sol";
import { fromAsset } from "solidity-scale-codec/src/Xcm/v5/Assets/Assets.sol";
import {
  Location,
  parent
} from "solidity-scale-codec/src/Xcm/v5/Location/Location.sol";
import { AssetId } from "solidity-scale-codec/src/Xcm/v5/AssetId/AssetId.sol";
import {
  fungible,
  FungibleParams
} from "solidity-scale-codec/src/Xcm/v5/Fungibility/Fungibility.sol";
import { unlimited } from "solidity-scale-codec/src/Xcm/v5/WeightLimit/WeightLimit.sol";
import {
  AssetFilter,
  wild,
  WildParams
} from "solidity-scale-codec/src/Xcm/v5/AssetFilter/AssetFilter.sol";
import {
  allOf,
  AllOfParams
} from "solidity-scale-codec/src/Xcm/v5/WildAsset/WildAsset.sol";
import { WildFungibility } from "solidity-scale-codec/src/Xcm/v5/WildFungibility/WildFungibility.sol";
import {
  accountId32,
  AccountId32Params
} from "solidity-scale-codec/src/Xcm/v5/Junction/Junction.sol";
import { fromJunction } from "solidity-scale-codec/src/Xcm/v5/Junctions/Junctions.sol";
import { polkadot } from "solidity-scale-codec/src/Xcm/v5/NetworkId/NetworkId.sol";
import { IXcm, XCM_PRECOMPILE_ADDRESS } from "./IXcm.sol";

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
