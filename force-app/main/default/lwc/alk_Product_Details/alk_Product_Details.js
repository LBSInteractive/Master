import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import assignInvoice from '@salesforce/apex/ALK_InvoiceSearch_LWC.assignInvoice';

const productDetailsColumns = [
    {label:'Proveedor',fieldName:'brandDescription', type: 'text',initialWidth:100},
    {label:'EAN',fieldName:'eanCode', type: 'text',initialWidth:100},
    {label:'Descripción',fieldName:'descr', type : 'text',initialWidth:100},
    {label:'Familia',fieldName:'categoryDescription', type: 'text',initialWidth:100},
    {label:'Grupo',fieldName:'groupDescription', type: 'text',initialWidth:100},
    {label:'Marca',fieldName:'brandCode', type: 'text',initialWidth:150},
    {label:'Contador de Días de Entregado',fieldName:'cntDays', type: 'number',initialWidth:150},
    {label:'Fecha Devolución',fieldName:'devolutionDate', type: 'text',initialWidth:100},
    {label:'Valor Devolución',fieldName:'total', type: 'number',initialWidth:100},
    {label:'Motivo Devolución',fieldName:'reason', type: 'text',initialWidth:150},
    {label:'Tienda Devolución',fieldName:'businessUnit', type: 'text',initialWidth:150},
  ]; 

export default class Alk_Product_Details extends NavigationMixin(LightningElement){
    @api invoiceId;
    @api location;
    @api eanCode;
    @api isLoading ;
    @api objectApiName;
    //Modify Date 29/06/2022
    //Modify by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com.
    //Change :Create new var to assign results by get returns and product detail.
	@api errorOnInvoiceListSearch;//
    @api productListFnl;//
    @api recordId;
    productDetailsColumns = productDetailsColumns;
    
    showError(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    handleOnClick(){
        this.isLoading = true;
        console.log(JSON.stringify(this.productListFnl));
        assignInvoice({ jsonData: JSON.stringify(this.productListFnl), caseId: this.recordId})
             .then(result => {
                let invId=result.substring(8, 26);
                this.navToRecordView(invId); 
            })
            .catch(error => {
                this.showError('Error!',error.body.message,error);
                console.log('error invoice detail data '+JSON.stringify(error));
            })
            .finally(() => this.isLoading = false );
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
}