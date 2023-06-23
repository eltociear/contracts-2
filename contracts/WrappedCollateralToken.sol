// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Wrapper } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IWrappedCollateralToken } from "./Interfaces/IWrappedCollateralToken.sol";
import { PositionManagerDependent } from "./PositionManagerDependent.sol";

contract WrappedCollateralToken is
    IWrappedCollateralToken,
    ERC20Wrapper,
    ERC20Permit,
    Ownable2Step,
    PositionManagerDependent
{
    uint256 public override maxBalance;
    uint256 public override cap;

    constructor(
        IERC20 underlying_,
        string memory name_,
        string memory symbol_,
        uint256 maxBalance_,
        uint256 cap_,
        address positionManager_
    )
        ERC20(name_, symbol_)
        ERC20Wrapper(underlying_)
        ERC20Permit(name_)
        PositionManagerDependent(positionManager_)
    {
        setMaxBalance(maxBalance_);
        setCap(cap_);
    }

    function setMaxBalance(uint256 newMaxBalance) public override onlyOwner {
        maxBalance = newMaxBalance;
        emit MaxBalanceSet(newMaxBalance);
    }

    function setCap(uint256 newCap) public override onlyOwner {
        cap = newCap;
        emit CapSet(newCap);
    }

    function decimals() public view virtual override(ERC20, ERC20Wrapper) returns (uint8) {
        return ERC20Wrapper.decimals();
    }

    function recover(address account) external override onlyOwner returns (uint256) {
        return _recover(account);
    }

    function depositFor(address account, uint256 amount) public override returns (bool) {
        if (totalSupply() + amount > cap) {
            revert ExceedsCap();
        }
        if (balanceOf(account) + amount > maxBalance) {
            revert ExceedsMaxBalance();
        }

        return super.depositFor(account, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal override onlyPositionManager {
        super._transfer(from, to, amount);
    }
}
