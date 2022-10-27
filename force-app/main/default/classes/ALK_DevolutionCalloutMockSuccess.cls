global class ALK_DevolutionCalloutMockSuccess implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"USER1": " A080598","NUMERO_DEVOLUCION": "0010050 A080598","DESCRIPCION": "Aud Nokia Bluet TWS Essent Az","MOTIVO": "115-Centro de Servicio","UNIDAD_NEGOCIO": "AKB30","CATEGORIA": "ELECT.ELE01.97.971.9715.97152.9715200002.","DIRECCION": "ELECT.","NO_FACTURA": "29460010070407","EAN": "6438409033673","PROVEEDOR": "VDR0021897","TIPO_VENTA": "return","FECHA_DEVOLUCION": "02/03/2022 15:17:39","KEY": "0302202215173900010050000000101458"}]');
		response.setStatusCode(200);            
		return response;
	}
}