@isTest
Public class Calendar_Colors_ControllerTest
{
    static testMethod void cofigureCalendarColors()
    {
        Id user = UserInfo.getUserId();
        
        system.assertEquals(user, UserInfo.getUserId());
        
        Work_Order__c work;
        work = new Work_Order__c();
        work.Van_assignment__c = 'Van5'; 
        work.Requested_By__c = 'Test';
        work.Start_Date__c = system.today();
        work.OwnerId = UserInfo.getUserId();
        insert work;
        
        Calendar_Colors__c newCalendarColor = new Calendar_Colors__c(Name = 'Test Color Code', Back_Color__c = '#84FF80', Object__c = 'Account, Lead', Status__c = 'In Progress', Text_Color__c = '#FFFFFF', Type__c = 'Task', User__c = user,Van_Based__c = true);
        insert newCalendarColor;
        
        Calendar_Objects__c newCalendarObject = new Calendar_Objects__c(Name = 'Test Object',API_Name__c = 'Work_Order__c');
        insert newCalendarObject;
        
        system.assertEquals(newCalendarColor.Name, 'Test Color Code');
        system.assert(newCalendarColor.Id != null);
      
        Calendar_Colors_Controller configureCalendarColorController = new Calendar_Colors_Controller();
        newCalendarColor.Type__c = 'Event';
        update newCalendarColor;
        Calendar_Colors_Controller configure = new Calendar_Colors_Controller();
        newCalendarColor.Type__c = 'Work_Order__c';
        update newCalendarColor;
        Calendar_Colors_Controller configures = new Calendar_Colors_Controller();
        newCalendarColor.Type__c = 'Campaign';
        update newCalendarColor;
        Calendar_Colors_Controller con = new Calendar_Colors_Controller();
        configureCalendarColorController.addRows();
        configureCalendarColorController.deleteSelectedRows();
        configureCalendarColorController.Save();
        configureCalendarColorController.selectedColorRow = 1;
        configureCalendarColorController.disableUserCheckBox();
        configureCalendarColorController.disableVanCheckBox();
        
    }
}