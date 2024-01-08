// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;



contract Freelance {

    event ProjectCreated(address owner,uint project_id);

    struct Project{
        uint project_id;
        address owner;
        bytes32 title;
        uint initial_bid;
        bytes32 ssrdoc_ipfs;
        bytes32 project_type;
        uint deadline;
        //A Bid Above this will not be fullfilled
        uint deposit_budget;
    }
    enum WorkStatus {
        STARTED,
        IN_PROGRESS,
        COMPLETED
    }

    struct Work{
        bytes16 task;
        uint pay;
        WorkStatus status;
    }


    struct Developer{
        address dev_address;
        bytes32 name;
        bytes32 profile_photo_ipfs;
        Review[] reviews;
        bytes32[] techstack;
        uint bid_tokens;
        bytes32 profession;
    }

    struct Review{
        uint project_id;
        string review;
    }

    uint immutable private min_budget=0.001 ether;
    uint private total_deposit=0 ether;
    //A mapping having the works associated with project_id
    mapping(uint => Work[]) private work_and_pays;

    Project[] private projects;


    constructor() {
        
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


    
//About Project ==================================================
  //A mapping having the works associated with project_id
    mapping(address => uint[]) private owner_and_projects;

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
            Project memory new_project =  Project({
                project_id:new_project_id,
                owner:_owner,
                title:_title,
                initial_bid:_initial_bid,
                ssrdoc_ipfs:_ssrdoc_ipfs,
                project_type:_project_type,
                deadline:_deadline,
                deposit_budget:_deposit_budget}
            );
        
            projects.push(new_project);
            owner_and_projects[_owner].push(new_project_id);
            emit ProjectCreated(_owner,new_project_id);
            _created = true;
    }



        modifier authotizedByDao(address owner) {
               //make oracle or other contract request to check auth  
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
    mapping(address => uint[]) private dev_and_projects;
    
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

    
}