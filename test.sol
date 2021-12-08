// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract CryptoWhales is ERC721Enumerable, Ownable {

    using Strings for uint256;

    string _baseTokenURI;
    bool public _pausedPresale = true;
    uint256 private _reserved = 10;
    uint256 private _price = 0.05 ether;
    uint256 public _maxSupply = 30;
    uint256 public _presaleSupply = 19;
    uint256 public _startDate = 1638974922;
    // withdraw addresses
    address wallet = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    constructor(string memory baseURI) ERC721("Crypto Whales", "CW")  {
        setBaseURI(baseURI);

        // team gets the first 4 cats
        for(uint256 i; i < 5; i++){
            _safeMint( wallet, i );
        }
    }

    function mint(uint256 num) public payable {
        uint256 supply = totalSupply();
        require( supply + num <= _maxSupply - _reserved,     "Exceeds maximum supply" );
        require( msg.value >= _price * num,                 "Ether sent is not correct" );
        require(_startDate <= block.timestamp,              "Sale is not active");

        for(uint256 i; i < num; i++){
            _safeMint( msg.sender, supply + i );
        }
    }

    function pausePresale(bool val) public onlyOwner {
        _pausedPresale = val;
    }

    function mintPresale(uint256 num) public payable {
        uint256 supply = totalSupply();
        require( !_pausedPresale,                            "Sale paused" );
        require( supply + num <= _presaleSupply,      "Exceeds maximum supply" );
        require( msg.value >= _price * num,                  "Ether sent is not correct" );

        for(uint256 i; i < num; i++){
            _safeMint( msg.sender, supply + i );
        }
    }

    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint256 i; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function setPrice(uint256 _newPrice) public onlyOwner() {
        _price = _newPrice;
    }

    function setPresaleSupply(uint256 _newSupply) public onlyOwner() {
        require( _newSupply <= _maxSupply,      "Exceeds maximum supply" );
        _presaleSupply = _newSupply;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function getPrice() public view returns (uint256){
        return _price;
    }

    function giveAwayNft(address _to, uint256 _amount) external onlyOwner() {
        require( _amount <= _reserved, "Exceeds reserved Cat supply" );

        uint256 supply = totalSupply();
        for(uint256 i; i < _amount; i++){
            _safeMint( _to, supply + i );
        }

        _reserved -= _amount;
    }

    function withdrawAll() public payable onlyOwner {
        uint256 _each = address(this).balance / 1;
        require(payable(wallet).send(_each));
    }
}
