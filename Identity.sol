
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

contract IdentityManagement{

    address public Admin;  //Declaration of Admin

    struct UserDetail {
        address addr;
        string name;
        string email;
        string password;
        bool loginstatus;
        bool isverified;
    }

    struct File
    {
        string hash;
    }

    struct Share
    {
        address fromsend;
        string hash;
        uint start;  //Start time
    }

    struct Request
    {
        address fromrequest;
        string hash;
    }

    mapping(address => UserDetail) user;   //Mapping of User
    mapping(address => File[]) files;      //Mapping of User Files
    mapping(address => Share[]) shares;    //Mapping of Files Share
    mapping(address => Request[]) requests;  //Mapping of Request For Verification

    //Assigning Admin Address When Contract Is Deploy
    constructor()
    {
        Admin = msg.sender;
    }

    // User Registration Function
    function registerUser( address _address, string memory _name, string memory _email, string memory _password) public returns (bool)
    {
        require(user[_address].addr != msg.sender);
        user[_address].addr = _address;
        user[_address].name = _name;
        user[_address].email = _email;
        user[_address].password = _password;
        user[_address].loginstatus = false;
        user[_address].isverified = false;
        return true;
    }

    // User Login Function
    function loginUser( address _address, string memory _password) public returns (bool)
    {
        require(user[_address].addr == msg.sender);
        if ( keccak256(abi.encodePacked(user[_address].password)) == keccak256(abi.encodePacked(_password)))
        {
            user[_address].loginstatus = true;
            return user[_address].loginstatus;
        }
        else
        {
            return false;
        }
    }

    // Get User Name Function
    function getUserName(address _address) public view returns (string memory)
    {
        require(user[_address].addr == msg.sender);
        string memory _name;
        _name = user[_address].name;
        return _name;
    }

    // Get User Email Function
    function getUserEmail(address _address) public view returns (string memory)
    {
        require(user[_address].addr == msg.sender);
        string memory _email;
        _email = user[_address].email;
        return _email;
    }

    // Get User Verification Status
    function getUserVerificationStatus(address _address) public view returns (bool)
    {
        require(user[_address].addr == msg.sender);
        bool _isverified;
        _isverified = user[_address].isverified;
        return _isverified;
    }

    // User Logout Function
    function logoutUser(address _address) public 
    {
        require(user[_address].addr == msg.sender);
        user[_address].loginstatus = false;
    }

    // Check User Login Status
    function checkIsUserLogged(address _address) public view returns (bool) 
    {
        return (user[_address].loginstatus);
    }

    // Adding Files
    function add(string memory _hash) public
    {
        files[msg.sender].push(File(_hash));
    }

    // Getting Files
    function getFile(uint256 _index) public view returns(string memory)
    {
        File memory file = files[msg.sender][_index];
        return file.hash;
    }

    // Sending Files To Particular Address
    function sendfile(address _tosend, uint256 _index) public
    {
        File memory file = files[msg.sender][_index];
        shares[_tosend].push(Share(msg.sender,file.hash,block.timestamp));
    }

    // Get Length of Files Uploaded
    function getLengthUploadedFile() public view returns (uint256)
    {
        return files[msg.sender].length;
    }

    // Get Length of Files Share
    function getLengthSharedFile() public view returns (uint256)
    {
        return shares[msg.sender].length;
    }

    // Showing Files That is Shared
    function showSharedFiles(uint256 _index) public view returns(string memory)
    {
        Share memory share = shares[msg.sender][_index];
        if(block.timestamp < (share.start + 50))
        {
                return share.hash;
        }
        else
        {
            return "Time to view document is over";
        }
    }

    //Admin Part
    //Request For Verification To Admin
    function requestToAdmin(address _address, string memory _hash) public
    {
        require(user[_address].addr == msg.sender);
        requests[Admin].push(Request(msg.sender,_hash));
    }

    //Showing Requests Of User For Verification To Admin
    function showRequests(uint256 _index) public view returns(address,string memory)
    {
        require(msg.sender==Admin,"You are not Admin, access denied");
        Request memory request = requests[Admin][_index];
        return (request.fromrequest,request.hash);
    }

    //Admin Giving Verified Status To Requested User
    function giveVerification(uint256 _index) public
    {
        require(msg.sender==Admin,"You are not Admin, access denied");
        Request memory request = requests[Admin][_index];
        user[request.fromrequest].isverified = true;
    } 

    // Get Length of Requests
    function getLengthRequests() public view returns (uint256)
    {
        require(msg.sender==Admin,"You are not Admin, access denied");
        return requests[Admin].length;
    } 
}
