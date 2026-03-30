// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {HintType} from "./Hint/Hint.sol";

// Maximum number of items we expect in a single Assets value.
uint64 constant MAX_ITEMS_IN_ASSETS = 20;
// Maximum number of PalletsInfo entries we expect in a single `PalletsInfo` value.
uint32 constant MAX_PALLETS_INFO = 64;
// Maximum number of entries in `InitiateTransfer.assets` (BoundedVec<AssetTransferFilter, MaxAssetTransferFilters> in Rust).
uint32 constant MAX_ASSET_TRANSFER_FILTERS = 6;
// Maximum length of a pallet name in bytes.
uint32 constant MAX_PALLET_NAME_LEN = 48;
// Maximum number of hints in a `SetHints` instruction, equal to the number of variants in the `Hint` enum.
uint32 constant HINT_NUM_VARIANTS = uint32(type(HintType).max) + 1;
