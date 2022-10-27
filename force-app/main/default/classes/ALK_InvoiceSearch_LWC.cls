public without sharing class ALK_InvoiceSearch_LWC {
    @AuraEnabled
    public static List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> searchInvoice(String customerId, Date startDate, Date endDate) {
        return ALK_InvoiceService.searchInvoice(customerId, startDate, endDate);
    }
    
    //DGMS 03/08/2022 change supported by BUG 13581
    //Updated the method searchInvoiceDetail to support to use the ALK_InvoiceService.searchInvoiceDetail API without the location.
    @AuraEnabled
    public static List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> searchInvoiceDetail(String invoiceNumber, String location) {
        List<Schema.Location> locationList = [SELECT ID, ALK_Unidad_de_Venta__c FROM Location WHERE ID = :location];
        if(!locationList.isEmpty()){
            return ALK_InvoiceService.searchInvoiceDetail(invoiceNumber, locationList[0].ALK_Unidad_de_Venta__c);
        }
        else{
            return ALK_InvoiceService.searchInvoiceDetail(invoiceNumber, '');
        }
    }   
    
    @AuraEnabled
    public static List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> searchInvoiceDetailBU(String invoiceNumber, String location) {
        return ALK_InvoiceService.searchInvoiceDetail(invoiceNumber, location);
        
    } 
    
    //DGMS 03/08/2022 change supported by the BUG 13519
    //Create that method to add a new way to get the documentation number.
    @AuraEnabled
    public static string getIdentification(String recordId) {
        string idNumber;
        List<Case> caseData = new List<Case>();
        caseData=[Select Id,Account.ALK_Identification_Id__c from case where Id=:recordId limit 1];
        List<Account> accntData =new List<Account>();
        accntData= [Select Id,ALK_Identification_Id__c from Account where Id=:recordId limit 1];
        if(caseData.size()>0){
            idNumber=caseData[0].Account.ALK_Identification_Id__c;
        }else if(accntData.size()>0){
            idNumber=accntData[0].ALK_Identification_Id__c;
        }else{
            idNumber= null;
        }       
        return idNumber;
        
    } 
    
    @AuraEnabled
    public static ALK_ProductDetailCalloutResponseWrapper.ALK_ProductDetailWrapper searchProductDetailBU(String invoiceNumber, String location, String ean) {
        system.debug('** ean'+ean+'** invoiceNumber '+invoiceNumber+'** location '+location);
        return ALK_InvoiceService.searchProductDetail(invoiceNumber, location, ean);
        
    }    
    @AuraEnabled
    public static List<ALK_DevolutionCalloutResponseWrapper.ALK_DevolutionWrapper> searchDevolutions(String invoiceNumber) {
        system.debug('** invoiceNumber '+invoiceNumber);
        return ALK_InvoiceService.searchDevolutions(invoiceNumber);
        
    }  
    /**************************************************************************************************************************************
*   Author: Daniel Murcia Suarez daniel.murcia@globant.com
*   Date :06-Jul-2022
*   Test Class: ALK_InvoiceSearch_LWCTest [Code Coverage: 92%]
**
* -------------------------------------
*            No.    Date           Author                           Description      
*            ----   ----------     ---------------------------     -------------    
* @version   1.0    06-Jul-2022    Daniel Murcia Suarez DGMS      Creation of the method assignInvoice to create and
* @version   2.0    13-Jul-2022    Daniel Murcia Suarez DGMS      Creation of the method searchInvoiceDetailRMA and assignInvoiceRMA
to create and assign the invoice to the case the type RMA.                                                                      assign the invoice to the case.           
****************************************************************************************************************************************/
    
    @AuraEnabled
    public static String assignInvoice (String jsonData,String caseId) {
        String responseStr;
        List<ALK_invoiceWrapper> invoiceDataInp = ALK_invoiceWrapper.parse(jsonData);       
        try { 
            List <Case> relatedCase = new List <Case>([Select Id,ALK_INVOICE_TYPE__c,ALK_Almacen__c from case where Id=:caseId limit 1]);
            ALK_Invoice_setting__mdt iStngs =ALK_Invoice_setting__mdt.getInstance(relatedCase[0].ALK_INVOICE_TYPE__c);
            Id rtInv =Schema.SObjectType.ALK_Invoice__c.getRecordTypeInfosByName().get(iStngs.Invoice_Record_Type_Name__c).getRecordTypeId();
            Id storeId=srchStore(invoiceDataInp[0].business_unit);
            ALK_Invoice__c invObj= new ALK_Invoice__c();
            invObj.ALK_Case__c=caseId;
            assignStore(relatedCase[0],storeId);
            invObj.RecordTypeId=rtInv;
            invObj.ALK_Warehouse__c=storeId;
            invObj.Name=invoiceDataInp[0].invoice;
            //Date dtInv = string.isNotBlank(invoiceDataInp[0].opendate)?Date.valueOf(invoiceDataInp[0].opendate):null;
            invObj.ALK_Invoice_Date__c= invoiceDataInp[0].opendate!=null?DateTime.newInstance(invoiceDataInp[0].opendate.year(), invoiceDataInp[0].opendate.month(),invoiceDataInp[0].opendate.day(),00,00,00):null;
            
            invObj.ALK_EAN__c=invoiceDataInp[0].eanCode;
            invObj.ALK_Description__c=invoiceDataInp[0].description;
            invObj.ALK_Quantity__c=invoiceDataInp[0].qty;
            invObj.ALK_Value__c=invoiceDataInp[0].total;
            invObj.ALK_NIT_Purchaser__c=invoiceDataInp[0].nit_comprador;
            invObj.ALK_Purchaser_Name__c=invoiceDataInp[0].nombre_comprador;
            invObj.ALK_Purchaser_Phone__c=invoiceDataInp[0].phone_comprador;
            invObj.ALK_Order_Number__c=invoiceDataInp[0].pedido;
            invObj.ALK_Devolucion_Value__c=invoiceDataInp[0].devolutionNumber!=null&&invoiceDataInp[0].total!=null?invoiceDataInp[0].total:null;//pending to clarify
            datetime dtDev=invoiceDataInp[0].devolutionDate!=null?datetime.newInstanceGmt(Integer.valueof(invoiceDataInp[0].devolutionDate.substring(6,10)),
                                                                                          Integer.valueof(invoiceDataInp[0].devolutionDate.substring(0,2)),
                                                                                          Integer.valueof(invoiceDataInp[0].devolutionDate.substring(3,5)),
                                                                                          Integer.valueof(invoiceDataInp[0].devolutionDate.substring(11,13)),
                                                                                          Integer.valueof(invoiceDataInp[0].devolutionDate.substring(14,16)),
                                                                                          Integer.valueof(invoiceDataInp[0].devolutionDate.substring(17,19))):null;
            invObj.ALK_Devolution_Date__c= dtDev;
            invObj.ALK_Devolution_Number__c=invoiceDataInp[0].devolutionNumber;
            invObj.ALK_Devolution_Reason2__c=invoiceDataInp[0].reason;
            invObj.ALK_Devolution_Store__c=invoiceDataInp[0].businessUnit;
            invObj.ALK_Division__c=invoiceDataInp[0].divisionDescription;
            invObj.ALK_Family__c=invoiceDataInp[0].categoryDescription;
            invObj.ALK_Group__c=invoiceDataInp[0].groupDescription;
            invObj.ALK_Provider__c=invoiceDataInp[0].brandDescription;
            invObj.ALK_Brand__c=invoiceDataInp[0].brandCode;
            invObj.ALK_Delivery_Days_Dt__c=invoiceDataInp[0].dtCntDays;
            invObj.ALK_NIT_Send__c=invoiceDataInp[0].nit_envio;
            invObj.ALK_Actual_Delivery_Date__c=invoiceDataInp[0].dtCntDays!=null?DateTime.newInstance(invoiceDataInp[0].dtCntDays.year(), invoiceDataInp[0].dtCntDays.month(),invoiceDataInp[0].dtCntDays.day(),00,00,00):null;
            invObj.ALK_Send_Name__c=invoiceDataInp[0].cltEnv;
            insert invObj;
            responseStr='Success '+invObj.Id;
        } catch (DmlException e) {            
            responseStr='Error '+e;
            throw new ALK_InvSrchLWCException(responseStr);
        }
        return responseStr;
    }
    
    @AuraEnabled
    public static List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> searchInvoiceDetailRMA(String invoiceNumber) {
        return ALK_InvoiceService.searchInvoiceDetail(invoiceNumber,'');
    } 
    
    @AuraEnabled
    public static String searchRMA(String invoiceNumber) {
        ALK_DispatchCalloutResponseWrapper.ALK_DispatchWrapper responseFnl=ALK_RMAService.searchDispatch(invoiceNumber);
        return JSON.serialize(responseFnl);
    }  
    
    @AuraEnabled
    public static String assignInvoiceRMA (String jsonData,String caseId) {
        String responseStr;    
        List<ALK_invoiceWrapperRMA> invoiceDataInpRMA = ALK_invoiceWrapperRMA.parse(jsonData);   
        try { 
            List <Case> relatedCase = new List <Case>([Select Id,ALK_INVOICE_TYPE__c,ALK_Almacen__c from case where Id=:caseId limit 1]);
            ALK_Invoice_setting__mdt iStngs =ALK_Invoice_setting__mdt.getInstance(relatedCase[0].ALK_INVOICE_TYPE__c);
            Id rtInv =Schema.SObjectType.ALK_Invoice__c.getRecordTypeInfosByName().get(iStngs.Invoice_Record_Type_Name__c).getRecordTypeId();
            Id storeId=srchStore(invoiceDataInpRMA[0].unidadVenta);
            ALK_Invoice__c invObj= new ALK_Invoice__c();
            invObj.ALK_Case__c=caseId;
            assignStore(relatedCase[0],storeId);
            invObj.RecordTypeId=rtInv;
            invObj.Name=invoiceDataInpRMA[0].invoice;
            Date dtInv = string.isNotBlank(invoiceDataInpRMA[0].fechaFactura)?Date.parse(invoiceDataInpRMA[0].fechaFactura):null;
            DateTime dtTmInv = dtInv!= null?DateTime.newInstance(dtInv.year(),dtInv.month(),dtInv.day(),00,00,00):null;
            invObj.ALK_Invoice_Date__c=dtTmInv;
            invObj.ALK_Purchase_Date__c=dtTmInv;
            invObj.ALK_Quantity__c=invoiceDataInpRMA[0].qty;
            invObj.ALK_Warehouse__c=storeId;
            invObj.ALK_Unit_Collects__c=invoiceDataInpRMA[0].unidadRecoge;
            invObj.ALK_Guide_Number__c=invoiceDataInpRMA[0].noGuia;
            invObj.ALK_RMA_Number__c=invoiceDataInpRMA[0].noRMA;
            invObj.ALK_RMA_Reason__c=invoiceDataInpRMA[0].motivoRma;
            invObj.ALK_Last_State__c=invoiceDataInpRMA[0].estado;
            invObj.ALK_Last_Observation__c=invoiceDataInpRMA[0].ultimaObservacion;
            invObj.ALK_Address__c=invoiceDataInpRMA[0].direccion;
            invObj.ALK_City__c=invoiceDataInpRMA[0].ciudad;
            invObj.ALK_Purchaser_Phone__c=invoiceDataInpRMA[0].telefono;
            invObj.ALK_Conveyor__c=invoiceDataInpRMA[0].transportador;
            invObj.ALK_Approved_Transporter__c=invoiceDataInpRMA[0].transportadorH;
            datetime dtSch=String.isNotBlank(invoiceDataInpRMA[0].fechaProgramadaRecogida)?datetime.newInstance(Integer.valueof(invoiceDataInpRMA[0].fechaProgramadaRecogida.substring(0,4)),Integer.valueof(invoiceDataInpRMA[0].fechaProgramadaRecogida.substring(5,7)),Integer.valueof(invoiceDataInpRMA[0].fechaProgramadaRecogida.substring(8,10)),0,0,0):null;
            invObj.ALK_Schedule_Date_Collected__c=dtSch; 
            invObj.ALK_Observations__c=invoiceDataInpRMA[0].observacionesPS;
            invObj.ALK_Provider__c=invoiceDataInpRMA[0].brandDescription;
            invObj.ALK_Brand__c=invoiceDataInpRMA[0].brandCode;
            invObj.ALK_EAN__c=invoiceDataInpRMA[0].ean;
            invObj.ALK_Description__c=invoiceDataInpRMA[0].descripcion;
            invObj.ALK_Status__c=invoiceDataInpRMA[0].estado;
            invObj.ALK_Last_State_Date__c=string.isNotBlank(invoiceDataInpRMA[0].fechaUltimoEstado)?datetime.valueOfGmt(invoiceDataInpRMA[0].fechaUltimoEstado):null;
            invObj.ALK_Link_Voz_Cliente__c=invoiceDataInpRMA[0].link;
            invObj.ALK_Purchaser_Name__c=invoiceDataInpRMA[0].clienteFactura;
            invObj.ALK_ID_Customer_Sent__c=invoiceDataInpRMA[0].documentoEnvio;
            invObj.ALK_NIT_Send__c=invoiceDataInpRMA[0].documentoEnvio;                
            invObj.ALK_NIT_Invoice__c=invoiceDataInpRMA[0].documentoFactura;
            invObj.ALK_Linea__c=string.valueOf(invoiceDataInpRMA[0].noLinea);
            invObj.ALK_Group__c=invoiceDataInpRMA[0].groupDescription;                 
            invObj.ALK_Family__c=invoiceDataInpRMA[0].familyDescription;                
            invObj.ALK_NIT_Purchaser__c=invoiceDataInpRMA[0].documentoFactura;     
            invObj.ALK_Value__c=invoiceDataInpRMA[0].valor;      
            invObj.ALK_Order_Number__c=invoiceDataInpRMA[0].noPedido;      
            insert invObj;
            responseStr='Success '+invObj.Id;
        } catch (DmlException e) {
            responseStr='Error '+e;
            throw new ALK_InvSrchLWCException(responseStr);
        }
        return responseStr;
    } 
    
    @AuraEnabled
    public static String assignInvoiceDes (String jsonData,String caseId) {
        String responseStr;    
        List<ALK_invoiceWrapperDsp> invoiceDataInpDsp = ALK_invoiceWrapperDsp.parse(jsonData);   
        try { 
            List <Case> relatedCase = new List <Case>([Select Id,ALK_INVOICE_TYPE__c,ALK_Almacen__c from case where Id=:caseId limit 1]);
            ALK_Invoice_setting__mdt iStngs =ALK_Invoice_setting__mdt.getInstance(relatedCase[0].ALK_INVOICE_TYPE__c);
            Id rtInv =Schema.SObjectType.ALK_Invoice__c.getRecordTypeInfosByName().get(iStngs.Invoice_Record_Type_Name__c).getRecordTypeId();
            Id storeId=srchStore(invoiceDataInpDsp[0].unidadVenta);
            ALK_Invoice__c invObj= new ALK_Invoice__c();
            invObj.ALK_Case__c=caseId;
            assignStore(relatedCase[0],storeId);
            invObj.RecordTypeId=rtInv;
            invObj.Name=invoiceDataInpDsp[0].invoice;        
            invObj.ALK_NIT_Purchaser__c=invoiceDataInpDsp[0].documentoFactura; 
            invObj.ALK_Purchaser_Name__c=invoiceDataInpDsp[0].clienteFactura;
            invObj.ALK_Purchaser_Phone__c=invoiceDataInpDsp[0].telefono; 
            invObj.ALK_Address__c=invoiceDataInpDsp[0].direccion;
            invObj.ALK_City__c=invoiceDataInpDsp[0].ciudad;
            invObj.ALK_Order_Number__c=invoiceDataInpDsp[0].noPedido;
            invObj.ALK_NIT_Send__c=invoiceDataInpDsp[0].documentoEnvio;  
            invObj.ALK_ID_Customer_Sent__c=invoiceDataInpDsp[0].documentoEnvio;      
            invObj.ALK_NIT_Invoice__c=invoiceDataInpDsp[0].documentoFactura;
            invObj.ALK_EAN__c=invoiceDataInpDsp[0].ean;    
            invObj.ALK_Description__c=invoiceDataInpDsp[0].descripcion; 
            invObj.ALK_Dispatch_Number__c=invoiceDataInpDsp[0].noDespacho;  
            invObj.ALK_Dispactch_Type__c=invoiceDataInpDsp[0].tipoDespacho;   
            invObj.ALK_Dispatch_Unit__c=invoiceDataInpDsp[0].unidadDespacho;  
            Date dtDes = string.isNotBlank(invoiceDataInpDsp[0].fechaDespacho)?Date.parse(invoiceDataInpDsp[0].fechaDespacho):null;                
            DateTime dtTmDes  = dtDes!= null?DateTime.newInstance(dtDes.year(),dtDes.month(),dtDes.day(),0,0,0):null;
            invObj.ALK_Dispatch_Date__c=dtTmDes;     
            invObj.ALK_Dispatch_Management__c=String.valueof(invoiceDataInpDsp[0].gestionDespacho); 
            invObj.ALK_Consigment_Number__c=invoiceDataInpDsp[0].noConsigment;     
            invObj.ALK_Conveyor__c=invoiceDataInpDsp[0].transportador; 
            invObj.ALK_Approved_Transporter__c=invoiceDataInpDsp[0].transportadorH;        
            invObj.ALK_Devolution_Number__c=invoiceDataInpDsp[0].devolutionNumber;         
            invObj.ALK_Devolution_Reason2__c=invoiceDataInpDsp[0].reason; 
            datetime dtDevDsp=invoiceDataInpDsp[0].devolutionDate!=null?datetime.newInstanceGmt(Integer.valueof(invoiceDataInpDsp[0].devolutionDate.substring(6,10)),
                                                                                                Integer.valueof(invoiceDataInpDsp[0].devolutionDate.substring(0,2)),
                                                                                                Integer.valueof(invoiceDataInpDsp[0].devolutionDate.substring(3,5)),
                                                                                                Integer.valueof(invoiceDataInpDsp[0].devolutionDate.substring(11,13)),
                                                                                                Integer.valueof(invoiceDataInpDsp[0].devolutionDate.substring(14,16)),
                                                                                                Integer.valueof(invoiceDataInpDsp[0].devolutionDate.substring(17,19))):null;
            invObj.ALK_Devolution_Date__c= dtDevDsp;            
            invObj.ALK_Devolution_Store__c=invoiceDataInpDsp[0].businessUnit;    
            if(invoiceDataInpDsp[0].devolutionNumber!= null){
                invObj.ALK_Devolucion_Value__c=invoiceDataInpDsp[0].valor; 
            }     
            Date dtInv = string.isNotBlank(invoiceDataInpDsp[0].fechaFactura)?Date.parse(invoiceDataInpDsp[0].fechaFactura):null;                
            DateTime dtTmInv = dtInv!= null?DateTime.newInstance(dtInv.year(),dtInv.month(),dtInv.day(),0,0,0):null;
            invObj.ALK_Invoice_Date__c=dtTmInv;   
            invObj.ALK_Purchase_Date__c=dtTmInv;  
            invObj.ALK_Quantity__c=invoiceDataInpDsp[0].qty;
            invObj.ALK_Warehouse__c=storeId;
            invObj.ALK_Sell_Channel__c=invoiceDataInpDsp[0].canal;
            invObj.ALK_Brand__c=invoiceDataInpDsp[0].brandCode;
            invObj.ALK_Group__c=invoiceDataInpDsp[0].groupDescription;              
            invObj.ALK_Family__c=invoiceDataInpDsp[0].familyDescription;   
            invObj.ALK_Provider__c=invoiceDataInpDsp[0].brandDescription;
            invObj.ALK_Linea__c=string.valueOf(invoiceDataInpDsp[0].noLinea);
            invObj.ALK_Guide_Number__c=invoiceDataInpDsp[0].noGuia;
            invObj.ALK_Unit_Collects__c=invoiceDataInpDsp[0].unidadRecoge; 
            datetime dtSch=String.isNotBlank(invoiceDataInpDsp[0].fechaProgramadaRecogida)?datetime.newInstance(Integer.valueof(invoiceDataInpDsp[0].fechaProgramadaRecogida.substring(0,4)),Integer.valueof(invoiceDataInpDsp[0].fechaProgramadaRecogida.substring(5,7)),Integer.valueof(invoiceDataInpDsp[0].fechaProgramadaRecogida.substring(8,10)),0,0,0):null;
            invObj.ALK_Schedule_Date_Collected__c=dtSch;
            invObj.ALK_Last_State__c=invoiceDataInpDsp[0].estado;
            invObj.ALK_Last_State_Date__c=string.isNotBlank(invoiceDataInpDsp[0].fechaUltimoEstado)?datetime.valueOfGmt(invoiceDataInpDsp[0].fechaUltimoEstado):null;
            invObj.ALK_Observations__c=invoiceDataInpDsp[0].observacionesPS;
            invObj.ALK_Last_Observation__c=invoiceDataInpDsp[0].ultimaObservacion;
            invObj.ALK_Link_Voz_Cliente__c=invoiceDataInpDsp[0].link; 
            Date dtDesRl = string.isNotBlank(invoiceDataInpDsp[0].fechaReal)?Date.parse(invoiceDataInpDsp[0].fechaReal):null;                
            DateTime dtTmDesRl  = dtDes!= null?DateTime.newInstance(dtDes.year(),dtDes.month(),dtDes.day(),00,00,00):null;
            invObj.ALK_Actual_Delivery_Date__c=dtTmDesRl;
            Date dtPc = string.isNotBlank(invoiceDataInpDsp[0].fechaPactada)?Date.valueOf(invoiceDataInpDsp[0].fechaPactada):null;                
            DateTime dtTmPc = dtPc!= null?DateTime.newInstance(dtPc.year(),dtPc.month(),dtPc.day(),0,0,0):null;                 
            invObj.ALK_Agreed_Delivery_Date__c=dtTmPc; 
            invObj.ALK_Departamento_Comprador__c=invoiceDataInpDsp[0].State;
            invObj.ALK_Reissue__c=invoiceDataInpDsp[0].reexpedicion;
            invObj.ALK_Send_Name__c=invoiceDataInpDsp[0].clienteEnvio;
            insert invObj;
            responseStr='Success '+invObj.Id;
        } catch (DmlException e) {
            responseStr='Error '+e;
            throw new ALK_InvSrchLWCException(responseStr);
        }
        return responseStr;
    } 
    
    public static void assignStore (Case caseObj, Id storeId){
        caseObj.ALK_Almacen__c=storeId;
        update caseObj;
    }

    public static Id srchStore (string bssUnt){
        List <Schema.Location> rtrnLct=[Select Id, Name,ALK_Unidad_de_Venta__c from Location where ALK_Unidad_de_Venta__c=:bssUnt LIMIT 1];
        return rtrnLct.size()>0?rtrnLct[0].Id:null;
    }
    
    public class ALK_InvSrchLWCException extends Exception {}   
}