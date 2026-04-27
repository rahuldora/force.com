public with sharing class BankAccountHandler extends fflib_SObjectDomain {
    
    public static Set<Bank_Account__c> bankAccountsToBeNotified;
    
    /**
     * @name        : BankAccountHandler (Constructor)
     * @param       : sObjectList => List of Bank_Account__c records
     * @return      : null
     * @description : constructor method
     */
    public BankAccountHandler(List<Bank_Account__c> sObjectList) {

        // Domain classes are initialised with lists to enforce bulkification throughout
		super(sObjectList);
        bankAccountsToBeNotified = new Set<Bank_Account__c>();

    }

    /**
     * @name        : Constructor
     * @param       : sObjectList => List of Bank_Account__c records
     * @return      : null
     * @description : Constructor class to invoke the constructor method when initialised dynamically
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {

		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new BankAccountHandler((List<Bank_Account__c>)sObjectList);
		}

	}

    /**
     * @name        : onAfterInsert
     * @param       : null
     * @return      : null
     * @description : Method for afterInsert Logic
     */
    public override void onAfterInsert() {
        
        // need to check whether the existing balance is less than minimum balance
        for(Bank_Account__c bankAccount : (List<Bank_Account__c>)getRecords()) {
            if(bankAccount.Balance__c <= bankAccount.Minimum_Balance__c) {
                // add the affected bank accounts to the list
                bankAccountsToBeNotified.add(bankAccount);        
            }
        }
        // create a custom notification (Custom notification named "Minimum Balance" has been created)
        createCustomNotifications();
        
    }
    
    /**
     * @name        : onAfterInsert
     * @param       : existing => Map<Id, Bank_Account__c>
     * @return      : null
     * @description : Method for afterUpdate Logic
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        
        // Map of Old Bank_Account__c records
        Map<Id, Bank_Account__c> oldBankAccountsMap = (Map<Id, Bank_Account__c>)existing;
        // need to check whether the existing balance is less than minimum balance
        for(Bank_Account__c bankAccount : (List<Bank_Account__c>)getRecords()) {
            if((bankAccount.Balance__c <= bankAccount.Minimum_Balance__c) && 
            (bankAccount.Balance__c != oldBankAccountsMap.get(bankAccount.Id).Balance__c)) {
                // add the affected bank accounts to the list
                bankAccountsToBeNotified.add(bankAccount);        
            }
        }
        // create a custom notification (Custom notification named "Minimum Balance" has been created)
        createCustomNotifications();
        
    }
    
    /**
     * @name        : onAfterUndelete
     * @param       : null
     * @return      : null
     * @description : Method for afterUndelete Logic
     */
    public override void onAfterUndelete() {
        
        // need to check whether the existing balance is less than minimum balance
        for(Bank_Account__c bankAccount : (List<Bank_Account__c>)getRecords()) {
            if(bankAccount.Balance__c <= bankAccount.Minimum_Balance__c) {
                // add the affected bank accounts to the list
                bankAccountsToBeNotified.add(bankAccount);        
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
            for(Bank_Account__c bankAccount : bankAccountsToBeNotified) {
                alertClass.sendNotification(
                    'Minimum Balance Alert!', 
                    'Your '+bankAccount.Bank_Account_Name__c+' account '+bankAccount.Name+' has dropped below the minimum balance required. To take action for the record, click on this notification!', 
                    bankAccount.Id
                );
            }
        }
        catch(Exception e) {
            System.debug('Error : '+e.getStackTraceString());
            System.debug('Error : '+e.getCause());
            return;
        }

    }

}