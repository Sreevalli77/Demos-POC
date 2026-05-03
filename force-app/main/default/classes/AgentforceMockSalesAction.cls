public with sharing class AgentforceMockSalesAction {

    // Structure the output so the Agent understands the fields
    public class RecommendationOutput {
        @InvocableVariable(label='Engagement Score' description='Mocked Score 0-100')
        public Integer engagementScore;
        
        @InvocableVariable(label='Intent Level' description='Mocked Level: HIGH, MEDIUM, or LOW')
        public String intentLevel;

        @InvocableVariable(label='Recommended Action' description='The calculated next step')
        public String recommendedAction;
        
        @InvocableVariable(label='Urgency' description='How fast to act')
        public String urgency;

        @InvocableVariable(label='Reasoning' description='Explanation for the recommendation')
        public String reasoning;
    }

    @InvocableMethod(label='Get Mock Next Best Action' description='Simulates customer insights to test Agent reasoning.')
    public static List<RecommendationOutput> getMockRecommendation(List<Id> recordIds) {
        List<RecommendationOutput> results = new List<RecommendationOutput>();
        
        for (Id recId : recordIds) {
            RecommendationOutput output = new RecommendationOutput();

            // --- MOCK DATA PROVIDER ---
            // In a real scenario, this would be a SOQL query. 
            // Here, we assume high engagement for testing purposes.
            output.engagementScore = 82; 
            output.intentLevel = 'HIGH';
            Integer mockDaysSinceActivity = 2;
            // ---------------------------

            // Logic Integration (The "Rules Engine")
            if (output.intentLevel == 'HIGH' && output.engagementScore >= 60) {
                output.urgency = 'IMMEDIATE';
                output.recommendedAction = 'Schedule a discovery call within 24 hours';
                output.reasoning = 'High engagement + high intent signals buying readiness (Mocked Data)';
            } 
            else if (output.intentLevel == 'MEDIUM' && mockDaysSinceActivity <= 7) {
                output.urgency = 'THIS_WEEK';
                output.recommendedAction = 'Send personalized product demo invite';
                output.reasoning = 'Recent activity with moderate interest — warm lead (Mocked Data)';
            } 
            else {
                output.urgency = 'NURTURE';
                output.recommendedAction = 'Enroll in email nurture campaign';
                output.reasoning = 'Low recent engagement — keep brand top of mind (Mocked Data)';
            }

            results.add(output);
        }
        return results;
    }
}