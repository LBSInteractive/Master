public with sharing class ALK_InfobipCalloutRequestWrapper {

	public static String WHATSAPP = 'whatsapp';    
	public static String SMS = 'sms';    
    
    public String type;
    public String destinationTo;
    public String message;
    public String templateName;
    public String[] templateData;
}