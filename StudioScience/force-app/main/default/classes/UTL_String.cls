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
    @date 03/04/2020
    @description This utility class created for string manipulation methods
*/
public class UTL_String {

    /**
    *  @description : This method is use to get readable error message
    *  @args        : String errorMessage
    *  @return      : String
    **/
    public static String getErrorMessage(String errorMessage) {
        String message = '';
        if(String.isNotBlank(errorMessage)) {
            if(errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                message = errorMessage.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
            } else if(errorMessage.contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
                message = errorMessage.substringBetween('FIELD_FILTER_VALIDATION_EXCEPTION, ', ': ');
            } else if(errorMessage.contains('DUPLICATE_VALUE')) {
                String tempMessage = errorMessage.substringBetween('duplicate value found:', 'id:');
                String fieldName = tempMessage.substring(0, tempMessage.indexOf('__c'));
                message = fieldName.indexOf('_') > -1 ? fieldName.replace('_', ' ') : fieldName;
                message += ' is already present in the system.';
            }
            return message;
        }
        return message;
    }

}