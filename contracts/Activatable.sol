pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Activatable is Ownable {
    
    event Deactive(address indexed _sender);
    event Activate(address indexed _sender);
    
    // 状態変数
    bool public active = false;
    
    // 
    modifier whenActive() {
        require(active); _;
    }
    
    // 
    modifier whenNotActive() {
        require(!active); _;
    }
    
    //
    function deactivate() public whenActive onlyOwner {
        active = false;
        emit Deactive(msg.sender);
    }
    
    //
    function activate() public whenNotActive onlyOwner {
        active = true;
        emit Activate(msg.sender);
    }
}