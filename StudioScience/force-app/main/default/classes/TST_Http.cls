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
    @description This test class is created to test UTL_Http.
*/
@isTest
public class TST_Http {
    
    /**
    *  @description : This method is use http callout.
    **/
	@isTest 
    public static void testCallout() {
        String endpointUrl = 'http://example.com/example/test';
        String method = 'GET';
        String body = '';
        Map<String,String> headersMap = new Map<String,String>();
        headersMap.put('Cache-Control', 'no-cache');
        Test.setMock(HttpCalloutMock.class, new MockHttpUtilResponseGenerator());
        Map<String, Object>  res = UTL_Http.makeHttpRequest(endpointUrl,method,body);
        System.assertEquals(1,res.keyset().size());
        System.assertEquals(true , res.get('success'));
    }
    
    /**
    *  @description : This method is use http callout.
    **/
	@isTest 
    public static void testNegativeResponseCallout() {
        String endpointUrl = 'http://example.com/example/test';
        String method = 'GET';
        String body = '';
        Map<String,String> headersMap = new Map<String,String>();
        headersMap.put('Cache-Control', 'no-cache');
        Test.setMock(HttpCalloutMock.class, new MockHttpUtilNegativeResponseGenerator());
        Map<String, Object>  res = UTL_Http.makeHttpRequest(endpointUrl,method,body);
        System.assertEquals(1,res.keyset().size());
        System.assertEquals(false , res.get('success'));
    }
}