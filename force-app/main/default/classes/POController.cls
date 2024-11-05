public class POController{
    public String poId{get;set;}
    public List<Purchase_Orders__c> poList{get;set;}
    public List<Purchase_Order_Lines__c> poLinesList{get;set;}
    public List<Contact> cList{get;set;}
    Private Purchase_Orders__c pageOpp;
    public Boolean initialised{get; set;}
    Date myDate = system.today();
    public List<SelectOption> selectedContacts{get;set;}
    public Decimal Total{get;set;}
    public String selectedTemplate{get;set;}
    public Boolean attachment{get;set;}
    public String selectedMethod{get;set;}
    public String dateTimeValue { get; set; }
    public String type { get; set; }
    public String UserType{get; set;}
    //variables to populate email fields field.
    public OrgWideEmailAddress owa;
    public String LoggedInUserEmail {get;set;}
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
    //For selected Email template and its meta data types list
    public String selectedEmailTemplate{get;set;}
    public List<Purchase_Order_Email_Template__mdt> POEmailTemplateList {get;set;}
    public String deliveryInstructions{get;set;}
    
    public POController(ApexPages.StandardController stdController) {
        UserType = userinfo.getusertype();
        system.debug('UserType in constructor = '+UserType);
        this.pageOpp = (Purchase_Orders__c)stdController.getRecord();
        poId = ApexPages.currentPage().getParameters().get('id');
        type = ApexPages.currentPage().getParameters().get('type');
        initialised=false;
        selectedMethod = 'Email';
        
        poList = [select id,Status__c,Type__c,Ship_Via__c,Name,Franchise__c,Franchise_Address__c,Franchise__r.Name,Account_Name__c,Account_Name__r.Name,Account_Name__r.Delivery_Instructions__c,Account_Address__c,Account_Billing_Address__c,Shipping_Address__c,CreatedDate,Payment_Terms__c
                  ,Notes__c, Order_Status__c from Purchase_Orders__c where id =: poId];
        
        if(poList != null &&  poList.size()>0){
            //first condition for community user
            //second OR condition for powerpartner user
            deliveryInstructions = poList[0].Account_Name__r.Delivery_Instructions__c;
            if((poList[0].Type__c == 'Inbound' && poList[0].Status__c == 'Order Created') || 
               (UserType == 'PowerPartner' && poList[0].Type__c == 'Inbound' && poList[0].Order_Status__c == 'Pending')){
                Account a = [Select id,Name,Email__c,ShippingAddress from Account where id = '0011a00000nvhwN' limit 1];
                //Account a = [Select id,Name,Email__c,ShippingAddress from Account where id = '0018F000007dkz4QAA' limit 1];    
                cList = [select id,Name,AccountId from Contact where AccountId =: a.id]; 
                system.debug('cList: '+cList);
            }
            else if((poList[0].Type__c == 'Outbound' && poList[0].Status__c == 'Order Created') || 
                    (UserType == 'PowerPartner' && poList[0].Type__c == 'Outbound' && poList[0].Order_Status__c == 'Pending')){
                poLinesList = [select id,Total_Price_Formula__c,Product__c,Product__r.Supplier_Manufacturer__c,Product__r.ProductCode,Product__r.Name,Product__r.Description,Quantity__c,Act_Cost__c,
                               Purchase_Orders__c,Purchase_Orders__r.Balance_Due__c ,Product__r.Supplier_Product_Code__c from Purchase_Order_Lines__c where Purchase_Orders__c =: poId];  
                
                system.debug('PO Supplier_Manufacturer__c: '+poLinesList[0].Product__r.Supplier_Manufacturer__c);
                
                if(poLinesList != null && poLinesList.size()>0){
                    system.debug('PO Line items: '+poLinesList);
                    cList = [select id,Name,AccountId from Contact where AccountId =: poLinesList[0].Product__r.Supplier_Manufacturer__c];
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
    }
    
    public POController(){
        LoggedInUserEmail = UserInfo.getUserEmail();
        owa = new OrgWideEmailAddress();
        UserType = userinfo.getusertype();
        system.debug(UserType);
        ToEmail = ApexPages.currentPage().getParameters().get('toEmail');
        whoId = ApexPages.currentPage().getParameters().get('whoId');
        ccEmails = ApexPages.currentPage().getParameters().get('ccEmails');
        documentId = ApexPages.currentPage().getParameters().get('doc_id');
        templateId  = ApexPages.currentPage().getParameters().get('templateId');
        System.debug('ToEmail: '+ToEmail);
        System.debug('whoId: '+whoId);
        System.debug('ccEmails: '+ccEmails);
        System.debug('templateId from main class...........' + templateId  );
        selectedEmailTemplate = templateId;
        
        Total = 0;
        poId = ApexPages.currentPage().getParameters().get('id');
        poList = [select id,Status__c,Type__c,Ship_Via__c,Name,Account_Name__c,Franchise__c,Franchise_Address__c,Franchise__r.Name,Franchise__r.Primary_Contact__c,Franchise__r.Delivery_Instructions__c, Account_Name__r.Name,Account_Name__r.Delivery_Instructions__c,Account_Address__c,Shipping_Address__c,CreatedDate,Payment_Terms__c,
                  Subtotal__c,Tax_Amount__c,Account_Billing_Address__c,Shipping_Handling__c,Balance_Due__c,Discount_Credit__c,CreatedBy.Name,Account_Name__r.Primary_Contact__c
                  ,Notes__c, Order_Status__c from Purchase_Orders__c where id =: poId];
        
        if(poList != null){
            for(Purchase_Orders__c porders : poList) {
                 if(porders.Franchise__c != null) {
                	deliveryInstructions = poList[0].Franchise__r.Delivery_Instructions__c;
            		}
            	 else
        			deliveryInstructions = poList[0].Account_Name__r.Delivery_Instructions__c;
            	}      
        }
        

        dateTimeValue = System.Now().format('MM/dd/yy  hh:mm a', 'America/Denver');//GMT          
        
        poLinesList = [select id,Item__c,Product__c,Product__r.ProductCode,Product__r.Name,Product__r.Description,Quantity__c,Act_Cost__c,Sub_Total__c,Total_Price_Formula__c,
                       Product__r.Supplier_Manufacturer__r.Name,  Product__r.Supplier_Product_Code__c,Purchase_Orders__c,Purchase_Orders__r.Balance_Due__c from Purchase_Order_Lines__c where Purchase_Orders__c =: poId];  
        
        for(Purchase_Order_Lines__c pol : poLinesList){
            Total = Total + pol.Purchase_Orders__r.Balance_Due__c;
        }                      
    }
    //list to show all email templates from custom setting.
    public List<SelectOption> getEmailTemplates(){
        List<SelectOption> temp = new List<SelectOption>();
        POEmailTemplateList = [SELECT MasterLabel, Template_Id__c FROM Purchase_Order_Email_Template__mdt LIMIT 1000];
        for(Purchase_Order_Email_Template__mdt et : POEmailTemplateList){
            temp.add(new SelectOption(et.Template_Id__c,et.MasterLabel));
        }
        //temp.add(new SelectOption('00X1P000000J7Jb','Purchase Order Template'));
        return temp;
    }
    public List<SelectOption> getContacts(){
        List<SelectOption> options = new List<SelectOption>();
        system.debug('Clist: '+cList);
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
        system.debug('poList: '+poList);
        options.add(new SelectOption('None','None'));
        if(poList != null && poList.size()>0){
            if((poList[0].Status__c == 'Order Created') || (UserType =='PowerPartner' && poList[0].Order_Status__c == 'Pending')){ 
                if(type != 'slip'){
                    options.add(new SelectOption('Purchase Order','Purchase Order'));
                }
                else if(type == 'slip' && poList[0].Type__c == 'Inbound'){
                    options.add(new SelectOption('Packing Slip','Packing Slip'));
                }
            }
        }
        return options;
    }
    
    public PageReference saveAttachement(){
        if(selectedTemplate == 'None'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select the Template to proceed!!'));
            return null;
        }
        
        String emailaddress = '';
        
        Set<String> selConId = new Set<String>();
        for(SelectOption s : selectedContacts){
            selConId.add(s.getValue());    
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
        
        PageReference pageRef;
        
        if (!initialised && pageOpp.ID !=NULL) {
            PageReference pdf;
            if(selectedTemplate == 'Purchase Order'){
                pdf = new PageReference ('/apex/PO_Purchase_Order_Template?id='+pageOpp.Id);
            }
            else if(selectedTemplate == 'Packing Slip'){
                pdf = new PageReference ('/apex/PO_Packing_Slip_Template?id='+pageOpp.Id);
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
                if(selectedTemplate == 'Purchase Order'){
                    attach.Name = 'Purchase Order for' + poList[0].name +'.pdf';
                }
                else if(selectedTemplate == 'Packing Slip'){
                    attach.Name = 'Packing Slip for' + poList[0].name +'.pdf';
                }
                attach.IsPrivate = false;
                attach.ParentId = pageOpp.Id;
                insert attach;
                
            }
            
            ContentVersion version = new ContentVersion();
            if(selectedTemplate == 'Purchase Order'){
                version.Title='Purchase Order for' + poList[0].name +'.pdf';
                version.PathOnClient = 'Purchase Order for' + poList[0].name +'.pdf';
            }
            else if(selectedTemplate == 'Packing Slip'){
                version.Title='Packing Slip for' + poList[0].name +'.pdf';
                version.PathOnClient = 'Packing Slip for' + poList[0].name +'.pdf';
            }
            version.VersionData = body;
            insert version;
            
            FeedItem post = new FeedITem();
            if(selectedTemplate == 'Purchase Order'){
                post.body = 'Purchase Order Document sent to Account for this Purchase Order';
            }
            else if(selectedTemplate == 'Packing Slip'){
                post.body = 'Packing Slip sent to Account for this Purchase Order';
            }
            post.ParentID = pageOpp.Id;
            insert post;
            
            FeedAttachment postAttachment = new FeedAttachment();
            postAttachment.FeedEntityId = post.id;
            postAttachment.Type = 'Content';
            postAttachment.RecordId = version.id;
            insert postAttachment;
            
            EmailTemplate email;
            email = [select id,Name from EmailTemplate where Name = 'Purchase Order'];
            
            if(selectedMethod == 'Email'){
                Document document = new Document();
                document.AuthorId = UserInfo.getUserId();
                document.FolderId = UserInfo.getUserId(); // put it in running user's folder
                document.Body = body;
                if(selectedTemplate == 'Purchase Order'){
                    document.Name = 'Purchase Order for' + poList[0].name +'.pdf';
                }
                else if(selectedTemplate == 'Packing Slip'){
                    document.Name = 'Packing Slip for' + poList[0].name +'.pdf';
                }
                insert document;
                
                String sscAddress = 'supply@smartcarpetcare.com';
                system.debug('UserType = '+UserType);
                if(UserType =='Standard'){  
                    pageRef = new PageReference('/_ui/core/email/author/EmailAuthor?template_id='+email.id+'&retURL=/'+ poId + '&p2_lkid=' + con[0].id + '&p24=' + emailaddress + '&p5=' + sscAddress + '&saveURL=%2F' + poId + '&doc_id=' + document.id + '&p3_lkid='+poId);   
                }else if(UserType =='PowerPartner'){ //PowerPartner
                    pageRef = new PageReference('/apex/PO_SendInvoice?id='+poId+'&toEmail='+con[0].Email+'&ccEmails='+emailaddress+'&templateId='+email.id+'&doc_id='+ document.id+'&whoId='+con[0].Id);
                }
                pageOpp.Status__c = 'Order Placed';
                update pageOpp;
                system.debug('pageOpp: '+pageOpp);
            }
            else{
                pageOpp.Status__c = 'Order Placed';
                update pageOpp;
                system.debug('pageOpp: '+pageOpp);
                pageRef = new PageReference('/'+poId);
            }
            initialised=true;
        }
        else{
            pageRef = new PageReference('/'+poId);
        }
        return pageRef;
    }
    
    public void prepareEmail(){
        system.debug('documentId ='+documentId +'templateId ='+templateId);
        attchIds = new List<String>();
        if(string.isNotBlank(documentId)){
            attchIds.add(documentId);
        }
        Messaging.SingleEmailMessage se = Messaging.renderStoredEmailTemplate(templateId,poId , poId);
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
    
        Messaging.SingleEmailMessage se = Messaging.renderStoredEmailTemplate(selectedEmailTemplate,poId , poId);
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
        em.relatedToId = poId;
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
            
        
        PageReference pg = new PageReference('/'+poId);
        return pg;
    }
    
    public PageReference Cancel(){
        PageReference pageRef = new PageReference('/'+poId);
        return pageRef;
    }
    public PageReference cancelForCommunity(){
        PageReference pageRef = new PageReference('/'+poId);
        return pageRef;
    }
}