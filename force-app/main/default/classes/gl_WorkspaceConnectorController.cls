//Added 'with sharing' for avoiding sharing warning on checkmarx on 15/04/20
global with sharing class gl_WorkspaceConnectorController {

	public static Boolean personAccountsEnabled = Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
	
	@RemoteAction
	global static String IsPersonAccountEnabled()
	{
		if (personAccountsEnabled == true)
			return 'true';
		return 'false';	
	}
	
	
   	@RemoteAction
   	global static String findContactFromcase(String caseId)
    {
        system.debug('findContactFromcase using  ' + caseId);
        if (caseId == null || caseId == '')
        	return null;       
        String query;
        List<Case> cases = null;
        List<List<SObject>> cobjects = null;
        try {
        	//List<Case> cases = [SELECT ContactId FROM Case WHERE Id= :caseId];   
        	query = 'FIND \'' + caseId + '\' IN ALL FIELDS RETURNING Case(ContactId WHERE Id = \'' + caseId + '\')';
        	cobjects = search.query(query);
        	if (cobjects != null && !cobjects.isEmpty())
        	{
	        	cases = ((List<Case>)cobjects[0]);
         		if(cases != null && !cases.isEmpty()) {
	               // return the first case found (should only be one)                            
	               for (Case c : cases) {
	                   return c.ContactId;
	               } 
	           	}
        	}
        } catch(Exception e){
            return null; 
        }
        return null; 
    }
  

    @RemoteAction
    global static Object findObjectFromANI(String ANI)
    {
        system.debug('*** findObjectFromANIfor '+ANI); 
        Integer listSize = 0; 
        //List<SObject> objList;
        SObject obj_found = null;     
        try{
            
            List<List<SObject>> aobjects = [FIND :ANI IN PHONE FIELDS RETURNING Account];
            if (!aobjects.isEmpty()){
              List<Account> accounts = ((List<Account>)aobjects[0]);
              listSize = accounts.size();
              system.debug('*** accounts listSize = ' + listSize);
              if(listSize > 1){
                    return 'multiple found';
              }
              if(listSize != 0){
                  for (List<SObject> objList : aobjects)
                      for (SObject aobj : objList){
                        obj_found = aobj;
                        system.debug('*** findObjectFromANI account = '+ obj_found.Id);
                  } 
              }
            } 
            
            List<List<SObject>> cobjects = [FIND :ANI IN PHONE FIELDS RETURNING Contact];
            if (!cobjects.isEmpty()){
              List<Contact> contacts= ((List<Contact>)cobjects[0]);
              listSize = contacts.size();
              system.debug('*** contacts listSize = ' + listSize);
              if(listSize > 1){
                    return 'multiple found';
              }
              if(listSize == 1 && obj_found != null){
                    return 'multiple found';
              }
              if(listSize != 0){
                  for (List<SObject> objList : cobjects)
                      for (SObject cobj : objList){
                        obj_found = cobj;
                        system.debug('*** findObjectFromANI contact = '+ obj_found.Id);
                      } 
                  }
            }                      

            List<List<SObject>> lobjects = [FIND :ANI IN PHONE FIELDS RETURNING Lead];
            if (!lobjects.isEmpty()){
              List<Lead> leads= ((List<Lead>)lobjects[0]);
              listSize = leads.size();
              system.debug('*** leads listSize = ' + listSize);              
              if(listSize > 1){
                    return 'multiple found';
              }
              if(listSize == 1 && obj_found != null){
                    return 'multiple found';
              }
              if(listSize != 0){                            
                  for (List<SObject> objList : lobjects)
                      for (SObject lobj: objList){
                        obj_found = lobj;
                        system.debug('*** findObjectFromANI lead= '+obj_found.Id);
                      } 
              }
            }
            
            if(obj_found != null)              
                return obj_found; 
            return 'not found';

        }
        catch(Exception e){
            return 'not found'; 
        }        
    }    
    
    @RemoteAction
    global static Object findObjectFromANIByType(String ANI, String searchObjectType)
    {
        system.debug('*** findObjectFromANIByType for ANI - '+ ANI + ', searchObjectType - ' + searchObjectType);
        Integer listSize = 0;      
        String query;   
        try{        	
        	List<List<SObject>> aobjects = null;  
        	if (searchObjectType == 'contact')
        	{
				//Fix for the issue - search results are not showing on search fields count zero multimatch scenario : EASFP-53
				//query = 'FIND :ANI IN PHONE FIELDS RETURNING Contact';
				query = 'FIND :ANI IN PHONE FIELDS RETURNING Contact(Account.Name, Account.BillingPostalCode, Id, Name, FirstName, LastName, MailingStreet, EMail, Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone, LastModifiedDate)';
        		aobjects = search.query(query);
	            if (aobjects != null && !aobjects.isEmpty()){
	            	List<Contact> contacts = ((List<Contact>)aobjects[0]);
	              	listSize = contacts.size();
	              	system.debug('*** findObjectFromANIByType accounts listSize = ' + listSize);
	              	if(listSize != 0){              	
	                    return contacts; 
	            	}   
	        	}  
        	}       
			else if (searchObjectType.contains('account'))
			{  	
	            if (personAccountsEnabled == false){
		        	query='FIND :ANI IN PHONE FIELDS RETURNING Account(Id, Name,Phone)';  
	            }
	            /*
	            else{
	            	if (searchObjectType == 'personaccount'){
	            		query='FIND :ANI IN PHONE FIELDS RETURNING Account(Id, Name, Phone, IsPersonAccount, PersonEmail where IsPersonAccount = true)'; 
	            	}
	            	else{
	            		query='FIND :ANI IN PHONE FIELDS RETURNING Account(Id, Name, Phone, IsPersonAccount, PersonEmail)'; 
	            	}            	
	            }*/
	            aobjects = search.query(query);
	            
	            if (aobjects != null && !aobjects.isEmpty()){
	            	List<Account> accounts = ((List<Account>)aobjects[0]);
	              	listSize = accounts.size();
	              	system.debug('*** findObjectFromANIByType accounts listSize = ' + listSize);
	              	if(listSize != 0){              	
	                    return accounts;
	              	}
	            }   
            }         
            return 'not found';
        }
        catch(Exception e){
            return 'not found'; 
        }                    
    }    
    
    
    @RemoteAction
    global static Object findContactFromANI(String ANI)
    {
    	system.debug('*** findContactFromANI '+ANI);    
        if (ANI == null || ANI=='')
    		return null;   
        try{                                  
            List<List<SObject>> cobjects = [FIND :ANI IN PHONE FIELDS RETURNING Contact];
            Integer listSize = cobjects.size();
            system.debug('*** listSize = ' + listSize);
            if(listSize > 1){
                    return 'multiple found'; //not expected
            }
            if (!cobjects.isEmpty()){
              List<Contact> contacts = ((List<Contact>)cobjects[0]);
              listSize = contacts.size();
              system.debug('*** contacts listSize = ' + listSize);
              if(listSize > 1){
                    return 'multiple found';
              }
              if(listSize == 0){
                  return 'not found';
              }
              for (List<SObject> objList : cobjects)
                  for (SObject cobj : objList){
                    system.debug('*** findContactFromANI contact = '+ cobj.Id);
                    return cobj;
                  } 
            }
        }
        catch(Exception e){
            return null; 
        } 
        return null;        
    }

    @RemoteAction
    global static Object findContactFromEmailAddress(String address)
    {
		system.debug('*** findObjectFromEmailAddress' + address);   
		if (address == null || address=='')
    		return null; 
    	String query;   
    	List<Contact> contacts = null;
    	List<List<SObject>> cobjects = null;   
		try {
		    //List<Contact> objects = [select name from contact where email= :address ];
		    query='FIND \'' + address + '\' IN ALL FIELDS RETURNING Contact(Name WHERE email = \'' + address + '\')';
        	cobjects = search.query(query);
		    if (cobjects != null && !cobjects.isEmpty())
        	{
        		contacts = ((List<Contact>)cobjects[0]);			    
			    if(contacts != null && !contacts.isEmpty()) {
			    	Integer listSize = contacts.size();
			    	if (listSize == 1){
						for (Contact obj : contacts) {
						    system.debug('*** findContactFromEmailAddress contact = '+ obj.Name);
						    return obj;
						}
			    	}
			    }      
        	}
		}
		catch(Exception e){
		    return null; 
		}  
		return null;       
    }
    
    @RemoteAction
    global static Object findContactFromChatAddress(String theName)
    {
        system.debug('*** findObjectFromChatAddress' + theName); 
        if (theName == null || theName=='')
    		return null; 
    	String query;   
    	List<Contact> contacts = null;
    	List<List<SObject>> cobjects = null;  
        try {
            //List<Contact> objects = [select name from contact where name= :theName];
            query='FIND \'' + theName + '\' IN ALL FIELDS RETURNING Contact(Name WHERE name = \'' + theName + '\')';
        	cobjects = search.query(query);
        	if (cobjects != null && !cobjects.isEmpty())
        	{
        		contacts = ((List<Contact>)cobjects[0]);			    
			    if(contacts != null && !contacts.isEmpty()) {
			    	Integer listSize = contacts.size();
			    	if (listSize == 1){
						for (Contact obj : contacts) {
						    system.debug('*** findContactFromChatAddress contact = '+ obj.Name);
						    return obj;
						}
			    	}
			    }      
        	}
        }
        catch(Exception e){
            return null; 
        } 
        return null; 
    }

        
    @RemoteAction
    global static Object findContactFromWorkItemAddress(String theName)
    {
        system.debug('*** findContactFromWorkItemAddress' + theName);  
        if (theName == null || theName=='')
    		return null; 
    	String query;   
    	List<Contact> contacts = null;
    	List<List<SObject>> cobjects = null;       
        try {
        	query='FIND \'' + theName + '\' IN ALL FIELDS RETURNING Contact(Name WHERE name = \'' + theName + '\')';
        	cobjects = search.query(query);
        	if (cobjects != null && !cobjects.isEmpty())
        	{
        		contacts = ((List<Contact>)cobjects[0]);			    
			    if(contacts != null && !contacts.isEmpty()) {
			    	Integer listSize = contacts.size();
			    	if (listSize == 1){
						for (Contact obj : contacts) {
						    system.debug('*** findContactFromWorkItemAddress contact = '+ obj.Name);
						    return obj;
						}
			    	}
			    }      
        	}
        }
        catch(Exception e){
            return null; 
        }
        return null;         
    }  

    @RemoteAction
    global static Object findContactFromOpenMediaAddress(String theName)
    {
        system.debug('*** findContactFromOpenMediaAddress' + theName); 
        if (theName == null || theName=='')
    		return null; 
    	String query;   
    	List<Contact> contacts = null;
    	List<List<SObject>> cobjects = null;        
        try {
        	query='FIND \'' + theName + '\' IN ALL FIELDS RETURNING Contact(Name WHERE name = \'' + theName + '\')';
        	cobjects = search.query(query);
        	if (cobjects != null && !cobjects.isEmpty())
        	{
        		contacts = ((List<Contact>)cobjects[0]);			    
			    if(contacts != null && !contacts.isEmpty()) {
			    	Integer listSize = contacts.size();
			    	if (listSize == 1){
						for (Contact obj : contacts) {
						    system.debug('*** findContactFromOpenMediaAddress contact = '+ obj.Name);
						    return obj;
						}
			    	}
			    }      
        	}            
            return null; 
        }
        catch(Exception e){
            return null; 
        } 
     
    }
 
 
    @RemoteAction
    global static Object findAccountFromOpenMediaAddress(String theName, String searchObjectType)
    {
        system.debug('*** findAccountFromOpenMediaAddress' + theName + ', searchObjectType - ' + searchObjectType);
        return findObjectByType('Name', theName, searchObjectType);
    }
 
 	@RemoteAction 
 	global static String createActivity(Map<String,String> activityMap, String searchObjectType,Map<String,String> defaulTaskValues){
        system.debug('*** createActivity' );
        String result = 'not found';
                        
        String accountPrefix = Schema.SObjectType.Account.getKeyPrefix();
        String contactPrefix = Schema.SObjectType.Contact.getKeyPrefix();
        String leadPrefix = Schema.SObjectType.Lead.getKeyPrefix(); 
        String casePrefix = Schema.SObjectType.Case.getKeyPrefix(); 
        String taskPrefix = Schema.SObjectType.Task.getKeyPrefix(); 
        
        system.debug('*** createActivity accountPrefix = ' + accountPrefix);
        system.debug('*** createActivity contactPrefix = ' + contactPrefix);
        system.debug('*** createActivity leadPrefix = ' + leadPrefix);
        system.debug('*** createActivity casePrefix = ' + casePrefix);
        system.debug('*** createActivity taskPrefix = ' + taskPrefix);
        

        system.debug('*** createActivity duration = ' + activityMap.get('Call Duration'));
        String callType = activityMap.get('IXN Type');
        String mediaType = activityMap.get('Media Type');
        String d = activityMap.get('DATE');
        system.debug('*** d   '+ d);
        if(d == '0001-01-01 00:00:00')
        	d = '';
        String subject = callType + ' ' + mediaType + ' ' + d; 
        String objectToUse = '';
        String duration = activityMap.get('Call Duration');
        Integer durationInSecs = Integer.valueOf(duration);

        DateTime startDate=null;
        try{
        	startDate = (activityMap.get('StartDate')=='' && activityMap.get('StartDate')==null) ? null : dateTime.valueOf(activityMap.get('StartDate'));
        }catch(Exception e) {
        	system.debug(e); 
        }
        system.debug('*** createActivity start date = ' + startDate);

        DateTime endDate=null;
        try{
        	endDate = (activityMap.get('EndDate')=='' && activityMap.get('EndDate')==null) ? null : dateTime.valueOf(activityMap.get('EndDate'));
        }catch(Exception e) {
        	system.debug(e); 
        }
        
        system.debug('*** createActivity end date = ' + endDate);
        
        if(activityMap.get('sfdc Object Id')!= ''){
                system.debug('*** createActivity sfdc Object Id = ' + activityMap.get('sfdc Object Id'));
                objectToUse = activityMap.get('sfdc Object Id');
        }
         else
        	system.debug('*** createActivity sfdc Object Id is empty ' );
       
        system.debug('*** createActivity for objectToUse ' + objectToUse);      
        
        String prefix = '';
        if(objectToUse != '')
            prefix = objectToUse.substring(0, 3);
        system.debug('*** objectToUse prefix = '+prefix);
        
        String description = activityMap.get('Comments');
       	if (description == null )
        {
        	system.debug('*** createActivity description is null, set it to empty ' );
        	description = '';
        }
        else{
        	system.debug('*** createActivity description = ' + description );
        }
        

        Task t = new Task (
	          Type = 'Call',
	          Status = 'Completed',
	          Subject = subject,
	          CallDurationInSeconds = durationInSecs,            
	          //Start__c = startDate,  //If we want to use the start of the interaction
	          //End__c = endDate,  //If we want to use the end of the interaction
	          Description = description,	         
	          CallDisposition = activityMap.get('Disposition'),
	          CallObject = activityMap.get('GenesysId')
	        ); 
	               
 		try{	         			
 			if(prefix == accountPrefix || prefix == casePrefix){
	          	system.debug('*** create task for account or case as the sfdcobjectId');
	           	system.debug('*** create task Related to - WhatId = ' + objectToUse);
	          	t.put('WhatId',objectToUse);
	        }
	        else{
	        	if(prefix == contactPrefix || prefix == leadPrefix){
	        		system.debug('*** create task for contact or lead as the sfdcobjectId');
	           		system.debug('*** create task Name - WhoId = ' + objectToUse);
	          		t.put('WhoId',objectToUse);
	        	}
	        	else { // Generic object{
	        		system.debug('*** create task for generic object');
	           		system.debug('*** create task Related to - WhatId = ' + objectToUse);
	          		t.put('WhatId',objectToUse);
	        	}
	        }
	              
	        if(prefix == contactPrefix)
	        {
	        	//Following SOQL should not be causing issues with encryption	
	          	Contact contact= [SELECT AccountId, Id FROM Contact WHERE Id= :objectToUse];
	          	system.debug('*** create task for contact');
	          	system.debug('*** create task Related to - WhatId for conact.AccountId= ' + contact.AccountId);
	          	t.put('WhatId',contact.AccountId); 
	        }
	        
	        if (prefix == casePrefix && personAccountsEnabled == false)
	        {
	        	String contactId = findContactFromcase(objectToUse);
	        	if (contactId != null && contactId != '')
	        	{
	        		system.debug('*** create task Name - WhoId = ' + contactId);
	        		t.put('WhoId',contactId);
	        	}        		
			}

			//defaulTaskValues passed to the task params for mapping default values to the task - Case creation features (EASFP-21)
			if(defaulTaskValues!=null){
				system.debug('*** Setting Default Values to Task '+defaulTaskValues);
				for (String key : defaulTaskValues.keySet())
				{
					try{
					t.put(key,defaulTaskValues.get(key));
					}catch(SObjectException e){
						if(e.getMessage().equalsIgnoreCase('Illegal assignment from String to Date'))
							t.put(key,Date.valueOf(defaulTaskValues.get(key)));
						else {
							system.debug('***Exception occurred'+e);
						}
					}
				}

			}
	        
	        String caseId = activityMap.get('sfdcCaseId');
	        if(caseId != '')
	        {
	        	system.debug('*** case Id is exists');
	        	system.debug('*** create task Related to - WhatId is assigned as caseId = ' + caseId);
	        	t.put('WhatId',caseId);
	        }                  
	        String mySFDCfield = '';
	        String mySFDCvalue = '';
	        for (Integer index=1; index<=5; index++){
	        	if (activityMap.get('SFDC'+index+'field') != '' && (activityMap.get('SFDC'+index+'field') != null) && activityMap.get('SFDC'+index+'value') != '' && activityMap.get('SFDC'+index+'value') != null)
		        {
		            mySFDCfield = activityMap.get('SFDC'+index+'field');
		            mySFDCvalue = activityMap.get('SFDC'+index+'value');
		            system.debug('*** mySFDCfield ' + mySFDCfield + ' -- mySFDCvalue ' + mySFDCvalue);
		            t.put(mySFDCfield,mySFDCvalue);
		        }
	        }

			//SFP-1: Map callType field - As it is a restricted picklist, it allows only Inbound, Outbound or Internal. Skip mapping for other values
			String CallTypeValue = activityMap.get('CallType');
			if(CallTypeValue == 'Inbound' || CallTypeValue == 'Outbound' || CallTypeValue == 'Internal')
	        {
	        	system.debug('*** Setting callType field to ' + CallTypeValue);
	        	t.put('CallType', CallTypeValue);
	        }
                            
        	insert t;
        }
        catch(Exception e){
        	return result; 
        }
        system.debug('*** objectToUse Task id = '  +t.Id);
        result = t.Id;
        return result;
     }
     
     //Get Task Desription
	@RemoteAction
	global static String getActivityComments(String taskID)
	{
		try {
           Task myTask = [SELECT Id, Description FROM Task WHERE Id = :taskID];            
           if(myTask != null) {           		
        		String comments = myTask.Description;     		
                system.debug('*** getActivityComment taskId = " + myTask.Id +  comments = ' +  myTask.Description);  
                return comments; 
           }
        } catch(Exception e){
        	System.debug('*** An unexpected error has occurred: ' + e.getMessage());           
        }

       return '';
	}


 	//search for an activity by Genesys Interaction Id
 	@RemoteAction
    global static String findActivity(String connID)
    {
        system.debug('findActivity using  ' + connID);
        String returnValue = null; 
        if(connID == null)
        	return  returnValue;     
        try {
    		system.debug('findActivity using  current userId = ' + UserInfo.getUserId());
    		//For transfer/conference calls, each agent involved can create activities where CallObjects are the same but they are 
        	//assigned to differentusers(agents).  To see if a new activity should be create, make sure no activity with the same connId and assignee
        	//already exists.
        	
        	//The following SOQL should not be conflicting with encryption
           	List<Task> tasks = [SELECT Id FROM Task WHERE CallObject= :connID AND OwnerId = :UserInfo.getUserId()];            
           	if(tasks != null && !tasks.isEmpty()) {
           		system.debug('findActivity tasks size=  ' + tasks.size());
               	// return the first case found (should only be one)                            
               	for (Task t : tasks) {
               		 system.debug('findActivity return task Id=  ' + t.Id);
                   return t.Id;
               	} 
           }
        } catch(Exception e){
        	system.debug('findActivity exception occurrred ' + e.getMessage());
            return returnValue; 
        }
        return returnValue; 
    }    
    
     // Update activity 
    @RemoteAction
    global static String updateActivity(String taskID,Map<String,String> activityMap,Map<String,String> defaulTaskValues)
    {
        system.debug('updateActivity using  taskID = ' + taskID);
        String returnValue = 'ERROR task Id ' + taskID +' not found';
        if(taskID == null)
        	return  returnValue; 
      	String accountPrefix = Schema.SObjectType.Account.getKeyPrefix();
        String contactPrefix = Schema.SObjectType.Contact.getKeyPrefix();
        String leadPrefix = Schema.SObjectType.Lead.getKeyPrefix(); 
        String casePrefix = Schema.SObjectType.Case.getKeyPrefix(); 
        String taskPrefix = Schema.SObjectType.Task.getKeyPrefix(); 
        
        system.debug('*** updateActivity accountPrefix = ' + accountPrefix);
        system.debug('*** updateActivity contactPrefix = ' + contactPrefix);
        system.debug('*** updateActivity leadPrefix = ' + leadPrefix);
        system.debug('*** updateActivity casePrefix = ' + casePrefix);
        system.debug('*** updateActivity taskPrefix = ' + taskPrefix);
        
        try {
           Task myTask = [SELECT Id, Description FROM Task WHERE Id = :taskID];            
           if(myTask != null) {
           		//Comments, Call Result, Call Duration, Name, RelatedTo
           		string useWDEnotes = activityMap.get('Use WDE Notes');
        		system.debug('*** update task useWDEnotes: ' + useWDEnotes);
        		String comments = '';
        		
        		if (useWDEnotes == 'true' || useWDEnotes == 'True')
        			comments = activityMap.get('Comments');
        		else
        		{
        			//The comments are from Salesforce with addition of Email Desription and Chat/SMS transcripts at the end.
        			comments = myTask.Description;
        			if (comments != null && comments != '')
        				comments = comments + '\n' + activityMap.get('Comments');
        			else
        				comments = activityMap.get('Comments');
        		}
        		system.debug('*** update task comments: ' + comments);     
        		myTask.put('Description',comments);
        		String callDisposition = activityMap.get('Disposition');
        		myTask.put('CallDisposition',callDisposition);
        		String duration = activityMap.get('Call Duration');
        		Integer durationInSecs = Integer.valueOf(duration);
        		myTask.put('CallDurationInSeconds',durationInSecs);
        		
        		String objectToUse = '';
        		if(activityMap.get('sfdc Object Id')!= ''){
                	system.debug('*** update task  sfdc Object Id = ' + activityMap.get('sfdc Object Id'));
                	objectToUse = activityMap.get('sfdc Object Id');
        		}
        		String prefix = '';
        		if(objectToUse != '')
           			prefix = objectToUse.substring(0, 3);
        		system.debug('*** prefix = '+prefix);
        		if(prefix == accountPrefix || prefix == casePrefix){
          			system.debug('*** update task for account or case');
          			myTask.put('WhatId',objectToUse);
        		}
        		else{
          			if(prefix == contactPrefix || prefix == leadPrefix){
	        			system.debug('*** Update task for contact or lead as the sfdcobjectId');
	           			system.debug('*** Update task Name - WhoId = ' + objectToUse);
	          			myTask.put('WhoId',objectToUse);
        			}
        		}
              
		        if(prefix == contactPrefix)
		        {
		          Contact contact= [SELECT AccountId, Id FROM Contact WHERE Id= :objectToUse];
		          system.debug('*** Update task for contact');
		          myTask.put('WhatId',contact.AccountId); 
		        }
		        
		        if (prefix == casePrefix && personAccountsEnabled == false)
				{
					String contactId = findContactFromcase(objectToUse);
					if (contactId != null && contactId != '')
					{
						system.debug('*** Update task Name - WhoId = ' + contactId);
						myTask.put('WhoId',contactId);
					}        		
				}
				
				//defaulTaskValues passed to the task params for mapping default values to the task - Case creation features (EASFP-21)
				if(defaulTaskValues!=null){
					system.debug('*** Setting Default Values to Task '+defaulTaskValues);
					for (String key : defaulTaskValues.keySet())
					{
						try{
							myTask.put(key,defaulTaskValues.get(key));
						}catch(SObjectException e){
							if(e.getMessage().equalsIgnoreCase('Illegal assignment from String to Date'))
								myTask.put(key,Date.valueOf(defaulTaskValues.get(key)));
							else {
								system.debug('***Exception occurred'+e);
							}
						}
					}

				}

		        String caseId = activityMap.get('sfdcCaseId');
		        if(caseId != '')
		        	myTask.put('WhatId',caseId);

           		//SFP-2: Mapping Attach data fields on update activity - Fix for Case #0002915182
				String mySFDCfield = '';
				String mySFDCvalue = '';
				for (Integer index=1; index<=5; index++){
					if (activityMap.get('SFDC'+index+'field') != '' && (activityMap.get('SFDC'+index+'field') != null) && activityMap.get('SFDC'+index+'value') != '' && activityMap.get('SFDC'+index+'value') != null)
					{
						mySFDCfield = activityMap.get('SFDC'+index+'field');
						mySFDCvalue = activityMap.get('SFDC'+index+'value');
						system.debug('*** mySFDCfield ' + mySFDCfield + ' -- mySFDCvalue ' + mySFDCvalue);
						myTask.put(mySFDCfield,mySFDCvalue);
					}
				}

				//SFP-1: Map callType field - As it is a restricted picklist, it allows only Inbound, Outbound or Internal. Skip mapping for other values
				String CallTypeValue = activityMap.get('CallType');
				if(CallTypeValue == 'Inbound' || CallTypeValue == 'Outbound' || CallTypeValue == 'Internal')
				{
					system.debug('*** Setting callType field to ' + CallTypeValue);
					myTask.put('CallType', CallTypeValue);
				} 
				
				update myTask;
				returnValue = 'success';

           }
        } catch(DmlException e){
        	System.debug('*** An unexpected error has occurred: ' + e.getMessage());
            returnValue = 'ERROR An unexpected error has occurred: ' + e.getMessage();
        }
        return returnValue; 
    }      	
	
	//Create case - EASFP-21
    @RemoteAction      
    global static String createCase(Map<String,String> caseMap,String objectToUse)
    {        
        system.debug('*** createCase');
        String result = 'case not created';
        Case myCase = new Case();
		// for (String key : caseMap.keySet())
		// {
    	// 	myCase.put(key,caseMap.get(key));
		// }

		// if(caseMap.containsKey('RecordTypeId')){
		// 	try{
		// 		Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(caseMap.get('RecordTypeId')).getRecordTypeId();
		// 		system.debug('***recordTypeId:'+recordTypeId);

		// 		if(recordTypeId!=null)
		// 			myCase.put('RecordTypeId',recordTypeId);
		// 	}catch(Exception e){
		// 		system.debug('*** Unable to set RecordTypeId : Record Type is not available: '+e);
		// 	}
		// }

		
		myCase = updateCaseMap(myCase,objectToUse,caseMap);
        try{                        
                insert myCase;
        }
        catch(Exception e){
                 return result; 
        }
        system.debug('*** Case id = '  +myCase.Id);
        result = myCase.Id;
        return result;
	}
	
	//Update case - EASFP-21
    @RemoteAction      
    global static String updateCase(String caseID,Map<String,String> caseMap,String objectToUse)
	{
		system.debug('*** In updateCase');
		system.debug('*** caseID = ' + caseID);
		String returnValue='case not updated';
		try
		{
			Case myCase= [SELECT AccountId, Id FROM Case WHERE Id= :caseID];
			if(myCase != null) {
				myCase=updateCaseMap(myCase,objectToUse,caseMap);
				update myCase;				
				returnValue = 'success';
			}
		}catch(Exception e){
				System.debug('*** An unexpected error has occurred: ' + e.getMessage());
				returnValue = 'case not updated';
		}
		return returnValue;
	}

	//Update case map with Contact and account details - EASFP-21
	global static Case updateCaseMap(Case myCase,String objectToUse,Map<String,String> caseMapParam)
	{
		system.debug('*** In UpdateCaseMap'); 
		String accountPrefix = Schema.SObjectType.Account.getKeyPrefix();
		String contactPrefix = Schema.SObjectType.Contact.getKeyPrefix();
		String casePrefix = Schema.SObjectType.Case.getKeyPrefix(); 
		
		system.debug('*** accountPrefix = ' + accountPrefix);
		system.debug('*** contactPrefix = ' + contactPrefix);
		system.debug('*** casePrefix = ' + casePrefix);
		
		Map<String,String> caseMap = new Map<String,String>(caseMapParam);

		//Updating default values in the case - EASFP-40
		if(caseMap.containsKey('RecordTypeId')){
			try{
				Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(caseMap.get('RecordTypeId')).getRecordTypeId();
				system.debug('***recordTypeId:'+recordTypeId);
				if(recordTypeId!=null)
					myCase.put('RecordTypeId',recordTypeId);
			}catch(Exception e){
				system.debug('*** Unable to set RecordTypeId : Record Type is not available: '+e);
			}
			caseMap.remove('RecordTypeId');
		}
		for (String key : caseMap.keySet())
		{
			myCase.put(key,caseMap.get(key));
		}

		String prefix = '';
		if(objectToUse != '' && objectToUse != null){
			system.debug('*** sfdc Object Id (objectToUse) = ' + objectToUse);
			prefix = objectToUse.substring(0, 3);
			system.debug('*** sfdc Object Id (objectToUse) prefix = '+prefix);					
			if(prefix == contactPrefix)
			{
				Contact contact= [SELECT AccountId, Id FROM Contact WHERE Id= :objectToUse];
				system.debug('*** Adding to caseMap: '+contact.Id+' and associated account '+ contact.AccountId);
				myCase.put('contactid',contact.Id);
				myCase.put('accountid',contact.AccountId); 				
			}else if(prefix == accountPrefix){
				system.debug('*** Adding to caseMap: account '+ objectToUse);
				myCase.put('accountid',objectToUse); 
			}else if(prefix == casePrefix){
				system.debug('*** Adding to caseMap: parentCase '+ objectToUse);
				myCase.put('ParentId',objectToUse); 
			}
		}
		return myCase;
	}


	//Update case map with Contact and account details - show new case creation page : EASFP-48
	@RemoteAction
	global static Map<String,Object> buildCasePopulationMap(String objectToUse,Map<String,String> caseMap){
		system.debug('*** In buildCasePopulationMap for New case page');
		system.debug('*** sfdc Object Id (objectToUse) = ' + objectToUse);
		system.debug('*** Default values received = ' + caseMap);
		Map<String,Object> fields = new Map<String,Object>();
		try{
			Case myCase = new Case();
			myCase=updateCaseMap(myCase,objectToUse,caseMap);
			fields = mycase.getPopulatedFieldsAsMap();
		}Catch(Exception e){
			system.debug('*** Exception occured ' + e);
		}
		return fields;
	}



   /* @RemoteAction      
    global static String createCase(Map<String,String> caseMap)
    {        
        system.debug('*** createCase');
        String result = 'case not created';
        String ixnType = caseMap.get('IXN Type');
        String mediaType = caseMap.get('Media Type');
        String subject = ixnType + ' ' + mediaType + ' ' + caseMap.get('DATE'); 
		
        Case c = new Case (
        	Subject = subject,
        	Priority = 'Medium',
        	Origin = ixnType       	
        );               
        
        try{                        
                insert c;
        }
        catch(Exception e){
                 return result; 
        }
        system.debug('*** Case id = '  +c.Id);
        result = c.Id;
        return result;
    }  */
      
    @RemoteAction      
	global static String addAttachment(String objectId, String descriptionText, String nameText, String mimeType, Blob attachmentBody, String attachmentId)
    {        
        system.debug('***addAttachment objectId: ' + objectId + ' descriptionText: ' + descriptionText + ' nameText: ' + nameText + ' mimeType: ' + mimeType + 'attachmentId: '  + attachmentId);       
        try{           
 
   			    if(attachmentBody != null) {
                    Attachment att = getAttachment(attachmentId);
                    
                    String newBody = '';
                    if(att.Body != null) {
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }
                    
                    String newAttachmentBody = EncodingUtil.base64Encode(attachmentBody);                    
                    
                    newBody += newAttachmentBody;
                    
                    att.Body = EncodingUtil.base64Decode(newBody);
                    //att.Body = Blob.valueOf(newBody);                    
                    
                    if(attachmentId == null) {
                    	system.debug('*** First time through');
                        att.Name = nameText;
                        att.parentId = objectId;
                    }
                    upsert att;
                    return att.Id;
                } else {
                    return 'error';
                }
        }
        catch(Exception e){
            system.debug('*** addAttachment error ' + e);
            return 'error';
        }
    }
    
	private static Attachment getAttachment(String attId) 
	{
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment 
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }

    @RemoteAction
   	global static Object findCaseObject(String searchFieldName, String searchFieldValue){
        system.debug('*** findCaseObject: searchFieldName - ' + searchFieldName +', searchFieldValue - ' + searchFieldValue);
		Object result = null;
		//Added escapeSingleQuotes for avoiding SOQL injection warning on checkmarx on 15/04/20
		searchFieldName =  String.escapeSingleQuotes(searchFieldName);
		//This line is added for the Cipher Cloud user support
        searchFieldValue =  String.escapeSingleQuotes(searchFieldValue);
        if(searchFieldName == '' || searchFieldValue == '')
			return result;
			
		List<List<SObject>> cObjects = null;
        String query;
        String lowerFieldName = searchFieldName.toLowerCase(); 
        try{
        	if ((lowerFieldName.length() > 8 && (lowerFieldName.substring(0,8) == 'account.' || lowerFieldName.substring(0,8) == 'contact.')) || 
        		(lowerFieldName.length() > 5 && lowerFieldName.substring(0,5) == 'lead.')){
	        	query = 'SELECT Id, ContactId, CaseNumber, Subject, Account.Name, Contact.Name, CreatedDate FROM Case WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\'';
	        	system.debug('***findCaseObject:  Case query = ' + query);  
	        	List<Case> all_cases = Database.query(query);
	        	if (all_cases != null && !all_cases.isEmpty()){ 	        		 
	           		Integer listSize = all_cases.size();	           		
		        	system.debug('***findCaseObject:  Case Count = ' + listSize);
		        	result = all_cases;
	        	}
	        	else
	        		system.debug('***findCaseObject:  Case Count = 0');
	        }
	        else
	        {        	
	        	if (lowerFieldName != 'contactid' && lowerFieldName != 'casenumber' && lowerFieldName != 'subject' && 
	        		lowerFieldName != 'account.name' && lowerFieldName != 'contact.name' && lowerFieldName != 'createddate')
		           	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Case(Id, ContactId, CaseNumber, Subject, Account.Name, Contact.Name, CreatedDate, ' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
		        else
		        	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Case(Id, ContactId, CaseNumber, Subject, Account.Name, Contact.Name, CreatedDate WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
		         		
	           	system.debug('***findCaseObject: Case query = ' + query);   
	           	
	           	cObjects = search.query(query);
				if (cObjects != null){          
		           	List<Case> all_cases = ((List<Case>)cObjects[0]);		          
	           		if (all_cases != null && !all_cases.isEmpty()){ 
	           			Integer listSize = all_cases.size();
		        		system.debug('***findCaseObject: Case Count = ' + listSize);
		        		result = all_cases;
		        	}
		        	system.debug('***findCaseObject:  Case Count = 0');
				}
				else
	        		system.debug('***findCaseObject:  Case Count = 0');
	        }             
        }
        catch(Exception e){
        	system.debug('*** Exception ' + e); 
        }        
        return result;
    } 
 
    @RemoteAction
    global static Object findCaseObjectMapSearch(List<String> sfdcFields, List<String> sfdcValues, Boolean searchAllFields){
    	system.debug('*** findCaseObjectMapSearch:  searchAllFields - ' + searchAllFields);	
        Integer totalCount = 0;
        List<Case> all_cases = new List<Case>();

		if (sfdcFields == null || sfdcValues == null && sfdcFields.size() != sfdcValues.size())
    		return null;
    		
    	for(Integer i = 0; i < sfdcFields.size(); i++)
        {
        	if (sfdcFields[i] != '' && sfdcFields[i] != null && sfdcValues[i] != '' && sfdcValues[i] != null){
 	  	 		String mySFDCfield = sfdcFields[i];
 	  			String mySFDCvalue = sfdcValues[i];
		        system.debug('*** findCaseObjectMapSearch: searchFieldName - ' + mySFDCfield +', searchFieldValue - ' + mySFDCvalue );
		        Object resultObj = findCaseObject(mySFDCfield,mySFDCvalue);
		        if (resultObj != null)
		        {
		        	List<Case> result = (List<Case>)resultObj;
		        	Integer listSize = result.size();
		        	system.debug('*** findCaseObjectMapSearch:  result size= ' + listSize);		        			
				    if (listSize > 0){
					   	for (Case r: result){
					   		Boolean alreadyAdded = false;
					   		for(Case c: all_cases){
			          			if (r.Id == c.Id){
			          				alreadyAdded = true;
			          				break;
			          			}
			          		}
			          		if (alreadyAdded == false){
			          			all_cases.add(r);
			          		}
			          	}				          	    
	        			// If search till first result, stop the search 	  
	        			if  (searchAllFields == false)
	        			{
        					system.debug('*** findCaseObjectMapSearch:  Found some result, stop the search');  
        					break;    
        				} 
		          	}    			
		        }			         
		        	
	        	else
	        		system.debug('*** findCaseObjectMapSearch: go on to next check');
	        }
        } //for loop
        system.debug('*** findCaseObjectMapSearch: search completed');     
       
        if (all_cases != null && all_cases.size() > 0)
        {
        	system.debug('*** findCaseObjectMapSearch: all_cases.size() :' + all_cases.size()); 
        	return all_cases; 
        }
        return null;   
    } 
    
    @RemoteAction
    global static Object findGenericObject(String searchFieldName, String searchFieldValue){
    	system.debug('*** findGenericObject: searchFieldName - ' + searchFieldName +', searchFieldValue - ' + searchFieldValue);
    	Object result = null;
    	String objectName = '';
    	List<List<SObject>> genObjects = null;
    	List<SObject> sObjects = null;
    	Integer listSize = 0;
    	
    	// SearchFieldName in the format - object.field
    	String[] objectFieldPair = searchFieldName.split('\\.'); 
    	system.debug('*** findGenericObject: objectFieldPair - ' + objectFieldPair);
    	objectName = objectFieldPair[0];
    	searchFieldName = objectFieldPair[1];
    	
    	searchFieldName = searchFieldName.removeEnd('\"').removeStart('\"');
        searchFieldValue = searchFieldValue.removeEnd('\"').removeStart('\"');
		
		//Added escapeSingleQuotes for avoiding SOQL injection warning on checkmarx on 15/04/20
		searchFieldName =  String.escapeSingleQuotes(searchFieldName);
		objectName= String.escapeSingleQuotes(objectName);
    	//This line is added for the Cipher Cloud user support
        searchFieldValue =  String.escapeSingleQuotes(searchFieldValue);
        
        if(searchFieldName == '' || searchFieldValue == '')
        	return result;
        String query;
        String lowerFieldName = searchFieldName.toLowerCase();
        
        try{
        	if(lowerFieldName != 'id')
        	{
        		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING ' + objectName + '(Id, ' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
        		system.debug('***Generic object query = ' + query);
        		genObjects = search.query(query);
				if (genObjects != null)          
	           		sObjects = genObjects[0];
        	}
        	else
        	{
        		query = 'Select Id FROM ' + objectName + ' WHERE Id = \'' + searchFieldValue + '\'';
        		system.debug('***Generic object query = ' + query);
        		sObjects = Database.query(query);
        	}
	        if (sObjects != null){
                listSize = sObjects.size();
                system.debug('***Number of fields fetched - ' + listSize);
            	if(listSize == 1){                   
                	system.debug('*** Found one match');   
                	system.debug('***  Id = ' + sObjects[0].Id);             
                }
            }	           			          
        }
        catch(Exception e){
        	system.debug('*** Exception generic object search - ' + e);
        }
        system.debug('*** findGenericObject total search result(s) = ' + listSize);
        
        if (listSize == 0)
        	return 'not found';
        else if (listSize == 1)
        	return sObjects[0];
        else 
        	return 'multiple found';  
    }
            
 	@RemoteAction
    global static Object findObject(String searchFieldName, String searchFieldValue){
        system.debug('*** findObject: searchFieldName - ' + searchFieldName +', searchFieldValue - ' + searchFieldValue);
        Object result = null;
        Integer aListSize = 0, cListSize = 0, lListSize = 0;
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();
        
        List<List<SObject>> cObjects = null;
        List<List<SObject>> aObjects = null;
        List<List<SObject>> lObjects = null; 
        
        searchFieldName = searchFieldName.removeEnd('\"').removeStart('\"');
        searchFieldValue = searchFieldValue.removeEnd('\"').removeStart('\"');
        
        //This line is added for the Cipher Cloud user support
        searchFieldValue =  String.escapeSingleQuotes(searchFieldValue);
        
        if(searchFieldName == '' || searchFieldValue == '')
        	return result;
        String query;
        String lowerFieldName = searchFieldName.toLowerCase();
        	
        //check account
        try{
        	if (lowerFieldName != 'name' && lowerFieldName != 'phone' && lowerFieldName != 'account.name' && lowerFieldName != 'account.phone')
	           	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name,Phone,' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
	        else
	        	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name,Phone' + ' WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
	          		
           	system.debug('*** Account query = ' + query);            
           	aObjects = search.query(query);
			if (aObjects != null){          
	           	accounts =((List<Account>)aObjects[0]);		          
           	}    
          	
            if (accounts != null){
                aListSize = accounts.size();
                if(aListSize == 1){                   
                	system.debug('*** Found one account match');   
                    system.debug('***  Id = ' + accounts[0].Id);
                    system.debug('***  Name = '+ accounts[0].Name);
                    system.debug('*** Phone = '+ accounts[0].Phone);               
                }
            }
        }
        catch(Exception e){
        	system.debug('*** Exception account search' + e);
        }
        
        //check contact
        try{
        	
			if (lowerFieldName != 'name' && lowerFieldName != 'phone' && lowerFieldName != 'contact.name' && lowerFieldName != 'contact.phone')
	           	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Contact(Id, Name,Phone,' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
	        else
	        	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Contact(Id, Name,Phone' + ' WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
	           		
           	system.debug('*** Contact query = ' + query);            
           	cObjects = search.query(query);
			if (cObjects != null){          
	           	contacts =((List<Contact>)cObjects[0]);		          
           	}         
	        if (contacts != null){
	            cListSize = contacts.size();
	            if(cListSize == 1){	           
	            	system.debug('*** Found one contact match');  	             
	                system.debug('***  Id = ' + contacts[0].Id);
	                system.debug('***  Name = '+ contacts[0].Name);
	                system.debug('*** Phone = '+ contacts[0].Phone);	
	            }
	        }
        }
        catch(Exception e){
        	system.debug('*** Exception ' + e); 
        }
        
        //check lead
        try{
        	if (lowerFieldName != 'name' && lowerFieldName != 'phone' && lowerFieldName != 'lead.name' && lowerFieldName != 'lead.phone')
	           	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Lead(Id, Name,Phone,' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
	        else
	        	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Lead(Id, Name,Phone' + ' WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
	          
	        system.debug('*** Lead query = ' + query);            
           	lObjects = search.query(query);
			if (lObjects != null){          
	           	leads =((List<Lead>)lObjects[0]);		          
           	}
	        if (leads != null){
	            lListSize = leads.size();
	            if(lListSize == 1){
	            	system.debug('*** Found one lead match');  
	                system.debug('***  Id = ' + leads[0].Id);
	                system.debug('***  Name = '+ leads[0].Name);
	                system.debug('*** Phone = '+ leads[0].Phone);	                
	            }
	        }
        }
        catch(Exception e){
        	system.debug('*** Exception ' + e); 
        }
        
        
        Integer total = aListSize + cListSize + lListSize;
        system.debug('*** findObject total search result(s) = ' + total);
        
        if (total == 0)
        	return 'not found';
        else if (total == 1){
        	if (aListSize == 1)
        		return accounts[0];
        	else if (cListSize == 1)
        		return contacts[0];
        	else
        		return leads[0];
        }
        else 
        	return 'multiple found';   
    }
    
    //Generic function using list of field/field values
    @RemoteAction
    global static Object findGenericObjectMapSearch(List<String> sfdcFields, List<String> sfdcValues, Boolean searchAllFields ){
        Object result = null;
        Object singleResult = null;
        Integer totalCount = 0;
    	
    	if (sfdcFields == null || sfdcValues == null && sfdcFields.size() != sfdcValues.size())
    		return null;
    		
    	for(Integer i = 0; i < sfdcFields.size(); i++)
        {
        	if (sfdcFields[i] != '' && sfdcFields[i] != null && sfdcValues[i] != '' && sfdcValues[i] != null){
 	  			String mySFDCfield = sfdcFields[i];
 	  			String mySFDCvalue = sfdcValues[i];
	        	system.debug('*** findGenericObjectMapSearch: mySFDCfield - ' + mySFDCfield +', mySFDCvalue - ' + mySFDCvalue);
	        	result = findGenericObject(mySFDCfield,mySFDCvalue);
	        	if (result != null && result != 'not found')
	        	{
	        		if (result == 'multiple found')
	        			return result;
	        		else //only one found for the current field and field-value
	        		{
	        			//store in case result gets overwritten by not found in next field/fieldValue searches
	        			singleResult = result;  
	        			if  (searchAllFields == false)
	        				break;
	        			else{
	        				totalCount ++;
	        		 	if (totalCount > 1)
	        				return 'multiple found';
	        			}
	        		}     			
	        	}		         
	        }
	        else
	        	system.debug('*** findGenericObjectMapSearch go on to next check');  
        }
        system.debug('*** findGenericObjectMapSearch totalCount = ' + totalCount +  ' result = ' + result + ' singleResult = ' + singleResult);
        
        if (totalCount == 1)
        	return singleResult;
        else
        	return result;  
    } 
    
   //Overload function using list of field/field values
    @RemoteAction
    global static Object findObjectMapSearch(List<String> sfdcFields, List<String> sfdcValues, Boolean searchAllFields ){
        Object result = null;
        Object singleResult = null;
        Integer totalCount = 0;
    	
    	if (sfdcFields == null || sfdcValues == null && sfdcFields.size() != sfdcValues.size())
    		return null;
    		
    	for(Integer i = 0; i < sfdcFields.size(); i++)
        {
        	if (sfdcFields[i] != '' && sfdcFields[i] != null && sfdcValues[i] != '' && sfdcValues[i] != null){
 	  			String mySFDCfield = sfdcFields[i];
 	  			String mySFDCvalue = sfdcValues[i];
	        	system.debug('*** findObjectMapSearch: mySFDCfield - ' + mySFDCfield +', mySFDCvalue - ' + mySFDCvalue);
	        	result = findObject(mySFDCfield,mySFDCvalue);
	        	if (result != null && result != 'not found')
	        	{
	        		if (result == 'multiple found')
	        			return result;
	        		else //only one found for the current field and field-value
	        		{
	        			//store in case result gets overwritten by not found in next field/fieldValue searches
	        			singleResult = result;  
	        			if  (searchAllFields == false)
	        				break;
	        			else{
	        				totalCount ++;
	        		 	if (totalCount > 1)
	        				return 'multiple found';
	        			}
	        		}     			
	        	}		         
	        }
	        else
	        	system.debug('*** findObjectMapSearch go on to next check');  
        }
        system.debug('*** findObjectMapSearch totalCount = ' + totalCount +  ' result = ' + result + ' singleResult = ' + singleResult);
        
        if (totalCount == 1)
        	return singleResult;
        else
        	return result;  
    }  
    
     @RemoteAction
     global static Object findObjectByType(String searchFieldName, String searchFieldValue, String searchObjectType){
    	system.debug('*** findObjectByType: searchFieldName - ' + searchFieldName +', searchFieldValue - ' + searchFieldValue +', searchObjectType - ' + searchObjectType);
 		
    	List<Account> account_results = new List<Account>();
    	List<Contact> contact_results = new List<Contact>();
    	//This line is added for the Cipher Cloud user support
        searchFieldValue =  String.escapeSingleQuotes(searchFieldValue);
        
        if(searchFieldName == '' || searchFieldValue == '' && (searchObjectType == 'account' || searchObjectType == 'personaccount' ))
        	return account_results;    
        	
        if(searchFieldName == '' || searchFieldValue == '' && searchObjectType == 'contact')
       		return contact_results;  
       
       	String lowerFieldName = searchFieldName.toLowerCase();
        String query;
        
        if (searchObjectType == 'contact')
    	{        		
    		try{
    			//Added LastModifiedDate in find queries for supporting sort by LastModifiedDate in contactlookup page : EASFP-54
    	      	if (lowerFieldName != 'account.name' &&lowerFieldName != 'account.billingpostalcode' && lowerFieldName != 'name' &&lowerFieldName != 'firstname' && lowerFieldName != 'lastname' &&
    	      		lowerFieldName != 'mailingstreet' && lowerFieldName != 'email' && 
    	      		lowerFieldName != 'phone' && lowerFieldName != 'mobilephone' && lowerFieldName != 'homephone' && lowerFieldName != 'assistantphone' && lowerFieldName != 'otherphone')
	           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Contact(Id, Account.Name, Account.BillingPostalCode, Name, FirstName, LastName, MailingStreet, EMail, Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone, LastModifiedDate, ' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
	           	else
	           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Contact(Id, Account.Name, Account.BillingPostalCode, Name, FirstName, LastName, MailingStreet, EMail, Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone, LastModifiedDate WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
	           		
	           	system.debug('*** Contact query = ' + query);            
	           	List<List<sObject>> searchList = search.query(query);
				if (searchList != null){          
		           	List<Contact> contacts =((List<Contact>)searchList[0]);
		            if (!contacts.isEmpty()){
		                Integer listSize = contacts.size();
		                system.debug('*** Contact Count = ' + listSize);
		                if(listSize != 0){					
			            	contact_results.addAll(contacts);
			            	return  contact_results; //RETURN IF ANY RESULTS CAME
				        }
		            }
	           	}
	        }
	        catch(Exception e){
	        	system.debug('*** findObjectByType Exception ' + e);        	
	        }
    	}
        else if (searchObjectType.contains('account'))
        {
        	if (searchObjectType == 'account' && personAccountsEnabled == false)
	        {      	
	
		        try{
		        	if (lowerFieldName != 'name' && lowerFieldName != 'phone' && lowerFieldName != 'account.name' && lowerFieldName != 'account.phone')
		           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name,Phone,' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
		           	else
		           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name,Phone' + ' WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
		           		
		           	system.debug('*** Account query = ' + query);            
		           	List<List<sObject>> searchList = search.query(query);
					if (searchList != null){          
			           	List<Account> accounts =((List<Account>)searchList[0]);
			            if (!accounts.isEmpty()){
			                Integer listSize = accounts.size();
			                system.debug('*** Account Count = ' + listSize);
			                if(listSize != 0){					
				            	account_results.addAll(accounts);
				            	return  account_results; //RETURN IF ANY RESULTS CAME
					        }
			            }
		           	}
		        }
		        catch(Exception e){
		        	system.debug('*** findObjectByType Exception ' + e);        	
		        }
	        	
	        }  
	        /*else if (personAccountsEnabled == true)
	        {
		        try{	        	
		        	if (searchObjectType == 'personaccount'){	
		           		if(lowerFieldName != 'name' && lowerFieldName != 'phone' && lowerFieldName != 'account.name' && lowerFieldName != 'account.phone' && lowerFieldName != 'ispersonaccount' && lowerFieldName != 'personemail'){
			           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name, Phone, IsPersonAccount, PersonEmail,'+searchFieldName+' WHERE IsPersonAccount = true AND ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
		           		}  
			           	else{
			           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name, Phone, IsPersonAccount, PersonEmail WHERE IsPersonAccount = true AND ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
			           	}
		        	}
		        	else{ //Business and Person Account both
		       			if(lowerFieldName != 'name' && lowerFieldName != 'phone' && lowerFieldName != 'account.name' && lowerFieldName != 'account.phone' && lowerFieldName != 'ispersonaccount' && lowerFieldName != 'personemail')
			           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name,Phone, IsPersonAccount, PersonEmail,'+searchFieldName+ ' WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
			           	else
			           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name, Phone, IsPersonAccount, PersonEmail WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
		   
		        	}
		        	system.debug('*** Account query = ' + query);  
		        	List<List<sObject>> searchList = search.query(query);
		           
		           	if (searchList != null){          
			           	List<Account> accounts =((List<Account>)searchList[0]);
			            if (!accounts.isEmpty()){
			                Integer listSize = accounts.size();
			                system.debug('*** Account Count = ' + listSize);
			                if(listSize != 0){					
				            	account_results.addAll(accounts);
				            	return  account_results; //RETURN IF ANY RESULTS CAME
					        }
			            }
		           	}
		        }
		        catch(Exception e){
		        	system.debug('*** Exception ' + e);        	
		        }
	        } */  
	        return account_results;
        	
        }
        return null;     
    }  
    
    
    
    //Overload function using list of field/field values
    @RemoteAction
    global static Object findObjectByTypeMapSearch(List<String> sfdcFields, List<String> sfdcValues, Boolean searchAllField, String searchObjectType){
   		system.debug('*** findObjectByTypeMapSearch: searchAllField - ' + searchAllField +', searchObjectType - ' + searchObjectType);
 	  	List<Account> account_results = new List<Account>(); 	
 	  	List<Contact> contact_results = new List<Contact>(); 	  	
 	  	
 	  	if (sfdcFields == null || sfdcValues == null && sfdcFields.size() != sfdcValues.size())
    		return null;
    		
    	for(Integer i = 0; i < sfdcFields.size(); i++)
        {
        	if (sfdcFields[i] != '' && sfdcFields[i] != null && sfdcValues[i] != '' && sfdcValues[i] != null){
 	  			String mySFDCfield = sfdcFields[i];
 	  			String mySFDCvalue = sfdcValues[i];
        		system.debug('*** findObjectByTypeMapSearch: searchFieldName - ' + mySFDCfield +', searchFieldValue - ' + mySFDCvalue +', searchObjectType - ' + searchObjectType);
        		Object resultObj = findObjectByType(mySFDCfield,mySFDCvalue, searchObjectType);  
        		
        		if (resultObj != null)
        		{
        			if (searchObjectType == 'account' || searchObjectType == 'personaccount')
        			{
	        			List<Account> result =  (List<Account>)resultObj;
	        			Integer listSize = result.size();
	        			system.debug('*** findObjectByTypeMapSearch:  result size= ' + listSize);    
	        			if (listSize > 0){		        			
		        			for (Account r: result){
				          		Boolean alreadyAdded = false;
				          		for(Account ar: account_results){
				          			if (ar.Id == r.Id){
				          				alreadyAdded = true;
				          				break;
				          			}
				          		}
				          		if (alreadyAdded == false){
				          			account_results.add(r);
				          		}
				          	}
		        			// If search till first result, stop the search 	  
		        			if  (searchAllField == false)
		        			{
		        				system.debug('*** findObjectByTypeMapSearch:  Found some result, stop the search');  
		        				break;    
		        			} 		
	        			}	
        			}
        			else if (searchObjectType == 'contact')
        			{
        				List<Contact> result =  (List<Contact>)resultObj;
	        			Integer listSize = result.size();
	        			system.debug('*** findObjectByTypeMapSearch:  result size= ' + listSize);    
	        			if (listSize > 0){		        			
		        			for (Contact r: result){
				          		Boolean alreadyAdded = false;
				          		for(Contact ar: contact_results){
				          			if (ar.Id == r.Id){
				          				alreadyAdded = true;
				          				break;
				          			}
				          		}
				          		if (alreadyAdded == false){
				          			contact_results.add(r);
				          		}
				          	}
		        			// If search till first result, stop the search 	  
		        			if  (searchAllField == false)
		        			{
		        				system.debug('*** findObjectByTypeMapSearch:  Found some result, stop the search');  
		        				break;    
		        			} 		
	        			}        				
        			}        			
        		}
	        	else
	        		system.debug('*** findObjectByTypeMapSearch: go on to next check');
        	}        	
        } 
        system.debug('*** findObjectByTypeMapSearch: search completed');  
		if (searchObjectType == 'account' || searchObjectType == 'personaccount')  
        	return account_results;
        else if (searchObjectType == 'contact')
        	return contact_results;
        else
        	return null;
    }

	//SFP-5: Get Presence Status Id
	@RemoteAction
	global static String getPresenceStatusId(String apiName)
	{
		try {		
			
           List<ServicePresenceStatus> apiIds = [SELECT Id FROM ServicePresenceStatus WHERE developername = :apiName limit 1];            
           if(apiIds != null && apiIds.size() > 0) {           		
        		String statusId = apiIds[0].Id;     		
                system.debug('*** getPresenceStatusId statusId = " + statusId  ');  
                return statusId; 
           }
        } catch(Exception e){
        	System.debug('*** An unexpected error has occurred: ' + e.getMessage());           
        }
       return '';
	}
      
    @RemoteAction
    global static String testConnection()
    {   
    	return 'Active';
    }
        
	//The method below is for the support of activating Mark Done and Call Result from Salesforce to Genesys WDE
    @AuraEnabled
    public static Sobject getRecords(Id recordId, String fieldsToShow) {
    	try
    	{
	    	system.debug('*** getRecords recordId = " + recordId  ' + 'fieldsToShow = ' + fieldsToShow);  
	    	system.debug('*** getRecords recordId.getSobjectType() = ' + recordId.getSobjectType());
	    	system.debug('*** getRecords recordId.getSobjectType().getDescribe() = ' + recordId.getSobjectType().getDescribe());
	    	system.debug('*** getRecords recordId.getSobjectType().getDescribe().getName() = ' + recordId.getSobjectType().getDescribe().getName());
	        String objectName = recordId.getSobjectType().getDescribe().getName();
	        //Added escapeSingleQuotes for avoiding SOQL injection warning on checkmarx on 15/04/20
			String soql = 'Select '+ String.escapeSingleQuotes(fieldsToShow)+'  from ' + objectName + ' where Id = :recordId';
		    System.debug('getRecords Query:'+soql);
			Sobject rec = Database.query(soql);
	        system.debug('*** getRecords rec = ' + rec);
	        return rec;
    	}catch(Exception e){
        	System.debug('*** getRecords An unexpected error has occurred: ' + e.getMessage());           
        }
       return null;
    	
    }   

}