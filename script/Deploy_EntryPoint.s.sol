//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../core/EntryPoint.sol";
import "../interfaces/IEntryPoint.sol";
import "../utils/DeploymentsManager.s.sol";

contract DeployScript is DeploymentsManager {

  function run() external {
    uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    // Deploy EntryPoint
    uint256 initialSupply = 5000000 * 10 ** 18;
    IEntryPoint entryPoint = new EntryPoint();
    console.log("EntryPoint deployed to:", address(entryPoint));

    // Deploy
    address underlyingTokenAddress = vm.envAddress("UNDERLYING_TOKEN_ADDRESS");
    uint48 leverageFactor = 200_000;
    OrbitLend orbitLend = new OrbitLend(IERC20Metadata(underlyingTokenAddress), orbitOracle, leverageFactor);
    console.log("OrbitLend deployed to:", address(orbitLend));

    // Set the Oracle in OrbitLend
    orbitLend.setOracle(orbitOracle);
    console.log("Oracle set in OrbitLend");

    // Set the backend address in OrbitOracle
    address backendAddress = vm.envAddress("BACKEND_ADDRESS");
    orbitOracle.setBackendAddress(backendAddress);
    console.log("Backend address set in OrbitOracle");

    vm.stopBroadcast();

    /**
     * This function generates the file containing the contracts Abi definitions.
     * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
     * This function should be called last.
     */
    exportDeployments();
  }
}
