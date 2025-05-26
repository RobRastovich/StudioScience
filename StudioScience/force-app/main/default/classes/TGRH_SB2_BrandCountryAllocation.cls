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
    @date 29/04/2020
    @description This Class is handler class for Brand Country Allocation Trigger
*/
public class TGRH_SB2_BrandCountryAllocation {

    /**
    *  @description : This method is use to handle before insert operations.
    *  @args        : List<Brand_Country_Allocation__c> lstBrandCountryAllocation
    **/
    public static void handleBeforeInsert(List<Brand_Country_Allocation__c> lstBrandCountryAllocation) {
        SRV_SB2_BrandCountryAllocation.setAllocationName(lstBrandCountryAllocation);
        SRV_SB2_BrandCountryAllocation.checkDuplicateRecord(lstBrandCountryAllocation);
        SRV_SB2_BrandCountryAllocation.checkAllocationProvidedForLeafNode(lstBrandCountryAllocation);
    }

    /**
    *  @description : This method is use to handle after insert operations.
    *  @args        : List<Brand_Country_Allocation__c> lstBrandCountryAllocation
    **/
    public static void handleAfterInsert(List<Brand_Country_Allocation__c> lstBrandCountryAllocation) {
        SRV_SB2_BrandCountryAllocation.cascadeUpAllocation(lstBrandCountryAllocation);
    }

    /**
    *  @description : This method is use to handle before update operations.
    *  @args        : List<Brand_Country_Allocation__c> lstBrandCountryAllocation, Map<Id, Brand_Country_Allocation__c> oldMapOfBrandCountryAllocation
    **/
    public static void handleBeforeUpdate(List<Brand_Country_Allocation__c> lstBrandCountryAllocation, 
                                            Map<Id, Brand_Country_Allocation__c> oldMapOfBrandCountryAllocation) {

    }

    /**
    *  @description : This method is use to handle after udpate operations.
    *  @args        : y_Allocation__c> lstBrandCountryAllocation, Map<Id, Brand_Country_Allocation__c> newMapOfBrandCountryAllocation
    **/
    public static void handleAfterUpdate(List<Brand_Country_Allocation__c> lstBrandCountryAllocation, 
                                            Map<Id, Brand_Country_Allocation__c> newMapOfBrandCountryAllocation) {
        SRV_SB2_BrandCountryAllocation.cascadeUpAllocation(lstBrandCountryAllocation);   
    }

}