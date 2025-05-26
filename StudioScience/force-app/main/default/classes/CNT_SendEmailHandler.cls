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
    @date 11/18/2020
    @description This class is used to send email to Person Contact Email from SurveyInvitation for Customer negative feedback.
*/
public class CNT_SendEmailHandler {
    /**
    *  @description : This method is used to send email.
    *  @args        : String WhatId, String email, String Subject, String Message, String ThreadId
    *  @return      : String
    **/
    @AuraEnabled
    public static String processEmail(String WhatId, String email, String Subject, String Message, String ThreadId){
        String sMessage='';
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {email}; 
            String serviceEmail;
            mail.setToAddresses(toAddresses);
            List<Organization> org= [select id, IsSandbox from Organization limit 1];
            Boolean isSandbox= org[0].isSandBox;
            OrgWideEmailAddress[] owea = new OrgWideEmailAddress[]{};
            if(!isSandbox){
                owea = [select Id from OrgWideEmailAddress where Address = 'ccvm@beamsuntory.com'];
            } else {
                owea = [select Id from OrgWideEmailAddress where Address = 'nidhi.munjal.metacube@beamsuntory.com'];
                /*List<EmailServicesAddress> emailList= [SELECT Id,LocalPart, EmailDomainName,IsActive FROM EmailServicesAddress Where LocalPart ='ccvm' and isActive=true];
                serviceEmail= emailList[0].LocalPart + '@' + emailList[0].EmailDomainName;
                mail.setCcAddresses(new String[] {serviceEmail});*/
            }
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            mail.setSubject(Subject);
            mail.setHtmlBody(Message+ '<br/><br/><p><span>'+ThreadId+ '</span> </p>');
            mail.setWhatId(WhatId);
            Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            sMessage='Success';
        }
        catch(Exception ex){
            sMessage=ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();
            String errorMessage = 'Error sending survey email ' + ex.getMessage() + '\n' + ex.getStackTraceString();
            CreateExceptionLog.insertErrorLog('CNT_SendEmailHandler', 'processEmail', String.valueOf(errorMessage), 'Fatal');
        }
        return sMessage;
    }
 }