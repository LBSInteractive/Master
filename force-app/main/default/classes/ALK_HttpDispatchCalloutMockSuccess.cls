global class ALK_HttpDispatchCalloutMockSuccess  implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');        
        response.setBody('{"fechaFactura": "26/01/2022","noFactura": "W1290001008679","documentoFactura": "11406002","clienteFactura": "Rojas Gutierrez Jose Reinaldo","documentoEnvio": "11406002","clienteEnvio": "Rojas Gutierrez Jose Reinaldo","unidadVenta": "AKVEN","link": "","canal": "","productos": [{"ean": "7706060012511","descripcion": "EstPisoABBA 52Cm4PGNAG2035 NY?","no_despacho": "END0322844","unidadDespacho": "AKCED","cantidadDespacho": 1,"noLinea": 1,"transportador": "ABBA","noGuia":"","direccion":"DG 62 A SUR # 19 B - 80 CS","codCiudad":"11001","ciudad":"BOGOTÁ D.C.","telefono":"3105727256","fechaDespacho":"27/01/2022","fechaPactada":"08/02/2022","fechaReal": null,"fechaReprogramada": null,"tipoDespacho": "Despachos a la dirección","reexpedicion":"NO","estado": "","fechaUltimoEstado": null,"observacionesUltimoEstado": null,"usuarioUltimoEstado": null,"gestionDespacho": 0,"noPedido": null,"noConsigment": null,"barrio": null,"cantidad": 1,"marca": "ABBA","observacionesPS": "J0-3105727256 ACACIAS SUR","cumple": "","unidadDestino": "","fechaCreacionRma": "","fechaProgramadaRecogida": "","fechaRealRecogida": "","motivoRma": null,"tipoRma": 0}]}');
        response.setStatusCode(200);            
		return response;
	}
}