public class LinkedlnoAuthController{

    static Boolean isCode { get; set; }
    static String authCodeFromURL { get; set; }
    static List<LinkedIn_Information__c> linkedlnInfoList { get; set; }
    static String BasicInfo { get; set; }
    static String urlToSharedPost { get; set; }
    static String sharedInformation { get; set; }
    
    static Final String consumerKey = '86rpg5bt6xiwe8';
    static Final String consumerSecret ='HJpnMkXqvWbDmHxr';
    static Final String redirect_URI = 'https://divya2812-dev-ed.lightning.force.com/c/LinkedinSalesforceApp.app';
    static String linkedln_Scope = 'w_member_social%20r_emailaddress%20r_liteprofile';
    static Final String linkedln_AuthUrl = 'https://www.linkedin.com/oauth/v2/authorization?';
    static Final String accessToken_Endpoint = 'https://www.linkedin.com/oauth/v2/accessToken';
   
    @AuraEnabled
    public static string doGetAuthorizationCodevf(){
        String requestoAuthURL = linkedln_AuthUrl + 'response_type=code&client_id='+consumerKey+'&redirect_uri='+redirect_URI+
                                     '&state=12345567dggd&scope='+linkedln_Scope;
         return requestoAuthURL;
       // System.debug(' #### requestoAuthURL '+requestoAuthURL);
        
    }
    
    @AuraEnabled
    public static void doGetAccessTokenvf(){
        authCodeFromURL = ApexPages.currentPage().getParameters().get('code');
        System.debug('==authCodeFromURL==='+authCodeFromURL);
        if(authCodeFromURL == null || authCodeFromURL == '')
            isCode = true;
        else
            isCode = false;
            
        linkedlnInfoList = [Select Id, Name,Access_Token__c,Expires_In_Seconds__c From LinkedIn_Information__c Where Name='LinkedlnInfo'];
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        
        String requestTokenBody = 'code='+authCodeFromURL+'&grant_type=authorization_code'+
                                    '&client_id='+consumerKey+'&client_secret='+consumerSecret+
                                    '&redirect_uri='+redirect_URI;
        String errorMessage = '';
        
        System.debug('#### authCodeFromURL '+authCodeFromURL);
        System.debug('#### requestTokenBody '+requestTokenBody);
        
        httpReq.setMethod('POST');
        httpReq.setEndpoint(accessToken_Endpoint);
        httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpReq.setBody(requestTokenBody);
        
        try{
            httpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 200){
             
                Map<String,object> TokenInfo = (Map<String,object>)JSON.deserializeUntyped(httpRes.getBody());
                
                LinkedIn_Information__c linkedlnInfo = new LinkedIn_Information__c();
                linkedlnInfo.Access_Token__c =  String.valueOf(TokenInfo.get('access_token'));
                system.debug('==linkedlnInfo.Access_Token__c==='+linkedlnInfo.Access_Token__c);
                linkedlnInfo.Expires_In_Seconds__c =  Double.valueOf(TokenInfo.get('expires_in'));
                linkedlnInfo.Name ='LinkedlnInfo';
                linkedlnInfo.Id = linkedlnInfoList[0].Id;
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 
                                         'Congrattzzzzz..... You have done successfull Integration with Linkedln'));
                upsert linkedlnInfo;
                
            }else{
                errorMessage = 'Unexpected Error while communicating with LinkedIn API. '
                                    +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            }
        }catch(System.Exception e){
            System.debug('#### Exception Excuted '+e.getStackTraceString()+'  '+e.getMessage());
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage =  'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                                    +' Remote Site Setting and add '+' '+ accessToken_Endpoint +' Endpoint';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            }else{
                errorMessage = 'Unexpected Error while communicating with LinkedIn API. '
                                    +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            }
        }
    }
}
