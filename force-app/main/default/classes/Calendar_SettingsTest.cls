@isTest
Public class Calendar_SettingsTest{
    
    public static testMethod void timeSlateProSettingsTest()
    {    
        Calendar_Settings settings = new Calendar_Settings ();
        PageReference pageRef = Page.Calendar_Settings;
        Test.setCurrentPage(pageRef);

        insert new Calendar_Event_Fields__c(API_Name__c = 'Priority',Field_Name__c = 'Priority',Object__c = 'Task',Order__c = 3, Name = 'Task-Priority');
        insert new Calendar_Event_Fields__c(API_Name__c = 'Van_Assignment__c',Field_Name__c = 'Van_Assignment__c', Object__c = 'Work_Order__c',Order__c = 3, Name = 'WorkOrder-Name');
        insert new Calendar_Event_Fields__c(API_Name__c = 'Subject',Field_Name__c = 'Subject',Object__c = 'Event',Order__c = 3, Name = 'Event-Subject');

        Test.startTest();
        
		Calendar_Settings tProObject = new Calendar_Settings();
		ApexPages.currentPage().getParameters().put('userSelectedValuesParam','Type:Type,Description:Description');
		ApexPages.currentPage().getParameters().put('userSelectedValuesParamSecond','Type:0,Description:1');
		tProObject.getSelectedValues();
		tProObject.saveTaskFields();
		tProObject.saveEventFields();
		tProObject.saveCampaignFields();
        settings.toggleSettings();

        Test.stopTest();        
    }
}