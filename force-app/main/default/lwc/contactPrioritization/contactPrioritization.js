import { LightningElement,api,track,wire } from 'lwc';
import getPrioritizationRecords from '@salesforce/apex/ContactPrioritizationController.getPrioritizationRecords';
export default class ContactPrioritization extends LightningElement {
    @api recordId;
    priorityLst;
    @track priorityExist;
    connectedCallback(){
        this.priorityExist = false;
    }
    @wire(getPrioritizationRecords,{ recordId: '$recordId'}) wiredPriorityLst(result)
    {        
        this.priorityLst = result.data;
        
        if(typeof result.data != "undefined" && result.data.length > 0)
        {
            this.priorityExist = true;   
        }
        else
        {
            this.priorityExist = false;
        }
        
        console.log('this.priorityLst-->',this.priorityLst);
    };    

}