Promise = require('bluebird')
Promise.promisifyAll(web3.eth, { suffix: 'Promise' })

const expectedExceptionPromise = require("../utils/expectedException.js");
const Splitter  = artifacts.require('./Splitter.sol');

contract('Scenarios', accounts => {
    let owner
    let firstPerson
    let secondPerson
    let splitter

    before('Setup variables', () => {
        assert.isAtLeast(accounts.length, 3)
        owner = accounts[0]
        firstPerson = accounts[1]
        secondPerson = accounts[2]
    })

    beforeEach('Setup contracts', () => {
        return splitter = Splitter.new({from: owner})
            .then(instance => splitter = instance)
    })

    it('Scenario 1 - should have 0 balance after split and withdraw', () => {
        return splitter.split(firstPerson, secondPerson, {from: owner, value: 10})
            .then(tx => {
                assert.strictEqual(tx.logs[0].event, 'LogSplit')
                assert.strictEqual(tx.logs[0].args.amount.toString(), '5')

                return splitter.withdraw({from: firstPerson})
            })
            .then(tx => {
                assert.strictEqual(tx.logs[0].event, 'LogWithdraw')
                assert.strictEqual(tx.logs[0].args.amount.toString(), '5')

                return splitter.withdraw({from: secondPerson})
            })
            .then(tx => {
                assert.strictEqual(tx.logs[0].event, 'LogWithdraw')
                assert.strictEqual(tx.logs[0].args.amount.toString(), '5')

                return splitter;
            })
            .then(splitter => web3.eth.getBalancePromise(splitter.address))
            .then(balance => assert.strictEqual(balance.toString(), '0'))
    })

    it('Scenario 2 - should have 10 balance after split 10', () => {
        return splitter.split(firstPerson, secondPerson, {from: owner, value: 10})
            .then(tx => {
                assert.strictEqual(tx.logs[0].event, 'LogSplit')
                assert.strictEqual(tx.logs[0].args.amount.toString(), '5')

                return splitter
            })
            .then(splitter => web3.eth.getBalancePromise(splitter.address))
            .then(balance => assert.strictEqual(balance.toString(), '10'))
    })

    it('Scenario 3 - should have 1 balance after split and withdraw odd value', () => {
        return splitter.split(firstPerson, secondPerson, {from: owner, value: 11})
            .then(tx => {
                assert.strictEqual(tx.logs[0].event, 'LogSplit')
                assert.strictEqual(tx.logs[0].args.amount.toString(), '5')

                return splitter.withdraw({from: firstPerson})
            })
            .then(tx => {
                assert.strictEqual(tx.logs[0].event, 'LogWithdraw')
                assert.strictEqual(tx.logs[0].args.amount.toString(), '5')

                return splitter.withdraw({from: secondPerson})
            })
            .then(tx => {
                assert.strictEqual(tx.logs[0].event, 'LogWithdraw')
                assert.strictEqual(tx.logs[0].args.amount.toString(), '5')

                return splitter;
            })
            .then(splitter => web3.eth.getBalancePromise(splitter.address))
            .then(balance => assert.strictEqual(balance.toString(), '1'))
    })

    it('Scenario 4 - should not let split without amount', () => {
        return expectedExceptionPromise(() =>
            splitter.split(firstPerson, secondPerson, {from: owner}))

    })
})
