import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import searchInvoice from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchInvoice';
import searchInvoiceDetailrma from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchInvoiceDetailRMA';
import srchRMA from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchRMA';
import IDENTIFICATION_FROM_CASE from '@salesforce/schema/Case.Account.ALK_Identification_Id__c';
import getIdentification from '@salesforce/apex/ALK_InvoiceSearch_LWC.getIdentification';
import errMsgDt from '@salesforce/label/c.ALK_Error_Message_dt';

const fieldsForCase = [IDENTIFICATION_FROM_CASE];

const invoiceSearchColumns = [
    {label:'No de la factura',fieldName:'invoice', type: 'text'},
    {label:'Fecha de Compra',fieldName:'opendate', type : 'date'},
    {label:'Almacén',fieldName:'business_unit', type: 'text'},
    {label:'Total(valor)',fieldName:'total', type : 'number'}
  ]; 

export default class aLK_Invoice_Search_RMA extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api rmaLst;
    rmaLstHlp;
	@track invoiceList;
    @track invoiceDetailRMA = false;
	@track errorOnInvoiceListSearch;
    invoiceSearchColumns = invoiceSearchColumns;
    isLoading = false;
    statusSearchButton=true;
    customerId;
    startDate;
    endDate;
    invoiceId;
    location;
    ean;
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
        }else if(this.customerId === undefined){
            this.getIdNumber();
        }        
    }  

    getIdNumber(){
        getIdentification({ recordId: this.recordId})
        .then(result => {
            this.customerId = result;       
        })
        .catch(error => {
            this.errorOnInvoiceListSearch = error;
        })
        .finally(() => this.isLoading = false );

    }
        
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleOnRowSelection(event){
        this.isLoading = true; 
        const selectedRows = event.detail.selectedRows;
        this.invoiceSearchId = selectedRows[0].invoice; 
        this.total = selectedRows[0].total; 
        this.invoiceList = false;
        this.invoiceDetailRMA=true;
        srchRMA({ invoiceNumber: this.invoiceSearchId})
        .then(result => {
            this.rmaLstHlp= JSON.parse(result); 
            this.rmaLst=[]; 
            this.rmaLstHlp.details.forEach(element => {
                if (element.tipoRma===1) { 
                      this.ean=element.ean;
                      this.location=this.rmaLstHlp.unidadVenta;
                        this.rmaLst.push ({
                            'invoice': this.rmaLstHlp.noFactura,
                            'fechaFactura': this.rmaLstHlp.fechaFactura,
                            'qty': element.cantidad,
                            'unidadVenta':this.rmaLstHlp.unidadVenta,
                            'unidadRecoge':element.unidadDespacho,
                            'noGuia': element.noGuia,
                            'noRMA': element.no_despacho,
                            'motivoRma': element.motivoRma,
                            'estado': element.estado,
                            'ultimaObservacion': element.observacionesUltimoEstado,
                            'direccion': element.direccion,
                            'ciudad': element.ciudad,
                            'telefono': element.telefono,
                            'transportador': element.transportador,
                            'transportadorH': element.transportadorHomologado,
                            'fechaCreacionRma': element.fechaCreacionRma,
                            'fechaProgramadaRecogida': element.fechaProgramadaRecogida,
                            'observacionesPS':element.observacionesPS,
                            'ean':element.ean,
                            'descripcion':element.descripcion,
                            'estado':element.estado,
                            'fechaUltimoEstado':element.fechaUltimoEstado,
                            'link':this.rmaLstHlp.link,
                            'clienteFactura':this.rmaLstHlp.clienteFactura,
                            'documentoEnvio':this.rmaLstHlp.documentoEnvio,
                            'documentoFactura':this.rmaLstHlp.documentoFactura,
                            'valor':this.total,
                            'noLinea':element.noLinea,
                            'gstColor':element.reRma === 1?'purpleRMA':'',
                            // and so on for other fields
                        });   
                }
            });
            this.errorOnInvoiceListSearch = undefined;
            if (this.rmaLst === undefined) {
                this.showError('Oops Error!','no tiene RMA asociados!', 'error'); 
                this.rmaLst = undefined;
            }
           
          })
        .catch(error => {
            this.errorOnInvoiceListSearch = error;
            this.rmaLst = undefined;
           })
        .finally(() => this.isLoading = false//,console.log(this.rmaLst)
        );  
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
        this.invoiceDetailRMA=false;  
        if (this.customerId != '' && this.startDate !== undefined && this.endDate !== undefined && this.startDate !== null && this.endDate !== null){
            this.isLoading = true;
            searchInvoice({ customerId: this.customerId, startDate : this.startDate, endDate : this.endDate })
            .then(result => {
                this.invoiceList = result;
                this.errorOnInvoiceListSearch = undefined;          
            })
            .catch(error => {
                this.errorOnInvoiceListSearch = error;
                this.invoiceList = undefined;
                })
            .finally(() => this.isLoading = false );
        }   
        else if (this.invoiceId != undefined && this.invoiceId !='' && this.invoiceId !=null){
            this.isLoading = true;
            searchInvoiceDetailrma({ invoiceNumber: this.invoiceId})
            .then(result => {
                this.invoiceList = result;
                this.errorOnInvoiceListSearch = undefined;
               })
            .catch(error => {
                this.errorOnInvoiceListSearch = error;
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