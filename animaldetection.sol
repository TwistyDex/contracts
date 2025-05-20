// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract DetectionLogger {
    struct Detection {
        string animalType;
        string imageURL;
        string location;
        uint256 timestamp;
    }

    Detection[] detections;
    address public owner;
    mapping(address => bool) public authorizedViewers;

    // Events for logging actions
    event DetectionLogged(string animalType, string imageURL, string location, uint256 timestamp);
    event ViewerAuthorized(address viewer);
    event ViewerRevoked(address viewer);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    modifier onlyAuthorized() {
        require(authorizedViewers[msg.sender] || msg.sender == owner, "Not authorized");
        _;
    }

    function logDetection(
        string memory _animalType,
        string memory _imageURL,
        string memory _location
    ) public onlyOwner {
        detections.push(Detection(_animalType, _imageURL, _location, block.timestamp));
        emit DetectionLogged(_animalType, _imageURL, _location, block.timestamp);
    }

    function getDetection(uint _index) public view onlyAuthorized returns (
        string memory animalType,
        string memory imageURL,
        string memory location,
        uint256 timestamp
    ) {
        require(_index < detections.length, "Invalid index");
        Detection storage d = detections[_index];
        return (d.animalType, d.imageURL, d.location, d.timestamp);
    }

    function getAllDetections() public view onlyAuthorized returns (
        string[] memory animalTypes,
        string[] memory imageURLs,
        string[] memory locations,
        uint256[] memory timestamps
    ) {
        uint256 count = detections.length;
        animalTypes = new string[](count);
        imageURLs = new string[](count);
        locations = new string[](count);
        timestamps = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {
            Detection storage d = detections[i];
            animalTypes[i] = d.animalType;
            imageURLs[i] = d.imageURL;
            locations[i] = d.location;
            timestamps[i] = d.timestamp;
        }
    }

    function authorizeViewer(address _viewer) public onlyOwner {
        authorizedViewers[_viewer] = true;
        emit ViewerAuthorized(_viewer);
    }

    function revokeViewer(address _viewer) public onlyOwner {
        authorizedViewers[_viewer] = false;
        emit ViewerRevoked(_viewer);
    }
}