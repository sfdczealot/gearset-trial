/**
 * @name CS_utl_Rollup
 * @description Utility method for rolling up values
 * @revision
 *
 */
public class CS_utl_Rollup {
	public enum Operation {
		SUM,
		COUNT,
		COUNT_DISTINCT,
		MIN,
		MAX,
		LOGICAL_AND,
		LOGICAL_OR
	}
	
	public static List<RollupDefinition> init(List<RollupDefinition> definitionTemplates) {
		List<RollupDefinition> rollupDefinitions = new List<CS_utl_Rollup.RollupDefinition>();
    	for(RollupDefinition rp : definitionTemplates) {
    		rollupDefinitions.add(rp.clone());
    	}
    	
    	return rollupDefinitions;
	}
	
	public class RollupDefinition {
		public String fromField {get; set;}
		public String toField {get; set;}
		public Operation operator {get; set;}
		public Object condition {get; set;}
		public Object value {get; set;}
		
		public RollupDefinition(String fromField, String toField, Operation operator, Object condition, Object initialValue) {
			this.fromField = fromField;
			this.toField = toField;
			this.operator = operator;
			this.value = initialValue;
			this.condition = condition;
		}
		
		public void calculate(SObject obj) {
			if(this.operator == Operation.SUM) {
				this.value = (Decimal) this.value + CS_utl_SObject.getDecimalValue(this.fromField, obj);
			}
			else if(this.operator == Operation.COUNT) {
				this.value = (Decimal) this.value + (this.condition != null ? (CS_utl_Comparison.compare(this.condition, obj.get(this.fromField)) == CS_utl_Comparison.Comparison.EQUALS ? 1 : 0) : 1); 
			}
			else if(this.operator == Operation.COUNT_DISTINCT) {
				if(this.condition == null || CS_utl_Comparison.compare(this.condition, obj.get(this.fromField)) == CS_utl_Comparison.Comparison.EQUALS) ((Set<String>)this.value).add(String.valueOf(obj.get(this.fromField)));
			}
			else if(this.operator == Operation.MIN) {
				this.value = this.value == null || CS_utl_Comparison.compare(obj.get(this.fromField), this.value) == CS_utl_Comparison.Comparison.LESS_THAN ? obj.get(this.fromField) : this.value;
			}
			else if(this.operator == Operation.MAX) {
				this.value = this.value == null || CS_utl_Comparison.compare(obj.get(this.fromField), this.value) == CS_utl_Comparison.Comparison.GREATER_THAN ? obj.get(this.fromField) : this.value;
			}
			else if(this.operator == Operation.LOGICAL_AND) {
				this.value = (Boolean) this.value && (CS_utl_Comparison.compare(this.condition, obj.get(this.fromField)) == CS_utl_Comparison.Comparison.EQUALS);
			}
			else if(this.operator == Operation.LOGICAL_OR) {
				this.value = (Boolean) this.value || (CS_utl_Comparison.compare(this.condition, obj.get(this.fromField)) == CS_utl_Comparison.Comparison.EQUALS);
			}
		}
		
		public Object getValue() {
			if(this.operator == Operation.COUNT_DISTINCT) {
				return ((Set<String>)this.value).size();
			}
			else {
				return this.value;
			}
		}
	}
}