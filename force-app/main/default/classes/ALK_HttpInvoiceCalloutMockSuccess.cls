@isTest
global class ALK_HttpInvoiceCalloutMockSuccess  implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"invoice": "SETT0003121479","ruc": "8909009431","client_phone": "3124567654","client_full_name": "Colombiana de comercio|||","document": "3121479","opendate": "2022-02-17T14:17:00","documenttype": "sale","business_unit": "AKIPI","localid": "08","total": 99900,"pos": "62","dian_prefix": "SETT000","name": "Colombiana de comercio","ticketnumber": 9984,"id": "8909009431","client_address": "CL 84 # 24 - 78","finance_ean": null,"barcode": "086200009984170222141700"}]');
		response.setStatusCode(200);            
		return response;
	}
}