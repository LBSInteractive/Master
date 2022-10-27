@isTest
private class gl_CustomLookupController_Test {
	static testMethod void performSearchByFields_Test() {
		gl_CustomLookupController lookup = new gl_CustomLookupController();
		Id [] fixedSearchResults= new Id[9];
		Contact con0 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333');
		insert con0;
		fixedSearchResults[0] = con0.Id;
		
		Contact con1 = new Contact(FirstName = 'Pat', LastName = 'Doer', Phone = '8888888888');
		insert con1;
		fixedSearchResults[1] = con1.Id;
		
		Contact con2 = new Contact(FirstName = 'Patty', LastName = 'Ty', Phone = '2222222222');
		insert con2;
		fixedSearchResults[2] = con2.Id;
		
		Contact con3 = new Contact(FirstName = 'Jane', LastName = 'Doer', Email = 'test@gmail.com');
		insert con3;
		fixedSearchResults[3] = con3.Id;
		
		Account acc0 = new Account(Name = 'testAccount0', Phone = '5555555555'); 
		insert acc0;
		fixedSearchResults[4] = acc0.Id;
		Account acc1 = new Account(Name = 'testAccount1', Phone = '6666666666'); 
		insert acc1;
		fixedSearchResults[5] = acc1.Id;
		Account acc2 = new Account(Name = 'testAccount2', Phone = '7777777777'); 
		insert acc2;				
		fixedSearchResults[6] = acc2.Id;
		
		Lead l0= new Lead(FirstName = 'Jack', LastName = 'Black', Email = 'test1@gmail.com', Company = 'ABC');
		insert l0;
		fixedSearchResults[7] = l0.Id;
		
		Lead l1= new Lead(FirstName = 'Joe', LastName = 'Smith', Email = 'test2@gmail.com', Company = 'DEF');
		insert l1;
		fixedSearchResults[8] = l1.Id;
		Test.setFixedSearchResults(fixedSearchResults);			

		PageReference pageRef = Page.gl_CustomLookup;	
	    pageRef.getParameters().put('lksrch','');
	    pageRef.getParameters().put('ixnId','1234567');
	    pageRef.getParameters().put('inServiceCloudConsole','false');
	    pageRef.getParameters().put('frm','');
	    pageRef.getParameters().put('txt','');
	    Test.setCurrentPage(pageRef);
		
		lookup.performSearchByFields('Phone', '8888888888');
		System.assert(lookup.contact_results.size() != 0);
		
		lookup.performSearchByFields('Phone', '7777777777');
		System.assert(lookup.account_results.size() != 0);
		
		lookup.getFormTag();
        lookup.getTextBox();
        lookup.replaceLogic('test');
		
		lookup.performSearchByFields('Email', 'test2@gmail.com');
		System.assert(lookup.lead_results.size() != 0);
				
		lookup.searchString = '4444444444';
		lookup.firstName = 'Pat';
		lookup.lastName = 'Ty';
		lookup.email = 'test@gmail.com';
		PageReference pr = lookup.search();	
		
	}  
	
	static testMethod void search_Test() {
		gl_CustomLookupController lookup = new gl_CustomLookupController();
		Id [] fixedSearchResults= new Id[9];
		Contact con0 = new Contact(FirstName = 'John', LastName = 'Doer', Phone = '4444444444', MobilePhone = '3333333333');
		insert con0;
		fixedSearchResults[0] = con0.Id;
		
		Contact con1 = new Contact(FirstName = 'Pat', LastName = 'Doer', Phone = '8888888888');
		insert con1;
		fixedSearchResults[1] = con1.Id;
		
		Contact con2 = new Contact(FirstName = 'Patty', LastName = 'Ty', Phone = '2222222222');
		insert con2;
		fixedSearchResults[2] = con2.Id;
		
		Contact con3 = new Contact(FirstName = 'Jane', LastName = 'Doer', Email = 'test@gmail.com');
		insert con3;
		fixedSearchResults[3] = con3.Id;
		
		Account acc0 = new Account(Name = 'testAccount', Phone = '5555555555'); 
		insert acc0;
		fixedSearchResults[4] = acc0.Id;
		
		Account acc1 = new Account(Name = 'testAccount1', Phone = '6666666666'); 
		insert acc1;
		fixedSearchResults[5] = acc1.Id;
		
		Account acc2 = new Account(Name = 'testAccount2', Phone = '7777777777'); 
		insert acc2;		
		fixedSearchResults[6] = acc2.Id;
		
		Lead l0= new Lead(FirstName = 'Jack', LastName = 'Black', Email = 'test1@gmail.com', Company = 'ABC', Phone = '5555555555');
		insert l0;
		fixedSearchResults[7] = l0.Id;
		
		Lead l1= new Lead(FirstName = 'Joe', LastName = 'Smith', Email = 'test2@gmail.com', Company = 'DEF', Phone = '7777777777');
		insert l1;
		fixedSearchResults[8] = l1.Id;
		
		Test.setFixedSearchResults(fixedSearchResults);
		
		lookup.searchString = '7777777777';
		lookup.firstName = 'Pat';
		lookup.lastName = 'Ty';
		lookup.email = 'test@gmail.com';
		PageReference pr = lookup.search();		
		System.debug('*** results = ' + lookup.contact_results);
		System.assert(lookup.lead_results.size() != 0);
		System.assert(lookup.contact_results.size() != 0);
		System.assert(lookup.account_results.size() != 0);
	} 
}