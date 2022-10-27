public with sharing class ALK_InvoiceCallout extends ALK_StandardCallout {
    private Boolean isSearchingDetails = false;
    
    public ALK_InvoiceCalloutResponseWrapper getInvoices(ALK_InvoiceCalloutRequestWrapper fieldsParam) {
        this.isSearchingDetails = !String.isEmpty(fieldsParam.invoice);
        
        ALK_InvoiceCalloutResponseWrapper result = new ALK_InvoiceCalloutResponseWrapper();{}
        try{
            result = (ALK_InvoiceCalloutResponseWrapper)super.execute(fieldsParam);
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
        return ALK_API_Callouts__mdt.getInstance('ALK_Invoice_Callout'); 
    }
    
    protected override String getPathParams(object requestWrapper) {
        ALK_InvoiceCalloutRequestWrapper request = (ALK_InvoiceCalloutRequestWrapper)requestWrapper;
        
        String result = '';
        
        if (!this.isSearchingDetails) {
            // search for head records
            result = '?id='+request.id+'&documentType='+request.documentType+'&startDate='+request.startDate+'&endDate='+request.endDate;    
        } else {
            // search for detail records of specific invoice
            result = '/'+request.invoice+'?businessUnit='+request.bu;                
        }
        
        return result;
    }
    
    protected override Map<String, Object> getPayLoad(object requestWrapper) {
        Map<String, Object> bodyPayload = new map<String, Object>();            
        return bodyPayload;        
    }
    
    protected override Object getResponse(HttpResponse response) {
        ALK_InvoiceCalloutResponseWrapper result = new ALK_InvoiceCalloutResponseWrapper(); 
        
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            result.isSucceeded = true;
            
            if (this.isSearchingDetails) {
				result.Invoices.addAll(this.getDetailResponse(response));
            } else {
            	result.Invoices.addAll(this.getInvoiceResponse(response)); 
            }
            
        } else {
            // This part need to be reviewed when the error messagem be available from SIAF. 
            result.isSucceeded = false;
            result.status = response.getStatus();
        }
        
        result.statusCode = response.getStatusCode();  
        
        
        return result;        
    }
    
    private List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> getInvoiceResponse(HttpResponse response) {        
        List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> result = new List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper>();
        
        List<Object> resultPayload = (List<Object>)JSON.deserializeUntyped(response.getBody());
        for(object payload : (List<Object>)resultPayload) {
            Map<String, Object> resultPayloadItem = (Map<String, Object>)payLoad;
            
            ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper item = new ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper();
            
            item.ruc = (String)resultPayloadItem.get('ruc'); 
            item.client_phone = (String)resultPayloadItem.get('client_phone');
            item.client_full_name = (String)resultPayloadItem.get('client_full_name');
            item.document = (String)resultPayloadItem.get('document');  
            String openDate = (String)resultPayloadItem.get('opendate');
            item.opendate = String.isEmpty(openDate) || openDate.length() < 10 ? null : Date.valueof(openDate.substring(0, 10)); // getting just the date without time
            item.documenttype = (String)resultPayloadItem.get('documenttype');
            item.localid = (String)resultPayloadItem.get('localid');
            item.total = (Decimal)resultPayloadItem.get('total');
            item.pos = (String)resultPayloadItem.get('pos');
            item.dian_prefix = (String)resultPayloadItem.get('dian_prefix');
            item.name = (String)resultPayloadItem.get('name');
            item.ticketnumber = (Integer)resultPayloadItem.get('ticketnumber');
            item.id = (String)resultPayloadItem.get('id');
            item.client_address = (String)resultPayloadItem.get('client_address');
            item.finance_ean = (String)resultPayloadItem.get('finance_ean');
            item.barcode = (String)resultPayloadItem.get('barcode');
            item.business_unit = (String)resultPayloadItem.get('business_unit');          
            item.invoice = (String)resultPayloadItem.get('invoice');
            item.details = new List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceDetailWrapper>();
            
            result.add(item);
        }        
        
        return result;        
    } 
    
    private List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> getDetailResponse(HttpResponse response) {
        List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> result = new List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper>();
        
        List<Object> resultPayload = (List<Object>)JSON.deserializeUntyped(response.getBody());
        
        for(object payload : (List<Object>)resultPayload) {
            ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper head = new ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper(); 
            
            Map<String, Object> payLoadHead = (Map<String, Object>)payload;
            
            // head fields
            head.ruc = (String)payLoadHead.get('ruc'); 
            head.client_phone = (String)payLoadHead.get('client_phone');
            head.client_full_name = (String)payLoadHead.get('client_full_name');
            head.document = (String)payLoadHead.get('document');      
            String openDate = (String)payLoadHead.get('opendate');
            head.opendate = String.isEmpty(openDate) || openDate.length() < 10 ? null : Date.valueof(openDate.substring(0, 10));// getting just the date without time
            head.documenttype = (String)payLoadHead.get('documenttype');
            head.localid = (String)payLoadHead.get('localid');
            head.total = (Decimal)payLoadHead.get('total');
            head.pos = (String)payLoadHead.get('pos');
            head.dian_prefix = (String)payLoadHead.get('dian_prefix');
            head.name = (String)payLoadHead.get('name');
            head.ticketnumber = (Integer)payLoadHead.get('ticketnumber');
            head.id = (String)payLoadHead.get('id');
            head.client_address = (String)payLoadHead.get('client_address');
            head.finance_ean = (String)payLoadHead.get('finance_ean');
            head.barcode = (String)payLoadHead.get('barcode');
            head.business_unit = (String)payLoadHead.get('business_unit');          
            head.invoice = (String)payLoadHead.get('invoice');   
            
            for(object payLoadDetail : (List<Object>)payLoadHead.get('details')) {
                Map<String, Object> resultPayloadItem = (Map<String, Object>)payLoadDetail;
                
                ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceDetailWrapper detail = new ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceDetailWrapper();
                
                // Detail fields
                detail.order_no = (String)resultPayloadItem.get('order_no');
                detail.sold_to_cust_id = (String)resultPayloadItem.get('sold_to_cust_id');
                detail.entry_reason = (String)resultPayloadItem.get('entry_reason');
                detail.tot_discount_amt = (Decimal)resultPayloadItem.get('tot_discount_amt');
                detail.line_seq_num = (String)resultPayloadItem.get('line_seq_num');
                detail.amount_with_disc = (Decimal)resultPayloadItem.get('amount_with_disc');
                detail.inventory_item = (String)resultPayloadItem.get('inventory_item');
                detail.supplier = (String)resultPayloadItem.get('supplier');
                detail.ship_to_cust_id = (String)resultPayloadItem.get('ship_to_cust_id');
                detail.accounting_dt = (String)resultPayloadItem.get('accounting_dt');
                
                detail.user1 = (String)resultPayloadItem.get('user1');
                detail.inv_item_id = (String)resultPayloadItem.get('inv_item_id');
                detail.ship_from_bu = (String)resultPayloadItem.get('ship_from_bu');
                detail.tax_cd_vat_pct = (Decimal)resultPayloadItem.get('tax_cd_vat_pct');
                detail.descr = (String)resultPayloadItem.get('descr');
                detail.bill_to_cust_id = (String)resultPayloadItem.get('bill_to_cust_id');
                detail.tot_discount_xeu = (Decimal)resultPayloadItem.get('tot_discount_xeu');
                detail.name3 = (String)resultPayloadItem.get('name3');
                detail.net_extended_bse = (Decimal)resultPayloadItem.get('net_extended_bse');
                detail.qty = (Decimal)resultPayloadItem.get('qty');
                detail.order_int_line_no = (String)resultPayloadItem.get('order_int_line_no');
                detail.vat_amt_bse = (Integer)resultPayloadItem.get('vat_amt_bse');
                detail.entry_type = (String)resultPayloadItem.get('entry_type');
                detail.name2 = (String)resultPayloadItem.get('name2');
                detail.tot_discount_bse = (Decimal)resultPayloadItem.get('tot_discount_bse');
                detail.name1 = (String)resultPayloadItem.get('name1');
                detail.business_unit_om = (String)resultPayloadItem.get('business_unit_om');
                detail.ck_flg_bodegazo = (String)resultPayloadItem.get('ck_flg_bodegazo'); 
                
                head.details.add(detail);                
            }        
            
            result.add(head);             
        }
        
        return result;
    }    
}