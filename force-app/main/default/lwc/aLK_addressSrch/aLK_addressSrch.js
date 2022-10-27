//Created Date 01/08/2022
//Created by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com.
import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import crtAddress from '@salesforce/apex/ALK_createRMA_LWC.crtAddress';
import searchCity from '@salesforce/apex/ALK_createRMA_LWC.searchCity';
import srchAddress from '@salesforce/apex/ALK_createRMA_LWC.getAddress';

export default class ALK_addressSrch_LWC extends LightningElement {
@api addressLst;
@api idNumber;
@api optionsState;
optionsCity;
stateId;
isShowModal;
selectedAddress;
selectedAddressSeqNum;
createAddressOpt= false;
isLoading = false;
city;
sBttn;
newAddress;
stateName;
    showError(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    hideModalBox() {  
        this.isShowModal= false;
        const closeModalEvent= new CustomEvent("hidemodal",{
            detail:this.isShowModal
        });
        this.dispatchEvent(closeModalEvent);
    }

    getSlectedAddrs(event) {  
        this.selectedAddress=  event.currentTarget.name;
        this.selectedAddressSeqNum=  event.currentTarget.id;
        this.selectedAddressSeqNum=this.selectedAddressSeqNum.substring(0,this.selectedAddressSeqNum.indexOf('-',0));
        this.sBttn=true;
    }

    confirmAddress(){
        let selectedAddressInfo={
            seqnum:this.selectedAddressSeqNum , 
            address:this.selectedAddress};
        this.isShowModal= false;
        const getAddressEvent= new CustomEvent("getaddress",{
            detail:selectedAddressInfo
        });
        this.dispatchEvent(getAddressEvent);
    }

    activateCrtAddrs(){     
        this.createAddressOpt =true;
        this.selectedAddress='';
        this.sBttn=false;
        
    }

    assignNewAddress(event){
        this.newAddress = event.detail.value;
    }

    stChange(event){
        this.stateId = event.detail.value;
        this.stateName = event.target.options.find(opt => opt.value === event.detail.value).label;
        searchCity({ StateId:this.stateId})
        .then(result => {
            let ctyOpt=[];
            result.forEach(element=>{
                ctyOpt.push({
                    label:element.Name,
                    value:element.Name,
                });
            });
            this.optionsCity=ctyOpt;
        })
        .catch(error => {
            console.log('error searchCity method '+JSON.stringify(error));
        })
        .finally(() => this.isLoading = false);
    }

    cityChange(event){
        this.city=event.detail.value;
    }

    createAddress(){        
        this.isLoading= true;
        if (this.newAddress != undefined && this.idNumber != undefined && this.city != undefined && this.stateName!= undefined) {
            crtAddress({ customerId:this.idNumber,address:this.newAddress, city:this.city , stateName:this.stateName})
            .then(result => {                              
                this.createAddressOpt =false;
                this.stateId = '';
                this.city = '';   
                this.newAddress='';  
                if (!result.isError) {             
                    this.handleSrchAddress();
                }else{
                    this.showError('Error! ',result.errorMessage,'error');
                }
            })
            .catch(error => {
                this.showError('Error! ',error.body.message,'error');
            })
            .finally(() => this.isLoading = false ); 
        }else{
            this.showError('Error! ','todos los campos de la nueva dirección son requeridos','error');
            this.isLoading = false;
        }
    }

    handleSrchAddress(){
        this.isLoading=true;
        srchAddress({docNumber: this.idNumber})
        .then(result => {
            this.addressLst=result;
        })
        .catch(error => {
            this.showError('Error! ',error.body.message,'error');
        })
        .finally(() => this.isLoading = false );
    }
}