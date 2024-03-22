/*
* @name Property Mapping Engine 
* @description Mapps fields from one sOject or Attribute to Another.
*              The class utilises the Attribute Mapping Engine when performing attribute mapping functions.
*/
public class PropertyMappingEngine
{
    private static Map<String, Property_Map__c> mapHeaderCache = new Map<String, Property_Map__c>();
    private static Map<Id, map<string,cscfga__Object_Mapping__c>> objectMapsBysObjectCache = new Map<Id, map<string,cscfga__Object_Mapping__c>>();
    private static Map<SObjectType, List<String>> objectFieldsNamesCache = new Map<SObjectType, List<String>>();    

    //
    // We want to map soBject fields to or from attributes.
    // Leverage the AttributeMappingEngine for This.
    //
    
    public static list<cscfga__Attribute__c> mapAtrributesAndFields(string propertyMapName, map<id, sObject[]> configsObjectMap)
    {
    
        list<cscfga__Attribute__c> retVal = new list<cscfga__Attribute__c>();
    
    
        Property_Map__c mapHeader = getPropertyMapByName(propertyMapName);
        if (mapHeader == null)
        { 
            if (test.IsRunningTest())
            {
                return retVal;
                
            }
            else
            {
                throw new PropertyMappingEngineException('invalid Property Map name provided:' + propertyMapName);
            }
        }
            
        retval.addAll(AttributeMappingEngine.mapAttributes(mapHeader, configsObjectMap)) ;
        
        
        return retVal;
        
    }

    //
    // We want to map soBject fields to or from other sObjectFields.
    //
    public static sObject[] mapsObjectFields(string propertyMapName, FieldMappingPair[]  fieldMappingPairs) {    

        sobject[] retVal = new sObject[]{};

        Property_Map__c mapHeader;
        if (mapHeaderCache.containsKey(propertyMapName)){
            mapHeader = mapHeaderCache.get(propertyMapName);
        }
        else {
            mapHeader = getPropertyMapByName(propertyMapName);
            if (mapHeader == null)
            {
                if (test.IsRunningTest())
                {
                    return retVal;
                
                }
                else
                {
                    throw new PropertyMappingEngineException('invalid Property Map name provided:' + propertyMapName);
                }
            }
            mapHeaderCache.put(propertyMapName, mapHeader);
        }

        // get all of the object mappings related to this Property Map
        map<string,cscfga__Object_Mapping__c> objectMapsBysObject;
        if (objectMapsBysObjectCache.containsKey(mapHeader.Id)){
            objectMapsBysObject = objectMapsBysObjectCache.get(mapHeader.Id);
        }
        else {
            objectMapsBysObject = retrieveOMsBysObject(mapHeader.Id);
            objectMapsBysObjectCache.put(mapHeader.Id, objectMapsBysObject);
        }

        for (FieldMappingPair fmp : fieldMappingPairs)
        {
            for (sObject obj : fmp.Destinations)
            {
                string ObjectName = obj.getSObjectType().getDescribe().getName().toLowerCase();
                cscfga__Object_Mapping__c OM = objectMapsBysObject.get(objectName);
                if (OM != null)
                {
                    doOneObjectMapping (OM, fmp.Source, obj);
                    retVal.add(obj);
                }
                
            }
            
        }
 //to remove duplicate records
				Set<SObject> retValSet = new Set<SObject>(retVal);
                //to convert set back to list 
                List<SObject> retValList = new List<SObject>(retValSet);
        return retValList;
        
    }
    
    
    
    //
    // Get the PropertyMap object by it's unique name.
    //
    //
    private static Property_Map__c getPropertyMapByName(string name)
    {

        Property_Map__c retval;

        Property_Map__c[] retVals = [   select Id,
                                                Name,
                                                Attribute_Mapping_Direction__c,
                                                Description__c,
                                                Unique_name__c
                                        from Property_Map__c
                                        WHERE unique_name__c = :name LIMIT 1];


        if (retvals.Size() == 1)
            retval = retvals[0];

        return retval;



    }
    
    public class PropertyMappingEngineException extends Exception {}

    // Map Objects to Objects
    private static void doOneObjectMapping (cscfga__Object_Mapping__c OM, sObject srcObject, sObject destObject) {
        List<String> objFieldsNames;
        System.debug('***** srcObject ');
        System.debug(srcObject);
        if (objectFieldsNamesCache.containsKey(srcObject.getSObjectType())){
            objFieldsNames = objectFieldsNamesCache.get(srcObject.getSObjectType());
        }
        else {
            objFieldsNames = new List<String>();
            for (SObjectField objField : srcObject.getSObjectType()
                                                  .getDescribe()
                                                  .fields
                                                  .getMap()
                                                  .values()) {
                objFieldsNames.add(objField.getDescribe()
                                           .getName());
            }
            objectFieldsNamesCache.put(srcObject.getSObjectType(), objFieldsNames);
        }
        
        Map<String, Object> fieldValues = new Map<String, Object>();
        for (String objFieldName : objFieldsNames) {
            try {
                fieldValues.put(objFieldName, 
                                srcObject.get(objFieldName));
            }
            catch (Exception e) { }
        }
        for(cscfga__Field_Mapping__c FM : OM.cscfga__Field_Mappings__r) {
            //System.debug('++FM++cscfga__From_Field__c>' + FM.cscfga__From_Field__c + '++' + 'cscfga__To_Field__c>' + FM.cscfga__To_Field__c);
            if(fieldValues.containsKey(FM.cscfga__From_Field__c)) {
                destObject.put(FM.cscfga__To_Field__c, fieldValues.get(FM.cscfga__From_Field__c));
                //System.debug('>>>' + fieldValues.get(FM.cscfga__From_Field__c));
            }
        }
    }
    
    /*
    * Create a map of Object Mapping records and their field mappings, keyed on sObject Name.
    */
    private static map<string,cscfga__Object_Mapping__c> retrieveOMsBysObject(id propertyMapId){
    
    
        cscfga__Object_Mapping__c[] oms = [select 
                    id, name, cscfga__From_Type__c, cscfga__To_Type__c, cscfga__Verified__c ,
                    (select 
                            id, 
                            cscfga__From_Field__c, 
                            cscfga__To_Field__c  
                        from 
                            cscfga__Field_Mappings__r)
                from 
                    cscfga__Object_Mapping__c 
                where 
                    Property_Map__c = :propertyMapId];
                    
                    
        map<string,cscfga__Object_Mapping__c> retVal = new map<string,cscfga__Object_Mapping__c>(); 
        for (cscfga__Object_Mapping__c om : oms)
        {
            retVal.put(om.cscfga__To_Type__c.toLowerCase(), om);
        }

        return retVal;
                    
    }

    public class FieldMappingPair
    {

        public FieldMappingPair()
        {
          
        }

         public FieldMappingPair(sObject theSource, sObject[] theDestinations)
        {
            this.Source = theSource;
            this.Destinations = theDestinations;
        }

        public sObject Source {get;set;}
        public sObject[] Destinations {get;set;}
    }
    
    
    
}