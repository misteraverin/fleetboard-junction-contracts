pragma solidity ^0.4.18;

contract TrackTruck {
    enum cargoState {Inactive, InDelivery, Damaged, Delivered, Checked}
    
    struct Place {
        uint id;
        string name;
    }
    
    struct Company {
        uint id;
        string name;
    }
    
    struct Cargo {
        uint id;
        address company;
        string name;
        Place place;
    }
    
    mapping(uint => mapping(address => bool)) workers; //id company -> map (address of worker -> bool)
    mapping(address => Company) company;
    mapping(address => bool) inspectors;
    mapping(uint => Cargo) cargos;
    mapping(uint => Place) places;
    mapping(uint256 => cargoState) stateInPlace; // cargo Id -> state
    uint public placeAmount = 0;
    uint256 public cargoAmount = 0;
    uint public companyAmount = 0;
    address public flowerAddress = 0xC0a618ABC30DE498D63166Ebcd44892e6a4faC28;
    address public medicineAddress = 0xC0a618ABC30DE498D63166Ebcd44892e6a4faC28;
    
    
    address public owner; 

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyCompanyMember(address _targetCompany, address _targetWorker) {
        uint companyId = company[_targetCompany].id;
        require(workers[companyId][_targetWorker] == true);
        _;
    }

    function TrackTruck() public
    {
        owner = msg.sender;
        addNewPlace("Greece");
        addNewPlace("Holland");
        addNewPlace("Germany");
        addNewPlace("Spain");
        addNewCompany("Junction Flowers Inc.", flowerAddress);
        addNewCompany("Johnson & Johnson", medicineAddress);
        addNewCargo("Red Tulip", flowerAddress, 1, flowerAddress);
        addNewCargo("Pharmacy", flowerAddress, 1, flowerAddress);
    }

    function addNewPlace(string _name) public onlyOwner returns(uint _value) {
        places[placeAmount] = Place(placeAmount, _name);
        placeAmount = placeAmount + 1;
        return placeAmount;
    }
    
    function getPlaceName(uint _id) public constant returns(string) {
        return places[_id].name;
    }
    
    
    
    function addNewCargo(string _name, address _companyAddress, uint _place, address _targetWorker) 
    public 
    onlyCompanyMember(_companyAddress, _targetWorker) 
    returns(uint) {
        Place place = places[_place];
        cargos[cargoAmount] = Cargo(cargoAmount, _companyAddress, _name, place);
        cargoAmount = cargoAmount + 1;
        return cargoAmount;
    }

   
    function setCargoToDelivery(address _companyAddress, address _targetWorker, uint _cargoId) 
    public 
    onlyCompanyMember(_companyAddress, _targetWorker) 
    returns(bool) {
        stateInPlace[_cargoId] = cargoState.InDelivery;
    }
    
    function makeCargoDelivered(address _companyAddress, address _targetWorker, uint _cargoId) 
    public 
    onlyCompanyMember(_companyAddress, _targetWorker) 
    returns(bool) {
       stateInPlace[_cargoId] = cargoState.Delivered; 
    }
    
    function addNewCompany(string _name, address _companyAddress) public onlyOwner returns(uint) {
        company[_companyAddress] = Company(companyAmount, _name);
        companyAmount = companyAmount + 1;
        return companyAmount;
    }
    
    
    function getCompany(address _companyAddress) public constant returns(Company) {
        return company[_companyAddress];
    }
    
    
    function getCargo(uint _id) public constant returns(Cargo){
        return cargos[_id];
    }
    
    function isInspector(address _address) public constant returns(bool) {
        return inspectors[_address];
    }
    
    function addInspector(address _address) public onlyOwner returns(bool) {
        inspectors[_address] = true;
    }
    
    function addWorkerToCompany(address _companyAddress, address _workerAddress) public onlyOwner {
        workers[company[_companyAddress].id][_workerAddress] = true;
    }
    
    function isWorkerInCompany(address _companyAddress, address _workerAddress) public onlyOwner constant returns(bool){
        return workers[company[_companyAddress].id][_workerAddress];
    }
}
