public with sharing class Calendar_Settings {  

    public SelectOption[] selectedCampaignFields {get; set;}
    public SelectOption[] allCampaignFields {get; set;}
    
    public SelectOption[] selectedEventFields {get; set;}
    public SelectOption[] allEventFields {get; set;}
    
    public SelectOption[] selectedTaskFields {get; set;}
    public SelectOption[] allTaskFields {get; set;}
    
    Public List<ObjectSetting> timeSlateProSettings {get; set;}
    public string selectedObjName {get; set;}
    
    public Map<string, string> availableObjects {get; set;}
    public Map<String,String> selectedValuesMap;
    public Map<String,String> valueIndexMap;
    public Set<String> selectedValueSetEvent;
    public Set<String> selectedValueSetTask;
    public Set<String> selectedValueSetCampaign;
    
    Public List<Calendar_Event_Fields__c> eventLst = new List<Calendar_Event_Fields__c>();
    List<Calendar_Event_Fields__c> eventList;
    List<Calendar_Event_Fields__c> campaignList;
    List<Calendar_Event_Fields__c> taskList;
    
    public Calendar_Settings(){
    
        selectedEventFields = new List<SelectOption>();
        selectedCampaignFields = new List<SelectOption>();
        selectedTaskFields = new List<SelectOption>();
        getAvailableEventValues();
        getAvailableTaskValues();
        getAvailableCampaignValues();
        getCampaignFields();
        getTaskFields();
        getEventFields();
        getAvailableObjects();
    }
    
    public void getSelectedValues(){
    
        List<String> selectedvaluesList = new List<String>();
        List<String> valueIndexPairList = new List<String>();
        selectedValuesMap = new Map<String,string>();
        valueIndexMap = new Map<String,string>();
        
        string selectedvalues = ApexPages.currentPage().getParameters().get('userSelectedValuesParam');
        string valueIndexPair =  ApexPages.currentPage().getParameters().get('userSelectedValuesParamSecond');
        
        if(selectedvalues != '' && selectedvalues !=null){
            selectedvaluesList  = selectedValues.split(',');
            system.debug('###values'+selectedvalues);
            system.debug('###values1'+selectedvaluesList);
            
            for(String s:selectedvaluesList){
                if(!selectedValuesMap.containsKey(s.split(':')[1].trim())){
                    selectedValuesMap.put(s.split(':')[1].trim(),s.split(':')[0].trim());
                }
            }
        }

        if(valueIndexPair !='' && valueIndexPair!=null){
            valueIndexPairList = valueIndexPair.split(',');
        }

        for(String vIndex:valueIndexPairList){
            if(!valueIndexMap.containsKey(vIndex.split(':')[0].trim())){
                valueIndexMap.put(vIndex.split(':')[0].trim(),vIndex.split(':')[1].trim());
            }
        }
    }
    public PageReference toggleSettings() {
        List<Calendar_Objects__c> addressMappingObjects;
        if(Schema.sObjectType.Calendar_Objects__c.fields.Name.isAccessible() &&
            Schema.sObjectType.Calendar_Objects__c.fields.API_Name__c.isAccessible()){
            addressMappingObjects = [SELECT Id, Name, API_Name__c FROM Calendar_Objects__c Where API_Name__c =: selectedObjName];
        }
        
        if(addressMappingObjects != null && addressMappingObjects.size() > 0){
            try{
                if(Calendar_Objects__c.sObjectType.getDescribe().isDeletable()){
                    delete addressMappingObjects;
                }
            }
            catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
                return null;
            }
        }
        
        if(addressMappingObjects == null || addressMappingObjects.size() == 0){
            if(availableObjects.containsKey(selectedObjName)){
                Calendar_Objects__c newAddressMappingObject = new Calendar_Objects__c();
                if(Schema.sObjectType.Calendar_Objects__c.fields.Name.isCreateable()){
                    newAddressMappingObject.Name = availableObjects.get(selectedObjName);
                }

                if(Schema.sObjectType.Calendar_Objects__c.fields.Name.isCreateable()){
                    newAddressMappingObject.API_Name__c = selectedObjName;
                }

                insert newAddressMappingObject;
            }
        }       
        
        getAvailableObjects();
        return null;
    }
    
    public void getCampaignFields()
    {
        Map <String, Schema.SObjectField> fieldMap= Work_Order__c.sObjectType.getDescribe().fields.getMap();
        allCampaignFields = new List<SelectOption>();
        
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            if(!selectedValueSetCampaign.contains(dfield.getName())){
                if(dfield.isAccessible()){
                    if(dfield.getName() != 'Id'){
                        if(dField.isCustom() && dField.getReferenceTo().size() == 0){
                            allCampaignFields.add(new SelectOption(dfield.getName(), dfield.getLabel()));
                        }
                        else if(!dField.isCustom()){
                            allCampaignFields.add(new SelectOption(dfield.getName(), dfield.getLabel()));
                        }
                    }
                }
            }
        }
        allCampaignFields.sort();
    }  
    
    public void getTaskFields()
    {
        Map <String, Schema.SObjectField> fieldMap= Task.sObjectType.getDescribe().fields.getMap();
        allTaskFields = new List<SelectOption>();
        
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            if(!selectedValueSetTask.contains(dfield.getName())){
                if(dfield.isAccessible()){
                    if(dfield.getName() != 'Id'){
                        if(dField.isCustom() && dField.getReferenceTo().size() == 0){
                            allTaskFields.add(new SelectOption(dfield.getName(), dfield.getLabel()));
                        }
                        else if(!dField.isCustom()){
                            allTaskFields.add(new SelectOption(dfield.getName(), dfield.getLabel()));
                        }
                    }
                }
            }
            
        }
    }  

    public void getEventFields()
    {
        Map <String, Schema.SObjectField> fieldMap= Event.sObjectType.getDescribe().fields.getMap();
        allEventFields = new List<SelectOption>();
        
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            if(!selectedValueSetEvent.contains(dfield.getName())){
                if(dfield.isAccessible()){
                    if(dfield.getName() != 'Id'){
                        if(dField.isCustom() && dField.getReferenceTo().size() == 0){
                            allEventFields.add(new SelectOption(dfield.getName(), dfield.getLabel()));
                        }
                        else if(!dField.isCustom()){
                            allEventFields.add(new SelectOption(dfield.getName(), dfield.getLabel()));
                        }
                    }
                }
            }
        }
    }  
    
    public void getAvailableEventValues()
    {
        selectedValueSetEvent = new Set<String>();
        List<Calendar_Event_Fields__c> eventLst;
        try{
            if(Schema.sObjectType.Calendar_Event_Fields__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.API_Name__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Field_Name__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Object__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Order__c.isAccessible()){

                eventLst = [SELECT Id, Name, API_Name__c, Field_Name__c, 
                Object__c, Order__c FROM Calendar_Event_Fields__c where Object__c = 'Event' ORDER BY Order__c ASC limit 500];
            }
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
            return;
        }
            
        if(eventLst != null && eventLst.size() > 0){
            for(Calendar_Event_Fields__c cef : eventLst)
            {
                if(!selectedValueSetEvent.contains(cef.API_Name__c)){
                    selectedValueSetEvent.add(cef.API_Name__c);
                }
                selectedEventFields.add(new SelectOption(cef.API_Name__c, cef.Field_Name__c));
            }
        }
    }  
    public void getAvailableTaskValues()
    {
        selectedValueSetTask = new Set<String>();
        List<Calendar_Event_Fields__c> taskLst;
        try{
            if(Schema.sObjectType.Calendar_Event_Fields__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.API_Name__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Field_Name__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Object__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Order__c.isAccessible()){

                taskLst = [SELECT Id, Name, API_Name__c, Field_Name__c, 
                Object__c, Order__c FROM Calendar_Event_Fields__c where Object__c = 'Task' ORDER BY Order__c ASC limit 500];
            }
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
            return;
        }
            
        if(taskLst != null && taskLst.size() > 0){
            for(Calendar_Event_Fields__c cef : taskLst)
            {
                if(!selectedValueSetTask.contains(cef.API_Name__c)){
                    selectedValueSetTask.add(cef.API_Name__c);
                }
                selectedTaskFields.add(new SelectOption(cef.API_Name__c, cef.Field_Name__c));
            }
        }
    }  
    
    public void getAvailableCampaignValues()
    {
        selectedValueSetCampaign = new Set<String>();
        List<Calendar_Event_Fields__c> campaignLst;
        try{
            if(Schema.sObjectType.Calendar_Event_Fields__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.API_Name__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Field_Name__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Object__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Order__c.isAccessible()){

                campaignLst = [SELECT Id, Name, API_Name__c, Field_Name__c, 
                Object__c, Order__c FROM Calendar_Event_Fields__c where Object__c = 'Work_Order__c' ORDER BY Order__c ASC limit 500];
            }
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
            return;
        }
            
        if(campaignLst != null && campaignLst.size() > 0){
            for(Calendar_Event_Fields__c cef : campaignLst)
            {
                if(!selectedValueSetCampaign.contains(cef.API_Name__c)){
                    selectedValueSetCampaign.add(cef.API_Name__c);
                }
                selectedCampaignFields.add(new SelectOption(cef.API_Name__c, cef.Field_Name__c));
            }
        }
    }  
    
    public PageReference saveEventFields()
    {
        getSelectedValues();

        if(selectedValuesMap.size() > 12){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select less than 12 fields for the display!'));
            return null;
        }
        try{
            if(Schema.sObjectType.Calendar_Event_Fields__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.API_Name__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Field_Name__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Object__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Order__c.isAccessible()){

            eventList = new List<Calendar_Event_Fields__c>([SELECT Id, Name, API_Name__c, Object__c, Order__c, Field_Name__c
            FROM Calendar_Event_Fields__c where Object__c = 'Event' limit 500]);
            }
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
            return null;
        }

        if(eventList != null && eventList.size() > 0)
        {
            System.debug('in if');
            try{
                if(Calendar_Event_Fields__c.sObjectType.getDescribe().isDeletable()){
                    delete eventList;
                }
                eventList.clear();
            }
            catch(Exception e){
                system.debug('##message'+e.getMessage());
            }
        }
        
        createFields('Event');
        return null;
    }    

    public PageReference saveCampaignFields(){
        getSelectedValues();

        if(selectedValuesMap.size() > 12){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select less than 12 fields for the display!'));
            return null;
        }

        try{
            if(Schema.sObjectType.Calendar_Event_Fields__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.API_Name__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Field_Name__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Object__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Order__c.isAccessible()){

            campaignList = new List<Calendar_Event_Fields__c>([SELECT Id, Name, API_Name__c, Object__c, Order__c, Field_Name__c
            FROM Calendar_Event_Fields__c where Object__c = 'Work_Order__c' limit 500]);
            }
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
            return null;
        }

        if(campaignList != null && campaignList.size() > 0){
            System.debug('in if');
            try{
                if(Calendar_Event_Fields__c.sObjectType.getDescribe().isDeletable()){
                    delete campaignList;
                }
                campaignList.clear();
            }
            catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
                return null;
            }
        }
        
        createFields('Work_Order__c');
        return null;
    }    
    
    public PageReference saveTaskFields() {
        getSelectedValues();

        if(selectedValuesMap.size() > 12){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select less than 12 fields for the display!'));
            return null;
        }

        try{
            if(Schema.sObjectType.Calendar_Event_Fields__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.API_Name__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Field_Name__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Object__c.isAccessible() &&
                Schema.sObjectType.Calendar_Event_Fields__c.fields.Order__c.isAccessible()){

            taskList = new List<Calendar_Event_Fields__c>([SELECT Id, Name, API_Name__c, Object__c, Order__c, Field_Name__c
            FROM Calendar_Event_Fields__c where Object__c = 'Task' limit 500]);
            }
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
            return null;
        }

        if(taskList != null && taskList.size() > 0)
        {
            System.debug('in if');
            try{
                if(Calendar_Event_Fields__c.sObjectType.getDescribe().isDeletable()){
                    delete taskList;
                }
                taskList.clear();
            }
            catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
                return null;
            }
        }
        
        createFields('Task');
        return null;
    }

    private List<Calendar_Event_Fields__c> updateList(String objectName){
        system.debug(objectName);
        system.debug('stsrt map'+selectedValuesMap);
        List<Calendar_Event_Fields__c> newList = new List<Calendar_Event_Fields__c>();
        if(selectedValuesMap!= null && selectedValuesMap.size() > 0){
        
            for(String obj : selectedValuesMap.keyset()){ 
            
                Calendar_Event_Fields__c calendarObj = new Calendar_Event_Fields__c();
                calendarObj.Name = objectName + '-' + obj;
                calendarObj.Field_Name__c = selectedValuesMap.get(obj);
                calendarObj.Object__c = objectName;
                calendarObj.API_Name__c = obj;
                calendarObj.Order__c = Integer.valueOf(valueIndexMap.get(obj));
                newList.add(calendarObj);
                if(objectName == 'Task'){
                    selectedTaskFields.add(new Selectoption(obj,selectedValuesMap.get(obj)));
                }
                else if(objectName == 'Event'){
                    selectedEventFields.add(new Selectoption(obj,selectedValuesMap.get(obj)));
                }
                else if(objectName == 'Work_Order__c'){
                system.debug('hi');
                    selectedCampaignFields.add(new Selectoption(obj,selectedValuesMap.get(obj)));
                    system.debug('map'+selectedCampaignFields);
                }
            }
        }
        return newList;
    } 

    public void createFields(String objectName)
    {   
        List<Calendar_Event_Fields__c> newList = new List<Calendar_Event_Fields__c>();
        if(objectName == 'Task'){
            selectedTaskFields.clear();
            if(taskList == null || taskList.size() == 0 ){
                newList = updateList('Task');
            }
        }

        else if(objectName == 'Event'){
            selectedEventFields.clear();
            if(eventList == null || eventList.size() == 0 ){
                newList = updateList('Event');
            }
        }

        else if(objectName == 'Work_Order__c'){
            selectedCampaignFields.clear();
            if(campaignList == null || campaignList.size() == 0 ){
                newList = updateList('Work_Order__c');
            }
        }
                        
        if(newList != null && newList.size() > 0)
        {
            system.debug('##newList'+newList);
            if(selectedValuesMap.size() > 12){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select less than 12 fields for the display!'));
                return;
            }
            insert newList;
            newList.clear();
        } 
    }
    
    private void getAvailableObjects(){
        
        availableObjects = new Map<string, string>();
        Map<string, string> mappingObjects = new Map<string, string>();
        List<Calendar_Objects__c> addressMappingObjects = new List<Calendar_Objects__c>();
        timeSlateProSettings = new List<ObjectSetting>();
        
        try{
            if(Schema.sObjectType.Calendar_Objects__c.fields.Name.isAccessible() &&
                Schema.sObjectType.Calendar_Objects__c.fields.API_Name__c.isAccessible()){
                addressMappingObjects = [SELECT Id, Name, API_Name__c FROM Calendar_Objects__c];
            }
        }

        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
            return;
        }
        
        for(Calendar_Objects__c objMap : addressMappingObjects){
            mappingObjects.put(objMap.API_Name__c, objMap.Name);
        }
        
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values(); 
        
        for(Schema.SObjectType f : Task.WhatId.getDescribe().getReferenceTo())
        {
           availableObjects.put(f.getDescribe().getName(), f.getDescribe().getLabel());
        }
        
        for(Schema.SObjectType f : Event.WhatId.getDescribe().getReferenceTo())
        {
           availableObjects.put(f.getDescribe().getName(), f.getDescribe().getLabel());
        }
        
        for(Schema.SObjectType f : Task.WhoId.getDescribe().getReferenceTo())
        {
           availableObjects.put(f.getDescribe().getName(), f.getDescribe().getLabel());
        } 
        
        for(Schema.SObjectType f : Event.WhoId.getDescribe().getReferenceTo())
        {
           availableObjects.put(f.getDescribe().getName(), f.getDescribe().getLabel());
        }         
        
        for(String str : availableObjects.keySet()){
        
            if(mappingObjects.containsKey(str)){
                ObjectSetting objSet = new ObjectSetting();
                objSet.objectName = availableObjects.get(str);
                objSet.APIName = str;
                objSet.enabled = 'Enabled';                
                timeSlateProSettings.add(objSet);
            }
            else{
                ObjectSetting objSet = new ObjectSetting();
                objSet.objectName = availableObjects.get(str);
                objSet.APIName = str;
                objSet.enabled = 'Disabled';                
                timeSlateProSettings.add(objSet);            
            }
        }
        timeSlateProSettings.sort();
    }    
    
    Public Class ObjectSetting implements Comparable{
        
        Public string objectName {get; set;}
        Public string fieldName {get; set;}
        Public string APIName {get; set;}
        Public string enabled {get; set;}
        
        public ObjectSetting() {}
        
        public Integer compareTo(Object ObjToCompare) {
            return objectName.CompareTo(((ObjectSetting)ObjToCompare).objectName);
        }
    }    
}