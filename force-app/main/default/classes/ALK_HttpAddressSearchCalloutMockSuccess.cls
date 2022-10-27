global class ALK_HttpAddressSearchCalloutMockSuccess implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"SETID": "ALKOS","CUST_ID": "8909009431","COUNTRY": "COL","STATE": "BOGOTA","DESCR": "Pensilvania","CITY": "11001","COUNTY": "000317","ADDRESS1": "CL 11 # 31 A - 42","ADDRESS2": "CL 10 A # 31 A - 42","COUNTRY_CODE": "051","PHONE": "4376868","FAX": "6305812","ADDRESS_SEQ_NUM": 1,"BILL_TO_ADDR": "Y","SHIP_TO_ADDR": "Y","SOLD_TO_ADDR": "Y"},{"SETID": "ALKOS","CUST_ID": "8909009431","COUNTRY": "COL","STATE": "BOGOTA","DESCR": "Pensilvania","CITY": "11001","COUNTY": "000317","ADDRESS1": "CR 30 # 10 - 77","COUNTRY_CODE": "001","PHONE": "3649777","FAX": "2017981","ADDRESS_SEQ_NUM": 2,"BILL_TO_ADDR": "Y","SHIP_TO_ADDR": "Y","SOLD_TO_ADDR": "Y"}]');
		response.setStatusCode(200);            
		return response;
	}
}