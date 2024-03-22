//Class to help with common sObject Query and describe functions
public with sharing class sObjectHelper {
    

    public boolean includeUserRelationships {get; set;}

    private Map<String, string> objectFieldTypes;
    private Map<String, Schema.SobjectField> objectFieldInfo; 
    private string sObjectName; 

    //#
    //# Disable the constructor without a object name
    //#
    @TestVisible  
    private sObjectHelper ()
    {}

    public sObjectHelper (string objectName)
    {
        sObjectName = objectName;
        objectFieldTypes = new Map<String, string>();
        objectFieldInfo  = new Map<String, Schema.SobjectField>();
        this.includeUserRelationships = true;  
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();        

        //#
        //# get opp fields and ones off related objects too
        //#
        buildFieldTypes(gd, sObjectName, '', '', 1);
        
    }

    public sObject[] getSelectStarFrom(string whereClause, integer maxRecords, boolean includeRelationships)
    {
        string query = 'Select ' +  this.getFieldListAsCSV(includeRelationships)  + ' From ' + sObjectName;
        if ( whereClause != '' ) query += ' WHERE ' +  whereClause.replace('where','');  
        if ( maxRecords > 0 ) query += ' LIMIT ' +  maxRecords;
        

        sobject[] results = database.query(query);
        
        return results;
    }

    //#
    //# Return a simple CSV of all available fields on the instance
    //#
    public string getFieldListAsCSV(boolean includeRelationships)
    {       
        set<string> fieldNames = getAllFieldsAndTypesMap().keyset();    
        set<string> finalFieldNames = new set<string>();
        if (includeRelationships)
            finalFieldNames.addall(fieldNames);
        else
        {
            for (string s : fieldNames)
                if(!s.contains('.')) finalFieldNames.add(s);
        }
        
        return convertSetToCSV(finalFieldNames);    
    }

    //#
    //# provide a static method to get a list of all available fields
    //#
    public static string getObjectFieldListAsCSV(string objectName, boolean includeRelationships)
    {
        sObjectHelper hlp = new sObjectHelper(objectName);
         
        return hlp.getFieldListAsCSV(includeRelationships);
    }

    public static sObject[] getSelectStarFrom(string objectName, string whereClause, integer maxRecords, boolean includeRelationships)
    {
        sObjectHelper  hlp = new sObjectHelper(objectName);
        return hlp.getSelectStarFrom(whereClause, maxRecords, includeRelationships);
        
    }


    //##################################################################
    //# Get the field Type
    //#
    public string getFieldType(string fieldName)
    {
        string fieldNameKey = fieldName.toLowerCase();              
        return  objectFieldTypes.get(fieldNameKey);
    }
    
    //##################################################################
    //# get an entire map of fields and their type, keyed on fieldName
    //#
    public map<string,string> getAllFieldsAndTypesMap()
    {
        return objectFieldTypes; 
    }
    

    //#
    //# get the list of fields for a specified object
    //#
    private void buildFieldTypes(Map<String, Schema.SObjectType> globalDescribe, string objectName, string relationshipName, string keyPrefix, integer depth)
    {   
                    
        if (depth > 2) return;  
    
        Schema.SObjectType ctype = globalDescribe.get(objectName);
        Map<String, Schema.SobjectField> fieldInfoMap = ctype.getDescribe().fields.getMap();
        
        for(Schema.Sobjectfield F : fieldInfoMap.values())
        {       
            Schema.Describefieldresult dF = F.getDescribe();
            if (dF.isAccessible())
            {
            
                
                string fieldNameKey = dF.getName().toLowerCase();
                
                if (relationshipName != '') fieldNameKey = relationshipName.toLowerCase() + '.' + fieldNameKey;
                
                if (dF.getType().name().equalsIgnoreCase('Reference') && !dF.isNamePointing())
                {   
                    
                    String rName = dF.getRelationshipName();
                    if (rName != null)
                    {
                        if (relationshipName != '') rName = relationshipName.toLowerCase() + '.' + rName;
                
                        List<Schema.Sobjecttype> refList = dF.getReferenceTo();             
                        string childObjectName  = refList.get(0).getDescribe().getName();
                        if ( this.includeUserRelationships) {
                            buildFieldTypes(globalDescribe, childObjectName, rName ,keyPrefix + rName + '.', depth +1);
                        }
                    }                                               
                }   
                //else
                //{
                
                    objectFieldTypes.put(fieldNameKey,string.valueOf( dF.getType()));
                    objectFieldInfo.put(fieldNameKey, F);
                //}                 
            }
                
        }
                    
                                                        
    }
    
    private static String convertSetToCSV(set<String> vSet) {
        
        Integer i = 0;
        string listString = '';
        if (vSet.size() > 0) {
            for (String lSet : vSet) {              
                listString += (i == 0) ? lSet :  ',\n' + lSet;
                i++;
            }
        }
        return listString ;
    }

    //#
    //# Just an instance accessor to the static method - nicer when
    //# consuming the class in calling code.
    //#
    public object getFieldValue(sObject obj, string fieldName)
    {
        return getsObjectFieldValue(obj,fieldName);
    }

    //#
    //# get a field value for an sObject field - INCLUDING Related object
    //#
    public static object getsObjectFieldValue(sObject obj, string fieldName)
    {
        list<string> items = fieldName.split('\\.');
        
        string actualFieldName = items.get(items.Size()-1);
            
        //#
        //# we can only go to three levels deep including the root, 
        //# so no need for loop complexity                  
        //#
        object retVal= (items.Size() == 1) ? obj.get(actualFieldName) :
                        (items.Size() == 2) ? obj.getSObject(items.get(0)).get(actualFieldName) :
                        (items.Size() == 3) ? obj.getSObject(items.get(0)).getSObject(items.get(1)).get(actualFieldName) :
                        null;

        return retval;
    }


}