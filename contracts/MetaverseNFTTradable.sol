pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import { MetaverseNFT } from "./MetaverseNFT.sol";
import { MetaverseNFTData } from "./MetaverseNFTData.sol";


/**
 * @title - MetaverseNFTTradable contract
 * @notice - This contract has role that put on sale of metaverseNFTs
 */
contract MetaverseNFTTradable {
    event TradeStatusChange(uint256 _metaverseId, bytes32 status);

    address public owner;
    uint256 public fee;
    uint256 public feeRoyalty;
    uint256 PERCENTS_DIVIDER = 1000;
    address payable public feeTo;
    address public feeToSetter;
    MetaverseNFTData public metaverseNFTData;

    struct Trade {
        address seller;
        uint256 metaverseId;  /// MetaverseNFT's token ID
        uint256 metaversePrice;
        bool isValid;
        bytes32 status;   /// Open, Executed, Cancelled
    }
    mapping(uint256 => Trade) public trades;  /// [Key]: Metaverse's ID

    constructor(MetaverseNFTData _metaverseNFTData) public {
        metaverseNFTData = _metaverseNFTData;
        owner = msg.sender;
        feeTo = msg.sender;
        fee = 15;
        feeRoyalty = 1;
    }

    /**
     * @notice - This method is only executed when a seller create a new MetaverseNFT
     * @dev Opens a new trade. Puts _metaverseId in escrow.
     * @param _metaverseId The id for the metaverseId to trade.
     * @param _metaversePrice The amount of currency for which to trade the metaverseId.
     */
    function openTradeMetaverseNFT(MetaverseNFT metaverseNFT, uint256 _metaverseId, uint256 _metaversePrice) public {
        Trade storage trade = trades[_metaverseId];
        //if not new,then Opentrade,or create new trade;
        if (trade.isValid == true) {
            openTrade(metaverseNFT, _metaverseId,_metaversePrice);
            return;
        }

        require(
            msg.sender == metaverseNFT.ownerOf(1),
            "Trade can be open only by owner."
        );
        metaverseNFT.transferFrom(msg.sender, address(this), 1);
        metaverseNFTData.updateStatus(metaverseNFT, "Open");
        metaverseNFTData.updatePrice(metaverseNFT,_metaversePrice);
        trades[_metaverseId] = Trade({
            seller: msg.sender,
            metaverseId: _metaverseId,
            metaversePrice: _metaversePrice,
            isValid : true,
            status: "Open"
        });
        emit TradeStatusChange(_metaverseId,"Open");
    }

    /**
     * @dev Opens a trade by the seller.
     */
    function openTrade(MetaverseNFT metaverseNFT, uint256 _metaverseId, uint256 _metaversePrice) public {
        Trade storage trade = trades[_metaverseId];
        require(
            msg.sender == trade.seller,
            "Trade can be open only by seller."
        );
         if (metaverseNFT.ownerOf(1) == msg.sender)
            metaverseNFT.transferFrom(msg.sender, address(this), 1);
        metaverseNFTData.updateStatus(metaverseNFT, "Open");
        metaverseNFTData.updatePrice(metaverseNFT,_metaversePrice);
        trade.status = "Open";
        trade.metaversePrice = _metaversePrice;
        emit TradeStatusChange(_metaverseId, "Open");
    }

    /**
     * @dev Cancels a trade by the seller.
     */
    function cancelTrade(MetaverseNFT metaverseNFT, uint256 _metaverseId) public {
        Trade storage trade = trades[_metaverseId];
        require(
            msg.sender == trade.seller,
            "Trade can be cancelled only by seller."
        );
        require(trade.status == "Open", "Trade is not Open.");
        metaverseNFTData.updateStatus(metaverseNFT, "Cancelled");
        metaverseNFT.transferFrom(address(this), trade.seller, 1);
        trade.status = "Cancelled";
        emit TradeStatusChange(_metaverseId, "Cancelled");
    }

    /**
     * @dev Executes a trade.
     * Must have approved this contract to transfer the amount of currency specified to the seller. Transfers ownership of the metaverseId to the filler.
     */
    function transferOwnershipOfMetaverseNFT(MetaverseNFT _metaverseNFT, uint256 _metaverseId, address _buyer) internal {
        MetaverseNFT metaverseNFT = _metaverseNFT;

        Trade storage trade = trades[_metaverseId];
        require(trade.status == "Open", "Trade is not Open.");

        metaverseNFT.transferFrom(address(this), _buyer, 1);
        trade.seller = _buyer;
        trade.status = "Cancelled";
        emit TradeStatusChange(_metaverseId, "Cancelled");
    }

    /**
     * @dev - Returns the details for a trade.
     */
    function getTrade(uint256 _metaverseId) public view returns (Trade memory trade_) {
        Trade memory trade = trades[_metaverseId];
        return trade;
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "Metaverse: setFeeTo caller is not feeToSetter");
        feeTo = payable(_feeTo);
    }

    function setFee(uint8 _fee) external {
        require(msg.sender == feeToSetter, "Metaverse: setFee caller is not feeToSetter");
        fee = _fee;
    }

    function setRoyaltyFee(uint8 _royaltyFee) external {
        require(msg.sender == feeToSetter, "Metaverse: setRoyaltyFee caller is not feeToSetter");
        feeRoyalty = _royaltyFee;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == owner, "Metaverse: setFeeToSetter caller is not owner");
        feeToSetter = _feeToSetter;
    }

    function getBalance() public view returns(uint) {
    	return payable(address(this)).balance;
    }
}
