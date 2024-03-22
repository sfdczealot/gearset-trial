/**
 * Created by petar on 16/9/20.
 */


global with sharing class CS_GetAddonAssociations implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {

    global String performAction(String parameters) {
        csaom.GetAddOnsPlugin aomPlugin = new csaom.GetAddOnsPlugin();
        return JSON.serialize(aomPlugin.invoke(parameters));
    }

}