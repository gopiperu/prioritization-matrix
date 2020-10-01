trigger CriteriaEvaluationTrigger on CSA_Criteria_Evaluation__c (before insert, before update) {
    System.debug('--->');
    new CriteriaEvaluationTriggerHandler().run();
}