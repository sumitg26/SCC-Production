public with sharing class Calendar_Colors_Controller{
    
    Public List<ColorRows> colorRowsList {get;set;}
    Public List<SelectOption> typeOptions {get; set;}
    Public List<SelectOption> objectOptions {get; set;}
    Public List<SelectOption> statusOptions {get; set;}
    Public List<SelectOption> subjectOptions {get; set;}
    Public Integer selectedColorRow {get; set;} 
    Public Map<Id, Calendar_Colors__c> calendarColors {get; set;}
    Public Id currentUserId {get; set;}
    Public List<SelectOption> vanOptions{get;set;}
    Public List<SelectOption> userOptions{get;set;}
   
    public Calendar_Colors_Controller(){
        
        currentUserId = UserInfo.getUserId();
        colorRowsList = new List<ColorRows>();
        vanOptionsSelectList();
        userOptionsSelectList();          
        typeOptionsSelectList();
        objectOptionsSelectList();
        getCurrentCalColor();
    }
    
    Public void getCurrentCalColor()
    {
        calendarColors = new Map<Id, Calendar_Colors__c>([Select Id, Name, Back_Color__c, Order__c, Text_Color__c, Object__c, Status__c, Type__c, 
        User__c, Selected_Van__c,Selected_User__c, Van_Based__c,User_Based__c,Subject__c From Calendar_Colors__c]);
        
        if(calendarColors != null && calendarColors.size() > 0){
            for(Calendar_Colors__c calCol : calendarColors.Values())
            {
                ColorRows row = new ColorRows();
                row.sequence = calCol.Order__c;
                row.selectedType = calCol.Type__c;  
                row.selectedObject = calCol.Object__c;
                row.selectedStatus = calCol.Status__c;
                row.selectedSubject = calCol.Subject__c;
                row.backColor = calCol.Back_Color__c;
                row.textColor = calCol.Text_Color__c;
                row.typeOption = typeOptions; 
                row.objectOption = objectOptions;
                row.statusOption = statusOptions;
                row.subjectOption = subjectOptions;
                row.vanOption = vanOptions;
                row.userOption = userOptions;
                row.vanEnabled = calCol.Van_Based__c ;
                row.selectedVan = calCol.Selected_Van__c;
                row.selectedUser = calCol.Selected_User__c;
                colorRowsList.add(row);
            } 
            displayUpdatedStatus();
        }
        else 
        {
            addRows();
        }
    }
   
    public Void typeOptionsSelectList()
    {
        typeOptions = new List<SelectOption>();
        typeOptions.add(new SelectOption('All', 'All'));
        typeOptions.add(new SelectOption('Work_Order__c', 'Work Order'));
        typeOptions.add(new SelectOption('Event', 'Event'));
        typeOptions.add(new SelectOption('Task', 'Task'));
    }
    
    public Void vanOptionsSelectList()
    {
        vanOptions = new List<SelectOption>();
    
        List<Work_Order__c> userList = [SELECT Id,Van_assignment__c FROM Work_Order__c];
        
        Map<String,String> VanMap = new Map<String,String>();
        
        vanOptions.add(new selectOption('All', 'All'));         
        
        for(Work_Order__c usr : userList){
            if(usr.Van_assignment__c != null && usr.Van_assignment__c != ''){
                VanMap.put(usr.Van_assignment__c , usr.Van_assignment__c );
            }
        }
        
        if(VanMap != null && VanMap.size()>0){
            for(String van : VanMap.keyset()){
                vanOptions.add(new selectOption(van,VanMap.get(van)));  
            }
        }
    }
    
    public Void userOptionsSelectList()
    {
        userOptions = new List<SelectOption>();
        List<User> allUsers = [SELECT Id, Name, Profile.UserLicense.Name FROM User Where IsActive = true limit 999];        
     
        userOptions.add(new SelectOption('','--Select--'));
        for(User u:allUsers){
            userOptions.add(new SelectOption(u.Id,u.Name));
        }  
    }
    
    public Void objectOptionsSelectList()
    {
        List<Calendar_Objects__c> calObjectsList = [select id ,API_Name__c,Name from Calendar_Objects__c];
        
        objectOptions = new List<SelectOption>();
        objectOptions.add(new SelectOption('All', 'All'));
        
        if (calObjectsList != null && calObjectsList.size() > 0) 
        {
            for(Calendar_Objects__c calObj : calObjectsList)
            {
                objectOptions.add(new SelectOption(calObj.API_Name__c, calObj.Name));
            }
        }
    }
    
    public PageReference displayUpdatedStatus()
    {
        List<ColorRows> tempcolorRowsList = new List<ColorRows>();
        List<Schema.PicklistEntry> ple = new List<Schema.PicklistEntry>();
         
        for(ColorRows row : colorRowsList)
        {
            statusOptions = new List<selectOption>();
            subjectOptions = new List<selectOption>();
            if(row.selectedType == 'Task'){
               subjectOptions.add(new SelectOption('All', 'All'));
               row.subjectOption = subjectOptions;
               statusOptions.add(new SelectOption('All', 'All'));
               Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
               ple = fieldResult.getPicklistValues();
                    
            }  
            else if(row.selectedType == 'Work_Order__c'){
                subjectOptions.add(new SelectOption('All', 'All'));
                row.subjectOption = subjectOptions;
                statusOptions.add(new SelectOption('All', 'All'));
                Schema.DescribeFieldResult fieldResult = Work_Order__c.Status__c.getDescribe();
                ple = fieldResult.getPicklistValues();
                row.selectedObject = 'All';
            }
            else if(row.selectedType == 'Event'){                
                statusOptions.add(new SelectOption('All', 'All'));
                row.statusOption = statusOptions;
                subjectOptions.add(new SelectOption('All', 'All'));
                Schema.DescribeFieldResult fieldResult = Event.Subject.getDescribe();
                ple = fieldResult.getPicklistValues();
            } 
            else{                
                statusOptions.add(new SelectOption('All', 'All'));
                row.statusOption = statusOptions;
                subjectOptions.add(new SelectOption('All', 'All'));
                row.subjectOption = subjectOptions;
                row.selectedStatus = 'All';
                row.selectedSubject = 'All';
                row.selectedObject = 'All';
            } 
            
            for(Schema.PicklistEntry f : ple)
            {
              statusOptions.add(new SelectOption(f.getValue(), f.getLabel()));
              row.statusOption = statusOptions;
              subjectOptions.add(new SelectOption(f.getValue(), f.getLabel()));
              row.subjectOption = subjectOptions;
            }     

            tempcolorRowsList.add(row);                      
        }
        
        colorRowsList = tempcolorRowsList;        
        return null;
    }    
     
    Public PageReference addRows(){
        
        ColorRows row = new ColorRows();
        row.sequence = colorRowsList.size() + 1; 
        row.typeOption = typeOptions; 
        row.objectOption = objectOptions;
        row.statusOption = statusOptions;
        row.subjectOption = subjectOptions;
        row.backColor = '';
        row.vanEnabled = false;
        row.userEnabled = false;
        row.vanOption = vanOptions;
        row.userOption = userOptions;
        colorRowsList.add(row);
        return null;
    } 
    
    Public PageReference deleteSelectedRows(){
        
        List<ColorRows> tempList = new List<ColorRows>();
        
        Integer sequence = 1;
        system.debug(selectedColorRow);
        system.debug(colorRowsList);
        for(ColorRows row : colorRowsList){
            if(row.Sequence != selectedColorRow){
            system.debug('hi');
                row.Sequence = sequence;
                tempList.add(row);
                sequence++;            
            }
        }
        
        if(tempList.size() > 0)
        {
            colorRowsList = tempList;
        }
        else{
            colorRowsList = new List<ColorRows>();
        }
        
        return null;
    }
    
    Public PageReference Save(){
        
        List<Calendar_Colors__c> calColorInsertList = new List<Calendar_Colors__c>();
        List<Calendar_Colors__c> toBeDeletedCalColorList = [Select Id,Selected_Van__c,Selected_User__c From Calendar_Colors__c];
        
        Integer Index = 1;
        for(ColorRows row : colorRowsList)
        {
            Calendar_Colors__c calColor = new Calendar_Colors__c(); 
            
            if(row.vanEnabled){
                calColor.Name = 'ColorCode-' + row.selectedVan + '-' + string.valueOf(index);
                if(row.selectedVan == '' || row.selectedVan == null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please select a Van.'));
                    return null;
                }
                else{
                    calColor.Van_Based__c = row.vanEnabled;
                    calColor.Selected_Van__c = row.selectedVan;
                }
            }
            else{
                calColor.Name = 'ColorCode-' + row.selectedObject + '-' + string.valueOf(index);
                calColor.Type__c = row.selectedType;
                calColor.Status__c = row.selectedStatus;
                calColor.Subject__c = row.selectedSubject;
                calColor.Object__c = row.selectedObject;
                calColor.Selected_Van__c = row.selectedObject;
            }   
            
            if(row.userEnabled){
                calColor.Name = 'ColorCode-' + row.selectedUser + '-' + string.valueOf(index);
                if(row.selectedUser == '' || row.selectedUser == null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please select a User.'));
                    return null;
                }
                else{
                    calColor.User_Based__c = row.userEnabled;
                    calColor.Selected_User__c = row.selectedUser;
                }
            }
            else{
                calColor.Name = 'ColorCode-' + row.selectedObject + '-' + string.valueOf(index);
                calColor.Type__c = row.selectedType;
                calColor.Status__c = row.selectedStatus;
                calColor.Subject__c = row.selectedSubject;
                calColor.Object__c = row.selectedObject;
                calColor.Selected_User__c = row.selectedObject;
            }          
           
            calColor.Back_Color__c = '#' + row.backColor;
            calColor.Text_Color__c = '#' + row.textColor;  
            calColor.Order__c = row.sequence;          
                
            calColorInsertList.add(calColor);
            index++;
       }              
        
       if(calColorInsertList != null && calColorInsertList.size() > 0)
       {
           if(toBeDeletedCalColorList != null && toBeDeletedCalColorList.size() > 0){
                try{
                    delete toBeDeletedCalColorList;
                }
                catch(Exception e){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
                    return null;
                }
           } 
              
           insert calColorInsertList; 
       }
       
       return null;
    }
    
    public void disableVanCheckBox(){
        if(selectedColorRow != null && colorRowsList!= null && colorRowsList.size()>0){
            if(colorRowsList[selectedColorRow-1].userEnabled == true){
                if(colorRowsList[selectedColorRow-1].vanEnabled == true){
                    colorRowsList[selectedColorRow-1].vanEnabled = false;
                }
            }
        } 
    }
    
    public void disableUserCheckBox(){     
        if(selectedColorRow != null && colorRowsList!= null && colorRowsList.size()>0){  
            if(colorRowsList[selectedColorRow-1].vanEnabled == true){
                if(colorRowsList[selectedColorRow-1].userEnabled == true){
                    colorRowsList[selectedColorRow-1].userEnabled = false;
                }
            }
        }
    }
     
    Public Class ColorRows{
        
        Public Decimal sequence {get; set;}
        Public List<SelectOption> objectOption {get; set;} 
        Public List<SelectOption> typeOption {get; set;}
        Public List<SelectOption> statusOption {get; set;}
        Public List<SelectOption> subjectOption {get; set;}
        Public List<SelectOption> userOption {get; set;}
        Public List<SelectOption> vanOption {get; set;}
        Public string selectedType {get; set;}
        Public string selectedObject {get; set;}
        Public string selectedStatus {get; set;}
        Public string selectedSubject {get; set;}
        Public string selectedVan{get;set;}
        Public string selectedUser{get;set;}
        Public string backColor {get; set;}
        Public string textColor {get; set;}
        Public boolean vanEnabled{get;set;}
        Public boolean userEnabled{get;set;}
        Public ColorRows(){          
           
        }      
    }
}