public with sharing class PrioritizationMatrixController {
    public PrioritizationMatrixController() {

    }

    @AuraEnabled(cacheable=true)
    public static PriorityMatrix getCriteriaList(String recordId)
    {
        List<CSA_Prioritization__c> prioritizationItem = [SELECT Id,Category__c,Total_score__c,
                                                        (SELECT Id,Name,Criteria__c,Selected_option__c,Score__c,User_Value__c 
                                                            FROM Criteria_Evaluations__r) 
                                                        FROM CSA_Prioritization__c 
                                                        WHERE Id = :recordId];  
        
        Map<Id,CSA_Criteria_Evaluation__c> criEvalMap = New Map<Id,CSA_Criteria_Evaluation__c>();
        if(!prioritizationItem.isEmpty())
        {
            for(CSA_Criteria_Evaluation__c criEvalItem : prioritizationItem.get(0).Criteria_Evaluations__r)
            {
                criEvalMap.put(criEvalItem.Selected_option__c,criEvalItem);
            }
        }
        
        

        Map<Id,CSA_Criteria__c> criteriaMap = new Map<Id,CSA_Criteria__c>(
                                        [SELECT Id,Name,Type__c,Weightage__c,Min_Value__c,Max_Value__c,(
                                            SELECT Id,Name,User_Value__c,Min_Value__c, Max_Value__c,Score__c,Style__c
                                            FROM Options__r 
                                            ORDER BY Createddate) 
                                    FROM CSA_Criteria__c
                                    WHERE Category__c = :prioritizationItem.get(0).Category__c
                                    ORDER BY Display_order__c]);
        
        List<Criteria> criteriaList = New List<Criteria>();         
        PriorityMatrix priMax = New PriorityMatrix();                           
        for(CSA_Criteria__c cri : criteriaMap.values())
        {
            Map<Id,CSA_Option__c> optionMap =  new Map<Id,CSA_Option__c>(cri.Options__r);
            List<Option> optionLst = New List<Option>();
            Criteria criteriaItem = New Criteria();
            for(CSA_Option__c optionItem : optionMap.values())
            {
                Option opty = New Option();
                opty.label = optionItem.Name;
                opty.value = optionItem.Id;
                opty.min = optionItem.Min_Value__c;
                opty.max = optionItem.Max_Value__c;
                opty.score = optionItem.Score__c;
                opty.classList = 'slds-path__item slds-is-incomplete';
                opty.style = optionItem.Style__c;
                // setting already selected option
                if(criEvalMap.containsKey(optionItem.Id) && criEvalMap.get(optionItem.Id).Criteria__c == cri.Id)
                {
                    criteriaItem.selectedOption = optionItem.Id;
                    criteriaItem.score = criEvalMap.get(optionItem.Id).Score__c;
                    if(criEvalMap.get(optionItem.Id).User_Value__c != NULL)
                    {
                        criteriaItem.uservalue = criEvalMap.get(optionItem.Id).User_Value__c;
                    }
                    else {
                        criteriaItem.uservalue = 0;                        
                    }
                    if(cri.Type__c == 'Picklist')
                    {
                        opty.classList = 'slds-path__item slds-is-complete '+optionItem.Style__c;
                    }
                    else 
                    {
                        opty.classList = optionItem.Style__c;    
                    }
                    opty.selected = true;
                }
                else {
                    criteriaItem.score = 0;
                }
                optionLst.add(opty);
            }
            criteriaItem.Id = cri.Id;
            criteriaItem.value = cri.Name;
            criteriaItem.type = cri.Type__c;
            criteriaItem.weightage = cri.Weightage__c;
            criteriaItem.min = cri.Min_Value__c;
            criteriaItem.max = cri.Max_Value__c;
            criteriaItem.options = optionLst;
            criteriaList.add(criteriaItem);
        }
        priMax.criteriaList = criteriaList;
        priMax.Id = recordId;
        if(!prioritizationItem.isEmpty() && prioritizationItem.get(0).Total_score__c != NULL)
        {
            priMax.totalscore = prioritizationItem.get(0).Total_score__c;
        }
        else {
            priMax.totalscore = 0;
        }
        //return criteriaList;
        return priMax;
    }

    @AuraEnabled
    public static String updateCriteriaEvaluation(String optionId,String criteriaId)
    {

        return optionId;
    }

    @AuraEnabled
    public static string calculateScore(String matrix){
        PriorityMatrix  matrixObj = (PriorityMatrix) JSON.deserialize(matrix,PriorityMatrix.class);
        List<CSA_Criteria_Evaluation__c> criteriaEvalLst = New List<CSA_Criteria_Evaluation__c>();
        System.debug('id-->'+matrixObj.Id);
        System.debug('query-->'+[SELECT Id, Criteria__c, Selected_Option__c FROM CSA_Criteria_Evaluation__c
        WHERE Prioritization__c = :matrixObj.Id
        LIMIT 100]);
        Map<String,String> existingCriEvalMap = new Map<String,String>();
        for(CSA_Criteria_Evaluation__c criEvalitem : [SELECT Id, Criteria__c, Selected_Option__c FROM CSA_Criteria_Evaluation__c
                                                    WHERE Prioritization__c = :matrixObj.Id
                                                    LIMIT 100])
            {
                System.debug('criEvalitem'+criEvalitem);
                if(String.isNotBlank(criEvalitem.Criteria__c) && String.isNotBlank(criEvalitem.Selected_Option__c))
                {
                    existingCriEvalMap.put(criEvalitem.Criteria__c+'-'+criEvalitem.Selected_Option__c,criEvalitem.Id);
                }
            }
        
        Set<String> newCriEvalSet = New Set<String>();
        for(Criteria criteriaItem : matrixObj.criteriaList)
        {
            for(Option optionItem : criteriaItem.options)
            {
                if(optionItem.selected && String.isNotBlank(criteriaItem.Id) && String.isNotBlank(optionItem.value))
                {
                    CSA_Criteria_Evaluation__c criItem = New CSA_Criteria_Evaluation__c();
                    criItem.Criteria__c = criteriaItem.Id;
                    criItem.Selected_Option__c  = optionItem.value;
                    criItem.User_Value__c  = criteriaItem.uservalue;
                    criItem.Prioritization__c  = matrixObj.Id;
                    newCriEvalSet.add(criteriaItem.Id+'-'+optionItem.value);
                    if(existingCriEvalMap.containsKey(criteriaItem.Id+'-'+optionItem.value))
                    {
                        criItem.Id = existingCriEvalMap.get(criteriaItem.Id+'-'+optionItem.value);
                    }
                    criteriaEvalLst.add(criItem);
                }
            }
        }

        List<CSA_Criteria_Evaluation__c> criEvaltoDelete = New List<CSA_Criteria_Evaluation__c>();
        System.debug('existingCriEvalMap-->'+existingCriEvalMap);
        System.debug('newCriEvalSet-->'+newCriEvalSet);
        for(String existCriKey : existingCriEvalMap.keySet())
        {
            if(newCriEvalSet.contains(existCriKey))
            {

            }
            else {
                System.debug('existingCriEvalMap.get(existCriKey)'+existingCriEvalMap.get(existCriKey));
                criEvaltoDelete.add(new CSA_Criteria_Evaluation__c(Id = existingCriEvalMap.get(existCriKey)));
            }
        }
        System.debug('criEvaltoDelete'+criEvaltoDelete);
        Delete criEvaltoDelete;
        Upsert(criteriaEvalLst);
        System.debug('m-->'+matrixObj);
        return 'method-call-sucess';
    }

    public class PriorityMatrix{
        @AuraEnabled
        public List<Criteria> criteriaList {get;set;}
        @AuraEnabled
        public Decimal totalscore{get; set;}
        @AuraEnabled
        public String Id{get; set;}
        
    }

    public class Criteria{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String value {get;set;}
        @AuraEnabled
        public List<Option> options {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String selectedOption{get;set;}
        @AuraEnabled
        public Decimal weightage{get; set;}
        @AuraEnabled
        public Decimal score{get; set;}
        @AuraEnabled
        public Decimal min{get; set;}
        @AuraEnabled
        public Decimal max{get; set;}
        @AuraEnabled
        public Decimal uservalue {get; set;}
    }

    public class Option{
        Option()
        {
            this.selected = false;
        }
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
        @AuraEnabled
        public String classList {get; set;}
        @AuraEnabled
        public Decimal min{get; set;}
        @AuraEnabled
        public Decimal max{get; set;}
        @AuraEnabled
        public Decimal score{get; set;}
        @AuraEnabled
        public Boolean selected{get; set;}
        @AuraEnabled
        public String style{get; set;}
    }
}