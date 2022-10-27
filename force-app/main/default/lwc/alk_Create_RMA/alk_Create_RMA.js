//Created Date 13/07/2022
//Created by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com.
import {LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent} from 'lightning/actions';
import searchInvoice from '@salesforce/apex/ALK_createRMA_LWC.searchInvoice';
import srchAddress from '@salesforce/apex/ALK_createRMA_LWC.getAddress';
import searchState from '@salesforce/apex/ALK_createRMA_LWC.searchState';
import searchLocation from '@salesforce/apex/ALK_createRMA_LWC.searchLocation';
import searchRMAParameters from '@salesforce/apex/ALK_createRMA_LWC.searchRMAParameters';
import createRMA from '@salesforce/apex/ALK_createRMA_LWC.createRMA';
import errMsgHD from '@salesforce/label/c.ALK_Error_Message_RMA_Hd';
import errMsgBody from '@salesforce/label/c.ALK_Error_Message_RMA_Bdy';
export default class Alk_Create_RMA extends LightningElement {
    @api recordId;
    @api optionsState;
    @api name;
    @api idNumber;
    @api address;
    @api email;
    @api invoiceNumber;
    @api EAN;
    @api quantityInit = 0;
    @api quantity = 0;
    @api noPedido;
    @api uCollect;
    @api saleStore;
    @api dateSchColl;
    @api reasonPickup;
    @api seqnum;
    @api conveyor;
    @api typeMngmt;
    @api observation;
    @api isLoading;
    @api addressLst;
    @track isShowModal = false;
    @track optionsLoc;
    @track optionsConv;
    @track optionsRePick;
    @track createRMAdisabled = false;

    showError(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    showModalBox() {
        this.isShowModal = true;
    }

    hideModal(event) {
        this.isShowModal = event.detail;
    }

    getaddress(event) {
        this.isShowModal = false;
        this.address = event.detail.address;
        this.seqnum = event.detail.seqnum;
    }

    handleOnLoad() {
        this.isLoading = true;
        this.getLocations();
        this.getStates();
        this.getConveyor();
        this.getReasonPickup();
        searchInvoice({
                caseId: this.recordId
            })
            .then(result => {
                let rpObj = result;
                this.EAN = rpObj.EAN;
                this.name = rpObj.name;
                this.idNumber = rpObj.idNumber;
                this.email = rpObj.email;
                this.invoiceNumber = rpObj.invoiceNumber;
                this.noPedido = rpObj.noPedido;
                this.quantityInit = rpObj.quantity;
                this.quantity = rpObj.quantity;
                this.typeMngmt = rpObj.typeMngmt;
                this.saleStore = rpObj.saleStore;
            })
            .catch(error => {
                this.showError('Error! ', error.body.message, 'error');
                this.closeQuickAction();
            })
            .finally(() => this.isLoading = false);
    }

    getLocations() {
        searchLocation({})
            .then(result => {
                let locOpt = [];
                result.forEach(element => {
                    locOpt.push({
                        label: element.Name,
                        value: element.ALK_Unidad_de_Venta__c,
                    });
                });
                this.optionsLoc = locOpt;
            })
            .catch(error => {
                console.log('error method searchLocation ' + JSON.stringify(error));
            })
            .finally();
    }

    getStates() {
        searchState({})
            .then(result => {
                let stOpt = [];
                result.forEach(element => {
                    stOpt.push({
                        label: element.Name,
                        value: element.Id,
                    });
                });
                this.optionsState = stOpt;
            })
            .catch(error => {
                console.log('error method searchState ' + JSON.stringify(error));
            })
            .finally();
    }

    getConveyor() {
        searchRMAParameters({
                filterStr: 'Conveyor'
            })
            .then(result => {
                let convOpt = [];
                result.forEach(element => {
                    convOpt.push({
                        label: element.RMA_Label__c,
                        value: element.Value__c,
                    });
                });
                this.optionsConv = convOpt;
            })
            .catch(error => {
                console.log('error method searchRMAParameters ' + JSON.stringify(error));
            })
            .finally();
    }

    getReasonPickup() {
        searchRMAParameters({
                filterStr: 'Reason Pickup'
            })
            .then(result => {
                let rPickOpt = [];
                result.forEach(element => {
                    rPickOpt.push({
                        label: element.RMA_Label__c,
                        value: element.Value__c,
                    });
                });
                this.optionsRePick = rPickOpt;
            })
            .catch(error => {
                console.log('error method searchRMAParameters ' + JSON.stringify(error));
            })
            .finally();
    }

    handleSrchAddress() {
        this.isLoading = true;
        srchAddress({
                docNumber: this.idNumber
            })
            .then(result => {
                this.addressLst = result;
                this.showModalBox();
            })
            .catch(error => {
                this.showError('Error! ', error.body.message, 'error');
            })
            .finally(() => this.isLoading = false);
    }

    createRMA() {
        let rmaDataArr = {
            businessUnit: this.saleStore,
            invoice: this.invoiceNumber,
            orderNo: this.noPedido,
            custId: this.idNumber,
            estReturnDt: this.dateSchColl,
            reasonCd: this.reasonPickup,
            returnToIbu: this.uCollect,
            oprid: this.idNumber,
            oprid2: this.idNumber,
            carrierId: this.conveyor,
            addressSeqNum: this.seqnum,
            invItemId: this.EAN,
            qty: this.quantity,
            ckComments: this.observation,
            rmaStatus: this.conveyor === 'AAA-002' ? 'P' : 'O',
            emailTo: this.email
        };
        if ((this.saleStore != null && this.invoiceNumber != null &&
                this.noPedido != null && this.idNumber != null && 
                this.dateSchColl != null && this.reasonPickup != null && 
                this.uCollect != null && this.idNumber != null &&
                this.idNumber != null && this.conveyor != null && 
                this.seqnum != null && this.EAN != null && this.quantity != null &&
                this.observation != null && this.conveyor != null && this.email != null) ||
            (this.saleStore != undefined && this.invoiceNumber != undefined &&
                this.noPedido != undefined && this.idNumber != undefined && 
                this.dateSchColl != undefined && this.reasonPickup != undefined &&
                this.uCollect != undefined && this.idNumber != undefined &&
                this.idNumber != undefined && this.conveyor != undefined &&
                this.seqnum != undefined && this.EAN != undefined &&
                this.quantity != undefined && this.observation != undefined &&
                this.conveyor != undefined && this.email != undefined)) {
            let rmaData = [];
            rmaData.push(rmaDataArr);
            this.createRMAdisabled = true;
            createRMA({
                    jsonInput: JSON.stringify(rmaData),
                    caseId: this.recordId
                })
                .then(result => {
                    if (result.rmaNumber != undefined) {
                        this.showError('Fue creada el RMA con número: ', result.rmaNumber, 'success');
                    } else {
                        let errMsg = result.ErrorCode + '' + result.ErrorDescription;
                        this.showError('No es posible crear el RMA', errMsg, 'error');
                    }
                })
                .catch(error => {
                    this.showError('Error', JSON.stringify(error), 'error');
                })
                .finally(() => this.closeQuickAction());
        }else{
            this.showError(errMsgHD, errMsgBody, 'error');
        }
    }

    uniChange(event) {
        this.uCollect = event.detail.value;
    }

    obsChange(event) {
        this.observation = event.detail.value;
    }

    convChange(event) {
        this.conveyor = event.detail.value;
    }

    rePickChange(event) {
        this.reasonPickup = event.detail.value;
    }

    dtChange(event) {
        this.dateSchColl = event.detail.value;
    }

    qtyChange(event) {
        let newValue = event.detail.value;
        if (newValue <= this.quantityInit) {
            this.quantity = newValue;
        } else {
            let errMsg = 'El Valor de cantidad no puede superar: ' + this.quantityInit;
            this.showError('Valor Erroneo', errMsg, 'error');
            this.quantity = this.quantityInit;
        }
    }

    emlChange(event) {
        this.email = event.detail.value;
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}