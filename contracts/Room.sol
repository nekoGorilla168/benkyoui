pragma solidity >=0.4.21 <0.6.0;

// import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "./Activatable.sol";

contract Room is Pausable, Destructible, Activatable {
  
  /*マップ*/
  // sendReword関数実行時の二重払い防止のための状態変数
  mapping(uint => bool) public rewardSent;
  
  /*イベント(トランザクションが発行される関数内部で実行される)*/
  // Deposit関数が実行時、発行される
  event Deposited(
    address indexed _depositer,
    uint _depositedValue
  );
  
  // sendReword関数実行時、発行される
  event RewardSent(
      // indexedキーワードは、イベント引数の値をフィルタリングし絞り込むことができる
    address indexed _dest,
    uint _reward,
    uint _id
  );
  
  // RefundedtoOwner関数実行時、発行される
  event RefundedtoOwner(
    address indexed _dest,
    uint _refundedBalance
  );
  
  //コンストラクタ、支払いも可能
  constructor (address _creator) public payable {
    owner = _creator;
  }
  
  // コントラクトに何らかの問題が生じた場合、関数の実行を停止する
  function deposit() external payable whenNotPaused {
      require(msg.value > 0);
      emit Deposited(msg.sender, msg.value);
  }
  
  //
  function sendReword(uint _reward, address _dest, uint _id) external onlyOwner {
    require(!rewardSent[_id]); // _id(ユニークな質問ID)が既に支払い済みかのチェックをする
    require(_reward > 0);   // 送金額が0でないか
    require(address(this).balance >= _reward); // 入力された送金額が、コントラクトが所持する額を超過していないか
    require(_dest != address(0)); // 送金先のアドレスが初期化されているか
    require(_dest != owner); // 送金先のアドレスが、オーナーのアドレスと一致していないか
    
    //
    rewardSent[_id] = true;
    _dest.transfer(_reward);
    emit RewardSent(_dest, _reward, _id);
  }
  
  // ルーム非活性時のみ実行できる関数
  function refundedtoOwner() external whenNotPaused onlyOwner {
      require(address(this).balance > 0);
      
      uint refundedBalance = address(this).balance;
      owner.transfer(refundedBalance);
      emit RefundedtoOwner(msg.sender, refundedBalance);
  }
}
