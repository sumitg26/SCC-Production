@isTest
public class FieldCrewGeoLocation_Test {
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
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        FieldCrewGeoLocation fc = new FieldCrewGeoLocation(sc);
        ApexPages.currentPage().getParameters().put('LatParam','28.4417269');
        ApexPages.currentPage().getParameters().put('LongParam','77.31067139999999');
        fc.latt = '28.4417269';
        fc.longt = '77.31067139999999';
        fc.request = 'checkin';
        fc.saveCordinates();
    }
    static testmethod void testCheckOutGeoLoc(){
        Work_Order__c wo = [Select id,Van_assignment__c FROM Work_Order__c];
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        FieldCrewGeoLocation fc = new FieldCrewGeoLocation(sc);
        ApexPages.currentPage().getParameters().put('LatParam','28.4417269');
        ApexPages.currentPage().getParameters().put('LongParam','77.31067139999999');
        fc.latt = '28.4417269';
        fc.longt = '77.31067139999999';
        fc.request = 'checkout';
        fc.saveCordinates();
    }
}