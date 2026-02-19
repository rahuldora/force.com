public without sharing class CustomAlertClass {
    
    private Id typeObj;
    private Set<String> users;

    public CustomAlertClass() {

        this.typeObj = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Custom_Alert' LIMIT 1].Id;
        List<User> userList = [SELECT Id FROM User WHERE Alias IN ('rdora', 'ssark', 'UUser')];
        this.users = new Set<String>();
        for(User usr : userList){
            this.users.add((String)usr.Id);
        }
        
    }

    public void sendNotification(String title, String message, Id targetRecord) {

        try{
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setNotificationTypeId(this.typeObj);
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
    
}