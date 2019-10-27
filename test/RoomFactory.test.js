const RoomFactory = artifacts.require('./RoomFactory.sol')
// ヘルパーモジュールをインポート
const EVMRevert = require('openzeppelin-solidity/test/helpers/EVMRevert')
const expectEvent = require('openzeppelin-solidity/test/helpers/expectEvent')

// web3オブジェクトを参照可能
const BigNumber = web3.BigNumber

// Ethereumアカウントの配列分割代入
const should = require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber)).should();


contract('RoomFactory',
    ([factoryOwner, roomOwner1, roomOwner2, roomOwner3, ...accounts]) => {

        describe('as an instance', () => {
            // RoomFactoryコントラクトがfactoryOwnerアカウントによってEthereumネットワークにデプロイされる
            // itメソッドの前に毎回実行されるので、毎回新しいRoomFactoryこんとらくとインスタンスがitメソッドのテストコードに用意される
            beforeEach(async function () {
                // そのインスタンスはroomFactoryへ代入される
                // newメソッドはPromiseオブジェクトを返す
                this.roomFactory = await RoomFactory.new({ from: factoryOwner })
            });
            // this.roomFactoryコントラクトインスタンスの存在を確認
            it('should exist', function () {

                this.roomFactory.should.exist
            });
            // 期待通りroomが作成されているか検証
            describe('createRoom', () => {
                // 1ETHのこと
                const amount = web3.toWei('1', 'ether');

                // 
                it('should create a room', async function () {
                    // roomOwner1が1ETHを送金し、createRoom関数を実行する
                    // createRoom関数はviewやpureが付いていないので、トランザクションとして処理する
                    // トランザクションレシート(ツリー構造)でさまざまな情報を含むので、テストに必要はlogsだけを抽出する
                    const { logs } = await this.roomFactory.createRoom({ from: roomOwner1, value: amount })
                    // トランザクションレシートから抽出したLogsから更にイベントを抽出する
                    const event = await expectEvent.inLogs(logs, 'RoomCreated')
                    // getBalanceはアドレスが保持するETH残高を取得可能
                    // factoryBalanceにはRoomFactoryコントラクトが保持するETH残高(BigNumber)
                    const factoryBalance = await web3.eth.getBalance(this.roomFactory.address)
                    // roomBalanceはcreateRoomによって生成されたRoomコントラクトが保持するETH残高(BigNumber)
                    const roomBalance = await web3.eth.getBalance(event.args._room)
                    /* 最重要 */
                    // 送金額をRoomFactoryコントラクトが保持していないこと
                    factoryBalance.should.be.bignumber.equal(0)
                    // 新規作成されるRoomコントラクトに渡しているかテスト
                    roomBalance.should.be.bignumber.equal(amount)
                });
                // 実行権限を持つ者のみが実行できるかテスト
                it('only the factory owner can pause createRooom', async function () {
                    // rejectされるはず
                    await this.roomFactory.pause({ from: roomOwner1 })
                        .should.be.rejectedWith(EVMRevert);
                    // 処理が成功した状態が返される
                    await this.roomFactory.pause({ from: factoryOwner })
                        .should.be.fulfilled;
                });
            });
        });
    }
)


