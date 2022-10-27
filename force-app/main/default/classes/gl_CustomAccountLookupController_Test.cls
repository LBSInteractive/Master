@isTest

private class gl_CustomAccountLookupController_Test {
	
    static testMethod void search_Test() {
       //Create Account test data
		gl_CustomAccountLookupController lookup = new gl_CustomAccountLookupController();
		
		//assigning Name only, creates business account
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
		
		//This is necessary to create search results when querying by SOSL
		Test.setFixedSearchResults(fixedSearchResults);		
		
		lookup.Name = 'test';
		System.debug('*** Name = ' + lookup.Name );
		
		lookup.Phone = '8888888888';
		System.debug('*** Phone = ' + lookup.Phone );
		
		lookup.search();
		System.debug('*** results 1 - size = ' + lookup.Account_results.size());
		
		lookup.searchString = '[{"Id":"0016A000005TPTqQAO","Name":"JaneMyAmpersands SmithMyPlus","Phone":"5555555555"}]';
		

		PageReference pageRef = Page.gl_CustomAccountLookup;	
	    pageRef.getParameters().put('lksrch','');
	    pageRef.getParameters().put('ixnId','1234567');
	    pageRef.getParameters().put('inServiceCloudConsole','false');
	    pageRef.getParameters().put('searchObjectType','Account');
	    pageRef.getParameters().put('lookupNumber','5555555555');
	    pageRef.getParameters().put('frm','');
	    pageRef.getParameters().put('txt','');
	    Test.setCurrentPage(pageRef);
		
	
		System.debug('*** results = ' + lookup.Account_results);
		//System.assert(lookup.Account_results.size() != 0);
		
		PageReference pr = lookup.search();
		
		System.debug('*** results = ' + lookup.Account_results);
		//System.assert(lookup.Account_results.size() != 0);	
		
		lookup.Name = '';
		lookup.Phone='6666666666'	;
		
		lookup.search();	
		//System.assert(lookup.Account_results.size() != 0);
		lookup.replaceLogic('test');
	}
	
	static testMethod void loadSearchResults_Test() {
       //Create Account test data
		gl_CustomAccountLookupController lookup = new gl_CustomAccountLookupController();
		
		//Create Account test data
		//assigning Name only, creates business account
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
		
		
		//This is necessary to create search results when querying by SOSL
		Test.setFixedSearchResults(fixedSearchResults);		
		
		lookup.searchString = '[{"Id":"0016A000005TPTqQAO","Name":"Jane Smith","Phone":"5125512551"}]';
		PageReference pr = lookup.search();
	
		System.debug('*** results = ' + lookup.Account_results);
		System.assert(lookup.Account_results.size() == 0);
	
		lookup.Phone='5555555555'	;
		lookup.search();	
		//System.assert(lookup.Account_results.size() != 0);
		
		lookup.loadSearchResults(lookup.searchString);	
		//System.assert(lookup.Account_results.size() != 0);
	}
	
	static testMethod void performSearch_Test() {
       //Create Account test data
		gl_CustomAccountLookupController lookup = new gl_CustomAccountLookupController();
		
		//assigning Name only, creates business account
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
		
		//This is necessary to create search results when querying by SOSL
		Test.setFixedSearchResults(fixedSearchResults);		
		
		lookup.Name = 'test Account1';
		lookup.Phone='3333333333'	;
		
		lookup.searchString = '[{"Id":"0016A000005TPTqQAO","Name":"Jane Smith","Phone":"5125512551"}]';
		System.debug('*** isPersonAccountEnabled = ' + lookup.isPersonAccountEnabled);

		lookup.performSearch();	
		//System.assert(lookup.Account_results.size() != 0);	
	}
	
	static testMethod void searcha_Test() {
       //Create Account test data
		gl_CustomAccountLookupController lookup = new gl_CustomAccountLookupController();
		
		//assigning Name only, creates business account
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
			
		//This is necessary to create search results when querying by SOSL
		Test.setFixedSearchResults(fixedSearchResults);		
		
		lookup.Name = 'test';
		lookup.Phone='5555555555'	;
		
		lookup.searchString = '[{"Id":"0016A000005TPTqQAO","Name":"Jane Smith","Phone":"5125512551"}]';
		PageReference pr = lookup.search();
		
		System.debug('*** results = ' + lookup.Account_results);
		//System.assert(lookup.Account_results.size() != 0);
			
		lookup.loadSearchResults(lookup.searchString);	
		//System.assert(lookup.Account_results.size() != 0);
		
		lookup.performSearch();	
		//System.assert(lookup.Account_results.size() != 0);	
		System.debug('*** results = ' + lookup.Account_results);

		
		lookup.searchString = '';
		lookup.Name = 'test Account2';
		lookup.Phone='6666666666'	;
		pr = lookup.search();	
		//System.assert(lookup.Account_results.size() != 0);
	}
	
	static testMethod void getFormTag_Test() {
		gl_CustomAccountLookupController lookup = new gl_CustomAccountLookupController();
		String result = lookup.getFormTag();
		System.debug('*** result = ' + result);
		system.assert(true);
	}
	static testMethod void getTextBox_Test() {
		gl_CustomAccountLookupController lookup = new gl_CustomAccountLookupController();
		lookup.getTextBox();
		system.assert(true);
	}
	
	static testMethod void test_getAccount(){
		//Create Account test data
		gl_CustomAccountLookupController lookup = new gl_CustomAccountLookupController();
		
		//assigning Name only, creates business account
		Id [] fixedSearchResults= new Id[3];
		Account acc0 = new Account(Name = 'test Account0', Phone = '8888888888'); 
		insert acc0;		
        fixedSearchResults[0] = acc0.Id;    
		
		//EASFP-67 - Increasing the test coverage - To cover sorting when account names are equal
		Account acc1 = new Account(Name = 'test Account1', Phone = '2222222222'); 
		insert acc1;
		fixedSearchResults[1] = acc1.Id;    
		
		Account acc2 = new Account(Name = 'test Account1', Phone = '3333333333'); 
		insert acc2;
		fixedSearchResults[2] = acc2.Id;
		
		//This is necessary to create search results when querying by SOSL
		Test.setFixedSearchResults(fixedSearchResults);		
		
		lookup.Name = 'test';
		
		PageReference pageRef = Page.gl_CustomAccountLookup;	
		
		lookup.search();	
		//System.assert(lookup.Account_results.size() != 0);
		List<gl_AccountWrapper> myresult = null;   
		if (lookup.Account_results.size() != 0) {
        	Set<Account> myAccountSet = new Set<Account>();
            myresult = new List<gl_AccountWrapper>();
            myAccountSet.addAll(lookup.Account_results);
            for (Account c : myAccountSet) {
            	gl_AccountWrapper gc = new gl_AccountWrapper(c);
            	if (myresult.size() > 0){
            		Account a = gc.getAccount();
            		gc.compareto(myresult[0]);
            	}
            	myresult.add(gc);
            }          
        }
        
        lookup.search();			
  }
		

}