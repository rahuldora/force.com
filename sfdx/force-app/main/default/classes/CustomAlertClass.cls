public without sharing class CustomAlertClass {
    
    private Set<String> users;

    public CustomAlertClass() {

        this.users = new Set<String>();
        for(User usr : getUserList()){
            this.users.add((String)usr.Id);
        }
        
    }

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

    public Id getCustomNotificationTypeId() {

        fflib_QueryFactory qf = new fflib_QueryFactory(CustomNotificationType.SObjectType);
        qf.selectField(CustomNotificationType.Id)
        .setCondition('DeveloperName = \'Custom_Alert\'')
        .setLimit(1);
        List<CustomNotificationType> results = Database.query(qf.toSOQL());
        return results[0].Id;

    }

    public List<User> getUserList() {

        fflib_QueryFactory qf = new fflib_QueryFactory(User.SObjectType);
        qf.selectField(User.Id)
        .setCondition('Alias IN (\'dor\')');
        return Database.query(qf.toSOQL());

    }
    
}