import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import searchInvoice from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchInvoice';
import searchInvoiceDetail from '@salesforce/apex/ALK_InvoiceSearch_LWC.searchInvoiceDetail';
import IDENTIFICATION_FROM_CASE from '@salesforce/schema/Case.Account.ALK_Identification_Id__c';
import IDENTIFICATION_FROM_ACCOUNT from '@salesforce/schema/Account.ALK_Identification_Id__c';
import getIdentification from '@salesforce/apex/ALK_InvoiceSearch_LWC.getIdentification';

const fieldsForCase = [IDENTIFICATION_FROM_CASE];
const fieldsForAccount = [IDENTIFICATION_FROM_ACCOUNT];

const invoiceSearchColumns = [
    {label:'No de la factura',fieldName:'invoice', type: 'text'},
    {label:'Fecha de Compra',fieldName:'opendate', type : 'date', typeAttributes: {timeZone:"UTC"}},
    {label:'Almacén',fieldName:'business_unit', type: 'text'},
    {label:'Total(valor)',fieldName:'total', type : 'number'}
  ]; 

export default class aLK_Invoice_Search extends LightningElement {
    @api recordId;
    @api objectApiName;
	@track invoiceList;
    @track invoiceDetail = false;
	@track errorOnInvoiceListSearch;
    invoiceSearchColumns = invoiceSearchColumns;
    isLoading = false;
    customerId;
    startDate;
    endDate;
    invoiceId;
    invoiceSearchId;
    locationSearch;
    location;   
    
    @wire(getRecord, {
        recordId: "$recordId",
        fields: fieldsForCase
    })
    recordDetail;   
    
    @wire(getRecord, {
        recordId: "$recordId",
        fields: fieldsForAccount
    })
    recordDetailAccount;     
    
    customerIdChange(event) {
        this.customerId = event.target.value;
    }    

    startDateChange(event) {
        this.startDate= event.target.value;
    }  
    
    endDateChange(event) {
        this.endDate= event.target.value;
    }  
    
    invoiceIdChange(event) {
        this.invoiceId= event.target.value;
    }  
    
    locationChange(event) {
        this.location= event.target.value;
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
        }else if(this.recordDetailAccount.data !== undefined){
            this.customerId = getFieldValue(this.recordDetailAccount.data, IDENTIFICATION_FROM_ACCOUNT);  
            this.isLoading = false;  
        }else if( this.customerId === undefined || this.customerId === ''){
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
        let actObj=this.objectApiName.toString();
        if (actObj !='Account') {
        const selectedRows = event.detail.selectedRows;
        this.invoiceSearchId = selectedRows[0].invoice;
        this.locationSearch = selectedRows[0].business_unit;
            this.invoiceDetail = true;
            this.invoiceList = false;
        }
    }

    handleInvoiceSearch() { 
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
                searchInvoiceDetail({ invoiceNumber: this.invoiceId, location : this.location})
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
            && (this.invoiceId == '' || this.invoiceId === undefined)
            && (this.location === undefined || this.location === null)
            ){
                this.showError('Faltan datos','Es necesario llenar los datos para hacer la búsqueda!', 'error'); 
            }      
    }       
}