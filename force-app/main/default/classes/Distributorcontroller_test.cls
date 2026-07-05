@IsTest
public class Distributorcontroller_test {
    static void testGetDistributorOptionsForLead() {
        Id currentUserId = UserInfo.getUserId();

        Account distributorA = new Account(Name = 'Alpha Distributor', Type = 'Distributor', OwnerId = currentUserId);
        Account distributorB = new Account(Name = 'Beta Distributor', Type = 'Distributor', OwnerId = currentUserId);
        insert new List<Account>{distributorA, distributorB};

        Lead leadRecord = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'TestCo', OwnerId = currentUserId);
        insert leadRecord;

        Test.startTest();
        //List<DistributorController.DistributorOption> options = DistributorController.getDistributorOptionsForLead(leadRecord.Id);
        DistributorController.getDistributorOptionsForLead(leadRecord.Id);
        Test.stopTest();

       // System.assertEquals(2, options.size(), 'Expected two distributor options');
        //System.assertEquals(distributorA.Id, options[0].id, 'Expected options ordered by name');
        //System.assertEquals(distributorB.Id, options[1].id, 'Expected options ordered by name');
    }

    @IsTest
    static void testSaveSelectedDistributor() {
        Id currentUserId = UserInfo.getUserId();

        Account distributor = new Account(Name = 'Selected Distributor', Type = 'Distributor', OwnerId = currentUserId);
        insert distributor;

        Lead leadRecord = new Lead(FirstName = 'Save', LastName = 'Test', Company = 'TestCo', OwnerId = currentUserId);
        insert leadRecord;

        Test.startTest();
        Boolean result = DistributorController.saveSelectedDistributor(leadRecord.Id, distributor.Id);
        Test.stopTest();

        System.assert(result, 'Expected saveSelectedDistributor to return true');
        leadRecord = [SELECT Id, Forwarding_Distributor__c FROM Lead WHERE Id = :leadRecord.Id];
        System.assertEquals(distributor.Id, leadRecord.Forwarding_Distributor__c, 'Expected lead forwarding distributor to be set');
    }
    @IsTest
    static void getDistributorOptionsForLead() {
       Id currentUserId = UserInfo.getUserId();

        Account distributorA = new Account(Name = 'Alpha Distributor', Type = 'Distributor', OwnerId = currentUserId);
        Account distributorB = new Account(Name = 'Beta Distributor', Type = 'Distributor', OwnerId = currentUserId);
        insert new List<Account>{distributorA, distributorB};

        Lead leadRecord = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'TestCo', OwnerId = currentUserId);
        insert leadRecord;

        Test.startTest();
        List<DistributorController.DistributorOption> options = DistributorController.getDistributorOptionsForLead(leadRecord.Id);    
        Test.stopTest();

         System.assertEquals(2, options.size(), 'Expected two distributor options');
         System.assertEquals(distributorA.Id, options[0].id, 'Expected options ordered by name');
        System.assertEquals(distributorB.Id, options[1].id, 'Expected options ordered by name');
    }
}