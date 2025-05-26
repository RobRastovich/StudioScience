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
    @date 20/4/2020
    @description This Class is DAO class Brand
*/
public class SLT_SB2_Brand {
    /**
    *  @description : This method is get brand Allocation for a particular list of brand
    *  @args        : Set<Id>
    *  @return      : List<Brand__c>
    **/
    public static List<Brand__c> getExistingBrand() {
            return[SELECT Id,  Name, is_Active__c
                   FROM Brand__c 
				   WHERE  is_Active__c = true];
    }
    
    /**
    *  @description : This method is get brand Allocation for a particular list of brand
    *  @args        : Set<Id>
    *  @return      : List<Brand__c>
    **/
    public static Map<Id, Brand__c> getBrandMap(Set<Id> setofBrand) {
            return new Map<Id, Brand__c> ([SELECT Id,  Name, is_Active__c
                   FROM Brand__c 
				   WHERE  Id IN: setofBrand
                                      AND is_Active__c = true]);
    }
}