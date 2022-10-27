public with sharing class ALK_DispatchCallout extends ALK_StandardCallout {
   public ALK_DispatchCalloutResponseWrapper searchDispatch(String invoiceNumber) {
    	ALK_DispatchCalloutResponseWrapper result = new ALK_DispatchCalloutResponseWrapper();{}
        try{
            result = (ALK_DispatchCalloutResponseWrapper)super.execute(invoiceNumber);
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
        return ALK_API_Callouts__mdt.getInstance('ALK_Dispatch_Search_Callout'); 
    }

    protected override String getPathParams(object requestWrapper) {
        return '/'+requestWrapper;
    }
    
    protected override Map<String, Object> getPayLoad(object requestWrapper) {
        Map<String, Object> bodyPayload = new map<String, Object>();  
        return bodyPayload;        
    }
    
    protected override Object getResponse(HttpResponse response) {
		ALK_DispatchCalloutResponseWrapper result = new ALK_DispatchCalloutResponseWrapper();   
        
       // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            result.isSucceeded = true;
        result.dispatch = new ALK_DispatchCalloutResponseWrapper.ALK_DispatchWrapper();

        Map<String, Object> payLoadHead = (Map<String, Object>)JSON.deserializeUntyped(response.getBody()); 
        
        // head fields
        result.dispatch.fechaFactura = (String)payLoadHead.get('fechaFactura');             
        result.dispatch.noFactura = (String)payLoadHead.get('noFactura');             
        result.dispatch.documentoFactura = (String)payLoadHead.get('documentoFactura');             
        result.dispatch.clienteFactura = (String)payLoadHead.get('clienteFactura');             
        result.dispatch.documentoEnvio = (String)payLoadHead.get('documentoEnvio');             
        result.dispatch.clienteEnvio = (String)payLoadHead.get('clienteEnvio');             
        result.dispatch.unidadVenta = (String)payLoadHead.get('unidadVenta');             
        result.dispatch.link = (String)payLoadHead.get('link');             
        result.dispatch.canal = (String)payLoadHead.get('canal'); 
        result.dispatch.email =  (String)payLoadHead.get('email');         
        result.dispatch.details = new List<ALK_DispatchCalloutResponseWrapper.ALK_DispatchDetailWrapper>();             
        
        for(object payLoadDetail : (List<Object>)payLoadHead.get('productos')) {
            Map<String, Object> resultPayloadItem = (Map<String, Object>)payLoadDetail;
            
            ALK_DispatchCalloutResponseWrapper.ALK_DispatchDetailWrapper detail = new ALK_DispatchCalloutResponseWrapper.ALK_DispatchDetailWrapper();
            
            // Detail fields
            detail.ean = (String)resultPayloadItem.get('ean');  
            detail.descripcion = (String)resultPayloadItem.get('descripcion');  
            detail.no_despacho = (String)resultPayloadItem.get('no_despacho');  
            detail.unidadDespacho = (String)resultPayloadItem.get('unidadDespacho');  
            detail.cantidadDespacho = (Integer)resultPayloadItem.get('cantidadDespacho');  
            detail.noLinea = (Integer)resultPayloadItem.get('noLinea');  
            detail.transportador = (String)resultPayloadItem.get('transportador');  
            detail.transportadorHomologado = (String)resultPayloadItem.get('transportadorHomologado');  
            detail.noGuia = (String)resultPayloadItem.get('noGuia');  
            detail.direccion = (String)resultPayloadItem.get('direccion');  
            detail.codCiudad = (String)resultPayloadItem.get('codCiudad');  
            detail.ciudad = (String)resultPayloadItem.get('ciudad');   
            detail.codDepartamento = (String)resultPayloadItem.get('codDepartamento');   
            detail.Departamento = (String)resultPayloadItem.get('Departamento');  
            detail.telefono = (String)resultPayloadItem.get('telefono');  
            detail.fechaDespacho = (String)resultPayloadItem.get('fechaDespacho');  
            detail.fechaPactada = (String)resultPayloadItem.get('fechaPactada');  
            detail.fechaReal = (String)resultPayloadItem.get('fechaReal');  
            detail.fechaReprogramada = (String)resultPayloadItem.get('fechaReprogramada');  
            detail.tipoDespacho = (String)resultPayloadItem.get('tipoDespacho');  
            detail.reexpedicion = (String)resultPayloadItem.get('reexpedicion');  
            detail.estado = (String)resultPayloadItem.get('estado');  
            detail.fechaUltimoEstado = (String)resultPayloadItem.get('fechaUltimoEstado');  
            detail.observacionesUltimoEstado = (String)resultPayloadItem.get('observacionesUltimoEstado');  
            detail.usuarioUltimoEstado = (String)resultPayloadItem.get('usuarioUltimoEstado');  
            detail.gestionDespacho = (Integer)resultPayloadItem.get('gestionDespacho');  
            detail.noPedido = (String)resultPayloadItem.get('noPedido');  
            detail.noConsigment = (String)resultPayloadItem.get('noConsigment');  
            detail.barrio = (String)resultPayloadItem.get('barrio');  
            detail.cantidad=(Integer)resultPayloadItem.get('cantidad'); 
            detail.marca=(String)resultPayloadItem.get('marca'); 
            detail.observacionesPS=(String)resultPayloadItem.get('observacionesPS'); 
            detail.unidadDestino=(String)resultPayloadItem.get('unidadDestino'); 
            detail.unidadDestino=(String)resultPayloadItem.get('unidadDestino'); 
            detail.fechaCreacionRma=(String)resultPayloadItem.get('fechaCreacionRma'); 
            detail.fechaProgramadaRecogida=(String)resultPayloadItem.get('fechaProgramadaRecogida'); 
            detail.fechaRealRecogida=(String)resultPayloadItem.get('fechaRealRecogida'); 
            detail.motivoRma=(String)resultPayloadItem.get('motivoRma'); 
            detail.tipoRma=(Integer)resultPayloadItem.get('tipoRma'); 
            detail.reRma=(Integer)resultPayloadItem.get('reRma'); 
            result.dispatch.details.add(detail);
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