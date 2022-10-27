/***********************************************************************************************************************
    *   Author: Daniel Murcia Suarez daniel.murcia@globant.com
    *   Date :06-Jul-2022
    *   Test Class: ALK_InvoiceSearch_LWCTest [Code Coverage: 100%]
    **
    * -------------------------------------
    *            No.    Date           Author                           Description      
    *            ----   ----------     ---------------------------     -------------    
    * @version   1.0    06-Jul-2022    Daniel Murcia Suarez DGMS      Creation of the wrapper class to map all data to invoice
																	  when the search invoice is executed.          
    *************************************************************************************************************************/
public with sharing class ALK_invoiceWrapper {
	public String brandCode;
	public String brandDescription;
	public String categoryCode;
	public String categoryDescription;
	public String description;
	public String divisionCode;
	public String divisionDescription;
	public String familyCode;
	public String familyDescription;
	public String groupCode;
	public String groupDescription;
	public String lineCode;
	public String lineDescription;
	public String productId;
	public String SETID;
	public String subCategoryCode;
	public String subCategoryDescription;
	public String subLineCode;
	public String subLineDescription;
	public String eanCode;
	public String address;
	public String businessUnit;
	public String category;
	public String devolutionDate;
	public String devolutionNumber;
	public String ean;
	public String invoiceNumber;
	public String key;
	public String provider;
	public String reason;
	public String salesType;
	public String user;
	public String invoice;
	public String descr;
	public String location;
	public String business_unit;
	public Date opendate;
	public Decimal qty;
	public Decimal total;
	public String nit_comprador;
	public String nombre_comprador;
	public String phone_comprador;
	public String cliente_envio;
	public String nit_envio;
	public String cltEnv;
	public String pedido;
	public Date dtCntDays;
	public static List<ALK_invoiceWrapper> parse(String json) {
		return (List<ALK_invoiceWrapper>) System.JSON.deserialize(json, List<ALK_invoiceWrapper>.class);
	}
}