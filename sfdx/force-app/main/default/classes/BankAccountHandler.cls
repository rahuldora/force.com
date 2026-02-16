public without sharing class BankAccountHandler extends TriggerHandler {

    // trigger variables
    private List<Bank_Account__c> newBankAccounts;
    private List<Bank_Account__c> oldBankAccounts;
    private Map<Id, Bank_Account__c> newBankAccountsMap;
    private Map<Id, Bank_Account__c> oldBankAccountsMap;

    public static Set<Bank_Account__c> bankAccountsToBeNotified;

    public BankAccountHandler() {

        this.setMaxLoopCount(1);
        this.newBankAccounts = (List<Bank_Account__c>)Trigger.new;
        this.oldBankAccounts = (List<Bank_Account__c>)Trigger.old;
        this.newBankAccountsMap = (Map<Id, Bank_Account__c>)Trigger.newMap;
        this.oldBankAccountsMap = (Map<Id, Bank_Account__c>)Trigger.oldMap;
        bankAccountsToBeNotified = new Set<Bank_Account__c>();

    }

    // afterInsert Logic
    public override void afterInsert() {
        
        // need to check whether the existing balance is less than minimum balance
        for(Bank_Account__c bankAccount : this.newBankAccounts) {
            if(bankAccount.Balance__c <= bankAccount.Minimum_Balance__c) {
                // add the affected bank accounts to the list
                bankAccountsToBeNotified.add(bankAccount);        
            }
        }
        // create a custom notification (Custom notification named "Minimum Balance" has been created)
        createCustomNotifications();
        
    }
    
    // afterUpdate Logic
    public override void afterUpdate() {
        
        // need to check whether the existing balance is less than minimum balance
        for(Bank_Account__c bankAccount : this.newBankAccounts) {
            if((bankAccount.Balance__c <= bankAccount.Minimum_Balance__c) && 
            (bankAccount.Balance__c != oldBankAccountsMap.get(bankAccount.Id).Balance__c)) {
                // add the affected bank accounts to the list
                bankAccountsToBeNotified.add(bankAccount);        
            }
        }
        // create a custom notification (Custom notification named "Minimum Balance" has been created)
        createCustomNotifications();
        
    }
    
    // afterUndelete Logic
    public override void afterUndelete() {
        
        // need to check whether the existing balance is less than minimum balance
        for(Bank_Account__c bankAccount : this.oldBankAccounts) {
            if(bankAccount.Balance__c <= bankAccount.Minimum_Balance__c) {
                // add the affected bank accounts to the list
                bankAccountsToBeNotified.add(bankAccount);        
            }
        }
        // create a custom notification (Custom notification named "Minimum Balance" has been created)
        createCustomNotifications();
        
    }
    
    // method for creating the notifications
    public static void createCustomNotifications() {
        
        // Setting up the custom notification
        CustomNotificationType typeObj = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Minimum_Balance' LIMIT 1];
        List<User> users = [SELECT Id FROM User WHERE Alias IN ('rdora', 'ssark', 'UUser')];
        Set<String> userIds = new Set<String>();
        for(User u : users){
            userIds.add((String)u.Id);
        }
        
        for(Bank_Account__c bankAccount : bankAccountsToBeNotified) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setNotificationTypeId(typeObj.Id);
            notification.setTitle('Minimum Balance Alert!');
            notification.setBody('Your '+bankAccount.Bank_Account_Name__c+' account '+bankAccount.Name+' has dropped below the minimum balance required. To take action for the record, click on this notification!');
            notification.setTargetId(bankAccount.Id);
            try {
                notification.send(userIds);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        }

    }

}