import { LightningElement, api, track } from 'lwc';

export default class CriteriaRangeSelect extends LightningElement {
    @api criteriaItem;
    @track uservalue;
    @track optionlst;
    connectedCallback(){
        this.uservalue = this.criteriaItem.uservalue;
        this.optionlst = this.criteriaItem.options;
   }    

   handleSliderChange(event)
   {
       console.log('slider value-->',event.target.value);
       this.uservalue = event.target.value;
       if(typeof this.uservalue != "undefined" && this.uservalue != null)
       {
        let optionList = [];
            console.log('slider value-->',event.target.value);
            this.criteriaItem.options.forEach(element => {
                var newOption ={};
                newOption.selected = false;
                newOption.value = element.value;
                newOption.min = element.min;
                newOption.max = element.max;
                newOption.classList = element.classList;
                newOption.label = element.label;
                newOption.style = element.style;
                if(element.min <= this.uservalue && element.max >= this.uservalue)
                {
                    newOption.selected = true;
                }
                
                optionList.push(newOption);
            });

            this.dispatchEvent(new CustomEvent('optionchange', { detail: {
                criteriaId: this.criteriaItem.Id,
                optionList : optionList,
                userValue : this.uservalue,
            }  }));


            /*var elementsIndex = this.criteriaItem.options.findIndex(element => element.min <= this.uservalue && element.max >= this.uservalue);
            console.log('elementsIndex-->',elementsIndex);
            if(typeof elementsIndex != "undefined" && elementsIndex != -1)
            {
            console.log('-->',this.criteriaItem.options[elementsIndex].value);
            console.log('option item',elementsIndex);
            console.log('this.criteriaItem.value',this.criteriaItem.Id);
            console.log('this.criteriaItem.options[elementsIndex].score',this.criteriaItem.options[elementsIndex].score);
            
            console.log('optionList',optionList);

            this.dispatchEvent(new CustomEvent('optionchange', { detail: {
                criteriaId: this.criteriaItem.Id,
                selectedOption : optionList
            }  }));
            }*/
       }
             
   }
}