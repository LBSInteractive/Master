@isTest
public class UserForTestFactory {

    public static User getUserForMobileTest() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Tecnico de campo Externo'];
        
        UserRole ur = [SELECT Id FROM UserRole Where Name = ''];
        
        Contact c = new Contact(FirstName = 'Test', LastName = 'Mobile',
        RecordTypeId= Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ALK_Partner_Employee').getRecordTypeId());
        
        insert c;
        
        User result = new User(Alias = 'jpTest', 
                               Email='jpTest@testorg.com',
                               EmailEncodingKey='UTF-8', 
                               LastName='jpTest', 
                               LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', 
                               ProfileId = p.Id,
                               TimeZoneSidKey='America/Los_Angeles', 
                               UserName='jpTest@testorg.com',
                               ContactId = c.Id,
                               UserRoleId = ur.Id);        
        
        insert result;
        
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();

        permissionSetList.add(new PermissionSetAssignment (PermissionSetId = [SELECT Id From PermissionSet Where Name = 'ALK_Tecnico_Campo_Externo' LIMIT 1].Id, 
                                                                   AssigneeId = result.Id));
        
        permissionSetList.add(new PermissionSetAssignment (PermissionSetId = [SELECT Id From PermissionSet Where Name = 'FSL_Mobile_License' LIMIT 1].Id, 
                                                                   AssigneeId = result.Id));
        
        permissionSetList.add(new PermissionSetAssignment (PermissionSetId = [SELECT Id From PermissionSet Where Name = 'FSL_Resource_License' LIMIT 1].Id, 
                                           AssigneeId = result.Id));
        
        permissionSetList.add(new PermissionSetAssignment (PermissionSetId = [SELECT Id From PermissionSet Where Name = 'FSL_Resource_Permissions' LIMIT 1].Id, 
                                           AssigneeId = result.Id));        

/*        permissionSetList.add(new PermissionSetAssignment (PermissionSetId = [SELECT Id From PermissionSet Where Name = 'HealthCloudStandard' LIMIT 1].Id, 
                                           AssigneeId = result.Id));         

        permissionSetList.add(new PermissionSetAssignment (PermissionSetId = [SELECT Id From PermissionSet Where Name = 'HealthCloudUtilizationManagement' LIMIT 1].Id, 
                                           AssigneeId = result.Id)); 

        permissionSetList.add(new PermissionSetAssignment (PermissionSetId = [SELECT Id From PermissionSet Where Name = 'HealthCloudFoundation' LIMIT 1].Id, 
                                           AssigneeId = result.Id));

        permissionSetList.add(new PermissionSetAssignment (PermissionSetId = [SELECT Id From PermissionSet Where Name = 'HealthCloudMemberServices' LIMIT 1].Id, 
                                           AssigneeId = result.Id));     
        
        permissionSetList.add(new PermissionSetAssignment (PermissionSetId = [SELECT Id From PermissionSet Where Name = 'Representante_de_Atendimento_Call_Center' LIMIT 1].Id, 
                                           AssigneeId = result.Id)); 

        permissionSetList.add(new PermissionSetAssignment (PermissionSetId = [SELECT Id From PermissionSet Where Name = 'Administrador_de_Call_Center' LIMIT 1].Id, 
                                           AssigneeId = result.Id));       */                                     
        
        upsert permissionSetList;        
        
        return result;        
    }
}