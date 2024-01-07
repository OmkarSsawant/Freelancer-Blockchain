interface IFreelace{
     createProject(
         _owner : string,
         _title:string,
         _initial_bid:bigint,
         _ssrdoc_ipfs:string,
         _project_type:string,
         _deadline:bigint,
         _deposit_budget:bigint
    ) :Promise<boolean>

};