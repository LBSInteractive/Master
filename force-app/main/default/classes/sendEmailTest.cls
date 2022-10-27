@IsTest
public class sendEmailTest {
    
    @TestSetup
    public static void setup() {
        
      List<Account> accRecords = new List<Account>();
      List<WorkOrder> woRecords = new List<WorkOrder>();
      List<ServiceAppointment> saRecords = new List<ServiceAppointment>();

        
      //Inserting Operating Hours
      OperatingHours operatingHours = new OperatingHours(
          			Name = 'Test OH',
          			TimeZone = 'Asia/Tokyo');
      insert operatingHours;
        
      //Inserting Service Territory 
      ServiceTerritory st1 = new ServiceTerritory ( 
                   Name     = 'Test ST',
                   OperatingHoursId        =operatingHours.id,
                   IsActive  = true );
      insert st1;
        
      //Inserting Work Type
      WorkType workType = new WorkType(
           			Name = 'Test WorkType',
        			DurationType = 'Hours',
       				EstimatedDuration = 2);
      insert workType;
        
      //Inserting List of accounts
      for(Integer i=0;i<100;i++){
          Account acc = new Account(
          			PersonEmail  = 'swissad@salesforce.com',
          			LastName     =  'Test Account'+i,
          			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
          );
      	  accRecords.add(acc);
      }
      insert accRecords;
        
      //Inserting List of Work Orders 
      for(Integer i=0;i<100;i++){
        	WorkOrder wo = new WorkOrder(
                    ServiceTerritoryId    = st1.Id,
                    WorkTypeId            = workType.id,
                    AccountId             = accRecords[i].Id
                    );
            woRecords.add(wo);
         }
      insert woRecords;
        
      //Inserting List of Work Orders 
      for(Integer i=0;i<100;i++){
        	ServiceAppointment sa = new ServiceAppointment(
                    ServiceTerritoryId    = st1.Id,
                    ParentRecordId        = woRecords[i].Id,
                    //AccountId             = accRecords[i].Id,
                 	Status 				  = 'No Asignada',
                	EarliestStartTime     = System.today(),
                	DueDate 			  = System.today()
                    );
            saRecords.add(sa);
         }
      insert saRecords;
        
      ContentVersion contentVersion = new ContentVersion(
      Title = 'Penguins',
      PathOnClient = 'Penguins.jpg',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
     );
     insert contentVersion;  
        
     List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

     //create ContentDocumentLink  record 
     ContentDocumentLink cdl = New ContentDocumentLink();
     cdl.LinkedEntityId = saRecords[0].id;
     cdl.ContentDocumentId = documents[0].Id;
     cdl.shareType = 'V';
     insert cdl;
        
    }
    
    @IsTest
    static void testSendMail() {
        List<ServiceAppointment> sas = [SELECT Id FROM ServiceAppointment ];
        Set<Id> saIds = new Set<Id>();
        for(ServiceAppointment sa: sas){
            saIds.add(sa.id);
        }
 		ContentDocumentLink cdl = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: saIds LIMIT 1];
        
        ServiceReport srRecord = new ServiceReport(
        				ParentId 				  = cdl.LinkedEntityId,
            			DocumentBody 			  = Blob.valueOf('Test Content'), 
        				DocumentContentType       ='application/pdf',
            			DocumentName 			  ='Test'
        );
        insert srRecord;
        Test.startTest();
        
    	Test.stopTest();
        
    }

}