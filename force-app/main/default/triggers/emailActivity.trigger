trigger emailActivity on EmailMessage (after insert) {
    List<EmailMessage> duplicateTaskForParentList = new List<EmailMessage>();
    Set<Id> accIds= new Set<Id>();
    for(EmailMessage t : trigger.new){
        if(t.RelatedToId !=null){
            String wId = t.RelatedToId; 
            if(wId.startsWith('001') && !accIds.contains(t.RelatedToId)){
                system.debug('Inside 001 and accIds='+accIds);
                accIds.add(t.RelatedToId); 
            }
        }
    }
    Map<ID,Account> parentAccMap = new Map<ID,Account>([Select Id,ParentId, Name FROM Account WHERE ID IN :accIds AND ParentID!=null]);
    
    Set<Id> InsertedTaskIdsSet = new Set<Id>();
    
    for(EmailMessage t : Trigger.new){
        String taskSubject = t.subject;        
        if(t.RelatedToId!=null && parentAccMap!=null && parentAccMap.size()>0 
           && parentAccMap.containsKey(t.RelatedToId) && t.Parent_Activity__c == false){
               InsertedTaskIdsSet.add(t.Id);
           }
    }
    if(InsertedTaskIdsSet.size()>0){
        List<EmailMessage> InsertedTaskList = [SELECT Subject,RelatedToId,FromAddress, FromName, ToAddress, BccAddress, 
                                               CcAddress, HasAttachment, HtmlBody, MessageDate, Status, TextBody, 
                                               ValidatedFromAddress FROM EmailMessage where ID IN:InsertedTaskIdsSet];
        for(EmailMessage t : InsertedTaskList ){
            EmailMessage ParentTskObj = new EmailMessage();
            ParentTskObj = t;
            ParentTskObj.id = null;
            ParentTskObj.RelatedToId = parentAccMap.get(t.RelatedToId).ParentId;
            ParentTskObj.Subject = t.Subject;
            ParentTskObj.FromAddress = t.FromAddress;
            ParentTskObj.FromName = t.FromName;
            ParentTskObj.ToAddress = t.ToAddress;
            ParentTskObj.BccAddress = t.BccAddress;
            ParentTskObj.CcAddress = t.CcAddress;
            ParentTskObj.HtmlBody = t.HtmlBody;
            ParentTskObj.MessageDate = t.MessageDate;
            ParentTskObj.Status = t.Status;
            ParentTskObj.TextBody = t.TextBody;
            ParentTskObj.ValidatedFromAddress = t.ValidatedFromAddress;
            
            ParentTskObj.Parent_Activity__c = true;
            duplicateTaskForParentList.add(ParentTskObj);
        }
    }
    if(duplicateTaskForParentList.size()>0){
        insert duplicateTaskForParentList;
    }

}