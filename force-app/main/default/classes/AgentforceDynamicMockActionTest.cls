@isTest
private class AgentforceDynamicMockActionTest {

    @isTest
    static void testGetDynamicRecommendation_MultiplePaths() {
        List<Id> recordIds = new List<Id>{
            Id.valueOf('001000000000AAE'), // HIGH intent, high engagement
            Id.valueOf('003000000000000AAA'), // MEDIUM intent, high engagement
            Id.valueOf('001000000000000AAB')  // HIGH intent, low engagement
        };

        Test.startTest();
        List<AgentforceDynamicMockAction.RecommendationOutput> results = AgentforceDynamicMockAction.getDynamicRecommendation(recordIds);
        Test.stopTest();

        System.assertEquals(3, results.size(), 'Expected three recommendations returned.');

        AgentforceDynamicMockAction.RecommendationOutput highOutput = results[0];
        System.assertEquals(98, highOutput.engagementScore, 'High output engagement score should match.');
        System.assertEquals('HIGH', highOutput.intentLevel, 'High output intent level should be HIGH.');
        System.assertEquals('IMMEDIATE', highOutput.urgency, 'High output urgency should be IMMEDIATE.');
        System.assertEquals('Schedule a discovery call within 24 hours', highOutput.recommendedAction);
        System.assertEquals('Generated High Intent + High Score signal for this specific record ID.', highOutput.reasoning);

        AgentforceDynamicMockAction.RecommendationOutput mediumOutput = results[1];
        System.assertEquals(86, mediumOutput.engagementScore, 'Medium output engagement score should match.');
        System.assertEquals('MEDIUM', mediumOutput.intentLevel, 'Medium output intent level should be MEDIUM.');
        System.assertEquals('THIS_WEEK', mediumOutput.urgency, 'Medium output urgency should be THIS_WEEK.');
        System.assertEquals('Send personalized product demo invite', mediumOutput.recommendedAction);

        AgentforceDynamicMockAction.RecommendationOutput nurtureOutput = results[2];
        System.assertEquals(18, nurtureOutput.engagementScore, 'Nurture output engagement score should match.');
        System.assertEquals('HIGH', nurtureOutput.intentLevel, 'Nurture output intent level should be HIGH.');
        System.assertEquals('NURTURE', nurtureOutput.urgency, 'Nurture output urgency should be NURTURE.');
        System.assertEquals('Enroll in email nurture campaign', nurtureOutput.recommendedAction);
    }

    @isTest
    static void testGetDynamicRecommendation_EmptyList() {
        Test.startTest();
        List<AgentforceDynamicMockAction.RecommendationOutput> results = AgentforceDynamicMockAction.getDynamicRecommendation(new List<Id>());
        Test.stopTest();

        System.assertNotEquals(null, results, 'Method should return a list even when input is empty.');
        System.assertEquals(0, results.size(), 'Expected no recommendation outputs for empty input.');
    }
}