public class PurchaseOrderTriggerHandler {
    public static void handleShippingAddress(List<Purchase_Orders__c> newPurchaseOrders) {
        List<Purchase_Orders__c> inboundPurchaseOrders = new List<Purchase_Orders__c>();
        
        for(Purchase_Orders__c po: newPurchaseOrders) {
            if(po.Type__c == 'Inbound') {
                User u = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];
                po.Franchise__c = u.AccountId;
            }
        }
    }
    
    public static void handleEmptyInboundPurchaseOrderDeletion(List<Purchase_Orders__c> updatedPurchaseOrders) {
        Set<Id> poIds = new Set<Id>();
        for(Purchase_Orders__c po: updatedPurchaseOrders) {
            if(po.Type__c == 'Outbound') {
                poIds.add(po.Inbound_Purchase_Order__c);
            }
        }
        List<Purchase_Orders__c> inboundOrdersWithEmptyPOLines = [SELECT Id from Purchase_Orders__c
                                                                  where Id IN: poIds 
                                                                  and Type__c = 'Inbound' 
                                                                  and Id not in (select Purchase_Orders__c from Purchase_order_Lines__c)];
        
        try {
            delete inboundOrdersWithEmptyPOLines;
        } catch(DmlException ex){
            system.debug('Error occured while deleting empty inbound PO - ' + ex.getMessage());
        } 
    }
}