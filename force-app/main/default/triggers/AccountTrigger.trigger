trigger AccountTrigger on Account (after insert, after update) {

    if(Trigger.isInsert){
        AccountTriggerHelper.SyncAccountContacts(Trigger.New);
    }
    if(Trigger.isUpdate){
       AccountTriggerHelper.SyncAccountContacts(Trigger.New); 
    }
    
}