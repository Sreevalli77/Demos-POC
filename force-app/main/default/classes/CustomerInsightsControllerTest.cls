@isTest
private with sharing class CustomerInsightsControllerTest {

    @testSetup
    static void setupTestData() {
        Account acct = new Account(Name = 'Test Account');
        insert acct;

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test.user@example.com',
            AccountId = acct.Id
        );
        insert con;
    }

    static testMethod void testGetCustomerInsights() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
            CustomerInsightsController.CustomerInsightData data = CustomerInsightsController.getCustomerInsights(con.Id);
        Test.stopTest();

        System.assertNotEquals(null, data, 'Expected returned insight data.');
        System.assertEquals(con.Id, data.contactId, 'Contact Id should match.');
        System.assertEquals('Test', data.firstName, 'First name should be populated.');
        System.assertEquals('User', data.lastName, 'Last name should be populated.');
        System.assertEquals('test.user@example.com', data.email, 'Email should be populated.');
        System.assertEquals('Test Account', data.accountName, 'Account name should be populated.');
        System.assertNotEquals(null, data.engagementScore, 'Engagement score should be returned.');
        System.assertNotEquals(null, data.intentLevel, 'Intent level should be returned.');
        System.assertNotEquals(null, data.daysSinceLastActivity, 'Days since last activity should be returned.');
        System.assertEquals('CRM Pro', data.topProductInterest, 'Top product interest should be mocked as CRM Pro.');
        System.assertEquals(5, data.recentActivities.size(), 'Expected five mock recent activities.');
    }

    static testMethod void testGetRecommendationMedium() {
        String recommendation = CustomerInsightsController.getRecommendation('003000000000001', 45, 'MEDIUM');

        System.assertNotEquals(null, recommendation, 'Recommendation must not be null.');
        System.assert(recommendation.contains('NURTURE'), 'MEDIUM intent should return a nurture recommendation.');
    }

    static testMethod void testGetRecommendationHigh() {
        String recommendation = CustomerInsightsController.getRecommendation('003000000000002', 80, 'HIGH');

        System.assertNotEquals(null, recommendation, 'Recommendation must not be null.');
        System.assert(recommendation.contains('HIGH PRIORITY'), 'HIGH intent should return a high priority recommendation.');
    }

    static testMethod void testGetRecommendationLow() {
        String recommendation = CustomerInsightsController.getRecommendation('003000000000003', 10, 'LOW');

        System.assertNotEquals(null, recommendation, 'Recommendation must not be null.');
        System.assert(recommendation.contains('RE-ENGAGE'), 'LOW intent should return a re-engage recommendation.');
    }
}