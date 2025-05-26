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
    @date 13/04/2020
    @description This service class is created for region object.
*/
public class SRV_SB2_Region {
    
    /**
    *  @description : This method is use to check duplicate entry on insert & update.
    *  @args        : List<Region__c> lstRegions, Map<Id, Region__c> oldRegionsMap
    **/
    public static void checkDuplicateName(List<Region__c> lstRegions, Map<Id, Region__c> oldRegionsMap) {
        List<Region__c> existingRegionList = getExistingRegionList(lstRegions);
        if(!existingRegionList.isEmpty()) {
            Set<String> existingNameSet = new Set<String>();
            for(Region__c region : existingRegionList) {
                existingNameSet.add((region.Name + '-' + region.Country__C).toUpperCase());
            }
            for(Region__c region : lstRegions) {
                String key = (region.Name + '-' + region.Country__C).toUpperCase();
                if(oldRegionsMap != null) {
                    if(!oldRegionsMap.get(region.Id).Name.equalsIgnoreCase(region.Name) && existingNameSet.contains(key)) {
                        region.Name.addError(String.format(Label.SB2_Duplicate_Record_Error, new List<Object> {'region'}));
                    }
                } else {
                    if(existingNameSet.contains(key)) {
                        region.Name.addError(String.format(Label.SB2_Duplicate_Record_Error, new List<Object> {'region'}));
                    }
                }
                
            }
        }
    }
    
    /**
    *  @description : This helper method is use to fetch existing regions by region name & country.
    *  @args        : List<Region__c> lstRegions
    *  @return      : List<Region__c>
    **/
    private static List<Region__c> getExistingRegionList(List<Region__c> lstRegions) {
        Set<String> regionNameSet = new Set<String>();
        Set<Id> regionCountrySet = new Set<Id>();
        for(Region__c region : lstRegions) {
            String regionName = region.Name.trim();
            regionNameSet.add(regionName);
            regionCountrySet.add(region.Country__c);
        }
        return SLT_SB2_Region.getExistingRegionsBasedOnNameAndCountry(regionNameSet, regionCountrySet);
    }
}