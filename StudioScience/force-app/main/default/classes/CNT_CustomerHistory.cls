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
    @date 06/01/2020
    @description This class is use to get the customer history and show the notification.
*/
public with sharing class CNT_CustomerHistory {

    /**
    *  @description : This method is use to fetch the existing cases based on current case's contact email id or address.
    *  @args        : Id caseId, String email, String country, String state, String city, String postalCode, String street.
    *  @return      : List<Case>
    **/
    @AuraEnabled
    public static List<Case> getCases(Id caseId, String email, String country, String state, String city, String postalCode, String street) {
        List<Case> lstCaseInfo;
        try{
           lstCaseInfo = SRV_CustomerHistory.getCaseByEmailOrAddress(caseId, email, country, state, city, postalCode, street); 
        } catch(Exception e){
            String errorMessage = 'Error getting cases ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('CNT_CustomerHistory', 'getCases', String.valueOf(errorMessage), 'Fatal');
            // throw so that we can detect issues before deploying
            if (Test.isRunningTest()) {
                throw new CS_CustomException(e.getMessage());
            }
        }
        return lstCaseInfo;
    }
    
    /**
    *  @description : This method is use to get warning message for cases created by current case's contact email id or address.
    *  @args        : Id caseId, String email, String country, String state, String city, String postalCode, String street, Datetime createdDate.
    *  @return      : String
    **/
    @AuraEnabled
    public static String getWarningMessage(Id caseId, String email, String country, String state, String city, String postalCode, String street, Datetime createdDate) {
        String emailMessage = '';
        try{
            emailMessage = SRV_CustomerHistory.getWarningMessage(caseId, email, country, state, city, postalCode, street, createdDate);
        } catch(Exception e){
            String errorMessage = 'Error getting warning ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('CNT_CustomerHistory', 'getWarningMessage', String.valueOf(errorMessage), 'Fatal');
            // throw so that we can detect issues before deploying
            if (Test.isRunningTest()) {
                throw new CS_CustomException(e.getMessage());
            }
        }
        return emailMessage;
    }

    @AuraEnabled
    public static List<Case> getLotcodeCases(Id caseId, String country, String lotCode) {
        try{
            return SRV_CustomerHistory.getCasesByCountryAndLotcode(caseId, country, lotCode);
        } catch(Exception e) {
            String errorMessage = 'Error getting lot code related cases ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('CNT_CustomerHistory', 'getWarningMessage', String.valueOf(errorMessage), 'Fatal');
            throw new CS_CustomException(errorMessage);
        }
    }
}