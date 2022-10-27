import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import searchInvoice from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchInvoice';
import searchInvoiceDetailrma from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchInvoiceDetailRMA';
import srchDespachos from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchRMA';
import IDENTIFICATION_FROM_CASE from '@salesforce/schema/Case.Account.ALK_Identification_Id__c';
import errMsgDt from '@salesforce/label/c.ALK_Error_Message_dt';
import getIdentification from '@salesforce/apex/ALK_InvoiceSearch_LWC.getIdentification';

const fieldsForCase = [IDENTIFICATION_FROM_CASE];

const invoiceSearchColumns = [
    {label:'No de la factura',fieldName:'invoice', type: 'text'},
    {label:'Fecha de Compra',fieldName:'opendate', type : 'date', typeAttributes: {timeZone:"UTC"}},
    {label:'Almacén',fieldName:'business_unit', type: 'text'},
    {label:'Total(valor)',fieldName:'total', type : 'number'}
  ]; 

export default class aLK_Invoice_Search_RMA extends LightningElement {
    @api recordId;
    @api despachoLst; 
    despachoLstHlp;
	@track invoiceList;
    @track invoiceDetailDespacho = false;
	@track errorOnInvoiceListSearchDespacho;
    invoiceSearchColumns = invoiceSearchColumns;
    isLoading = false;
    statusSearchButton=true;
    customerId;
    startDate;
    endDate;
    invoiceId;
    location;
    invoiceSearchId;    
    total;

    @wire(getRecord, {
        recordId: "$recordId",
        fields: fieldsForCase
    })
    recordDetail;   

    customerIdChange(event) {
        this.isLoading = true;
        this.customerId = event.target.value;
        this.datesValidator();
        this.fieldValidation();
        this.isLoading = false;
    }
    
    startDateChange(event) {
        this.startDate= event.target.value;
        this.datesValidator();
    }  
    
    endDateChange(event) {
        this.endDate= event.target.value;
        this.datesValidator();
    }  
    
    datesValidator(){
        if (this.endDate!=undefined && this.startDate!=undefined){
            let endDt = new Date(this.endDate);
            let strtDt  = new Date(this.startDate);
            let diffTm = (endDt - strtDt);
            let diffDys = diffTm / (1000 * 3600 * 24);
            if( diffDys < 0 && (endDt!=null && strtDt!=null||endDt!=undefined && strtDt!=undefined)){
                this.statusSearchButton=true;
                this.showError('Importante',errMsgDt,'info');
            }else{
                this.fieldValidation();
            }
        }else{
            this.statusSearchButton=true;
        }
    }
    
    invoiceIdChange(event) {
        this.invoiceId= event.target.value;
        this.fieldValidation();
    }

    showError(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
  
    handleOnLoad() { 
        this.isLoading = true;
        if(this.recordDetail.data !== undefined){
            this.customerId = getFieldValue(this.recordDetail.data, IDENTIFICATION_FROM_CASE); 
            this.isLoading = false;  
        }else if( this.customerId === undefined){
            this.getIdNumber();
        }
    }
    
    getIdNumber(){
        getIdentification({ recordId: this.recordId})
        .then(result => {
            this.customerId = result;       
        })
        .catch(error => {
            this.errorOnInvoiceListSearchDespacho = error;
        })
        .finally(() => this.isLoading = false );

    }
        
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleOnRowSelection(event){
        this.isLoading = true;
        let idx=0;
        const selectedRows = event.detail.selectedRows;
        this.invoiceSearchId = selectedRows[0].invoice; 
        this.total = selectedRows[0].total; 
        this.invoiceList = false;
        this.invoiceDetailDespacho=true;
        srchDespachos({ invoiceNumber: this.invoiceSearchId})
        .then(result => {
            this.despachoLstHlp= JSON.parse(result);
            this.despachoLst=[]; 
            this.despachoLstHlp.details.forEach(element => {
                idx=idx+1;
                if (element.tipoRma===0) { 
                      this.location=this.despachoLstHlp.unidadVenta;
                        this.despachoLst.push ({
                            'id':element.ean+element.no_despacho+idx,
                            'invoice': this.despachoLstHlp.noFactura,
                            'ean':element.ean,
                            'descripcion':element.descripcion,
                            'unidadVenta':this.despachoLstHlp.unidadVenta,
                            'fechaFactura': this.despachoLstHlp.fechaFactura,
                            'qty': element.cantidad,
                            'noDespacho': element.no_despacho,
                            'unidadDespacho':element.unidadDespacho,
                            'tipoDespacho':element.tipoDespacho,
                            'documentoFactura':this.despachoLstHlp.documentoFactura,
                            'clienteFactura':this.despachoLstHlp.clienteFactura,
                            'noLinea':element.noLinea,
                            'transportador': element.transportador,
                            'transportadorH': element.transportadorHomologado,
                            'observacionesPS':element.observacionesPS,
                            'noPedido':element.noPedido,
                            'noConsigment':element.noConsigment,
                            'canal':this.despachoLstHlp.canal,
                            'documentoEnvio':this.despachoLstHlp.documentoEnvio,
                            'clienteEnvio':this.despachoLstHlp.clienteEnvio,
                            'valor':this.total,
                            'gestionDespacho':element.gestionDespacho,
                            'reexpedicion':element.reexpedicion,
                            'direccion':element.direccion,
                            'fechaReprogramada':element.fechaReprogramada,
                            'fechaDespacho':element.fechaDespacho,
                            'fechaPactada':element.fechaPactada,
                            'fechaReal':element.fechaReal,
                            'fechaUltimoEstado':element.fechaUltimoEstado,
                            'estado':element.estado,
                            'noGuia':element.noGuia,
                            'link':this.despachoLstHlp.link,
                            'telefono':element.telefono,
                            'ciudad':element.ciudad,
                            'unidadRecoge':element.unidadDespacho,
                            'fechaProgramadaRecogida':element.fechaProgramadaRecogida,
                            'ultimaObservacion':element.observacionesUltimoEstado,
                            'State':element.Departamento,
                            // and so on for other fields
                        });   
                }
            });
            this.errorOnInvoiceListSearchDespacho = undefined;
           
          })
        .catch(error => {
            this.errorOnInvoiceListSearchDespacho = error;
            this.despachoLst = undefined;
           })
        .finally(() => this.validateDspLst());  
    }

    validateDspLst(){
        if (this.despachoLst === undefined ) {
            this.showError('Oops Error!','no tiene Despachos asociados!', 'error'); 
            this.despachoLst = undefined;
            this.isLoading = false;
        }
        this.isLoading = false;
    }

    fieldValidation(){
        if (this.customerId != '' && this.startDate !== undefined && this.endDate !== undefined && this.startDate !== null && this.endDate !== null){
            this.statusSearchButton=false;
        }else if (this.invoiceId != '' ){
            this.statusSearchButton=false;
        }else{
            this.statusSearchButton=true;
        }
    }
    
    handleInvoiceSearch() { 
        this.invoiceDetailDespacho=false;  
        if (this.customerId != '' && this.startDate !== undefined && this.endDate !== undefined && this.startDate !== null && this.endDate !== null){
            this.isLoading = true;
            searchInvoice({ customerId: this.customerId, startDate : this.startDate, endDate : this.endDate })
            .then(result => {
                this.invoiceList = result;
                this.errorOnInvoiceListSearchDespacho = undefined;          
            })
            .catch(error => {
                this.errorOnInvoiceListSearchDespacho = error;
                this.invoiceList = undefined;
                })
            .finally(() => this.isLoading = false );
        }   
        else if (this.invoiceId != undefined && this.invoiceId !='' && this.invoiceId !=null){
            this.isLoading = true;
            searchInvoiceDetailrma({ invoiceNumber: this.invoiceId})
            .then(result => {
                this.invoiceList = result;
                this.errorOnInvoiceListSearchDespacho = undefined;
               })
            .catch(error => {
                this.errorOnInvoiceListSearchDespacho = error;
                this.invoiceList = undefined;
               })
            .finally(() => this.isLoading = false );
        }         
        else if((this.customerId != '') && (this.startDate === undefined || this.endDate === undefined || this.startDate === null || this.endDate === null)){
            
            this.showError('Faltan datos','Es necesario llenar el rango de fechas!', 'error'); 
        
        } 
        else if((this.customerId == '' || this.customerId === undefined) 
            && (this.startDate === undefined || this.endDate === undefined || this.startDate === null || this.endDate === null)  
            && (this.invoiceId == '' || this.invoiceId === undefined)){ 
            this.showError('Faltan datos','Es necesario llenar los datos para hacer la búsqueda!', 'error'); 
        }      
    }       
}