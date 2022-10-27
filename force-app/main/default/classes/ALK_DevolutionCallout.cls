public class ALK_DevolutionCallout extends ALK_StandardCallout { 
   public ALK_DevolutionCalloutResponseWrapper getDevolutions(String invoiceNumber) {  
    	ALK_DevolutionCalloutResponseWrapper result = new ALK_DevolutionCalloutResponseWrapper();{}
        //try{
            result = (ALK_DevolutionCalloutResponseWrapper)super.execute(invoiceNumber);
       	/*}
        catch(Exception ex) {
           // This part need to be reviewed when the error messagem. 
            result.isSucceeded = false;
            result.statusCode = 0;
            result.status = ex.getMessage();
        }*/
        
        return result; 
    }
    
    protected override ALK_API_Callouts__mdt getCalloutConfig() {
        return ALK_API_Callouts__mdt.getInstance('ALK_Devolution_Callout'); 
    }
    
    protected override String getEndpoint(ALK_API_Callouts__mdt config, object requestWrapper) {      
        return 'callout:'+String.format(config.ALK_Path__c, new String[]{(String)requestWrapper});
    }    

    protected override String getPathParams(object requestWrapper) {
        return '';
    }
    
    protected override Map<String, Object> getPayLoad(object requestWrapper) {
        Map<String, Object> bodyPayload = new map<String, Object>();            
        return bodyPayload;        
    }
    
    protected override Object getResponse(HttpResponse response) {
		ALK_DevolutionCalloutResponseWrapper result = new ALK_DevolutionCalloutResponseWrapper(); 
        
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            result.isSucceeded = true;
            result.devolutions = new List<ALK_DevolutionCalloutResponseWrapper.ALK_DevolutionWrapper>();
            
            List<Object> resultPayload = (List<Object>)JSON.deserializeUntyped(response.getBody());
            
            for(Object devolutionPayLoad : resultPayload) {
                Map<String,object> devolutionPayLoadItem = (Map<String,object>)devolutionPayLoad;
                
                ALK_DevolutionCalloutResponseWrapper.ALK_DevolutionWrapper devolution = new ALK_DevolutionCalloutResponseWrapper.ALK_DevolutionWrapper();

                devolution.user = (String)devolutionPayLoadItem.get('USER1');
                devolution.devolutionNumber = (String)devolutionPayLoadItem.get('NUMERO_DEVOLUCION');
                devolution.description = (String)devolutionPayLoadItem.get('DESCRIPCION');
                devolution.reason = (String)devolutionPayLoadItem.get('MOTIVO');
                devolution.businessUnit = (String)devolutionPayLoadItem.get('UNIDAD_NEGOCIO');
                devolution.category = (String)devolutionPayLoadItem.get('CATEGORIA');
                devolution.address = (String)devolutionPayLoadItem.get('DIRECCION');
                devolution.invoiceNumber = (String)devolutionPayLoadItem.get('NO_FACTURA');
                devolution.ean = (String)devolutionPayLoadItem.get('EAN');
                devolution.provider = (String)devolutionPayLoadItem.get('PROVEEDOR');
                devolution.salesType = (String)devolutionPayLoadItem.get('TIPO_VENTA');
                //Modify Date 29/06/2022
                //Modify by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com.
                //Change :the data type of devolutionDate before was DateTime and 
                //now is String
                devolution.devolutionDate = (String)devolutionPayLoadItem.get('FECHA_DEVOLUCION');
                devolution.key = (String)devolutionPayLoadItem.get('KEY');
                
                result.devolutions.add(devolution);
            }
                         
        } else {
            // This part need to be reviewed when the error messagem be available from SIAF. 
            result.isSucceeded = false;
        }
        
        result.statusCode = response.getStatusCode();
        result.status = response.getStatus();        
        
        return result;        
    }
}