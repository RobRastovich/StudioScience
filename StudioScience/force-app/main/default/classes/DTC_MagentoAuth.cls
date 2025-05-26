/**************************************************************************************
Apex Class Name     : DTC_MagentoAuth
Created Date        : 05/2023	Vikash Kumar 	Metacube
Function            : Used for authentication and to establish connection to Magento through generating OAuth 1.0 signature/header.
*************************************************************************************/
public class DTC_MagentoAuth {
    public static HttpRequest signRequest(HttpRequest req, String consumerKey, String oauthToken, String consumerSecret, 
        String signatureMethod, String oauthVersion) {
        String nonce     = String.valueOf(Crypto.getRandomLong());
        String timestamp = String.valueOf(DateTime.now().getTime() / 1000);
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('oauth_consumer_key', consumerKey);
        if(oauthToken != null){
            parameters.put('oauth_token',oauthToken);
        }
        parameters.put('oauth_signature_method', signatureMethod);
        parameters.put('oauth_timestamp', timestamp);
        parameters.put('oauth_nonce', nonce);
        parameters.put('oauth_version', oauthVersion);
        
        String signature = generateSignature(req,consumerSecret,parameters, signatureMethod);
        String header = generateHeader(signature, parameters);
        req.setHeader('Authorization', header);
        return req;
    }
    
    private static String generateHeader(String signature, Map<String,String> parameters) {
        String header = 'OAuth ';
        for (String key : parameters.keySet()) {
            header = header+key+'="'+parameters.get(key)+'",';
        }
        return header+'oauth_signature="'+signature+'"';
    }
    
    private static String generateSignature(HttpRequest req, String consumerSecret, Map<String,String> parameters, 
        String signatureMethod) {
        String s = createBaseString(parameters,req);
        // generate Message Authentication code
        Blob sig = Crypto.generateMac(
            signatureMethod
            , Blob.valueOf(s)
            , Blob.valueOf(consumerSecret)
        );
        return EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');
    }
    
    private static String createBaseString(Map<String,String> oauthParams, HttpRequest req) {
        Map<String,String> p = oauthParams.clone();
        if(req.getMethod().equalsIgnoreCase('post') && req.getBody()!=null &&
           req.getHeader('Content-Type')=='application/x-www-form-urlencoded') {
               p.putAll(getUrlParams(req.getBody()));
           }
        String host = req.getEndpoint();
        Integer n = host.indexOf('?');
        if(n>-1) {
            p.putAll(getUrlParams(host.substring(n+1)));
            host = host.substring(0,n);
        }
        List<String> keys = new List<String>();
        keys.addAll(p.keySet());
        keys.sort();
        string sa = '';
        for (String r : keys) sa += '\n' + r;
        String s = keys.get(0)+'='+p.get(keys.get(0));
        for(Integer i=1;i<keys.size();i++) {
            s = s + '&' + keys.get(i)+'='+p.get(keys.get(i));
        }
       
        return req.getMethod().toUpperCase()+ '&' +
            EncodingUtil.urlEncode(host, 'UTF-8') + '&' +
            EncodingUtil.urlEncode(s, 'UTF-8');
    }
    
    private static Map<String,String> getUrlParams(String value) { 
        Map<String,String> res = new Map<String,String>();
        if(value==null || value=='') {
            return res;
        }
        for(String s : value.split('&')) {
            List<String> keyValue = s.split('=');
            if(keyValue.size()>1) {
                // RFC 5849 section 3.4.1.3.1 and 3.4.1.3.2 specify that parameter names
                // and values are decoded then encoded before being sorted and concatenated
                // Section 3.6 specifies that space must be encoded as %20 and not +
                String encName = EncodingUtil.urlEncode(EncodingUtil.urlDecode(keyValue[0], 'UTF-8'), 'UTF-8').replace('+','%20');
                String encValue = EncodingUtil.urlEncode(EncodingUtil.urlDecode(keyValue[1], 'UTF-8'), 'UTF-8').replace('+','%20');
                res.put(encName,encValue);
            }
        }
        return res;
    }
}