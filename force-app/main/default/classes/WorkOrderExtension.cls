public with sharing class WorkOrderExtension
{
    public List<Work_Order__c> lstWorkOrder { get; set; }
    public List<SelectOption> listViewOptions1 {get; set;}
    
    public Integer recordCount{public get;public set;}
    public String filter{public get;public set;}
    public String filterCondition{public get;public set;}
    public Integer recordOffset{public get;public set;}
    public Integer recordLimit{public get;public set;}
    public Integer pageNum{public get;public set;}
    public String sortDirection;
    public String sortExp;
    
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
             sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
             sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
    }
    
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }
    
    public WorkOrderExtension(ApexPages.StandardSetController controller) {
         
        listViewOptions1= new List<SelectOption>();
        
        Database.QueryLocator ql = Database.getQueryLocator('select id from Work_Order__c limit 200');
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(ql);
        System.SelectOption[] listViews = setController.getListViewOptions();
        String listViewID = null;
        for(System.SelectOption listView : listViews)
        {
            listViewOptions1.add(new SelectOption(listView.getValue(),listView.getLabel()));
        }            
        
        recordOffset =0;
        recordLimit =50;
        pageNum=1;
        sortExpression = 'Start_Date__c';
        sortDirection = 'Desc';
        filterCondition = ' ID!=null';
        GetData();
    }

    
    public void GetData()
    {
       String query = 'select ID,name,Property_Address__c,Unit_Number__c,Status__c,Start_Date__c,Completion_Date__c,Time_Frame__c from Work_Order__c';
       String countQuery = 'select count() from Work_Order__c';
       
       query +=' where '+filterCondition;
       countQuery +=' where '+filterCondition;
       
       query +=' order by '+sortExpression+' '+sortDirection+' limit ' + String.valueOf(recordLimit)+' offset '+String.valueOf(recordOffset);
       
       lstWorkOrder = Database.query(query);
       
       recordCount= database.countQuery(countQuery);            
    }
    
    public void GetDataFilter()
    {
        filterCondition = Apexpages.currentPage().getParameters().get('condition');
        
        recordOffset = 0;
        pageNum = 1;
        
        if(filterCondition.equalsIgnoreCase(' Status__c = \'Invoice Paid\' '))
        {
            
            sortExpression = 'Start_Date__c';
            sortDirection = 'Desc';
        }
                
        GetData();
    }
    
    public void GetDataPageSize()
    {
        pageNum = 1;
        recordOffset = 0;
        GetData();
    }
    
    public void PreviousData()
    {
        pageNum -=1;
        recordOffset = recordOffset - recordLimit;
        GetData();
    }
    
    public void NextData()
    {
        pageNum +=1;
        recordOffset = recordOffset + recordLimit;
        GetData();
    }
}