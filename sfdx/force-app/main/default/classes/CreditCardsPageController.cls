public with sharing class CreditCardsPageController {
    
    /**
     * @name        : fetchCreditCards
     * @param       : null
     * @return      : List<Credit_Card__c>
     * @description : Method that fetches the list of Credit_Card__c records
     */
    @AuraEnabled
    public static List<Credit_Card__c> fetchCreditCards(){
        return CreditCardService.getCreditCards();
    }

    /**
     * @name        : fetchCreditCardById
     * @param       : recordId => Id of the Credit_Card__c
     * @return      : Credit_Card__c
     * @description : Method that fetches the Credit_Card__c record for the specified record id
     */
    @AuraEnabled
    public static Credit_Card__c fetchCreditCardById(Id recordId){
        return CreditCardService.getCreditCardById(recordId);
    }

    /**
     * @name        : updateCreditCard
     * @param       : card => Credit_Card__c record details
     * @return      : String => returns Successful when update is successfule, otherwise Failed
     * @description : Method that updates the Credit_Card__c record provided
     */
    @AuraEnabled
    public static string updateCreditCard(Credit_Card__c card){
        return CreditCardService.updateCreditCard(card);
    }
    
}