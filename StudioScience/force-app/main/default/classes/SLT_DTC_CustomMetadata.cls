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
    @date 16/02/2022
    @description This selector class is created to fetch custom metadata.
*/
public class SLT_DTC_CustomMetadata {
    /**
    *  @description : This method is use to fetch Case Status flow for DTC.
    *  @args        : String howCanWeHelpYou, String additionalInformation
    *  @return      : 
    **/
    public static List<DTC_Status_Flow__mdt> getCaseStatusFlowDTC(Set<String> typesOfCase) {
        return [SELECT 
                Current_Stage__c, Next_Stage__c,Type__c 
                FROM
                DTC_Status_Flow__mdt 
                WHERE Type__c IN: typesOfCase];
    }

    public static List<DTC_Manage_Status__mdt> getManageStatusRecords(Set<String> typesOfCase, String howCanWeHelpYou) {
        String SearchKeyword = '%'+howCanWeHelpYou+'%';
        return [SELECT 
                Status__c, Sub_Status__c,Type__c, Order__c
                FROM 
                DTC_Manage_Status__mdt 
                WHERE Type__c IN: typesOfCase 
                AND How_Can_We_Help_You__c Like : SearchKeyword ORDER BY Order__c ASC];
    }
    //Added by Milan Bilochi
    public static map<String, String> getTrackTypeList(){
        List<Track_Carrier_Types__mdt> allCodes = Track_Carrier_Types__mdt.getAll().values();
        Map<String, String> mapOfCodeAndDescription = new map<String, String>();
        for(Integer i = 0 ; i < allCodes.Size() ; i++) {
            mapOfCodeAndDescription.put(allCodes[i].Carrier_Name__c+ '_'+allCodes[i].Code__c, allCodes[i].Type_Description__c);
        }
        return mapOfCodeAndDescription;
    }
}