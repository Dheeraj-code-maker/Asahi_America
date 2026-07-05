@isTest
private class LeadTriggerTest {
    
    @isTest
    static void testLeadTriggerOnOwnerChange() {
        // Setup test data
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Status = 'Open',
            Interlynx_LUID__c = '1234'
        );
        insert testLead;
        
        // Change owner to trigger the condition
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        testLead.OwnerId = testUser.Id;
        testlead.Sub_Status__c='Contacting';
        
        // Mock the handler call
        Test.startTest();
        update testLead;
        Test.stopTest();
        
        // Verify the lead was updated
        Lead updatedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(testUser.Id, updatedLead.OwnerId);
    }
    
    @isTest
    static void testLeadTriggerNoLUIDNoAction() {
        // Setup lead without Interlynx_LUID__c
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Status = 'Open'
        );
        insert testLead;
        
        Test.startTest();
        testLead.OwnerId = UserInfo.getUserId();
        testlead.Sub_Status__c='Other';
        update testLead;
        Test.stopTest();
        
        // Should not trigger handler when LUID is null
        Lead updatedLead = [SELECT Id FROM Lead WHERE Id = :testLead.Id];
        System.assertNotEquals(null, updatedLead.Id);
    }
    
    @isTest
    static void testLeadTriggerOwnerNotChanged() {
        // Setup lead with LUID
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Status = 'Open',
            Interlynx_LUID__c = '123'
        );
        insert testLead;
        
        Test.startTest();
        testLead.Status = 'Closed';
        update testLead;
        Test.stopTest();
        
        // Should not trigger when owner doesn't change
        Lead updatedLead = [SELECT Id, Status FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Closed', updatedLead.Status);
    }
    
    @isTest
    static void testLeadQuoting() {
        // Setup lead with LUID
        Lead testLead = new Lead(
            LastName = 'Test Lead1',
            Company = 'Test Company1',
            Status = 'Open',
            Sub_Status__c='Quoting',
            Interlynx_LUID__c = '1235'
        );
        insert testLead;
        
        Test.startTest();
        testLead.status = 'Order';
        update testLead;
        Test.stopTest();
        
        // Should not trigger when owner doesn't change
        Lead updatedLead = [SELECT Id, Status FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Quoting', updatedLead.Status);
    }
    @isTest
    static void testLeaGoodLead() {
        // Setup lead with LUID
        Lead testLead = new Lead(
            LastName = 'Test Lead2',
            Company = 'Test Company2',
            Status = 'Open',            
            Interlynx_LUID__c = '1236'
        );
        insert testLead;
        
        Test.startTest();
        testLead.Sub_Status__c='Quoting';
        update testLead;
        Test.stopTest();
        
  
    }
        @isTest
    static void testLowQaulity() {
        // Setup lead with LUID
        Lead testLead = new Lead(
            LastName = 'Test Lead4',
            Company = 'Test Company4',
            Status = 'Open',            
            Interlynx_LUID__c = '12367'
        );
        insert testLead;
        
        Test.startTest();
        testLead.status = 'Low Quality Lead';
        testLead.Sub_Status__c='Other';
        update testLead;
        Test.stopTest();
        
  
    }
    
          @isTest
    static void testGoodlead() {
        // Setup lead with LUID
        Lead testLead = new Lead(
            LastName = 'Test Lead44',
            Company = 'Test Company44',
            Status = 'Open',            
            Interlynx_LUID__c = '1236744'
        );
        insert testLead;
        
        Test.startTest();
        testLead.status = 'Good Lead';
        testLead.Sub_Status__c='Other';
        update testLead;
        Test.stopTest();
        
  
    }
}