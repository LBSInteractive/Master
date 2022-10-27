//Created Date 13/07/2022
//Created by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com.
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import assignInvoiceDes from '@salesforce/apex/ALK_InvoiceSearch_LWC.assignInvoiceDes';
import {loadStyle} from 'lightning/platformResourceLoader'
import cssDespacho from '@salesforce/resourceUrl/cssDespacho'

const invoiceSearchColumns = [
{label:'No de Despacho',fieldName:'noDespacho', type: 'text',initialWidth:100},
{label:'Almacén',fieldName:'unidadVenta', type: 'text',initialWidth:100},
{label:'Unidad de Despacho',fieldName:'unidadDespacho', type: 'text',initialWidth:150},
{label:'Cantidad',fieldName:'qty', type: 'number',initialWidth:100},
{label:'Dirección',fieldName:'direccion', type: 'text',initialWidth:100},
{label:'Fecha Reprogramación',fieldName:'fechaReprogramada', type: 'text',initialWidth:100},
{label:'Fecha Despacho',fieldName:'fechaDespacho', type: 'text',initialWidth:100},
{label:'Fecha Pactada Entrega',fieldName:'fechaPactada', type: 'text',initialWidth:100},
{label:'Fecha Real Entrega',fieldName:'fechaReal', type: 'text',initialWidth:100},
{label:'No de la factura',fieldName:'invoice', type: 'text',initialWidth:100},
{label:'Observación',fieldName:'observacionesPS', type: 'text',initialWidth:150},
{label:'No de Guía',fieldName:'noGuia', type: 'text',initialWidth:150},
{label:'No de Línea',fieldName:'noLinea', type: 'text',initialWidth:150},
{label:'Transportador',fieldName:'transportador', type: 'text',initialWidth:150},
{label:'Fecha Último Estado',fieldName:'fechaUltimoEstado', type: 'text',initialWidth:150},
{label:'Último Estado',fieldName:'estado', type: 'text',initialWidth:150},
{label:'Última Observación',fieldName:'ultimaObservacion', type: 'text',initialWidth:150},
{label:'Reexpedición',fieldName:'reexpedicion', type: 'text',initialWidth:150},
{label:'Tipo de Despacho',fieldName:'tipoDespacho', type: 'text',initialWidth:150},
{label:'No Devolución',fieldName:'devolutionNumber', type: 'text',initialWidth:150},
{label:'Fecha Devolución',fieldName:'devolutionDate', type: 'text',initialWidth:150},
{label:'Valor Devolución',fieldName:'total', type: 'text',initialWidth:150},
{label:'Motivo Devolución',fieldName:'reason', type: 'text',initialWidth:150},
{label:'Tienda Devolución',fieldName:'businessUnit', type: 'text',initialWidth:150},
{label:'Link despacho voz cliente',fieldName:'link', type: 'url',initialWidth:150,typeAttributes:{label: { fieldName: 'link' }}},
{label:'Familia',fieldName:'categoryDescription', type: 'text',initialWidth:100},
{label:'Grupo',fieldName:'groupDescription', type: 'text',initialWidth:100},
{label:'Proveedor',fieldName:'brandDescription', type: 'text',initialWidth:100},
{label:'Marca',fieldName:'brandCode', type: 'text',initialWidth:150},
{label:'Gestión Despacho', fieldName:'gestionDespacho', type:'text', cellAttributes:{
    class:{fieldName:'gstColor'}
}
}
];

export default class alk_Invoice_Prdetails_Despacho extends NavigationMixin(LightningElement) {
@api isLoading ;
@api despachoLstFnl;
@api recordId;
@api errorOnInvoiceListItm;
ean;
invoiceNumber;
invoiceSearchColumns = invoiceSearchColumns;
statusSearchButton=false;
isCssLoaded = false

handleOnClick(){
    this.isLoading = true;
    assignInvoiceDes({ jsonData:JSON.stringify(this.despachoLstFnl), caseId: this.recordId})
        .then(result => {
           let invId=result.substring(8, 26);
           this.navToRecordView(invId); 
       })
       .catch(error => {
        this.statusSearchButton=true;
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
renderedCallback(){ 
    if(this.isCssLoaded) return
    this.isCssLoaded = true
    loadStyle(this, cssDespacho).then(()=>{
    }).catch(error=>{ 
        console.error("Error in loading the cssDespacho"+ error);
    })
}
}