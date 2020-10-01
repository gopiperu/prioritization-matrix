import { LightningElement, track, api } from 'lwc';

export default class App extends LightningElement {
    @track selectedOptionLst;
    @track yourSelectedValues;
    @api msOptions;
    @api criteriaId;

    getSelectedItems () {
        this.yourSelectedValues = '';
        let self = this;
        this.template.querySelector ('c-multi-pick-list').getSelectedItems().forEach (function (eachItem) {
                self.yourSelectedValues.push(eachItem.value);
                console.log (eachItem.value);
                console.log('yourSelectedValues-->',self.yourSelectedValues);
                //self.yourSelectedValues += eachItem.value + ', ';
        });
    }

    handleOnItemSelected (event) {
        if (event.detail) {
            this.yourSelectedValues = '';
            let self = this;
            var selectedItems = [];
            var selectedItemIds = [];
            event.detail.forEach (function (eachItem) {
                console.log('eachitem-value',eachItem.value);
                console.log('eachitem-selected',eachItem.selected);
                    selectedItems.push(eachItem.label);
                    selectedItemIds.push(eachItem.value);
                    self.yourSelectedValues += eachItem.label + ' ';
            });
            
            var optionList = [];
            this.msOptions.forEach(function(optionItem){
                var newOption ={};
                if(selectedItemIds.includes(optionItem.value))
                {
                    newOption.selected = true;
                }
                else
                {
                    newOption.selected = false;
                }
                newOption.value = optionItem.value;
                newOption.label = optionItem.label;
                optionList.push(newOption);
            }); 
            console.log('optionList',optionList);
            this.msOptions = optionList;
            self.selectedOptionLst = selectedItems;
            console.log('selectedItems',this.msOptions);
            this.dispatchEvent(new CustomEvent('optionchange', { detail: {
                criteriaId: this.criteriaId,
                optionList : this.msOptions,
            }  }));
            console.log('multiselect event fired');
        }
    }
}