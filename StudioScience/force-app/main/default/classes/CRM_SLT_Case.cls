/**
    @company : Copyright © 2020, BeamSuntory
    All rights reserved.
    Redistribution and use in source form, with or without modification, are prohibited without the express written consent of BeamSuntory,Inc.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
    IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    @website : https://www.beamsuntory.com/
    @author BeamSuntory
    @version V_1.0
    @date 01/03/2023
    @description This selector class is created to fetch case details.
*/
public class CRM_SLT_Case {
    /**
    *  @description : This method is use to fetch case Record by id(CRM).
    *  @args        : String 
    *  @return      : Case
    **/
    public static Case getCasesOwnerName(ID caseId, Set<String> dynamicFieldsApiName) {
        String query = 'SELECT Id, ParentId, Owner.Name, Brand__c, trigger_word__c, Consumer_Country__c, Description,' 
                      	   +'AdditionalInformation__c, How_can_we_help__c,';
        if(dynamicFieldsApiName.size() > 0){
            for(String apiName : dynamicFieldsApiName){
                if(!query.contains(apiName)){
                   query = query + ' '+ apiName + ','; 
                }
            }
        }
        query = query.substring(0, query.length() -1);
        query = query + ' FROM Case Where ID =: caseId';
        List <Case> lstOfRecords = Database.query(query);
        Case recordCase = new Case();
        recordCase = lstOfRecords.size()>0  ? lstOfRecords[0] : null;
        return recordCase;
    }
    
    public static List<case> getQClaimAndCInquiryRecorTypeCases(Date startDate, Date endDate, List<String> recordTypeList) {
		DateTime now = DateTime.now();
        DateTime apexStartDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
        DateTime apexEndDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 23, 59, 59);
        Long offset = DateTime.newInstance(now.date(), now.time()).getTime() - DateTime.newInstance(now.dateGmt(), now.timeGmt()).getTime();
        apexStartDateTime = apexStartDateTime.addSeconds(Integer.valueof(offset / 1000));
        apexEndDateTime = apexEndDateTime.addSeconds(Integer.valueof(offset / 1000));
        List<Case> caseList = new List<Case>();
        caseList = [SELECT ID, Owner.Name, CreatedDate, RecordType.Name, CaseNumber, Brand__c,
                        (SELECT ID, TopicId, topic.Name, EntityId 
                         FROM TopicAssignments) 
                         FROM Case 
                         WHERE RecordType.Name 
                         IN :recordTypeList
                         AND ID IN 
                         (SELECT EntityId 
                         	FROM TopicAssignment WHERE EntityKeyPrefix = :CRM_Constants.CASE_PREFIX)
                         AND CreatedDate >=:apexStartDateTime AND CreatedDate <=:apexEndDateTime
                         ORDER BY Case_Owner__c ASC];
        return caseList;
    }
}