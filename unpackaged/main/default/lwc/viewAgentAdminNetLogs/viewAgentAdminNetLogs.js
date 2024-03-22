import { api,wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { NavigationMixin } from 'lightning/navigation';
import getAdminAuditLogs from '@salesforce/apex/AccountActionsCtlr.getAdminAuditLogs';
import getAuthorName from '@salesforce/apex/AccountActionsCtlr.getAuthorDetails';
import getSectionList from '@salesforce/apex/AccountActionsCtlr.getSectionList';
import getActionCodeList from '@salesforce/apex/AccountActionsCtlr.getActionCodeList';
import thailandCountry from '@salesforce/label/c.THAILAND_REGION';
import singaporeCountry from '@salesforce/label/c.SINGAPORE_REGION';
import malaysiaCountry from '@salesforce/label/c.MALAYSIA_REGION';
const actions = [{ label: 'Show Author Details', name: 'showAuthorDetails' }];
import {loadStyle} from 'lightning/platformResourceLoader';
import accountActionCmpCss from '@salesforce/resourceUrl/AccountActionCmpCss'
export default class ViewAgentAdminNetLogs extends NavigationMixin(LightningModal) {
    @api agentNetId;
    @api agentCountry;
    @api title;
    sectionList;
    isLoading=true;
    logType='showActionByAgent';
    actionOptions=[{
        label: '- Any -', value: '' 
    }];
    action='';
    pageNumber=1;
    showListingId=false;
    listingId;
    inputChanged=false;
    section='';
    totalRecords;
    data;
    sectionIdVsCode=[];
    sectionCodeVsId={};
    sectionCodeVsLabel={};
    validationMessage;
    pageRecordLimit=20;
    toDate=this.todayDate;
    fromDate=this.twoMonthBeforeDate;
    isCssLoaded=false;
    columns = [
        { label: 'Date/Time', fieldName: 'dateTime' ,hideDefaultActions:true,initialWidth: 70,wrapText:true},
        { label: 'Section', fieldName: 'sectionCode',hideDefaultActions:true,wrapText:true,initialWidth: 65,cellAttributes:{
            class:'wrap-text-css'
            }
        },
        { label: 'Action', fieldName: 'actionCode' ,hideDefaultActions:true,wrapText:true,initialWidth: 60,cellAttributes:{
            class:'wrap-text-css'
            }
        },
        { label: 'Old Value', fieldName: 'oldValue',type: 'text',hideDefaultActions:true,wrapText:true,cellAttributes:{
            class:'wrap-text-css'
        },wrapText:true
        },
        { label: 'New Value', fieldName: 'newValue',hideDefaultActions:true,wrapText:true,cellAttributes:{
            class:'wrap-text-css'
            }
        },
        
        { label: 'Object Id', fieldName: 'objectId',hideDefaultActions:true, initialWidth: 45,cellAttributes:{
            class:'wrap-text-css'
            }
        },
        { label: 'IP Address', fieldName: 'ipAddress' ,initialWidth: 55,hideDefaultActions:false,wrapText:true},
        { label: 'Author', fieldName: 'author' ,initialWidth: 50,hideDefaultActions:false,wrapText:true},
        {type:'action',typeAttributes:{rowActions:actions}}
    ];
    renderedCallback(){ 
        if(this.isCssLoaded){
            return;
        }
        loadStyle(this, accountActionCmpCss+'/AccountActionCmpCss.css').then(()=>{
            this.isCssLoaded = true;
        }).catch(error=>{ 
            this.validationMessage=this.processError(error);
        });
    }
    @wire(getSectionList,{country:'$agentCountry'})
    sectionListResponse(result){
        if(result.data){
            // section codes
            if(result.data && result.data.isSuccess){
                this.sectionList=[{
                    label: '- Any -', value: '' 
                }];
                for(let i=0;i<result.data.data.length;i++){
                    let sectionRecord=result.data.data[i];
                    let sectionIdVsCodeObj={[sectionRecord.id]:sectionRecord.code};
                    this.sectionCodeVsLabel[sectionRecord.code]=sectionRecord.description;
                    this.sectionCodeVsId[sectionRecord.code]=sectionRecord.id;
                    this.sectionIdVsCode.push(sectionIdVsCodeObj);
                    let sectionObj={label:sectionRecord.description,value:sectionRecord.code};
                    this.sectionList.push(sectionObj);
                }
            }
            //Error in response
            else{
                this.validationMessage=this.processError(result.data.errorMessage);
            }
            this.isLoading=false;
        }
        else if(result.error){
            this.validationMessage=this.processError(result.error);
            this.isLoading=false;
        }
    }
    connectedCallback(){
        if(!this.agentCountry){
            this.validationMessage='Country is not present on this agent record';
        }
    }
    handleChange(event){
        this.inputChanged=true;
        //Change in from date 
        if(event.target.name == 'fromDate'){
            this.fromDate=event.detail.value;
        }
        else if(event.target.name === 'listingID'){
            this.listingId=event.detail.value;
        }
        //Change in to date 
        else if(event.target.name == 'toDate'){
            this.toDate=event.detail.value;
        }
        else if(event.target.name == 'action'){
            this.action=event.detail.value;
            
        }
        else if(event.target.name == 'section'){
            this.showListingId=false;
            this.action='';
            let newActionOptions=[{label:'- Any -',value:''}];
            if(event.detail.value && this.section !== event.detail.value){
                this.isLoading=true;
                getActionCodeList({country:this.agentCountry,sectionCode:event.detail.value})
                .then(result=>{
                    if(result.isSuccess){
                        if(result.data){
                            for(let i=0;i<result.data.length;i++){
                                let actionObj={label:result.data[i].description,value:result.data[i].code};
                                newActionOptions.push(actionObj);
                            }
                        }
                        if(this.agentCountry === malaysiaCountry || this.agentCountry === singaporeCountry){
                            if(this.section === 'LISTINGS' || this.section ==='FEATURED_LISTING' ){
                                this.showListingId=true;
                            }
                        }
                        else if(this.agentCountry === thailandCountry && this.section === 'LISTINGS' ){
                            this.showListingId=true;
                        }
                        this.actionOptions=newActionOptions;
                        this.isLoading=false;
                    }
                    else{
                        this.validationMessage=this.processError(result.errorMessage);
                    }
                })
                .catch(err=>{
                    this.validationMessage=this.processError(err);
                    this.isLoading=false;
                });
            }
            //Handling if section is changed to any 
            else if(!event.detail.value){
                this.actionOptions=newActionOptions;
            }
            this.section=event.detail.value;
        }
        else if(event.target.name == 'logType'){
            this.logType=event.detail.value;
        }
    }
    handleRowActions(event) {
        let row=event.detail.row;
        if(row && row.userId && !row.author){
            this.isLoading=true;
            getAuthorName({userId:row.userId,country:this.agentCountry}).then(result=>{
                if(result.isSuccess && result.data){
                    let dataObj=JSON.parse(result.data);
                    row.author=dataObj.firstname +' '+dataObj.lastname ;
                    this.data=JSON.parse(JSON.stringify(this.data));
                }
                else{
                    this.fireToastEvent('error',result.errorMessage,'Failed to get author details');
                }
                this.isLoading=false;
            }).catch(err=>{
                this.fireToastEvent('error',this.processError(err),'Failed to get author details');
                this.isLoading=false;
            });
        }
        
    }
    fireToastEvent(type,message,title) {
        // Creates the event 
        const completeEvent = new CustomEvent('complete', { detail:{
           toastType:type,
           toastMessage:message,
           toastTitle:title
        }});
       this.dispatchEvent(completeEvent);
    }
    options= [{ label: 'Show Actions by Agent', value: 'showActionByAgent' },
    { label: 'Show Actions on Agent', value: 'showActionOnAgent' },{ label: 'Show Both', value: 'both' }];
    errorMessage;
    getAuditLogs(newSearch){
        //Error 
        if(this.validateInputs()){
            this.isLoading=false;
            return;
        };
        if(newSearch){
            this.pageNumber=1;
        }
        this.isLoading=true;
        this.errorMessage=null;
        getAdminAuditLogs({mapOfSelectedFieldNameVsValue:this.getInputObject()}).then(result=>{
            if(result.isSuccess && result.data){
                    let resultObj=JSON.parse(result.data);
                    let sectionData=result.sectionData;
                    if(resultObj.total > 0){                        
                        this.totalRecords=resultObj.total;
                        this.data=this.processResult(resultObj.audits,sectionData);
                    }
                    else{
                        this.errorMessage='Can\'t find any log data';
                        this.data=null;
                    }
            }
            //Show error
            else{
                this.errorMessage=result.errorMessage;
                this.data=null;
            }
            this.isLoading=false;
        }).catch(err=>{
            this.errorMessage=this.processError(err);
            this.isLoading=false;
            this.data=null;
        });
    }
    processResult(result,sectionData){
        if(result ){
            let key=1;
            for(let i=0;i<result.length;i++){
                let auditRecord=result[i];
                let sectionCodeId=auditRecord.sectionCode;
                //Date formatting
                if(auditRecord.date && auditRecord.time && auditRecord.time.split('T')){
                    auditRecord.dateTime=auditRecord.date;
                    let time=auditRecord.time.split('T')[1];
                    if(time && time.length >= 8){
                        auditRecord.dateTime+=' '+time.substring(0,8);
                    } 
                }
                auditRecord.key=key;
                //action code label rename
                if(this.sectionCodeVsId && this.sectionCodeVsId[auditRecord.sectionCode] ){
                    let sectionId=this.sectionCodeVsId[auditRecord.sectionCode];
                    if(sectionId && sectionData[sectionId] && sectionData[sectionId].length> 0){
                        let actionCodesInSection=sectionData[sectionId];
                        let actionCodeIndex=actionCodesInSection.findIndex(actionCodeObj => actionCodeObj.actionCode === auditRecord.actionCode);
                        if(actionCodeIndex > -1){
                            auditRecord.actionCode=actionCodesInSection[actionCodeIndex].actionLabel;
                        }                        
                    } 
                    }
                //section rename
                if(this.sectionCodeVsLabel && this.sectionCodeVsLabel[auditRecord.sectionCode] ){
                    auditRecord.sectionCode= this.sectionCodeVsLabel[auditRecord.sectionCode];
                }
                key++;
            }
        }
        return result;
    }
    getLogs(){
        this.getAuditLogs(true);
    }
    getInputObject(){
        let obj={};
        obj.agentNetId=this.agentNetId;
        obj.fromDate=this.fromDate;
        obj.endDate=this.toDate;
        obj.section=this.section;
        obj.action=this.action;
        obj.agentCountry=this.agentCountry;
        obj.logType=this.logType;
        obj.pageNumber=this.pageNumber;
        obj.listingId=(this.showListingId)?this.listingId:null;
        return obj;
    }
    handleNext(){
        this.isLoading=true;
        this.pageNumber++;
        this.getAuditLogs();
    }
    handlePrevious(){
        this.isLoading=true;
        this.pageNumber--;
        this.getAuditLogs();
    }
    get disableNext(){
        if(this.data && this.totalRecords && this.totalRecords > 0 && (this.pageRecordLimit * this.pageNumber < this.totalRecords )){
            return false;
        }
        return true;
    }
    get disablePrevious(){
        if( this.pageNumber > 1){
            return false;
        }
        return true;
    }
    get todayDate(){
        let todayDate=new Date();
        let month=todayDate.getMonth() +1;
        return todayDate.getFullYear()+'-'+ String(month).padStart(2, '0')+'-'+ String(todayDate.getDate()).padStart(2, '0');
    }
    get twoMonthBeforeDate(){
        let todayDate=new Date();
        let lastMonthIndex=todayDate.getMonth()- 1;
        let year=lastMonthIndex<=0?todayDate.getFullYear()-1:todayDate.getFullYear();
        let month=lastMonthIndex<=0 ?lastMonthIndex +12 :lastMonthIndex ;
        return year+'-'+ String(month).padStart(2, '0')+'-'+ String(todayDate.getDate()).padStart(2, '0');
    }
    validateInputs(){
        let hasError=false;
        this.errorMessage=null;
        let fromDateInput = this.template.querySelector("[data-name='fromDate']");
        let toDateInput = this.template.querySelector("[data-name='toDate']");
        toDateInput.setCustomValidity("");
        fromDateInput.setCustomValidity(""); 
        if(!this.fromDate){
            hasError=true;
            fromDateInput.setCustomValidity("Please select a date");
        }
        if(!this.toDate){
            hasError=true;
            toDateInput.setCustomValidity("Please select a date");
        }
        else if(this.fromDate && this.toDate && new Date(this.fromDate) > new Date(this.toDate)){
            fromDateInput.setCustomValidity("From date can\'t be greater than To date.");
            //this.errorMessage='From date can\'t be greater than To date.';
            hasError=true;
        }
        fromDateInput.reportValidity();
        toDateInput.reportValidity();
        return hasError;
    }
    processError(error){
        let errorMessage='Unknown Error';
        if(typeof error === 'string'){
            errorMessage=error;
        }
        else if(error.body){
            // UI Api read operation return an array of objects
            if(Array.isArray(error.body)){
                errorMessage=error.body.map(e=> e.message).join(', ');
            }
            //update wire error handling
            else if(error.body.output && error.body.output.errors){
                errorMessage=error.body.output.errors.map(e=> e.message).join(', ');
            }
            //UI api write operation, apex read and write error handling
            else if(typeof error.body.message === 'string'){
                errorMessage='';
                errorMessage+=(error.body.exceptionType)?error.body.exceptionType+' : ':'';
                errorMessage+=error.body.message;
                errorMessage+=(error.body.stackTrace)?' Stack Trace : '+error.body.stackTrace:'';
            }
        }
        return errorMessage;
    }   
}