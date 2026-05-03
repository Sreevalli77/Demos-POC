public with sharing class CustomerInsightsController {

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
        @AuraEnabled public String aiRecommendation;
    }

    public class ActivityRecord {
        @AuraEnabled public String eventType;
        @AuraEnabled public String pageUrl;
        @AuraEnabled public String productName;
        @AuraEnabled public String eventDate;
        @AuraEnabled public String iconName;
    }

    public class ContactSearchResult {
        @AuraEnabled public String contactId;
        @AuraEnabled public String name;
        @AuraEnabled public String email;
        @AuraEnabled public String accountName;
    }

    @AuraEnabled(cacheable=true)
    public static CustomerInsightData getCustomerInsights(String contactId) {
        CustomerInsightData data = new CustomerInsightData();

        // Fetch Contact
        Contact con = [
            SELECT Id, FirstName, LastName, Email, Account.Name
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];

        data.contactId    = con.Id;
        data.firstName    = con.FirstName;
        data.lastName     = con.LastName;
        data.email        = con.Email;
        data.accountName  = con.Account?.Name;

        // Mock Calculated Insights
        // In production, these come from Data Cloud via Connect API
        data.engagementScore       = getMockEngagementScore(contactId);
        data.intentLevel           = getMockIntentLevel(data.engagementScore);
        data.daysSinceLastActivity = getMockRecency(contactId);
        data.topProductInterest    = 'CRM Pro';
        data.recentActivities      = getMockActivities(contactId);
        data.aiRecommendation      = '';  // fetched separately via getRecommendation()

        return data;
    }

    @AuraEnabled(cacheable=true)
    public static List<ContactSearchResult> searchContacts(String searchTerm) {
        if (String.isBlank(searchTerm) || searchTerm.length() < 2) {
            return new List<ContactSearchResult>();
        }

        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email, Account.Name
            FROM Contact
            WHERE (FirstName LIKE :('%' + searchTerm + '%') OR LastName LIKE :('%' + searchTerm + '%'))
            LIMIT 5
        ];

        List<ContactSearchResult> results = new List<ContactSearchResult>();
        for (Contact con : contacts) {
            ContactSearchResult result = new ContactSearchResult();
            result.contactId = con.Id;
            result.name = (con.FirstName != null ? con.FirstName + ' ' : '') + con.LastName;
            result.email = con.Email;
            result.accountName = con.Account?.Name;
            results.add(result);
        }

        return results;
    }

    @AuraEnabled
    public static String getRecommendation(String contactId,
                                            Integer engagementScore,
                                            String intentLevel) {
        // In production: call Einstein Prompt Template or Agentforce API
        // Here we return deterministic mock responses
        if (intentLevel == 'HIGH' && engagementScore >= 60) {
            return '🔥 HIGH PRIORITY: Customer shows strong buying signals. '
                                  + 'Schedule a discovery call within 24 hours. '
                                  + 'Lead with ROI metrics and reference the CRM Pro pages they visited.';
        } else if (intentLevel == 'MEDIUM') {
            return '📧 NURTURE: Customer is warming up. '
                                  + 'Send a personalized demo invite for the Analytics module this week.';
        } else {
            return '💤 RE-ENGAGE: Low recent activity. '
                                  + 'Enroll in a 3-touch email nurture sequence. '
                                  + 'Start with a relevant case study.';
        }
    }

    // ── Private helpers (mock data — replace with real DLO/DMO queries) ──

    private static Integer getMockEngagementScore(String contactId) {
        // Deterministic mock based on contactId hash
        return Math.mod(Math.abs(contactId.hashCode()), 100);
    }

    private static String getMockIntentLevel(Integer score) {
        if (score >= 60) return 'HIGH';
        if (score >= 30) return 'MEDIUM';
        return 'LOW';
    }

    private static Integer getMockRecency(String contactId) {
        return Math.mod(Math.abs(contactId.hashCode()), 30) + 1;
    }

    private static List<ActivityRecord> getMockActivities(String contactId) {
        List<ActivityRecord> activities = new List<ActivityRecord>();

        ActivityRecord a1 = new ActivityRecord();
        a1.eventType   = 'Product View';
        a1.productName = 'CRM Pro';
        a1.eventDate   = '2026-04-28';
        a1.iconName    = 'utility:preview';
        activities.add(a1);

        ActivityRecord a2 = new ActivityRecord();
        a2.eventType = 'Page View';
        a2.pageUrl   = '/pricing';
        a2.eventDate = '2026-04-27';
        a2.iconName  = 'utility:open';
        activities.add(a2);

        ActivityRecord a3 = new ActivityRecord();
        a3.eventType = 'Form Submit';
        a3.pageUrl   = '/contact-us';
        a3.eventDate = '2026-04-26';
        a3.iconName  = 'utility:email';
        activities.add(a3);

        ActivityRecord a4 = new ActivityRecord();
        a4.eventType   = 'Product View';
        a4.productName = 'Analytics Suite';
        a4.eventDate   = '2026-04-25';
        a4.iconName    = 'utility:preview';
        activities.add(a4);

        ActivityRecord a5 = new ActivityRecord();
        a5.eventType = 'Video Watch';
        a5.pageUrl   = '/demo-video';
        a5.eventDate = '2026-04-24';
        a5.iconName  = 'utility:video';
        activities.add(a5);

        return activities;
    }
}