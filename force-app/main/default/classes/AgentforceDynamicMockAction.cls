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

            // Get a deterministic hashcode for the ID string
            Integer rawHash = String.valueOf(recId).hashCode();

            Integer score = Math.mod(rawHash, 101);
            if (score < 0) score += 101;
            output.engagementScore = score;

            if (output.engagementScore > 80) {
                output.intentLevel = 'HIGH';
            } else if (output.engagementScore > 40) {
                output.intentLevel = 'MEDIUM';
            } else {
                output.intentLevel = 'LOW';
            }

            System.debug('hash' + rawHash);
            System.debug('engagementScore' + output.engagementScore);
            System.debug('intentLevel' + output.intentLevel);

            if (output.intentLevel == 'HIGH') {
                output.urgency = 'IMMEDIATE';
                output.recommendedAction = 'Schedule a discovery call within 24 hours';
                output.reasoning = 'Engagement score over 80; high intent and priority.';
            } else if (output.intentLevel == 'MEDIUM') {
                output.urgency = 'THIS_WEEK';
                output.recommendedAction = 'Send personalized product demo invite';
                output.reasoning = 'Engagement score between 41 and 80; moderate intent.';
            } else {
                output.urgency = 'NURTURE';
                output.recommendedAction = 'Enroll in email nurture campaign';
                output.reasoning = 'Engagement score 40 or below; recommend long-term nurture.';
            }

            results.add(output);
        }
        return results;
    }
}