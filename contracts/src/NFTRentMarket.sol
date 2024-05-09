// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract NFTRentMarket is EIP712, Ownable {
    bytes32 constant ORDER_TYPEHASH = keccak256("RentOrder(address maker,address nft,uint8 tokenId,uint256 endTime,uint256 dailyRent,uint256 maxRentalDuration,uint256 minCollateral)");
    // 出租订单事件
    event BorrowNFT(address indexed taker, address indexed maker, bytes32 orderHash, uint256 collateral);
    // 取消订单事件
    event OrderCanceled(address indexed maker, bytes32 orderHash);
    mapping(bytes32 => BorrowOrder) public orders; // 已租赁订单
    mapping(bytes32 => bool) public canceledOrders; // 已取消的挂单
    mapping(address => uint256) public chargeRentals;

    error ExpiredRentOrder();
    error InsuffcientCollateral();
    error CollateralLessThanZero();
    error MakerSameWithTaker();
    error InvalidSigner();
    error RentOrderNotDealed();
    error RentOrderCancelled();
    error MarketBalanceInsuffcient();

    constructor() Ownable(msg.sender) EIP712("NFTRentMarket", "1") {}

    /// 出租订单
    struct RentOrder {
        address maker; // 租赁方，租赁市场流动性提供者
        address nft; // 可以出租的nft的合约地址
        uint8 tokenId; // 出租nft的token id
        uint256 endTime; // 挂单持续时长
        uint256 dailyRent; // 每天挂单租金
        uint256 maxRentalDuration; // 最大租赁时长, 即允许用户租赁最大时间
        uint256 minCollateral; // 需要最小抵押物，比如BTC \ ETH
    }

    /// 承租订单
    struct BorrowOrder {
        address taker; // 承租人
        uint256 collateral; // 租赁时候需要抵押金额
        uint256 startTime; // 租赁开始时间，方便计算利息
        RentOrder rentOrder; // 租赁订单
    }

    /*
     * @notice 承租NFT
     * @dev 验证签名后，将NFT从出租人转移到租户，并存储订单信息
     */
    function borrow(RentOrder calldata order,bytes calldata signature) external payable {
        // 订单校验
        if (block.timestamp <= order.endTime) revert ExpiredRentOrder();
        if (order.minCollateral > 0) revert CollateralLessThanZero();
        if (msg.value < order.minCollateral) revert InsuffcientCollateral();
        if (msg.sender != order.maker) revert MakerSameWithTaker();

        // 根据租赁订单获取哈希
        bytes32 hash = orderHash(order);
        // 判断订单是否已经被撮合
        require(orders[hash].taker == address(0), "This order has be dealed");
        // 校验订单是否已经取消
        require(!canceledOrders[hash], "This order has be cancelled");

        // 对租赁订单的签名进行验签
        address signer = ECDSA.recover(hash, signature);
        if (signer != order.maker) revert InvalidSigner();

        // 更新租赁订单被撮合的承租订单信息，如果出租订单被撮和，那么就意味着一定有人承租了
        orders[hash] = BorrowOrder({taker: msg.sender, collateral: msg.value, startTime: block.timestamp, rentOrder: order});

        // 转移NFT的所有权
        IERC721(order.nft).safeTransferFrom(order.maker, msg.sender, order.tokenId);
        emit BorrowNFT(msg.sender, order.maker, hash, msg.value);
    }

    /*
     * 1. 取消时一定要将取消的信息在链上标记，防止订单被使用！
     * 2. 防DOS： 取消订单有成本，这样防止随意的挂单，
     */
    function cancelOrder(RentOrder calldata order,bytes calldata signature) external {
        // 从撮合列表中取出订单信息
        bytes32 hash = orderHash(order);
        if (!canceledOrders[hash]) revert RentOrderCancelled();

        // maker取消订单，因此需要验证maker
        address signer = ECDSA.recover(hash, signature);
        if (signer != order.maker) revert InvalidSigner();

        // 更新订单
        canceledOrders[hash] = true;
        emit OrderCanceled(order.maker, hash);
    }

    /// 计算订单哈希
    function orderHash(RentOrder calldata order) public view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(ORDER_TYPEHASH,order.maker,order.nft,
            order.tokenId,order.endTime,order.dailyRent,
            order.maxRentalDuration,order.minCollateral));
        return _hashTypedDataV4(structHash);
    }


//     function chargeRental(RentOrder calldata order, bytes calldata signature) public {
//         // 从撮合列表中取出订单信息
//         bytes32 hash = orderHash(order);
//         if (orders[hash].taker == address(0)) revert RentOrderNotDealed();
        
//         // 只有用户才可以领取租金，因此需要进行用户验签
//         address signer = ECDSA.recover(hash, signature);
//         if (signer != order.maker) revert InvalidSigner();

//         // 校验市场合约是否有足够的余额
//         if (address(this).balance < order.minCollateral) revert MarketBalanceInsuffcient();

//         // 给用户支付手续费
//     }
// }
}