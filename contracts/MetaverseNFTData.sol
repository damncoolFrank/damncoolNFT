pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import { MetaverseNFT } from "./MetaverseNFT.sol";


/**
 * @notice - This is the storage contract for metaverseNFTs
 */
contract MetaverseNFTData {

    Metaverse[] public metaverses;

    mapping (address => uint256) public metaverseIndexes;

    constructor() public {}

    struct Metaverse {
        uint256 metaverseId;
        MetaverseNFT metaverseNFT;
        string metaverseNFTName;
        string metaverseNFTSymbol;
        address ownerAddress;
        address authorAddress;
        uint metaversePrice;
        string ipfsHashOfMetaverse;
        string status;  /// "Open" or "Cancelled"
        uint256 reputation;
        //string metaverseNftDescription;
        //string fileformat;
        string extra; //extra description
        //string tags;  //"split by #"
        //string cover; //cover of nft
    }

    /**
     * @notice - Save metadata of a metaverseNFT
     */
    function saveMetadataOfMetaverseNFT(
        MetaverseNFT _metaverseNFT, 
        string memory _metaverseNFTName, 
        string memory _metaverseNFTSymbol, 
        address _ownerAddress,
        address _authorAddress,
        uint _metaversePrice, 
        string memory _ipfsHashOfMetaverse, 
        //string memory _metaverseNftDescription,
        string memory _extra
    ) public returns (bool) {
        /// Save metadata of a metaverseNFT of metaverse
        uint id = metaverses.length;
        Metaverse memory metaverse = Metaverse({
            metaverseId : id,
            metaverseNFT: _metaverseNFT,
            metaverseNFTName: _metaverseNFTName,
            metaverseNFTSymbol: _metaverseNFTSymbol,
            ownerAddress: _ownerAddress,
            authorAddress: _authorAddress,
            metaversePrice: _metaversePrice,
            ipfsHashOfMetaverse: _ipfsHashOfMetaverse,
            status: "Cancelled",
            reputation: 0, 
            //metaverseNftDescription: _metaverseNftDescription,
            extra: _extra
        });
        metaverses.push(metaverse);
        metaverseIndexes[address(_metaverseNFT)] = id;
    }

    /**
     * @notice - Update owner address of a metaverseNFT by transferring ownership
     * Update status "Cancelled"
     */
    function updateOwnerOfMetaverse(MetaverseNFT _metaverseNFT, address _newOwner) public returns (bool) {
        require (_newOwner != address(0), "A new owner address should be not empty");
        require(
            _newOwner == _metaverseNFT.ownerOf(1),
            "metaverse newOwner address must be equal to NFT address"
        );
        uint index = getMetaverseIndex(_metaverseNFT);
        Metaverse storage metaverse = metaverses[index];
        metaverse.ownerAddress = _newOwner;
    }

    /**
     * @notice - Update status ("Open" or "Cancelled")
     */
    function updateStatus(MetaverseNFT _metaverseNFT, string memory _newStatus) public returns (bool) {
        require(msg.sender == _metaverseNFT.ownerOf(1), "Metaverse status can be update only by owner");
        uint index = getMetaverseIndex(_metaverseNFT);
        Metaverse storage metaverse = metaverses[index];
        metaverse.status = _newStatus;
    }

    function updatePrice(MetaverseNFT _metaverseNFT, uint _price) public returns (bool) {
        require(msg.sender == _metaverseNFT.ownerOf(1), "Metaverse price can be update only by owner");
        uint index = getMetaverseIndex(_metaverseNFT);
        Metaverse storage metaverse = metaverses[index];
        metaverse.metaversePrice = _price; 
    }

    ///-----------------
    /// Getter methods
    ///-----------------
    function getMetaverse(uint index) public view returns (Metaverse memory _metaverse) {
        Metaverse memory metaverse = metaverses[index];
        return metaverse;
    }

    function getMetaverseIndex(MetaverseNFT metaverseNFT) public view returns (uint) {
        uint index = metaverseIndexes[address(metaverseNFT)];
        return index;
    }

    function getMetaverseByNFTAddress(MetaverseNFT metaverseNFT) public view returns (Metaverse memory _metaverse) {
        uint index = metaverseIndexes[address(metaverseNFT)];

        Metaverse memory metaverse = metaverses[index];
        return metaverse;
    }

    function getMetaversesByRange(uint startIndex, uint blockSize) public view returns (Metaverse[] memory _metaverses) {
        if(getMetaversesCount() == 0) {
            return new Metaverse[](0);
        }
        if (startIndex + blockSize > metaverses.length) {
            blockSize = metaverses.length - startIndex;
        }
        Metaverse[] memory metaversesRange = new Metaverse[](blockSize);
        for (uint i=startIndex; i <= startIndex+blockSize-1; i++) {
            metaversesRange[i-startIndex] = metaverses[i];
        }
        return metaversesRange;
    }

    function getMetaversesCount() public view returns (uint _metaversesCount) {
        return metaverses.length;
    }

    function getAllMetaverses() public view returns (Metaverse[] memory _metaverses) {
        return metaverses;
    }

    /*function getMyMetaverses() public view returns (Metaverse[] memory_metaverses) {
        for (uint i=0; i < metaverses.length; i++) {
            if (metaverses[i].ownerAddress == msg.sender) {
                
            }
        }
    }*/

}
