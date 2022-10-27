import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchInvoiceDetail from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchInvoiceDetailBU';
import searchProductDetailBU from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchProductDetailBU';
import searchDevolutions from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchDevolutions';
import srchDespachos from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchRMA';

const invoiceSearchColumns = [
{label:'No de la factura',fieldName:'invoice', type: 'text',initialWidth:100},
{label:'EAN',fieldName:'ean', type: 'button', typeAttributes: { label: { fieldName: 'ean' }, variant: 'base'},initialWidth:100},
{label:'Descripción',fieldName:'descr', type : 'text',initialWidth:100},
{label:'Almacén',fieldName:'location', type: 'text',initialWidth:100},
{label:'Unidad de venta',fieldName:'business_unit', type: 'text',initialWidth:100},
{label:'Fecha de Compra',fieldName:'opendate', type: 'date',initialWidth:150, typeAttributes: {timeZone:"UTC"}},
{label:'Cantidad',fieldName:'qty', type: 'number',initialWidth:150},
{label:'Total(valor)',fieldName:'total', type : 'number',initialWidth:150},
{label:'NIT comprador',fieldName:'nit_comprador', type: 'number',initialWidth:100},
{label:'Nombre Comprador',fieldName:'nombre_comprador', type: 'text',initialWidth:100},
{label:'Teléfono Comprador',fieldName:'phone_comprador', type: 'phone',initialWidth:150},
{label:'NIT Envio',fieldName:'nit_envio', type: 'number',initialWidth:150},
{label:'Cliente Envio',fieldName:'cliente_envio', type: 'text',initialWidth:150},
{label:'Número de pedido',fieldName:'pedido', type: 'text',initialWidth:150},

]; 

export default class alk_Invoice_Details extends LightningElement {
@api invoiceId;
@api location;
@api isLoading ;
@api ean;
@api recordId;
@api objectApiName;
@api rowIndex;
@api isSearchCurrentRowByEan;

//Modify Date 29/06/2022
//Modify by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com.
//Change :Create new var to assign results by get returns and product detail.
@api productList;
@api productList2;
@api productListFnl;
@api errorOnInvoiceListItm;
productListFnlHlp={};
@track invoiceList=[];
@track invoiceListHlp;
@track errorOnInvoiceListSearch;
@api showProductDetail= false;
invoiceSearchColumns = invoiceSearchColumns;
countDays=0;
countDate;
cltEnvDoc;
cltEnv;
//

showError(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
}
    
handleRowAction(event) {
    this.isLoading = true;
    this.showProductDetail = false;
    const row = event.detail.row;
    this.rowIndex = row.rowIndex;
    this.ean=row.ean;
    this.productListFnl=[];  
    if(row.pedido!=undefined || row.pedido!=null ){
        var oNum=row.pedido.substring(0,3); 
        let realDt;
        srchDespachos({ invoiceNumber: this.invoiceId})
            .then(result => {
                let despachoLstHlp= JSON.parse(result);
                this.cltEnvDoc=despachoLstHlp.documentoEnvio;
                this.cltEnv=despachoLstHlp.clienteEnvio;
                despachoLstHlp.details.forEach(element => {
                    if (element.tipoRma===0 && 
                        element.ean===this.ean &&
                        element.no_despacho===row.pedido) { 
                        realDt = element.fechaReal; 
                    }
                });
              })
            .catch(error => {

                if (!error.body.message.includes("status code 404")) {
                    this.showError('Oops Error!','Obteniendo Despachos! '+ error.body.message, 'error');
                } else {
                    console.log('Obteniendo Despachos! '+ error.body.message);
                } 
               })
            .finally(()=> this.valTypeOrder(oNum,row.opendate,realDt));
    }
    if (this.invoiceId != '' && this.location !== undefined && this.location !== null && this.ean != null){
        searchDevolutions({ invoiceNumber: this.invoiceId})
        .then(result => {
            this.productList2 = result;
            this.errorOnInvoiceListItm = undefined;
            if (this.productList2.length>0){
                this.productListFnl=this.productList2;
                this.isSearchCurrentRowByEan = true;
            }
        })
        .catch(error => {
            this.errorOnInvoiceListItm = error;
            this.productList2 = undefined;
             })
        .finally(() =>this.srchPrdDtlBU(row));
    }     
}

srchPrdDtlBU(row){
    this.isLoading = true;
    searchProductDetailBU({ invoiceNumber: this.invoiceId, location : this.location, ean : this.ean})
        .then(result => {
            this.showProductDetail = false;
            if (this.isSearchCurrentRowByEan) {
                this.searchCurrenRowByEan(this.ean,this.productListFnl);
            } else {
                this.searchCurrenRowByRowIndex(this.rowIndex,this.productListFnl);            
            }
            this.productList = [result];
            this.productList[0].eanCode = this.ean;
            this.errorOnInvoiceListItm = undefined;
            if (this.productList.length>0 && this.productListFnl != undefined){
                this.productListFnlHlp= {...this.productList[0],...this.productListFnl[0],...row};
                this.productListFnl=[];
                this.productListFnl.push(this.productListFnlHlp);
            } else{
                this.productListFnlHlp= {...this.productList[0],...row};
                this.productListFnl=[];
                this.productListFnl.push(this.productListFnlHlp);
            }
            this.productListFnl[0].cntDays = this.countDays;
            this.productListFnl[0].dtCntDays=this.countDate;
            this.productListFnl[0].nit_envio=this.cltEnvDoc;
            this.productListFnl[0].cltEnv=this.cltEnv;
            this.showProductDetail = true;
           })
        .catch(error => {
            this.errorOnInvoiceListItm = error;
            this.productList = undefined;
           })
        .finally(() =>this.isLoading = false,this.showProductDetail = true)
}

handleOnLoad() {    
    this.showProductDetail = false;   
    this.isLoading = true;
    this.rowIndex = 1;
    if (this.invoiceId != '' && this.location !== undefined && this.location !== null){
            searchInvoiceDetail({ invoiceNumber: this.invoiceId, location : this.location})
            .then(result => {
                this.invoiceListHlp = result; 
                //Modify by Daniel Murcia Suarez -DGMS- daniel.murcia@globant.com
                //Modify Date 28/06/2022
                //Change : Change the way to show all invoice items.            
                this.invoiceListHlp.forEach(element => {
                        element.details.forEach(intEl =>{
                            this.invoiceList.push ({
                                'invoice': element.invoice,
                                'ean': intEl.inv_item_id,
                                'descr': intEl.descr,
                                'location': this.location,
                                'business_unit': element.business_unit,
                                'opendate': intEl.accounting_dt,
                                'qty': intEl.qty,
                                'total': intEl.amount_with_disc,
                                'nit_comprador': element.ruc,
                                'nombre_comprador': element.name,
                                'phone_comprador': element.client_phone,
                                'cliente_envio': element.business_unit,
                                'pedido':intEl.order_no,
                                'rowIndex':this.rowIndex++,
                                // and so on for other fields
                            });});});
                this.errorOnInvoiceListSearch = undefined;
              })
            .catch(error => {
                this.errorOnInvoiceListSearch = error;
                this.invoiceList = undefined;
             })
            .finally(() => {
                this.isLoading = false;
                this.rowIndex = 0; 
            });
        }
    }

valTypeOrder(oNumInp, opDateInp, realDtInp){
    if (oNumInp ==='VEN' &&(opDateInp!=undefined ||opDateInp!=null)){
        this.countDaysLgc(opDateInp);
    }else if (oNumInp ==='DES' && (realDtInp!=undefined ||realDtInp!=null)){
        this.countDaysLgc(realDtInp);
    }
}
countDaysLgc (inpDtInpI){
    var inpDtInp = inpDtInpI.replace(/^(\d{1,2}\/)(\d{1,2}\/)(\d{4})$/,"$2$1$3");
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); 
    var yyyy = today.getFullYear();
    today = yyyy + '-' + mm + '-' + dd;
    let dtToday=new Date(today);
    dtToday.setDate(dtToday.getDate() + 1);
    let Difference_In_Time; 
    
    let inpDt=new Date(inpDtInp);
    if (inpDtInp.split("/").length == 1) {
        inpDt.setDate(inpDt.getDate() + 1);
    }

    this.countDate=inpDt.getFullYear()+'-'+String(inpDt.getMonth() + 1).padStart(2, '0')+'-'+String(inpDt.getDate()).padStart(2, '0');
    Difference_In_Time = dtToday.getTime() - inpDt.getTime();
    this.countDays = Math.round(Difference_In_Time/(1000 * 3600 * 24));
}

searchCurrenRowByRowIndex(indexInp, inptLst){
    this.productListFnl =[Object.values(inptLst).find((obj) => {
        return obj.rowIndex == indexInp;
    })];
}

searchCurrenRowByEan(eanInp, inptLst){
    this.productListFnl =[Object.values(inptLst).find((obj) => {
        return obj.ean == eanInp;
    })];
}

}