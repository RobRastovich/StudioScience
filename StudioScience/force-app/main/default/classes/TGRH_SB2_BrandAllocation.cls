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
    @date 16/04/2020
    @description This Class is handler class for Brand Allocation Trigger
*/
public class TGRH_SB2_BrandAllocation {

    /**
    *  @description : This method is use to handle operation on before insert
    *  @args        : List Brand_Allocation__c
    *  @return      : void
    **/
    public static void handleBeforeInsert(List<Brand_Allocation__c> lstBrandAllocations) {
        SRV_SB2_BrandAllocation.setBrandAllocationName(lstBrandAllocations);
        SRV_SB2_BrandAllocation.checkDuplicateAllocation(lstBrandAllocations);
    }
    
    public static void handleAfterUpdate(List<Brand_Allocation__c> lstBrandAllocations) {
        SRV_SB2_BrandAllocation.updateCarryForwardBarrels(lstBrandAllocations);
    }
}