@isTest
public class leadControllerExtensionTest {
    @isTest
    static void positiveCase() {
        Lead l = new Lead();
        l.lastName = 'Damco';
        l.Email = 'test@damcogroup.com';
        l.Company ='Damco';
        insert l;
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        leadControllerExtension lce = new leadControllerExtension(sc);
        PageReference pageRef = Page.leadDelete; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(l.Id));
        Test.setCurrentPage(pageRef);
        lce.deleteLeads();
        //testAccPlan.save(); call all your function here
        Test.StopTest();
    }
    @isTest
    static void negativeCase() {
        Lead l = new Lead();
        l.lastName = 'Damco';
        l.Email = 'test@damcogroup.com';
                l.Company ='Damco';

        insert l;
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        leadControllerExtension lce = new leadControllerExtension(sc);
        PageReference pageRef = Page.leadDelete; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(l.Id));
        Test.setCurrentPage(pageRef);
        lce.deleteLeads();
        //testAccPlan.save(); call all your function here
        Test.StopTest();
    }
    @isTest
    static void redirect() {
        Lead l = new Lead();
        l.lastName = 'Damco';
        l.Email = 'test@damcogroup.com';
                l.Company ='Damco';

        insert l;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        leadControllerExtension lce = new leadControllerExtension(sc);
        PageReference pageRef = Page.leadDelete; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(l.Id));
        Test.setCurrentPage(pageRef);
        lce.leadRecordView();
    }
}