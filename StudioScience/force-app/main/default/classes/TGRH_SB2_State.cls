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
    @description This handler class is created for state object.
*/
public class TGRH_SB2_State {
    
    /**
    *  @description : This method is use to handle before insert operations.
    *  @args        : List<State__c> lstStates
    **/
    public static void handleBeforeInsert(List<State__c> lstStates) {
        SRV_SB2_State.checkDuplicateName(lstStates, null);
        SRV_SB2_State.checkDuplicatedAlias(lstStates);
        SRV_SB2_State.checkStateIsActive(lstStates);
        SRV_SB2_State.isStateManagerAvailable(lstStates);
    }
    
    /**
    *  @description : This method is use to handle before update operations.
    *  @args        : List<State__c> lstStates
    **/
    public static void handleBeforeUpdate(List<State__c> lstStates, Map<Id, State__c> oldStatesMap) {
        SRV_SB2_State.checkDuplicateName(lstStates, oldStatesMap);
        SRV_SB2_State.checkActivateState(lstStates, oldStatesMap);
        SRV_SB2_State.isStateManagerAvailable(lstStates);
    }
}