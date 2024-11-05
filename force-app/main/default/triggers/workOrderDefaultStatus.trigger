trigger workOrderDefaultStatus on Work_Order__c (before insert,before update, after insert, after update) {
    
    List<Work_Order__c> NewWorkOrderList = new List<Work_Order__c>();
    List<Work_Order__c> OldWorkOrderList = new List<Work_Order__c>();
    set<id> WorkOrderInsertedIdSet = new set<id> ();
    set<id> WorkOrderUpdatedIdSet = new set<id> ();
    
    if(trigger.IsBefore){
        for(Work_Order__c woRec : Trigger.new){
            
            String InvNotes = '';
            if(woRec.Invoice_Notes__c !='' && woRec.Invoice_Notes__c != null){
                InvNotes = InvNotes+woRec.Invoice_Notes__c+'\n\n';
            }
            //remove unselected notes option text
            if(InvNotes.contains(System.Label.Carpet_Roll)){
                InvNotes = InvNotes.remove(System.Label.Carpet_Roll+'\n\n');
            }
            if(InvNotes.contains(System.Label.Banding)){
                InvNotes = InvNotes.remove(System.Label.Banding+'\n\n');
            }
            if(InvNotes.contains(System.Label.Wear_That_Looks_Like_Soil)){
                InvNotes = InvNotes.remove(System.Label.Wear_That_Looks_Like_Soil+'\n\n');
            }
            if(InvNotes.contains(System.Label.Bleaching)){
                InvNotes = InvNotes.remove(System.Label.Bleaching+'\n\n');
            }
            if(InvNotes.contains(System.Label.Pivot_Wear)){
                InvNotes = InvNotes.remove(system.Label.Pivot_Wear+'\n\n');
            }
            if(InvNotes.contains(System.Label.Residual_Urine_Smell)){
                InvNotes = InvNotes.remove(System.Label.Residual_Urine_Smell+'\n\n');
            }
            if(InvNotes.contains(System.Label.Stain_Magic)){
                InvNotes = InvNotes.remove(System.Label.Stain_Magic+'\n\n');
            }
            if(InvNotes.contains(System.Label.High_Levels_Of_Pet_Hair)){
                InvNotes = InvNotes.remove(System.Label.High_Levels_Of_Pet_Hair+'\n\n');
            }
            if(InvNotes.contains(System.Label.Carpet_Illusions_After_Cleaning)){
                InvNotes = InvNotes.remove(System.Label.Carpet_Illusions_After_Cleaning+'\n\n');
            }
            //newly added on 3/7/2024
            if(InvNotes.contains(System.Label.Furniture_Divots)){
                InvNotes = InvNotes.remove(System.Label.Furniture_Divots+'\n\n');
            }
            
            //add selected option text
            if(woRec.Invoice_Notes_Options__c != null){
                if(woRec.Invoice_Notes_Options__c.contains('Carpet Roll')){
                    InvNotes = InvNotes+System.Label.Carpet_Roll+'\n\n';
                }
                
                if(woRec.Invoice_Notes_Options__c.contains('Banding')){
                    InvNotes = InvNotes+System.Label.Banding+'\n\n';
                }
                if(woRec.Invoice_Notes_Options__c.contains('Wear That Looks Like Soil')){
                    InvNotes = InvNotes+System.Label.Wear_That_Looks_Like_Soil+'\n\n';
                }
                if(woRec.Invoice_Notes_Options__c.contains('Bleaching')){
                    InvNotes = InvNotes+System.Label.Bleaching+'\n\n';
                }
                if(woRec.Invoice_Notes_Options__c.contains('Pivot Wear')){
                    InvNotes = InvNotes+System.Label.Pivot_Wear+'\n\n';
                }
                if(woRec.Invoice_Notes_Options__c.contains('Residual Urine Smell')){
                    InvNotes = InvNotes+System.Label.Residual_Urine_Smell+'\n\n';
                }
                if(woRec.Invoice_Notes_Options__c.contains('Stain Magic')){
                    InvNotes = InvNotes+System.Label.Stain_Magic+'\n\n';
                }
                if(woRec.Invoice_Notes_Options__c.contains('High Levels Of Pet Hair')){
                    InvNotes = InvNotes+System.Label.High_Levels_Of_Pet_Hair+'\n\n';
                }
                if(woRec.Invoice_Notes_Options__c.contains('Carpet Illusions After Cleaning')){
                    InvNotes = InvNotes+System.Label.Carpet_Illusions_After_Cleaning+'\n\n';
                }
                //newly added on 3/7/2024
                if(woRec.Invoice_Notes_Options__c.contains('Furniture Divots')){
                    InvNotes = InvNotes+System.Label.Furniture_Divots+'\n\n';
                }
            }
          woRec.Invoice_Notes__c = InvNotes;
        }
    }else{
        if(trigger.isInsert){
            for(Work_Order__c wo : Trigger.new){
                WorkOrderInsertedIdSet.add(wo.id);
            }
            NewWorkOrderList = [select id, name, Owner.Profile.Name,Property_Zip_Code__c from Work_Order__c where id =:WorkOrderInsertedIdSet];
            for(Work_Order__c wo:NewWorkOrderList){
                if( wo.Property_Zip_Code__c !=null && (UserInfo.getUserType() != 'Standard' && 
                   UserInfo.getUserType() != 'Chatter Free' && UserInfo.getUserType() != 'Guest')){
                   //&& wo.Owner.Profile.Name == 'Customer Community User - Custom'){
                    system.debug('Customer Community User');
                    ShareWorkOrder.manualshare(wo);
                }
            }
        }
        if(trigger.isUpdate){
            for(Work_Order__c wo : Trigger.new){
                system.debug('old-'+Trigger.oldMap.get(wo.ID).Property_Zip_Code__c+' new-'+wo.Property_Zip_Code__c);
                if(Trigger.oldMap.get(wo.ID).Property_Zip_Code__c != wo.Property_Zip_Code__c){
                    system.debug('changed');
                    WorkOrderUpdatedIdSet.add(wo.id);
                }
            }
            OldWorkOrderList = [select id, name, Owner.Profile.Name,Property_Zip_Code__c,Assigned_Business__c from Work_Order__c where id =:WorkOrderUpdatedIdSet];
            for(Work_Order__c wo:OldWorkOrderList){
                if(wo.Property_Zip_Code__c !=null && (UserInfo.getUserType() != 'Standard' && 
                   UserInfo.getUserType() != 'Chatter Free' && UserInfo.getUserType() != 'Guest')){
                //   && wo.Owner.Profile.Name == 'Customer Community User - Custom'){
                    system.debug('Customer Community User');
                    ShareWorkOrder.manualshare(wo);
                }
            }
        }
        
    }
    
}