@isTest
private class gl_WorkspaceConnectorController_Test {
	
	 static testMethod void IsPersonAccountEnabled_Test()
	 {
	    String result = gl_WorkspaceConnectorController.IsPersonAccountEnabled(); 
	    System.assert(result!=null);
	 }

     static testMethod void findContactFromCase_Test()
	 {
	    String test_subject = '123test321test';
	    //error leg
	    String result = gl_WorkspaceConnectorController.findContactFromCase('1');
	    System.assert(result == null);
	    
	 	Id [] fixedSearchResults= new Id[2];
	 	//Create Contact test data
	  	Contact con1 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333',Email = 'john.doer@somewhere.com');
	  	insert con1;
		fixedSearchResults[0] = con1.Id;
	  		 
	 	//Create Case test data
	 	Case test_case = new Case(Subject = test_subject, ContactId = con1.Id);
	    insert test_case;
		fixedSearchResults[1] = test_case.Id;
		Test.setFixedSearchResults(fixedSearchResults);
		
	 	result = gl_WorkspaceConnectorController.findContactFromCase(test_case.Id);
	 	System.assert(result!=null);
	 }
    

	static testMethod void findObjectFromANI_Test() 
	{
    	Object result = gl_WorkspaceConnectorController.findObjectFromANI('5555555555');
		System.assert(result == 'not found');
		
		/* From Salesforce documentation: Adding SOSL Queries to Unit Tests
		To ensure that test methods always behave in a predictable way, any Salesforce Object Search Language (SOSL) query that is 
		added to an Apex test method returns an empty set of search results when the test method executes.
		Need to use setFixedSearchResults to set the results.		
		*/    
		//Create Account test data
        Account acc = new Account(Name = 'testAccount',Phone = '5555555555'); 
        insert acc;
       
        Id [] fixedSearchResultsACC= new Id[1];
  		fixedSearchResultsACC[0] = acc.Id;
  		Test.setFixedSearchResults(fixedSearchResultsACC);
    	result = gl_WorkspaceConnectorController.findObjectFromANI('5555555555');
    	System.assert(result!=null);
    	
		//Create Contact test data
  		Contact con1 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333',Email = 'john.doer@somewhere.com');
  		insert con1;
  		
  		Id [] fixedSearchResults= new Id[1];
  		fixedSearchResults[0] = con1.Id;
  		Test.setFixedSearchResults(fixedSearchResults);
  		result = gl_WorkspaceConnectorController.findObjectFromANI('4444444444');       
        System.assert(result!=null);  
        
        //Create Lead test data
  		Lead lead = new Lead(FirstName = 'John', LastName = 'Doer', Phone = '2424242424', Company = 'ABC');
  		insert lead;
  		Id [] fixedSearchResultsLead= new Id[1];
  		fixedSearchResultsLead[0] = lead.Id;
  		Test.setFixedSearchResults(fixedSearchResultsLead);
  		result = gl_WorkspaceConnectorController.findObjectFromANI('2424242424');       
        System.assert(result!=null); 
	}


	static testMethod void findObjectFromANIByType_Test() 
	{
    	Object result = gl_WorkspaceConnectorController.findObjectFromANI('5555555555');
		System.assert(result == 'not found');		
  
		//Create Account test data
        Account acc = new Account(Name = 'testAccount',Phone = '5555555555'); 
        insert acc;
        Id [] fixedSearchResultsACC= new Id[1];
  		fixedSearchResultsACC[0] = acc.Id;
  		Test.setFixedSearchResults(fixedSearchResultsACC);
    	result = gl_WorkspaceConnectorController.findObjectFromANIByType('5555555555', 'account');
    	System.assert(result!=null);  
    	
    	result = gl_WorkspaceConnectorController.findObjectFromANIByType('5555555555', 'personaccount');
    	System.assert(result!=null);  
	}
    
	static testMethod void findContactFromANI_Test() 
	{
         Object id;
        //error
        id = gl_WorkspaceConnectorController.findContactFromANI('');
        System.assert(id == null);
        
        id = gl_WorkspaceConnectorController.findContactFromANI('4444444444');
        System.assert(id == 'not found');
        
        Id [] fixedSearchResults = new Id[2];
        //Create Contact test data
        Contact con1 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333');
		insert con1;
		fixedSearchResults[0] = con1.Id;
				
        Contact con2 = new Contact(FirstName = 'Jane', LastName = 'Doer', Phone = '4444444444');
    	insert con2;
		fixedSearchResults[1] = con2.Id;

		Test.setFixedSearchResults(fixedSearchResults);
    	String test_phone = '4444444444';
         
        id = gl_WorkspaceConnectorController.findContactFromANI(test_phone);
        System.assert(id == 'multiple found');
	}  


	static testMethod void findContactFromEmailAddress_Test() 
	{
         Object id;
        //error
        id = gl_WorkspaceConnectorController.findContactFromEmailAddress('john.doer@somewhere.com');
        System.assert(id == null);
         
        Id [] fixedSearchResults = new Id[1];       
        //Create Contact test data
        Contact con1 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333',Email = 'john.doer@somewhere.com');
        insert con1;
        fixedSearchResults[0] = con1.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        id = gl_WorkspaceConnectorController.findContactFromEmailAddress('john.doer@somewhere.com');
        System.assert(id != null);             
	}


	static testMethod void findContactFromChatAddress_Test() 
	{
        Object id;
        //error
        id = gl_WorkspaceConnectorController.findContactFromChatAddress('John Doer');
        System.assert(id == null);
                 
        Id [] fixedSearchResults = new Id[1];       
        //Create Contact test data
        Contact con1 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333',Email = 'john.doer@somewhere.com');
        insert con1;
        fixedSearchResults[0] = con1.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        id = gl_WorkspaceConnectorController.findContactFromChatAddress('John Doer');
        System.assert(id != null);         
	}

	static testMethod void findContactFromWorkItemAddress_Test() 
	{
        Object id;
        //error
        id = gl_WorkspaceConnectorController.findContactFromWorkItemAddress('John Doe');
        System.assert(id == null);
                 
        Id [] fixedSearchResults = new Id[1];       
        //Create Contact test data
        Contact con1 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333',Email = 'john.doer@somewhere.com');
        insert con1;
        fixedSearchResults[0] = con1.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        id = gl_WorkspaceConnectorController.findContactFromWorkItemAddress('John Doer');
        System.assert(id != null);        
	}
    
    static testMethod void findContactFromOpenMediaAddress_Test() 
    {
         Object id;
        //error
        id = gl_WorkspaceConnectorController.findContactFromOpenMediaAddress('John Doe');
        System.assert(id == null);
                 
        Id [] fixedSearchResults = new Id[1];       
        //Create Contact test data
        Contact con1 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333',Email = 'john.doer@somewhere.com');
        insert con1;
        fixedSearchResults[0] = con1.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        id = gl_WorkspaceConnectorController.findContactFromOpenMediaAddress('John Doer');
        System.assert(id != null);  
	}    


	/*static testMethod void createCase_Test() 
	{
        Map<String,String> fieldsMap = new Map<String,String>();
        //create map  
        fieldsMap.put('IXN Type','Call');
    	fieldsMap.put('Media Type','');
    	fieldsMap.put('DATE','June1');
    	String result = gl_WorkspaceConnectorController.createCase(fieldsMap);
        System.assert(result != 'case not created');
	}*/

	static testMethod void createCase_Test() 
	{
        Map<String,String> fieldsMap = new Map<String,String>();
        //create map  
        // fieldsMap.put('IXN Type','Call');
    	// fieldsMap.put('Media Type','');
		// fieldsMap.put('DATE','June1');
		//bp
		fieldsMap.put('Type','Inquiry');
		fieldsMap.put('Description','Inquiry');
		fieldsMap.put('Origin','Chat');
		fieldsMap.put('Status','Closed');
		fieldsMap.put('Priority','Medium');

    	String result = gl_WorkspaceConnectorController.createCase(fieldsMap,'');
		//System.assert(result != 'case not created');
		
		fieldsMap.put('RecordTypeId','Tech Support');
		
		result = gl_WorkspaceConnectorController.createCase(fieldsMap,'');
		//System.assert(result != 'case not created');

	}
	

	static testMethod void findAccountFromOpenMediaAddress_Test()
	{
		Account acc = new Account(Name = 'testAccount',Phone = '7654321765'); 
        insert acc;
        Object result = gl_WorkspaceConnectorController.findAccountFromOpenMediaAddress('testAccount', 'account');
    	System.assert(result!=null);    
	}
    
	static testMethod void createActivity_Test() 
	{
        String ID = '';
        Map<String,String> fieldsMap = new Map<String,String>();
        //create map
        fieldsMap.put('Genesys Call Type','Inbound');
        fieldsMap.put('LOOKUP','4444444444');
        fieldsMap.put('Call Duration','35');
        fieldsMap.put('DATE','June1');
        fieldsMap.put('Comments','');
        fieldsMap.put('ANI','4444444444');
    	fieldsMap.put('IXN Type','Phone');
        fieldsMap.put('Media Type','');
        fieldsMap.put('sfdc Object Id',ID);
		
		Map<String,String> defaultValues = new Map<String,String>();
		defaultValues.put('Type','Test');
		defaultValues.put('ActivityDate','06/24/2020');
    	//Activity created as orhpan
        String noIDResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account',defaultValues);
        System.assert(noIDResult != null);
    
        //Create Account test data
        Account acc = new Account(Name = 'testAccount',Phone = '7654321765'); 
        insert acc;

        //Create Contact test data
        Contact con = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333',Email = 'john.doer@somewhere.com');
        con.AccountId = acc.Id;  //account id
        insert con;
    	
    	//Activity created under Contact using search
    	String contactResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account',defaultValues);
        System.assert(contactResult != null);

    	fieldsMap.put('IXN Type','Email');
    	fieldsMap.put('LOOKUP','john.doer@somewhere.com');
        contactResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account',defaultValues);
        System.assert(contactResult != null);

    	fieldsMap.put('IXN Type','Chat');
    	fieldsMap.put('LOOKUP','John Doer');
        contactResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account',defaultValues);
        System.assert(contactResult != null); 
        
    	fieldsMap.put('IXN Type','OpenMedia');
    	fieldsMap.put('LOOKUP','John Doer');
        contactResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account',defaultValues);
        System.assert(contactResult != null);        
    
    	//Activity created under Contact using ID
        ID = con.Id;
    	System.Debug('sfdc Object Id = '+ID);
        fieldsMap.put('sfdc Object Id',ID);
    	fieldsMap.put('SFDC1field','Description');
    	fieldsMap.put('SFDC1value','Test1');
        fieldsMap.put('SFDC2field','Description');
    	fieldsMap.put('SFDC2value','Test2');
        fieldsMap.put('SFDC3field','Description');
    	fieldsMap.put('SFDC3value','Test3');
    	fieldsMap.put('SFDC4field','Description');
    	fieldsMap.put('SFDC4value','Test4');
    	fieldsMap.put('SFDC5field','Description');
    	fieldsMap.put('SFDC5value','Test5');    
        contactResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account',null);
        System.assert(contactResult != null);
	} 
	
	
	
	static testMethod void findActivity_Test() 
	{
		String connID = '12345abc123';		
		String ID = '';
        Map<String,String> fieldsMap = new Map<String,String>();
        //create map
        fieldsMap.put('Genesys Call Type','Inbound');
        fieldsMap.put('LOOKUP','4444444444');
        fieldsMap.put('Call Duration','35');
        fieldsMap.put('DATE','June1');
        fieldsMap.put('Comments','');
        fieldsMap.put('ANI','4444444444');
    	fieldsMap.put('IXN Type','Phone');
        fieldsMap.put('Media Type','');
        fieldsMap.put('sfdc Object Id',ID);
        fieldsMap.put('GenesysId',connID);
        
    	//Activity created as orhpan
        String noIDResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account',null);
        System.assert(noIDResult != null);		
		
		String result = gl_WorkspaceConnectorController.findActivity(connID);
		System.assert(result != null);	
		result = gl_WorkspaceConnectorController.getActivityComments(connID);
        System.assert(result != null);  
		
		
	}
	
	static testMethod void updateActivity_Test() 
	{
		String connID = '12345abc123';		
		String ID = '';
        Map<String,String> fieldsMap = new Map<String,String>();
        //create map
        fieldsMap.put('Genesys Call Type','Inbound');
        fieldsMap.put('LOOKUP','4444444444');
        fieldsMap.put('Call Duration','35');
        fieldsMap.put('DATE','June1');
        fieldsMap.put('Comments','');
        fieldsMap.put('ANI','4444444444');
    	fieldsMap.put('IXN Type','Phone');
        fieldsMap.put('Media Type','');
        fieldsMap.put('sfdc Object Id',ID);
        fieldsMap.put('GenesysId',connID);
        
    	//Activity created as orhpan
        String noIDResult = gl_WorkspaceConnectorController.createActivity(fieldsMap, 'account',null);
        System.assert(noIDResult != null);		
		
		String taskId = gl_WorkspaceConnectorController.findActivity(connID);
		System.assert(taskId != null);	
		
		fieldsMap.put('Comments','updated comment');
		
		String updateResult = gl_WorkspaceConnectorController.updateActivity(taskId, fieldsMap,null);
		System.assert(updateResult == 'success');	
	}
	

	static testMethod void addAttachment_Test()
	{
	    Task t = new Task (
	          Type = 'Call',
	          Status = 'Completed',
	          Subject = 'Testttt',
	          Priority = 'Normal',
	          ActivityDate = System.today()
	        );
        insert t;
        String blobString= 'This is a string';
     	Blob b = Blob.valueOf(blobString);
        String result = gl_WorkspaceConnectorController.addAttachment(t.Id,'Test Description','TestName1','txt',b,null);
	    System.assert(result != 'error');
	}
	

	static testMethod void testConnection_Test()
	{
		Object result = gl_WorkspaceConnectorController.testConnection();
		system.assert(true);
	}
	
	
	static testMethod void findCaseObject_Test() 
	{
		Id [] fixedSearchResults = new Id[4];
		
		Account acc = new Account(Name = 'testAccount',Phone = '5555555555'); 
        insert acc;
        fixedSearchResults[0] = acc.Id;
	
		Contact con = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333', Email = 'john.doer@somewhere.com');
		con.AccountId = acc.Id;  //account id 
		insert con; 
		fixedSearchResults[1] = con.Id;
		
		Case test_case1 = new Case(Subject = 'test_subject1', AccountID = acc.Id, ContactId = con.Id);
		insert test_case1;
		fixedSearchResults[2] = test_case1.Id;
		
		Case test_case2 = new Case(Subject = 'test_subject2', AccountID = acc.Id, ContactId = con.Id);
		insert test_case2;
		fixedSearchResults[3] = test_case2.Id; 
		
		Test.setFixedSearchResults(fixedSearchResults);
		   			
		Object result = gl_WorkspaceConnectorController.findCaseObject('Subject','test_subject2');
		Object result2 = gl_WorkspaceConnectorController.findCaseObject('Contact.FirstName','John');
		System.assert(result != null);
		
	}
	
	
	static testMethod void findCaseObjectMapSearch_Test() 
	{
		Id [] fixedSearchResults = new Id[4];
		
		Account acc = new Account(Name = 'testAccount',Phone = '5555555555'); 
        insert acc;
        fixedSearchResults[0] = acc.Id;
	
		Contact con = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333', Email = 'john.doer@somewhere.com');
		con.AccountId = acc.Id;  //account id 
		insert con; 
		fixedSearchResults[1] = con.Id;
		
		Case test_case1 = new Case(Subject = 'test_subject1', AccountID = acc.Id, ContactId = con.Id);
		insert test_case1;
		fixedSearchResults[2] = test_case1.Id;
		
		Case test_case2 = new Case(Subject = 'test_subject2', AccountID = acc.Id, ContactId = con.Id);
		insert test_case2;
		fixedSearchResults[3] = test_case2.Id; 
		
		Test.setFixedSearchResults(fixedSearchResults);   			
		
		Boolean searchAllFields = true;
		List<String> sfdcFields = new List<string>();
		// sfdcFields.add('Subject');
		// sfdcFields.add('test_subject2');
		
		// List<String> sfdcValues = new List<string>();
		// sfdcValues.add('SubjectValue');
		// sfdcValues.add('test_subject2Value');

		// EASFP-46: Fixed test data
		sfdcFields.add('Name');
		sfdcFields.add('Subject');					    
		// EASFP-46: Fixed test data
		List<String> sfdcValues = new List<string>();
		sfdcValues.add('testAccount');
		sfdcValues.add('test_subject1');
		
		Object result = gl_WorkspaceConnectorController.findObjectMapSearch(sfdcFields,sfdcValues, searchAllFields);
		System.assert(result!=null);
		Object result2 = gl_WorkspaceConnectorController.findGenericObject('[acc.Phone]','[5555555555]');
        System.assert(result2!=null);  
        Object result3 = gl_WorkspaceConnectorController.findCaseObjectMapSearch(sfdcFields,sfdcValues, searchAllFields);
		System.assert(result3!=null); //EASFP-46: findCaseObjectMapSearch now returns a value
		Object result4 = gl_WorkspaceConnectorController.findGenericObject('[opportunity.id]','[0060K00000WBL6ZQAX]');
        System.assert(result4!=null); 
	}

	static testMethod void findObject_Test() 
	{    			
		Object result = gl_WorkspaceConnectorController.findObject('Phone','5555555555');
		System.assert(result != null);
	
		/* From Salesforce documentation: Adding SOSL Queries to Unit Tests
		To ensure that test methods always behave in a predictable way, any Salesforce Object Search Language (SOSL) query that is 
		added to an Apex test method returns an empty set of search results when the test method executes.
		Need to use setFixedSearchResults to set the results.		
		*/
		Id [] fixedSearchResults = new Id[5];
		//Create Account test data
        Account acc = new Account(Name = 'testAccount',Phone = '5555555555'); 
        insert acc;
  		fixedSearchResults[0] = acc.Id;
  		
    	//Create Contact test data
  		Contact con = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333',Email = 'john.doer@somewhere.com');
  		insert con;
  		fixedSearchResults[1] = con.Id;  
 
        //Create Lead test data
  		Lead lead = new Lead(FirstName = 'John', LastName = 'Doer', Phone = '2424242424', Company = 'ABC');
  		insert lead;
  		fixedSearchResults[2] = lead.Id;

		Case test_case1 = new Case(Subject = 'test_subject1', AccountID = acc.Id, ContactId = con.Id);
		insert test_case1;
		fixedSearchResults[3] = test_case1.Id;
		
		Case test_case2 = new Case(Subject = 'test_subject2', AccountID = acc.Id, ContactId = con.Id);
		insert test_case2;
		fixedSearchResults[4] = test_case2.Id; 
		
		Test.setFixedSearchResults(fixedSearchResults);
		
		result = gl_WorkspaceConnectorController.findObject('Phone','4444444444');       
        System.assert(result!=null);
        
        result = gl_WorkspaceConnectorController.findObject('Phone','2424242424');       
        System.assert(result!=null);
          	
  		result = gl_WorkspaceConnectorController.findCaseObject('Subject', 'test_subject2');       
        System.assert(result!=null);
	}
	
	static testMethod void findObjectMapSearch_Test() 
	{    
		Boolean searchAllFields = true;
		List<String> sfdcFields = new List<string>();
		sfdcFields.add('Name');
		sfdcFields.add('Phone');
		sfdcFields.add('FirstName');
		

		List<String> sfdcValues = new List<string>();
		sfdcValues.add('John Doer');
		sfdcValues.add('5555555555');
		sfdcValues.add('Jack');               
 
 		Id [] fixedSearchResults= new Id[3];        
        Account acc1 = new Account(Name = 'testAccount',Phone = '5555555555'); 
        insert acc1;  
  		fixedSearchResults[0] = acc1.Id;
        
        Contact con1 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333',Email = 'john.doer@somewhere.com');
  		insert con1;
  		fixedSearchResults[1] = con1.Id;
  		
		Lead l1= new Lead(FirstName = 'Jack', LastName = 'Black', Email = 'test1@gmail.com', Company = 'ABC',  Phone = '9876987698');
		insert l1;
  		fixedSearchResults[2] = l1.Id;
  		
  		Test.setFixedSearchResults(fixedSearchResults);
  		
		Object result = gl_WorkspaceConnectorController.findObjectMapSearch(sfdcFields, sfdcValues, searchAllFields);
		System.assert(result!=null);
		
		result = gl_WorkspaceConnectorController.findObjectMapSearch(sfdcFields, sfdcValues, false);
		System.assert(result!=null);		
		
	}

	static testMethod void findObjectByType_Test() 
	{
		//Create Account test data
        Id [] fixedSearchResults= new Id[4];
		Account acc0 = new Account(Name = 'test Account0', Phone = '8888888888'); 
		insert acc0;		
        fixedSearchResults[0] = acc0.Id;    
		
		Account acc1 = new Account(Name = 'test Account1', Phone = '2222222222'); 
		insert acc1;
		fixedSearchResults[1] = acc1.Id;    
		
		Account acc2 = new Account(Name = 'test Account2', Phone = '3333333333'); 
		insert acc2;
		fixedSearchResults[2] = acc2.Id;  
        Test.setFixedSearchResults(fixedSearchResults);

    	Object result = gl_WorkspaceConnectorController.findObjectByType('Phone','8888888888', 'account');
    	System.assert(result!=null);   
    	
    	Contact con1 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333',Email = 'john.doer@somewhere.com');
  		insert con1;
  		fixedSearchResults[3] = con1.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        result = gl_WorkspaceConnectorController.findObjectByType('Phone','4444444444', 'contact');
	}
	
	//EASFP-46: Add test case for non person account	
	static testMethod void findObjectByTypeNPA_Test() 
	{
		//Create Account test data
        Id [] fixedSearchResults= new Id[4];
		Account acc0 = new Account(Name = 'test Account0', Phone = '8888888888'); 
		insert acc0;		
        fixedSearchResults[0] = acc0.Id;    
		
		Account acc1 = new Account(Name = 'test Account1', Phone = '2222222222'); 
		insert acc1;
		fixedSearchResults[1] = acc1.Id;    
		
		Account acc2 = new Account(Name = 'test Account2', Phone = '3333333333'); 
		insert acc2;
		fixedSearchResults[2] = acc2.Id;  
        Test.setFixedSearchResults(fixedSearchResults);
        
        // force personAccountsEnabled = false    
        gl_WorkspaceConnectorController.personAccountsEnabled = false;

    	Object result = gl_WorkspaceConnectorController.findObjectByType('Phone','8888888888', 'account');
    	System.assert(result!=null);   
    	
    	Contact con1 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333',Email = 'john.doer@somewhere.com');
  		insert con1;
  		fixedSearchResults[3] = con1.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        result = gl_WorkspaceConnectorController.findObjectByType('Phone','4444444444', 'contact');
	}


	static testMethod void findObjectByTypeMapSearch_Test() 
	{    
		Boolean searchAllFields = true;
		// Create lists
		List<String> sfdcFields = new List<string>();
        sfdcFields.add('Name');
		sfdcFields.add('test Account2');
		
		List<String> sfdcValues = new List<string>();
        sfdcValues.add('Phone');
		sfdcValues.add('8888888888');       
 		
 		Id [] fixedSearchResults= new Id[3];
		Account acc0 = new Account(Name = 'test Account0', Phone = '8888888888'); 
		insert acc0;		
        fixedSearchResults[0] = acc0.Id;    
		
		Account acc1 = new Account(Name = 'test Account1', Phone = '2222222222'); 
		insert acc1;
		fixedSearchResults[1] = acc1.Id;    
		
		Account acc2 = new Account(Name = 'test Account2', Phone = '3333333333'); 
		insert acc2;
		fixedSearchResults[2] = acc2.Id;  

		//EASFP-46: Create Contact test data
		Contact con = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '8888888888', MobilePhone = '3333333333',Email = 'john.doer@somewhere.com');
		insert con;
		fixedSearchResults[1] = con.Id; 

		Test.setFixedSearchResults(fixedSearchResults);
		
		Object result = gl_WorkspaceConnectorController.findObjectByTypeMapSearch(sfdcFields, sfdcValues, searchAllFields, 'account');
		System.assert(result!=null);

		//EASFP-46: Search by Contact
		Object result2 = gl_WorkspaceConnectorController.findObjectByTypeMapSearch(sfdcFields, sfdcValues, searchAllFields, 'contact');
		System.assert(result2!=null);

	}
	
	//EASFP-46 Add test for getRecords
	static testMethod void getRecords_Test() 
	{    
		
		Id [] fixedSearchResults = new Id[1];
		//Create Account test data
		Account acc0 = new Account(Name = 'test Account0', Phone = '8888888888'); 
		insert acc0;		
		fixedSearchResults[0] = acc0.Id;  
		
		Test.setFixedSearchResults(fixedSearchResults);
		
		Object result = gl_WorkspaceConnectorController.getRecords(acc0.Id, 'Name,Phone');
		System.assert(result!=null);
	}

	//EASFP-46 Add test for findGenericObjectMapSearch
	static testMethod void findGenericObjectMapSearch_Test() 
	{    
		Boolean searchAllFields = false;
		// Create lists
		List<String> sfdcFields = new List<string>();
        sfdcFields.add('account.phone');
		
		List<String> sfdcValues = new List<string>();
		sfdcValues.add('8888888888');       
 		
 		Id [] fixedSearchResults= new Id[3];
		Account acc0 = new Account(Name = 'test Account0', Phone = '8888888888'); 
		insert acc0;		
        fixedSearchResults[0] = acc0.Id;    
		
		Account acc1 = new Account(Name = 'test Account1', Phone = '2222222222'); 
		insert acc1;
		fixedSearchResults[1] = acc1.Id;    
		
		Account acc2 = new Account(Name = 'test Account2', Phone = '3333333333'); 
		insert acc2;
		fixedSearchResults[2] = acc2.Id;  
		Test.setFixedSearchResults(fixedSearchResults);
		
		Object result = gl_WorkspaceConnectorController.findGenericObjectMapSearch(sfdcFields, sfdcValues, searchAllFields);
		System.assert(result!=null);
	}

}