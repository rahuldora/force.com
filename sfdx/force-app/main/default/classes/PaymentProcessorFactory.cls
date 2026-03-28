public without sharing class PaymentProcessorFactory {

    private static Map<String, PaymentProcessor> processorMap = new Map<String, PaymentProcessor> {
        'Online' => new OnlinePaymentProcessor(),
        'Credit Card' => new CreditCardPaymentProcessor(),
        'Cash' => new CashPaymentProcessor()
    };

    public static PaymentProcessor getProcessor(String paymentMethod) {
        return processorMap.get(paymentMethod);
    }
    
}