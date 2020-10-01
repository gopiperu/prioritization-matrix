public with sharing class CriteriaEvaluationTriggerHandler extends TriggerHandler{

    private List<CSA_Criteria_Evaluation__c> newList;

    public CriteriaEvaluationTriggerHandler() {
        this.newList = (List<CSA_Criteria_Evaluation__c>) Trigger.new;
    }

    public override void beforeUpdate() {
        System.debug('--->'+this.newList);
        calculateScore(this.newList);
      }
    
    public override void beforeInsert() {
        calculateScore(this.newList);
    }
    
    public void calculateScore(List<CSA_Criteria_Evaluation__c> newList)
    {
        
        Set<Id> criteriaIdSet = New Set<Id>();
        Set<Id> optionIdSet = New Set<Id>();

        for(CSA_Criteria_Evaluation__c criEvalItem : newList)
        {
            if(String.isNotBlank(criEvalItem.Criteria__c))
            {
                criteriaIdSet.add(criEvalItem.Criteria__c);
            }

            if(String.isNotBlank(criEvalItem.Selected_option__c))
            {
                optionIdSet.add(criEvalItem.Selected_option__c);
            }
        }

        Map<Id,Decimal> criteriaWeightageMap = New Map<Id,Decimal>();
        for(CSA_Criteria__c criteriaItem : [SELECT Id,Weightage__c
                                        FROM CSA_Criteria__c 
                                        WHERE Id IN :criteriaIdSet])
        {
            criteriaWeightageMap.put(criteriaItem.Id,criteriaItem.Weightage__c);
        }

        Map<Id,Decimal> optionScoreMap = New Map<Id,Decimal>();
        for(CSA_Option__c optionItem : [SELECT Id,Score__c
                                        FROM CSA_Option__c 
                                        WHERE Id IN :optionIdSet])
        {
            optionScoreMap.put(optionItem.Id,optionItem.Score__c);
        }
        
        for(CSA_Criteria_Evaluation__c criEvalItem : newList)
        {
            if(String.isNotBlank(criEvalItem.Criteria__c) && String.isNotBlank(criEvalItem.Selected_option__c)
            && criteriaWeightageMap.containsKey(criEvalItem.Criteria__c) 
            && optionScoreMap.containsKey(criEvalItem.Selected_option__c))
            {
                    Decimal optionScore = optionScoreMap.get(criEvalItem.Selected_option__c);
                    Decimal criWeightage = criteriaWeightageMap.get(criEvalItem.Criteria__c);
                    if(optionScore != NULL && criWeightage != NULL)
                    {
                        criEvalItem.Score__c = optionScore * criWeightage;
                    }
                    else{
                        criEvalItem.Score__c = 0;
                    }
            }
            else {
                criEvalItem.Score__c = 0;
            }
        }
        
    }
}