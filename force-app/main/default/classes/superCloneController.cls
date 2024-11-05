global class superCloneController {
    public Work_Order__c sourceWorkOrder { get; set; }
    public Work_Order__c targetWorkOrder { get; set; }
    public ID workOrderID {get;set;}
    /*public superCloneController(){
        workOrderID = ApexPages.currentPage().getParameters().get('id');
        workOrderID= String.valueOf(workOrderID).substring(0, 15);
        //cloneRecord(woId);
    }
    */
    public superCloneController(ApexPages.StandardController stdController){
        workOrderID = ((Work_Order__c)stdController.getRecord()).id;
        workOrderID= String.valueOf(workOrderID).substring(0, 15);
    }
    
    public PageReference cloneRecord(){
        system.debug('inside cloneRecord');
        try{
            workOrderID = String.valueOf(workOrderID).substring(0, 15);
            String queryStr = 'SELECT ';
            for(Schema.FieldSetMember f : getFields()) {
                queryStr += f.getFieldPath() + ', ';
            }
            if(!queryStr.contains('RecordTypeId'))
                queryStr+='RecordTypeId,';
            queryStr += 'Id, Name FROM Work_Order__c Where id =\''+workOrderID+'\' LIMIT 1';
            
            system.debug(workOrderID+' : queryStr : '+queryStr);
            sourceWorkOrder = Database.query(queryStr);
            if(sourceWorkOrder != null){
                Map<String, Schema.SObjectField> workOrderFieldsMap = Schema.SObjectType.Work_Order__c.fields.getMap();
                Id com = Schema.SObjectType.Work_Order__c.getRecordTypeInfosByName().get('Commercial').getRecordTypeId();
                Id res = Schema.SObjectType.Work_Order__c.getRecordTypeInfosByName().get('Residential').getRecordTypeId();
                Id comIC = Schema.SObjectType.Work_Order__c.getRecordTypeInfosByName().get('Commercial IC').getRecordTypeId();
                Id comICC = Schema.SObjectType.Work_Order__c.getRecordTypeInfosByName().get('Commercial ICC').getRecordTypeId();
                targetWorkOrder = new Work_Order__c();
                targetWorkOrder.recordTypeId = sourceWorkOrder.recordTypeId ;
                for(Schema.FieldSetMember f : getFields()) {
                    if(f.getFieldPath() == 'Van_assignment__c')
                        targetWorkOrder.Van_assignment__c = 'van 5';
                    else if(f.getFieldPath() == 'Status__c'){
                        if((sourceWorkOrder.recordTypeId == com  || sourceWorkOrder.recordTypeId == res)  && (sourceWorkOrder.Status__c =='Invoice Paid' ||sourceWorkOrder.Status__c =='Invoiced' || sourceWorkOrder.Status__c =='Completed' ) )
                            targetWorkOrder.Status__c = 'Pending';
                        else if((sourceWorkOrder.recordTypeId == comIC ) && (sourceWorkOrder.Status__c =='Invoice Paid' || sourceWorkOrder.Status__c =='Invoiced' || sourceWorkOrder.Status__c =='Completed' ))
                            targetWorkOrder.Status__c =  'Pending IC';
                        else if((sourceWorkOrder.recordTypeId == comICC )&& (sourceWorkOrder.Status__c =='Invoice Paid' || sourceWorkOrder.Status__c =='Invoiced' || sourceWorkOrder.Status__c =='Completed' ))
                            targetWorkOrder.Status__c =  'Pending ICC';
                    }else if(f.getFieldPath() != 'Id' && workOrderFieldsMap.get(f.getFieldPath()).getDescribe().isUpdateable())
                        targetWorkOrder.put(f.getFieldPath(), sourceWorkOrder.get(f.getFieldPath()));
                }
            }
            if(targetWorkOrder != null){
                insert targetWorkOrder;
                return  (new PageReference('/'+targetWorkOrder.id));
            }else
                return  (new PageReference('/'+sourceWorkOrder.id));
        }catch(Exception e){
            
        }
        return null;
    }
    
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Work_Order__c.FieldSets.Fields_To_Super_Clone.getFields();
    }
    
    
}