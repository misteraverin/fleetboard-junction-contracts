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
    
    // addresses for network
    address public flowerAddress;
    address public medicineAddress;
    address public worker1;
    address public worker2;
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

    function TrackTruck(address _flowerAddress, address _medicineAddress, 
                        address _worker1, address _worker2)
    {
        owner = msg.sender;
        flowerAddress = _flowerAddress;
        medicineAddress = _medicineAddress;
        worker1 = _worker1;
        worker2 = _worker2;
        addNewPlace("Greece");
        addNewPlace("Holland");
        addNewPlace("Germany");
        addNewPlace("Spain");
        addNewCompany("Junction Flowers Inc.", flowerAddress);
        addNewCompany("Johnson & Johnson", medicineAddress);
        addInspector(worker1);
        addInspector(worker2);
        addWorkerToCompany(flowerAddress, worker1);
        addWorkerToCompany(medicineAddress, worker2);
        addNewCargo("Red Tulip", flowerAddress, 1, worker1);
        addNewCargo("Pharmacy", medicineAddress, 2, worker2);
    }

    function addNewPlace(string _name) public onlyOwner returns(uint _value) {
        places[placeAmount] = Place(placeAmount, _name);
        placeAmount = placeAmount + 1;
        return placeAmount;
    }
    
    function getPlaceName(uint _id) public constant returns(string) {
        return places[_id].name;
    }
    
    function addNewCompany(string _name, address _companyAddress) public onlyOwner returns(uint) {
        company[_companyAddress] = Company(companyAmount, _name);
        companyAmount = companyAmount + 1;
        return companyAmount;
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
    
    
    function getCompany(address _companyAddress) public constant returns(uint, string) {
        return (company[_companyAddress].id, company[_companyAddress].name) ;
    }
    
       
    function getCargo(uint _id) public constant 
    returns(uint, address, string, uint, string){
        return (cargos[_id].id, cargos[_id].company, cargos[_id].name, cargos[_id].place.id, cargos[_id].place.name);
    }
    
    
    function addNewCargo(string _name, address _companyAddress, uint _place, address _targetWorker) 
    public 
    onlyCompanyMember(_companyAddress, _targetWorker) 
    constant
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
    
    function getCargoStatus(uint _id) public returns(cargoState) {
        return stateInPlace[_id];
    }
}
