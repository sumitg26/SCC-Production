public without sharing class LeadUpdate {
    public string LeadId{get;set;}
    public string feedback{get;set;}
    public Lead ld{get;set;}
    public LeadUpdate() {
        LeadId = ApexPages.currentPage().getParameters().get('id');
        system.debug('Lead Id' +LeadId);
        feedback = 'False';
        ld = new Lead();
    }
    public PageReference InitPage() {
        if(LeadId!=NULL && LeadId!=''){
        ld = [select Id, Name, Email, phone, Company, Estimated_Credit_Score__c, Updated_by_Franchise_Contact__c, 
              street, city, state, country, postalcode, dob__c, Spouse_Partner_DOB__c, Spouse_Partner_Name__c, 
              How_Did_You_Hear_About_Smart_Franchise__c, Household_Yearly_Income__c, 
              Liquid_Assets__c, Retirement_Funds_Estimate__c, Additional_Financial_Comments__c, 
              How_Do_You_Plan_on_Funding_Your_Business__c, First_Priority_Territory__c, Second_Priority_Territory__c, 
              Third_Priority_Territory__c, Looking_to_Start__c, Current_Most_Recent_Job_Title__c, Veteran__c, 
              Have_You_Ever_Filed_Bankruptcy__c, Felony_Conviction__c, Will_You_Operate_the_Business_Full_Time__c, 
              Other_Business_Partners__c, Own_Another_Business__c, Spouse_Email_ID__c,Have_You_Ever_Used_CRM_System_for_Client__c,
              How_Many_Hrs_Week_Do_You_Use_a_Computer__c
              from Lead WHERE id=:LeadId LIMIT 1];
        system.debug('Lead' +ld);
        if (ld.Updated_by_Franchise_Contact__c==False){
            feedback = 'False';
        }
        else {
            feedback = 'True';
        }
        }
        system.debug('Feedback Value ' +feedback);
        return null;
        
    }
    public PageReference UpdateRecord(){
        
        ld.Updated_by_Franchise_Contact__c = true;
        update ld;
        PageReference pageref = new PageReference('/apex/thankspage');
        return pageref;
    }
}