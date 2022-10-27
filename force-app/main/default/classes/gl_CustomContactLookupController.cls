global class gl_CustomContactLookupController {
    public List<Contact> contact_results {get;set;} // search results
    public string searchString {get;set;} // search keyword, set either by invoking page or via URI
    public string firstName {get;set;} // set by invoking page
    public string lastName {get;set;} // set by invoking page
    public string email {get;set;} // set by invoking page
    public string phoneNumber {get;set;}  
    public static string ixnId {get;set;} // interaction id, set via URI

    //sortby and limit to lookup page : EASFP-51, EASFP-54
    public string sortBy {get;set;}
    public string searchLimit {get;set;}
    
    public gl_CustomContactLookupController() {
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        ixnId = System.currentPageReference().getParameters().get('ixnId');
        system.debug('*** CustomContactLookupController ixnId ' + ixnId);
        system.debug('*** CustomContactLookupController search for '+searchString);
        
        //Passing sortby and limit to lookup page : EASFP-51, EASFP-54
        sortBy = System.currentPageReference().getParameters().get('sortBy');
        searchLimit = System.currentPageReference().getParameters().get('limit');
        system.debug('*** CustomContactLookupController sort results by ' + sortBy);
        system.debug('*** CustomContactLookupController search results limit '+searchLimit);   
        
        if (searchString != '' && searchString != null) {
            runSearch();  
        }
    }
   
    // performs the keyword search
    global PageReference search() {
        system.debug('*** search');
        runSearch();
        return null;
    }
    
  
    // prepare the query and issue the search command
    private void runSearch() {
        system.debug('*** runSearch');
        performSearch(searchString, sortBy, searchLimit);         
    } 
    
    //Fix for contact duplicate issue - Putting the results inside the map: EASFP-50
    public void updateContactResults(Map<Id,Contact> contactMap,List<Contact> resultObjects){
        for(Contact resultObj : resultObjects){
            contactMap.put(resultObj.Id,resultObj);
        }
    }
  
    // run the search and save the records found. 
    private void performSearch(string searchString, String sortBy, String searchLimit) {
        system.debug('*** performSearch for ' + searchString);

        List<List<SObject>> objs = null;
        contact_results = new List<Contact>();
        Integer listSize = 0;
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        String addOnQuery = '';
        
        system.debug('*** phoneNumber = ' + phoneNumber);
        system.debug('*** firstName = ' + firstName);
        system.debug('*** lastName = ' + lastName);
        system.debug('*** email = ' + email);

        if (searchString != null && searchString != '') {
        	system.debug('*** performSearch for before replace all');
        	searchString = searchString.replaceAll('MyAmpersand','\\&'); 
        	searchString = searchString.replaceAll('SingleQuote','\\\''); 
        	system.debug('*** performSearch for searchString after modification: ' + searchString);
			List<Contact> test = (List<Contact>)System.JSON.deserialize(searchString, List<Contact>.class);
            
            //Fix for contact duplicate issue: EASFP-50
            //contact_results.addAll((List<Contact>) test);
            updateContactResults(contactMap,(List<Contact>) test);

			/* 
            objs = [find :searchString in phone fields returning Contact(Account.Name, Account.BillingPostalCode, Id, 
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
            */
        } 
        system.debug('*** contact_results from searchString = ' + contactMap.values());

        
        try {
            //Add on query for sortby and limit: EASFP-51, EASFP-54
            system.debug('*** sortBy = ' + sortBy);
            if(sortBy != null && sortBy.equalsIgnoreCase('LastModifiedDate')){
                addOnQuery = ' ORDER BY LastModifiedDate DESC ';
                gl_ContactWrapper.enableSortByLastModifiedDate();
            }
            if(searchLimit != null && searchLimit != ''){
                addOnQuery = addOnQuery + ' LIMIT ' + searchLimit;
            }else{
                system.debug('*** searchLimit is not configured, set to default 1000');
                searchLimit = '1000';
            }
            system.debug('*** searchLimit = ' + searchLimit);
            system.debug('*** Is Sorting by LastModifiedDate enabled for final sorting = ' + gl_ContactWrapper.sortByLastModifiedDate);

            
        	if(phoneNumber != null && phoneNumber != ''){
                //Query is updated for sorting and limiting the results: EASFP-51, EASFP-54
                String query = 'find :phoneNumber in phone fields returning Contact(Account.Name, Account.BillingPostalCode, Id, '
                                + 'Name, FirstName, LastName, '
                                + 'MailingStreet, '
                                + 'EMail, '
                                + 'Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone, LastModifiedDate ' + addOnQuery +')';
                objs = search.query(query);
            	listSize = objs.size();
            	system.debug('*** contact listSize = ' + listSize);
            	system.debug('*** objs = ' + objs);
            	system.debug('*** contact objs[0] = ' + objs[0]);
            	if (!objs.isEmpty()) {
                    //contact_results.addAll((List<Contact>) objs[0]);
                    updateContactResults(contactMap,(List<Contact>) objs[0]);
            	}
            }
            
            if (firstName != null && firstName != '') {
                string term = '%' + firstName + '%'; 
                system.debug('*** contact search term = ' + term);
                //Query is updated for sorting and limiting the results and fix for first name issue: EASFP-51, EASFP-54, EASFP-52
                String query = 'find :term in name fields returning Contact(Account.Name, Account.BillingPostalCode, Id, '
                    + 'Name, FirstName, LastName, '
                    + 'MailingStreet, '
                    + 'EMail, '
                    + 'Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone, LastModifiedDate WHERE firstName LIKE :term ' + addOnQuery +')';
                objs = search.query(query);

            	listSize = objs.size();
            	system.debug('*** contact listSize1 = ' + listSize);
            	system.debug('*** objs = ' + objs);
            	system.debug('*** contact objs[0] = ' + objs[0]);
            	if (!objs.isEmpty()) {
                    //contact_results.addAll((List<Contact>) objs[0]);
                    updateContactResults(contactMap,(List<Contact>) objs[0]);
            	}
                
            }

            if (lastName != null && lastName != '') {
                string term1 = '%' + lastName + '%';   
                system.debug('*** contact search last name term = ' + term1);
                //Query is updated for sorting and limiting the results and fix for last name issue: EASFP-51, EASFP-54, EASFP-52
                String query = 'find :term1 in name fields returning Contact(Account.Name, Account.BillingPostalCode, Id, '
                   + 'Name, FirstName, LastName, '
                   + 'MailingStreet, '
                   + 'EMail, '
                   + 'Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone, LastModifiedDate WHERE LastName LIKE :term1 ' + addOnQuery +')';
                objs = search.query(query);

            	listSize = objs.size();
            	system.debug('*** contact listSize2 = ' + listSize);
            	system.debug('*** objs = ' + objs);
            	system.debug('*** contact objs[0] = ' + objs[0]);
            	if (!objs.isEmpty()) {
                    //contact_results.addAll((List<Contact>) objs[0]);
                    updateContactResults(contactMap,(List<Contact>) objs[0]);
            	}  
                
            } 
            
            if (email != null && email != '') {
                //string term2 = '%' + email + '%';
                string term2 = email + '*';
                 system.debug('*** contact search email term = ' + term2);
                //Query is updated for sorting and limiting the results: EASFP-51, EASFP-54
                String query = 'find :term2 in email fields returning Contact(Account.Name, Account.BillingPostalCode, Id, '
                    + 'Name, FirstName, LastName, '
                    + 'MailingStreet, '
                    + 'EMail, '
                    + 'Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone, LastModifiedDate ' + addOnQuery +')';
                objs = search.query(query);

            	listSize = objs.size();
            	system.debug('*** contact listSize3 = ' + listSize);
            	system.debug('*** objs = ' + objs);
            	system.debug('*** contact objs[0] = ' + objs[0]);
            	if (!objs.isEmpty()) {
                    //contact_results.addAll((List<Contact>) objs[0]);
                    updateContactResults(contactMap,(List<Contact>) objs[0]);
            	}  
               
            }         
            system.debug('*** TOTAL contact_results= ' + contactMap.values());

            // Use custom sorting
            if (contactMap.size() != 0) {
                List<gl_ContactWrapper> myresult = new List<gl_ContactWrapper>();
                for (Contact c : contactMap.values()) {
                    myresult.add(new gl_ContactWrapper(c));
                }
                myresult.sort();

                contact_results.clear();
                //Limiting the search results to configured limit or default 1000 (VF allows only 1000) : EASFP-51
                Integer count=0;
                for (gl_ContactWrapper gl_c : myresult) {
                    count = count + 1;
                    if(count <= Integer.ValueOf(searchLimit)){
                        contact_results.add(gl_c.getContact());
                    }
                }

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
}