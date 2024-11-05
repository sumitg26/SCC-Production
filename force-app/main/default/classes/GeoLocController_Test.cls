@isTest
public class GeoLocController_Test {
    @testSetup
    static void testDataCreation(){
        Work_Order__c  work = new Work_Order__c();
        work.Van_assignment__c = 'Van5'; 
        work.Requested_By__c = 'Test';
        work.Start_Date__c = system.today();
        work.OwnerId = UserInfo.getUserId();
        insert work;
        work.Field_Crew_Start_Location__Latitude__s = 28.4417269;
        work.Field_Crew_Start_Location__Longitude__s  = 77.31067139999999;
        update work;
    }
    static testmethod void testCheckInGeoLoc(){
        Work_Order__c wo = [Select id,Van_assignment__c FROM Work_Order__c];
        GeoLocController.checkIn('28.4417269', '77.31067139999999', wo.Id);
    }
    static testmethod void testCheckOutGeoLoc(){
        Work_Order__c wo = [Select id,Van_assignment__c FROM Work_Order__c];
        GeoLocController.checkOut('28.4417269', '77.31067139999999', wo.Id);
    }
}