public class ResponseWrapper {
    public String result;
    public String error;
    public String message;
    public Case cases;
    public ResponseWrapper(String result, String error, String message, Case cases){
       this.result = result;
       this.error = error;
       this.message = message;
       this.cases = cases;
    }
}