/**
    @company : Copyright © 2021, BeamSuntory
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
    @date 1/23/2021
    @description This service class is for Sample
*/
public class SRV_SBP_Sample {
    /**
    *  @description : This method is use to restrict uncheck of sample record.
    *  @args        : List<Sample__c> lstSample, Map<Id, Sample__c> oldMapOfSample
    **/
    public static void isSampleAlreadySelected(List<Sample__c> lstSample, Map<Id, Sample__c> oldMapOfSample) {
        try {
            for(Sample__c newSample : lstSample) {
                Sample__c oldSample = oldMapOfSample.get(newSample.Id);
                if(!newSample.Sample_Selected__c && oldSample.Sample_Selected__c) {
                    newSample.Sample_Selected__c.addError(Label.Sample_Uncheck_Restriction);
                }
            }
        } catch(Exception e) {
            String errorMessage = 'Error validating sample selection ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('SRV_SBP_Sample', 'isSampleAlreadySelected', String.valueOf(errorMessage), 'Fatal');
        }
    }
    
    /**
    *  @description : This method is use to restrict multiple sample selection for sample kit.
    *  @args        : List<Sample__c> lstSample, Map<Id, Sample__c> oldMapOfSample
    **/
    public static void isSampleKitSelectedForSample(List<Sample__c> lstSample, Map<Id, Sample__c> oldMapOfSample) {
        try {
            Set<Id> sampleKitIdSet = new Set<Id>();
            for(Sample__c newSample : lstSample) {
                Sample__c oldSample = oldMapOfSample.get(newSample.Id);
                if(newSample.Sample_Selected__c && !oldSample.Sample_Selected__c) {
                    sampleKitIdSet.add(newSample.Sample_Kit__c);
                }
            }
            if(!sampleKitIdSet.isEmpty()) {
                Map<Id, Sample_Kit__c> mapOfSampleKit = new Map<Id, Sample_Kit__c>([SELECT Id, Sample_Selected__c FROM Sample_Kit__c Where Id IN: sampleKitIdSet]);
                for(Sample__c newSample : lstSample) {
                    Sample__c oldSample = oldMapOfSample.get(newSample.Id);
                    if(newSample.Sample_Selected__c && !oldSample.Sample_Selected__c) {
                        Sample_Kit__c sampleKit = mapOfSampleKit.get(newSample.Sample_Kit__c);
                        if(sampleKit != null && sampleKit.Sample_Selected__c) {
                            newSample.addError(Label.Sample_Kit_Already_Selected);
                        }
                    }
                }
            }
        } catch(Exception e) {
            String errorMessage = 'Error validating sample kit ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('SRV_SBP_Sample', 'isSampleKitSelectedForSample', String.valueOf(errorMessage), 'Fatal');
        }
    }
    
    /**
    *  @description : This method is use to update the details on sample kit and barrel object.
    *  @args        : List<Sample__c> lstSample, Map<Id, Sample__c> oldMapOfSample
    **/
    public static void updateSampleSelection(List<Sample__c> lstSample, Map<Id, Sample__c> oldMapOfSample) {
        try {
            Map<Id, Sample_Kit__c> mapOfSampleKit = new Map<Id, Sample_Kit__c>();
            Set<Id> sampleBarrelIds = new Set<Id>();
            for(Sample__c newSample : lstSample) {
                Sample__c oldSample = oldMapOfSample.get(newSample.Id);
                if(newSample.Sample_Selected__c && !oldSample.Sample_Selected__c) {
                    if(newSample.Sample_Kit__c != null && newSample.Barrel__c != null) {
                        Sample_Kit__c sampleKit = new Sample_Kit__c(Id = newSample.Sample_Kit__c);
                        sampleKit.Sample_Selected__c = true;
                        mapOfSampleKit.put(newSample.Sample_Kit__c, sampleKit);
                        sampleBarrelIds.add(newSample.Barrel__c);
                    }
                }
            }
            if(!mapOfSampleKit.isEmpty() && !sampleBarrelIds.isEmpty()) {
                Map<Id, Id> mapOfCaseWithSampleKit = new Map<Id, Id>();
                Map<Id, Barrel__c> mapOfCaseWithBarrel = new Map<Id, Barrel__c>();
                Map<Id, Barrel__c> mapOfBarrelsToUpdate = new Map<Id, Barrel__c>();
                List<Barrel__c> lstPlaceHolderBarrelToDelete = new List<Barrel__c>();
                List<Case> updateCaseBarrel = new List<Case>();
                
                for(Sample_Kit__c sampleKit : [SELECT Id, Case__c FROM Sample_Kit__c WHERE Id IN: mapOfSampleKit.keySet()]) {
                    mapOfCaseWithSampleKit.put(sampleKit.Id, sampleKit.Case__c);
                }
                if(!mapOfCaseWithSampleKit.isEmpty()) {
                    //Added for LSB-143 Brand__c in Query
                    for(Barrel__c barrel : [SELECT Id, Case__c, PO_Number__c, Brand__c FROM Barrel__c WHERE Case__c IN: mapOfCaseWithSampleKit.values()]) {
                        mapOfCaseWithBarrel.put(barrel.Case__c, barrel);
                    }
                }
                Map<Id, Barrel__c> mapOfBarrelBySample = new Map<Id, Barrel__c>([SELECT 
                        Id, Name, Barrel_Number__c, Quantity__c, Barrel_Approved__c, Brand__c, 
                        Product_Type__c, Warehouse__c, Floor__c, Tier__c, Story__c, Rick__c, Barreled_Date__c
                    FROM 
                        Barrel__c 
                    WHERE 
                        Id IN: sampleBarrelIds]);
                
                for(Sample__c newSample : lstSample) {
                    Barrel__c sampleBarrel = mapOfBarrelBySample.get(newSample.Barrel__c);
                    Id caseId = mapOfCaseWithSampleKit.get(newSample.Sample_Kit__c);
                    if(caseId != null && mapOfCaseWithBarrel.containsKey(caseId)) {
                        Barrel__c placeHolderBarrel = mapOfCaseWithBarrel.get(caseId);
                        //Added for LSB-143 
                        if(placeHolderBarrel.Brand__c == SBP_Constants.LAPHROAIG_SINGLE_CASK){
                            Case recordCase = new Case();
                            recordCase.Id = caseId;
                            recordCase.Barrel__c = sampleBarrel.Id;
                            updateCaseBarrel.add(recordCase);
                        }
                        //Till here LSB-143
                        sampleBarrel.RecordTypeId = SBP_Constants.fullBarrelBrandRTIdMap.get(sampleBarrel.Brand__c);
                        sampleBarrel.Case__c = caseId;
                        sampleBarrel.Barrel_Number__c = newSample.Portal_Label__c;
                        sampleBarrel.Selection_Date__c = Date.today();
                        sampleBarrel.PO_Number__c = placeHolderBarrel.PO_Number__c;
                        mapOfBarrelsToUpdate.put(placeHolderBarrel.Id, sampleBarrel);
                        lstPlaceHolderBarrelToDelete.add(placeHolderBarrel);
                    }
                }
                if(!(mapOfBarrelsToUpdate.isEmpty() && lstPlaceHolderBarrelToDelete.isEmpty())) {
                    update mapOfBarrelsToUpdate.values();
                    List<POS_Customization__c> lstPosCustomization = [SELECT Id, Barrel__c FROM POS_Customization__c WHERE Barrel__c = :mapOfBarrelsToUpdate.keySet()];
                    List<POS_Customization__c> lstPosCustomizationToUpdate = new List<POS_Customization__c>();
                    for(POS_Customization__c posItem : lstPosCustomization) {
                        if(mapOfBarrelsToUpdate.containsKey(posItem.Barrel__c)) {
                            posItem.Barrel__c = mapOfBarrelsToUpdate.get(posItem.Barrel__c).Id;
                            lstPosCustomizationToUpdate.add(posItem);
                        }
                    }
                    if(!lstPosCustomizationToUpdate.isEmpty()) {
                        update lstPosCustomizationToUpdate;
                    }
                    //Added LSB-143
                    if(!updateCaseBarrel.isEmpty() && updateCaseBarrel.size() > 0) {
                        update updateCaseBarrel;
                    }
                    //Till here LSB-143
                    delete lstPlaceHolderBarrelToDelete;
                    update mapOfSampleKit.values();
                }
            }
        } catch(Exception e) {
            String errorMessage = 'Error updating parent of sample ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('SRV_SBP_Sample', 'updateSampleSelection', String.valueOf(errorMessage), 'Fatal');
        }
    }
    
}