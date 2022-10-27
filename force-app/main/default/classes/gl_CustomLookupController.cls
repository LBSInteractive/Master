//Added 'with sharing' for avoiding sharing warning on checkmarx on 15/04/20
global with sharing class gl_CustomLookupController {
	public List<Contact> contact_results {get;set;} // search results
	public List<Contact> contact_results1{get;set;} // search results for FirstName
	public List<Contact> contact_results2{get;set;} // search results for LastName
	public List<Contact> contact_results3{get;set;} // search results for Email

	public List<Account> account_results {get;set;} // search results
	public List<Lead> lead_results {get;set;} // search results
	public List<Lead> lead_results1{get;set;} // search results for FirstName
	public List<Lead> lead_results2{get;set;} // search results for LastName
	public List<Lead> lead_results3{get;set;} // search results for Email

	public string searchString {get;set;} // search keyword, set either by invoking page or via URI
	
	public string searchFieldName {get; set;}
	public string searchFieldValue {get; set; }
	public string searchFields {get; set; }
	public string searchValues {get; set; }
	
	public string firstName {get;set;} // set by invoking page
	public string lastName {get;set;} // set by invoking page
	public string email {get;set;} // set by invoking page
	
	public static string ixnId {get;set;} // interaction id, set via URI
	public string inServiceCloudConsole {get;set;} // set in constructor
	

	public List<String> searchMapFields = null;
	public List<String> searchMapValues = null;
	
	public Boolean searchAllFields = true;
	
	
	public gl_CustomLookupController() {
		// get the current search string
		searchString = System.currentPageReference().getParameters().get('lksrch');
		if (searchString != null && searchString != ''){
			/*searchString = searchString.removeEnd('\"').removeStart('\"');
			searchString = searchString.replaceAll('MyAmpersand','\\&'); 
	    	searchString = searchString.replaceAll('SingleQuote','\\\'');
	    	searchString = searchString.replaceAll('MyPlus','\\+');*/
	    	searchString = replaceLogic(searchString);
			system.debug('*** g_CustomLookupController searchString ' + searchString);
		}
		else
			searchString = '';
		
		ixnId = System.currentPageReference().getParameters().get('ixnId');
		system.debug('*** CustomLookupController ixnId ' + ixnId);
		system.debug('*** CustomLookupController search for '+searchString);     
		
		searchFieldName =  System.currentPageReference().getParameters().get('searchFieldName');
		if (searchFieldName != null && searchFieldName != ''){
			/*searchFieldName = searchFieldName.removeEnd('\"').removeStart('\"');
			searchFieldName = searchFieldName.replaceAll('MyAmpersand','\\&'); 
	    	searchFieldName = searchFieldName.replaceAll('SingleQuote','\\\'');
	    	searchFieldName = searchFieldName.replaceAll('MyPlus','\\+');*/
	    	searchFieldName = replaceLogic(searchFieldName);
			system.debug('*** CustomLookupController searchFieldName ' + searchFieldName);
		}
		else
			searchFieldName = '';
		
		
		searchFieldValue = System.currentPageReference().getParameters().get('searchFieldValue');
		if (searchFieldValue != null && searchFieldValue != ''){
			/*searchFieldValue = searchFieldValue.removeEnd('\"').removeStart('\"');
			searchFieldValue = searchFieldValue.replaceAll('MyAmpersand','\\&'); 
	    	searchFieldValue = searchFieldValue.replaceAll('SingleQuote','\\\'');
	    	searchFieldValue = searchFieldValue.replaceAll('MyPlus','\\+');*/
	    	searchFieldValue = replaceLogic(searchFieldValue);
			system.debug('*** CustomLookupController searchFieldValue ' + searchFieldValue);
		}
		else
			searchFieldValue = '';
			
		searchFields = System.currentPageReference().getParameters().get('searchFields');

		if (searchFields != null && searchFields != ''){
			/*searchFields = searchFields.removeEnd('\"').removeStart('\"');
			searchFields = searchFields.replaceAll('MyAmpersand','\\&'); 
	    	searchFields = searchFields.replaceAll('SingleQuote','\\\'');
	    	searchFields = searchFields.replaceAll('MyPlus','\\+');*/
	    	searchFields = replaceLogic(searchFields);
			system.debug('*** CustomLookupController searchFields ' + searchFields);
			searchMapFields = (List<String>)JSON.deserialize(searchFields,List<String>.class);
			for (String s:searchMapFields){
				system.debug('*** CustomLookupController searchMapFields ' + s);
			}
		}
		else{

			searchFields = '';
			system.debug('*** CustomLookupController searchFieldMap is empty ');

			searchMapFields = null;
		}
		
		searchValues = System.currentPageReference().getParameters().get('searchValues');
		if (searchValues != null && searchValues != ''){
			/*searchValues = searchValues.removeEnd('\"').removeStart('\"');
			searchValues = searchValues.replaceAll('MyAmpersand','\\&'); 
	    	searchValues = searchValues.replaceAll('SingleQuote','\\\'');
	    	searchValues = searchValues.replaceAll('MyPlus','\\+');*/
	    	searchValues = replaceLogic(searchValues);
			system.debug('*** CustomLookupController searchValues ' + searchValues);
			searchMapValues = (List<String>)JSON.deserialize(searchValues,List<String>.class);
			for (String s:searchMapValues){
				system.debug('*** CustomLookupController searchMapValues ' + s);
			}
		}
		else{
			searchValues = '';
			system.debug('*** CustomLookupController searchMapValues is empty ');
			searchMapValues = null;
		}
		
		string searchAllFieldsStr  = System.currentPageReference().getParameters().get('searchAllFields');
		system.debug('*** CustomLookupController searchAllFieldsStr = ' + searchAllFieldsStr);
		if (searchAllFieldsStr != null && searchAllFieldsStr != '' && searchAllFieldsStr.toLowerCase() == 'true')
			searchAllFields = true;
		else
			searchAllFields = false;			
		
		system.debug('*** CustomLookupController searchAllFields = ' + searchAllFieldsStr);
		account_results = new List<Account>();
        contact_results = new List<Contact>();
        lead_results = new List<Lead>();
		
		if (searchMapFields != null && searchMapValues != null && searchMapFields.size() == searchMapValues.size())

		{	
			for(Integer i = 0; i < searchMapFields.size(); i++)
	        {
	        	if (i > 0 && searchAllFields == false && (account_results.size() > 0 || contact_results.size() > 0 || lead_results.size() > 0 ) )
	        	{
	        		system.debug('*** CustomLookupController stop the search.');
	        		break;
	        	}
	        	if (searchMapFields[i] != '' && searchMapFields[i] != null && searchMapValues[i] != '' && searchMapValues[i] != null){
	 	  			String mySFDCfield = searchMapFields[i];
	 	  			String mySFDCvalue = searchMapValues[i];
		        	system.debug('*** findObjectMapSearch: mySFDCfield - ' + mySFDCfield +', mySFDCvalue - ' + mySFDCvalue);
					performSearchByFields(mySFDCfield, mySFDCvalue);
	        	}
	        }			
		}
		else if (searchFieldName != null && searchFieldName != '' && searchFieldValue != null && searchFieldValue != '')
			performSearchByFields(searchFieldName, searchFieldValue);
		else
			runSearch();
	}
   
	// performs the keyword search
	global PageReference search() {
		system.debug('*** search');
		account_results = new List<Account>();
        contact_results = new List<Contact>();
        lead_results = new List<Lead>();
		//Activated by search button, ignore search string from url
		runSearch();
		return null;
	}
    
  
	// prepare the query and issue the search command
	private void runSearch() {
		system.debug('*** runSearch');
		performSearch(searchString);         
	} 
	
     public void performSearchByFields(String searchFieldName, String searchFieldValue){
        system.debug('*** performSearchByFields : searchFieldName - ' + searchFieldName +', searchFieldValue - ' + searchFieldValue);
        
        List<List<SObject>> cObjects = null;
        List<List<SObject>> aObjects = null;
        List<List<SObject>> lObjects = null;   
        String query;
        
        if(searchFieldName == '' || searchFieldValue == '')
        	return;
		String lowerFieldName = searchFieldName.toLowerCase();
		
		//check account
        try{
        	//query = 'SELECT Id, Name, Phone FROM Account WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\'';
            if (lowerFieldName != 'name' && lowerFieldName != 'phone' && lowerFieldName != 'account.name' && lowerFieldName != 'account.phone')
	           	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name,Phone,' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
	        else
	        	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name,Phone' + ' WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';

	           	
          	system.debug('*** Account query = ' + query); 
          	List<List<sObject>> searchList = search.query(query);
          	
          	system.debug('*** performSearchByFields :account search');
			if (searchList != null){          
	           	List<Account> temp_Account =((List<Account>)searchList[0]);
	            // Remove duplicates
	          	if (temp_Account != null && temp_Account.size() > 0){
		          	for (Account t: temp_Account){
		          		Boolean alreadyAdded = false;
		          		for(Account r: account_results){
		          			if (r.Id == t.Id){
		          				alreadyAdded = true;
		          				break;
		          			}
		          		}
		          		if (alreadyAdded == false){
		          			account_results.add(t);
		          		}
		          	}
	          	} 
           	}          	        
        }
        catch(Exception e){
        	system.debug('*** Exception account search' + e);
        }
        
        if (account_results != null && account_results.size() > 0)
        	system.debug('*** performSearchByFields :account search result count: ' + account_results.size());
        else
        	system.debug('*** performSearchByFields :account search result count: 0');
        
        //check contact
        try{   
        	
        	if (lowerFieldName != 'account.name' && 
        		lowerFieldName != 'name' && lowerFieldName != 'contact.name' && 
        		lowerFieldName != 'firstname' && lowerFieldName != 'contact.firstname' && 
        		lowerFieldName != 'lastname' && lowerFieldName != 'contact.lastname' && 
        		lowerFieldName != 'mailingaddress' && lowerFieldName != 'contact.mailingaddress' && 
        		lowerFieldName != 'email' && lowerFieldName != 'contact.email' && 
        		lowerFieldName != 'phone' && lowerFieldName != 'contact.phone' && 
        		lowerFieldName != 'mobilephone' && lowerFieldName != 'contact.mobilephone' && 
        		lowerFieldName != 'homephone' && lowerFieldName != 'contact.homephone' && 
        		lowerFieldName != 'assistantphone' && lowerFieldName != 'contact.assistantphone' && 
        		lowerFieldName != 'otherphone' && lowerFieldName != 'contact.otherphone')   
		        query = 'FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Contact(Account.Name, Id, Name, FirstName, LastName, MailingStreet, EMail, Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone,' +
		        	 searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
		    else
		    	 query = 'FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Contact(Account.Name, Id, Name, FirstName, LastName, MailingStreet, EMail, Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone' +
		        	 ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
		    system.debug('*** Contact query = ' + query);    
		    List<List<sObject>> searchList = search.query(query); 	 
			system.debug('*** performSearchByFields :contact search');
			if (searchList != null){          
	           	List<Contact> temp_Contact =((List<Contact>)searchList[0]);
	            // Remove duplicates
	          	if (temp_Contact != null && temp_Contact.size() > 0){
		          	for (Contact t: temp_Contact){
		          		Boolean alreadyAdded = false;
		          		for(Contact r: contact_results){
		          			if (r.Id == t.Id){
		          				alreadyAdded = true;
		          				break;
		          			}
		          		}
		          		if (alreadyAdded == false){
		          			contact_results.add(t);
		          		}
		          	}
	          	} 
           	} 			
        }
        catch(Exception e){
        	system.debug('*** Exception contact search' + e); 
        }
        
        if (contact_results != null && contact_results.size() > 0)
        	system.debug('*** performSearchByFields :contact search result count: ' + contact_results.size());
        else
        	system.debug('*** performSearchByFields :contact search result count: 0');
        
        //check lead
        try{        	
        	if (lowerFieldName != 'convertedaccountid' && 
        		lowerFieldName != 'name' && lowerFieldName != 'lead.name' &&
        		lowerFieldName != 'street' && lowerFieldName != 'lead.street' &&
        		lowerFieldName != 'firstname' && lowerFieldName != 'lead.firstname' &&
        		lowerFieldName != 'lastname' && lowerFieldName != 'lead.lastname' &&
        		lowerFieldName != 'email' && lowerFieldName != 'lead.email' &&
        		lowerFieldName != 'phone' && lowerFieldName != 'lead.phone' &&
        		lowerFieldName != 'mobilephone' && lowerFieldName != 'lead.mobilephone')    
	        	query = 'FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Lead(Id, ConvertedAccountId, Name, Street, FirstName, LastName, Email, Phone, MobilePhone,' + 
	        		+ searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
	        else
	        	query = 'FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Lead(Id, ConvertedAccountId, Name, Street, FirstName, LastName, Email, Phone, MobilePhone' + 
	        		 ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
	        system.debug('*** Lead query = ' + query);    
		    List<List<sObject>> searchList = search.query(query); 	 
			system.debug('*** performSearchByFields :lead search');
			if (searchList != null){          
	           	List<Lead> temp_Lead =((List<Lead>)searchList[0]);
	            // Remove duplicates
	          	if (temp_Lead != null && temp_Lead.size() > 0){
		          	for (Lead t: temp_Lead){
		          		Boolean alreadyAdded = false;
		          		for(Lead r: lead_results){
		          			if (r.Id == t.Id){
		          				alreadyAdded = true;
		          				break;
		          			}
		          		}
		          		if (alreadyAdded == false){
		          			lead_results.add(t);
		          		}
		          	}
	          	} 
           	}        
        }
        catch(Exception e){
        	system.debug('*** Exception lead search' + e); 
        }
        
        if (lead_results != null && lead_results.size() > 0)
        	system.debug('*** performSearchByFields :lead search result count: ' + lead_results.size());
        else
        	system.debug('*** performSearchByFields :lead search result count: 0'); 
   
    }  
  
	// run the search and save the records found. 
	public void performSearch(string searchString) {
		system.debug('*** performSearch for searchString = ' + searchString);
		List<List<SObject>> objs = null;
	
		contact_results1 = null;
		contact_results2 = null;
		contact_results3 = null;
		Integer listSize = 0;
		
		account_results = new List<Account>();
        contact_results = new List<Contact>();
        lead_results = new List<Lead>();    
		String query;
		
		List<List<sObject>> searchList = null;
		
		system.debug('*** firstName = ' + firstName);
		system.debug('*** lastName = ' + lastName);
		system.debug('*** email = ' + email);
		
		//Contact search
		try {
			//Need at least 2 chars for SOSL search
			if (searchString != null && searchString != '' && searchString.length() > 1) {
				objs = [find :searchString in phone fields returning Contact(Account.Name, Id, 
						Name, FirstName, LastName, 
						MailingStreet, 
						EMail, 
						Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone)];
				listSize = objs.size();
				system.debug('*** contact listSize = ' + listSize);
				List<Contact> contacts = null;
				if (!objs.isEmpty()) {
					contact_results.addAll((List<Contact>) objs[0]);
				}
			} 
			system.debug('*** performSearch contact_results= ' + contact_results);
			
			if (firstName != null && firstName != '' && firstName.length() > 1) {
				string term = '%' + firstName + '%'; 
				/*
				List<Contact> contact_results1 = [select  Account.Name, Id, 
						Name, FirstName, LastName, 
						MailingStreet, 
						EMail,
						Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone 
						from contact where FirstName like :term];
				*/
				query = 'FIND \'' + firstName + '*\' IN Name FIELDS RETURNING Contact(Account.Name, Id, Name, FirstName, LastName, MailingStreet,' +
						' EMail, Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone WHERE FirstName like \'' + term + '\' ) LIMIT 1000';
				system.debug('*** performSearch Contact query = ' + query);   
				searchList = search.query(query); 
				if (searchList != null){   
					contact_results1 = ((List<Contact>)searchList[0]);
					if (contact_results1 != null && contact_results1.size() > 0)
					{
						system.debug('*** contact_results1 = ' + contact_results1);
						system.debug('*** contact contact_results1.size = ' + contact_results1.size());
						contact_results.addAll(contact_results1);
					} 
				}
				
			}

			if (lastName != null && lastName != '' && lastName.length() > 1) {
				string term = '%' + lastName + '%';
				/*    		
				List<Contact> contact_results2 = [select Account.Name, Id, 
						Name, FirstName, LastName, 
						MailingStreet, 
						EMail,
						Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone 
						from contact where LastName like :term];
				*/	
				query = 'FIND \'' + lastName + '*\' IN Name FIELDS RETURNING Contact(Account.Name, Id, Name, FirstName, LastName, MailingStreet,' +
						' EMail, Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone WHERE LastName like \'' + term + '\') LIMIT 1000';

				system.debug('*** performSearch Contact query = ' + query);   
				searchList = search.query(query); 
				
				if (searchList != null){   
					contact_results2= ((List<Contact>)searchList[0]);
					if (contact_results2 != null && contact_results2.size() > 0)
					{
						system.debug('*** contact_results2 = ' + contact_results2);
						system.debug('*** contact contact_results2.size = ' + contact_results2.size());
						contact_results.addAll(contact_results2);
					} 
				}
			}
			 
			
			if (email != null && email != '' && email.length() > 0) {
				string term = '%' + email + '%';
				/*
				contact_results3 = [select Account.Name, Id, 
						Name, FirstName, LastName, 
						MailingStreet, 
						EMail,
						Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone 
						from contact where Email like :term];
					*/
				query = 'FIND \'' + email + '*\' IN EMail FIELDS RETURNING Contact(Account.Name, Id, Name, FirstName, LastName, MailingStreet,' +
						' EMail, Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone) LIMIT 1000';

				system.debug('*** performSearch Contact query = ' + query);   
				searchList = search.query(query); 
				
				if (searchList != null){   
					contact_results3= ((List<Contact>)searchList[0]);
					if (contact_results3 != null && contact_results3.size() > 0)
					{
						system.debug('*** contact_results3 = ' + contact_results3);
						system.debug('*** contact contact_results2.size = ' + contact_results3.size());
						contact_results.addAll(contact_results3);
					} 
				}
			}  
			       
			system.debug('*** TOTAL contact_results= ' + contact_results);

			// Use custom sorting
			if (contact_results.size() != 0) {
				Set<Contact> myset = new Set<Contact>();
				List<gl_ContactWrapper> myresult = new List<gl_ContactWrapper>();
				//this removes the duplicates since list is not allowed dups
				myset.addAll(contact_results);
				for (Contact c : myset) {
					myresult.add(new gl_ContactWrapper(c));
				}
				myresult.sort();

				contact_results.clear();
				for (gl_ContactWrapper gl_c : myresult) {
					contact_results.add(gl_c.getContact());
				}
			}
		}
		catch (Exception e) {
			system.debug('*** ERROR = ' + e); 
		}
		
		//Account search by phone		
		if (searchString != null && searchString != '' && searchString.length() > 1) {
			objs = [FIND :searchString IN PHONE FIELDS RETURNING Account(Id, Name, Phone)];

			listSize = objs.size();
			system.debug('*** account listSize = ' + listSize);
			List<Account> accounts = null;
			if (!objs.isEmpty()) {
				account_results = ((List<Account>)objs[0]);
			}
		}
		system.debug('*** account_results = ' + account_results);  
	
		//Lead search
		try {			
			lead_results = new List<Lead>();
			if (searchString != null && searchString != '' && searchString.length() > 1) { 
				//Error "field not recognized" when using Address in query   
				objs = [FIND :searchString IN PHONE FIELDS RETURNING Lead(Id, ConvertedAccountId, 
						Name, Street, FirstName, LastName, Email, Phone, MobilePhone)];
				listSize = objs.size();
				system.debug('*** lead listSize = ' + listSize);
				List<Lead> leads = null;
				if (!objs.isEmpty()) {
					lead_results = ((List<Lead>)objs[0]);
				}
			}
			system.debug('*** lead_results = ' + lead_results);
			
			lead_results1 = null;
			lead_results2 = null;
			lead_results3 = null;	
			if (firstName != null && firstName != '' && firstName.length() > 1) {
				string term = '%' + firstName + '%'; 
				/*
				List<Lead> lead_results1 = [select Id, ConvertedAccountId, 
					Name, Street, FirstName, LastName, Email, Phone, MobilePhone from Lead where FirstName like :term];
				*/
				query = 'FIND \'' + firstName + '*\' IN Name FIELDS RETURNING Lead(Id, ConvertedAccountId, Name, Street, FirstName, LastName, Email, Phone, MobilePhone WHERE FirstName like \'' + term + '\') LIMIT 1000';

		        system.debug('*** performSearch Lead query = ' + query);   
				searchList = search.query(query); 
				if (searchList != null){   
					lead_results1 = ((List<Lead>)searchList[0]);
					if (lead_results1 != null && lead_results1.size() > 0)
					{
						system.debug('*** lead_results1 = ' + lead_results1);
						system.debug('*** contact lead_results1.size = ' + lead_results1.size());
						lead_results.addAll(lead_results1);
					} 
				}	 	
		        	 	
				system.debug('*** lead listSize1 = ' + lead_results1.size());
				system.debug('*** lead_results1 = ' + lead_results1);
				lead_results.addAll(lead_results1);
			}

			if (lastName != null && lastName != '' && lastName.length() > 1) {
				string term = '%' + lastName + '%';   
				/* 		
				List<Lead> lead_results2 = [select Id, ConvertedAccountId, 
					Name, Street, FirstName, LastName, Email, Phone, MobilePhone from Lead where LastName like :term];
				*/
				query = 'FIND \'' + lastName + '*\' IN Name FIELDS RETURNING Lead(Id, ConvertedAccountId, Name, Street, FirstName, LastName, Email, Phone, MobilePhone WHERE LastName like \'' + term + '\') LIMIT 1000';
	
		        system.debug('*** performSearch Lead query = ' + query);   
				searchList = search.query(query); 
				if (searchList != null){   
					lead_results2 = ((List<Lead>)searchList[0]);
					if (lead_results2 != null && lead_results2.size() > 0)
					{
						system.debug('*** lead_results2 = ' + lead_results2);
						system.debug('*** contact lead_results2.size = ' + lead_results2.size());
						lead_results.addAll(lead_results2);
					} 
				}
			} 
			
			if (email != null && email != '' && email.length() > 1) {
				string term = '%' + email + '%';
				/*
				List<Lead> lead_results3 = [select Id, ConvertedAccountId, 
					Name, Street, FirstName, LastName, Email, Phone, MobilePhone from Lead where Email like :term];
				*/
				query = 'FIND \'' + email + '*\' IN Email FIELDS RETURNING Lead(Id, ConvertedAccountId, Name, Street, FirstName, LastName, Email, Phone, MobilePhone) LIMIT 1000';
	
		        system.debug('*** performSearch Lead query = ' + query);   
				searchList = search.query(query); 
				if (searchList != null){   
					lead_results3 = ((List<Lead>)searchList[0]);
					if (lead_results3 != null && lead_results3.size() > 0)
					{
						system.debug('*** lead_results3 = ' + lead_results3);
						system.debug('*** contact lead_results3.size = ' + lead_results3.size());
						lead_results.addAll(lead_results3);
					} 
				}
			}         
			system.debug('*** TOTAL lead_results= ' + lead_results);

			// Use default sorting
			if (lead_results.size() != 0) {
				Set<Lead> myset = new Set<Lead>();
				List<Lead> myresult = new List<Lead>();
				//this removes the duplicates since list is not allowed dups
				myset.addAll(lead_results);
				myresult.addAll(myset);
				lead_results = myresult;
				lead_results.sort();
			}
		}
		catch (Exception e) {
			system.debug('*** ERROR = ' + e); 
		}
	}
  

  
  
	// used by the visualforce page to send the link to the right dom element
	public string getFormTag() {
		return System.currentPageReference().getParameters().get('frm');
	}
  
	// used by the visualforce page to send the link to the right dom element for the text box
	public string getTextBox() {
		return System.currentPageReference().getParameters().get('txt');
	}
	
	public string replaceLogic(string stringtoreplace )
	{
		stringtoreplace = stringtoreplace.removeEnd('\"').removeStart('\"');
		stringtoreplace = stringtoreplace.replaceAll('MyAmpersand','\\&'); 
	    stringtoreplace = stringtoreplace.replaceAll('SingleQuote','\\\'');
	    stringtoreplace = stringtoreplace.replaceAll('MyPlus','\\+');
	    return stringtoreplace;
	}
}