pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import { Strings } from "./openzeppelin-solidity/contracts/utils/Strings.sol";
import { SafeMath } from "./openzeppelin-solidity/contracts/math/SafeMath.sol";
import { MetaverseNFT } from "./MetaverseNFT.sol";
import { MetaverseNFTMarketplace } from "./MetaverseNFTMarketplace.sol";
import { MetaverseNFTData } from "./MetaverseNFTData.sol";


/**
 * @notice - This is the factory contract for a NFT of metaverse
 */
contract MetaverseNFTFactory {
    using Strings for string;
    using SafeMath for uint256;

    address public owner;
    string public baseTokenURI;

    event MetaverseNFTCreated (
         uint256 metaverseId,
         address owner,
         address author,
         MetaverseNFT metaverseNFT,
         string nftName,
         string nftSymbol,
         uint metaversePrice,
         string ipfsHashOfMetaverse,
         string extra
    );

    event AddReputation (
        uint256 tokenId,
        uint256 reputationCount
    );

    MetaverseNFTData public metaverseNFTData;

    constructor(MetaverseNFTData _metaverseNFTData) public {
         metaverseNFTData = _metaverseNFTData;
         owner = msg.sender;
         baseTokenURI = "https://ipfs.io/ipfs/";
    }

    /**
     * @notice - Create a new metaverseNFT when a seller (owner) upload a metaverse onto IPFS
     */
    function createNewMetaverseNFT(string memory nftName, string memory nftSymbol, uint metaversePrice, string memory ipfsHashOfMetaverse, string memory extra)
        public returns (bool) {
        address _owner = msg.sender;
        string memory tokenURI = getTokenURI(ipfsHashOfMetaverse);  /// [Note]: IPFS hash + URL
        MetaverseNFT metaverseNFT = new MetaverseNFT(_owner, nftName, nftSymbol, tokenURI);

        /// Save metadata of a metaverseNFT created
        metaverseNFTData.saveMetadataOfMetaverseNFT(metaverseNFT, nftName, nftSymbol, msg.sender, msg.sender, metaversePrice, ipfsHashOfMetaverse, extra);

        uint metaverseId = metaverseNFTData.getMetaversesCount().sub(1);
        emit MetaverseNFTCreated(metaverseId, msg.sender, msg.sender, metaverseNFT, nftName, nftSymbol, metaversePrice, ipfsHashOfMetaverse, extra);
    }

    ///-----------------
    /// Getter methods
    ///-----------------
    function getBaseTokenURI() public view returns (string memory) {
        return baseTokenURI;
    }

    function setBaseTokenURI(string memory _baseTokenURI) public {
        require(msg.sender == owner, "Metaverse: setBaseTokenURI caller is not owner");
        baseTokenURI = _baseTokenURI;
    }

    function getTokenURI(string memory _ipfsHashOfMetaverse) private view returns (string memory) {
        return Strings.strConcat(baseTokenURI, _ipfsHashOfMetaverse);
    }

}
