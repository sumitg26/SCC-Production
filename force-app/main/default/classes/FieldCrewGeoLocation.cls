// class to Update latitude and longitude in work order.
public class FieldCrewGeoLocation{
    // variables to store lat and long
    public String latt {get; set;}
    public String longt {get; set;}
    //param passed from url button with request = checkIn/Checkout
    public String request;
    //Work Order object
    Public Work_order__c woObj;
    
    public FieldCrewGeoLocation(ApexPages.StandardController stdController){
        latt = '0';
        longt = '0';
        request = '';
        woObj = (Work_order__c)stdController.getRecord();
        request = Apexpages.currentPage().getParameters().get('request');
        saveCordinates();
    }
    // method to check request type and update lat, long
    public pagereference saveCordinates(){
        //setting param from actionFunction Kkumarr
        latt =  Apexpages.currentPage().getParameters().get('LatParam');
        longt =  Apexpages.currentPage().getParameters().get('LongParam');
        if(request =='checkin' && latt !='' && longt !='' && latt != null && longt !=null){
            woObj.Field_Crew_Start_Location__Latitude__s = decimal.valueOf(latt);
            woObj.Field_Crew_Start_Location__Longitude__s = decimal.valueOf(longt);
            woObj.Field_Crew_Start_Time__c = system.now();
            update woObj;
        }
        if(request =='checkout' && latt !='' && longt !='' && latt != null && longt !=null){
            woObj.Field_Crew_End_Location__Latitude__s = decimal.valueOf(latt);
            woObj.Field_Crew_End_Location__Longitude__s = decimal.valueOf(longt);
            woObj.Field_Crew_End_Time__c = system.now();
            update woObj;
        }
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
        String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
        ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
        (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone')))
        {
            system.debug('mobile');
            pagereference pg = new pagereference('/smartcarpetcare/lightning/r/Work_Order__c/'+woObj.Id+'/view');
            return pg;
            
        }
        else{
            system.debug('desktop');
            pagereference pg = new pagereference('/'+woObj.Id);
            return pg;
        }
        
    }
}