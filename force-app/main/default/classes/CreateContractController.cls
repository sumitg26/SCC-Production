public class CreateContractController{

    public Id AccId {get; set;}
    public List<Contact> AllContactsList {get;set;}
    public List<Smart_Agreement_Template__c> SmartTemplateList {get;set;}
    Public Account Acc {get;set;}
    public Account AccSignObj {get;set;}
    public List<SelectOption> contactsList {get;set;}
    public String[] selectedContacts{get;set;}
    public String selectedTemplate {get;set;}
    public String updatedTemplateLine {get;set;}
    //variables to populate email fields field --- added by Nitesh Kumar
    public OrgWideEmailAddress owa {get;set;}
    public String selectedFromEmail {get;set;}
    public String ToEmail{get;set;}
    public String ccEmails{get;set;}
    public String bccEmails{get;set;}
    public String whoId;
    Public String recId;
    public String templateBody{get;set;}
    public String templateSubject{get;set;}
    public String templateId;
    
    //For selected Email template and its meta data types list
    public String selectedEmailTemplate{get;set;}
    public List<Contract_Email_Template__mdt> ContractEmailTemplateList {get;set;}
    // To show service provider details
    Public User userObj;
    public List<User> userList = new List<User>();
    
    
    public CreateContractController(ApexPages.StandardController stdController){
        //updatedTemplateLine ='';
        acc = (Account)stdController.getRecord();
        AllContactsList = new List<Contact>();
        SmartTemplateList = new List<Smart_Agreement_Template__c>();
        AccId = ApexPages.currentPage().getParameters().get('id');
        AccSignObj = [SELECT Id,Name,Agreement_Signed_Date__c,Agreement_Signed__c FROM Account WHERE Id =:AccId LIMIT 1];
        userObj = [Select id,Email_Template_Signature__c,Profile.Name,Contract_Template_Signature__c,AccountId from User where Id=:UserInfo.getUserId()];
        if(userObj != null){
            userList = [Select Id from User where accountId=:userObj.AccountId];
            System.debug('User Details '+userObj);
        }
        contactsList = new List<SelectOption>();
        selectedContacts = new String[]{};
        
    }
    public CreateContractController(){
        system.debug('<<<< Custom constructor of Contract>>>>');
        owa = new OrgWideEmailAddress();
        recId = ApexPages.currentPage().getParameters().get('id');
        ToEmail = ApexPages.currentPage().getParameters().get('toEmail');
        whoId = ApexPages.currentPage().getParameters().get('whoId');
        ccEmails = ApexPages.currentPage().getParameters().get('ccEmails');
        bccEmails = ApexPages.currentPage().getParameters().get('bccEmails');
        templateId  = ApexPages.currentPage().getParameters().get('templateId');
        selectedEmailTemplate = templateId;
        
        system.debug('rec id accId? = '+recId);
    }
    //List to fetch all the contacts associated for an account
    public List<SelectOption> getContacts(){
        List<SelectOption> options = new List<SelectOption>();
        if(AccId != null){
            AllContactsList = [select id,Name,AccountId from Contact where AccountId =: AccId];
        }
        if(AllContactsList != null && AllContactsList.size() > 0){
            for(Contact c : AllContactsList){
                options.add(new SelectOption(c.id,c.Name));
            }
        }
        return options;
    }
    //list to show all email templates from custom setting.
    public List<SelectOption> getEmailTemplates(){
        List<SelectOption> temp = new List<SelectOption>();
        ContractEmailTemplateList = [SELECT MasterLabel, Template_Id__c FROM Contract_Email_Template__mdt LIMIT 1000];
        for(Contract_Email_Template__mdt et : ContractEmailTemplateList){
            temp.add(new SelectOption(et.Template_Id__c,et.MasterLabel));
        }
        return temp;
    }
    // to show the title of the Contract
    public List<SelectOption> getTemplates(){
        if(userObj.Profile.Name =='Franchise Partner Community'){
        	SmartTemplateList = [SELECT Id,Name,Agreement_Content__c,Is_Active__c FROM Smart_Agreement_Template__c 
                                 WHERE Is_Active__c=True AND 
                                 OwnerId in :userList LIMIT 10];
        }
        else{
            SmartTemplateList = [SELECT Id,Name,Agreement_Content__c,Is_Active__c FROM Smart_Agreement_Template__c WHERE Is_Active__c=True 
                                 AND OwnerId IN (Select Id from User where UserType = 'Standard') LIMIT 10];
        }
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('None','None'));
            for(Smart_Agreement_Template__c temp : SmartTemplateList){
                options.add(new SelectOption(temp.id,temp.Name));
            }
        return options;
    }
    //to get the Org wide email address and logged in user email -- added by Nitesh Kumar
    public List<SelectOption> getOrgwideAddress(){
        List<SelectOption> em = new List<SelectOption>();
        owa = [select id, Address, DisplayName from OrgWideEmailAddress LIMIT 1];
        em.add(new SelectOption(UserInfo.getUserId(),UserInfo.getName()));
        em.add(new SelectOption(owa.id,owa.DisplayName));
        return em;
    }
    //FOR SMART Agreement contract Template on change
    public void onChangeTemplate(){
        if(selectedTemplate!= '' && selectedTemplate != null){
        
        //Querying all the fields on Account
            String SobjectApiName = 'Account';
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            
            String commaSepratedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(commaSepratedFields == null || commaSepratedFields == ''){
                    commaSepratedFields = fieldName;
                }else{
                    commaSepratedFields = commaSepratedFields + ', ' + fieldName;
                }
            }
            
            //Additional Fields
            commaSepratedFields += '';
            
            //Query Formation
            String query = 'SELECT ' + commaSepratedFields + ' FROM ' + SobjectApiName + ' WHERE Id=:AccId LIMIT 1';
            system.debug('query='+query);
            //Querying from the database
            sObject AccRecord = Database.query(query);
            
            String templateName = String.valueOf(AccRecord.get('Contract_Template_Name__c'));
            system.debug('templateName ='+templateName);
    
    
            List<Smart_Agreement_Template__c> sat = [Select Id,Agreement_Content__c FROM Smart_Agreement_Template__c  WHERE Id =:selectedTemplate];
            
            for(Smart_Agreement_Template__c templateLine: sat){
                    updatedTemplateLine = '';
                    if(templateLine.Agreement_Content__c.containsIgnoreCase('[[')){ //If the template lines contains any merge field or not.
                        List<String> splittedByBracket = templateLine.Agreement_Content__c .split(']]'); //All the sentences with merge fields are separated.
                        system.debug('splittedByBracket='+splittedByBracket);
                        for(String s: splittedByBracket){
                            //Check if the sentence contains any merge field
                            if(s.stripHtmlTags().contains('[[')){
                                String keyword = s.stripHtmlTags().substringAfterLast('[['); // Extracting the merge field name from the sentence.
                                system.debug('keyword='+keyword);
                                Map<String, Merge_Fields_Mapping__c> mapCS = Merge_Fields_Mapping__c.getAll(); //Create a map of all the CS Values
                                system.debug('mapCS.keySet='+mapCS.keySet());
                                if(mapCS.keySet().contains(keyword)){
                                    //Get the field name from custom setting
                                    system.debug('keyword found in cs');
                                    String apiName = mapCS.get(keyword).Field_API_Name__c;
                                    System.debug('api name in cs='+apiName);
                                    String fieldValue = '';
                                    
                                    //If the merge field is a parent field
                                    if(apiName.contains('.')){
                                        List<String> apiNameSplit = apiName.split('\\.');
                                        if(apiNameSplit.size() == 2){
                                            fieldValue = String.valueOf(AccRecord.getsObject(apiNameSplit[0]).get(apiNameSplit[1]));
                                            system.debug('fieldValue 2='+fieldValue);
                                        }
                                        else if(apiNameSplit.size() == 3){
                                            fieldValue = String.valueOf(AccRecord.getsObject(apiNameSplit[0]).getsObject(apiNameSplit[1]).get(apiNameSplit[2]));
                                           system.debug('fieldValue 3='+fieldValue);
                                        }
                                        else if(apiNameSplit.size() == 4){
                                            fieldValue = String.valueOf(AccRecord.getsObject(apiNameSplit[0]).getsObject(apiNameSplit[1]).getsObject(apiNameSplit[2]).get(apiNameSplit[3]));
                                            system.debug('fieldValue 4='+fieldValue);
                                        }
                                        else if(apiNameSplit.size() == 5){
                                            fieldValue = String.valueOf(AccRecord.getsObject(apiNameSplit[0]).getsObject(apiNameSplit[1]).getsObject(apiNameSplit[2]).getsObject(apiNameSplit[3]).get(apiNameSplit[4]));
                                        }
                                    }
                                    //If the merge field is on Account level
                                    else{
                                        fieldValue = String.valueOf(AccRecord.get(apiName));
                                    }
                                    
                                    if(AccRecord !=null && fieldValue!=null){
                                        //Replace the keyword with the actual value in the sentence
                                        s = s.replace(keyword, fieldValue);
                                        
                                        //Replace the opening braces with blank value for proper formatting
                                        s = s.replace('[[','');
                                    }
                                }
                            }
                            if(s.containsIgnoreCase('{{Agreement Signed Date }}')){ //If the template lines contains sig text.
                                String str='';
                                if(AccSignObj.Agreement_Signed_Date__c == null)
                                    str = string.valueof(system.today().format());
                                else
                                    str = AccSignObj.Agreement_Signed_Date__c.format();
                                s= s.replace('{{Agreement Signed Date }}', str);
                                
                                system.debug('templateLine  >> '+s);
                            }
                            //Rejoin all the split sentences to form one template Line
                            updatedTemplateLine += s;
                        }
                    }
    
            }
        }
    }
    //send contract
    public PageReference sendContract(){
        
        if(selectedTemplate == 'None'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select the Template to proceed!!'));
            return null;
        }
        
        system.debug(selectedContacts);
        
        if(selectedContacts.size()==0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select atleast one contact to proceed!!'));
            return null;
        } 
        
        String emailaddress = '';
        
        Set<String> selConId = new Set<String>();
        for(String s : selectedContacts){
            selConId.add(s);    
        }
        
        List<Contact> con = new List<Contact>();
        if(selConId != null && selConId.size()>0){
            con = [select id,email from Contact where Id IN: selConId];
        }
        
        List<Contact> tempList = new List<Contact>();
        for(Integer i =1;i<con.size();i++){
            tempList.add(con[i]);
        }        
        for(Contact c : tempList){
            emailaddress = emailaddress + c.Email + ',';
        }
        EmailTemplate email = [select id,Name from EmailTemplate where Name = 'Interval Cleaning Contract'];
        String sscAddress;// = label.GabbyEmailAddress;
        acc.Contract_Template_Name__c = selectedTemplate ;
        if(userObj.Profile.Name =='Franchise Partner Community'){
            String UserId = UserInfo.getUserId();
            acc.Contract_Resource__c = 'User'+UserId.substring(0, 15);
            Account franchiseAccount = [Select Owner.Email from Account where id =: AccId];
            if(franchiseAccount != null){
                sscAddress = franchiseAccount.Owner.Email;
            }
        }else{
            acc.Contract_Resource__c = 'GMSignature';
            sscAddress = label.GabbyEmailAddress;
        }
        acc.Service_Provider_Guest__c = userObj.Contract_Template_Signature__c;
        update acc;
        PageReference pageRef;
        if(UserInfo.getUserType() == 'Standard'){
            pageRef = new PageReference('/_ui/core/email/author/EmailAuthor?template_id='+email.id+'&retURL=/'+ AccId+ '&p2_lkid=' + con[0].id + '&p24=' + emailaddress + '&p5=' + sscAddress + '&p3_lkid=' + AccId+ '&saveURL=%2F' + AccId);
        }else if(UserInfo.getUserType() =='PowerPartner'){ //PowerPartner
            system.debug('Power Partner');
            pageRef = new PageReference('/apex/SendContractInvoice?id='+AccId+'&toEmail='+con[0].Email+'&ccEmails='+emailaddress+'&bccEmails='+sscAddress+'&templateId='+email.id+'&whoId='+con[0].Id);
        }
        return pageRef;    
    }
    public void prepareEmail(){
        Messaging.SingleEmailMessage se = Messaging.renderStoredEmailTemplate(templateId,whoId , AccId);
        templateBody = se.getHtmlBody();
        templateSubject = se.getSubject();
    }
    public pagereference onChangePrepareEmail(){
        Messaging.SingleEmailMessage se = Messaging.renderStoredEmailTemplate(selectedEmailTemplate,whoId , recId);
        templateBody = se.getHtmlBody();
        templateSubject = se.getSubject();
        return null;
    }
    
    //--- added by Nitesh Kumar
    public pageReference sendInvoiceEmail(){
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(selectedFromEmail == owa.id){
          message.setOrgWideEmailAddressId(selectedFromEmail); // From email or Org wide email  
        }
        
        message.setToAddresses(new String[] {toEmail}); // set To addr
        if(ccemails !='' && ccemails != null){
            List<String> ccList = ccemails.split(',');
            String[] ccArray = ccList;
            message.setccaddresses(ccArray); //set CC emails
        }
        if(bccemails != '' && bccemails != null){
            message.setBccAddresses(new List<String>{bccemails});
        }
        message.setHtmlBody(templateBody);//set html body
        message.setSubject(templateSubject); // set subject
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        // create email activity
        EmailMessage em = new EmailMessage();
        em.relatedToId = recId;
        em.Status = '3'; // status as sent
        em.toIds = new String[] {whoId};
        em.toAddress =  ToEmail;
       if(selectedFromEmail != owa.id){
            em.fromAddress = userInfo.getUserEmail() ; //from address of the current logged in user
            em.fromName = UserInfo.getName(); 
        }else{
            em.fromAddress = owa.Address ; // from address of the org wide address
            em.fromName = owa.DisplayName; // from name
        } 
        em.subject = templateSubject; // email subject
        em.htmlBody = templateBody;
        insert em;
        system.debug('em = '+em);
        PageReference pg = new PageReference('/'+recId);
        system.debug('pg = '+pg);
        return pg;
    }
    public PageReference Cancel(){
        PageReference pageRef = new PageReference('/'+recId);
        return pageRef;
    }
    public PageReference SendContractCancel(){
        PageReference pageRef = new PageReference('/'+accId);
        return pageRef;
    }
}