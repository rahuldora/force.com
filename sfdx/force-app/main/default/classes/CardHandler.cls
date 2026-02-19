public with sharing class CardHandler extends TriggerHandler {
    
    // trigger variables
    private List<Credit_Card__c> newCardRecords;
    private List<Credit_Card__c> oldCardRecords;
    private Map<Id, Credit_Card__c> newCardMap;
    private Map<Id, Credit_Card__c> oldCardMap;

    public static Set<Credit_Card__c> cardsToBeNotified;
    
    public CardHandler() {
        
        newCardRecords = (List<Credit_Card__c>)Trigger.new;
        oldCardRecords = (List<Credit_Card__c>)Trigger.old;
        newCardMap = (Map<Id, Credit_Card__c>)Trigger.newMap;
        oldCardMap = (Map<Id, Credit_Card__c>)Trigger.oldMap;
        cardsToBeNotified = new Set<Credit_Card__c>();

    }

    // afterInsert Logic
    public override void afterInsert() {
        
        // need to check whether the existing balance is less than minimum balance
        for(Credit_Card__c card : this.newCardRecords) {
            if((card.Amount_Utilised__c / card.Total_Limit__c) >= 0.3) {
                // add the affected bank accounts to the list
                cardsToBeNotified.add(card);        
            }
        }
        // create a custom notification (Custom notification named "Minimum Balance" has been created)
        createCustomNotifications();
        
    }
    
    // afterUpdate Logic
    public override void afterUpdate() {
        
        // need to check whether the existing balance is less than minimum balance
        for(Credit_Card__c card : this.newCardRecords) {
            if((card.Amount_Utilised__c != this.oldCardMap.get(card.Id).Amount_Utilised__c) &&
                (card.Amount_Utilised__c / card.Total_Limit__c) >= 0.3) {
                // add the affected bank accounts to the list
                cardsToBeNotified.add(card);        
            }
        }
        // create a custom notification (Custom notification named "Minimum Balance" has been created)
        createCustomNotifications();
        
    }
    
    // afterUndelete Logic
    public override void afterUndelete() {
        
        // need to check whether the existing balance is less than minimum balance
        for(Credit_Card__c card : this.newCardRecords) {
            if((card.Amount_Utilised__c / card.Total_Limit__c) >= 0.3) {
                // add the affected bank accounts to the list
                cardsToBeNotified.add(card);        
            }
        }
        // create a custom notification (Custom notification named "Minimum Balance" has been created)
        createCustomNotifications();
        
    }
    
    // method for creating the notifications
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