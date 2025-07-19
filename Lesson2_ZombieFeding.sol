pragma solidity >=0.5.0 <0.6.0;

// Import the base ZombieFactory contract
import "./Lesson1_ZombieFactory.sol";

// Declaring the interface to interact with the external CryptoKitties contract
contract KittyInterface {
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

// ZombieFeeding inherits from ZombieFactory to reuse zombie creation logic
contract ZombieFeeding is ZombieFactory {

    // Official CryptoKitties contract address on Ethereum mainnet
    address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;

    // Creating an instance of the KittyInterface to call its functions
    KittyInterface kittyContract = KittyInterface(ckAddress);

    // This function handles DNA mixing and optionally alters it for special species like kitties
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) public {
        require(msg.sender == zombieToOwner[_zombieId], "Only the owner can use this zombie.");

        // Access the zombie from storage
        Zombie storage myZombie = zombies[_zombieId];

        // Normalize the target DNA to fit our dnaModulus
        _targetDna = _targetDna % dnaModulus;

        // Blend zombie and target DNA
        uint newDna = (myZombie.dna + _targetDna) / 2;

        // If target is a "kitty", adjust the last two digits to 99
        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - (newDna % 100) + 99;
        }

        // Create the new zombie with a modified DNA
        _createZombie("NoName", newDna);
    }

    // Feeds a zombie on a CryptoKitty by fetching its genes from the Kitty contract
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;

        // Destructuring the tuple, only using the last value (genes)
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);

        // Call feedAndMultiply with the kitty DNA and species set to "kitty"
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
