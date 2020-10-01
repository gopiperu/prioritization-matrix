public with sharing class ContactPrioritizationController {
    public ContactPrioritizationController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<CSA_Prioritization__c> getPrioritizationRecords(String recordId)
    {
        return [SELECT Id,Name FROM CSA_Prioritization__c WHERE Contact__c = :recordId];
    }
}