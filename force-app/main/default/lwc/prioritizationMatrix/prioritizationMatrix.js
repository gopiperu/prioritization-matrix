import { LightningElement,api,wire,track } from 'lwc';
import { getRecord,getRecordNotifyChange  } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getCriteriaList from '@salesforce/apex/PrioritizationMatrixController.getCriteriaList';
import calculateScore from '@salesforce/apex/PrioritizationMatrixController.calculateScore';

export default class PrioritizationMatrix extends LightningElement {

    isHigh;
    isMedium;
    isLow;
    //@track criteriaList;
    @track matrix;
    loaded = false;
    @track matrixResult;
    //@track totalscore=0.00;
    //@track totalscore1;
    @api recordId;
    connectedCallback() {
        //this.recordId = 'a6r5w000000xHCeAAM';
        this.loaded = false;
        this.isHigh = false;
        this.isLow = false;
        this.isMedium = false;
     }

   

    @wire(getCriteriaList,{ recordId: '$recordId'}) wiredCriteriaList(result) {
        this.matrixResult = result;
        console.log('error-->',result.error);
        console.log('data-->',result.data);
        let dataStr = JSON.stringify(result.data);
        if(typeof dataStr != "undefined")
        {
            let dataObj = JSON.parse(dataStr);
            this.matrix = dataObj;
            console.log('this.matrix.totalscore',this.matrix.totalscore);
            if(this.matrix.totalscore > 20)
            {
                this.isHigh = true;
                this.isMedium = false;
                this.isLow = false;
            }
            else if(this.matrix.totalscore > 10 && this.matrix.totalscore < 19)
            {
                this.isHigh = false;
                this.isMedium = true;
                this.isLow = false;
            }
            else if(this.matrix.totalscore < 9)
            {
                this.isHigh = false;
                this.isMedium = false;
                this.isLow = true;
            }
            else
            {
                /*this.isHigh = false;
                this.isMedium = false;
                this.isLow = false;*/
            }
            //this.matrix.totalscore = this.matrix.totalscore;
        }
        this.loaded = true;
    };

    handleOptionChange(event)
    {
        let optionList = event.detail.optionList;
        var criList = this.matrix.criteriaList;
        const elementsIndex = criList.findIndex(element => element.Id == event.detail.criteriaId );
        var totalScore = 0;
            if(elementsIndex != -1 && typeof criList[elementsIndex] != "undefined")
        {
            criList[elementsIndex].options = optionList;
            criList[elementsIndex].uservalue = event.detail.userValue;
            this.matrix.criteriaList = criList;
            //this.totalscore = totalScore;
        }
    }

    handleCalculate()
    {
        this.loaded = false;
        calculateScore({matrix:JSON.stringify(this.matrix)})
                .then((result) => {
                    console.log('resut from apex calculate',result);
                    refreshApex(this.matrixResult);
                    this.loaded = true;
                })
                .catch((error) => {
                    console.log('error from controller',error);
                });
    }
}