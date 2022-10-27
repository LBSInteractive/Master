@isTest(SeeAllData=true)
public class gl_CustomGenericLookupController_Test {
    
      static testMethod void search_Test() {
     
          
    gl_CustomGenericLookupController lookup = new gl_CustomGenericLookupController();
    gl_AgentWorkUtils agentUtil=new gl_AgentWorkUtils();
    
    
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
    
    lookup.searchString = '7777777777 ';
    lookup.firstName = 'Pat';
    lookup.lastName = 'Ty';
    lookup.email = 'test@gmail.com';
    PageReference pr = lookup.search();    
    System.debug('*** results = ' + lookup.contact_results);
    
    System.assert(lookup.contact_results.size() != 0);
    System.assert(lookup.account_results.size() != 0);
    
    
     lookup.getFormTag();
     lookup.getTextBox();
     lookup.replaceLogic('sampletext');
     lookup.filterLabel('Contact','Contact');
 	 lookup.getContent('Contact');
          
    //lookup.performSearchByFields(con1, con1.Phone, 1111);  performSearchByFields
    List<String> sfdcFields = new List<string>();
		sfdcFields.add('Name');
    gl_CustomGenericLookupController.SFObject sample=new gl_CustomGenericLookupController.SFObject('1',sfdcFields,con1,'all') ;
    gl_CustomGenericLookupController.SFObject sample2=new gl_CustomGenericLookupController.SFObject(sfdcFields,'CONTACT','1') ;   
     
            
  }  

   //EASFP-46: ++
    // Exercise method performSearchByFields 
    static testMethod void search_Test2() {
      // Insert test record  
      Id [] fixedSearchResults= new Id[1];
      Account acc0 = new Account(Name = 'testAccount', Phone = '5555555555'); 
      insert acc0;
      fixedSearchResults[0] = acc0.Id;
      Test.setFixedSearchResults(fixedSearchResults);

      Test.startTest();  // Need this to prevent "You have uncommitted work pending" error in test execution!
      // Setup callout mock response for getContent
      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('gl_get_content_mock');
      mock.setStatusCode(200);
      mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
      Test.setMock(HttpCalloutMock.class, mock);
  
    // Test 1 - Using searchFields/searchValues
      PageReference pageRef = Page.gl_CustomGenericLookup;        
      pageRef.getParameters().put('searchFields','["account.phone"]');
      pageRef.getParameters().put('searchValues','["5555555555"]');
      pageRef.getParameters().put('lksrch','');
      pageRef.getParameters().put('ixnId','1234567890');
      pageRef.getParameters().put('inServiceCloudConsole','false');
      pageRef.getParameters().put('searchObjectType','Account');
      pageRef.getParameters().put('lookupNumber','');
      Test.setCurrentPage(pageRef);

      gl_CustomGenericLookupController lookup = new gl_CustomGenericLookupController();   
      System.assert(lookup.search_results.size() != 0);


    // Test 2 - Using searchFieldName/searchFieldValue
      pageRef = Page.gl_CustomGenericLookup;        
      pageRef.getParameters().put('searchFieldName','account.phone');
      pageRef.getParameters().put('searchFieldValue','5555555555');
      pageRef.getParameters().put('lksrch','');
      pageRef.getParameters().put('ixnId','1234567890');
      pageRef.getParameters().put('inServiceCloudConsole','false');
      pageRef.getParameters().put('searchObjectType','Account');
      pageRef.getParameters().put('lookupNumber','');
      Test.setCurrentPage(pageRef);

      lookup = new gl_CustomGenericLookupController();   
      System.assert(lookup.search_results.size() != 0);    
      Test.stopTest();
  }  


}