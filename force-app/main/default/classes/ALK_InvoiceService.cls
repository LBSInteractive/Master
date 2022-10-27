public with sharing class ALK_InvoiceService {
    private static Cache.SessionPartition invoiceCache = Cache.Session.getPartition('local.ALKInvoicePartition');
    private static Integer ttlSecs = 300; // five minutes
    @testVisible
    private static String INVOICE_DETAIL_GROUP = 'Detail';
    @testVisible
    private static String INVOICE_DEVOLUTION_GROUP = 'Devolution';
    
    public static List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> searchInvoice(String customerId, Date startDate, Date endDate) {        
        if(String.isEmpty(customerId)) {
            throw new ALK_InvoiceServiceException('A valid customer identification needs to be provided. customerId param cannot be empty!');
        }
        
        if(startDate == null || endDate == null) {
            throw new ALK_InvoiceServiceException('A valid range of start and end dates needs to be provided. startDate and endDate params cannot be null!');
        }
        
        ALK_InvoiceCalloutRequestWrapper request = new ALK_InvoiceCalloutRequestWrapper();
        request.id = customerId;
        request.documentType = 'sale';
        request.startDate = String.valueOf(startDate);
        request.endDate = String.valueOf(endDate);        

            
        ALK_InvoiceCalloutResponseWrapper response = new ALK_InvoiceCallout().getInvoices(request);
        
        ALK_InvoiceService.checkIntegrationRequestResult(response.statusCode, response.status, 'Invoice');
                        
        return response.invoices;
    }
    
    public static List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> searchInvoiceDetail(String invoiceNumber, String bu) {        
        if(String.isEmpty(invoiceNumber)) {
            throw new ALK_InvoiceServiceException('A valid invoice number needs to be provided. invoiceNumber param cannot be empty!');
        }
        
        Map<String,ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> invoicesByBu = 
            (Map<String,ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper>)ALK_InvoiceService.getFromCache(ALK_InvoiceService.INVOICE_DETAIL_GROUP+invoiceNumber);
        
        if (invoicesByBu==null) {
            invoicesByBu = new Map<String,ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper>();
        }
        
        if (String.isEmpty(bu) && invoicesByBu.size() >0) {
            return invoicesByBu.values();
        } else if(!String.isEmpty(bu)) {
            ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper buInvoice = invoicesByBu.get(bu);
            if (buInvoice != null) {
            	return new List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> {buInvoice};    
            }
        }
        
        List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> invoices = ALK_InvoiceService.searchInvoiceDetailFromIntegration(invoiceNumber,bu);
                
        for(ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper i: invoices) {
            invoicesByBu.put(i.business_unit,i);
        }
        
        if (invoicesByBu.size() > 0) {
            ALK_InvoiceService.putOnCache(ALK_InvoiceService.INVOICE_DETAIL_GROUP+invoiceNumber,invoicesByBu,ALK_InvoiceService.ttlSecs);
        }
        
        return invoices;
    }

    public static List<ALK_DevolutionCalloutResponseWrapper.ALK_DevolutionWrapper> searchDevolutions(String invoiceNumber) {        
        if(String.isEmpty(invoiceNumber)) {
            throw new ALK_InvoiceServiceException('A valid invoice number needs to be provided. invoiceNumber param cannot be empty!');
        }
        
        List<ALK_DevolutionCalloutResponseWrapper.ALK_DevolutionWrapper> devolutions = 
            (List<ALK_DevolutionCalloutResponseWrapper.ALK_DevolutionWrapper>)ALK_InvoiceService.getFromCache(ALK_InvoiceService.INVOICE_DEVOLUTION_GROUP+invoiceNumber);
        
        if (devolutions==null) {
            devolutions = new List<ALK_DevolutionCalloutResponseWrapper.ALK_DevolutionWrapper>();
        }
        
        if (devolutions.size() >0) {
            return devolutions;
        }
        
        devolutions = ALK_InvoiceService.searchDevolutionsFromIntegration(invoiceNumber);
                       
        ALK_InvoiceService.putOnCache(ALK_InvoiceService.INVOICE_DEVOLUTION_GROUP+invoiceNumber,devolutions,ALK_InvoiceService.ttlSecs);
        
        return devolutions;
    }
    
    public static ALK_ProductDetailCalloutResponseWrapper.ALK_ProductDetailWrapper searchProductDetail(String invoiceNumber, String bu, String ean) {        
        if(String.isEmpty(invoiceNumber)) {
            throw new ALK_InvoiceServiceException('A valid invoice number needs to be provided. invoiceNumber param cannot be empty!');
        }

        if(String.isEmpty(bu)) {
            throw new ALK_InvoiceServiceException('A valid business unit needs to be provided. bu param cannot be empty!');
        }
        
        if(String.isEmpty(ean)) {
            throw new ALK_InvoiceServiceException('A valid product EAN needs to be provided. ean param cannot be empty!');
        }

        ALK_ProductDetailCalloutResponseWrapper.ALK_ProductDetailWrapper productDetail = 
            (ALK_ProductDetailCalloutResponseWrapper.ALK_ProductDetailWrapper)ALK_InvoiceService.getFromCache(invoiceNumber+bu+ean);
        
        if (productDetail != null) {
            return productDetail;
        }
        
        
        productDetail =  ALK_InvoiceService.searchProductDetailFromIntegration(invoiceNumber, bu, ean);
        
        ALK_InvoiceService.putOnCache(invoiceNumber+bu+ean, productDetail, ALK_InvoiceService.ttlSecs);
        
        return productDetail;
    }
    
    private static List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> searchInvoiceDetailFromIntegration(String invoiceNumber, String bu) {  
        ALK_InvoiceCalloutRequestWrapper request = new ALK_InvoiceCalloutRequestWrapper();
        request.invoice = invoiceNumber;
        request.bu = bu;
        request.documentType = 'sale';
            
        ALK_InvoiceCalloutResponseWrapper response = new ALK_InvoiceCallout().getInvoices(request);
        
        ALK_InvoiceService.checkIntegrationRequestResult(response.statusCode, response.status, 'Invoice');

		return response.invoices;        
    }

    private static List<ALK_DevolutionCalloutResponseWrapper.ALK_DevolutionWrapper> searchDevolutionsFromIntegration(String invoiceNumber) {              
        ALK_DevolutionCalloutResponseWrapper response = new ALK_DevolutionCallout().getDevolutions(invoiceNumber);
        
        ALK_InvoiceService.checkIntegrationRequestResult(response.statusCode, response.status, 'Devolutions');

		return response.devolutions;        
    }
    
    private static ALK_ProductDetailCalloutResponseWrapper.ALK_ProductDetailWrapper searchProductDetailFromIntegration(String invoiceNumber, String bu, String ean) {
        ALK_InvoiceCalloutRequestWrapper request = new ALK_InvoiceCalloutRequestWrapper();
        request.invoice = invoiceNumber;
        request.bu = bu;
        request.ean = ean;
        request.documentType = 'sale';
        
        ALK_ProductDetailCalloutResponseWrapper response = new ALK_ProductDetailCallout().getProductDetail(request);
        
        ALK_InvoiceService.checkIntegrationRequestResult(response.statusCode, response.status, 'Product Detail');
                        
        return response.detail;        
    }

    @testVisible
    private static Object getFromCache(String key) {
        return ALK_InvoiceService.invoiceCache.get(key);
    }

    @testVisible
    private static void putOnCache(String key, Object value, Integer ttl) {
        ALK_InvoiceService.invoiceCache.put(key, value, ttl);
    }

    @testVisible
    private static Boolean removeFromCache(String key) {
        return ALK_InvoiceService.invoiceCache.remove(key);
    }
    
    private static void checkIntegrationRequestResult(Integer statusCode, String status, String integration) {
        if (statusCode != 200) {
            throw new ALK_InvoiceServiceException(String.format('The {0} integration didn\'t work properly and result status code {1} and status {2}.',
                                                            new String[]{integration, String.valueOf(statusCode), status}));
        }        
    }
        
    // exception class
    public class ALK_InvoiceServiceException extends Exception {}     
}