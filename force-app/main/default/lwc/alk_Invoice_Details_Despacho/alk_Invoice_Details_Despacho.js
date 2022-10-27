//Created Date 13/07/2022
//Created by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com.
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import searchDevolutions from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchDevolutions';
import searchProductDetailBU from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchProductDetailBU';

const invoiceSearchColumns = [
{label:'No de la factura',fieldName:'invoice', type: 'text',initialWidth:100},
{label:'EAN',fieldName:'ean', type: 'button', typeAttributes: { label: { fieldName: 'ean' }, variant: 'base'},initialWidth:100},
{label:'Descripción',fieldName:'descripcion', type : 'text',initialWidth:100},
{label:'Almacén',fieldName:'unidadVenta', type: 'text',initialWidth:100},
{label:'Fecha de Factura',fieldName:'fechaFactura', type: 'text',initialWidth:100},
{label:'Cantidad',fieldName:'qty', type: 'number',initialWidth:100},
{label:'No de Despacho',fieldName:'noDespacho', type: 'text',initialWidth:150},
{label:'Unidad de Despacho',fieldName:'unidadDespacho', type: 'text',initialWidth:150},
{label:'Tipo de Despacho',fieldName:'tipoDespacho', type: 'text',initialWidth:150},
{label:'NIT Factura',fieldName:'documentoFactura', type: 'text',initialWidth:150},
{label:'Cliente Factura',fieldName:'clienteFactura', type: 'text',initialWidth:150},
{label:'No de Línea',fieldName:'noLinea', type: 'text',initialWidth:150},
{label:'Transportador',fieldName:'transportador', type: 'text',initialWidth:150},
{label:'Observación',fieldName:'observacionesPS', type: 'text',initialWidth:150},
{label:'Número de pedido',fieldName:'noPedido', type: 'text',initialWidth:150},
{label:'No de Consigment',fieldName:'noConsigment', type: 'text',initialWidth:150},
{label:'Canal de Venta',fieldName:'canal', type: 'text',initialWidth:150},
{label:'No de Documento Envío',fieldName:'documentoEnvio', type: 'text',initialWidth:150},
{label:'Cliente Envío',fieldName:'clienteEnvio', type: 'text',initialWidth:150},
{label:'Link',fieldName:'link', type: 'url',initialWidth:150,typeAttributes:{label: { fieldName: 'link' }}},
];

export default class alk_Invoice_Details_RMA extends NavigationMixin(LightningElement) {
@api isLoading ;
@api despachoLst;
@api despachoLstFnl;
@api recordId;
@api errorOnDespacho;
@track despachoLstFlt;
ean;
invoiceNumber;
location;
noDespacho;
invoiceSearchColumns = invoiceSearchColumns;
despachoLstDtl;

handleRowAction(event) {
    this.isLoading = true;
    const row = event.detail.row;
    this.ean=row.ean;
    this.invoiceNumber=row.invoice;
    this.location=row.unidadVenta;
    this.noDespacho=row.noDespacho;   
    this.searchCurrenRow(this.ean,this.noDespacho);
    if (this.invoiceNumber != '' && this.invoiceNumber != undefined){
        searchDevolutions({ invoiceNumber: this.invoiceNumber})
        .then(result => {
            this.despachoLstDtl = result;
            this.errorOnDespacho = undefined;
            this.searchCurrenRowDev(this.ean);
            let despachoLstFnlHlp;
            if (this.despachoLstDtl!= undefined && this.despachoLstFlt != undefined){
                despachoLstFnlHlp= {...this.despachoLstDtl,...this.despachoLstFlt};
            }else{
                despachoLstFnlHlp= {...this.despachoLstFlt};
            }
            let gstColor;
            if (despachoLstFnlHlp.gestionDespacho ===1 ){
                gstColor="orangeDt";
            } else if (despachoLstFnlHlp.gestionDespacho ===2 ){
                gstColor="greenDt";
            }
            despachoLstFnlHlp.gstColor=gstColor;
            this.despachoLstFnl=[];
            this.despachoLstFnl.push(despachoLstFnlHlp);
            this.despachoLst= false;
        })
        .catch(error => {
            this.errorOnDespacho = error;
            this.despachoLstFnl = undefined;
             })             
        .finally(() => this.searchDtlBuDesp());
    }        
}

searchDtlBuDesp(){
    searchProductDetailBU({ invoiceNumber: this.invoiceNumber, location : this.location, ean : this.ean})
        .then(result => {
            let productDtlLst = [result];
            this.errorOnInvoiceListSearchDespacho = undefined;
            if (productDtlLst!= undefined && this.despachoLstFnl != undefined){
                let dspFnlHlp= {...productDtlLst[0],...this.despachoLstFnl[0]};
                this.despachoLstFnl=[];
                this.despachoLstFnl.push(dspFnlHlp);
            } 
           })
        .catch(error => {
            this.errorOnDespacho = error;
            this.despachoLst = undefined;
           })
        .finally(() =>this.isLoading = false)
}

searchCurrenRow(eanInp, nDespInpo){
    this.despachoLstFlt = Object.values(this.despachoLst).find((obj) => {
        return obj.ean == eanInp && obj.noDespacho == nDespInpo;
    });
}

searchCurrenRowDev(eanInp){
    this.despachoLstDtl = Object.values(this.despachoLstDtl).find((obj) => {
        return obj.ean == eanInp
    });
}

showError(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
} 

}