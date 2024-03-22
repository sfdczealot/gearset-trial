global class TargetingPresetEditorController {
    // Method for update/edit data. For instance, PresetSave
    @RemoteAction
    public static String performAction(String dummy, String payload) {
        return MediaTargetingWidget.performAction(payload);
    }

    // Method called in read-only context
    @ReadOnly
    @RemoteAction
    public static String performReadOnlyAction(String dummy, String payload) {
        return MediaTargetingWidget.performAction(payload);
    }
}