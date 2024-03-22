import { LightningElement,track,wire,api } from 'lwc';
import fetchProductDetails from '@salesforce/apex/createOpportunities.fetchProductDetails';
import saveOpportunity from '@salesforce/apex/createOpportunities.saveOpportunity';


export default class LwcFormValidation extends LightningElement{


@track eligibleAgent = true;
@track showCountryError = false;
@track accountId;
@track quickActionAPIName;
@track fmList=[];
@track data=[];
@api sObjName;
@track recordtype;
@api recordId;
@track newObjId;
@track message;
@track Title;
@track endResult;
@track showSpinner = true;
@track createOpp = false;
@track createAcc = false;
@track PGProducts=[];
@track iPProducts=[];
@track jsonResponse=[];
@track toastClass;
@track toastButton;
@track isToast= false;
@track selectedName;
@track selectedId;
@track valueSelected;
@track BrickzAgent;
@track OverlapAgent;
@api navigateToList;
@api navigateToHome;



createOpportunity(){
   var inp=this.template.querySelectorAll("lightning-input");
   var allow= true;
   
   inp.forEach(function(element){
     
      if(element.name=="PersonMobilePhone"||element.name=="PersonEmail"){
         if(element.value==null||element.value==''||element.value=='undefined'||element.value=='null'){
            this.showToast('ERROR',element.label+' cannot be blank'); 
            allow = false;
         }
      }
         

  },this);
  var picklist=this.template.querySelectorAll("lightning-combobox");
  
  picklist.forEach(function(element){
    
     if(element.name=='function__pc'||element.name=='Position_Type__pc'||element.name=="Mobile_Country__c"){
        if(element.value==null||element.value==''||element.value=='undefined'||element.value=='null'){
           this.showToast('ERROR',element.label+' cannot be blank'); 
           allow = false;
        }
     }
        

 },this);
  if(allow==true){
  
   this.showSpinner = true;
   saveOpportunity({jsonResponse: JSON.stringify(this.jsonResponse),
      sObjName : this.sObjName,
      recordtype : this.recordtype

   }).then((result)=>{
    
      if(result.isSuccess){
         this.parseDataResponse = JSON.parse(result.response);
         this.newObjId = this.parseDataResponse.objId;
        
          this.showToast('SUCCESS',this.sObjName+' is created successfully');
      }else{
         this.showToast('ERROR',result.message);
      }
   }).catch((error) => {
      this.showSpinner = false;
                this.showToast('ERROR',error);
            })
         }
 }
 connectedCallback(){
   this.showSpinner = true;
   this.fetchDetails();
} 


 fetchDetails(){
   fetchProductDetails({
      quickAction : this.sObjName,
      recordId : this.recordId
   }).then((result)=>{
      this.showSpinner = false;
      if(result.isSuccess){
  
         this.parseDataResponse = JSON.parse(result.response);
         if(this.parseDataResponse.recordName!=null){
            this.selectedId = this.recordId;
            this.selectedname =  this.parseDataResponse.recordName;
            this.valueSelected = true;
            this.jsonResponse.push({label:'AccountId',value:this.recordId});
           
         }else{
            this.valueSelected = false; 
         }
        
         for(var i=0; i< this.parseDataResponse.fmList.length; i++){
            let isCheckbox = false;
            if(this.parseDataResponse.fmList[i].DataType__c == 'Checkbox'){
               isCheckbox = true;  
            }
            if(this.parseDataResponse.fmList[i].Related_List_Label__c!=null){
               this.fmList.push({label:this.parseDataResponse.fmList[i].Label__c,Related_List_Label:this.parseDataResponse.fmList[i].Related_List_Label__c,lookup:true
                  ,picklist:false,NonPicklist:false,api:this.parseDataResponse.fmList[i].from__c,
                  filter:this.parseDataResponse.fmList[i].filter_query__c,
                  required : this.parseDataResponse.fmList[i].Required__c,
                  relatedObjectAPI : this.parseDataResponse.fmList[i].related_Object_API__c,
                  isCheckbox : false});
           
            }else{
              
               if(this.parseDataResponse.fmList[i].DataType__c == 'Picklist'){
                  var pickValue=[];
                  let picklist = this.parseDataResponse.fmList[i].Picklist_values__c.split(',');
               
                     for(var j=0;j<picklist.length;j++ ){
                        pickValue.push({label:picklist[j],value:picklist[j]});    
                     }
                     this.fmList.push({label:this.parseDataResponse.fmList[i].Label__c,datatype:this.parseDataResponse.fmList[i].DataType__c,picklist:true,NonPicklist:false,
                        lookup:false,value:pickValue,api:this.parseDataResponse.fmList[i].from__c,
                        required : this.parseDataResponse.fmList[i].Required__c,
                        isCheckbox : false}); 
                        
               }else{
               this.fmList.push({label:this.parseDataResponse.fmList[i].Label__c,datatype:this.parseDataResponse.fmList[i].DataType__c,picklist:false,NonPicklist:true,
                  lookup:false,api:this.parseDataResponse.fmList[i].from__c,
                  required : this.parseDataResponse.fmList[i].Required__c,
                  isCheckbox : isCheckbox});
            } 
            }
        
      }

      this.recordtype = this.parseDataResponse.recordtype;
     
         if(this.parseDataResponse.objName=='Opportunity'){
            this.createOpp = true;
            this.Title = 'New Cross-Sell Opportunity';
         for(var i=0; i< this.parseDataResponse.products.length; i++){
            if(this.parseDataResponse.products[i].Instance_Name__c=='ipp'){
            this.iPProducts.push({value:this.parseDataResponse.products[i].Product_Code__c,label:this.parseDataResponse.products[i].Product_Name__c});
            }
            if(this.parseDataResponse.products[i].Instance_Name__c=='PropertyGuru'){
               this.PGProducts.push({value:this.parseDataResponse.products[i].Product_Code__c,label:this.parseDataResponse.products[i].Product_Name__c});
               }
      
          }

       
         }else if(this.parseDataResponse.objName=='Account'){
             this.createAcc = true;
             this.Title = 'New Overlapping Account';
         }
         this.eligibleAgent = true;
      
      }else{

                this.showToast('ERROR',result.message);
             
        }

   })
            .catch((error) => {
               this.showSpinner = false;
                this.showToast('ERROR',error);
            })
    }
    closePopUp(){
      this.eligibleAgent = false;
      if(this.newObjId!=null){
         this.navigateToList(this.newObjId);
      }else{
      if(this.sObjName == 'Opportunity'){
            this.navigateToHome('/006');
           
         }else if(this.sObjName == 'Account'){
            this.navigateToHome('/001');
         }
      }
     
         
      }
   updateValue(event){
  
      let apiname = event.target.name;
      let value;
      
      if(event.target.type!='checkbox'){
         value = event.target.value; 
      }else{
       value = event.target.checked;
      }

      this.jsonResponse.push({label:apiname,value:value});
    
      
   }
 
   handleAccountSelection(event){
      
      this.jsonResponse.push({label:this.template.querySelector('.lookup').getAttribute('data-key'),
      value:event.detail});
    
   }
   showToast(title,msg) {
      let delay = 2000;
      let delayNavigate = 2000;
    
      this.showSpinner = false;
      this.isToast = true;
      this.message = msg;
      this.endResult = title;
     
        setTimeout(() => {
         this.isToast = false;
        }, delay );
       
        if(title=='SUCCESS'){
          setTimeout(() => {
            this.closePopUp();
           }, delayNavigate );
        }
        if(title=='SUCCESS'){
         this.toastClass = 'slds-notify slds-notify_toast slds-theme_success';
         this.toastButton = 'utility:check';
        }else if(title=='ERROR'){
         this.toastClass = 'slds-notify slds-notify_toast slds-theme_error';
         this.toastButton = 'utility:error';
        }
    }
    renderedCallback() {

      const style = document.createElement("style");
  
      style.innerText ='.createOpp-modal .create-lookup{padding: 0px !important;} .create-lookup .slds-pill__remove{position: absolute;   right: 5px;} .create-lookup .slds-pill{width: 100%; text-align: left;justify-content: flex-start;height: 35px;}';
  
      
  
      if (this.template.querySelector(".createOpp-modal"))
  
        this.template.querySelector(".createOpp-modal").appendChild(style);
  
  }
   
}