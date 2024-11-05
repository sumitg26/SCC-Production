trigger PurchaseOrderTrigger on Purchase_Orders__c (before insert, after update) {
    if(trigger.isBefore && trigger.isInsert) {
        PurchaseOrderTriggerHandler.handleShippingAddress(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate) {
        PurchaseOrderTriggerHandler.handleEmptyInboundPurchaseOrderDeletion(trigger.new);
    }
}