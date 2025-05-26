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
    @date 17/02/2020
    @description This is service class to fetch cases & warning messages.
*/
public class SRV_CustomerHistory {
	/**
    *  @description : This method is use to fetch warning message based on cases created in last 90 or 365 days.
    *  @args        : String Brand
    *  @return      : String
    **/
    public static String getWarningMessage(Id caseId, String email, String country, String state, String city, String postalCode, String street, Datetime createdDate) {
        if(caseId == null) {
            throw new CS_CustomException('Case id cannot be empty.');
        }
    	String warningMessage = '';
        List<Case> lstCaseInfo365Days = SLT_Case.getCasesInLastDaysForParticularUser(365, caseId, email, country, state, city, postalCode, street, createdDate, 3);
        if(lstCaseInfo365Days.size() >= 2) {
            warningMessage =  System.Label.WarningMessage52Weeks;
        } else{
            List<Case> lstCaseInfo90Days = SLT_Case.getCasesInLastDaysForParticularUser(90, caseId, email, country, state, city, postalCode, street, createdDate, 2);
            if(lstCaseInfo365Days.size() >= 1){
                warningMessage = System.Label.WarningMessage90Days;
            }
        } 
        return warningMessage;
    }
    
    /**
    *  @description : This method is use to fetch all cases based on given email address or mailing address.
    *  @args        : Id caseId, String email, String country, String state, String city, String postalCode, String street
    *  @return      : List<Case>
    **/
    public static List<Case> getCaseByEmailOrAddress(Id caseId, String email, String country, String state, String city, String postalCode, String street){
        if(caseId == null) {
            throw new CS_CustomException('Case id cannot be empty.');
        }
    	return SLT_Case.getCaseByEmailOrAddress(caseId, email, country, state, city, postalCode, street);
    }

    /**
    *  @description : This method is use to fetch all the quality claim cases based on country and intial 4 characters of lot code.
    *  @args        : Id caseId, String country, String lotCode
    *  @return      : List<Case>
    **/
    public static List<Case> getCasesByCountryAndLotcode(Id caseId, String country, String lotCode) {
        if(caseId == null || country == null || lotCode == null  || (lotCode != null && lotCode.length() < 4)) {
            throw new CS_CustomException('There is an error while retrieving the cases.');
        }
        return SLT_Case.getCasesByCountryAndLotcode(caseId, country, lotCode);
    }
    
    
}