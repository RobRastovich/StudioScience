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
    @description This test class is created to Email Signature Controller.
*/
@isTest(SeeAllData = false)
public class TST_EmailSignature {
   
    /**
    *  @description : This method is use to test all the getters & setters of Email Signature Controller
    **/
    @IsTest
    public static void testEmailSignature() {
        CNT_EmailSignature emailSignatureObj = new CNT_EmailSignature();
        List<Email_Signature_Information__mdt> expectedLstEmailSignatureInformation = new List<Email_Signature_Information__mdt>();
       
        Test.startTest();
        Case caseObj = new Case();
        insert caseObj;
        emailSignatureObj.setCurrentCaseId(caseObj.Id);
        String currentCaseId = emailSignatureObj.getCurrentCaseId();
        String expectedThreadId = 'ref:_' + UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11,4) + '._' + currentCaseId.left(5) + currentCaseId.mid(10,5) + ':ref';
        emailSignatureObj.setBrandName('Jim Beam');
        emailSignatureObj.setLstEmailSignatureInformation(emailSignatureObj.getBrandName());
        emailSignatureObj.setThreadId(currentCaseId);
        expectedLstEmailSignatureInformation = SLT_CustomMetadata.getEmailSignatureInformationByBrand(emailSignatureObj.getBrandName());
        Test.stopTest();
        System.assertEquals('Jim Beam', emailSignatureObj.getBrandName());
        System.assertEquals(expectedLstEmailSignatureInformation, emailSignatureObj.getLstEmailSignatureInformation());
        System.assertEquals(expectedThreadId, emailSignatureObj.getThreadId());
    }
    
}