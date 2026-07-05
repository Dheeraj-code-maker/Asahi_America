//Asahi iNterlynx Lead Receiver class
@RestResource(urlMapping='/PostLead')
global with sharing class LeadReceiver{
public static Id existingAccountId;
    public static String existingAccountOwner;
    public static Contact contactToBeInserted;
    public static boolean taskCreation = false;
    public static boolean keyAcc = false;
    public static boolean oppCreation = false;
    public static String Accountcriteria;
    public static string Contactid;
    public static string ContactOnwerid;
    public static string ContactName;
    
    @HttpPost
    global static responseWrapper doPost() 
    {
        List<Lead> leadsToBeUpdated = new List<Lead>();
        Set<Id> updatedLeadIds = new Set<Id>();
        Set<String> EmailList = new Set<String>();
        Set<String> Ownerrecord = new Set<String>();
        Map<String, Id> owneremail = new Map<String, Id>();
        Map<String, Id> leadstatus = new Map<String, Id>();
        Map<String, Id> checkcondition = new Map<String, Id>();
        responseWrapper objResWrapper = new responseWrapper();
        List<Lead> LeadRecsList = new List<Lead>();
        Map<String, List<String>> accOwner = new Map<String, List<String>>();
       List<wrapperAccountAndContact> objWrapper = new List<wrapperAccountAndContact>();
        Id LeadRecId;
        
        try {
            List<LeadRecord> RecordDataList = (List<LeadRecord>) JSON.deserialize(
                RestContext.request.requestBody.toString(), 
                List<LeadRecord>.class
            );
            System.debug('Print record' + RecordDataList);
            
            if (RecordDataList == null || RecordDataList.isEmpty()) {
                objResWrapper.errMsg = 'No records found in request';
                return objResWrapper;
            }
            
            // Collect emails and owners
            for (LeadRecord leadRec : RecordDataList) {
                if (String.isNotBlank(leadRec.Email)) {
                    EmailList.add(leadRec.Email);
                }
                if (String.isNotBlank(leadRec.lead_Owner)) {
                    Ownerrecord.add(leadRec.lead_Owner);
                }
               objWrapper.add(searchAccountAndContact.searchAccountAndContactCall(leadRec));
            }
            
            // Query and map owners
            if (!Ownerrecord.isEmpty()) {
                for (User u : [SELECT Email, Id FROM User WHERE Email IN :Ownerrecord]) {
                    owneremail.put(u.Email, u.Id);
                }
            }
            // call the account and contact search method            
            // Add Distributor forwarding list
            // for (LeadRecord leadRec : RecordDataList) {
            //     if (String.isNotBlank(leadRec.lead_Owner)) {
            //         for (Account atm : [SELECT Name, Type,Owner.Email FROM Account WHERE Owner.Email = :leadRec.lead_Owner AND Type = 'Distributor']) {
            //             // add null/blank check for account name before putting into map
            //             if (atm != null && String.isNotBlank(atm.Name)) {
            //                 if (!accOwner.containsKey(leadRec.lead_Owner)) {
            //                     accOwner.put(leadRec.lead_Owner, new List<String>());
            //                 }
            //                 accOwner.get(leadRec.lead_Owner).add(atm.Name);
            //             }
            //         }
            //     }
            // }
            
            // Create leads
            if (!EmailList.isEmpty()) {
                for (LeadRecord leadRec : RecordDataList) {
                    if (String.isBlank(leadRec.Email)) {
                        continue;
                    }
                    Lead leadinsert = new Lead();
                    if (String.isNotBlank(leadRec.First_Name)) {
                        leadinsert.FirstName = leadRec.First_Name;
                        leadinsert.LastName = String.isNotBlank(leadRec.Last_Name) ? leadRec.Last_Name : leadRec.First_Name;
                        leadinsert.Title = leadRec.Title;
                        leadinsert.Email = leadRec.Email;
                        leadinsert.Company = leadRec.Company;
                        leadinsert.OwnerId = owneremail.get(leadRec.lead_Owner);
                        leadinsert.Phone = leadRec.Phone;
                        leadinsert.Website = leadRec.Website;
                        leadinsert.LeadSource = leadRec.LeadSource;
                        leadinsert.Description = leadRec.Description;
                        leadinsert.PostalCode = leadRec.Zip;
                        leadinsert.City = leadRec.City;
                        leadinsert.Rating = 'Hot';
                        leadinsert.State = leadRec.State;
                        leadinsert.MobilePhone = leadRec.Phone_Researched;
                        leadinsert.Line_Of_Business__c = leadRec.Line_Of_Business;
                        leadinsert.Country = leadRec.Country;
                        leadinsert.Street = leadRec.Street;
                        leadinsert.NumberOfEmployees = integer.valueof(leadRec.No_of_Employees);
                        leadinsert.DUNS__c = string.valueof(leadRec.DUNS);
                        leadinsert.SIC__c = leadRec.SIC;
                        leadinsert.SIC_Description__c = leadRec.SIC_Description;
                        leadinsert.NAICS__c = leadRec.NAICS;
                        leadinsert.NAICS_Description__c = leadRec.NAICS_Description != null ? leadRec.NAICS_Description : '';
                        //leadinsert.Lead_Comments__c = leadRec.Description != null ? leadRec.Description.replaceAll('<[^>]*>', '').replaceAll('[^a-zA-Z0-9\\s]', '') : '';
                        leadinsert.Lead_Comments__c = leadRec.Description != null ? leadRec.Description.replaceAll('<[^>]*>', '').replaceAll('[^a-zA-Z0-9\\s.,\\-/]', '').trim(): '';
                        leadinsert.Interlynx_LUID__c = leadRec.Interlynx_LUID;
                        leadinsert.Parent_Name__c = leadRec.Parent_Name;
                        leadinsert.Sub_status__c = leadRec.substatus;
                        leadinsert.Quoted_Amount__c = leadRec.QuoteAmount;
                        leadinsert.Order_Amount__c = leadRec.OrderAmount;
                        leadinsert.Other_Reason__c = leadRec.otherReason;
                        leadinsert.Reminder_Date__c = leadRec.ReminderDate;                        
                        leadinsert.Additional_Comments__c = leadRec.AdditionalComments;
                        leadinsert.Status = String.isNotBlank(leadRec.Status) ? leadRec.Status : 'New';
                        leadinsert.put('RecordTypeId', Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Interlynx_Lead').getRecordTypeId());                    
                        LeadRecsList.add(leadinsert);
                    }
                }
            }
            
            // Upsert leads
            if (!LeadRecsList.isEmpty()) {
                Schema.SObjectField externalField = Lead.Fields.Interlynx_LUID__c;
                Database.UpsertResult[] upsrtResultList = Database.upsert(LeadRecsList, externalField, false);
                
                for (Database.UpsertResult ur : upsrtResultList) {
                    if (ur.isSuccess()) {
                        LeadRecId = ur.getId();
                        if (!RecordDataList.isEmpty() && String.isNotBlank(LeadRecId)) {
                            Id attachment = addAttachment(RecordDataList, LeadRecId);
                            objResWrapper.Attachmentid = attachment;
                        }
                        objResWrapper.SalesforceId = LeadRecId;
                        objResWrapper.successMessage = 'Lead inserted or updated successfully';
                    } else {
                        for (Database.Error err : ur.getErrors()) {
                            objResWrapper.errMsg = err.getStatusCode() + ': ' + err.getMessage();
                            objResWrapper.successMessage = 'error';
                        }
                    }
                }
            }
        } catch (Exception ex) {
            objResWrapper.errMsg = 'Exception: ' + ex.getMessage();
            objResWrapper.successMessage = 'error';
            System.debug('Error: ' + ex.getStackTraceString());
        }
        
        return objResWrapper;
    }
    public static Id addAttachment(List<LeadRecord> rec, Id recordId) {
        ContentDocumentLink conDocLink;
        ContentVersion conVer;
        
        if (String.isBlank(rec[0].AttachmentName) || rec[0].Body == null) {
            return null;
        }
        
        List<ContentVersion> attachIdList = [SELECT Id, VersionData, PathOnClient FROM ContentVersion WHERE Id = :rec[0].Attachmentid];
        
        conVer = new ContentVersion();
        conVer.PathOnClient = rec[0].AttachmentName;
        conVer.Title = rec[0].AttachmentName;
        conVer.VersionData = EncodingUtil.base64Decode(rec[0].Body);
        conVer.ContentLocation = 'S';
        
        if (!attachIdList.isEmpty()) {
            conVer.Id = attachIdList[0].Id;
        }
        
        upsert conVer;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;
        
        conDocLink = new ContentDocumentLink();
        conDocLink.LinkedEntityId = recordId;
        conDocLink.ContentDocumentId = conDocId;
        conDocLink.ShareType = 'V';
        
        upsert conDocLink;
        
        return conVer.Id;
    }

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
        public String SIC;
        public String SIC_Description;
        public String NAICS;
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
        public string Interlynx_LUID;
        public string Website;
        Public string SalesforceId;
        Public string Supplier;
        Public string Line_Of_Business;
        Public string Files;
        public string DUNS;
        Public string Parent_Name;
        Public string No_of_Employees;
        Public string Lead_Source;
        Public string Body;
        Public string AttachmentName;
        Public string Attachmentid;
        Public String VendorName;
        Public String SupplierID;
        Public Decimal OrderAmount;
        Public Decimal QuoteAmount;
        Public String Status;
        Public String Interlynx_Status;
        Public String Interlynx_SubStatus;
        Public String PostedComment;
        public string LeadComment;
        public string QueueId;
        public string Line_Of_Buisness;
        public string substatus;
        public string otherReason;
        public date ReminderDate;
        public string address;
        public string AdditionalComments;
    }

    
       global class responseWrapper {
        public String SalesforceId;
        public String errMsg;
        Public string successMessage;
        Public string Attachmentid;
        Public string AttachmentMessage;
    }
        
}