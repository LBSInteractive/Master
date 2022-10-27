/***********************************************************************************************************************
    *   Author: Daniel Murcia Suarez daniel.murcia@globant.com
    *   Date :13-Jul-2022
    *   Test Class: ALK_InvoiceSearch_LWCTest [Code Coverage: 100%]
    **
    * -------------------------------------
    *            No.    Date           Author                           Description      
    *            ----   ----------     ---------------------------     -------------    
    * @version   1.0    13-Jul-2022    Daniel Murcia Suarez DGMS      Creation of the wrapper class to map all data to invoice
																	  when the search invoice is executed.          
    *************************************************************************************************************************/
    public class ALK_invoiceWrapperRMA {

	public String invoice;
	public String fechaFactura;
	public Integer qty;
	public String unidadVenta;
	public String unidadRecoge;
	public String noGuia;
	public String noRMA;
	public String motivoRma;
	public String estado;
	public String ultimaObservacion;
	public String direccion;
	public String ciudad;
	public String telefono;
	public String transportador;
	public String transportadorH;
	public String fechaCreacionRma;
	public String fechaProgramadaRecogida;
	public String observacionesPS;
	public String ean;
	public String descripcion;
	public String fechaUltimoEstado;
	public String link;
	public String clienteFactura;
	public String documentoEnvio;
	public String documentoFactura;
	public String brandCode;	
	public String groupDescription;	
	public String lineDescription;	
	public String familyDescription;	
	public String brandDescription;	
	public Decimal valor;			
	public String noPedido;			
	public Integer noLinea;		
	
	public static List<ALK_invoiceWrapperRMA> parse(String json) {
		return (List<ALK_invoiceWrapperRMA>) System.JSON.deserialize(json, List<ALK_invoiceWrapperRMA>.class);
	}
}