# DevOps-Projects
BanoQabil DevOps Projects

Service Log Monitoring Script
What is this script for?
This script helps monitor log files for different services. It checks the log files for any errors (like exceptions) and prints them out with some extra info, like the time they happened and which service had the error. It runs in the background and keeps checking the logs until you stop it.

How does it work?
1. List of Services
At the beginning of the script, there’s a list of services that it will monitor. These are the names of the services, and the script looks for their log files in a specific folder.

bash
Copy
SERVICES=(
  notification-broker-services
  receiving-services
  rest-handler-cas
  rest-handler-Host
  rest-handler-inquiry
  rest-handler-MX
  rest-handler-payment
  rest-handler-payment-async
)
2. Where are the logs?
All the logs are saved in a folder called /apps/logs/. Inside that folder, there’s a subfolder for each service where its log files are stored. For example, the log file for notification-broker-services will be in /apps/logs/notification-broker-services/.

bash
Copy
LOG_BASE="/apps/logs"
3. Monitoring Each Service
The script checks the log files for each service and looks for any "Exception" errors. If it finds any, it will show them on the screen with the time they happened and the name of the service. If the log file changes, it will stop watching the old one and start watching the new one.

4. What Happens If the Log File Is Missing?
If the script can’t find the log file for a service, it waits for a few seconds and then checks again. This keeps happening until it finds the log file.

5. Graceful Stop (CTRL+C)
If you press CTRL+C to stop the script, it will stop monitoring all services and exit safely without leaving anything running.

6. How to Use It
First, make sure the script has permission to run by typing:

bash
Copy
chmod +x monitor_log.sh
Then, you can run the script by typing:

bash
Copy
./monitor_log.sh
Extra Notes:
The script works by looking for log files named like this: application.YYYY-MM-DD_HH.log for each service.

Make sure your logs are in the right folders for each service to avoid any issues.

The script keeps running until you stop it, so you can leave it running in the background to monitor everything.
