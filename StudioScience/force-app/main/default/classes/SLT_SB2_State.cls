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
    @date 17/04/2020
    @description This selector class is created to fetch state details.
*/
public class SLT_SB2_State {
    
    /**
    *  @description : This method is use to fetch states by region name & country.
    *  @args        : Set<String> stateNameSet, Set<Id> stateCountrySet
    *  @return      : List<State__c>
    **/
    public static List<State__c> getExistingStatesBasedOnNameAndCountry(Set<String> stateNameSet, Set<Id> stateCountrySet) {
        return [Select 
                	Id, Name, Country__c 
                From 
                	State__c 
                Where 
                	Name IN :stateNameSet
                AND
                	Country__c IN :stateCountrySet
                AND
                	IsActive__c = TRUE
               	LIMIT 1000];
    }
    
    /**
    *  @description : This method is use to fetch states by region name & country.
    *  @args        : Set<String> stateNameSet, Set<Id> stateCountrySet
    *  @return      : List<State__c>
    **/
    public static List<State__c> getStateInfoFromAccount(String stateName) {
        return [Select 
                	Id, Name, Country__c, Region__r.Name 
                From 
                	State__c 
                Where 
                	Name =:stateName];
    }

    /**
    *  @description : This method is use to fetch state records.
    *  @args        : Set<Id> stateIds
    *  @return      : Map<Id, State__c>
    **/
    public static Map<Id, State__c> getStateMap(Set<Id> stateIds) {
        return new Map<Id, State__c>([
            SELECT
                Id, Alias__c
            FROM
                State__c
            WHERE
                Id IN: stateIds
        ]);
    }

    /**
    *  @description : This method is use to fetch state by id.
    *  @args        : String id
    *  @return      : State__c
    **/
    public static State__c getStateById(String id) {
        return [SELECT 
                	Id, Name, Alias__c, IsActive__c, Region__c, Country__c, State_Manager__c 
                FROM 
                	State__c 
                WHERE 
                	Id = :id];
    }
    
    /**
    *  @description : This method is use to fetch states by aliases.
    *  @args        : Set<String> aliasSet
    *  @return      : List<State__c>
    **/
    public static List<State__c> getStatesByAlias(Set<String> aliasSet) {
        return [SELECT 
                	Id, Alias__c 
                FROM 
                	State__c 
                WHERE 
                	IsActive__c = TRUE 
                AND 
                	Alias__c IN :aliasSet];
    }
    
    /**
    *  @description : This method is use to fetch states with region & country,
    * 				  where Region is not equal to Military & National Accounts.
    *  @args        : Set<String> stateNameSet, Set<Id> stateCountrySet
    *  @return      : List<State__c>
    **/
    public static List<State__c> getStatesWithRegionAndCountry() {
        return [SELECT
                	Id, Name, Region__c, Country__c, Region__r.Name, Country__r.Name 
                FROM 
                	State__c 
                WHERE 
                	IsActive__c = TRUE 
                AND 
                	Region__r.Name != 'Military' 
                AND 
                	Region__r.Name != 'National Accounts'
                AND
                	Region__c IN (Select Region__c From Brand_Country_Region_Allocation__c) 
                ORDER BY 
                	Country__r.Name, Region__r.Name, Name];
    }
}