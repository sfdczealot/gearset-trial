public class CS_utl_Currency {
    public static Map<String, CurrencyType> currencies {
        get {
            if(currencies == null) {
                currencies = new Map<String, CurrencyType>();
                for(CurrencyType ct : [SELECT id, DecimalPlaces, IsoCode FROM CurrencyType]) {
                    currencies.put(ct.IsoCode, ct);
                }
            }
            return currencies;
        }
        set;
    }

    public static Integer getDecimalPlaces(String isoCode) {
        if(currencies.containsKey(isoCode)) return currencies.get(isoCode).DecimalPlaces;
        else return 2;
    }
}