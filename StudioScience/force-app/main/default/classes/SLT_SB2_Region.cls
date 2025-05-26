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
    @description This selector class is created to fetch region details.
*/
public class SLT_SB2_Region {

    /**
    *  @description : This method is use to fetch regions by region name & country.
    *  @args        : Set<String> regionNameSet, Set<Id> regionCountrySet
    *  @return      : List<Region__c>
    **/
    public static List<Region__c> getExistingRegionsBasedOnNameAndCountry(Set<String> regionNameSet, Set<Id> regionCountrySet) {
        return [Select 
                	Id, Name, Country__c
                From
                	Region__c
                Where 
                	Name IN :regionNameSet
                AND 
                	Country__c IN :regionCountrySet
               	LIMIT 1000];
    }

    /**
    *  @description : This method is use to fetch region records.
    *  @args        : Set<Id> regionIds
    *  @return      : Map<Id, Region__c>
    **/
    public static Map<Id, Region__c> getRegionMap(Set<Id> regionIds) {
        return new Map<Id, Region__c>([
            SELECT
                Id, Name
            FROM
                Region__c
            WHERE
                Id IN: regionIds
        ]);
    }
}