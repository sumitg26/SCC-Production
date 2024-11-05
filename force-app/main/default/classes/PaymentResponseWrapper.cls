public class PaymentResponseWrapper {
    public PaymentDetail payment{get;set;}
    public List<ErrorDetail> errors{get;set;}
    
    public class PaymentDetail {
        public string id{get;set;}
        public string status{get;set;}
        public string source_type{get;set;}
        public DateTime created_at{get;set;}
        //public DateTime updated_at{get;set;}        
        public string location_id{get;set;}
        public string order_id{get;set;}
        public string receipt_number{get;set;}
        public string receipt_url{get;set;}  
        public CardDetails card_details{get;set;}  
        public AmountMoney amount_money{get;set;}
    }
    
    public class AmountMoney {
        public decimal amount{get;set;}  
        public string currency_x{get;set;}  
    }
    
    public class CardDetails {
        //public string status{get;set;}
        public string entry_method{get;set;}
        //public string cvv_status{get;set;}
        //public string avs_status{get;set;}
        //public string statement_description{get;set;}
        public CardDetail card{get;set;}                  
    }
    
    public class CardDetail {
        public string card_brand{get;set;}
        public string last_4{get;set;}
        public string exp_month{get;set;}
        public string exp_year{get;set;}
        //public string fingerprint{get;set;}
        public string card_type{get;set;}
        //public string prepaid_type{get;set;}
        //public string bin{get;set;}
    }
    
    public class ErrorDetail {
        public string detail{get;set;}
        public string code{get;set;}
        public string category{get;set;}        
    }
}