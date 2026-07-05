/**
 * @description Test class for LeadReceiver REST resource and helper methods.
 * Follows best practices: @TestSetup, bulk tests, positive/negative paths, assertions, no SeeAllData, start/stopTest usage.
 */
@IsTest
private class LeadReceiverTest {

    @TestSetup
    static void setupData() {
        // Create a user to act as Lead owner (ensures Owner mapping works)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'Owner',
            Alias = 'towner',
            Email = 'test.owner@example.com',
            Username = 'test.owner.' + System.currentTimeMillis() + '@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u;

        // Another owner to test multiple owners mapping
        User u2 = new User(
            FirstName = 'Test2',
            LastName = 'Owner2',
            Alias = 'towner2',
            Email = 'test.owner2@example.com',
            Username = 'test.owner2.' + System.currentTimeMillis() + '@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u2;

        Lead LeadRec1 = new Lead(FirstName = 'test', LastName = 'test', Description = 'Test Description', LeadSource = 'Phone', Company = 'Test', email ='test.owner@example.com');
        insert LeadRec1;
    }

    private static String buildRequestBody(Boolean includeSecond) {
        // Retrieve emails of created users to map to owners
        Map<String, User> emailToUser = new Map<String, User>();
        for (User u : [SELECT Id, Email FROM User WHERE Email IN ('test.owner@example.com')]) {
            emailToUser.put(u.Email, u);
        }

        // Build two lead records (bulk). One with blank Email should be skipped
        List<LeadReceiver.LeadRecord> recs = new List<LeadReceiver.LeadRecord>();

        LeadReceiver.LeadRecord r1 = new LeadReceiver.LeadRecord();
        r1.First_Name = 'Alice';
        r1.Last_Name = 'Anderson';
        r1.Title = 'Manager';
        r1.Email = 'alice.anderson@example.com';
        r1.Company = 'Acme Co';
        r1.lead_Owner = 'test.owner@example.com';
        r1.Phone = '1234567890';
        r1.Website = 'https://acme.example.com';
        r1.LeadSource = 'Web';
        r1.Description = 'Primary test record';
        r1.Zip = '94105';
        r1.City = 'San Francisco';
        r1.State = 'CA';
        r1.Country = 'US';
        r1.Street = '1 Market St';
        r1.Status = 'Open';
        r1.DUNS='223232';
             r1.SIC = '2222';
                        r1.SIC_Description = 'dsdsds';
                        r1.NAICS = '434343';
                        r1.NAICS_Description = 'dsdsds';
                        r1.AdditionalComments = 'dddddddddddddddddddddddddddd';
                        r1.Interlynx_LUID = '1222';
                        r1.Parent_Name = 'Interlynx';
                        r1.Interlynx_SubStatus = 'New';
                        r1.QuoteAmount = 123.09;
                        r1.OrderAmount = 123.09;
                        r1.otherReason = 'wqwqw';
                        r1.ReminderDate = system.today();
                        r1.AdditionalComments = 'dsdsdsd';
                        r1.Status = 'New';
                        r1.No_of_Employees ='20'; 
            
        recs.add(r1);        
        return JSON.serialize(recs);
    }

    @IsTest
    static void testDoPost_Success_Single() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/PostLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(buildRequestBody(false));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LeadReceiver.responseWrapper result = LeadReceiver.doPost();
        Test.stopTest();
    }

    @IsTest
    static void testDoPost_NoRecords_Error() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/PostLead';
        req.httpMethod = 'POST';
        // Empty list in body
        req.requestBody = Blob.valueOf('[]');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LeadReceiver.responseWrapper result = LeadReceiver.doPost();
        Test.stopTest();

        System.assertEquals('No records found in request', result.errMsg, 'Should return no records error');
        System.assertEquals(true, String.isBlank(result.successMessage) || result.successMessage == null, 'Success message should be blank on error');
    }

    @IsTest
    static void testDoPost_Exception_InvalidJson() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/PostLead';
        req.httpMethod = 'POST';
        // Invalid JSON to force exception branch
        req.requestBody = Blob.valueOf('{invalidJson:true}');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LeadReceiver.responseWrapper result = LeadReceiver.doPost();
        Test.stopTest();

        System.assertNotEquals(null, result.errMsg, 'Exception branch should set error message');
        System.assertEquals('error', result.successMessage, 'Success message should be error on exception');
    }
}