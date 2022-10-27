/**
* Launch a message from faul flow
* 
* @param  	Obj  Object from flow
* @return 	null
* @Author 	NTT Data
*/
global without sharing class ALK_Launch_ErrorFault {
    
    @InvocableMethod(label='LaunchErrorFault' description='Launch a message from faul flow.' category='Apex')
    public static void execute (List<Requests> requestList) {
        
        Boolean getFlag = requestList[0].flag;
        Assert.areEqual(true, getFlag , 'Lanzar Error');
 
    }
    
    global class Requests {
        @InvocableVariable(label='Flag for Input' description='Boolean' required=true)
        public Boolean flag;
    }
}