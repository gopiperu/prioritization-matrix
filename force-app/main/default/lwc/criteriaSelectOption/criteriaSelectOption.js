import { LightningElement, api ,track } from 'lwc';

export default class CustomPath extends LightningElement {
    @api currentOption;
    @api optionValues;
    @api criteriaId;
    @api criteriaItem;
    @track optionVal;
    connectedCallback() {

    }
    handleSelect(event)
    {
        var currOption = event.currentTarget.dataset.value;
        let selectedOption = event.currentTarget.dataset.value;
        let selectedStyle = event.currentTarget.dataset.style;
        let score = event.currentTarget.dataset.score;
        let optionList = [];
        this.criteriaItem.options.forEach(function(eachitem){
            var newOption ={};
            newOption.selected = false;
            newOption.value = eachitem.value;
            newOption.classList = eachitem.classList;
            newOption.label = eachitem.label;
            newOption.style = eachitem.style;
            newOption.classList = 'slds-path__item slds-is-incomplete';
            if(newOption.value == selectedOption)
            {
                newOption.selected = true;
                newOption.classList = 'slds-path__item slds-is-complete';
                if(typeof selectedStyle != "undefined")
                {
                    newOption.classList = newOption.classList + ' ' + selectedStyle;
                }
            }
            optionList.push(newOption);
        });
        console.log('criteriaItem-OptionList->',optionList);
        this.dispatchEvent(new CustomEvent('optionchange', { detail: {
            criteriaId: this.criteriaId,
            optionList : optionList,
            score: score
        }  }));
    }
}