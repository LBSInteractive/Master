public with sharing class ALK_ProductDetailCallout  extends ALK_StandardCallout { 
   public ALK_ProductDetailCalloutResponseWrapper getProductDetail(ALK_InvoiceCalloutRequestWrapper request) {  
    	ALK_ProductDetailCalloutResponseWrapper result = new ALK_ProductDetailCalloutResponseWrapper();{}
        try{
            result = (ALK_ProductDetailCalloutResponseWrapper)super.execute(request);
       	}
        catch(Exception ex) {
           // This part need to be reviewed when the error messagem. 
            result.isSucceeded = false;
            result.statusCode = 0;
            result.status = ex.getMessage();
        }
        
        return result; 
    }
    
    protected override ALK_API_Callouts__mdt getCalloutConfig() {
        return ALK_API_Callouts__mdt.getInstance('ALK_Product_Detail_Callout'); 
    }
    
    protected override String getEndpoint(ALK_API_Callouts__mdt config, object requestWrapper) {
        ALK_InvoiceCalloutRequestWrapper request = (ALK_InvoiceCalloutRequestWrapper)requestWrapper;        
        return 'callout:'+String.format (config.ALK_Path__c, new String[]{request.invoice});
    }    

    protected override String getPathParams(object requestWrapper) {
        ALK_InvoiceCalloutRequestWrapper request = (ALK_InvoiceCalloutRequestWrapper)requestWrapper;
        return '/'+request.ean+'?businessUnit='+request.bu;
    }
    
    protected override Map<String, Object> getPayLoad(object requestWrapper) {
        Map<String, Object> bodyPayload = new map<String, Object>();            
        return bodyPayload;        
    }
    
    protected override Object getResponse(HttpResponse response) {
		ALK_ProductDetailCalloutResponseWrapper result = new ALK_ProductDetailCalloutResponseWrapper(); 
        
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            result.isSucceeded = true;
            Map<String, Object> resultPayload = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
			System.debug('resultPayload -> ' + resultPayload);
            result.detail.SETID = (String)resultPayload.get('SETID');
            result.detail.productId = (String)resultPayload.get('PRODUCT_ID');
            result.detail.description = (String)resultPayload.get('DESCR');
            result.detail.groupCode = (String)resultPayload.get('CK_COD_GRUPO');
            result.detail.groupDescription = (String)resultPayload.get('DESCR3');
            result.detail.divisionCode = (String)resultPayload.get('CK_COD_DIVISION');
            result.detail.divisionDescription = (String)resultPayload.get('DESCR4');
            result.detail.lineCode = (String)resultPayload.get('CK_COD_LINEAS');
            result.detail.lineDescription = (String)resultPayload.get('DESCR_4');
            result.detail.subLineCode = (String)resultPayload.get('CK_COD_SUBLINEA');
            result.detail.subLineDescription = (String)resultPayload.get('DESCR30');
            result.detail.categoryCode = (String)resultPayload.get('CATEGORY_ID');
            result.detail.categoryDescription = (String)resultPayload.get('DESCR1');
            result.detail.subCategoryCode = (String)resultPayload.get('CK_COD_SUBCATEG');
            result.detail.subCategoryDescription = (String)resultPayload.get('DESCR2');
            result.detail.familyCode = (String)resultPayload.get('INV_PROD_FAM_CD');
            result.detail.familyDescription = (String)resultPayload.get('DESCR40');
            result.detail.brandCode = (String)resultPayload.get('PROD_BRAND');
            result.detail.brandDescription = (String)resultPayload.get('DESCR15');                           
        } else {
            // This part need to be reviewed when the error messagem be available from SIAF. 
            result.isSucceeded = false;
        }
        
        result.statusCode = response.getStatusCode();
        result.status = response.getStatus();        
        
        return result;        
    }
}