/**
 * @description Sales Order hook implementation that enables Sales Order to a custom Apex code bridge. The class can be
 * invoked from a JavaScript code in a Sales Order, e.g.:
 * <pre>
 * Visualforce.remoting.Manager.invokeAction(
 *   'csmso.CSRemoteActionDelegation.performAction',
 *   'FulfilmentItemActionInvoker',
 *   JSON.stringify(dfParams),
 *   function(result, event) {
 *   callback(result, event);
 *   },
 *   {escape: false}
 * );
 * </pre>
 * Where <em>dfParams</em> is an object that has to be serialised and sent to the Apax class,
 * <em>callback</em> is a function that handles the response. Important: the hook class must be global!
 *
 * FOR CSMLE integration, this function uses the plugin mechanism from CSUtil package.
 * <pre>
 * Visualforce.remoting.Manager.invokePlugin(
 *   'csutil.PluginExtensionController.invokePlugin',
 *   'FulfilmentItem',
 *   JSON.stringify(dfParams),
 *   function(result, event) {
 *   callback(result, event);
 *   },
 *   {escape: false}
 * );
 * </pre>
 */
global with sharing class FulfilmentItemActionInvoker extends csutil.PluginManager.ABasePlugin implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {

    /**
     * @description Implementation of the interface. The method receives JSON serialised request and responses with a
     * JSON structure that can be processed from JavaScript code within a Sales Order.
     *
     * @param parameters serialised JSON structure as a request
     * @return serialised JSON structure as a response
     */
    global String performAction(String parameters) {
        return createFulfilmentItem(new Map<String, Object>{'retry' => 0, 'param' => parameters}); 
    }

    public static String createFulfilmentItem(Object params) {
        CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
        Map<String, Object> paramsType = (Map<String, Object>) params;

        if((Integer) paramsType.get('retry') < 5) {
            try {
                CS_FulfilmentService.DigitalFulfilmentAttributes dfAttributes = 
                    (CS_FulfilmentService.DigitalFulfilmentAttributes)JSON.deserialize((String) paramsType.get('param'), CS_FulfilmentService.DigitalFulfilmentAttributes.class);
                
                Id fulfilmentItemId = DigitalFulfilmentAdapterUtil.createOrUpdateFulfilmentItem(dfAttributes, true);
                return JSON.serialize(fulfilmentItemId);
            }
            catch(System.DmlException dmlException) {
                dispatcher.addWorker(new CS_FulfilmentInvokerWorker(new Map<String, Object>{'retry' => ((Integer) paramsType.get('retry')) + 1, 'param' => (String )paramsType.get('param')}));
            }
            catch(System.QueryException QueryException) {
                dispatcher.addWorker(new CS_FulfilmentInvokerWorker(new Map<String, Object>{'retry' => ((Integer) paramsType.get('retry')) + 1, 'param' => (String )paramsType.get('param')}));
            }
            dispatcher.dispatch();
        }

        return null;
    }

	public class CS_FulfilmentInvokerWorker extends CS_QueueableWorker {
		public CS_FulfilmentInvokerWorker(Object params) {
			super('CS_FulfilmentInvokerWorker', params);
		}

		public override void doWork() {
            String fulfilmentItemId = createFulfilmentItem(params);
            Map<String, Object> paramsType = (Map<String, Object>) params;
            
            if(fulfilmentItemId != null) {
                this.success = false;
                CS_LogWorker log = CS_LogWorker.getInstance();
                log.addMessage((String) JSON.deserialize(fulfilmentItemId, String.class), 'Failed to upsert Fulfilment Item.', CS_const_LogMessage.Type_Error, 'CS_FulfilmentInvokerWorker');
                log.addAttachment('Payload', Blob.valueOf((String) paramsType.get('param')), 'application/javascript');
            }
		}
	}

    @RemoteAction
    global static String makeDummyFI(String salesOrderId){
        Id fulfilmentItemId = DigitalFulfilmentAdapterUtil.createDummyFulfilmentItem(salesOrderId);
        return JSON.serialize(fulfilmentItemId);
    }

    /* The CSUtil plug-in implementation */
    global override Object invoke(Object parameters) {
        return performAction((String)parameters);
    }
}