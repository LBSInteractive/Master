public class ALK_DevolutionCalloutResponseWrapper {
public String status='';
public Integer statusCode;
public Boolean isSucceeded;
@AuraEnabled    
public List<ALK_DevolutionWrapper> devolutions;

public class ALK_DevolutionWrapper {
    @AuraEnabled        
    public String user;
    @AuraEnabled        
    public String devolutionNumber;
    @AuraEnabled        
    public String description;
    @AuraEnabled        
    public String reason;
    @AuraEnabled
    public String businessUnit;
    @AuraEnabled        
    public String category;
    @AuraEnabled        
    public String address;
    @AuraEnabled        
    public String invoiceNumber;
    @AuraEnabled        
    public String ean;
    @AuraEnabled        
    public String provider;
    @AuraEnabled        
    public String salesType;
    @AuraEnabled   
    //Modify Date 29/06/2022
    //Modify by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com.
    //Change :the data type of devolutionDate before was DateTime and 
    //now is String     
    public String devolutionDate;
    @AuraEnabled        
    public string key;
}
}