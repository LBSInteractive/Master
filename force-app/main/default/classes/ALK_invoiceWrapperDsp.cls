/***********************************************************************************************************************
    *   Author: Daniel Murcia Suarez daniel.murcia@globant.com
    *   Date :18-Jul-2022
    *   Test Class: ALK_InvoiceSearch_LWCTest [Code Coverage: 100%]
    **
    * -------------------------------------
    *            No.    Date           Author                           Description      
    *            ----   ----------     ---------------------------     -------------    
    * @version   1.0    18-Jul-2022    Daniel Murcia Suarez DGMS      Creation of the wrapper class to map all data to invoice
																	  when the search invoice Despachos is executed.          
    *************************************************************************************************************************/
    public class ALK_invoiceWrapperDsp {

	public String address;
	public String businessUnit;
	public String category;
	public String description;
	public String devolutionDate;
	public String devolutionNumber;
	public String ean;
	public String invoiceNumber;
	public String key;
	public String provider;
	public String reason;
	public String salesType;
	public String user;
	public String brandCode;
	public String brandDescription;
	public String categoryCode;
	public String categoryDescription;
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
	public String invoice;
	public String descripcion;
	public String unidadVenta;
	public String fechaFactura;
	public Decimal qty;
	public String noDespacho;
	public String unidadDespacho;
	public String tipoDespacho;
	public String documentoFactura;
	public String clienteFactura;
	public Integer noLinea;
	public String transportador;
	public String transportadorH;
	public String observacionesPS;
	public String noPedido;
	public String noConsigment;
	public String canal;
	public String documentoEnvio;
	public String clienteEnvio;
	public Integer valor;
	public Integer gestionDespacho;
	public String reexpedicion;
	public String direccion;
	public String fechaReprogramada;
	public String fechaDespacho;
	public String fechaPactada;
	public String fechaReal;
	public String fechaUltimoEstado;
	public String estado;
	public String telefono;
	public String ciudad;
    public String noGuia;
    public String unidadRecoge;
    public String fechaProgramadaRecogida;
    public String ultimaObservacion;
    public String link;
	public String State;
    
    public static List<ALK_invoiceWrapperDsp> parse(String json) {
		return (List<ALK_invoiceWrapperDsp>) System.JSON.deserialize(json, List<ALK_invoiceWrapperDsp>.class);
	}
}