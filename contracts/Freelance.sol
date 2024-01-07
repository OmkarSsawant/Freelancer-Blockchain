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

    struct Work{
        bytes16 task;
        uint pay;
    }

    uint immutable private min_budget=0.001 ether;
    uint private total_deposit=0 ether;
    //A mapping having the works associated with project_id
    mapping(uint => Work[]) private work_and_pays;

    //A mapping having the works associated with project_id
    mapping(address => Project[]) private owner_and_projects;


    constructor() {
        
    }

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
        
            owner_and_projects[_owner].push(new_project);
            emit ProjectCreated(_owner,new_project_id);
            _created = true;
    }



        modifier authotizedByDao(address owner) {
               //make oracle or other contract request to check auth  
                _;
        }

    function getTotalDeposit() public view returns (uint _totalDeposit) {
           _totalDeposit = total_deposit; 
    }
}