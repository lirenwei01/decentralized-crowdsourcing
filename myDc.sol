contract myDC{
    
    enum UserState {Offline, Online, Busy, Waiting}//用户状态

    struct User{//用户信息
        bool registered;
        uint index;
        UserState state;
        string pubkey;
        string tasknow;
        string result;
        uint credit;
    }
    mapping(address => User) public UserPool;//用户与地址的映射
    
    enum ProjectState {enrolling,working,end}
    struct Project{
        ProjectState state;
        uint index;
        uint workernum;
        address publisher;
        address[] enrollers;
        address[] workers;
        uint ReqBlockNum;
        uint workersend;
        uint creditneed;
    }
    Project[] ProjectPool;
    
    address[] public UserAddrs;
    
    modifier checkRegistered(address _normalUser){
		require(!UserPool[_normalUser].registered,"Have registered!");
		_;
	}
	
	modifier checkUser(address _normalUser){
		require(UserPool[_normalUser].registered,"Not registered!");
		_;
	}
	
	modifier checkOnline(address _normalUser){
		require(UserPool[_normalUser].state == UserState.Online,"Not online!");
		_;
	}
	
	modifier checkEnrolled(address _normalUser,Project memory  _Pro){
	    uint i = 0;
	    for(uint j = 0;j < _Pro.enrollers.length;j ++){
	        if(_Pro.enrollers[j] == msg.sender)i = 1;
	    }
	    require(i == 0,"Have Enrolled!");
	    _;
	}

    modifier checkWorker(address _normalUser,Project memory  _Pro){
	    uint i = 0;
	    for(uint j = 0;j < _Pro.enrollers.length;j ++){
	        if(_Pro.workers[j] == msg.sender)i = 1;
	    }
	    require(i == 1,"You Are Not a Worker!");
	    _;
	}

    modifier checkEnrolling(Project memory _Pro){
        require (_Pro.state == ProjectState.enrolling,"NOT ENROLLING");
        _;
    }
	
    function UserRegister(string memory pubk)
        public
        checkRegistered(msg.sender)
    {
        UserAddrs.push(msg.sender);
        UserPool[msg.sender].index = UserAddrs.length - 1;
        UserPool[msg.sender].state = UserState.Offline;
        UserPool[msg.sender].registered = true;
        UserPool[msg.sender].pubkey = pubk;
        UserPool[msg.sender].credit = 100;
    }
    
    function UserPrint()
        public
        view
        returns
        (address[] memory)
    {
        return UserAddrs;
    }
    
    function UserUpline()
        public
        checkUser(msg.sender)
    {
        UserPool[msg.sender].state = UserState.Online;  
    }
    
    function UserDownline()
        public
        checkUser(msg.sender)
    {
        UserPool[msg.sender].state = UserState.Offline;  
    }
    
    function Publish(uint workersneed,uint creditneed)
        public
        checkUser(msg.sender)
    {
        Project memory P;
        P.index = ProjectPool.length;
        P.state = ProjectState.enrolling;
        P.publisher = msg.sender;
        P.workernum = workersneed;
        P.ReqBlockNum = block.number;
        P.creditneed = creditneed;
        ProjectPool.push(P);
    }
    
    function ProjectsPrint()
        public
        view
        returns
        (Project[] memory)
    {
        return ProjectPool;
    }
    
    function enroll(uint PIndex)
        public
        checkOnline(msg.sender)
        checkEnrolled(msg.sender,ProjectPool[PIndex])
        checkEnrolling(ProjectPool[PIndex])
    {
        require(UserPool[msg.sender].credit >= ProjectPool[PIndex].creditneed,"credit not enough!");
        ProjectPool[PIndex].enrollers.push(msg.sender);
    }
    
    function PrintEnrollers(uint PIndex)
        public
        view
        returns
        (address[] memory)
    {
        return ProjectPool[PIndex].enrollers;
    }
    
    event WorkerSelected(address indexed _who, uint _proindex,uint _windex);
    
    function sortition(uint ProIndex)
        public
    {
        
        require(ProjectPool[ProIndex].publisher == msg.sender,"YOU ARE NOT PUBLISHER!");
        require(ProjectPool[ProIndex].ReqBlockNum != 0,"NO");
        require(ProjectPool[ProIndex].enrollers.length >= ProjectPool[ProIndex].workernum,"NO ENOUGH ENROLLERS");
        require( block.number < ProjectPool[ProIndex].ReqBlockNum + 255,"TOO MANY BLOCKS");
        require( block.number > ProjectPool[ProIndex].ReqBlockNum + 2*2 ,"NO ENOUGH BLOCKS");
        uint seed = 0;
        for(uint bi = 0 ; bi < 2 ; bi++)
            seed += (uint)(blockhash(ProjectPool[ProIndex].ReqBlockNum + bi + 1 ));
        
        uint wcounter = 0;
        uint _N = ProjectPool[ProIndex].workernum;
        while(wcounter < _N){
            address sAddr = ProjectPool[ProIndex].enrollers[seed % ProjectPool[ProIndex].enrollers.length];
            
            if(UserPool[sAddr].state == UserState.Online)
            {
                UserPool[sAddr].state = UserState.Busy;
                ProjectPool[ProIndex].workers.push(sAddr);
                emit WorkerSelected(msg.sender, wcounter , ProIndex);
                wcounter++;
            }
            
            seed = uint(keccak256(abi.encodePacked(seed)));
        }
        ProjectPool[ProIndex].state = ProjectState.working;
        ProjectPool[ProIndex].workersend = 0;
        
    }
    
    function printsortition(uint ProIndex)
        public
        view
        returns
        (address[] memory)
    {
        return ProjectPool[ProIndex].workers;
    }
    
    function printblock()
        public
        view
        returns
        (uint,bytes32)
    {
        return (block.number,blockhash(block.number-1));
    }

    function getPubkey(uint Pro,uint worker)
        public
        view
        returns
        ( string memory)
    {
        return UserPool[ProjectPool[Pro].workers[worker]].pubkey;
    }

    function taskAssign(uint ProIndex,uint worker,string memory secTask)
        public
    {
        require(ProjectPool[ProIndex].publisher == msg.sender,"YOU ARE NOT PUBLISHER!");
        UserPool[ProjectPool[ProIndex].workers[worker]].tasknow = secTask;
    }
    
    function Submit(uint ProIndex, string memory res)
        public
    {
        
        UserPool[msg.sender].result = res;
        ProjectPool[ProIndex].workersend += 1;
    }

    event getres(string res);

    function CheckResults(uint ProIndex)
        public
        
    {
        require(ProjectPool[ProIndex].publisher == msg.sender,"YOU ARE NOT PUBLISHER!");
        require(ProjectPool[ProIndex].workernum == ProjectPool[ProIndex].workersend,"Not End!");
        
        for(uint i = 0; i < ProjectPool[ProIndex].workernum;i ++)
            emit getres(UserPool[ProjectPool[ProIndex].workers[i]].result);
       
    }

    function EndProject(uint ProIndex)
        public
    {
        require(ProjectPool[ProIndex].publisher == msg.sender,"YOU ARE NOT PUBLISHER!");
        require(ProjectPool[ProIndex].workernum == ProjectPool[ProIndex].workersend,"Not End!");
        ProjectPool[ProIndex].state = ProjectState.end;
        for(uint i = 0; i < ProjectPool[ProIndex].workersend ;i ++){
            UserPool[ProjectPool[ProIndex].workers[i]].state = UserState.Online;
            UserPool[ProjectPool[ProIndex].workers[i]].credit += 5;
        }
        UserPool[msg.sender].credit += 10;
    }   

    function CheckCre()
        public
        view
        returns
        (uint)
    {
        return UserPool[msg.sender].credit;
    }
}
