@isTest
Public class Calendar_ControllerTest
{
    static testMethod void calendarTest()
    {
        List<Calendar_Default_Setting__c> defaultSettingList;
        Calendar_Controller calendarControllerObj;

        Work_Order__c work;
        work = new Work_Order__c();
        work.Van_assignment__c = 'Van5'; 
        work.Requested_By__c = 'Test';
        work.Start_Date__c = system.today();
        work.OwnerId = UserInfo.getUserId();
        insert work; 
       
        system.assert(work.Id != null);
        
        Event event;
        event = new Event();
        event.Subject = 'Test Event';
        event.Location = 'Test Location';
        event.Description = 'Test Description'; 
        event.StartDateTime = datetime.now();
        event.EndDateTime = datetime.now().addHours(1);
        event.OwnerId = UserInfo.getUserId();
        event.IsPrivate = false;
        event.Whatid = work.Id;
        insert event;
        system.debug(event);
        Map<Id,Event> eventMap=new Map<Id,Event>();
        eventMap.put(event.id,event);
        system.assert(event.Id != null);
        
        Task task;
        task = new Task();
        task.Subject = 'Test Task';
        task.Status = 'In Progress';
        task.ActivityDate = Date.Today(); 
        task.ReminderDateTime = DateTime.now(); 
        task.Priority = 'High';
        task.OwnerId = UserInfo.getUserId();
        task.WhatId = work.Id;
        insert task;     
        
        system.assert(task.Id != null);
        
        calendarControllerObj = new Calendar_Controller();
        calendarControllerObj.createDefaultColors();
        
        Calendar_Default_Setting__c defaultSetting = new Calendar_Default_Setting__c ();
        defaultSetting.Name = UserInfo.getUserId();        
        defaultSetting.Show_Campaigns__c = true;
        defaultSetting.Show_Active_Campaigns_Only__c = false;
        defaultSetting.Default_Calendar_View__c = 'month';
        defaultSetting.Show_Events__c = true; 
        defaultSetting.Show_Historical_Events__c = true; 
        defaultSetting.Show_Open_Tasks_Only__c = false;
        defaultSetting.Show_Tasks__c = true;
        defaultSetting.Show_Todays_Events__c = false;
        defaultSetting.Start_Time__c = '09:00';
        defaultSetting.End_Time__c = '17:00';
        defaultSetting.User_Id__c = UserInfo.getUserId();
        insert defaultSetting;
        
        system.assert(defaultSetting.Id != null);
        
        Calendar_Colors__c calColors = new Calendar_Colors__c();
        calColors.Name = 'Color1'; 
        calColors.Back_Color__c = 'Black'; 
        calColors.Object__c = 'All'; 
        calColors.Status__c = 'All'; 
        calColors.Text_Color__c = 'White';
        calColors.Type__c = 'All';
        calColors.User__c = UserInfo.getUserId();        
        insert calColors; 
        
        system.assertEquals(calColors.Name, 'Color1');
        system.assert(calColors.Id != null);
        
        calColors = new Calendar_Colors__c();
        calColors.Name = 'Color2'; 
        calColors.Back_Color__c = 'Black'; 
        calColors.Object__c = 'All'; 
        calColors.Status__c = 'All'; 
        calColors.Text_Color__c = 'White';
        calColors.Type__c = 'Task';
        calColors.User__c = UserInfo.getUserId();        
        insert calColors; 
        
        system.assertEquals(calColors.Name, 'Color2');
        system.assert(calColors.Id != null);
        
        calColors = new Calendar_Colors__c();
        calColors.Name = 'Color3'; 
        calColors.Back_Color__c = 'Black'; 
        calColors.Object__c = 'All'; 
        calColors.Status__c = 'All'; 
        calColors.Text_Color__c = 'White';
        calColors.Type__c = 'Event';
        calColors.User__c = UserInfo.getUserId();  
        calColors.User_Based__c = true;
        calColors.Selected_User__c = UserInfo.getUserId(); 
        insert calColors; 
        
        calColors = new Calendar_Colors__c();
        calColors.Name = 'Color3'; 
        calColors.Back_Color__c = 'Black'; 
        calColors.Object__c = 'All'; 
        calColors.Status__c = 'All'; 
        calColors.Text_Color__c = 'White';
        calColors.Type__c = 'Work_Order__c';
        calColors.User__c = UserInfo.getUserId();  
        calColors.User_Based__c = true;
        calColors.Selected_User__c = UserInfo.getUserId(); 
        insert calColors; 

        Calendar_Event_Fields__c cef =  new Calendar_Event_Fields__c(API_Name__c = 'Priority', Field_Name__c = 'Priority',Object__c = 'Task',Order__c = 0, Name = 'Task-Priority');
        insert cef;
        
        Calendar_Event_Fields__c cef1 = new Calendar_Event_Fields__c(API_Name__c = 'Van_assignment__c', Field_Name__c = 'Van_assignment__c', Object__c = 'Work_Order__c',Order__c = 0, Name = 'WorkOrder-Name');
        insert cef1;
        insert new Calendar_Event_Fields__c(API_Name__c = 'Subject', Field_Name__c = 'Subject',Object__c = 'Event',Order__c = 0, Name = 'Event-Subject');
        
        system.assertEquals(calColors.Name, 'Color3');
        system.assert(calColors.Id != null);
        
        Calendar_Selected_Users__c users = new Calendar_Selected_Users__c();
        users.User_Id__c = UserInfo.getUserId();
        insert users;
        
        Calendar_Selected_Objects__c obj = new Calendar_Selected_Objects__c();
        obj.User_Id__c = UserInfo.getUserId();
        insert obj;
        
        Calendar_Selected_Vans__c vans = new Calendar_Selected_Vans__c();
        vans.User_Id__c = UserInfo.getUserId();
        insert vans;
       
        calendarControllerObj = new Calendar_Controller();
        calendarControllerObj.currentEventId = event.id;
        calendarControllerObj.showEvents = true;
        calendarControllerObj.flag = true;
        calendarControllerObj.backColor = '';
        calendarControllerObj.textColor = '';
        calendarControllerObj.currentUserId = UserInfo.getUserId();
        calendarControllerObj.createDefaultColors();
        
        calendarControllerObj.getObjectOptions();
        calendarControllerObj.getCalendarData();
        calendarControllerObj.getResourceData();
        calendarControllerObj.saveDefaults();
        
        cef.API_Name__c = 'WhatId';
        update cef;
        cef1.API_Name__c = 'OwnerId';
        update cef1;
        system.debug(cef1);
        calendarControllerObj.getCalendarData();
        calendarControllerObj.getResourceData();
        
        calendarControllerObj.newResourceId = string.valueOf(UserInfo.getUserId());
        calendarControllerObj.newStartTime = string.valueOf(DateTime.Now());
        calendarControllerObj.newEndTime = string.valueOf(DateTime.Now().addHours(2)); 
        calendarControllerObj.currentEventId = task.Id;
        calendarControllerObj.updateEvent();
        
        calendarControllerObj.newResourceId = string.valueOf(UserInfo.getUserId());
        calendarControllerObj.newStartTime = string.valueOf(DateTime.Now());
        calendarControllerObj.newEndTime = string.valueOf(DateTime.Now().addHours(2)); 
        calendarControllerObj.currentEventId = event.Id;
        calendarControllerObj.updateEvent();
        
        calendarControllerObj.newResourceId = string.valueOf(work.Van_assignment__c);
        calendarControllerObj.newStartTime = string.valueOf(DateTime.Now());
        calendarControllerObj.newEndTime = string.valueOf(DateTime.Now().addHours(2)); 
        calendarControllerObj.backColor = '';
        calendarControllerObj.textColor = '';
        calendarControllerObj.currentEventId = work.Id;
		
        
        calendarControllerObj.getSchedule();
        Calendar_Controller.getSalesforce1();
        calendarControllerObj.getAvailableViews();
        calendarControllerObj.getCalendarVans();
        calendarControllerObj.getCalendarUsers();
        calendarControllerObj.getEventColor(event,task,work);
    }
}