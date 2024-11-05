public class ShareWorkOrder {
        
    public static void manualshare(Work_Order__c workOrder){
        system.debug('order-'+workOrder);
        Territory_Coverage__C Coverage;
        Account businessAccount = new Account ();
        User AssignedUser = new User();
        id BusinesscontactId;
        List<Work_Order__share> totalSharings = new list<Work_Order__share> ();
        
        if(workOrder != null && workOrder.Property_Zip_Code__c != null){
            try{
                Coverage = [select id, (select id,Account__c, Account__r.Primary_Business_Contact__c from Account_Territories__r LIMIT 1) from Territory_Coverage__C where Zip_Code__C =:workOrder.Property_Zip_Code__c LIMIT 1];
                
            }catch(exception e){
                system.debug('error-'+e.getMessage());
            }
            system.debug('coverage--'+Coverage);
            if(Coverage != null){
                if(Coverage.Account_Territories__r != null && Coverage.Account_Territories__r.size()>0){
                    if(Coverage.Account_Territories__r[0].Account__c != null){
                        workOrder.Assigned_Business__c = Coverage.Account_Territories__r[0].Account__c;
                        if(Coverage.Account_Territories__r[0].Account__r.Primary_Business_Contact__c != null){
                            businessAccount = Coverage.Account_Territories__r[0].Account__r;
                            BusinesscontactId =Coverage.Account_Territories__r[0].Account__r.Primary_Business_Contact__c;
                        }  
                    }
                    else{
                         workOrder.Assigned_Business__c = null;
                    }
                }
            }
            else{
                workOrder.Assigned_Business__c = null;
            }
        }
        system.debug('BusinesscontactId'+BusinesscontactId);
        if(BusinesscontactId != null){
            try{
                AssignedUser = [select id, username from user where ContactId =:BusinesscontactId LIMIT 1];
            }catch(exception e){
                system.debug('error-'+e.getMessage());
            }
            
        }
        
        if(AssignedUser != null && AssignedUser.id !=null){
            system.debug('AssignedUser.id--'+AssignedUser.id);
            workOrder.Assigned_Business_User__c = AssignedUser.id;
            businessAccount.Assigned_Business_User__c = AssignedUser.id;
        }
        
        try{
            update workOrder;
            if(businessAccount.Assigned_Business_User__c != null){
            	update businessAccount;
            }
            system.debug('Successful--');
        }
        catch(dmlException e){
                system.debug('error-'+e.getMessage());
            }
        
        /*if(AssignedUser != null){
            Work_Order__share woshare;
                woshare = new Work_Order__share();
                woshare.ParentId = workOrder.id;
                woshare.UserOrGroupId = AssignedUser.id;
                woshare.AccessLevel = 'Read';
                system.debug('user--'+ AssignedUser.username+'ParentId--'+woshare.ParentId);
                totalSharings.add(woshare);
                if(Coverage.Account_Territories__r[0].Account__c != null){
                    woshare = new Work_Order__share();
                    woshare.ParentId = Coverage.Account_Territories__r[0].Account__c;
                    woshare.UserOrGroupId = AssignedUser.id;
                    woshare.AccessLevel = 'Read';
                    system.debug('user--'+ AssignedUser.username+'ParentId--'+woshare.ParentId); 
                }
                
                totalSharings.add(woshare);
        }
        if(totalSharings != null && totalSharings.size()>0){
            try{
                insert totalSharings;
                system.debug('Successful--'+totalSharings);
            }
            catch(Exception e){
                system.debug('error-'+e.getMessage());
            }
        }*/
    }
}