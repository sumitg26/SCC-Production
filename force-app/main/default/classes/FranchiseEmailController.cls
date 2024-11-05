global class FranchiseEmailController implements Schedulable { 
    global void execute(SchedulableContext ctx) {        
        List<Lead> leadList = [select Id,Name,Email,Franchise_Type__c,Last_Franchise_Email_Sent__c from lead where recordType.name = 'Franchise'];  
        
        List<EmailTemplate> emailTemplateList = [Select Id,Name,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate 
                                                where Name Like 'Franchise%' ];
                
        Map<String,EmailTemplate> emailTemplateMap = new Map<String,EmailTemplate>();
        for(EmailTemplate emailTemp : emailTemplateList)
        {
            emailTemplateMap.put(emailTemp.Name,emailTemp);
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();  
        for(Lead leadObj: leadList)
        {
            if(leadObj.Franchise_Type__c != 'None')
            {
                List<String> sendTo = new List<String>();
                sendTo.add(leadObj.Email);
                
                DateTime tempDate = leadObj.Last_Franchise_Email_Sent__c == null ? Date.today() :leadObj.Last_Franchise_Email_Sent__c ;
                String templateName = '';
                if(tempDate.addDays(15) == Date.today() && leadObj.Franchise_Type__c == 'No Contact Made - 2 weeks')
                {
                    templateName = 'Franchise No Contact Made';
                }
                else if(tempDate.addMonths(1) == Date.today() && leadObj.Franchise_Type__c == 'No Contact Made Monthly')
                {
                    templateName = 'Franchise No Contact Made';
                }
                else if(tempDate.addDays(7) == Date.today() && leadObj.Franchise_Type__c == 'Non-Responsive')
                {
                    templateName = 'Franchise still interested in Smart';
                }
                else if(tempDate.addMonths(1) == Date.today() && leadObj.Franchise_Type__c == 'Homeowner Issue ')
                {
                    templateName = 'Franchise Homeowner Issue';
                }
                else if(tempDate.addMonths(1) == Date.today() && leadObj.Franchise_Type__c == 'Full Time Issue ')
                {
                    templateName = 'Franchise Full Time Issue';
                }
                else if(tempDate.addMonths(3) == Date.today() && leadObj.Franchise_Type__c == 'No Contact Made Quarterly')
                {
                    templateName = 'Franchise No Contact Made';
                }
                else if(tempDate.addMonths(3) == Date.today() && leadObj.Franchise_Type__c == 'Not Enough Capital')
                {
                    templateName = 'Franchise Not Enough Capital';
                }
                System.debug('after template name.........' + templateName);
                if(emailTemplateMap.containsKey(templateName))
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    EmailTemplate templateObj = emailTemplateMap.get(templateName); 
                    mail.setTemplateID(templateObj.Id); 
                    mail.setSubject(templateObj.Subject);
                    mail.setTreatBodiesAsTemplate(true);
                    mail.setHtmlBody(templateObj.body);
                    //mail.setPlainTextBody(templateObj.body);
                    mail.setToAddresses(sendTo);
                    mail.setTargetObjectId(leadObj.Id);
                    mail.setSaveAsActivity(true);
                    mails.add(mail);
                }
                leadObj.Last_Franchise_Email_Sent__c  = Date.Today();
            }            
        }
        if(mails.size() > 0)
        {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            if (results[0].isSuccess()) {
                 System.debug('The email was sent successfully.');
                 System.debug('lead to update.........' + leadList);
                update leadList;
            } else {
                System.debug('The email failed to send: ' + results[0].getErrors()[0].getMessage());
            }
        }
    }
}