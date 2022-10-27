public with sharing class ALK_DispatchCalloutResponseWrapper {
	public String status='';
	public Integer statusCode;
    public Boolean isSucceeded;
	public ALK_DispatchWrapper dispatch;
    
    public class ALK_DispatchWrapper {
    	public String fechaFactura= '';
    	public String noFactura= '';
    	public String documentoFactura= '';
    	public String clienteFactura='';
    	public String documentoEnvio= '';
    	public String clienteEnvio='';
    	public String unidadVenta= '';
    	public String link= '';
    	public String canal= '';
    	public String email= '';
        public List<ALK_DispatchDetailWrapper> details;        
    }
    
    public class ALK_DispatchDetailWrapper {
    	public String ean= '';
    	public String descripcion= '';
    	public String no_despacho= '';
    	public String unidadDespacho='';
    	public Integer cantidadDespacho;
    	public Integer noLinea;
    	public String transportador= '';
		public String transportadorHomologado='';
    	public String noGuia= '';
    	public String direccion= '';
    	public String codCiudad= '';
    	public String ciudad= '';
		public String codDepartamento= '';
    	public String Departamento= '';
    	public String telefono= '';
    	public String fechaDespacho= '';
    	public String fechaPactada= '';
    	public String fechaReal='';
    	public String fechaReprogramada= '';
    	public String tipoDespacho= '';
    	public String reexpedicion= '';
    	public String estado='';
    	public String fechaUltimoEstado='';
    	public String observacionesUltimoEstado='';
    	public String usuarioUltimoEstado='';
    	public Integer gestionDespacho;
    	public String noPedido='';
    	public String noConsigment='';
    	public String barrio='';
		public Integer cantidad;
    	public String marca='';
    	public String observacionesPS='';
    	public String cumple='';
    	public String unidadDestino='';
    	public String fechaCreacionRma='';
    	public String fechaProgramadaRecogida='';
    	public String fechaRealRecogida='';
    	public String motivoRma='';
		public Integer tipoRma;
		public Integer reRma;
    }
}