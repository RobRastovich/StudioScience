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
    @description This service class is created for state object.
*/
public class SRV_SB2_State {
    
    public static void isStateManagerAvailable(List<State__c> lstStates) {
        for(State__c state : lstStates) {
            if(state.State_Manager__c == null) {
                state.addError(Label.SB2_State_Manager_Missing);
            }
        }
    }
    
    public static void checkDuplicatedAlias(List<State__c> lstStates) {
        Set<String> aliasSet = new Set<String>();
        for(State__c state : lstStates) {
            aliasSet.add(state.Alias__c.toUpperCase());
        }
        if(aliasSet.size() > 0) {
            List<State__c> lstExistingState = SLT_SB2_State.getStatesByAlias(aliasSet);
            Map<String, State__c> aliasWiseState = new Map<String, State__c>();
            for(State__c state : lstExistingState) {
                aliasWiseState.put(state.Alias__c.toUpperCase(), state);
            }
            
            for(State__c state : lstStates) {
                if(aliasWiseState.containsKey(state.Alias__c.toUpperCase())) {
                    state.Alias__c.addError(Label.SB2_Duplicate_Alias_Error);
                }
            }
        }
    }
    
    /**
    *  @description : This method is use to check duplicate entry on insert & update.
    *  @args        : List<State__c> lstStates, Map<Id, State__c> oldStatesMap
    **/
    public static void checkDuplicateName(List<State__c> lstStates, Map<Id, State__c> oldStatesMap) {
        List<State__c> existingStateList = getExistingStateList(lstStates);
        if(!existingStateList.isEmpty()) {
            Set<String> existingNameSet = new Set<String>();
            for(State__c state : existingStateList) {
                existingNameSet.add((state.Name + '-' + state.Country__C).toUpperCase());
            }
            for(State__c state : lstStates) {
                String key = (state.Name + '-' + state.Country__C).toUpperCase();
                if(oldStatesMap != null) {
                    if(!oldStatesMap.get(state.Id).Name.equalsIgnoreCase(state.Name) && existingNameSet.contains(key)) {
                        state.Name.addError(String.format(Label.SB2_Duplicate_Record_Error, new List<Object> {'state'}));
                    }
                }
                else {
                    if(existingNameSet.contains(key)) {
                        state.Name.addError(String.format(Label.SB2_Duplicate_Record_Error, new List<Object> {'state'}));
                    }
                }
            }
            
        }
    }
    
    /**
    *  @description : This method is use to ensure that record should be active while creating a state.
    *  @args        : List<State__c> lstStates
    **/
    public static void checkStateIsActive(List<State__c> lstStates) {
        for(State__c state : lstStates) {
            if(!state.IsActive__c) {
                state.IsActive__c.addError(Label.SB2_State_Active_Message);
            }
        }
    }
    
    /**
    *  @description : This method is use to ensure that an inactive record can't be activate again.
    *  @args        : List<State__c> lstStates, Map<Id, State__c> oldStatesMap
    **/
    public static void checkActivateState(List<State__c> lstStates, Map<Id, State__c> oldStatesMap) {
        for(State__c state : lstStates) {
            if(!oldStatesMap.get(state.Id).IsActive__c && state.IsActive__c) {
                state.IsActive__c.addError(Label.SB2_State_Active_Inactive_Error_Message);
            }
        }
    }
    
    /**
    *  @description : This helper method is use to fetch existing states by region name & country.
    *  @args        : List<State__c> lstStates
    *  @return      : List<State__c>
    **/
    private static List<State__c> getExistingStateList(List<State__c> lstStates) {
        Set<String> stateNameSet = new Set<String>();
        Set<Id> stateCountrySet = new Set<Id>();
        for(State__c state : lstStates) {
            String stateName = state.Name.trim();
            stateNameSet.add(stateName);
            stateCountrySet.add(state.Country__c);
        }
        return SLT_SB2_State.getExistingStatesBasedOnNameAndCountry(stateNameSet, stateCountrySet);
    }
}