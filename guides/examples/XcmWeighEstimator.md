Check Polkadot's docs on [the XCM precompile](https://docs.polkadot.com/smart-contracts/precompiles/xcm/).

```solidity
import {Instruction} from "../src/Xcm/v5/Instruction/Instruction.sol";
import {Xcm, fromInstructions} from "../src/Xcm/v5/Xcm/Xcm.sol";
import {v5} from "../src/Xcm/VersionedXcm/VersionedXcm.sol";
import {VersionedXcmCodec} from "../src/Xcm/VersionedXcm/VersionedXcmCodec.sol";
import {Weight} from "../src/Xcm/v5/Weight/Weight.sol";
import {WeightCodec} from "../src/Xcm/v5/Weight/WeightCodec.sol";
import {XCM_PRECOMPILE_ADDRESS, IXcm} from "./IXcm.sol";

contract XcmWeightEstimator {
  IXcm xcmPrecompile = IXcm(XCM_PRECOMPILE_ADDRESS);

  function weighMessage(
    Instruction[] memory instructions
  ) external view returns (Weight memory) {
    Xcm memory xcm = fromInstructions(instructions);
    IXcm.Weight memory weight = xcmPrecompile.weighMessage(VersionedXcmCodec.encode(v5(xcm)));
	return Weight({refTime: weight.refTime, proofSize: weight.proofSize});
  }
}
```
