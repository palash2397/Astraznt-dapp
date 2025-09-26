// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

//  $$$$$$\   $$$$$$\ $$$$$$$$\ $$$$$$$\   $$$$$$\  $$$$$$$$\ $$\   $$\ $$$$$$$$\
// $$  __$$\ $$  __$$\\__$$  __|$$  __$$\ $$  __$$\ \____$$  |$$$\  $$ |\__$$  __|
// $$ /  $$ |$$ /  \__|  $$ |   $$ |  $$ |$$ /  $$ |    $$  / $$$$\ $$ |   $$ |
// $$$$$$$$ |\$$$$$$\    $$ |   $$$$$$$  |$$$$$$$$ |   $$  /  $$ $$\$$ |   $$ |
// $$  __$$ | \____$$\   $$ |   $$  __$$< $$  __$$ |  $$  /   $$ \$$$$ |   $$ |
// $$ |  $$ |$$\   $$ |  $$ |   $$ |  $$ |$$ |  $$ | $$  /    $$ |\$$$ |   $$ |
// $$ |  $$ |\$$$$$$  |  $$ |   $$ |  $$ |$$ |  $$ |$$$$$$$$\ $$ | \$$ |   $$ |
// \__|  \__| \______/   \__|   \__|  \__|\__|  \__|\________|\__|  \__|   \__|

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MTBVirtual is ERC20, Ownable {
    constructor() ERC20("MTB Virtual", "MTBV") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
