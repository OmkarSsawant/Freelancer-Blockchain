// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "hardhat/console.sol";


contract Freelance {

    event ProjectCreated(address owner,uint project_id);
    event ProjectBidFinalized(address assigned_dev,uint project_id,uint amount);
    event ProjectOwnerRegistered(address owner);
    event EnableProjectChat(address owner,address developer,uint project_id);

    struct Project{
        uint project_id;
        address owner;
        bytes32 title;
        Bid finalized_bid;
        bytes32 ssrdoc_ipfs;
        bytes32 project_type;
        uint deadline;
        //A Bid Above this will not be fullfilled
        uint deposit_budget;
        WorkStatus status;
    }

    enum WorkStatus {
        UN_INIT,
        STARTED,
        IN_PROGRESS,
        COMPLETED
    }

struct Bid {
       uint amount;
       address bidder;
       string proposal;
       bytes32[] attachments; 
}
    struct Work{
        string  task;
        uint pay;
        WorkStatus status;
    }


    struct Developer{
        uint dev_id;
        address dev_address;
        bytes32 name;
        bytes32 profile_photo_ipfs;
        bytes32[] techstack;
        bytes32 profession;
    }

    struct Review{
        uint project_id;
        string review;
    }


    struct ProjectOwner{
        uint owner_id;
        bytes32 name;
        bytes32 email;
        uint phn;
        address  wallet;
        bytes32 licence_doc_ipfs;
        bool verified;
        bytes32 company;
        bytes32 url;
        CompanyType com_type;
        bytes32 profile_photo_ipfs;
    }
    
    enum CompanyType{
        PRIVATE,
        PUBLIC,
        STARTUP,
        UNICORN,
        SMALL_BUSINESS
    }

    uint immutable private min_budget=0.001 ether;
    uint private total_deposit=0 ether;
    address private immutable platform_owner;
    mapping(address => uint[]) private dev_and_projects;
    mapping(address => uint) private dev_and_id;
    mapping(address => Review[]) private dev_project_reviews;
    //A mapping having the works associated with project_id
    mapping(uint => Work[]) private work_and_pays;
    //A mapping having the works associated with project_id
    mapping(address => uint[]) private owner_and_projects;
    mapping(address => uint) private dev_and_bidtokens;

    ProjectOwner[] private project_owners;
    Project[] private projects;
    Developer[] private developers;

    constructor() {
        platform_owner = msg.sender;
    }

    function getName() public pure returns (string memory){
        return "Freelance.sol";
    }
   function idsToProjects(
        uint[] memory ids
    ) internal view returns (Project[] memory){
        Project[] memory _projects = new Project[](ids.length);
        for (uint i = 0; i < ids.length; i++) {
            _projects[i] = projects[ids[i]];
        }
        return _projects;
    }



// About Project Owner

function registerProjectOwner(
        bytes32 _name,
        bytes32 _email,
        uint _phn,
        bytes32 _licence_doc_ipfs,
        bool _verified,
        bytes32 _company,
        bytes32 _url,
        CompanyType _com_type,
        bytes32 _profile_photo_ipfs
)  authorizedByDao(msg.sender) public returns (bool _registered) {
    ProjectOwner memory po ;
    po.owner_id = project_owners.length;
    po.name = _name;
    po.email = _email;
    po.phn = _phn;
    po.wallet = msg.sender;
    po.licence_doc_ipfs = _licence_doc_ipfs;
    po.verified = _verified;
    po.company = _company;
    po.url = _url;
    po.com_type = _com_type;
    po.profile_photo_ipfs = _profile_photo_ipfs;
    project_owners.push(po);
    emit ProjectOwnerRegistered(msg.sender);
    _registered  = true;
}

    function finalizeProjectBid(uint amount,uint project_id,string memory proposal,bytes32[] memory attachments,address developer)
    /*isProjectOwner(project_id)*/
    public returns (bool _finalized)
    {
        Project storage p  = projects[project_id];
        p.finalized_bid = Bid(amount,developer,proposal,attachments);
        emit ProjectBidFinalized(developer, project_id, amount);
        _finalized = true;
    } 

function updateProjectStatus(
    uint project_id
)   public payable returns (bool _updated) {
    //get current project status
    Work[] memory works  = work_and_pays[project_id];
    uint i=0;
    for ( ; i < works.length; i++) {
        if(works[i].status  != WorkStatus.COMPLETED)
            break;
    }
    //pay the developer its part 
    uint amount = works[i].pay;
    address payable assigned_dev = payable(projects[project_id].finalized_bid.bidder);
    (bool success,) = assigned_dev.call{value:amount}(""); 
    require(success,"Payment Failed");
    //update to next stage
    Work storage w = work_and_pays[project_id][i];
    w.status = WorkStatus.COMPLETED;
    _updated=  true;
}

function addReview(uint _project_id,string memory _r)
/*isProjectOwner(_project_id)*/
 public returns (bool _process_completed){    
    address dev_adr = projects[_project_id].finalized_bid.bidder;
    dev_project_reviews[dev_adr].push(Review(_project_id,_r));
    projects[_project_id].status = WorkStatus.COMPLETED;
    dev_and_bidtokens[dev_adr]+=10;
    dev_and_projects[dev_adr].push(_project_id);
    _process_completed = true;
}

//About Project ==================================================
  

        function createProject(
        address _owner,
        bytes32 _title,
        bytes32 _ssrdoc_ipfs,
        bytes32 _project_type,
        uint _deadline,
        uint _deposit_budget
    ) 
    isRegisteredProjectOwner
    payable public returns (bool _created){
            require(msg.value >= min_budget,"Budget is too low");
            require(_ssrdoc_ipfs != "","SSR is required");
            require(_deadline > block.timestamp,"Deadline should be in future");

            uint new_project_id =  owner_and_projects[_owner].length;
            Project memory new_project;
            new_project.project_id=new_project_id;
            new_project.owner=_owner;
            new_project.title=_title;
            new_project.ssrdoc_ipfs=_ssrdoc_ipfs;
            new_project.project_type=_project_type;
            new_project.deadline=_deadline;
            new_project.deposit_budget=_deposit_budget;        
            projects.push(new_project);
            owner_and_projects[_owner].push(new_project_id);
            emit ProjectCreated(_owner,new_project_id);
            total_deposit+=msg.value;
            _created = true;
    }

function addWorksAndPays(uint _project_id,string[] memory _works,uint[] memory _pays) 
/*isProjectOwner(_project_id)*/ public returns (bool) {
    for (uint i = 0; i < _works.length; i++) {
      work_and_pays[_project_id].push(Work(_works[i],_pays[i],WorkStatus.UN_INIT));    
    }
    return true;
}

        modifier authorizedByDao(address owner) {
               //make oracle or other contract request to check auth  
                _;
        }

        modifier isProjectOwner(uint project_id){
            require(projects[project_id].owner == msg.sender);    
            _;
        }

        modifier isRegisteredProjectOwner{
            //check in project owners list
            _;
        }

        modifier onlyOwner{
            require(msg.sender == platform_owner,"Only Platform Owner can Register Developers");
            _;
        }

        modifier onlyDev{
                
            _;
        }

  
 

     function getProjectsOfOwner(
        address _owner
    ) 
    authorizedByDao(_owner) 
    public  view returns (Project[] memory){
        uint[] memory project_ids = owner_and_projects[_owner];
        
        return idsToProjects(project_ids);
    }

    function getProjectStatus(uint project_id) public view returns (WorkStatus) {
          return projects[project_id].status;  
    }


// About Developer ========================================================
    
    function registerDeveloper(
        bytes32 _name,
        bytes32 _profile_photo_ipfs,
        bytes32[] memory _techstack,
        bytes32 _profession
    )
    public returns (bool ){
            Developer memory dev ;
            
            dev.dev_id = developers.length;
            dev.dev_address = msg.sender;
            dev.name = _name;
            dev.profile_photo_ipfs = _profile_photo_ipfs;
            dev.techstack = _techstack;
            dev.profession = _profession;
            developers.push(dev);
            dev_and_id[msg.sender] = dev.dev_id;
            dev_and_bidtokens[msg.sender]  = 50;
            return true;

    }

    //starting the work signifies that dev has signed the agreement
    function signAgreement(uint project_id) public onlyDev returns (bool _success) {
        Project storage p = projects[project_id];
        p.status = WorkStatus.STARTED;
        emit EnableProjectChat(p.owner,msg.sender,project_id);
        _success = true;
    }

     function getProjectsOfDev(
        address _dev
    ) 
    authorizedByDao(_dev) 
    public view returns (Project[] memory){
        uint[] memory project_ids = dev_and_projects[_dev];
        return idsToProjects(project_ids);
    }

     function getCompletedProjectsCountOfDev(
        address _dev
    ) 
    authorizedByDao(_dev) 
    public view returns (uint){
        uint[] memory project_ids = dev_and_projects[_dev];
        return project_ids.length;
    }
    function getTotalDeposit() public view returns (uint _totalDeposit) {
           _totalDeposit = total_deposit; 
    }

    function getDevBidTokens(
        address dev
    ) public view returns (uint){
        return dev_and_bidtokens[dev];
    }
    
 function devPlaceBids(
        address dev,
        uint count
    ) public  returns (bool){
        dev_and_bidtokens[dev]-=count;
        return true;
    }
    
  receive() external payable{}


}