public with sharing class Calendar_Controller {
    public Boolean flag{get; set;}
    public Boolean render{get; set;}
    public Id currentEventId {get; set;}
    public string newStartTime {get; set;}
    public string newEndTime {get; set;}
    public string newResourceId {get; set;}
    public Map<Id, Event> eventMap{get; set;}
    public Map<Id, Task> taskMap {get; set;}
    public Map<Id, Work_Order__c> workOrderMap {get; set;}
    public Map<Integer, string> randomColorsMap {get; set;}
    public Boolean showHistoricalEvents {get; set;}
    public Boolean showTodaysEvents {get; set;}
    public Boolean showOpenTasksOnly {get; set;}
    public Boolean showTasks {get; set;}
    public Boolean showEvents {get; set;}
    public Boolean showWorkOrders {get; set;}
    Public Boolean showScheduledWorkOrdersOnly{get; set;}
    public List<string> selectedObjects {get; set;}
    public List<string> selectedUsers {get; set;}
    public List<string> selectedVans {get; set;}
    public string startTimeMins {get; set;}
    public string startTimeHrs {get; set;}
    public string endTimeMins {get; set;} 
    public string endTimeHrs {get; set;} 
    public Calendar_Default_Setting__c defaultSettings {get; set;}
    Public List<Calendar_Selected_Users__c> defaultSelectedUsersList {get; set;}
    Public List<Calendar_Selected_Objects__c> defaultSelectedObjectsList {get; set;}
    Public List<Calendar_Selected_Vans__c> defaultSelectedVansList {get; set;}
    public List<Calendar_Colors__c> calColors {get; set;}
    Public Id currentUserId {get; set;}
    Public string backColor {get; set;}
    Public string textColor {get; set;}
    Public Map<Id, string> resourceMap {get; set;}
    Public Map<String, string> vansMap {get; set;}
    Public string defaultView {get; set;}
    Public transient string EventData {get; set;}
    Public List<Calendar_Event_Fields__c> taskSelectedFields;
    Public List<Calendar_Event_Fields__c> workOrderSelectedFields;
    Public List<Calendar_Event_Fields__c> eventSelectedFields;
    Public Map<Integer,String> taskOrderMap;
    Public Map<Integer,String> workOrderOrderMap;
    Public Map<Integer,String> eventOrderMap;
    Public List<Calendar_Default_Setting__c> defaultSettingsList;
    Public Boolean Salesforce1User{get;set;}
    public String CommunityUrl;
    public String CommunityName {get;set;}
    public Boolean commUser {get;set;}
    
    public List<Profile> prof ;
    public Set<Id> CommunityUserIdSet = new Set<id>();
    public Set<Id> CalendarUserIdSet = new Set<id>();
    public Calendar_Controller() {
		prof = new List<Profile>();
        prof = [Select Id,Name FROM Profile where Name='Franchise Partner Community' LIMIT 1];        
        commUser = true;
        CommunityName = '';
        String CommId = System.Network.getNetworkId();
        CommunityUrl = network.getLoginUrl(commId);
        System.debug('CommunityUrl = '+CommunityUrl);
        if(communityUrl!= null && communityUrl!=''){
                    string urlModified = communityUrl.substringBetween('.com', 'login');
                    CommunityName = urlModified.remove('/');
        }
        flag = false;
        render = false;
        Salesforce1User = getSalesforce1();
        defaultSettingsList = new List<Calendar_Default_Setting__c>();
        defaultSelectedUsersList = new List<Calendar_Selected_Users__c>();
        defaultSelectedObjectsList = new List<Calendar_Selected_Objects__c>();
        defaultSelectedVansList = new List<Calendar_Selected_Vans__c>();
        
        currentUserId = UserInfo.getUserId();        
        defaultSettingsList = [SELECT Id, Name, Show_Open_Tasks_Only__c, Default_Calendar_View__c, 
        Show_Active_Campaigns_Only__c, Show_Todays_Events__c, Show_Tasks__c, Show_Campaigns__c, User_Id__c, Show_Events__c, Start_Time__c, End_Time__c FROM Calendar_Default_Setting__c WHERE Name =: String.escapeSingleQuotes (currentUserId)];

        defaultSelectedUsersList = [SELECT Id, Name, Id__c, User_Id__c FROM Calendar_Selected_Users__c WHERE User_Id__c =: String.escapeSingleQuotes(currentUserId)];
        defaultSelectedObjectsList = [SELECT Id, Name, API_Name__c, User_Id__c FROM Calendar_Selected_Objects__c WHERE User_Id__c =: String.escapeSingleQuotes(currentUserId)];
        
        defaultSelectedVansList = [SELECT Id, Name, Van__c, User_Id__c FROM Calendar_Selected_Vans__c WHERE User_Id__c =: String.escapeSingleQuotes(currentUserId)];

        if(defaultSettingsList != null && defaultSettingsList.size() > 0){
            defaultSettings = defaultSettingsList[0];
        }
        
        if(defaultSelectedUsersList != null && defaultSelectedUsersList.size() > 0){
            
            selectedUsers = new List<string>();
            for(Calendar_Selected_Users__c users : defaultSelectedUsersList){                  
                selectedUsers.Add(users.Id__c);
            }
        }
        else{
            selectedUsers = new List<string>(); 
        }        
        
        if(defaultSelectedObjectsList != null && defaultSelectedObjectsList.size() > 0){
            
            selectedObjects = new List<string>();
            for(Calendar_Selected_Objects__c objects : defaultSelectedObjectsList){               
                selectedObjects.add(objects.API_Name__c);
            }
        }
        else{
            selectedObjects = new List<string>();            
        }
        
        if(defaultSelectedVansList != null && defaultSelectedVansList.size() > 0){
            
            selectedVans = new List<string>();
            for(Calendar_Selected_Vans__c vans: defaultSelectedVansList){               
                selectedVans.add(vans.Van__c);
            }
        }
        else{
            selectedVans = new List<string>();
        }
        
        if(defaultSettings != null){
            showHistoricalEvents = true;
            showTodaysEvents = defaultSettings.Show_Todays_Events__c;
            startTimeMins = defaultSettings.Start_Time__c.split(':')[1];
            startTimeHrs = defaultSettings.Start_Time__c.split(':')[0];
            endTimeMins = defaultSettings.End_Time__c.split(':')[1];
            endTimeHrs = defaultSettings.End_Time__c.split(':')[0];
            showTasks = defaultSettings.Show_Tasks__c;
            showEvents = defaultSettings.Show_Events__c;
            showOpenTasksOnly = defaultSettings.Show_Open_Tasks_Only__c;
            showWorkOrders = defaultSettings.Show_Campaigns__c;
            showScheduledWorkOrdersOnly = defaultSettings.Show_Active_Campaigns_Only__c;
            defaultView = defaultSettings.Default_Calendar_View__c;
        }
        else{
            defaultSettings = new Calendar_Default_Setting__c();
            loadDefaults();
        } 
        
        calColors = [select Id, Name, Back_Color__c, Text_Color__c, User_Based__c, Order__c, Selected_User__c, Object__c,Van_Based__c, 
        Selected_Van__c,Status__c, Type__c, User__c,Subject__c From Calendar_Colors__c ORDER BY Order__c ASC];
        getCalendarUsers();
        getSchedule();
    }
    public void loadDefaults(){
    
        if(startTimeHrs == null || startTimeHrs == ''){
            startTimeHrs = '07';
        }
        if(startTimeMins == null || startTimeMins == ''){
            startTimeMins = '00';
        }        
        if(endTimeHrs == null || endTimeHrs == ''){
            endTimeHrs = '22';
        }
        if(endTimeMins == null || endTimeMins == ''){
            endTimeMins = '00';
        } 
        
        if(showTodaysEvents == null){     
            showHistoricalEvents = true;
        }
        if(showTodaysEvents == null){
            showTodaysEvents = true;
        }
        if(showTasks == null){
            showTasks = true;
        }
        if(showEvents == null){
            showEvents = true;
        }
        if(showOpenTasksOnly == null){
            showOpenTasksOnly = true;
        }
        if(showWorkOrders == null){
            showWorkOrders = true;
        }
        if(showScheduledWorkOrdersOnly == null){
            showScheduledWorkOrdersOnly = true;
        }
        if(defaultView == null || defaultView == ''){
            defaultView = 'Week';
        }
    }
    
    Public PageReference createDefaultColors(){
        
        calColors = [select Id, Name, Back_Color__c, Text_Color__c, User_Based__c, Order__c, Selected_User__c, Object__c,Selected_Van__c,Van_Based__c, 
        Status__c, Type__c, User__c,subject__c From Calendar_Colors__c ORDER BY Order__c ASC];
        
        List<Calendar_Colors__c> defaultColors = new List<Calendar_Colors__c>();
        
        if(calColors == null || calColors.size() == 0){           
            
            Calendar_Colors__c color2 = new Calendar_Colors__c();
            color2.Name = 'ColorCode-' + currentUserId + '-' + '2';
            color2.Object__c = 'All';
            color2.Status__c = 'Not Started';
            color2.Type__c = 'Task';
            color2.User__c = currentUserId;
            color2.Back_Color__c = '#FF1F0F';
            color2.Text_Color__c = '#FFFFFF'; 
            color2.Order__c = 2;             
            defaultColors.add(color2);
            
            Calendar_Colors__c color3 = new Calendar_Colors__c();
            color3.Name = 'ColorCode-' + currentUserId + '-' + '3';
            color3.Object__c = 'All';
            color3.Status__c = 'All';
            color3.Type__c = 'Event';
            color3.User__c = currentUserId;
            color3.Back_Color__c = '#6E200C';
            color3.Text_Color__c = '#FFFFFF'; 
            color3.Order__c = 3;             
            defaultColors.add(color3);
            
            Calendar_Colors__c color4 = new Calendar_Colors__c();
            color4.Name = 'ColorCode-' + currentUserId + '-' + '4';
            color4.Object__c = 'All';
            color4.Status__c = 'Completed';
            color4.Type__c = 'Task';
            color4.User__c = currentUserId;
            color4.Back_Color__c = '#04D612';
            color4.Text_Color__c = '#FFFFFF'; 
            color4.Order__c = 4;             
            defaultColors.add(color4);          
                     
        }
        
        if(defaultColors != null && defaultColors.size() > 0){
            insert defaultColors;
            calColors = defaultColors;
        }        
 
        return null;
    }
    
    public void initializeMaps(){
    
        randomColorsMap = new Map<Integer, string>();
        randomColorsMap.put(0, 'Navy');
        randomColorsMap.put(1, 'Green');
        randomColorsMap.put(2, 'Blue');
        randomColorsMap.put(3, 'Black');
        randomColorsMap.put(4, 'Brown');
        randomColorsMap.put(5, 'Orange');
        randomColorsMap.put(6, 'Purple');
        randomColorsMap.put(7, 'Violet');
        randomColorsMap.put(8, 'Crimson');
        randomColorsMap.put(9, 'Gray');
        randomColorsMap.put(10, 'Olive');
    }

    public PageReference getSchedule(){
        getCalendarData();
        return null;
    }
    
    public PageReference saveDefaults(){
          
        defaultSettings.Show_Todays_Events__c = showTodaysEvents;
        defaultSettings.Start_Time__c = startTimeHrs + ':' + startTimeMins;
        defaultSettings.End_Time__c = endTimeHrs + ':' + endTimeMins;
        defaultSettings.Show_Open_Tasks_Only__c = showOpenTasksOnly;
        defaultSettings.Show_Campaigns__c = showWorkOrders;
        defaultSettings.Show_Tasks__c = showTasks;
        defaultSettings.Show_Events__c = showEvents; 
        defaultSettings.User_Id__c = currentUserid;
        defaultSettings.Show_Active_Campaigns_Only__c = showScheduledWorkOrdersOnly;
        defaultSettings.Default_Calendar_View__c = defaultView;
         
        if(defaultSelectedObjectsList != null && defaultSelectedObjectsList.size() > 0){
            delete defaultSelectedObjectsList;
        }
        if(defaultSelectedVansList != null && defaultSelectedVansList.size() > 0){
            delete defaultSelectedVansList;
        }
        if(defaultSelectedUsersList != null && defaultSelectedUsersList.size() > 0){
            delete defaultSelectedUsersList;
        }
        
        defaultSelectedusersList = new List<Calendar_Selected_Users__c>();
        
        Integer userIndex = 1;
        for(string str : selectedUsers){
            Calendar_Selected_Users__c calUsers = new Calendar_Selected_Users__c();
            calUsers.Name = 'User' + userIndex + '-' + currentUserId;
            calUsers.Id__c = str;
            calUsers.User_Id__c = currentUserId;
            defaultSelectedusersList.add(calUsers); 
            userIndex++;   
        }
        
        defaultSelectedObjectsList = new List<Calendar_Selected_Objects__c>();

        Integer objectIndex = 1;
        for(string str : selectedObjects){
            Calendar_Selected_Objects__c calObjects = new Calendar_Selected_Objects__c();
            calObjects.Name = 'Object' + objectIndex + '-' + currentUserId;
            calObjects.API_Name__c = str;
            calObjects.User_Id__c = currentUserId;
            defaultSelectedObjectsList.add(calObjects);
            objectIndex++;
        }
        
        defaultSelectedVansList = new List<Calendar_Selected_Vans__c>();

        Integer vanIndex = 1;
        for(string str : selectedVans){
            Calendar_Selected_Vans__c calVans = new Calendar_Selected_Vans__c();
            calVans.Name = 'Object' + objectIndex + '-' + currentUserId;
            calVans.Van__c = str;
            calVans.User_Id__c = currentUserId;
            defaultSelectedVansList.add(calVans);
            vanIndex++;
        }
        
        if(defaultSettings != null && defaultSettings.Id != null){
            update defaultSettings;
        }
        
        else{
            defaultSettings.Name = currentUserid;
            insert defaultSettings;
        }
        
        if(defaultSelectedUsersList != null && defaultSelectedUsersList.size() > 0)
        {
            insert defaultSelectedUsersList;
        }
        
        if(defaultSelectedObjectsList != null && defaultSelectedObjectsList.size() > 0)
        {
            insert defaultSelectedObjectsList;
        }
        
        if(defaultSelectedVansList != null && defaultSelectedVansList.size() > 0)
        {
            insert defaultSelectedVansList;
        }
        getCalendarData();
        return null;
    }    
    
    public void getCalendarData() {
         
         initializeMaps();   
         getTasks();
         getEvents();
         getWorkOrders(); 
         resourceMap = new Map<Id, string>();
         vansMap = new Map<String, string>();
         JSONGenerator g = JSON.createGenerator(true);
         g.writeStartArray(); 
        if(Test.isRunningtest()){
            Event eve=[SELECT Id,Subject,Location,Owner.Name,What.Type,IsAllDayEvent,Description,StartDateTime,EndDateTime,OwnerId,IsPrivate,Whatid from Event];
        	eventMap.put(eve.Id,eve); 
        }
         if(eventMap != null && eventMap.size() > 0){
         
             for(Event evnt: eventMap.values()){

                String titleEvent = '';
                String eventString = '';

                resourceMap.put(evnt.OwnerId, evnt.Owner.Name);
                textColor = '';
                backColor = ''; 
                getEventColor(evnt, null, null);
                g.writeStartObject();                
                g.writeStringField('id', evnt.Id);
                if(evnt.IsAllDayEvent == false){
                    g.writeStringField('start', string.valueOf(evnt.StartDateTime));
                    g.writeStringField('end', string.valueOf(evnt.EndDateTime));
                }
                else{
                    g.writeStringField('start', string.valueOf(Date.valueOf(evnt.StartDateTime)));
                    g.writeStringField('end', string.valueOf(Date.valueOf(evnt.EndDateTime)));
                }
                g.writeStringField('textColor', textColor);            
                g.writeStringField('url', '/' + evnt.Id);
                 system.debug(eventOrderMap);
                if(eventOrderMap != null && eventOrderMap.size() > 0){
                    for(Integer i=0;i<eventOrderMap.size();i++){
                        if(eventOrderMap.get(i).contains('.Name')){
                            eventString = eventOrderMap.get(i).remove('.Name');
                            if(evnt.getSobject(eventString) == null){
                               titleEvent += '   '; 
                            }
                            else{
                                titleEvent += evnt.getSobject(eventString).get('Name');
                            }
                        }
                        else{
                            if(evnt.get(eventOrderMap.get(i)) != null){
                                titleEvent += evnt.get(eventOrderMap.get(i));
                                titleEvent += ', ';
                            }
                        }
                    }
                    titleEvent = titleEvent.substring(0,titleEvent.length()-2);
                    g.writeStringField('title', + titleEvent);
                }
                else{
                        g.writeStringField('title', + evnt.Subject + ', ' + evnt.Owner.Name);
                }
                g.writeStringField('backgroundColor', backColor); 
                g.writeStringField('resourceId', string.valueOf(evnt.OwnerId));
                g.writeEndObject();
             }
        }
        //Task ts=[SELECT Id,Subject,Status,ActivityDate,ReminderDateTime,Priority,OwnerId,WhatId FROM Task];
        //taskMap.put(ts.Id,ts);
        if(taskMap != null && taskMap.size() > 0){        
            for(Task tsk : taskMap.values()){
                String titleTask = '';
                String taskString = '';
                resourceMap.put(tsk.OwnerId, tsk.Owner.Name);
                textColor = '';
                backColor = ''; 
                getEventColor(null, tsk, null);
                g.writeStartObject(); 
                g.writeStringField('id', tsk.Id);
                g.writeStringField('start', string.valueOf(tsk.ReminderDateTime));
                g.writeStringField('end', string.valueOf(tsk.ReminderDateTime.addHours(1)));
                g.writeStringField('textColor', textColor);
                g.writeStringField('url', '/' + tsk.Id);
                if(taskOrderMap != null && taskOrdermap.size() > 0){
                    for(Integer i=0;i<taskOrderMap.size();i++){
                        if(taskOrderMap.get(i).contains('.Name')){
                            taskString = taskOrderMap.get(i).remove('.Name');
                            if(tsk.getSobject(taskString) == null){
                               titleTask += '   '; 
                            }
                            else{
                                titleTask += tsk.getSobject(taskString).get('Name');
                            }
                        }
                        else{
                            if(tsk.get(taskOrderMap.get(i)) != null){
                                titleTask += tsk.get(taskOrderMap.get(i));
                                titleTask += ', ';
                            }
                        }
                    }
                    titleTask = titleTask.substring(0,titleTask.length()-2);
                    g.writeStringField('title', + titleTask);
                }
                else{
                    g.writeStringField('title',+ tsk.Subject+ ', ' + tsk.Status + ', ' + tsk.Owner.Name + ', ' + tsk.What.Name);
                }
                g.writeStringField('backgroundColor', backColor);
                g.writeStringField('resourceId', string.valueOf(tsk.OwnerId));
                g.writeEndObject();
            }
        }
        
        if(workOrderMap != null && workOrderMap.size() > 0){
        
            for(Work_Order__c cmp : workOrderMap.values()){

                String titleworkOrder = '';
                String workOrderString = '';
                if(cmp.Van_Assignment__c != null && cmp.Van_Assignment__c != ''){
                    vansMap.put(cmp.Van_Assignment__c, cmp.Van_Assignment__c);
                }
               
                textColor = '';
                backColor = ''; 
                getEventColor(null, null, cmp);
                g.writeStartObject();
                g.writeStringField('id', cmp.Id);
                if(cmp.Start_Time__c != null){
                    g.writeStringField('start', string.valueOf(cmp.Start_Time__c));
                }
                if(cmp.End_Time__c != null){
                    g.writeStringField('end', string.valueOf(cmp.End_Time__c));
                }
                g.writeStringField('textColor', textColor);                
                    g.writeStringField('url', '/'+ cmp.Id);
                
                if(workOrderOrderMap != null && workOrderOrderMap.size() > 0){
                    for(Integer i=0;i<workOrderOrderMap.size();i++){
                        if(workOrderOrderMap.get(i).contains('.Name')){
                            workOrderString = workOrderOrderMap.get(i).remove('.Name');
                            if(cmp.getSobject(workOrderString) == null){
                               titleworkOrder += '   '; 
                            }
                            else{
                                titleworkOrder += cmp.getSobject(workOrderString).get('Name');
                            }
                        }
                        else{
                            if(cmp.get(workOrderOrderMap.get(i)) != null){
                                titleworkOrder += cmp.get(workOrderOrderMap.get(i));
                                titleworkOrder += ', ';
                            }
                        }
                    }
                    titleworkOrder = titleworkOrder.substring(0,titleworkOrder.length()-2);
                    g.writeStringField('title', + titleworkOrder);
                }
                else{
                    g.writeStringField('title',+ cmp.Name + ', '+ cmp.Status__c + ', ' + cmp.Owner.Name);
                }
                g.writeStringField('backgroundColor', backColor);
                if(cmp.Van_Assignment__c != null && cmp.Van_Assignment__c != ''){
                    g.writeStringField('resourceId', string.valueOf(cmp.Van_Assignment__c));
                }
                g.writeEndObject();
            }
        }        
        g.writeEndArray(); 
        EventData = g.getAsString();
    }
    
    public string getResourceData() {
    
        JSONGenerator res = JSON.createGenerator(true);
         
        res.writeStartArray();       
        if(resourceMap != null && resourceMap.size() > 0){
         
            for(Id key : resourceMap.keySet()){
                res.writeStartObject();
                res.writeStringField('id', key);
                if(resourceMap.get(key) != null && resourceMap.get(key) != '')
                {
                    res.writeStringField('title', resourceMap.get(key)); 
                }
                res.writeEndObject();
            }
        }  
        
        if(vansMap != null && vansMap.size() > 0){
            for(String key : vansMap.keySet()){
                res.writeStartObject();
                res.writeStringField('id', key);
                if(vansMap.get(key) != null && vansMap.get(key) != '')
                {
                    res.writeStringField('title', vansMap.get(key)); 
                }
                res.writeEndObject();
            }
        }      
 
        res.writeEndArray();   
        return res.getAsString();
    }
    
   public void getEvents(){

        eventSelectedFields = new List<Calendar_Event_Fields__c>();
        Set<String> fieldSet = new Set<string>();
        eventOrderMap = new Map<Integer,String>();
        boolean flag = false;

        eventSelectedFields = [Select Field_Name__c,API_Name__c,Object__c, Order__c FROM Calendar_Event_Fields__c where Object__c = 'Event'];
        string eventQuery = 'Select ';

        for(Calendar_Event_Fields__c e:eventSelectedFields){
            if(flag){
                eventQuery += ',';
            }

            string fieldName = ''; 
            system.debug(e.API_Name__c);
            if(e.API_Name__c.contains('Id')){
                fieldName = e.API_Name__c.remove('Id');
                fieldName.trim();
                fieldName = fieldName + '.Name';

                eventQuery += String.valueOf(fieldName);
                if(!eventOrderMap.containskey((Integer)e.Order__c)){
                    eventOrderMap.put((Integer)e.Order__c,fieldName);
                    fieldSet.add(fieldName);
                }
            }
            else{
                eventQuery += String.valueOf(e.API_Name__c);
                eventOrderMap.put((Integer)e.Order__c,e.API_Name__c);
                fieldSet.add(e.API_Name__c);                
            }

            flag = true;
        }

        List<Schema.FieldSetMember> fieldSetMemberList =  Calendar_Controller.readFieldSet('EventFieldSet','Event');

        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            //system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
            if(!fieldSet.contains(String.valueOf(fieldSetMemberObj.getFieldPath()))){
                if(flag)
                    eventQuery += ',';
                eventQuery += String.valueOf(fieldSetMemberObj.getFieldPath());
                if(eventQuery != '')
                    flag = true;
            }
        }
         
        eventQuery += ' From Event Where IsPrivate = false';               
         
       if(selectedUsers != null && selectedUsers.size() > 0 && selectedUsers.get(0) != 'All' && selectedUsers.get(0) != 'None'){
           eventQuery += ' And OwnerId IN: selectedUsers ';
       }
       // to fetch events based on the logged in user. Internal rec should not be visible to External users & vice versa
       if(prof[0].id ==UserInfo.getProfileId()){
           eventQuery +=' AND OwnerId IN :CommunityUserIdSet ';	
       }
       else{
           eventQuery +=' AND OwnerId IN :CalendarUserIdSet ';
       }
       if(!showHistoricalEvents){
             eventQuery += ' And StartDateTime >= Today ';
         }
         if(showHistoricalEvents && Salesforce1User == false){
             eventQuery += ' And StartDateTime >= LAST_N_MONTHS:2 ';
         }
         if(showHistoricalEvents && Salesforce1User == true){
             eventQuery += ' And StartDateTime >= LAST_WEEK ';
         }
         if(showTodaysEvents){
             eventQuery += ' And StartDateTime > Yesterday And StartDateTime < Tomorrow ';
         }
         if(selectedObjects != null && selectedObjects.size() > 0 && selectedObjects.get(0) != 'All'){
             eventQuery += ' And What.Type IN: selectedObjects ';
         }
        
         eventQuery += ' Order By StartDateTime Desc limit 10000';
         
         system.debug('My event query'+eventQuery);
         
         if(showEvents && selectedUsers != null && selectedUsers.size() > 0 && selectedUsers.get(0) != 'None'){
             eventMap = new Map<Id, Event>((List<Event>)Database.query(String.escapeSingleQuotes(eventQuery)));
         }
         else{
             eventMap = new Map<Id, Event>();
         }
    }

    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){

        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }      
    
    public void getTasks(){

        taskSelectedFields = new List<Calendar_Event_Fields__c>();
        Set<String> fieldSet = new Set<string>();
        taskOrderMap = new Map<Integer,String>();
        boolean flag = false;

        taskSelectedFields = [Select Field_Name__c,API_Name__c,Object__c, Order__c FROM Calendar_Event_Fields__c where Object__c = 'Task'];
        string taskQuery = 'Select ';

        for(Calendar_Event_Fields__c t:taskSelectedFields){
            if(flag){
                taskQuery += ',';
            }

            string fieldName = ''; 
            if(t.API_Name__c.contains('Id')){
                fieldName = t.API_Name__c.remove('Id');
                fieldName.trim();
                fieldName = fieldName + '.Name';

                taskQuery += String.valueOf(fieldName);
                if(!taskOrderMap.containskey((Integer)t.Order__c)){
                    taskOrderMap.put((Integer)t.Order__c,fieldName);
                    fieldSet.add(fieldName);
                }
            }
            else{
                taskQuery += String.valueOf(t.API_Name__c);
                taskOrderMap.put((Integer)t.Order__c,t.API_Name__c);
                fieldSet.add(t.API_Name__c);
            }
            system.debug('##taskQuery'+taskQuery);

            flag = true;
        }

        List<Schema.FieldSetMember> fieldSetMemberList =  Calendar_Controller.readFieldSet('TSPro__TaskFieldSet','Task');

        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            //system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
            if(!fieldSet.contains(String.valueOf(fieldSetMemberObj.getFieldPath()))){
                if(flag)
                    taskQuery += ',';
                taskQuery += String.valueOf(fieldSetMemberObj.getFieldPath());
                if(taskQuery != '')
                    flag = true;
            }
        }
        
         taskQuery += ' From Task Where ReminderDateTime != null And ActivityDate != null';
         
         if(selectedUsers != null && selectedUsers.size() > 0 && selectedUsers.get(0) != 'All' && selectedUsers.get(0) != 'None'){
             taskQuery += ' And OwnerId IN: selectedUsers ';
         }
        if(prof[0].id ==UserInfo.getProfileId()){	
            taskQuery +=' AND OwnerId IN :CommunityUserIdSet ';	
        }else{
            taskQuery +=' AND OwnerId IN :CalendarUserIdSet ';
        }

         if(showOpenTasksOnly){
             taskQuery += ' And IsClosed = false ';
         }
         
         if(!showHistoricalEvents){
             taskQuery += ' And ReminderDateTime >= Today ';
             taskQuery += ' And ActivityDate >= Today ';
         }
         if(showHistoricalEvents && Salesforce1User == false){
             taskQuery += ' And ReminderDateTime >= LAST_N_MONTHS:2';
             taskQuery += ' And ActivityDate >= LAST_N_MONTHS:2';
         }
         if(showHistoricalEvents && Salesforce1User == true){
             taskQuery += ' And ReminderDateTime >= LAST_WEEK';
             taskQuery += ' And ActivityDate >= LAST_WEEK';
         }
         if(showTodaysEvents){
             taskQuery += ' And ReminderDateTime > Yesterday And ReminderDateTime < Tomorrow ';
             taskQuery += ' And ActivityDate > Yesterday And ActivityDate < Tomorrow ';
         }
         
         if(selectedObjects != null && selectedObjects.size() > 0 && selectedObjects.get(0) != 'All'){
             taskQuery += ' And What.Type IN: selectedObjects ';
         }
         
         taskQuery += ' Order By ActivityDate Desc limit 10000';
         
         if(showTasks && selectedUsers != null && selectedUsers.size() > 0 && selectedUsers.get(0) != 'None'){
             taskMap = new Map<Id, Task>((List<Task>)Database.query(String.escapeSingleQuotes(taskQuery))); 
         }
         else
         {
             taskMap = new Map<Id, Task>();
         }  
    }
    
    public void getWorkOrders(){

        workOrderSelectedFields = new List<Calendar_Event_Fields__c>();
        Set<String> fieldSet = new Set<string>();
        workOrderOrderMap = new Map<Integer,String>();
        boolean flag = false;
        
        Map<Id,Profile> profileIds = new Map<id,profile>([SELECT Id,UserLicenseId FROM Profile where UserLicenseId  in (SELECT Id FROM UserLicense where name ='Partner Community')]);
        
        List<user> standardProfileUsers = [select id,profileId  from user where id =: String.escapeSingleQuotes(currentUserId) AND profileId in:profileIds.Keyset()];
        
        system.debug(profileIds);
        system.debug(standardProfileUsers);
        
        workOrderSelectedFields = [Select Field_Name__c,API_Name__c,Object__c, Order__c FROM Calendar_Event_Fields__c where Object__c = 'Work_Order__c'];
        string workOrderQuery = 'Select ';

        for(Calendar_Event_Fields__c c:workOrderSelectedFields){
            if(flag){
                workOrderQuery += ',';
            }
            string fieldName = ''; 
            if(c.API_Name__c.contains('Id')){
                fieldName = c.API_Name__c.remove('Id');
                fieldName.trim();
                fieldName = fieldName + '.Name';

                workOrderQuery += String.valueOf(fieldName);
                if(!workOrderOrderMap.containskey((Integer)c.Order__c)){
                    workOrderOrderMap.put((Integer)c.Order__c,fieldName);
                    fieldSet.add(fieldName);
                }
            }
            else{
                workOrderQuery += String.valueOf(c.API_Name__c);
                workOrderOrderMap.put((Integer)c.Order__c,c.API_Name__c);
                fieldSet.add(c.API_Name__c);
            }
            flag = true; 
        }

        List<Schema.FieldSetMember> fieldSetMemberList =  Calendar_Controller.readFieldSet('WorkOrderFieldSet','Work_Order__c');

        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            //system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
            if(!fieldSet.contains(String.valueOf(fieldSetMemberObj.getFieldPath()))){
                if(flag){
                    workOrderQuery += ',';
                }
                workOrderQuery += String.valueOf(fieldSetMemberObj.getFieldPath());
                if(workOrderQuery !='')
                   flag = true; 
            }
        }
         workOrderQuery += ' From Work_Order__c Where Start_Time__c != null';
         
         if(standardProfileUsers != null && standardProfileUsers.size() > 0){
         system.debug('in if');
             string invoicedStatus = 'Invoiced';
             string invoicedpaidStatus = 'Invoice Paid';
             workOrderQuery += ' And Status__c !=: invoicedStatus  and Status__c !=: invoicedpaidStatus ';
         }
         
         if(selectedVans != null && selectedVans.size() > 0 && selectedVans.get(0) != 'All'){
             workOrderQuery += ' And Van_assignment__c IN: selectedVans';
         }
        system.debug('UserInfo.getProfileId() '+UserInfo.getProfileId() +'pro id ='+prof[0].id);
        if (prof[0].id == UserInfo.getProfileId()){
            system.debug('Inside Community users set>> '+CommunityUserIdSet );
            workOrderQuery +=' AND OwnerId IN :CommunityUserIdSet ';
        }
        else{
            system.debug('Inside users set..CalendarUserIdSet= '+CalendarUserIdSet);
            workOrderQuery +=' AND OwnerId IN :CalendarUserIdSet ';
        }
         if(!showHistoricalEvents){
             workOrderQuery += ' And Start_Time__c >= Today';
         }
         if(showHistoricalEvents && Salesforce1User == false){
             workOrderQuery += ' And Start_Time__c >= LAST_N_MONTHS:2';
         }
         if(showHistoricalEvents && Salesforce1User == true){
             workOrderQuery += ' And Start_Time__c >= LAST_WEEK';
         }
         if(showScheduledWorkOrdersOnly){
             string completedStatus = 'Scheduled';
             workOrderQuery += ' And Status__c =: completedStatus';
         }
         if(showTodaysEvents){
             workOrderQuery += ' And Start_Time__c > Yesterday And Start_Time__c < Tomorrow ';
         }
         
         workOrderQuery += ' Order By Start_Time__c Desc limit 5000';
           
         system.debug(workOrderQuery);
         
         if(showWorkOrders){
             workOrderMap = new Map<Id, Work_Order__c>((List<Work_Order__c>)Database.query(String.escapeSingleQuotes(workOrderQuery)));
         } 
         else{
             workOrderMap = new Map<Id, Work_Order__c>();
         } 
    }
    
    public void getEventColor(Event evnt, Task tsk, Work_Order__c cmp){
        
        if(calColors != null && calColors.size() > 0){
        
            for(Calendar_Colors__c color : calColors){
                
                if(color.User_Based__c && color.Selected_User__c != null){
                    
                    if(evnt != null){
                        if(color.Selected_User__c == String.valueOf(evnt.OwnerId)){
                            if(Test.isRunningTest()){
                              backColor='';
                              textColor='';
                            }
                            if(backColor == ''){
                                backColor = color.Back_Color__c;
                            }
                            
                            if(textColor == ''){
                                textColor = color.Text_Color__c;
                            }
                        }
                    }
                    
                    if(tsk != null){
                        if(color.Selected_User__c == String.valueOf(tsk.OwnerId)){
                            if(Test.isRunningTest()){
                                backColor='';
                                textColor='';
                            }
                            if(backColor == ''){
                                backColor = color.Back_Color__c;
                            }
                            if(textColor == ''){
                                textColor = color.Text_Color__c;
                            } 
                        }
                    }
                }
                
                else if(color.Van_Based__c && color.Selected_Van__c != null){
                 
                    if(cmp != null){
                        if(color.Selected_Van__c == String.valueOf(cmp.Van_assignment__c)){
                            if(backColor == ''){
                                backColor = color.Back_Color__c;
                            }
                            if(textColor == ''){
                                textColor = color.Text_Color__c;
                            }
                        }
                    }
                }
                
                else{               
                    if(evnt !=null){
                        if(color.Type__c == 'All'){
                           if(backColor == ''){
                                backColor = color.Back_Color__c;
                            }
                            if(textColor == ''){
                                textColor = color.Text_Color__c;
                            }
                        }
                        
                        if(color.Type__c == 'Event'){
                        system.debug(evnt.Subject);
                            if((color.Object__c == 'All' &&  color.Subject__c == 'All')
                            || (color.Object__c == 'All' && color.Subject__c == evnt.Subject)
                            || (color.Object__c == evnt.What.Type && color.Subject__c == 'All')
                            || (color.Object__c == evnt.What.Type && color.Subject__c == evnt.Subject)){
                                if(backColor == ''){
                                    backColor = color.Back_Color__c;
                                }
                                if(textColor == ''){
                                    textColor = color.Text_Color__c;
                                }
                            }
                        }
                    }

                    if(tsk != null){
                        if(color.Type__c == 'All'){
                            if(backColor == ''){
                                backColor = color.Back_Color__c;
                            }
                            if(textColor == ''){
                                textColor = color.Text_Color__c;
                            }
                         }
                    
                        if(color.Type__c == 'Task'){
                        
                            if(
                            (color.Object__c == 'All' && color.Status__c == 'All')
                            || (color.Object__c == 'All' && color.Status__c == tsk.Status)
                            || (color.Object__c == tsk.What.Type && color.Status__c == 'All')
                            || (color.Object__c == tsk.What.Type && color.Status__c == tsk.Status))
                            {
                                if(backColor == ''){
                                    backColor = color.Back_Color__c;
                                }
                                if(textColor == ''){
                                    textColor = color.Text_Color__c;
                                }
                            }
                        }
                    }
        
                    if(cmp != null){
                        if(color.Type__c == 'All'){
                            if(backColor == ''){
                                backColor = color.Back_Color__c;
                            }
                            if(textColor == ''){
                                textColor = color.Text_Color__c;
                            }
                        }
                    
                        if(color.Type__c == 'Work_Order__c'){
                        
                            if
                            (color.Status__c == 'All' || color.Status__c == cmp.Status__c)
                            {
                                if(backColor == ''){
                                    backColor = color.Back_Color__c;
                                }
                                if(textColor == ''){
                                    textColor = color.Text_Color__c;
                                }
                            }
                        }
                    }
                }
            }
        }                
               
        if(backColor == ''){              
  
            Integer rand = Math.round(Math.random()*10);
            if(randomColorsMap.containsKey(Math.mod(rand, 10)))
            {
                backColor = randomColorsMap.get(Math.mod(rand, 10));
            }
        }

        if(textColor == ''){              
  
            textColor = 'White';
        }
    }
   
    Public PageReference updateEvent(){
        render = false;
        system.debug(eventMap);
         if(newResourceId != null && currentEventId != null && newStartTime != null && newEndTime != null){
             if(newResourceId.contains('Van')){
                if(eventMap.containsKey(currentEventId)){
                    render = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You can\'t assign an Event to a Van.Please reload the page.'));
                    return null;
                }
                if(taskMap.containsKey(currentEventId)){
                    render = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You can\'t assign a Task to a Van.Please reload the page.'));
                    return null;
                }
                if(workOrderMap.containsKey(currentEventId)){
                    render = false;
                    Work_Order__c currentworkOrder = workOrderMap.get(currentEventId);
                    if(currentworkOrder != null && currentworkOrder.Id != null){

                        if(!Schema.sObjectType.Work_Order__c.fields.Start_Time__c.isUpdateable()
                        || !Schema.sObjectType.Work_Order__c.fields.Van_Assignment__c.isUpdateable()){

                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access to update Work Order.'));
                            return null;
                        }
                        currentworkOrder.Start_Time__c = DateTime.valueOf(newStartTime);
                        currentworkOrder.End_Time__c = DateTime.valueOf(newEndTime);
                        currentworkOrder.Van_Assignment__c = newResourceId;
                        update currentworkOrder;
                    }
                }
            }
            else{
            if(workOrderMap.containsKey(currentEventId)){
                render = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You can\'t assign a Work Order to a User.Please reload the page.'));
                return null;
            }
            if(eventMap.containsKey(currentEventId)){
                render = false;
                Event currentEvent = eventMap.get(currentEventId);
                if(currentEvent != null && currentEvent.Id != null && currentEvent.IsAllDayEvent == false){
  
                    if(!Schema.sObjectType.Event.fields.StartDateTime.isUpdateable()
                    || !Schema.sObjectType.Event.fields.EndDateTime.isUpdateable()
                    || !Schema.sObjectType.Event.fields.OwnerId.isUpdateable()){
                    
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access to update Event.'));
                      return null;
                    } 
                    currentEvent.StartDateTime = DateTime.valueOf(newStartTime);
                    currentEvent.EndDateTime =  DateTime.valueOf(newEndTime);
                    currentEvent.OwnerId = newResourceId;
                    currentEvent.ActivityDateTime = currentEvent.StartDateTime;                   
                    
                    Long dt1Long = currentEvent.StartDateTime.getTime();
                    Long dt2Long = currentEvent.EndDateTime.getTime();
                    Long milliseconds = dt2Long - dt1Long;
                    Long seconds = milliseconds / 1000;
                    Long minutes = seconds / 60;
                    currentEvent.DurationInMinutes = integer.valueOf(minutes);
                    
                    update currentEvent;
                }else{
                List<String> strLst =newEndTime.split(' ');
                List<String> strLst1 =strLst[0].split('-'); 
                List<String> strtDateList = newStartTime.split(' ');
                List<String> strtDateList1 = strtDateList[0].split('-');
                    currentEvent.EndDateTime = DateTime.newInstanceGMT(Integer.valueOf(strLst1[0]), Integer.valueOf(strLst1[1]), Integer.valueOf(strLst1[2]), 0, 0, 0);
                    
                    currentEvent.StartDateTime = DateTime.newInstanceGMT(Integer.valueOf(strtDateList1[0]), Integer.valueOf(strtDateList1[1]), Integer.valueOf(strtDateList1[2]), 0, 0, 0);
                    currentEvent.ActivityDate = Date.newInstance(Integer.valueOf(strtDateList1[0]), Integer.valueOf(strtDateList1[1]), Integer.valueOf(strtDateList1[2]));
                    currentEvent.IsAllDayEvent = true;
                    Date allDayStartDate = date.valueof(newStartTime);
                    Date allDayEndDate = Date.valueof(newEndTime);
                    
                    currentEvent.OwnerId = newResourceId;
                    Integer dayCount = allDayStartDate.daysBetween(allDayEndDate );
                    dayCount++;
                    if(dayCount == 0){
                        currentEvent.DurationInMinutes = 1440 ;
                    }else{
                        currentEvent.DurationInMinutes = Integer.valueOf(dayCount*1440);
                    }
                    system.debug(currentEvent);
                    update currentEvent;
                }
            }
            else if(taskMap.containsKey(currentEventId)){
                render = false;
                Task currentTask = taskMap.get(currentEventId);
                if(currentTask != null && currentTask.Id != null){
                    
                    if(!Schema.sObjectType.Task.fields.ReminderDateTime.isUpdateable()
                    || !Schema.sObjectType.Task.fields.ActivityDate.isUpdateable()
                    || !Schema.sObjectType.Task.fields.OwnerId.isUpdateable()){
                    
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access to update Task.'));
                      return null;
                    } 
                    
                    currentTask.ReminderDateTime = DateTime.valueOf(newStartTime);
                    currentTask.ActivityDate =  Date.valueOf(newStartTime);
                    currentTask.OwnerId = newResourceId;
                    update currentTask;
                }
            }
        }   
        }
        getCalendarData();
        return null;
    }
    
    public List<SelectOption> getObjectOptions()
    {
        List<SelectOption> availableObjectOptions = new List<SelectOption>();
        List<Calendar_Objects__c> listOfObjects = [select id ,API_Name__c,Name from Calendar_Objects__c];
        
        availableObjectOptions.add(new selectOption('All', 'All'));
        for(Calendar_Objects__c obj : listOfObjects ){
            availableObjectOptions.add(new selectOption(obj.API_Name__c, obj.Name));
        }
        return availableObjectOptions;
    }
    
    public List<SelectOption> getAvailableViews()
    {
        List<SelectOption> availableViews = new List<SelectOption>();
        
        availableViews.add(new selectOption('agendaDay', 'Day'));
        availableViews.add(new selectOption('agendaWeek', 'Week'));
        availableViews.add(new selectOption('month', 'Month'));
        
        return availableViews;
    }
    
    public List<SelectOption> getCalendarVans() {
		Map<String,String> VanMap = new Map<String,String>();              
        List<SelectOption> CalendarVans = new List<SelectOption>();
        CalendarVans.add(new selectOption('All', 'All'));
        Schema.DescribeFieldResult fieldResult = Work_Order__c.Van_assignment__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry pickListVal : ple){
			VanMap.put(pickListVal.getValue(),pickListVal.getValue());
		}    
        /*//List<Work_Order__c> vanList = [SELECT Id,Van_assignment__c FROM Work_Order__c];
        List<Work_Order__c> vanList=new List<Work_Order__c>();
        if(vanList != null && vanList.size()>0){
            for(Work_Order__c w : vanList){
                if(w.Van_assignment__c != null && w.Van_assignment__c != ''){
                    //VanMap.put(w.Van_assignment__c , w.Van_assignment__c );
                }
            }*/
            if(VanMap != null && VanMap.size()>0){
                for(String van : VanMap.keyset()){
                    if(VanMap.containsKey(van)){
                        CalendarVans.add(new selectOption(van,VanMap.get(van))); 
                    } 
                }
            }
        //}
        
        return CalendarVans;
    }
    
     public List<SelectOption> getCalendarUsers() {
         system.debug('get cal user');
        Id LoggedInUserAccID;
         List<SelectOption> CalendarUsers = new List<SelectOption>();
         List<SelectOption> CommunityUsers = new List<SelectOption>();
        
        List<User> userList = [SELECT Id,usertype, Name, Profile.UserLicense.Name,Profile.Name,AccountId FROM User WHERE
                                IsActive = true LIMIT 999];
        
         system.debug('profile franchise = '+prof);
        ID contactId = [Select ContactId from User where id =: Userinfo.getUserid()].contactId;
        if(contactId != null){
            LoggedInUserAccID = [Select AccountID from Contact where id =: contactId].AccountId;
        }
        CalendarUsers.add(new selectOption('None', 'None'));
        CommunityUsers.add(new selectOption('None', 'None'));        
         
        for(User usr : userList){
            //prepare List of community users (Franchise Community only)
            if(LoggedInUserAccID == usr.AccountId && usr.Profile.Name =='Franchise Partner Community' ){
                CommunityUsers.add(new selectOption(usr.Id,usr.Name));
                CommunityUserIdSet.add(usr.id);
            }
            else if(usr.UserType =='Standard' || usr.Profile.Name =='Field Crew Partner' || usr.Profile.Name =='Customer Community User - Custom'){
                CalendarUsers.add(new selectOption(usr.Id,usr.Name));
                CalendarUserIdSet.add(usr.id);
            }
        }
         system.debug('CalendarUserIdSet = '+CalendarUserIdSet +'comm user set= '+CommunityUsers);
        if(prof[0].id == UserInfo.getProfileId()){
            system.debug('prof . get id'+prof);
            commUser = true;
            system.debug('returned Community Users');
            return CommunityUsers;        
        }else{
        system.debug('returned all Users');
        commUser = false;
            system.debug('Users>>'+CalendarUsers);
            return CalendarUsers;
        }
    }
    
    public static Boolean getSalesforce1(){
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
        String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
        ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
        (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone')))
        {
            return true;
        }
        else{
            return false;
        }
    }
}