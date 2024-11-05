public class CreateInvoiceController{
    public String woId{get;set;}
    public List<Contact> cList{get;set;}
    public String selectedTemplate{get;set;}
    public String selectedMethod{get;set;}
    public Boolean attachment{get;set;}
    public List<Work_Order__c> w{get;set;}
    public Work_Order__c work{get;set;}
    public List<Work_Order_Item__c> witemsList{get;set;}
    Public List<ContentDocumentLink> ContentDocumentLinkList{get;set;}
    public Set<Id> contentIdSet {get;set;}
    public Boolean check{get;set;}
    public Boolean invoiceRadio{get;set;}
    public Boolean otherRadio{get;set;}
    public String discount{get;set;}
    public String tax{get;set;}
    public Decimal taxAmount{get;set;}
    public Decimal subtotal{get;set;}
    public Decimal dis_Amount{get;set;}
    public Decimal balanceDue{get;set;}
    public String woName{get;set;}
    public String dateTimeValue { get; set; }
    
    Private Work_Order__c pageOpp;
    public Boolean initialised{get; set;}
    Date myDate = system.today();
    //Added by Shabana
    public String UserType{get; set;}
    public Boolean ShowEmailTemplate{get;set;}
    public String emailaddress{get;set;}
    public List<WOIWrapper> selectwitemsList{get;set;}
    public boolean isMonthly {get;set;}
    public string month ;
    public string year;
    // Added by Nitesh kkumarr
    public OrgWideEmailAddress owa;
    public String LoggedInUserEmail {get;set;}
    //variables to populate email fields field.
    public String selectedToEmail {get;set;}
    public String ToEmail{get;set;}
    public String ccEmails{get;set;}
    public String whoId;
    public String templateBody{get;set;}
    public String templateSubject{get;set;}
    public String templateId;
    public String documentId;
    public List<String> attchIds;
    public List<Document> DocList{get;set;}
    Public List<Work_Order_Item__c> woiList {get; set;}
    
    //For selected Email template and its meta data types list
    public String selectedEmailTemplate{get;set;}
    public List<Contract_Email_Template__mdt> ContractEmailTemplateList {get;set;}
    public List<SelectOption> selectedContacts{get;set;}
    
    public CreateInvoiceController(ApexPages.StandardController stdController) {
        system.debug('<<<<<<<<<< Standard Constructor Loads >>>>>>');
        month = system.now().format('MMM');
        year = string.valueOf(system.today().year());
        isMonthly = false;
        this.pageOpp = (Work_Order__c)stdController.getRecord();
        woId = ApexPages.currentPage().getParameters().get('id');
        initialised=false;
        otherRadio = false;
        UserType = userinfo.getusertype();
        String CommId = System.Network.getNetworkId();
        selectwitemsList = new List<WOIWrapper>();
        
        ShowEmailTemplate = false;
        system.debug('UserType in constructor = '+UserType);
        
        check = true;
        selectedMethod = 'Email';
        w = [select id,Name, Account_Name__c,Unit_Number_Formula__c,Account__c,Account_Billing_City__c,Account_Billing_State__c,Blacklight_Inspection__c,    
             Account_Billing_Street__c,Account_Billing_Zip_Code__c,Unit_Number__c,Property_Address__c,Property_City__c,Status__c,Invoice_Frequency__c,    
             Property_State__c,Property_Zip_Code__c,Purchase_Order__c,Field_Crew_Start_Time__c,Invoice_Notes__c,Additional_Invoice_Notes__c	 from Work_Order__c where id =: woId];    
        
        List<Work_Order_Item__c> woiList = new List<Work_Order_Item__c>();   
        if(w != null && w.size()>0){
            if(w[0].Invoice_Frequency__c == null || w[0].Invoice_Frequency__c == ''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please setup Invoice Frequency to continue'));
            }
            cList = [select id,Name,AccountId from Contact where AccountId =: w[0].Account_Name__c];    
            if(w[0].Invoice_Frequency__c =='Monthly'){    
                isMonthly = true;    
                woiList = [select id,name, Work_Order__r.Field_Crew_Start_Time__c,Service__c,Service__r.Name,Line_Item_Description__c,Comment__c,Comments__c,Price__c,Work_Order__c,Work_Order__r.Discount_Amount__c,    
                              Work_Order__r.Name,Work_Order__r.Sub_Total__c,Work_Order__r.Balance_Due1__c,Work_Order__r.Discount__c,Work_Order__r.Discount_Percentage__c,Services__c    
                              from Work_Order_Item__c where Work_Order__c =:woId ORDER By CreatedDate];    
            }    
        }    
            
        if(woiList != null && woiList.size()>0){    
                
            for(Work_Order_Item__c woi:woiList){
                WOIWrapper wrap = new WOIWrapper();
                wrap.woi = woi;
                wrap.selected = false;
                selectwitemsList.add(wrap);
            }    
        }    
            
        selectedContacts = new List<SelectOption>();    
            
        if(cList != null && cList.size()>0){    
            for(Contact c : cList){    
                if(c.Name.containsIgnoreCase('invoice')){    
                    selectedContacts.add(new SelectOption(c.id,c.Name));    
                }    
            }    
        }    
    }
    
    public CreateInvoiceController(){
        system.debug('<<<<<<<<<< Custom Constructor Loads >>>>>>');
        month = system.now().format('MMM');
        year = string.valueOf(system.today().year());
        LoggedInUserEmail = UserInfo.getUserEmail();
        owa = new OrgWideEmailAddress();
        UserType = userinfo.getusertype();
        system.debug(UserType);
        woId = ApexPages.currentPage().getParameters().get('id');
        ToEmail = ApexPages.currentPage().getParameters().get('toEmail');
        whoId = ApexPages.currentPage().getParameters().get('whoId');
        ccEmails = ApexPages.currentPage().getParameters().get('ccEmails');
        documentId = ApexPages.currentPage().getParameters().get('doc_id');
        templateId  = ApexPages.currentPage().getParameters().get('templateId');
        selectedEmailTemplate = templateId;
        
        string woiIdJson = ApexPages.currentPage().getParameters().get('woiIdJson');
        Set<String> woiIdList = new Set<String>();
        system.debug('woiIdJson>'+woiIdJson);
        if(String.isNotEmpty(woiIdJson) && woiIdJson != 'null'){
            woiIdList = (Set<String>)JSON.deserialize(woiIdJson, Set<String>.class);
        }
            
        attchIds = new List<String>();    
        system.debug('cc emails == '+ccemails);
        
        w = [select id,Name, Account_Name__c,Unit_Number_Formula__c,Account__c,Account_Billing_City__c,Account_Billing_State__c,Blacklight_Inspection__c,
             Account_Billing_Street__c,Account_Billing_Zip_Code__c,Unit_Number__c,Property_Address__c,Property_City__c,Status__c,
             Property_State__c,Property_Zip_Code__c,Purchase_Order__c,Field_Crew_Start_Time__c,Invoice_Notes__c,Additional_Invoice_Notes__c from Work_Order__c where id =: woId];
        
        if(woId != null){
            work=[select id,Name, Account_Name__c,Unit_Number_Formula__c,Account__c,Account_Billing_City__c,Account_Billing_State__c,Blacklight_Inspection__c,
                  Outside_Inside_temp__c,Ventilation_on__c,Door_Windows_open__c,Cleaning_products_or_air_frag_present__c,Urine_Smell_at_entry__c,
                  Urine_smell_at_head_level_in_following__c,Urine_smell_activated_during_cleaning__c,Blacklight_findings__c,
                  Account_Billing_Street__c,Account_Billing_Zip_Code__c,Unit_Number__c,Property_Address__c,Property_City__c,Status__c,
                  Property_State__c,Property_Zip_Code__c,Purchase_Order__c,Field_Crew_Start_Time__c,Invoice_Notes__c,Additional_Invoice_Notes__c,
                  Sub_Total__c,Balance_Due1__c,Discount__c,Tax__c,Discount_Amount_New__c,Discount_Percentage__c,Discount_Amount__c from Work_Order__c where id =: woId];   
        }     
        
        if(woiIdList != null && woiIdList.size()>0){    
            system.debug('monthly');    
            witemsList = [select Work_Order__r.Field_Crew_Start_Time__c,Service__c,Service__r.Name,Line_Item_Description__c,Comment__c,Comments__c,Price__c
                          from Work_Order_Item__c where id =:woiIdList];     
        }else{    
            witemsList = [select Work_Order__r.Field_Crew_Start_Time__c,Service__c,Service__r.Name,Line_Item_Description__c,Comment__c,Comments__c,Price__c
                          from Work_Order_Item__c where Work_Order__c =:woId];    
        }    
        
        if(work.Tax__c != null){
            tax = String.valueOf(work.Tax__c);
            Double discountAmount = work.Discount_Amount_New__c == null ? 0 : work.Discount_Amount_NEW__c; 
            Double subTotal = work.Sub_Total__c == null ? 0 : work.Sub_Total__c;
            taxAmount = ((work.Tax__c/100) * (subTotal - discountAmount)).setScale(2);
        }
        else{
            tax = '0';
            taxAmount = 0;
        }
            
        system.debug('Size- '+witemsList.size());    
        Map<string,Decimal> discounPercentMap = new Map<string,Decimal>();    
        discounPercentMap.put('5% Discount',5);    
        discounPercentMap.put('First Time Customer 10% Discount',10);    
        discounPercentMap.put('Preferred Customer 10% Discount',10);    
        discounPercentMap.put('Special Appreciation 25% Discount',25);    
        discounPercentMap.put('Golden Customer 50% Discount',50);    
        subtotal = 0;    
        dis_Amount = 0;
        
        if(work.Discount__c=='Custom' && work.Discount_Percentage__c != null ){    
            discount = work.Discount__c +'-'+work.Discount_Percentage__c+'%';    
            discounPercentMap.put('Custom',work.Discount_Percentage__c);    
        }else{    
            discount = work.Discount__c;    
        }    
        if(woiIdList != null && woiIdList.size()>0){
            system.debug('monthly');
            for(Work_Order_Item__c items : witemsList){
                if(items.Price__c != null)
                subtotal = subtotal+items.Price__c;
            }
            if(discounPercentMap.get(work.Discount__c) != null){    
                dis_Amount = subtotal * 0.01 * discounPercentMap.get(work.Discount__c);    
            }    
            if(dis_Amount != null){    
                balanceDue = subtotal - dis_Amount;    
            }    
            woName = work.Name + ' - '+month+'-'+year;
        }else{
            system.debug('Single');
            subtotal = work.Sub_Total__c;    
            dis_Amount = work.Discount_Amount__c;    
            balanceDue = work.Balance_Due1__c;    
            woName = work.Name;
        }
        if(work.Field_Crew_Start_Time__c != null){
        	dateTimeValue = work.Field_Crew_Start_Time__c.format('MM/dd/yy hh:mm:a');//GMT
        }
        //to track the bo. of invoice generated for work order
    }
    public List<contentdistribution> getContentDis(){
        
        woId = ApexPages.currentPage().getParameters().get('id');
        contentIdSet = new Set<Id>();
        if(woId != null){
            ContentDocumentLinkList =  [ SELECT ContentDocumentId,ContentDocument.filetype,Id,IsDeleted,LinkedEntityId,ShareType,Visibility FROM 
                                        ContentDocumentLink WHERE LinkedEntityId=:woId AND (ContentDocument.filetype ='JPG' OR ContentDocument.filetype ='JPEG' OR ContentDocument.filetype ='PNG') ];
        }
        for(ContentDocumentLink cdl :ContentDocumentLinkList ){
            contentIdSet.add(cdl.ContentDocumentId);
        }
        
        List<ContentDistribution> ContentDistributionList = new List<ContentDistribution>();
        if(contentIdSet != null && contentIdSet.size()>0){
            ContentDistributionList = [SELECT Id, Name, ContentDocumentId, DistributionPublicUrl, RelatedRecordId from ContentDistribution  WHERE
                                       ContentDocumentId IN :contentIdSet ORDER BY Name ASC];
        }
        return ContentDistributionList;
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
    public List<SelectOption> getContacts(){
        List<SelectOption> options = new List<SelectOption>();
        if(w != null && w.size()>0){
            cList = [select id,Name,AccountId from Contact where AccountId =: w[0].Account_Name__c];
        }
        if(cList != null && cList.size()>0){
            for(Contact c : cList){
                if(!c.Name.containsIgnoreCase('invoice')){
                    options.add(new SelectOption(c.id,c.Name));
                }    
            }
        }
        return options;
    }
    public List<SelectOption> getOrgwideAddress(){
        List<SelectOption> em = new List<SelectOption>();
        owa = [select id, Address, DisplayName from OrgWideEmailAddress LIMIT 1];
        em.add(new SelectOption(UserInfo.getUserId(),UserInfo.getName()));
        em.add(new SelectOption(owa.id,owa.DisplayName));
        return em;
    }
    
    public List<SelectOption> getTemplates(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','None'));
        if(w != null && w.size()>0){
            if((w[0].Status__c == 'Invoiced'|| w[0].Status__c == 'Completed') 
               && w[0].Blacklight_Inspection__c != 'Blacklight Inspection with Brief Report' 
               && w[0].Blacklight_Inspection__c != 'Blacklight Inspection with Full Report + Photos'){
                   options.add(new SelectOption('Work Order Invoice','Work Order Invoice'));
               }
            else if(w[0].Status__c == 'Invoice Paid' && w[0].Blacklight_Inspection__c != 'Blacklight Inspection with Brief Report' 
                    && w[0].Blacklight_Inspection__c != 'Blacklight Inspection with Full Report + Photos' ){
                        options.add(new SelectOption('Work Order Invoice Paid','Work Order Invoice Paid'));
                    }
            else if(w[0].Blacklight_Inspection__c == 'Blacklight Inspection with Brief Report' 
                    || w[0].Blacklight_Inspection__c == 'Blacklight Inspection with Full Report + Photos'){
                        options.add(new SelectOption('Smart Invoice with BL Report','Smart Invoice with BL Report'));
                    }
        }
        return options;
    }
    
    public void onChangeRadio(){
        if(selectedMethod == 'Attach'){
            check = false;
        }
        else{
            check = true;
        }
    }
    
    public void onChangeTemplate(){
        if(selectedTemplate == 'Smart Invoice with BL Report' || selectedTemplate == 'Work Order Invoice Paid'){
            otherRadio = false;
        }
        else{
            otherRadio = true;
        }
    }
    
    public PageReference saveAttachement(){    
        system.debug('selectwitemsList--'+selectwitemsList);    
        List<String> woiIds = new List<string>();
        string woiIdJson = '';
        if(selectedContacts.size()==0){    
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select atleast one contact to proceed!!'));    
            return null;    
        }    
            
        if(isMonthly){    
            boolean isSelected = false;
            for(WOIWrapper s:selectwitemsList){
                if(s.selected){
                    isSelected = true;
                    woiIds.add(s.woi.id);
                }
            }
            if(!isSelected){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select atleast one Work Order Item!!'));
                return null;
            }
        }
        if(woiIds != null && woiIds.size()>0){
            woiIdJson = JSON.serialize(woiIds);
        }
        
        system.debug('selectedTemplate='+selectedTemplate);    
        if(selectedTemplate == 'None'){    
            system.debug('selectedTemplate='+selectedTemplate);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select the Template to proceed!!'));    
            return null;    
        }
        
        emailaddress = '';
        
        Set<String> selConId = new Set<String>();
        for(SelectOption s : selectedContacts){
            selConId.add(s.getValue());    
        }
        
        List<Contact> con = new List<Contact>();
        if(selConId != null && selConId.size()>0){
            con = [select id,email,Name from Contact where Id IN: selConId];
        }
        //temp list to be used if multiple contact are selected. [For CC]
        List<Contact> tempList = new List<Contact>();
        for(Integer i =1;i<con.size();i++){
            tempList.add(con[i]);
        }
        system.debug('temp list of contacts = '+tempList);
        for(Contact c : tempList){
            emailaddress = emailaddress + c.Email + ',';
        }
        system.debug('emailaddress from templist = '+emailaddress);
        PageReference pageRef;
        
         if (!initialised && pageOpp.ID !=NULL) {    
            PageReference pdf;    
            if(selectedTemplate == 'Work Order Invoice'){    
                pdf = new PageReference ('/apex/Invoice_Template?id='+pageOpp.Id +'&woiIdJson='+woiIdJson);
            }    
            else if(selectedTemplate == 'Work Order Invoice Paid'){    
                pdf = new PageReference ('/apex/Invoice_Paid_Template?id='+pageOpp.Id +'&woiIdJson='+woiIdJson);
            }    
            else{
                pdf = new PageReference ('/apex/Smart_Invoice_with_BL_Report_Template?id='+pageOpp.Id +'&woiIdJson='+woiIdJson);
            }
            
            Blob body;
            try{
                if(pdf != null)
                    body = pdf.getContentAsPDF();
            }catch (VisualforceException e) {
                body = Blob.valueOf('No file');
            }
            
            if(attachment == true){    
                Attachment attach = new Attachment();    
                attach.Body = body;    
                if(isMonthly){    
                    attach.Name = 'Monthly Invoice for ' + w[0].name +' - ' +month+'-'+year+ '.pdf';    
                }else{    
                    attach.Name = 'Invoice for ' + w[0].name +'.pdf';    
                }    
                    
                attach.IsPrivate = false;    
                attach.ParentId = pageOpp.Id;    
                insert attach;    
            }    
                
            ContentVersion version = new ContentVersion();    
            if(isMonthly){    
                version.Title='Monthly Invoice for ' + w[0].name +' - ' +month+'-'+year + '.pdf';    
                version.PathOnClient = 'Invoice for ' + w[0].name +' - ' +month+'-'+year + '.pdf';    
            }else{    
                version.Title='Invoice for ' + w[0].name +'.pdf';    
                version.PathOnClient = 'Invoice for ' + w[0].name +'.pdf';    
            }    
            version.VersionData = body;    
            insert version;
            
            FeedItem post = new FeedITem();
            post.body = 'Invoice sent to Account for this Work Order';
            post.ParentID = pageOpp.Id;
            insert post;
            
            FeedAttachment postAttachment = new FeedAttachment();
            postAttachment.FeedEntityId = post.id;
            postAttachment.Type = 'Content';
            postAttachment.RecordId = version.id;
            insert postAttachment;
            
            
            
            if(selectedMethod == 'Email'){
                Document document = new Document();
                document.AuthorId = UserInfo.getUserId();
                document.FolderId = UserInfo.getUserId(); // put it in running user's folder
                document.Body = body;    
                if(isMonthly){    
                    document.Name = 'Monthly Invoice for ' + w[0].name +' - ' +month+'-'+year +'.pdf';    
                }else{    
                    document.Name = 'Invoice for ' + w[0].name +'.pdf';    
                }    
                insert document;
                
                EmailTemplate email;
                
                if(selectedTemplate == 'Work Order Invoice' || selectedTemplate == 'Smart Invoice with BL Report'){
                    email = [select id,Name from EmailTemplate where Name = 'Invoice'];
                    
                }
                else if(selectedTemplate == 'Work Order Invoice Paid'){
                    email = [select id,Name from EmailTemplate where Name = 'Invoice Paid'];
                }
                
                String sscAddress = label.GabbyEmailAddress;
                system.debug('UserType = '+UserType);
                if(UserType =='Standard'){    
                    pageRef = new PageReference('/_ui/core/email/author/EmailAuthor?template_id='+email.id+'&retURL=/'+ woId + '&p2_lkid=' + con[0].id + '&p24=' + emailaddress + '&p5=' + sscAddress + '&p3_lkid=' + woId + '&saveURL=%2F' + woId + '&doc_id=' + document.id );    
                }else if(UserType =='PowerPartner'){ //PowerPartner
                    pageRef = new PageReference('/apex/SendInvoice?id='+woId+'&toEmail='+con[0].Email+'&ccEmails='+emailaddress+'&templateId='+email.id+'&doc_id='+ document.id+'&whoId='+con[0].Id);
                }
            }
            else{
                pageRef = new PageReference('/'+woId);
            }
            initialised=true;
            Work_Order__c woupdate = w[0];    
            try{    
                update woupdate;    
            }catch(dmlException e){    
                system.debug('msg--'+e.getMessage());    
            }    
        }    
        else{    
            pageRef = new PageReference('/'+woId);    
        }    
        return pageref;    
    }
    public void prepareEmail(){
        system.debug('documentId ='+documentId +'templateId ='+templateId);
        if(documentId != '' && documentId != null){
            attchIds.add(documentId);
        }
        Messaging.SingleEmailMessage se = Messaging.renderStoredEmailTemplate(templateId,whoId , woId);
        templateBody = se.getHtmlBody();
        system.debug('attchIds= '+attchIds);
        if(attchIds != null && attchIds.size()>0){
            se.setEntityAttachments(attchIds);
            DocList = new List<Document>();
            DocList = [Select Id,Name from Document WHERE id IN :attchIds];
        }
        templateSubject = se.getSubject();
    }
    public pagereference onChangePrepareEmail(){
        Messaging.SingleEmailMessage se = Messaging.renderStoredEmailTemplate(selectedEmailTemplate,whoId , woId);
        templateBody = se.getHtmlBody();
        templateSubject = se.getSubject();
        return null;
    }
    public pageReference sendInvoiceEmail(){
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(selectedToEmail == owa.id){
          message.setOrgWideEmailAddressId(selectedToEmail); // From email or Org wide email  
        }
        
        message.setToAddresses(new String[] {toEmail}); // set to addr
        if(ccemails !='' && ccemails != null){
            List<String> ccList = ccemails.split(',');
            String[] ccArray = ccList;
            message.setccaddresses(ccArray); //set CC emails
        }
        message.setHtmlBody(templateBody);//set html body
        if(attchIds.size()>0){
            message.setEntityAttachments(attchIds) ;//set attachment.
        }
        message.setSubject(templateSubject); // set subject
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        // create email activity
        EmailMessage em = new EmailMessage();
        em.relatedToId = woId;
        em.Status = '3'; // status as sent
        em.toIds = new String[] {whoId};
        em.toAddress =  ToEmail;
        if(selectedToEmail != owa.id){
            em.fromAddress = userInfo.getUserEmail() ; //from address of the current logged in user
            em.fromName = UserInfo.getName(); 
        }else{
            em.fromAddress = owa.Address ; // from address of the org wide address
            em.fromName = owa.DisplayName; // from name
        }
        em.subject = templateSubject; // email subject
        em.htmlBody = templateBody;
        insert em;
            
        
        PageReference pg = new PageReference('/'+woId);
        return pg;
    }
    public PageReference Cancel(){
        PageReference pageRef = new PageReference('/'+woId);
        return pageRef;
    }
    public PageReference cancelForCommunity(){
        PageReference pageRef = new PageReference('/'+woId);
        return pageRef;
    }
    public class WOIWrapper{
        public Work_Order_Item__c woi{get;set;}
        public boolean selected{get;set;}
    }
    
}