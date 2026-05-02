public with sharing class CustomerInsightsControllerDynamic {
    public class CustomerInsightData {
        @AuraEnabled public String contactId;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String email;
        @AuraEnabled public String accountName;
        @AuraEnabled public Integer engagementScore;
        @AuraEnabled public String intentLevel;
        @AuraEnabled public Integer daysSinceLastActivity;
        @AuraEnabled public String topProductInterest;
        @AuraEnabled public List<ActivityRecord> recentActivities;
    }

    public class ActivityRecord {
        @AuraEnabled public String eventType;
        @AuraEnabled public String pageUrl;
        @AuraEnabled public String productName;
        @AuraEnabled public String eventDate;
        @AuraEnabled public String iconName;
    }

    @AuraEnabled(cacheable=true)
    public static CustomerInsightData getCustomerInsights(String contactId) {
        Contact con = [SELECT Id, FirstName, LastName, Email, Account.Name 
                       FROM Contact WHERE Id = :contactId LIMIT 1];

        CustomerInsightData data = new CustomerInsightData();
        data.contactId = con.Id;
        data.firstName = con.FirstName;
        data.lastName = con.LastName;
        data.email = con.Email;
        data.accountName = con.Account?.Name;
        
        // Mocking the data (Replace with Data Cloud/Calculated Insights logic)
        data.engagementScore = 75; 
        data.intentLevel = 'HIGH';
        data.daysSinceLastActivity = 2;
        data.topProductInterest = 'CRM Pro';
        data.recentActivities = getMockActivities();
        return data;
    }

    @AuraEnabled
    public static String getRecommendation(String contactId, Integer engagementScore, String intentLevel) {
        if (intentLevel == 'HIGH') return '🔥 HIGH PRIORITY: Schedule a discovery call immediately.';
        return '📧 NURTURE: Send a personalized demo invite.';
    }

    private static List<ActivityRecord> getMockActivities() {
        List<ActivityRecord> acts = new List<ActivityRecord>();
        ActivityRecord a = new ActivityRecord();
        a.eventType = 'Product View';
        a.productName = 'CRM Pro';
        a.eventDate = '2026-04-28';
        a.iconName = 'utility:preview';
        acts.add(a);
        return acts;
    }
}