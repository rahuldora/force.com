public with sharing class CreditCardsPageController {
    
    @AuraEnabled
    public static List<Credit_Card__c> fetchCreditCards(){
        return CreditCardService.getCreditCards();
    }

    @AuraEnabled
    public static Credit_Card__c fetchCreditCardById(Id recordId){
        return CreditCardService.getCreditCardById(recordId);
    }

    @AuraEnabled
    public static string updateCreditCard(Credit_Card__c card){
        return CreditCardService.updateCreditCard(card);
    }
    
}