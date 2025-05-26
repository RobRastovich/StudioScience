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
    @date 12/03/2020
    @description This class is used to prepopulate email field for email quick action.
*/
global class EmailPublisherHandler implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global EmailPublisherHandler() {
    }
    
    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        system.debug('defaults' + defaults);
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;
        for (Integer j = 0; j < defaults.size(); j++) {
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults && getIsSendEmailQuickAction((QuickAction.SendEmailQuickActionDefaults)defaults.get(j))) {
                sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults) defaults.get(j);
                break;
            }
        }
        if (sendEmailDefaults != null) {
            Case c = [SELECT Contact.Email FROM Case WHERE Id=:sendEmailDefaults.getContextId()];
            EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();
            emailMessage.ToAddress = c.Contact.Email;
        }
    }
    /**
    *  @description : This method is use to get whether it is SendEmailComplaintInquiry action or not.
    *  @args        : QuickAction.SendEmailQuickActionDefaults actionToValidate
    *  @return      : Boolean
    **/
    private Boolean getIsSendEmailQuickAction(QuickAction.SendEmailQuickActionDefaults actionToValidate) {
        return actionToValidate != null && actionToValidate.getTargetSObject().getSObjectType() == EmailMessage.sObjectType && 
            actionToValidate.getActionName().equals('Case.SendEmailComplaintInquiry') && 
            actionToValidate.getActionType().equals('SendEmail');
    }
}