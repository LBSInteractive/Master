@isTest

private class gl_CustomContactLookupController_Test {
	
	static testMethod void search_Test() {
		//EASFP-67 - fixedSearchResults for fixing SOSL empty object results response issue
		Id [] fixedSearchResults= new Id[4];
		gl_CustomContactLookupController lookup = new gl_CustomContactLookupController();
		
        Account acc0 = new Account(Name = 'test Account0', Phone = '8888888888'); 
		insert acc0;
        Contact con1 = new Contact(FirstName = 'Andy', LastName = 'Young', Phone = '4444444444', MobilePhone = '3333333333', AccountId = acc0.Id);
		insert con1;
		fixedSearchResults[0] = con1.Id; 
		Contact con2 = new Contact(FirstName = 'Pat', LastName = 'Doer', Phone = '8888888888');
		insert con2;
		fixedSearchResults[1] = con2.Id; 
		Contact con3 = new Contact(FirstName = 'Patty', LastName = 'Ty', Phone = '2222222222');
		insert con3;
		fixedSearchResults[2] = con3.Id; 
		Contact con4 = new Contact(FirstName = 'Jane', LastName = 'Doer', Email = 'test@gmail.com');
		insert con4;
		fixedSearchResults[3] = con4.Id;
		//This is necessary to create search results when querying by SOSL
		Test.setFixedSearchResults(fixedSearchResults);	

		lookup.searchString = '[{"AccountId":"00141000009i2ysAAA","Id":"0034100000CVAQMAA5","Name":"Andy Young","FirstName":"Andy","LastName":"Young","MailingStreet":"1301 Hoch Drive","Email":"a_young@dickenson.com","Phone":"4444444444","MobilePhone":"3333333333","Account":{"Name":"Dickenson plc","BillingPostalCode":"66045","Id":"00141000009i2ysAAA"}}]';
		
		PageReference pr = lookup.search();
		
		System.debug('*** results1 = ' + lookup.contact_results);
		System.assert(lookup.contact_results.size() != 0);
		lookup.firstName = 'Pat';
		lookup.lastName = 'Ty';
		lookup.email = 'test@gmail.com';
		pr = lookup.search();
		System.debug('*** results2 = ' + lookup.contact_results);
		System.assert(lookup.contact_results.size() != 0);	

		//EASFP-67 - Increasing the test coverage
		PageReference pageRef = Page.gl_CustomContactLookup;	
		pageRef.getParameters().put('sortBy','LastModifiedDate');
		Test.setCurrentPage(pageRef);
		lookup = new gl_CustomContactLookupController();
        lookup.searchString = '[{"AccountId":"00141000009i2ysAAA","Id":"0034100000CVAQMAA5","Name":"Andy Young","FirstName":"Andy","LastName":"Young","MailingStreet":"1301 Hoch Drive","Email":"a_young@dickenson.com","Phone":"4444444444","MobilePhone":"3333333333","Account":{"Name":"Dickenson plc","BillingPostalCode":"66045","Id":"00141000009i2ysAAA"}}]';
		lookup.firstName = 'Pat';
		lookup.lastName = 'Ty';
		lookup.email = 'test@gmail.com';
        pr = lookup.search();
		System.debug('*** results3 = ' + lookup.contact_results);
		System.assert(lookup.contact_results.size() != 0);	


		lookup.getFormTag();
        lookup.getTextBox();	
	}  
    
     
   
}