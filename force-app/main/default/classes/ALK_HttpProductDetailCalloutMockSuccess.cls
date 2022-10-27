global with sharing class ALK_HttpProductDetailCalloutMockSuccess implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"SETID": "COLCO","PRODUCT_ID": "7701023462488","DESCR": "Cereal Aritos Frutas Alk 500g","CK_COD_GRUPO": "MERCA","DESCR3": "Mercado","CK_COD_DIVISION": "MER01","DESCR4": "Alimentos No Refrigerados","CK_COD_LINEAS": "5D","DESCR_4": "Alimentos No Basicos y Rancho","CK_COD_SUBLINEA": "5D4","DESCR30": "Cereales y Granolas","CATEGORY_ID": "5D40","DESCR1": "Cereales Granolas y Barras","CK_COD_SUBCATEG": "5D401","DESCR2": "Cereales","INV_PROD_FAM_CD": "5D40100001","DESCR40": "Cereales Infantiles","PROD_BRAND": "ALKOSTO","DESCR15": "ALKOSTO"}');
		response.setStatusCode(200);            
		return response;
	}
}