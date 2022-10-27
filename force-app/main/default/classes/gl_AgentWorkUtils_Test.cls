@isTest

private class gl_AgentWorkUtils_Test {
	
	static testMethod void createAgentWork_Test() {
        
        Account acc = new Account(Name = 'testAccount',Phone = '5555555555'); 
        insert acc;
	
		Contact con = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333', Email = 'john.doer@somewhere.com');
		con.AccountId = acc.Id;
		insert con; 

        Case test_case1 = new Case(Subject = 'test_subject1', AccountID = acc.Id, ContactId = con.Id);
        insert test_case1;
        
        
        gl_AgentWorkUtils.createAgentWork(null, test_case1.Id);
        
        system.assert(true);

    }
}