/**
 * @name CS_const_Http
 * @description Constants for Http
 */
public class CS_const_Http {
    public static final String Request_Method_Get = 'GET';
    public static final String Request_Method_Post = 'POST';
    public static final String Request_Method_Put = 'PUT';
    public static final String Request_Method_Delete = 'DELETE';
    
    public static final String Header_Field_Auth = 'Authorization';
    public static final String Header_Field_Content_Type = 'Content-Type';
    public static final String Header_Field_Content_Length = 'Content-Length';
    public static final String Header_Field_Message = 'Message';
    public static final String Header_Field_SoapAction = 'SOAPAction';
    
    public static final String Content_Type_Application_Json = 'application/json';
    public static final String Content_Type_Application_Json_Utf8 = 'application/json;charset=UTF-8';
    public static final String Content_Type_Application_Soap_Xml = 'application/soap+xml';
    public static final String Content_Type_Text_Plain = 'text/plain';
    
    public static final String Format_Oauth = 'OAuth {0}';
    
    public static final String Response_Status_Ok = 'OK';
    public static final String Response_Status_Error = 'ERROR';
    
    public static final Integer Response_Status_Code_Ok = 200;
    public static final Integer Response_Status_Code_Accepted = 202;
    public static final Integer Response_Status_Code_Bad_Request = 400;
    public static final Integer Response_Status_Code_Forbidden = 403;
    public static final Integer Response_Status_Code_Not_Found = 404;
    public static final Integer Response_Status_Internal_Server_Error = 500;
    public static final Integer Response_Status_Service_Unavailable = 503;
}