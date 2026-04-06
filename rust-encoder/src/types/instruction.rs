use staging_xcm::v5::{
    Asset, AssetFilter, AssetId, Assets, Fungibility, Instruction, Junction, Junctions, Location,
    MaybeErrorCode, NetworkId, OriginKind, QueryResponseInfo, Response, Weight, WeightLimit,
};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    let empty_assets = Assets::from(vec![]);
    let empty_location = Location::new(0, Junctions::Here);
    let parent_location = Location::new(1, Junctions::Here);

    vec![
        // 0: WithdrawAsset
        encode_example(
            "instruction_withdraw_asset",
            Instruction::<()>::WithdrawAsset(empty_assets.clone()),
        ),
        // 1: ReserveAssetDeposited
        encode_example(
            "instruction_reserve_asset_deposited",
            Instruction::<()>::ReserveAssetDeposited(empty_assets.clone()),
        ),
        // 2: ReceiveTeleportedAsset
        encode_example(
            "instruction_receive_teleported_asset",
            Instruction::<()>::ReceiveTeleportedAsset(empty_assets.clone()),
        ),
        // 3: QueryResponse
        encode_example(
            "instruction_query_response",
            Instruction::<()>::QueryResponse {
                query_id: 0u64,
                response: Response::Null,
                max_weight: Weight::from_parts(0, 0),
                querier: None,
            },
        ),
        // 4: TransferAsset
        encode_example(
            "instruction_transfer_asset",
            Instruction::<()>::TransferAsset {
                assets: empty_assets.clone(),
                beneficiary: empty_location.clone(),
            },
        ),
        // 5: TransferReserveAsset
        encode_example(
            "instruction_transfer_reserve_asset",
            Instruction::<()>::TransferReserveAsset {
                assets: empty_assets.clone(),
                dest: empty_location.clone(),
                xcm: Default::default(),
            },
        ),
        // 6: Transact
        encode_example(
            "instruction_transact",
            Instruction::<()>::Transact {
                origin_kind: OriginKind::Native,
                fallback_max_weight: Some(Weight::from_parts(20, 10)),
                call: hex::decode("00071054657374").unwrap().into(),
            },
        ),
        // 7: HrmpNewChannelOpenRequest
        encode_example(
            "instruction_hrmp_new_channel_open_request",
            Instruction::<()>::HrmpNewChannelOpenRequest {
                sender: 1,
                max_message_size: 1024,
                max_capacity: 100,
            },
        ),
        // 8: HrmpChannelAccepted
        encode_example(
            "instruction_hrmp_channel_accepted",
            Instruction::<()>::HrmpChannelAccepted { recipient: 1 },
        ),
        // 9: HrmpChannelClosing
        encode_example(
            "instruction_hrmp_channel_closing",
            Instruction::<()>::HrmpChannelClosing {
                initiator: 1,
                sender: 2,
                recipient: 3,
            },
        ),
        // 10: ClearOrigin
        encode_example("instruction_clear_origin", Instruction::<()>::ClearOrigin),
        // 11: DescendOrigin
        encode_example(
            "instruction_descend_origin",
            Instruction::<()>::DescendOrigin(Junctions::Here),
        ),
        // 12: ReportError
        encode_example(
            "instruction_report_error",
            Instruction::<()>::ReportError(QueryResponseInfo {
                destination: empty_location.clone(),
                query_id: 0u64,
                max_weight: Weight::from_parts(0, 0),
            }),
        ),
        // 13: DepositAsset
        encode_example(
            "instruction_deposit_asset",
            Instruction::<()>::DepositAsset {
                assets: AssetFilter::Wild(staging_xcm::v5::WildAsset::All),
                beneficiary: empty_location.clone(),
            },
        ),
        // 14: DepositReserveAsset
        encode_example(
            "instruction_deposit_reserve_asset",
            Instruction::<()>::DepositReserveAsset {
                assets: AssetFilter::Wild(staging_xcm::v5::WildAsset::All),
                dest: empty_location.clone(),
                xcm: Default::default(),
            },
        ),
        // 15: ExchangeAsset
        encode_example(
            "instruction_exchange_asset",
            Instruction::<()>::ExchangeAsset {
                give: AssetFilter::Wild(staging_xcm::v5::WildAsset::All),
                want: empty_assets.clone(),
                maximal: true,
            },
        ),
        // 16: InitiateReserveWithdraw
        encode_example(
            "instruction_initiate_reserve_withdraw",
            Instruction::<()>::InitiateReserveWithdraw {
                assets: AssetFilter::Wild(staging_xcm::v5::WildAsset::All),
                reserve: empty_location.clone(),
                xcm: Default::default(),
            },
        ),
        // 17: InitiateTeleport
        encode_example(
            "instruction_initiate_teleport",
            Instruction::<()>::InitiateTeleport {
                assets: AssetFilter::Wild(staging_xcm::v5::WildAsset::All),
                dest: empty_location.clone(),
                xcm: Default::default(),
            },
        ),
        // 18: ReportHolding
        encode_example(
            "instruction_report_holding",
            Instruction::<()>::ReportHolding {
                response_info: QueryResponseInfo {
                    destination: empty_location.clone(),
                    query_id: 0u64,
                    max_weight: Weight::from_parts(0, 0),
                },
                assets: AssetFilter::Wild(staging_xcm::v5::WildAsset::All),
            },
        ),
        // 19: BuyExecution
        encode_example(
            "instruction_buy_execution",
            Instruction::<()>::BuyExecution {
                fees: Asset {
                    id: AssetId(parent_location.clone()),
                    fun: Fungibility::Fungible(1_000_000),
                },
                weight_limit: WeightLimit::Unlimited,
            },
        ),
        // 20: RefundSurplus
        encode_example(
            "instruction_refund_surplus",
            Instruction::<()>::RefundSurplus,
        ),
        // 21: SetErrorHandler
        encode_example(
            "instruction_set_error_handler",
            Instruction::<()>::SetErrorHandler(Default::default()),
        ),
        // 22: SetAppendix
        encode_example(
            "instruction_set_appendix",
            Instruction::<()>::SetAppendix(Default::default()),
        ),
        // 23: ClearError
        encode_example("instruction_clear_error", Instruction::<()>::ClearError),
        // 24: ClaimAsset
        encode_example(
            "instruction_claim_asset",
            Instruction::<()>::ClaimAsset {
                assets: empty_assets.clone(),
                ticket: empty_location.clone(),
            },
        ),
        // 25: Trap
        encode_example("instruction_trap", Instruction::<()>::Trap(0)),
        // 26: SubscribeVersion
        encode_example(
            "instruction_subscribe_version",
            Instruction::<()>::SubscribeVersion {
                query_id: 0u64,
                max_response_weight: Weight::from_parts(0, 0),
            },
        ),
        // 27: UnsubscribeVersion
        encode_example(
            "instruction_unsubscribe_version",
            Instruction::<()>::UnsubscribeVersion,
        ),
        // 28: BurnAsset
        encode_example(
            "instruction_burn_asset",
            Instruction::<()>::BurnAsset(empty_assets.clone()),
        ),
        // 29: ExpectAsset
        encode_example(
            "instruction_expect_asset",
            Instruction::<()>::ExpectAsset(empty_assets.clone()),
        ),
        // 30: ExpectOrigin
        encode_example(
            "instruction_expect_origin",
            Instruction::<()>::ExpectOrigin(Some(empty_location.clone())),
        ),
        // 31: ExpectError
        encode_example(
            "instruction_expect_error",
            Instruction::<()>::ExpectError(None),
        ),
        // 32: ExpectTransactStatus
        encode_example(
            "instruction_expect_transact_status",
            Instruction::<()>::ExpectTransactStatus(MaybeErrorCode::Success),
        ),
        // 33: QueryPallet
        encode_example(
            "instruction_query_pallet",
            Instruction::<()>::QueryPallet {
                module_name: vec![],
                response_info: QueryResponseInfo {
                    destination: empty_location.clone(),
                    query_id: 0u64,
                    max_weight: Weight::from_parts(0, 0),
                },
            },
        ),
        // 34: ExpectPallet
        encode_example(
            "instruction_expect_pallet",
            Instruction::<()>::ExpectPallet {
                index: 0,
                name: vec![],
                module_name: vec![],
                crate_major: 0,
                min_crate_minor: 0,
            },
        ),
        // 35: ReportTransactStatus
        encode_example(
            "instruction_report_transact_status",
            Instruction::<()>::ReportTransactStatus(QueryResponseInfo {
                destination: empty_location.clone(),
                query_id: 0u64,
                max_weight: Weight::from_parts(0, 0),
            }),
        ),
        // 36: ClearTransactStatus
        encode_example(
            "instruction_clear_transact_status",
            Instruction::<()>::ClearTransactStatus,
        ),
        // 37: UniversalOrigin
        encode_example(
            "instruction_universal_origin",
            Instruction::<()>::UniversalOrigin(Junction::GlobalConsensus(
                staging_xcm::v5::NetworkId::Polkadot,
            )),
        ),
        // 38: ExportMessage
        encode_example(
            "instruction_export_message",
            Instruction::<()>::ExportMessage {
                network: NetworkId::Polkadot,
                destination: Junctions::Here,
                xcm: Default::default(),
            },
        ),
        // 39: LockAsset
        encode_example(
            "instruction_lock_asset",
            Instruction::<()>::LockAsset {
                asset: Asset {
                    id: AssetId(parent_location.clone()),
                    fun: Fungibility::Fungible(1_000_000),
                },
                unlocker: empty_location.clone(),
            },
        ),
        // 40: UnlockAsset
        encode_example(
            "instruction_unlock_asset",
            Instruction::<()>::UnlockAsset {
                asset: Asset {
                    id: AssetId(parent_location.clone()),
                    fun: Fungibility::Fungible(1_000_000),
                },
                target: empty_location.clone(),
            },
        ),
        // 41: NoteUnlockable
        encode_example(
            "instruction_note_unlockable",
            Instruction::<()>::NoteUnlockable {
                asset: Asset {
                    id: AssetId(parent_location.clone()),
                    fun: Fungibility::Fungible(1_000_000),
                },
                owner: empty_location.clone(),
            },
        ),
        // 42: RequestUnlock
        encode_example(
            "instruction_request_unlock",
            Instruction::<()>::RequestUnlock {
                asset: Asset {
                    id: AssetId(parent_location.clone()),
                    fun: Fungibility::Fungible(1_000_000),
                },
                locker: empty_location.clone(),
            },
        ),
        // 43: SetFeesMode
        encode_example(
            "instruction_set_fees_mode",
            Instruction::<()>::SetFeesMode { jit_withdraw: true },
        ),
        // 44: SetTopic
        encode_example(
            "instruction_set_topic",
            Instruction::<()>::SetTopic([0u8; 32]),
        ),
        // 45: ClearTopic
        encode_example("instruction_clear_topic", Instruction::<()>::ClearTopic),
        // 46: AliasOrigin
        encode_example(
            "instruction_alias_origin",
            Instruction::<()>::AliasOrigin(empty_location.clone()),
        ),
        // 47: UnpaidExecution
        encode_example(
            "instruction_unpaid_execution",
            Instruction::<()>::UnpaidExecution {
                weight_limit: WeightLimit::Unlimited,
                check_origin: None,
            },
        ),
        // 48: PayFees
        encode_example(
            "instruction_pay_fees",
            Instruction::<()>::PayFees {
                asset: Asset {
                    id: AssetId(parent_location.clone()),
                    fun: Fungibility::Fungible(1_000_000),
                },
            },
        ),
        // 49: InitiateTransfer
        encode_example(
            "instruction_initiate_transfer",
            Instruction::<()>::InitiateTransfer {
                destination: empty_location.clone(),
                remote_fees: None,
                preserve_origin: false,
                assets: Default::default(),
                remote_xcm: Default::default(),
            },
        ),
        // 50: ExecuteWithOrigin
        encode_example(
            "instruction_execute_with_origin",
            Instruction::<()>::ExecuteWithOrigin {
                descendant_origin: None,
                xcm: Default::default(),
            },
        ),
        // 51: SetHints
        encode_example(
            "instruction_set_hints",
            Instruction::<()>::SetHints {
                hints: Default::default(),
            },
        ),
    ]
}
