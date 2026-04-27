public without sharing class PaymentProcessorFactory {

    private static Map<String, PaymentProcessor> processorMap = new Map<String, PaymentProcessor> {
        'Online' => new OnlinePaymentProcessor(),
        'Credit Card' => new CreditCardPaymentProcessor(),
        'Cash' => new CashPaymentProcessor()
    };

    /**
     * @name        : getProcessor
     * @param       : String => Payment method value
     * @return      : PaymentProcessor => returns the PaymentProcessor class type based on the Payment method passed
     * @description : method to return the PaymentProcessor class type based on the Payment method passed
     */
    public static PaymentProcessor getProcessor(String paymentMethod) {
        return processorMap.get(paymentMethod);
    }
    
}