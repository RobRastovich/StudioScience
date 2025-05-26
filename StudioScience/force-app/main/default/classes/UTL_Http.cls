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
    @date 14/02/2020
    @description This utility class responsible to make http requests.
*/
public class UTL_Http {

    /**
    *  @description : This method is use to make http request.
    *  @args        : String endPoint, String requestMethod, String requestBody
    *  @return      : Map<String, Object>
    **/
    public static Map<String, Object> makeHttpRequest(String endPoint, String requestMethod, String requestBody) {
        Map<String, Object> responseMap;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(requestMethod);
        request.setBody(requestBody);
        
        Http httpProvider = new Http();
        HttpResponse response = httpProvider.send(request); 
        if(response.getBody() != null){
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        }
        return responseMap;
    }
    
}