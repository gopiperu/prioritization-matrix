import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import updateCriteriaEvaluation from '@salesforce/apex/PrioritizationMatrixController.updateCriteriaEvaluation';

export default class CriteriaItem extends LightningElement {
    @api criteria;
    @api option;
    @track currentOption;
    @api val=15000;
    @api isRange = false;
    @api isPicklist = false;
    @api isMultiSelect = false;
    localScore = '123';
    connectedCallback() {
        if(this.criteria.type == 'Range')
        {
            this.isRange = true;
            this.isPicklist = false;
            this.isMultiSelect = false;
        }
        else if(this.criteria.type == 'Picklist')
        {
            this.isRange = false;
            this.isPicklist = true;
            this.isMultiSelect = false;
        }
        else if(this.criteria.type == 'Multiselect')
        {
            this.isRange = false;
            this.isPicklist = false;
            this.isMultiSelect = true;
        }
        this.currentOption = this.criteria.selectedOption;
    }
    handleStepBlur(event) {
        const stepIndex = event.detail.index;
        console.log('stepIndex--',stepIndex);
    }
    
    handleChange(event)
    {
        this.dispatchEvent(new CustomEvent('optionchange', {detail: {
            criteriaId: event.detail.criteriaId,
            score : event.detail.score,
            optionList : event.detail.optionList,
            userValue : event.detail.userValue,
        }}));
    }
    resetValue(newVal)
    {
        this.currentOption = newVal;
    }
}