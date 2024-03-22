global class LogSinkDemo implements cscfga.Log.Sink
{ global void logMessage(LoggingLevel level, String message)
 {
 System.debug(level, 'LOGSINK: ' + message);
 }
}