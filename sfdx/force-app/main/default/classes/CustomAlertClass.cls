public without sharing class CustomAlertClass {
    
    private Set<String> users;

    /**
     * @name        : CustomAlertClass (Constructor)
     * @param       : null
     * @return      : null
     * @description : Constructor method
     */
    public CustomAlertClass() {

        this.users = new Set<String>();
        for(User usr : getUserList()){
            this.users.add((String)usr.Id);
        }
        
    }

    /**
     * @name        : sendNotification
     * @param       : title => Title to be displayed in the notification
     *              : message => Message to be displayed in the notification
     *              : targetRecord => Target record's id
     * @return      : null
     * @description : Method to send the custom notification
     */
    public void sendNotification(String title, String message, Id targetRecord) {
        
        try{
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setNotificationTypeId(getCustomNotificationTypeId());
            notification.setTitle(title);
            notification.setBody(message);
            notification.setTargetId(targetRecord);
            try {
                notification.send(this.users);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
                return;
            }
        }
        catch(Exception e) {
            System.debug('Error : '+e.getStackTraceString());
            return;
        }
        
    }
    
    /**
     * @name        : getCustomNotificationTypeId
     * @param       : null
     * @return      : Id => Id of the Custom Notification type Id
     * @description : Method to fetch the Id of the custom notification type
     */
    public Id getCustomNotificationTypeId() {

        fflib_QueryFactory qf = new fflib_QueryFactory(CustomNotificationType.SObjectType);
        qf.selectField(CustomNotificationType.Id)
        .setCondition('DeveloperName = \'Custom_Alert\'')
        .setLimit(1);
        List<CustomNotificationType> results = Database.query(qf.toSOQL());
        return results[0].Id;

    }

    /**
     * @name        : getUserList
     * @param       : null
     * @return      : List<User> => List of users 
     * @description : Method to fetch the list of users that are to be notified
     */
    public List<User> getUserList() {

        fflib_QueryFactory qf = new fflib_QueryFactory(User.SObjectType);
        qf.selectField(User.Id)
        .setCondition('Alias IN (\'dor\')');
        return Database.query(qf.toSOQL());

    }
    
}