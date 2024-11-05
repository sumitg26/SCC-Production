public class GeoLocController {
    @AuraEnabled
    public static string checkIn(String latitude, String longitude, String recId ){
        system.debug('latitude - '+latitude +'longitude= '+longitude +'Record id ='+recId);
        Work_order__c wo = [Select Id,Field_Crew_Start_Time__c,Field_Crew_End_Time__c FROM work_Order__c where id = :recId LIMIT 1];
       //Comment out for temporarily deactivate the GPS functionality and have only the timestamp captured.
       //Dt - 20/08/2024
      
        //wo.Field_Crew_Start_Location__Latitude__s = decimal.valueOf(latitude);
        //wo.Field_Crew_Start_Location__Longitude__s = decimal.valueOf(longitude);
        wo.Field_Crew_Start_Time__c = system.now();
        update wo;
        return 'checkIn success';
    }
    @AuraEnabled
    public static string checkOut(String latitude, String longitude, String recId ){
        system.debug('inside checkout latitude - '+latitude +'longitude= '+longitude +'Record id ='+recId);
        Work_order__c wo = [Select Id,Field_Crew_Start_Time__c,Field_Crew_End_Time__c FROM work_Order__c where id = :recId LIMIT 1];
       //Comment out for temporarily deactivate the GPS functionality and have only the timestamp captured.
       //Dt - 20/08/2024
      
        //wo.Field_Crew_End_Location__Latitude__s = decimal.valueOf(latitude);
        //wo.Field_Crew_End_Location__Longitude__s = decimal.valueOf(longitude);
        wo.Field_Crew_End_Time__c = system.now();
        update wo;
        return 'checkOut success';
    }

}