public with sharing class ALK_InvoiceCalloutResponseWrapper {
    @AuraEnabled
    public List<ALK_InvoiceWrapper> Invoices = new List<ALK_InvoiceWrapper>();
    public String status = '';
    public Integer statusCode = 0;
    public Boolean isSucceeded = false;
    
    public class ALK_InvoiceWrapper {
        @AuraEnabled
        public String invoice = '';
        @AuraEnabled        
        public String ruc = '';
        @AuraEnabled        
        public String client_phone = '';
        @AuraEnabled        
        public String client_full_name = '';
        @AuraEnabled        
        public String document = '';
        @AuraEnabled        
        public Date opendate;
        @AuraEnabled        
        public String documenttype = '';
        @AuraEnabled        
        public String business_unit = '';
        @AuraEnabled        
        public String localid = '';
        @AuraEnabled        
        public Decimal total=0;
        @AuraEnabled        
        public String pos = '';
        @AuraEnabled        
        public String dian_prefix = '';
        @AuraEnabled        
        public String name = '';
        @AuraEnabled        
        public Integer ticketnumber=0;
        @AuraEnabled        
        public String id = '';
        @AuraEnabled        
        public String client_address = '';
        @AuraEnabled        
        public String finance_ean = '';
        @AuraEnabled        
        public String barcode = '';
        @AuraEnabled        
        public List<ALK_InvoiceDetailWrapper> details = new List<ALK_InvoiceDetailWrapper>();   
    }
    
    public class ALK_InvoiceDetailWrapper {
        @AuraEnabled        
        public String order_no = '';
        @AuraEnabled        
        public String sold_to_cust_id = '';
        @AuraEnabled        
        public String entry_reason = '';
        @AuraEnabled        
        public Decimal tot_discount_amt=0;
        @AuraEnabled        
        public String line_seq_num = '';
        @AuraEnabled        
        public Decimal amount_with_disc=0;
        @AuraEnabled        
        public String inventory_item = '';
        @AuraEnabled
        public String supplier = '';
        @AuraEnabled
        public String ship_to_cust_id = '';
        @AuraEnabled
        public String accounting_dt = '';
        @AuraEnabled
        public String user1 = '';
        @AuraEnabled
        public String inv_item_id = '';
        @AuraEnabled
        public String business_unit = '';
        @AuraEnabled
        public String ship_from_bu = '';
        @AuraEnabled
        public Decimal tax_cd_vat_pct=0;
        @AuraEnabled
        public String descr = '';
        @AuraEnabled
        public String bill_to_cust_id = '';
        @AuraEnabled
        public Decimal tot_discount_xeu=0;
        @AuraEnabled
        public String name3 = '';
        @AuraEnabled
        public Decimal net_extended_bse = 0;
        @AuraEnabled
        public Decimal qty=0;
        @AuraEnabled
        public String invoice = '';
        @AuraEnabled
        public String order_int_line_no = '';
        @AuraEnabled
        public Integer vat_amt_bse=0;
        @AuraEnabled
        public String entry_type = '';
        @AuraEnabled
        public String name2 = '';
        @AuraEnabled
        public Decimal tot_discount_bse=0;
        @AuraEnabled
        public String name1 = '';
        @AuraEnabled
        public String business_unit_om = '';
        @AuraEnabled
        public String ck_flg_bodegazo = '';      
    }
}