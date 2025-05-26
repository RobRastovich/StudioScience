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
    @date 20 Jun 2020
    @description This test class is to test Contact Us Controller .
*/
@isTest(SeeAllData = true)
public class TST_CustomMetada {
    
    @IsTest
    public static void testGetBrandCategoryHelpListByBrand() {
        String brand = 'Jim Beam';
        List<Brand_Category_Help_Mapping__mdt> bchmList = new List<Brand_Category_Help_Mapping__mdt>();
        Test.startTest();
        bchmList = SLT_CustomMetadata.getBrandCategoryHelpListByBrand(brand);
        Test.stopTest();
        System.assertNotEquals(null, bchmList);
    }
    
    @IsTest
    public static void testGetBrandProductMappingByBrand() {
        String brand = 'Jim Beam';
        List<Brand_Product_Mapping__mdt> bpmList = new List<Brand_Product_Mapping__mdt>();
        Test.startTest();
        bpmList = SLT_CustomMetadata.getBrandProductMappingByBrand(brand);
        Test.stopTest();
        System.assertNotEquals(null, bpmList);
    }
    
    @IsTest
    public static void testGetIssuetypeList() {
        List<Issue_Type__mdt> issueTypeList = new List<Issue_Type__mdt>();
        Test.startTest();
        issueTypeList = SLT_CustomMetadata.getIssuetypeList();
        Test.stopTest();
        System.assertNotEquals(null, issueTypeList);
    }
    
    @IsTest
    public static void testGetLotCodeResourceByBrand() {
        String brand = 'Jim Beam';
        List<Brand_Lot_Code_Setting__mdt> blcsList = new List<Brand_Lot_Code_Setting__mdt>();
        Test.startTest();
        blcsList = SLT_CustomMetadata.getLotCodeResourceByBrand(brand);
        Test.stopTest();
        System.assertNotEquals(null, blcsList);
    }
    
    @IsTest
    public static void testGetEmailSignatureInformationByBrand() {
        String brand = 'Jim Beam';
        List<Email_Signature_Information__mdt> esiList = new List<Email_Signature_Information__mdt>();
        Test.startTest();
        esiList = SLT_CustomMetadata.getEmailSignatureInformationByBrand(brand);
        Test.stopTest();
        System.assertNotEquals(null, esiList);
    }
    
    @IsTest
    public static void testGetBrandCategoryMappingByBrand() {
        Set<String> brands = new Set<String>();
        brands.add('Jim Beam');
        Map<String, String> helpOptionsPriorityMap = new Map<String, String>();
        List<Email_Signature_Information__mdt> esiList = new List<Email_Signature_Information__mdt>();
        Test.startTest();
        helpOptionsPriorityMap = SLT_CustomMetadata.getBrandCategoryMappingByBrand(brands);
        Test.stopTest();
        System.assertNotEquals(null, esiList);
    }

}