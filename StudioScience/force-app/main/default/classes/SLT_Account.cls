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
    @description This selector class is created to fetch account details.
*/
public class SLT_Account {
	
    /**
    *  @description : This method is use to fetch accounts by email.
    *  @args        : String email
    *  @return      : List<Account>
    **/
    public static List<Account> getAccountByEmail(String email){
        List<Account> existAccLst = new List<Account>();
        if(String.isNotBlank(email)){
            existAccLst = [SELECT Id FROM Account Where PersonEmail = :email LIMIT 1];  
        }
        return existAccLst;
    }
    
    /**
    *  @description : This method is use to fetch accounts by ids.
    *  @args        : Set<ID> ids
    *  @return      : List<Account>
    **/
    public static List<Account> getAccountsByIDs(Set<ID> ids){
        return [SELECT PersonContactId,PremiseType__c,Military__c,BillingCountry, BillingState FROM Account WHERE Id IN :ids limit 1];
    }

    /**
    *  @description : This method is use to fetch accounts by BillingState, BillingCountry & RecordTypeId.
    *  @args        : Id recordTypeId, Set<String> states, Set<String> countries
    *  @return      : List<Account>
    **/
    public static List<Account> getAccountsByStateCountryRecordType(Id recordTypeId, Set<String> states, Set<String> countries){
        return [SELECT
                    Id, BillingState, BillingCountry
                FROM 
                    Account
                WHERE 
                    RecordTypeId = :recordTypeId 
                AND 
                    BillingState LIKE :states 
                AND 
                    BillingCountry LIKE :countries 
                LIMIT 1000];
    }

    /**
    *  @description : This method is use to fetch accounts by Name.
    *  @args        : String name
    *  @return      : Account
    *  Author      : Nishant Khandal LSB-7
    **/
    public static Account getAccountsByName(String name){
        List<Account> getAccountRecords = new List<Account>();
        getAccountRecords = [SELECT ID
                                FROM Account
                                WHERE Name =: name
                                LIMIT 1];
        Account recordAccount = new Account();
        recordAccount = getAccountRecords.size()>0  ? getAccountRecords[0] : null;
        return recordAccount;
    }
}