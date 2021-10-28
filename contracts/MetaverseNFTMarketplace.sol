pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import { SafeMath } from "./openzeppelin-solidity/contracts/math/SafeMath.sol";
import { MetaverseNFT } from "./MetaverseNFT.sol";
import { MetaverseNFTTradable } from "./MetaverseNFTTradable.sol";
import { MetaverseNFTData } from "./MetaverseNFTData.sol";


contract MetaverseNFTMarketplace is MetaverseNFTTradable {
    using SafeMath for uint256;

    event MetaverseNFTOwnershipChanged (
        MetaverseNFT metaverseNFT,
        uint metaverseId,
        address ownerBeforeOwnershipTransferred,
        address ownerAfterOwnershipTransferred
    );

    // address public METAVERSE_NFT_MARKETPLACE;

    constructor(MetaverseNFTData _metaverseNFTData) public MetaverseNFTTradable(_metaverseNFTData) {
        // address payable METAVERSE_NFT_MARKETPLACE = address(uint160(address(this)));
    }

    /** 
     * @notice - Buy function is that buy NFT token and ownership transfer. (Reference from IERC721.sol)
     * @notice - msg.sender buy NFT with ETH (msg.value)
     * @notice - MetaverseNFT is always 1. Because each metaverseNFT is unique.
     */
    function buyMetaverseNFT(MetaverseNFT _metaverseNFT) public payable returns (bool) {
        uint _metaverseId = metaverseNFTData.getMetaverseIndex(_metaverseNFT);
        Trade storage trade = trades[_metaverseId];
        require(trade.status == "Open", "Trade is not Open");

        uint buyAmount = trade.metaversePrice;
        require (msg.value == buyAmount, "msg.value should be equal to the buyAmount");

        MetaverseNFTData.Metaverse memory metaverse = metaverseNFTData.getMetaverseByNFTAddress(_metaverseNFT);

        feeTo.transfer(msg.value.mul(fee).div(PERCENTS_DIVIDER));
        payable(metaverse.authorAddress).transfer(msg.value.mul(feeRoyalty).div(PERCENTS_DIVIDER));
        payable(trade.seller).transfer(msg.value.mul(PERCENTS_DIVIDER - fee - feeRoyalty).div(PERCENTS_DIVIDER));

        /// Approve a buyer address as a receiver before NFT's transferFrom method is executed
        address buyer = msg.sender;
        uint nftID = 1;  /// [Note]: nftID is always 1. Because each metaverseNFT is unique.
        _metaverseNFT.approve(buyer, nftID);

        address ownerBeforeOwnershipTransferred = _metaverseNFT.ownerOf(nftID);

        metaverseNFTData.updateStatus(_metaverseNFT, "Cancelled");
        /// Transfer Ownership of the MetaverseNFT from a seller to a buyer
        transferOwnershipOfMetaverseNFT(_metaverseNFT, _metaverseId, buyer);
        metaverseNFTData.updateOwnerOfMetaverse(_metaverseNFT, buyer);


        /// Event for checking result of transferring ownership of a metaverseNFT
        address ownerAfterOwnershipTransferred = _metaverseNFT.ownerOf(nftID);
        emit MetaverseNFTOwnershipChanged(_metaverseNFT, _metaverseId, ownerBeforeOwnershipTransferred, ownerAfterOwnershipTransferred);
    }


    ///-----------------------------------------------------
    /// Methods below are pending methods
    ///-----------------------------------------------------

    /** 
     * @dev reputation function is that gives reputation to a user who has ownership of being posted metaverse.
     * @dev Each user has reputation data in struct
     */
    function reputation(address from, address to, uint256 metaverseId) public returns (uint256, uint256) {

        // Metaverse storage metaverse = metaverses[metaverseId];
        // metaverse.reputation = metaverse.reputation.add(1);

        // emit AddReputation(metaverseId, metaverse.reputation);

        // return (metaverseId, metaverse.reputation);
        return (0, 0);
    }
    

    function getReputationCount(uint256 metaverseId) public view returns (uint256) {
        uint256 curretReputationCount;

        // Metaverse memory metaverse = metaverses[metaverseId];
        // curretReputationCount = metaverse.reputation;

        return curretReputationCount;
    }
}
