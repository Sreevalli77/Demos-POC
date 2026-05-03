public with sharing class AgentforceDynamicMockAction {

    public class RecommendationOutput {
        @InvocableVariable(label='Engagement Score')
        public Integer engagementScore;
        
        @InvocableVariable(label='Intent Level')
        public String intentLevel;

        @InvocableVariable(label='Recommended Action')
        public String recommendedAction;
        
        @InvocableVariable(label='Urgency')
        public String urgency;

        @InvocableVariable(label='Reasoning')
        public String reasoning;
    }

    @InvocableMethod(label='Get Dynamic Mock Action' description='Uses Record ID hash to generate stable mock scores for testing.')
    public static List<RecommendationOutput> getDynamicRecommendation(List<Id> recordIds) {
        List<RecommendationOutput> results = new List<RecommendationOutput>();
        
        for (Id recId : recordIds) {
            RecommendationOutput output = new RecommendationOutput();

            // 1. GENERATE DETERMINISTIC MOCK DATA
            // Get the absolute hashcode of the ID string
            Integer hash = Math.abs(String.valueOf(recId).hashCode());
            
            // Generate a score between 0 and 100 based on hash
            output.engagementScore = Math.mod(hash, 101); 
            
            // Determine Intent Level based on hash (3 levels)
            Integer intentFactor = Math.mod(hash, 3);
            if (intentFactor == 0) output.intentLevel = 'HIGH';
            else if (intentFactor == 1) output.intentLevel = 'MEDIUM';
            else output.intentLevel = 'LOW';

            // 2. APPLY BUSINESS LOGIC (From your Part 2.3 requirements)
            if (output.intentLevel == 'HIGH' && output.engagementScore >= 60) {
                output.urgency = 'IMMEDIATE';
                output.recommendedAction = 'Schedule a discovery call within 24 hours';
                output.reasoning = 'Generated High Intent + High Score signal for this specific record ID.';
            } 
            else if (output.intentLevel == 'MEDIUM' && output.engagementScore >= 40) {
                output.urgency = 'THIS_WEEK';
                output.recommendedAction = 'Send personalized product demo invite';
                output.reasoning = 'Record shows moderate interest and recent activity in our simulated model.';
            } 
            else {
                output.urgency = 'NURTURE';
                output.recommendedAction = 'Enroll in email nurture campaign';
                output.reasoning = 'Engagement score below threshold; recommended for long-term marketing nurture.';
            }

            results.add(output);
        }
        return results;
    }
}