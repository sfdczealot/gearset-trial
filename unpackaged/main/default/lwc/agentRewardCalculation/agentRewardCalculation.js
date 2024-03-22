import { LightningElement , api , wire, track } from 'lwc';
import populateFields from '@salesforce/apex/AgentRewardCalculatorController.prePopulateFields';
import calculateTotalSpending from '@salesforce/apex/AgentRewardCalculatorController.calculateTotalSpending';
import runRewardCalculation from '@salesforce/apex/AgentRewardCalculatorController.runRewardCalculation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import errorMsg from '@salesforce/label/c.ADD_ERROR_UNDETECTED';
export default class agentRewardCalculation extends LightningElement {
    @api recordId;
    @track loyaltyDate;
    @track calculateED;
    @track xFactor;
    @track yFactor;
    @track originalXFactor;
    @track originalYFactor;
    @track showPopup = false;
    @track calculatedData = {};
    @track showSpinner = false;
    @track agentcountry;
    @track toastErrorMsg = false;
    @track eligibleAgent = false;
    @track showCountryError = false;
    @track pgfPoints;
    @track pgPoints;
    @track currencyCode;

    @wire(populateFields, {
        accId: '$recordId'
    }) resWrapper(result){
        if(result.data){
        this.parseDataResponse = JSON.parse(result.data.response);
        this.agentcountry = this.parseDataResponse.agtCountry;
        if(this.agentcountry == 'Singapore' || this.agentcountry == 'Malaysia'|| this.agentcountry == 'Thailand'){
        this.eligibleAgent = true;
        this.loyaltyDate = this.parseDataResponse.loyaltyStartDate;
        this.calculateED = this.parseDataResponse.calculateEndDate;
        this.xFactor = this.parseDataResponse.XFactor;
        this.originalXFactor = this.parseDataResponse.XFactor;
        this.yFactor = this.parseDataResponse.YFactor;
        this.originalYFactor = this.parseDataResponse.YFactor;
        this.pgfPoints = this.parseDataResponse.pgfRewardPoints;
        this.pgPoints = this.parseDataResponse.pgRewardPoints;
        this.currencyCode = this.parseDataResponse.CurrencyIsoCode;
        }
        else{
            this.showCountryError = true;
        }
        }
    }

    updateValue(event){
        this[event.target.name] = event.target.value;
    }

    getTotalSpending(){
        this.XYFactorZeroValidation();
        if(this.toastErrorMsg){
            console.log('error',this.toastErrorMsg);
            return;
        }
        else {
            this.commonMethForTotalSpending(true);
        }
    }
    
    commonMethForTotalSpending(totalSpendingButton){
        this.showSpinner = true;
        calculateTotalSpending({
            accId: this.recordId,
            country: this.agentcountry,
            LSD: this.loyaltyDate,
            CED: this.calculateED,
            xFact: this.xFactor,
            yFact: this.yFactor,
            pgPoints:this.pgPoints,
            pgfPoints:this.pgfPoints,
            CurrencyIsoCode:this.currencyCode           
          }).then((result)=>{
                if(result.isSuccess){
                    var parseWrapResponse = JSON.parse(result.response);
                for (var accResponse in parseWrapResponse) {
                    var tempVar = parseWrapResponse[accResponse];
                if(tempVar.accId == this.recordId){
                this.showPopup = totalSpendingButton;
                this.calculatedData = tempVar;
                if(!totalSpendingButton) {
                    this.runRewardDML();
                }
                else{
                    this.showSpinner = false; 
                }
        }
        }
            
        }
        else{
                this.calculatedData = '';
                this.showSpinner = false; 
                this.showToast('ERROR',result.message);
        }
            })
            .catch((error) => {
                this.calculatedData = '';
                this.showSpinner = false; 
                this.showToast('ERROR',errorMsg);
            })
    }

    runRewardCalculator(){
        this.XYFactorZeroValidation();
        if(this.toastErrorMsg){
            return;
        }
        else {
            if(this.xFactor!= this.originalXFactor || this.yFactor!= this.originalYFactor) {
                this.showToast('ERROR','X-Factor and Y-Factor should be same as defined.');
                return;
            }
            this.commonMethForTotalSpending(false);
        }
    }

    runRewardDML(){
        runRewardCalculation({
            totalSpending: JSON.stringify(this.calculatedData),
              }).then((result)=>{
                if(result.isSuccess){
                this.showToast('SUCCESS','Completed Successfully.');
                this.showSpinner = false;
                }
                else{
                    this.showToast('ERROR',result.message);
                    this.showSpinner = false;
                }
                })
                .catch((error) => {
                    this.showToast('ERROR',errorMsg);
                    this.showSpinner = false;
                })
    }

    XYFactorZeroValidation(){
        this.toastErrorMsg = false;
        if(this.xFactor == '' || this.xFactor == 0 || this.yFactor == '' || this.yFactor == 0) {
            this.showToast('ERROR','X-Factor and Y-Factor cannot be blank or zero.');
            this.toastErrorMsg = true;
        }
    }

    closePopup(){
        this.showPopup = false;
    }
    showToast(title,msg) {
        const event = new ShowToastEvent({
          title: title +'! ',
          message: msg,
          variant: title
         });
        this.dispatchEvent(event);
      }
}