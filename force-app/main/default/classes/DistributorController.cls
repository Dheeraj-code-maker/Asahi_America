public without sharing class DistributorController {
    @AuraEnabled(cacheable=true)
    public static List<DistributorOption> getDistributorOptionsForLead(Id leadId) {
        if (leadId == null) return new List<DistributorOption>();
        Lead ld = [SELECT Id, OwnerId FROM Lead WHERE Id = :leadId LIMIT 1];
        if (ld == null || ld.OwnerId == null) return new List<DistributorOption>();

        // Accounts owned by the lead owner that reference a Distributor lookup field
        List<Account> accs = [
            SELECT Id, Name
            FROM Account
            WHERE OwnerId = :ld.OwnerId AND type = 'Distributor'
              AND Name != null Order by Name ASC
        ];

        Map<Id, DistributorOption> mapid = new Map<Id, DistributorOption>();
        for (Account a : accs) {
            if (a.Name != null) {
                Id dId = a.Id;
                String dName = a.Name != null ? a.Name : String.valueOf(dId);
                if (!mapid.containsKey(dId)) {
                    mapid.put(dId, new DistributorOption(dId, dName));
                }
            }
        }

        return mapid.values();
    }

    @AuraEnabled
    public static Boolean saveSelectedDistributor(Id leadId, Id distributorId) {
        if (leadId == null || distributorId == null) return false;
        Lead ld = [SELECT Id,Forwarding_Distributor__c FROM Lead WHERE Id = :leadId LIMIT 1];
        // Save the selected distributor to the Lead.Distributor__c lookup
        ld.Forwarding_Distributor__c = distributorId;
        update ld;
        return true;
    }

    public  class DistributorOption {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;

        public DistributorOption(Id id, String name) {
            this.id = id;
            this.name = name;
        }
    }
}