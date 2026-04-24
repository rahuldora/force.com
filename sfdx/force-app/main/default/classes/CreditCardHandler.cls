public with sharing class CreditCardHandler extends fflib_SObjectDomain {
    
    public static Set<Credit_Card__c> cardsToBeNotified;
    
    /**
     * @name        : CreditCardHandler (Constructor)
     * @param       : sObjectList => List of Credit_Card__c records
     * @return      : null
     * @description : constructor method
     */
    public CreditCardHandler(List<Credit_Card__c> sObjectList) {

        // Domain classes are initialised with lists to enforce bulkification throughout
		super(sObjectList);
        cardsToBeNotified = new Set<Credit_Card__c>();

    }

    /**
     * @name        : Constructor
     * @param       : sObjectList => List of Credit_Card__c records
     * @return      : null
     * @description : Constructor class to invoke the constructor method when initialised dynamically
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {

		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new CreditCardHandler((List<Credit_Card__c>)sObjectList);
		}

	}

    /**
     * @name        : onAfterInsert
     * @param       : null
     * @return      : null
     * @description : method is invoked to perform afterInsert Logic
     */
    public override void onAfterInsert() {
        
        // need to check whether the existing balance is less than minimum balance
        for(Credit_Card__c card : (List<Credit_Card__c>)getRecords()) {
            if((card.Amount_Utilised__c / card.Total_Limit__c) >= 0.3) {
                // add the affected bank accounts to the list
                cardsToBeNotified.add(card);        
            }
        }
        // create a custom notification (Custom notification named "Minimum Balance" has been created)
        createCustomNotifications();
        
    }
    
    /**
     * @name        : onAfterUpdate
     * @param       : existing => Map<Id, SObject> containing the map of old Credit_Card__c records
     * @return      : null
     * @description : method is invoked to perform afterUpdate Logic
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        
        // Map of Old Credit_Card__c records
        Map<Id, Credit_Card__c> oldCardMap = (Map<Id, Credit_Card__c>)existing;
        // need to check whether the existing balance is less than minimum balance
        for(Credit_Card__c card : (List<Credit_Card__c>)getRecords()) {
            if((card.Amount_Utilised__c != oldCardMap.get(card.Id).Amount_Utilised__c) &&
                (card.Amount_Utilised__c / card.Total_Limit__c) >= 0.3) {
                // add the affected bank accounts to the list
                cardsToBeNotified.add(card);        
            }
        }
        // create a custom notification (Custom notification named "Minimum Balance" has been created)
        createCustomNotifications();
        
    }
    
    /**
     * @name        : onAfterUndelete
     * @param       : null
     * @return      : null
     * @description : method is invoked to perform afterUndelete Logic
     */
    public override void onAfterUndelete() {
        
        // need to check whether the existing balance is less than minimum balance
        for(Credit_Card__c card : (List<Credit_Card__c>)getRecords()) {
            if((card.Amount_Utilised__c / card.Total_Limit__c) >= 0.3) {
                // add the affected bank accounts to the list
                cardsToBeNotified.add(card);        
            }
        }
        // create a custom notification (Custom notification named "Minimum Balance" has been created)
        createCustomNotifications();
        
    }
    
    /**
     * @name        : createCustomNotifications
     * @param       : null
     * @return      : null
     * @description : method for creating and dispatching the notifications
     */
    public static void createCustomNotifications() {
        
        // Setting up the custom notification
        try {
            CustomAlertClass alertClass = new CustomAlertClass();
            for(Credit_Card__c card : cardsToBeNotified) {
                double percent = ((Double)card.Amount_Utilised__c / (Double)card.Total_Limit__c) * 100;
                alertClass.sendNotification('Credit Card Usage Alert!', 
                    'Your '+card.Credit_Card_Name__c+' utilization has crossed 30%.\n Current utilization is at '+percent+'%.\n Try to reduce usage or make a payment to keep your credit score healthy.', 
                    card.Id);
            }
        }
        catch(Exception e) {
            System.debug('Custom notification type is not created!');
            return;
        }
    
    }
    
}