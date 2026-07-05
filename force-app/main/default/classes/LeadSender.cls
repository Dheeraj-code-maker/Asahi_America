global class LeadSender{
    @future(callout = true) 
 public static void sendLeadRecs(Set<Id> insertedLeadIds)
 {
     List<LeadRecord>LeadRecsWrapperList = new List<LeadRecord>();
    if(insertedLeadIds != null && insertedLeadIds.size() > 0)
    {
        for(Lead ldata : [SELECT interlynx_LUID__c, FirstName, LastName, Title, Email, Company, 
                          OwnerId, Phone, MobilePhone, Website, LeadSource, Description, PostalCode, 
                          City, State, Country, Street, Owner.Name, Owner.Email, Status ,Additional_Comments__c, Quoted_Amount__c, Order_Amount__c, Sub_status__c, Other_Reason__c, Reminder_Date__c
                          FROM Lead 
                          WHERE Id IN :insertedLeadIds])
        {
            LeadRecord lr = new LeadRecord();
            if(String.isNotBlank(ldata.Email) || String.isNotBlank(ldata.FirstName) || String.isNotBlank(ldata.LastName)) {
                lr.SalesforceId = ldata.Id;
                lr.Interlynx_LUID = String.valueOf(ldata.interlynx_LUID__c);
                lr.First_Name = ldata.FirstName;
                lr.Last_Name = ldata.LastName;
                lr.Title = ldata.Title;
                lr.Email = ldata.Email;
                lr.Company = ldata.Company;
                lr.Lead_Owner = ldata.OwnerId;
                lr.Phone = String.isNotBlank(ldata.MobilePhone) ? ldata.MobilePhone : ldata.Phone;
                lr.Website = ldata.Website;
                lr.LeadSource = ldata.LeadSource;
                lr.Description = ldata.Description;
                lr.Zip = ldata.PostalCode;
                lr.City = ldata.City;
                lr.State = ldata.State;
                lr.Country = ldata.Country;
                lr.Street = ldata.Street;
                lr.OwnerName = ldata.Owner?.Name;
                lr.OwnerEmail = ldata.Owner?.Email;
                lr.Status = ldata.Status;
                lr.Substatus = ldata.Sub_status__c;
                lr.QuotedAmount = (decimal)ldata.Quoted_Amount__c;
                lr.OrderAmount = ldata.Order_Amount__c;
                lr.OtherReason = ldata.Other_Reason__c;
                lr.ReminderDate = ldata.Reminder_Date__c;
                lr.AdditionalComments = ldata.Additional_Comments__c;
                LeadRecsWrapperList.add(lr);
            }
        }
    }
     if(LeadRecsWrapperList.size() > 0){
            Lead_System_Authentication__mdt EndPointSetting;
           EndPointSetting = [SELECT DeveloperName, Bearer_Token__c, End_Point_URL__c FROM Lead_System_Authentication__mdt WHERE DeveloperName =: 'Lead_System_Update' LIMIT 1];
            if(EndPointSetting != null){
                String EndPointLink = EndPointSetting.End_Point_URL__c;
                String AuthenticationToken = EndPointSetting.Bearer_Token__c;          
                HttpRequest req = new HttpRequest();
                req.setTimeout(120000);
                req.setHeader('Content-Type','application/json');
                String endpoint = EndPointLink;
                req.setHeader('Authorization', 'Bearer ' + AuthenticationToken);
                req.setMethod('POST');
                req.setEndpoint(endpoint);
                String JsonString=JSON.serialize(LeadRecsWrapperList);
                System.debug('!!!!!!!!!!!JsonString!!!!!!!!!!!!'+JsonString);
                req.setBody(JsonString);
                Http http = new Http();
                if(!Test.isRunningTest()){
                    HTTPResponse res = http.send(req);
                }
            }
        }
             
         
 }
    // Public static List<LeadRecord.Leadrechistory> Leadhistory( set<id>leadid)
    // {
    //    List<LeadRecord.Leadrechistory>Listrecord= new List<LeadRecord.Leadrechistory>();
    //    LeadRecord.Leadrechistory LLrecord;
    //    List<LeadHistory>Lshistory=[SELECT Field, NewValue, OldValue, CreatedById, CreatedDate,CreatedBy.Name FROM LeadHistory where leadid in : leadid];   
    //    for(LeadHistory ls : Lshistory)
    //    {
    //    LLrecord = new LeadRecord.Leadrechistory(); 
    //    LLrecord.newvalue= (string)ls.NewValue;
    //    LLrecord.oldvalue= (string)ls.OldValue;
    //    LLrecord.field=(string)ls.field;
    //    LLrecord.CreatedDate=ls.CreatedDate;
    //    LLrecord.CreatedbyName=ls.CreatedBy.Name;    
    //    Listrecord.add(LLrecord);
    //    }
    //     return Listrecord;     
        
    // }
    global class LeadRecord {
        public String InterlynxLeadId ;
        public String LeadSource;
        public String First_Name ;
        public String Last_Name;
        public String Title;
        public String Email ;
        public String Company;
        public String Phone;
        public String Phone_Researched;
        public Integer SIC;
        public String SIC_Description;
        public Integer NAICS;
        Public string NAICS_Description;
        public String LeadSourceDescription;
        public String Description;
        public String County;
        public String City;
        public String State;
        Public string CompanyType;
        public String Street;
        public String Zip;
        public String Country;
        public String Lead_Owner;
        Public string Interlynx_LUID;
        public string Website;
        Public string SalesforceId;
        Public string Supplier;
        Public string Line_Of_Business;
        public string DUNS;
        Public string Parent_Name;
        Public string No_of_Employees;
        Public string Lead_Source;
        Public String VendorName;
        Public String SupplierID;
        Public Decimal OrderAmount;
        //Public Decimal QuoteAmount;
        Public String Status;
        //Public String Interlynx_Status;
        Public String Interlynx_SubStatus;
        Public String PostedComment;
        Public string OwnerName;
        Public String OwnerEmail;
        Public String statusReason;
        Public string Substatus;
        Public decimal QuotedAmount;
        Public string OtherReason;
        Public date ReminderDate;
        Public string AdditionalComments;
        }
}