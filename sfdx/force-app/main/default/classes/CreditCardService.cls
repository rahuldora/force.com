public with sharing class CreditCardService {
    
    public static List<Credit_Card__c> getCreditCards() {

        CreditCardSelector selector = new CreditCardSelector();
        return selector.getCreditCards();

    }

    public static Credit_Card__c getCreditCardById(Id recordId) {

        CreditCardSelector selector = new CreditCardSelector();
        return selector.getCreditCardById(recordId);

    }

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