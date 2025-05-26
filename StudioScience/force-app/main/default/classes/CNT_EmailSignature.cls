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
    @date 01/02/2020
    @description It will set the Email Signature based on the brand.
*/
public with sharing class CNT_EmailSignature {

    public String brandName;
    public List<Email_Signature_Information__mdt> lstEmailSignatureInformation;
    public Email_Signature_Information__mdt brandLogoEmailSignatureInformation;
    public List<Email_Signature_Information__mdt> lstSocialInformation;
    public String threadId;
    public String currentCaseId;

    public Email_Signature_Information__mdt productLink;
    
    /*Constructor of the class*/
    public CNT_EmailSignature() {}
	
    /*Below we are set the value of brand name and email signature information*/
    public void setBrandName(String brandValue) {
        this.brandName = brandValue;
        this.setLstEmailSignatureInformation(this.brandName);
        this.setLstSocialInformation(this.brandName);
        this.setProductLink();
        this.setBrandLogoEmailSignatureInformation();
    }
    
    /* Setter method to set current case id & thread id */
    public void setCurrentCaseId(String currentCaseId) {
        this.currentCaseId = currentCaseId;
        this.setThreadId(this.currentCaseId);
    }
    
    /* Getter of current case id */
    public String getCurrentCaseId() {
        return this.currentCaseId;
    }

    public void setProductLink() {
        for(Email_Signature_Information__mdt emailSignature  : SLT_CustomMetadata.getEmailSignatureInformationByBrand(brandName)){
            if(emailSignature.URL_Type__c == 'Product Link'){
                this.productLink = emailSignature;
            }
        }
    }

    public Email_Signature_Information__mdt getProductLink() {
        return this.productLink;
    }
    
    public void setBrandLogoEmailSignatureInformation() {
        for(Email_Signature_Information__mdt emailSignature  : SLT_CustomMetadata.getEmailSignatureInformationByBrand(brandName)){
            if(emailSignature.URL_Type__c == 'Brand Logo'){
                this.brandLogoEmailSignatureInformation = emailSignature;
            }
        }
    }

    public Email_Signature_Information__mdt getBrandLogoEmailSignatureInformation() {
        return this.brandLogoEmailSignatureInformation;
    }

    public void setLstSocialInformation(String brandName) {
        List<Email_Signature_Information__mdt> socialLinks = new List<Email_Signature_Information__mdt>();
        for(Email_Signature_Information__mdt emailSignature  : SLT_CustomMetadata.getEmailSignatureInformationByBrand(brandName)){
            if(emailSignature.URL_Type__c != 'Brand Logo' && emailSignature.URL_Type__c != 'Product Link'){
                socialLinks.add(emailSignature);
            }
        }
        this.lstSocialInformation = socialLinks;
    }

    public List<Email_Signature_Information__mdt> getLstSocialInformation() {
        return this.lstSocialInformation;
    }    

    /*Getter of Brand Name*/
    public String getBrandName() {
        return brandName;
    }

    /* Setter of lstEmailSignatureInformation */
    public void setLstEmailSignatureInformation(String brandName) {
        this.lstEmailSignatureInformation = SLT_CustomMetadata.getEmailSignatureInformationByBrand(brandName);
    }

    /* Getter of getLstEmailSignatureInformation */
    public List<Email_Signature_Information__mdt> getLstEmailSignatureInformation() {
        return this.lstEmailSignatureInformation;
    }
    
    /* Setter of Thread Id */
    public void setThreadId(String currentCaseId) {
       this.threadId = 'ref:_' + UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11,4) + '._' + currentCaseId.left(5) + currentCaseId.mid(10,5) + ':ref';
    }
    
    /* Getter of Thread Id */
    public String getThreadId() {
        return this.threadId;
    }
}