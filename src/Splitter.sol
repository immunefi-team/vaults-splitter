// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { IERC20 } from "openzeppelin-contracts/interfaces/IERC20.sol";
import { SafeERC20 } from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "openzeppelin-contracts/access/Ownable.sol";
import { ReentrancyGuard } from "openzeppelin-contracts/security/ReentrancyGuard.sol";

/**
 * @title Splitter
 * @author Immunefi
 */
contract Splitter is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct ERC20Payment {
        address token;
        uint256 amount;
    }

    event FeeRecipientChanged(address prevFeeRecipient, address newFeeRecipient);
    event PayWhitehat(
        address indexed from,
        bytes32 indexed referenceId,
        address wh,
        ERC20Payment[] payout,
        uint256 nativeTokenAmt,
        address feeRecipient,
        uint256 fee
    );

    uint256 public constant FEE_BASIS = 100_00;
    uint256 public immutable maxFee;
    uint256 public immutable gasCap;
    address payable public feeRecipient;

    constructor(uint256 _gasCap, uint256 _maxFee, address _owner, address payable _feeRecipient) {
        require(_maxFee <= FEE_BASIS, "Splitter: maxFee must be below FEE_BASIS");
        maxFee = _maxFee;

        gasCap = _gasCap;

        _changeFeeRecipient(_feeRecipient);
        _transferOwnership(_owner);
    }

    /**
     * @notice internal change fee recipient
     * @param newFeeRecipient address of new fee recipient
     */
    function _changeFeeRecipient(address payable newFeeRecipient) internal {
        require(newFeeRecipient != address(0), "Splitter: FeeRecipient cannot be null address");

        emit FeeRecipientChanged(feeRecipient, newFeeRecipient);

        feeRecipient = newFeeRecipient;
    }

    /**
     * @notice change fee recipient
     * @dev only callable by owner
     * @param newFeeRecipient address of new fee recipient
     */
    function changeFeeRecipient(address payable newFeeRecipient) public onlyOwner {
        _changeFeeRecipient(newFeeRecipient);
    }

    /**
     * @notice Pay a whitehat
     * @dev If whitehats attempt to grief payments, project/immunefi reserves the right to nullify bounty payout
     * @dev The amount of gas forwarded to the whitehat should be enough for a delegatecall to be made to support
     *      gnosis safe wallets
     * @param referenceId id reference to report
     * @param wh whitehat address
     * @param payout The payout of tokens/token amounts to whitehat
     * @param nativeTokenAmt The payout of native Ether amount to whitehat
     * @param gas The amount of gas to forward to the whitehat to mitigate gas griefing
     * @param fee The fee to be paid to the fee recipient
     */
    function payWhitehat(
        bytes32 referenceId,
        address payable wh,
        ERC20Payment[] calldata payout,
        uint256 nativeTokenAmt,
        uint256 gas,
        uint256 fee
    ) external payable nonReentrant {
        require(wh != address(0), "Splitter: Whitehat address cannot be null");
        require(gas <= gasCap, "Splitter: Gas greater than max allowed");
        require(fee <= maxFee, "Splitter: Fee greater than max allowed");

        for (uint256 i = 0; i < payout.length; i++) {
            uint256 feeAmount = (payout[i].amount * fee) / FEE_BASIS;
            if (feeAmount > 0) IERC20(payout[i].token).safeTransferFrom(msg.sender, feeRecipient, feeAmount);
            IERC20(payout[i].token).safeTransferFrom(msg.sender, wh, payout[i].amount);
        }

        if (nativeTokenAmt > 0) {
            _payWhitehatNative(wh, nativeTokenAmt, gas, fee);
        } else if (msg.value > 0) {
            // must refund msg.sender
            _refundCaller(msg.value);
        }

        if (nativeTokenAmt > 0 || payout.length > 0) {
            emit PayWhitehat(msg.sender, referenceId, wh, payout, nativeTokenAmt, feeRecipient, fee);
        }
    }

    /**
     * @notice Pays whitehat in native token
     * @param wh whitehat address
     * @param nativeTokenAmt The payout of native Ether amount to whitehat
     * @param gas The amount of gas to forward to the whitehat to mitigate gas griefing
     * @param fee The fee to be paid to the fee recipient
     */
    function _payWhitehatNative(address payable wh, uint256 nativeTokenAmt, uint256 gas, uint256 fee) internal {
        uint256 feeAmount = (nativeTokenAmt * fee) / FEE_BASIS;
        if (feeAmount > 0) {
            // feeRecipient is trusted, we can skip this check
            // slither-disable-next-line arbitrary-send-eth,low-level-calls
            (bool successFee, ) = feeRecipient.call{ value: feeAmount }("");
            require(successFee, "Splitter: Failed to send ether to fee receiver");
        }
        // wh is not trusted but, we cap execution and avoid to re-enter, we can skip this check
        // slither-disable-next-line arbitrary-send-eth,low-level-calls
        (bool successWh, ) = wh.call{ value: nativeTokenAmt, gas: gas }("");
        require(successWh, "Splitter: Failed to send ether to whitehat");

        uint256 nativeAmountDistributed = nativeTokenAmt + feeAmount;
        if (msg.value > nativeAmountDistributed) {
            _refundCaller(msg.value - nativeAmountDistributed);
        }
    }

    /**
     * @notice Refunds msg.sender
     * @param amount Amount to refund
     */
    function _refundCaller(uint256 amount) internal {
        // slither-disable-next-line arbitrary-send-eth,low-level-calls
        (bool success, ) = msg.sender.call{ value: amount }("");
        require(success, "Splitter: Failed to refund to msg.sender");
    }
}
