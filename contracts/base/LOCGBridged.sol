// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IOptimismMintableERC20} from "../interfaces/IOptimismMintableERC20.sol";

contract LOCGBridged is
    IOptimismMintableERC20,
    AccessControl,
    ERC20,
    Pausable,
    ERC20Burnable,
    ERC20Snapshot
{
    using SafeERC20 for IERC20;
    /// @notice Address of the corresponding version of this token on the remote chain.
    address public immutable REMOTE_TOKEN;

    /// @notice Address of the StandardBridge on this network.
    address public immutable BRIDGE;

    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE"); // Whitelisted addresses can transfer token when paused

    /// @notice Emitted whenever tokens are minted for an account.
    /// @param account Address of the account tokens are being minted for.
    /// @param amount  Amount of tokens minted.
    event Mint(address indexed account, uint256 amount);

    /// @notice Emitted whenever tokens are burned from an account.
    /// @param account Address of the account tokens are being burned from.
    /// @param amount  Amount of tokens burned.
    event Burn(address indexed account, uint256 amount);

    /// @notice A modifier that only allows a defined admin address to call.
    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "!admin");
        _;
    }
    /// @notice A modifier that only allows the bridge to call.
    modifier onlyBridge() {
        require(msg.sender == BRIDGE, "LOCG: only bridge can mint and burn");
        _;
    }

    /// @param _bridge      Address of the L2 standard bridge.
    /// @param _remoteToken Address of the corresponding L1 token.
    /// @param _name        ERC20 name.
    /// @param _symbol      ERC20 symbol.
    constructor(
        address _bridge,
        address _remoteToken,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        REMOTE_TOKEN = _remoteToken;
        BRIDGE = _bridge;
    }

    /**
     * @notice Triggers stopped state.
     * Requirements:
     * - The contract must not be paused.
     */
    function pause() external onlyAdmin {
        _pause();
    }

    /**
     * @notice Returns to normal state.
     * Requirements:
     * - The contract must be paused.
     */
    function unpause() external onlyAdmin {
        _unpause();
    }

    /**
     * @notice Creates a new snapshot and returns its snapshot id.
     */
    function snapshot() external onlyAdmin returns (uint256) {
        return _snapshot();
    }

    function withdrawERC20(IERC20 token) external onlyAdmin {
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(_msgSender(), balance);
    }

    function withdrawERC721(IERC721 token, uint256 id) external onlyAdmin {
        token.transferFrom(address(this), _msgSender(), id);
    }

    function withdrawERC1155(
        IERC1155 token,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external onlyAdmin {
        token.safeTransferFrom(address(this), _msgSender(), id, amount, data);
    }

    /**
     * @dev This function is overridden in both ERC20 and ERC20Snapshot, so we need to specify execution order here.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);

        require(
            !paused() ||
                hasRole(WHITELISTED_ROLE, _msgSender()) ||
                hasRole(WHITELISTED_ROLE, from),
            "transfers paused"
        );
    }

    // Functions needed for the bridge

    /// @notice ERC165 interface check function.
    /// @param _interfaceId Interface ID to check.
    /// @return Whether or not the interface is supported by this contract.
    function supportsInterface(
        bytes4 _interfaceId
    ) public pure virtual override(IERC165, AccessControl) returns (bool) {
        bytes4 iface1 = type(IERC165).interfaceId;
        // Interface corresponding to the updated OptimismMintableERC20 (this contract).
        bytes4 iface2 = type(IOptimismMintableERC20).interfaceId;
        return _interfaceId == iface1 || _interfaceId == iface2;
    }

    /// @notice Allows the StandardBridge on this network to mint tokens.
    /// @param _to     Address to mint tokens to.
    /// @param _amount Amount of tokens to mint.
    function mint(
        address _to,
        uint256 _amount
    ) external virtual override(IOptimismMintableERC20) onlyBridge {
        _mint(_to, _amount);
        emit Mint(_to, _amount);
    }

    /// @notice Prevents tokens from being withdrawn to L1.
    function burn(
        address,
        uint256
    ) external virtual override(IOptimismMintableERC20) onlyBridge {
        revert("LOCG cannot be withdrawn");
    }
    /**
     * @custom:legacy
     * @notice Legacy getter for the remote token. Use REMOTE_TOKEN going forward.
     */
    function l1Token() public view returns (address) {
        return REMOTE_TOKEN;
    }

    /**
     * @custom:legacy
     * @notice Legacy getter for the bridge. Use BRIDGE going forward.
     */
    function l2Bridge() public view returns (address) {
        return BRIDGE;
    }

    /**
     * @custom:legacy
     * @notice Legacy getter for REMOTE_TOKEN.
     */
    function remoteToken() public view returns (address) {
        return REMOTE_TOKEN;
    }

    /**
     * @custom:legacy
     * @notice Legacy getter for BRIDGE.
     */
    function bridge() public view returns (address) {
        return BRIDGE;
    }
}
