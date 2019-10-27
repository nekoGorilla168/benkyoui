pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "./Room.sol";

contract RoomFactory is Destructible, Pausable {
    
    //
    event RoomCreated(
        address indexed _creator,
        address _room,
        uint _depositedValue
    );
    
    // constructorキーワードで定義されたコンストラクタが一度だけ実行される
    function createRoom() external payable whenNotPaused {
        /* (new Room).value(msg.value)(msg.sender) について*/
        // コンストラクタはアドレスを受け取るのでnew Room(msg.sender)となる
        // コンストラクタは送金も可能(payable)なので、.value(msg.value)となる
        /* (new コンストラクタ).value(送金額)(コンストラクタの引数) */ 
        address newRoom = (new Room).value(msg.value)(msg.sender);
        emit RoomCreated(msg.sender, newRoom, msg.value);
    }
}