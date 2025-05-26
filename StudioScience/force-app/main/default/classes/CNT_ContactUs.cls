/**
    @company : Copyright © 2019, BeamSuntory
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
    @date 16/11/2019
    @description This class is used to get the all the values of all related picklist and create the case.
*/
/*Without Sharing : It made due to update the case record, as Guest user does not have edit permissions according to the salesforce winter-20 security release. */
public without sharing class CNT_ContactUs {
    
    /**
    *  @description : This method is use to fetch value for picklist on contact us page.
    *  @args        : String brand
    *  @return      : Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> getPickListValues(String brand) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            responseMap = SRV_Case.getPickListValues(brand);
        } catch(Exception e) {
            responseMap.put('error', e.getMessage());
            String errorMessage = 'Error getting picklist values ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('CNT_ContactUs', 'getPickListValues', String.valueOf(errorMessage), 'Fatal');
            // throw so that we can detect issues before deploying
            if (Test.isRunningTest()) {
                throw new CS_CustomException(e.getMessage());
            }
        }
        return responseMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> getPickListValuesForLwc(String brand) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            responseMap = SRV_Case.getPickListValuesForLwc(brand);
        } catch(Exception e) {
            responseMap.put('error', e.getMessage());
            String errorMessage = 'Error getting picklist values ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('CNT_ContactUs', 'getPickListValues', String.valueOf(errorMessage), 'Fatal');
            // throw so that we can detect issues before deploying
            if (Test.isRunningTest()) {
                throw new CS_CustomException(e.getMessage());
            }
        }
        return responseMap;
    }
    
    /**
    *  @description : This method is use to create case through contact us page.
    *  @args        : Case caseObj, String caseId, Boolean isComplaint, String reCaptchaResponse, Account accountObj, String accountId
    *  @return      : Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> createCase(Case caseObj, String caseId, Boolean isComplaint, String reCaptchaResponse, Account accountObj, String accountId, List<String> documentIdList) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            responseMap = SRV_Case.createCase(caseObj,caseId,isComplaint,reCaptchaResponse,accountObj,accountId,documentIdList);
        } catch(Exception e) {
            responseMap.put('error', e.getMessage());
            String errorMessage = 'Error creating case ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('CNT_ContactUs', 'createCase', String.valueOf(errorMessage), 'Fatal');
            // throw so that we can detect issues before deploying
            if (Test.isRunningTest()) {
                throw new CS_CustomException(e.getMessage());
            }
        }
        return responseMap;
    }
    
    /**
    *  @description : This method is use to update & create quality claim case.
    *  @args        : Case caseObj, String caseId, Account accountObj, String accountId, String address2
    *  @return      : Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> updateCase(Case caseObj, String caseId, Account accountObj, String accountId, String address2) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            responseMap = SRV_Case.updateCase(caseObj,caseId,accountObj,accountId,address2);
        } catch(Exception e){
            responseMap.put('error', e.getMessage());
            String errorMessage = 'Error updating case ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('CNT_ContactUs', 'updateCase', String.valueOf(errorMessage), 'Fatal');
            // throw so that we can detect issues before deploying
            if (Test.isRunningTest()) {
                throw new CS_CustomException(e.getMessage());
            }
        }
        return responseMap;
    }
    
}