@isTest
Public class TestWorkOrderExtension
{
    TestWorkOrderExtension()
    {
        List<Work_Order__c> workOrderList = [SELECT Name FROM Work_Order__c LIMIT 20];

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(workOrderList);
        
        WorkOrderExtension objWorkOrderExtension = new WorkOrderExtension(sc);
        objWorkOrderExtension.GetDataFilter();
        objWorkOrderExtension.GetDataPageSize();
        objWorkOrderExtension.PreviousData();
        objWorkOrderExtension.NextData();
        
    }
    
    static testmethod void testWorkOrderExtensionController () 
    {
        List<Work_Order__c> workOrderList = [SELECT Name FROM Work_Order__c LIMIT 20];

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(workOrderList);
        
        WorkOrderExtension objWorkOrderExtension = new WorkOrderExtension(sc);
        
        objWorkOrderExtension.recordOffset =0;
        objWorkOrderExtension.recordLimit =50;
        //filter='All';
        objWorkOrderExtension.pageNum=2;
        objWorkOrderExtension.sortExpression = 'Start_Date__c';
        objWorkOrderExtension.sortDirection = 'Desc';
        objWorkOrderExtension.filterCondition = ' Status__c = \'Invoice Paid\' ';
        
        
        objWorkOrderExtension.NextData();
        objWorkOrderExtension.PreviousData();
        
        PageReference pRef = Page.Default_Community_Page;
        pRef.getParameters().put('condition', ' Status__c = \'Invoice Paid\' ');
        Test.setCurrentPage(pRef);
        
        //Test.startTest();
        
        objWorkOrderExtension.GetDataFilter();
        objWorkOrderExtension.GetDataPageSize();
        objWorkOrderExtension.getSortDirection();
        objWorkOrderExtension.setSortDirection('');
        //Test.stopTest();
        
        
        
    }  
}