// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;



contract Freelance {

    event ProjectCreated(address owner,uint project_id);
    event ProjectBidFinalized(address assigned_dev,uint project_id,uint amount);

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
        bytes16 task;
        uint pay;
        WorkStatus status;
    }


    struct Developer{
        uint dev_id;
        address dev_address;
        bytes32 name;
        bytes32 profile_photo_ipfs;
        Review[] reviews;
        bytes32[] techstack;
        bytes32 profession;
    }

    struct Review{
        uint project_id;
        string review;
    }

    uint immutable private min_budget=0.001 ether;
    uint private total_deposit=0 ether;
    address private immutable platform_owner;
    mapping(address => uint[]) private dev_and_projects;
    //A mapping having the works associated with project_id
    mapping(uint => Work[]) private work_and_pays;
    //A mapping having the works associated with project_id
    mapping(address => uint[]) private owner_and_projects;
    mapping(address => uint) private dev_and_bidtokens;

    Project[] private projects;
    Developer[] private developers;

    constructor() {
        platform_owner = msg.sender;
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

    function finalizeProjectBid(uint amount,uint project_id,string memory proposal,bytes32[] memory attachments,address developer)
    isProjectOwner(project_id)
    public returns (bool _finalized)
    {
        Project storage p  = projects[project_id];
        p.finalized_bid = Bid(amount,developer,proposal,attachments);
        emit ProjectBidFinalized(developer, project_id, amount);
        _finalized = true;
    } 


//About Project ==================================================
  

        function createProject(
        address _owner,
        bytes32 _title,
        uint _initial_bid,
        bytes32 _ssrdoc_ipfs,
        bytes32 _project_type,
        uint _deadline,
        uint _deposit_budget
    ) 
    authotizedByDao(_owner)
    payable public returns (bool _created){
            require(msg.value >= min_budget,"Budget is too low");
            require(_ssrdoc_ipfs != "","SSR is required");
            require(_deadline > block.timestamp,"Deadline should be in future");

            uint new_project_id =  owner_and_projects[_owner].length+1;
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
            _created = true;
    }



        modifier authotizedByDao(address owner) {
               //make oracle or other contract request to check auth  
                _;
        }

        modifier isProjectOwner(uint project_id){
            require(projects[project_id].owner == msg.sender);    
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
    authotizedByDao(_owner) 
    public  view returns (Project[] memory){
        uint[] memory project_ids = owner_and_projects[_owner];
        return idsToProjects(project_ids);
    }




// About Developer ========================================================
    
    function registerDeveloper(
        address _dev_address,
        bytes32 _name,
        bytes32 _profile_photo_ipfs,
        bytes32[] memory _techstack,
        bytes32 _profession
    )
    public returns (bool _registered){
            Developer memory dev ;
            dev.dev_id = developers.length+1;
            dev.dev_address = _dev_address;
            dev.name = _name;
            dev.profile_photo_ipfs = _profile_photo_ipfs;
            dev.techstack = _techstack;
            dev.profession = _profession;
            developers.push(dev);
            _registered = true;
    }

    //starting the work signifies that dev has signed the agreement
    function signAgreement(uint project_id) public onlyDev returns (bool _success) {
        Project storage p = projects[project_id];
        p.status = WorkStatus.STARTED;
        _success = true;
    }

     function getProjectsOfDev(
        address _dev
    ) 
    authotizedByDao(_dev) 
    public view returns (Project[] memory){
        uint[] memory project_ids = dev_and_projects[_dev];
        return idsToProjects(project_ids);
    }

     function getCompletedProjectsCountOfDev(
        address _dev
    ) 
    authotizedByDao(_dev) 
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
    
}