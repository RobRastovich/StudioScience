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
@date 27/10/2020
@description This batch is used check the trigger word field in existing quality claim cases that were created because of trigger words.
*/

global class BCH_DSC_UpdateTriggerField implements Database.Batchable<sObject> 
{
    /**
*  @description : This method is called at the starting of a batch job to collect the data on which the batch job will be operating.
*  @args        : Database.BatchableContext bc
*  @return      : Database.getQueryLocator
**/
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        
        return Database.getQueryLocator('select CaseNumber,Description,trigger_word__c from case where (RecordType.Name = \'Quality Claim\') or (RecordType.Name = \'Consumer Inquiry\')');
        
    }
    
    /**
*  @description : This method executes after the Start method, and it does the actual processing for each batch, separately.
*  @args        : Database.BatchableContext bc, List<Case> lstCase
*  @return      : void
**/
    
    global void execute(Database.BatchableContext BC, List<Case> Cases) 
    {
        
        List<TriggerWords__c> lstTriggerWord = SLT_TriggerWord.getAllTriggerWords();
        
        List<Case> lstCaseForTriggerWord = new List<Case>();
        
        for(Case c : Cases)
        {	
            String caseDescription = String.isNotEmpty(c.Description) ? ' ' + c.Description.replaceAll('[^a-zA-Z0-9 ]', ' ') + ' ' : null;
            
            for(TriggerWords__c triggerWord:lstTriggerWord)
            {
                
                if(caseDescription != null && caseDescription.containsIgnoreCase(' '+triggerWord.name+' '))
                {
                    if(c.trigger_word__c != true)
                    {
                        c.trigger_word__c = true;
                        lstCaseForTriggerWord.add(c);
                        
                    }
                    
                }
                
            }  
        }
        try
        {
            if(lstCaseForTriggerWord.size()>0)    
                update lstCaseForTriggerWord;
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        
        
    }
    
    /**
*  @description : This method will be called at last. It is responsible to perform post-processing operations such as sending an email.
* 					When this process is called all batches are already executed.
*  @args        : Database.BatchableContext bc
*  @return      : void
**/
    global void finish(Database.BatchableContext BC) 
    {
        
    }
    
}