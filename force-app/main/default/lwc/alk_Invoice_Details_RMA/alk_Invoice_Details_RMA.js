//Created Date 13/07/2022
//Created by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com.
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import assignInvoiceRMA from '@salesforce/apex/ALK_InvoiceSearch_LWC.assignInvoiceRMA';
import searchProductDetailBU from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchProductDetailBU';
import {loadStyle} from 'lightning/platformResourceLoader'
import cssRMA from '@salesforce/resourceUrl/cssRMA'

const invoiceSearchColumnsHeader = [
    {label:'No de la factura',fieldName:'invoice', type: 'text',initialWidth:100},
    {label:'EAN',fieldName:'ean', type: 'text',initialWidth:100},
    {label:'Descripción',fieldName:'descripcion', type: 'text',initialWidth:100},
    {label:'Almacén',fieldName:'unidadVenta', type: 'text',initialWidth:100},
    {label:'Fecha Factura',fieldName:'fechaFactura', type: 'text',initialWidth:100},
    {label:'Unidad Recoge',fieldName:'unidadRecoge', type: 'text',initialWidth:100},
    {label:'NIT Factura',fieldName:'documentoFactura', type : 'text',initialWidth:150},
    {label:'Cliente Factura',fieldName:'clienteFactura', type : 'text',initialWidth:150},
    {label:'No Línea',fieldName:'noLinea', type : 'text',initialWidth:100},
    {label:'No RMA', type: 'button', typeAttributes: { label: { fieldName: 'noRMA' },variant: 'base'},initialWidth:150,cellAttributes:{
        class:{fieldName:'gstColor'}
    }},
    {label:'Transportador',fieldName:'transportador', type: 'text',initialWidth:150},
    {label:'observaciones',fieldName:'observacionesPS', type: 'text',initialWidth:150},
    {label:'Estado',fieldName:'estado', type: 'text',initialWidth:100},   
    {label:'Fecha Último Estado',fieldName:'fechaUltimoEstado', type : 'text',initialWidth:150}
    ];

const invoiceSearchColumns = [
{label:'No de la factura',fieldName:'invoice', type: 'text',initialWidth:100},
{label:'Fecha Factura',fieldName:'fechaFactura', type: 'text',initialWidth:100},
{label:'Cantidad',fieldName:'qty', type : 'number',initialWidth:100},
{label:'Almacén',fieldName:'unidadVenta', type: 'text',initialWidth:100},
{label:'Unidad Recoge',fieldName:'unidadRecoge', type: 'text',initialWidth:100},
{label:'No Guia',fieldName:'noGuia', type: 'text',initialWidth:150},
{label:'No RMA',fieldName:'noRMA', type: 'text',initialWidth:150},
{label:'Motivo RMA',fieldName:'motivoRma', type : 'text',initialWidth:150},
{label:'Último Estado',fieldName:'estado', type: 'text',initialWidth:100},
{label:'Última observación',fieldName:'ultimaObservacion', type: 'text',initialWidth:100},
{label:'Dirección',fieldName:'direccion', type: 'text',initialWidth:150},
{label:'Ciudad',fieldName:'ciudad', type: 'text',initialWidth:150},
{label:'Teléfono',fieldName:'telefono', type: 'phone',initialWidth:150},
{label:'Transportador',fieldName:'transportador', type: 'text',initialWidth:150},
{label:'Fecha Creación RMA',fieldName:'fechaCreacionRma', type: 'text',initialWidth:150},
{label:'Fecha Programación Recogida',fieldName:'fechaProgramadaRecogida', type: 'text',initialWidth:150},
{label:'observaciones',fieldName:'observacionesPS', type: 'text',initialWidth:150},
{label:'Grupo',fieldName:'groupDescription', type: 'text',initialWidth:150},
{label:'Proveedor',fieldName:'brandDescription', type: 'text',initialWidth:150},
{label:'Marca',fieldName:'brandCode', type: 'text',initialWidth:150},
{label:'Link',fieldName:'link', type: 'url',initialWidth:100},
];

export default class alk_Invoice_Details_RMA extends NavigationMixin(LightningElement) {
@api isLoading ;
@api objectApiName;
@api rmaLst;
@track rmaLstbdy;
@api location;
@api recordId;
@api errorOnInvoiceListItm;
errorOnInvoiceListSearch;
invoiceSearchColumns = invoiceSearchColumns;
invoiceSearchColumnsHeader = invoiceSearchColumnsHeader;
statusSearchButton=false;
noRma;
invoiceNum;
location;
ean;

handleOnClick(){
    this.isLoading = true;
    console.log(JSON.stringify(this.rmaLstbdy));
        assignInvoiceRMA({ jsonData:JSON.stringify(this.rmaLstbdy), caseId: this.recordId})
        .then(result => {
           let invId=result.substring(8, 26);
           this.navToRecordView(invId); 
       })
       .catch(error => {
           this.showError('No se pudo crear Factura','Error: '+error.body.message, 'error');
       })
       .finally(() => this.isLoading = false );
}

showError(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
} 

navToRecordView(recId) {
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recId,
            actionName: 'view'
        },
    })
}

handleOnRowAction (event){    
    const row = event.detail.row;
    this.noRma = row.noRMA;
    this.invoiceNum = row.invoice;
    this.location = row.unidadVenta;
    this.ean = row.ean;
    this.searchDtlBuRMA();
    
}

searchDtlBuRMA(){
    this.isLoading = true;
    searchProductDetailBU({ invoiceNumber: this.invoiceNum, location : this.location, ean : this.ean})
    .then(result => {
        let productDtlLst = [result];
        this.errorOnInvoiceListSearch = undefined;
        if (productDtlLst.length>0 && this.rmaLst != undefined){
            this.rmaLst.forEach((element)  => {
                if (element.noRMA ===this.noRma) {
                    let rmaFnlHlp= {...productDtlLst[0],...element};
                    this.rmaLstbdy=[];
                    this.rmaLstbdy.push(rmaFnlHlp);
               } 
            });
        } 
       })
    .catch(error => {
        this.errorOnInvoiceListSearch = error;
        this.rmaLstbdy = undefined;
       })
    .finally(() =>this.isLoading = false)
}

renderedCallback(){ 
    if(this.isCssLoaded) return
    this.isCssLoaded = true
    loadStyle(this, cssRMA).then(()=>{
    }).catch(error=>{ 
        console.error("Error in loading the cssRMA"+ error);
    })
}

}