@isTest
global class ALK_HttpInvoiceDetailCalloutMockSuccess  implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"invoice": "SETT0003169815","ruc": "8909009431","client_phone": "3156841949","client_full_name": "NIT EDNA|||","document": "3169815","opendate": "2022-04-13T08:51:26","documenttype": "sale","business_unit": "KTINT","localid": "70","total": 95488,"pos": "25","dian_prefix": "SETT","name": "NIT EDNA ","ticketnumber": 137482,"id": "8909009431","client_address": "Calle 75 # 64-52","finance_ean": "Tarjeta Alkosto","barcode": "702500137482130422085126","details": [{"order_no": null,"sold_to_cust_id": "8909009431","entry_reason": null,"tot_discount_amt": null,"line_seq_num": "0","amount_with_disc": 95488,"inventory_item": "Y","supplier": "VDR0029076","ship_to_cust_id": "5163468","accounting_dt": "2022-04-13","user1": "SETT0003169815","inv_item_id": "7707315500609","business_unit": "KTINT","ship_from_bu": "KTINT","tax_cd_vat_pct": 19,"descr": "Soporte Movible Nevera Talla L","bill_to_cust_id": "8909009431","tot_discount_xeu": null,"name3": "NIT EDNA   ","net_extended_bse": 80242.02,"qty": 1,"invoice": null,"order_int_line_no": null,"vat_amt_bse": 15246,"entry_type": "FC","name2": "NIT EDNA   ","tot_discount_bse": null,"name1": "NIT EDNA   ","business_unit_om": "KTINT","ck_flg_bodegazo": "N"}]}]');
		response.setStatusCode(200);            
		return response;
	}
}