public class POInvoiceController{
    public List<Purchase_Orders__c> poList{get;set;}
    public List<Purchase_Order_Lines__c> poLinesList{get;set;}
    public Decimal Total{get;set;}
    public String poId{get;set;}
    public String selectedTemplate{get;set;}
    public List<Contact> cList{get;set;}
    public Boolean attachment{get;set;}
    public String selectedMethod{get;set;}
    public String dateTimeValue { get; set; }
    public String dueDate { get; set; }
    
    /*Boolean value to Display */
    public Boolean franchiseBillingAddExists {get;set;}
    
    Private Purchase_Orders__c pageOpp;
    public Boolean initialised{get; set;}
    Date myDate = system.today();
    public List<SelectOption> selectedContacts{get;set;}
    
    public POInvoiceController(ApexPages.StandardController stdController) {
        this.pageOpp = (Purchase_Orders__c)stdController.getRecord();
        poId = ApexPages.currentPage().getParameters().get('id');
        initialised=false;
        selectedMethod = 'Email';
        poList = [select id,Status__c,Type__c ,Ship_Via__c,Name,Account_Name__c,Account_Name__r.Name,Account_Address__c,Shipping_Address__c,Franchise__c,Franchise_Address__c, CreatedDate,Payment_Terms__c,Franchise_Billing_Address__c
        from Purchase_Orders__c where id =: poId];
        
        if(poList != null &&  poList.size()>0){
            
            cList = [select id,Name,AccountId from Contact where AccountId =: poList[0].Account_Name__c];
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
    
    public POInvoiceController(){
        Total = 0;
        poId = ApexPages.currentPage().getParameters().get('id');
        poList = [select id,PO_Date__c,Status__c,Type__c,Ship_Via__c,Name,Account_Name__c,Account_Name__r.Name,Account_Address__c,Shipping_Address__c,Franchise__c,Franchise_Address__c,CreatedDate,Payment_Terms__c,
                  Subtotal__c,Tax_Amount__c,Shipping_Handling__c,Balance_Due__c,Discount_Credit__c,Franchise_Billing_Address__c
                  from Purchase_Orders__c where id =: poId];
        
        dateTimeValue = System.Now().format('MM/dd/yy hh:mm a', 'America/Denver');//GMT
        	/*Initalize franchiseBillingAddExists value as false*/
        	this.franchiseBillingAddExists=False;
            /*Franchise Billing Address Exists*/
            if(poList[0].Franchise_Billing_Address__c!='<br>  <br>'){
               this.franchiseBillingAddExists=True;
                
            }
        if(poList[0].PO_Date__c != null){
            Date d = poList[0].PO_Date__c +  15;
            DateTime dt = DateTime.newInstance(d.year(),d.month(),d.day());
    
            dueDate = dt.format('MM/dd/yy', 'America/Denver');//GMT
        }
        
        poLinesList = [select id,Total_Price_Formula__c,Product__c,Product__r.ProductCode,Product__r.Name,Product__r.Description,Quantity__c,Act_Cost__c,Sub_Total__c,
        Purchase_Orders__c,Purchase_Orders__r.Balance_Due__c from Purchase_Order_Lines__c where Purchase_Orders__c =: poId];  
        
        for(Purchase_Order_Lines__c pol : poLinesList){
            Total = Total + pol.Purchase_Orders__r.Balance_Due__c;
        }                      
    }
    
    public List<SelectOption> getContacts(){
    List<SelectOption> options = new List<SelectOption>();
    
    if(cList != null && cList.size()>0){
        for(Contact c : cList){
            if(!c.Name.containsIgnoreCase('invoice')){
                options.add(new SelectOption(c.id,c.Name));
            }    
        }
    }
    return options;
    }
    
    public List<SelectOption> getTemplates(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','None'));
        if(poList != null && poList.size()>0){
            if(poList[0].Status__c == 'Order Placed'||poList[0].Status__c == 'Order Shipped'||poList[0].Status__c == 'Invoiced'){ 
                options.add(new SelectOption('Purchase Order Invoice','Purchase Order Invoice'));
            }else if(poList[0].Status__c == 'Order Completed'){
                options.add(new SelectOption('Purchase Order Invoice Paid','Purchase Order Invoice Paid'));
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
            if(selectedTemplate == 'Purchase Order Invoice'||selectedTemplate == 'Purchase Order Invoice Paid'){
                pdf = new PageReference ('/apex/PO_Invoice_Template?id='+pageOpp.Id);
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
                if(selectedTemplate == 'Purchase Order Invoice' || selectedTemplate == 'Purchase Order Invoice Paid'){
                    attach.Name = 'Invoice for' + poList[0].name +'.pdf';
                }
                attach.IsPrivate = false;
                attach.ParentId = pageOpp.Id;
                insert attach;
            }
            
            ContentVersion version = new ContentVersion();
            if(selectedTemplate == 'Purchase Order Invoice' || selectedTemplate == 'Purchase Order Invoice Paid'){
                version.Title='Invoice for' + poList[0].name +'.pdf';
                version.PathOnClient = 'Invoice for' + poList[0].name +'.pdf';
            }
            version.VersionData = body;
            insert version;
            
            FeedItem post = new FeedITem();
            if(selectedTemplate == 'Purchase Order Invoice' || selectedTemplate == 'Purchase Order Invoice Paid'){
                post.body = 'Invoice sent to Account for this Purchase Order';
            }
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
                if(selectedTemplate == 'Purchase Order Invoice' || selectedTemplate == 'Purchase Order Invoice Paid'){
                    document.Name = 'Invoice for' + poList[0].name +'.pdf';
                }
                insert document;
                
                String sscAddress = 'smartaccountmgmt@smartcarpetcare.com';
                String templName='';
                if(poList[0].Status__c=='Order Completed'){
                    templName='Purchase Order Invoice Paid';
                }
                else if(poList[0].Status__c == 'Order Placed'||poList[0].Status__c == 'Order Shipped'||poList[0].Status__c == 'Invoiced'){
                    templName='Purchase Order Invoice';
                }
                system.debug(templName);
                system.debug(poId);
                if(templName!=null && templName!=''){
                 	EmailTemplate emailTemplate =[Select Id from EmailTemplate WHERE name=:templName];  
                	pageRef = new PageReference('/_ui/core/email/author/EmailAuthor?retURL=/'+ poId + '&p2_lkid=' + con[0].id + '&p24=' + emailaddress + '&p5=' + sscAddress +'&saveURL=%2F' + poId +'&p3_lkid=' +poId+'&doc_id=' + document.id+'&template_id='+emailTemplate.id);
                }
                 
                
            }
            else{
                pageRef = new PageReference('/'+poId);
            }
            initialised=true;
        }
        else{
            pageRef = new PageReference('/'+poId);
        }
        return pageRef;
    }
    
    public PageReference Cancel(){
        PageReference pageRef = new PageReference('/'+poId);
        return pageRef;
    }

}