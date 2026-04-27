public with sharing class CreditCardService {
    
    /**
     * @name        : getCreditCards
     * @param       : null
     * @return      : List<Credit_Card__c>
     * @description : Method that fetches the list of Credit_Card__c records
     */
    public static List<Credit_Card__c> getCreditCards() {
        
        CreditCardSelector selector = new CreditCardSelector();
        return selector.getCreditCards();
        
    }
    
    /**
     * @name        : getCreditCardById
     * @param       : recordId => Id of the Credit_Card__c
     * @return      : Credit_Card__c
     * @description : Method that fetches the Credit_Card__c record for the specified record id
     */
    public static Credit_Card__c getCreditCardById(Id recordId) {
        
        CreditCardSelector selector = new CreditCardSelector();
        return selector.getCreditCardById(recordId);
        
    }
    
    /**
     * @name        : updateCreditCard
     * @param       : card => Credit_Card__c record details
     * @return      : String => returns Successful when update is successfule, otherwise Failed
     * @description : Method that updates the Credit_Card__c record provided
     */
    public static String updateCreditCard(Credit_Card__c card) {

        // Create a Unit Of Work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Credit_Card__c.SObjectType
            }
        );

        uow.registerDirty(card);
        String successFlag = 'Successful';
        try {
            // Commit the work
            uow.commitWork();
        }
        catch(Exception e) {
            successFlag = 'Failed';
        }
        return successFlag;

    }

}