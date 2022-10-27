//Added 'with sharing' for avoiding sharing warning on checkmarx on 15/04/20
global with sharing class gl_CustomGenericLookupController {

	public List<Contact> contact_results {get;set;} // search results
	public List<Contact> contact_results1{get;set;} // search results for FirstName
	public List<Contact> contact_results2{get;set;} // search results for LastName
	public List<Contact> contact_results3{get;set;} // search results for Email

	public List<Account> account_results {get;set;} // search results
	public List<Lead> lead_results1{get;set;} // search results for FirstName
	public List<Lead> lead_results2{get;set;} // search results for LastName
	public List<Lead> lead_results3{get;set;} // search results for Email
	
	public List<List<SObject>> genObjects {get;set;} 
    public List<SObject> search_results {get;set;} 
    public List<SFObject> sf_objects { get; set; }
    public Map<String, List<SFObject>> lookupMap { get; set; }  
        
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
	
	
	public gl_CustomGenericLookupController() {
	       
		// get the current search string
		searchString = System.currentPageReference().getParameters().get('lksrch');
		if (searchString != null && searchString != ''){
			/*searchString = searchString.removeEnd('\"').removeStart('\"');
			searchString = searchString.replaceAll('MyAmpersand','\\&'); 
	    	searchString = searchString.replaceAll('SingleQuote','\\\'');
	    	searchString = searchString.replaceAll('MyPlus','\\+');*/
	    	searchString = replaceLogic(searchString);
			system.debug('*** gl_CustomGenericLookupController searchString ' + searchString);
		}
		else
			searchString = '';
		
		ixnId = System.currentPageReference().getParameters().get('ixnId');
		system.debug('*** CustomGenericLookupController ixnId ' + ixnId);
		system.debug('*** CustomGenericLookupController search for '+searchString);     
		
		searchFieldName =  System.currentPageReference().getParameters().get('searchFieldName');
		if (searchFieldName != null && searchFieldName != ''){
			/*searchFieldName = searchFieldName.removeEnd('\"').removeStart('\"');
			searchFieldName = searchFieldName.replaceAll('MyAmpersand','\\&'); 
	    	searchFieldName = searchFieldName.replaceAll('SingleQuote','\\\'');
	    	searchFieldName = searchFieldName.replaceAll('MyPlus','\\+');*/
	    	searchFieldName = replaceLogic(searchFieldName);
			system.debug('*** CustomGenericLookupController searchFieldName ' + searchFieldName);
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
			system.debug('*** CustomGenericLookupController searchFieldValue ' + searchFieldValue);
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
			system.debug('*** CustomGenericLookupController searchFields ' + searchFields);
			searchMapFields = (List<String>)JSON.deserialize(searchFields,List<String>.class);
			for (String s:searchMapFields){
				system.debug('*** CustomGenericLookupController searchMapFields ' + s);
			}
		}
		else{

			searchFields = '';
			system.debug('*** CustomGenericLookupController searchFieldMap is empty ');

			searchMapFields = null;
		}
		
		searchValues = System.currentPageReference().getParameters().get('searchValues');
		if (searchValues != null && searchValues != ''){
			/*searchValues = searchValues.removeEnd('\"').removeStart('\"');
			searchValues = searchValues.replaceAll('MyAmpersand','\\&'); 
	    	searchValues = searchValues.replaceAll('SingleQuote','\\\'');
	    	searchValues = searchValues.replaceAll('MyPlus','\\+');*/
	    	searchValues = replaceLogic(searchValues);
			system.debug('*** CustomGenericLookupController searchValues ' + searchValues);
			searchMapValues = (List<String>)JSON.deserialize(searchValues,List<String>.class);
			for (String s:searchMapValues){
				system.debug('*** CustomGenericLookupController searchMapValues ' + s);
			}
		}
		else{
			searchValues = '';
			system.debug('*** CustomGenericLookupController searchMapValues is empty ');
			searchMapValues = null;
		}
		
		string searchAllFieldsStr  = System.currentPageReference().getParameters().get('searchAllFields');
		system.debug('*** CustomGenericLookupController searchAllFieldsStr = ' + searchAllFieldsStr);
		if (searchAllFieldsStr != null && searchAllFieldsStr != '' && searchAllFieldsStr.toLowerCase() == 'true')
			searchAllFields = true;
		else
			searchAllFields = false;			
		
		system.debug('*** CustomGenericLookupController searchAllFields = ' + searchAllFieldsStr);
		
		if (searchMapFields != null && searchMapValues != null && searchMapFields.size() == searchMapValues.size())

		{	
			search_results = new List<SObject>();
			sf_objects = new List<SFObject>();
			lookupMap = new Map<String,List<SFObject>>();
			for(Integer i = 0; i < searchMapFields.size(); i++)
	        {
	        	if (i > 0 && searchAllFields == false && search_results.size() > 0 )
	        	{
	        		system.debug('*** CustomGenericLookupController stop the search.');
	        		break;
	        	}
	        	if (searchMapFields[i] != '' && searchMapFields[i] != null && searchMapValues[i] != '' && searchMapValues[i] != null){
	        		String[] objectFieldPair = searchMapFields[i].split('\\.'); 
	        		String mySFDCobject = objectFieldPair[0];
    				String mySFDCfield = objectFieldPair[1];
	 	  			String mySFDCvalue = searchMapValues[i];
		        	system.debug('*** findObjectMapSearch: mySFDCobject - ' + mySFDCobject + ', mySFDCfield - ' + mySFDCfield +', mySFDCvalue - ' + mySFDCvalue);		        	
					performSearchByFields(mySFDCobject, mySFDCfield, mySFDCvalue);
					system.debug('*** searchFields: mySFDCobject - ' + mySFDCobject + ', fields - ' + searchFields); 
	        	}
	        }			
		}
		else if (searchFieldName != null && searchFieldName != '' && searchFieldValue != null && searchFieldValue != '')
		{
			search_results = new List<SObject>();
			sf_objects = new List<SFObject>();
			lookupMap = new Map<String,List<SFObject>>();
			String[] objectFieldPair2 = searchFieldName.split('\\.'); 
	        String mySFDCobject2 = objectFieldPair2[0];
			performSearchByFields(mySFDCobject2, objectFieldPair2[1], searchFieldValue);
		}
		else
			runSearch();
	}
   
    // Pass in the endpoint to be used using the string url   
    public List<String> getContent(String sObjName) {
    	try{
    	
    	String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
    	
    	String url = sfdcURL + '/services/data/v45.0/search/layout?q=' + sObjName;
        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Accept-Charset', 'UTF-8');
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setEndpoint(url);
        req.setMethod('GET');
        
        // Send the request, and return a response
        String response = '';
        HttpResponse res = h.send(req);
        if (res.getStatusCode() == 200 ) {  
        	List<Object> level1 = (List<Object>) JSON.deserializeUntyped(res.getBody());
			system.debug('*** getContent searchMapFields level1 ' + level1);
			for (Object obj : level1) {
				system.debug('*** getContent searchMapFields ' + obj);
				Map<String, Object> level2 = (Map<String, Object>) obj;
				system.debug('*** getContent searchMapFields level 2' + level2);
				if(level2.containsKey('searchColumns')){
					List<Object> level3 = (List<Object>) level2.get('searchColumns');
					system.debug('*** getContent searchMapFields level 3' + level3);
					List<String> labels = new List<String>();
					for (Object obj3 : level3) {
						Map<String, Object> level4 = (Map<String, Object>) obj3;
						system.debug('*** getContent searchMapFields level 4' + level4);
						String label = (String)level4.get('field');
						system.debug('*** getContent searchMapFields label ' + label);
						label = filterLabel(label, sObjName);
						if(label != '' && labels.size() < 5)
							labels.Add(label.capitalize());
					}
					system.debug('*** getContent fields count' + labels.size());
					return labels;
				}    			
			}			
		 } else {  
			   System.debug(' httpResponse - ' + res.getBody() );
			   return null;    
		 } 
		 return null;
    	}
    	catch(Exception ex){
    		System.debug(' getContent error - ' + ex);    
    		return null;
    	}        
    }
    
    global String filterLabel(String label, String sObjectName){
    	label = label.toLowerCase();
    	String prefixString = sObjectName.toLowerCase() + '.';
    	if(label.contains(prefixString))
    		label = label.replace(prefixString,'');
    	else
    		label = '';
    	return label;
    }
    
	// performs the keyword search
	global PageReference search() {
		system.debug('*** search');
		//search_results = new List<SObject>();
		//Activated by search button, ignore search string from url
		runSearch();
		return null;
	}
    
  
	// prepare the query and issue the search command
	private void runSearch() {
		system.debug('*** runSearch');
		performSearch(searchString);         
	} 
	
     public void performSearchByFields(String searchObject, String searchFieldName, String searchFieldValue){
        system.debug('*** performSearchByFields : searchObject - ' + searchObject +', searchFieldName - ' + searchFieldName +', searchFieldValue - ' + searchFieldValue);
          
        List<String> searchFieldsList = getContent(searchObject);
        
		// making a single string with comma seprated from above list

		String commaSepratedList='';
		for(Integer i=0; i < searchFieldsList.size(); i++)
		{
			if(i > 4)
				break;
 			commaSepratedList += searchFieldsList[i] + ',' ;
		}

		// remove last additional comma from string
		commaSepratedList = commaSepratedList.subString(0,commaSepratedList.length()-1);
		//Added escapeSingleQuotes for avoiding SOQL injection warning on checkmarx on 15/04/20
		commaSepratedList=String.escapeSingleQuotes(commaSepratedList);
		searchFieldValue =  String.escapeSingleQuotes(searchFieldValue);
		searchObject= String.escapeSingleQuotes(searchObject);
		
        String query;
        genObjects = new List<List<SObject>>();
        
        if(searchFieldName == '' || searchFieldValue == '')
        	return;
		String lowerFieldName = searchFieldName.toLowerCase();
		
		try{
			
			List<SObject> sObj = null;
			if(lowerFieldName != 'id')
			{
        		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING ' + searchObject + '(Id, ' + commaSepratedList + ' WHERE ' + lowerFieldName  + ' = \'' + searchFieldValue + '\')';
        		system.debug('***Generic object query = ' + query);
        		genObjects = search.query(query);
			}
        	else
        	{
        		query = 'Select ' +  commaSepratedList + ' FROM ' + searchObject + ' WHERE Id = \'' + searchFieldValue + '\'';
        		system.debug('***Generic object query = ' + query);
        		sObj = Database.query(query);
        	}
        	
			
			sf_objects = new List<SFObject>();
	        List<SObject> temp_Object = new List<SObject>();
	        if(sObj != null){
	        	temp_Object = sObj;
	           	system.debug('***temp_Object size = ' + temp_Object.size());
	        }
	        else if (genObjects != null){        
	            temp_Object = genObjects[0];
	           	system.debug('***genObjects size = ' + genObjects.size());
	        }
	            // Remove duplicates
	            if(!lookupMap.containsKey(searchObject.toUpperCase()))//Moved section for WF fix Saroj [from here]
	          		{
	          			system.debug('***sf_objects size = ' + sf_objects);
	          			sf_objects.add(new SFObject(searchFieldsList,searchObject.toUpperCase(),'')); 
	          		}   
	          	if (temp_Object != null && temp_Object.size() > 0){	  
	          		system.debug('***genObjects lookupMap = ' + lookupMap.size());
	          		system.debug('***genObjects Total lookupMap = ' + lookupMap);
	          		    		
		          	for (SObject t: temp_Object){
		          		Boolean alreadyAdded = false;
		          		system.debug('***search_results size = ' + search_results);
		          		if (search_results != null && search_results.size() > 0){
		          			for(SObject r: search_results){
		          				if (r.Id == t.Id){
		          					alreadyAdded = true;
		          					break;
		          				}
		          			}
		          		}
		          		if (alreadyAdded == false){		         
		          			system.debug('***t = ' + t); 			
		          			system.debug('***Adding to search_result');
		          			search_results.add(t);
		          			system.debug('***Adding to sf_objects');
		          			sf_objects.add(new SFObject(t.Id, searchFieldsList, t, searchObject.toUpperCase()));
		          			system.debug('***Added to sf_objects - size - ' + sf_objects.size());
		          		}
		          	}
	          	} 
           	
           	
           	if(!lookupMap.containsKey(searchObject.toUpperCase())){
           		system.debug('***Adding to lookupMap');
           		lookupMap.put(searchObject.toUpperCase(),sf_objects);
           		system.debug('***Added');
           	}
           	else{
           		List<SFObject> lst = lookupMap.get(searchObject.toUpperCase());
           		lst.addall(sf_objects);
           		system.debug('***Appending to lookupMap');
           		lookupMap.put(searchObject.toUpperCase(),lst);
           		system.debug('***Appended');
           	}
        

           	system.debug('***search_results - ' + search_results);
           	system.debug('***sf_objects - ' + sf_objects);
           	system.debug('***lookupMap size - ' + lookupMap.size());
           	system.debug('***lookupMap - ' + lookupMap);
        }
        catch(Exception e){
        	system.debug('*** Exception generic object search - ' + e);
        }
        if (search_results != null && search_results.size() > 0)
        	system.debug('*** performSearchByFields :search result count: ' + search_results.size());
        else
        	system.debug('*** performSearchByFields :search result count: 0');		
   
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
	
	public class SFObject{
		
		public SFObject(List<String> Fields, String SFType, String Id)
		{
			this.id = Id;
			this.m1 = new Map<String, String>();
			this.sfType = SFType;
						
			this.sfFields = new List<String>();			
			for (String field : Fields) {
				if(!m1.containsKey(field))
		        {
		        	sfFields.add(field);
		          	m1.put(field, field);
		        }
			}
		}
		public SFObject(String Id, List<String> Fields, SObject SFObject, String SFType)
        {
        	system.debug('***Fields size = ' + Fields.size());  	
            this.id = Id;
           // this.sfFields = Fields;
            this.sfObject = SFObject;
            this.sfType = SFType;
            
            this.sfFields = new List<String>();
            this.m1 = new Map<String, String>();
            for (String field : Fields) {
				if(!sfFields.contains(field))
		        {
		        	system.debug('***sfFields field = ' + field);  
		          	sfFields.add(field);
		          	system.debug('***sfFields added = ' + sfFields.size());  	
		          	if(sfObject.get(field) != null)
		          		m1.put(field, sfObject.get(field).toString());
		          	else
		          		m1.put(field, '');
		          	system.debug('***m1 added = ' + m1.size());  	
		          	system.debug('***m1  = ' + m1);  	
		        }
			}
        }
		public String id { get; set; }
		public List<String> sfFields { get; set; }
		public SObject sfObject { get; set; }
		public String sfType { get; set; }
		public Map<String, String> m1 { get; set; }
	}
}