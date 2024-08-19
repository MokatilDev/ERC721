// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./IERC721Receiver.sol";

contract ERC721 {
    string public name;
    string public symbol;
    uint256 public nextTokenIdMint;
    address public contractOwner;

    // Token id => Owner (Owner of the NFT)
    mapping(uint256 => address) internal _owners;
    // Address => Token count (How many tokens does an address have ?)
    mapping(address => uint256) internal _balances;
    // Token id => Approved address (An owner grants the address permission to sell the token on their behalf)
    mapping(uint256 => address) internal _tokenApprovals;
    // Owner => (operator => yes/no) (An owner grants the operator permission to sell all their tokens on their behalf)
    mapping(address => mapping(address => bool)) internal _operatorApprovals;
    // Token ID => Metadata
    mapping(uint256 => string) _tokenUris;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        nextTokenIdMint = 0;
        contractOwner = msg.sender;
    }

    modifier onlyValidAddress(address _addr) {
        require(
            _addr != address(0),
            "Invalid address: zero address is not allowed"
        );
        _;
    }

    function balanceOf(
        address _owner
    ) public view onlyValidAddress(_owner) returns (uint256) {
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        return _owners[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public payable {
        require(_owners[_tokenId] == _from, "You are not the owner");
        require(_to != address(0), "Invalid address");

        delete _tokenApprovals[_tokenId];
        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) public payable {
        require(
            ownerOf(_tokenId) == msg.sender ||
                _tokenApprovals[_tokenId] == msg.sender ||
                _operatorApprovals[ownerOf(_tokenId)][msg.sender],
            "Not Authorised"
        );

        emit Transfer(_from, _to, _tokenId);

        require(_checkOnERC721Received(_from, _to, _tokenId, data),"!ERC721Impelements");
    }

    function approve(address _approved,uint256 _tokenId) public payable {
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner");
        _tokenApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator,bool _approved) public {
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        return _tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner,address _operator) public view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function mintTo(address _to,string memory _uri) public {
        require(contractOwner == msg.sender , "You are not the owner");
        
        _owners[nextTokenIdMint] = _to;
        _balances[_to] += 1;
        _tokenUris[nextTokenIdMint] = _uri;
        emit Transfer(msg.sender, _to, nextTokenIdMint);
        nextTokenIdMint++;
    }

    function totalSupply() public view returns (uint256) {
        return nextTokenIdMint;
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return _tokenUris[_tokenId];
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.code.length > 0) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}
