SHELL SCRIPTS
============================================================================================================================
1). I want to automate the deployment of an application to multiple servers. How would you achieve this using a shell script?
=============================================================================================================================
#!/bin/bash
# Define an array of server IP addresses or hostnames
SERVERS=("server1.example.com" "server2.example.com")
# Path to your application files
APP_PATH="/home/ubuntu/index.html"
# Destination path on the remote servers
DEPLOY_PATH="/var/www/html/"

# Loop through each server and deploy the application
for SERVER in "${SERVERS[@]}"; do
    echo "Deploying to $SERVER"
    # Securely copy application files to the server
    scp -r $APP_PATH user@$SERVER:$DEPLOY_PATH
    # Restart the application service on the server
    ssh user@$SERVER "systemctl restart apache2"
    echo "Deployment to $SERVER completed"
done
============================================================================================================================
🔹 Question 2: Create a script to monitor disk usage and send an alert if usage exceeds 80%.
=============================================================================================================================
#!/bin/bash
# Define the disk usage threshold
THRESHOLD=80

# Get disk usage information, excluding certain filesystems
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output; do
    usage=$(echo $output | awk '{ print $1}' | sed 's/%//g')
    partition=$(echo $output | awk '{ print $2 }')
    if [ $usage -ge $THRESHOLD ]; then
        echo "Alert: High disk usage on $partition ($usage%)"
        # Send email or other alert here (e.g., using mail command)
    fi
done

============================================================================================================================
🔹 Question 3: Write a script to check if a service is running, and start it if it’s not.
=============================================================================================================================
#!/bin/bash

# Define the service to check
SERVICE="httpd"

# Check if the service is active
if ! systemctl is-active --quiet $SERVICE; then
    echo "$SERVICE is not running, starting it..."
    systemctl start $SERVICE
    echo "$SERVICE started"
else
    echo "$SERVICE is already running"
fi
============================================================================================================================
🔹 Question 4: Write a script to backup logs older than 7 days and delete the original files.
=============================================================================================================================
#!/bin/bash

# Define the log directory and backup directory
LOG_DIR="/var/log/myapp"
BACKUP_DIR="/backup/logs"

# Find and archive logs older than 7 days
find $LOG_DIR -type f -mtime +7 -exec tar -rvf $BACKUP_DIR/logs_backup_$(date +%F).tar {} \; -exec rm {} \;
echo "Logs older than 7 days have been backed up and deleted."

============================================================================================================================
🔹 Question 5: Create a script to automate database backup.
=============================================================================================================================
#!/bin/bash

# Define database credentials and backup directory
DB_NAME="mydatabase"
DB_USER="dbuser"
DB_PASS="dbpass"
BACKUP_DIR="/backup/db"

# Perform the backup using mysqldump
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_DIR/db_backup_$(date +%F).sql
echo "Database backup completed."

============================================================================================================================
🔹 Question 6: Write a script to rotate logs on a weekly basis.
=============================================================================================================================
#!/bin/bash

# Define the log directory and archive directory
LOG_DIR="/var/log/myapp"
ARCHIVE_DIR="/archive/logs"

# Move logs older than 7 days to the archive directory
find $LOG_DIR -type f -name "*.log" -mtime +7 -exec mv {} $ARCHIVE_DIR \;
echo "Weekly log rotation completed."

============================================================================================================================
🔹 Question 7: Write a script to check the status of multiple services and restart any that are not running.
=============================================================================================================================
#!/bin/bash

# Define the services to check
SERVICES=("nginx" "mysql" "redis")

# Loop through each service and check its status
for SERVICE in "${SERVICES[@]}"; do
    if ! systemctl is-active --quiet $SERVICE; then
        echo "$SERVICE is not running, restarting it..."
        systemctl restart $SERVICE
        echo "$SERVICE restarted"
    else
        echo "$SERVICE is running"
    fi
done

============================================================================================================================
🔹 Question 8: Create a script to update a web application by pulling the latest code from a Git repository.
=============================================================================================================================
#!/bin/bash

# Define the web application directory and Git repository
WEB_DIR="/var/www/myapp"
GIT_REPO="https://github.com/user/myapp.git"

# Change to the application directory and pull the latest code
cd $WEB_DIR
git pull $GIT_REPO
echo "Web application updated from the latest code."
# Restart the web server
systemctl restart nginx

============================================================================================================================
🔹 Question 9: Write a script to compress and archive old log files.
=============================================================================================================================
#!/bin/bash

# Define the log directory and archive directory
LOG_DIR="/var/log/myapp"
ARCHIVE_DIR="/archive/logs"

# Find and compress logs older than 30 days
find $LOG_DIR -type f -name "*.log" -mtime +30 -exec gzip {} \;
# Move compressed logs to the archive directory
find $LOG_DIR -type f -name "*.log.gz" -mtime +30 -exec mv {} $ARCHIVE_DIR \;
echo "Old log files have been compressed and archived."

============================================================================================================================
🔹 Question 10: Write a script automate the cleanup of temporary files older than 10 days.
=============================================================================================================================
#!/bin/bash

# Define the temporary directory
TEMP_DIR="/tmp"

# Find and delete files older than 10 days
find $TEMP_DIR -type f -mtime +10 -exec rm {} \;
echo "Temporary files older than 10 days have been deleted."

============================================================================================================================
🔹 Question 11: Write a script to monitor CPU usage and alert if it exceeds a certain threshold.

=============================================================================================================================
#!/bin/bash

# Define the CPU usage threshold
THRESHOLD=80

# Get current CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
if (( $(echo "$CPU_USAGE > $THRESHOLD" | bc -l) )); then
    echo "Alert: High CPU usage ($CPU_USAGE%)"
    # Send email or other alert here (e.g., using mail command)
fi

============================================================================================================================
🔹 Question 12: Write a script to install a list of packages.

=============================================================================================================================
#!/bin/bash

# Define the list of packages to install
PACKAGES=("nginx" "mysql-server" "redis")

# Loop through each package and install it if not already installed
for PACKAGE in "${PACKAGES[@]}"; do
    if ! dpkg -l | grep -q $PACKAGE; then
        echo "Installing $PACKAGE..."
        sudo apt-get install -y $PACKAGE
        echo "$PACKAGE installed"
    else
        echo "$PACKAGE is already installed"
    fi
done

============================================================================================================================
🔹 Question 13: Write a script to sync a local directory with a remote directory using rsync.

=============================================================================================================================
#!/bin/bash

# Define the local and remote directories
LOCAL_DIR="/path/to/local"
REMOTE_USER="user"
REMOTE_HOST="remote_host"
REMOTE_DIR="/path/to/remote"

# Sync the local directory with the remote directory
rsync -avz $LOCAL_DIR $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR
echo "Local directory synced with remote directory."

============================================================================================================================
🔹 Question 14: Write a script to check the health of a web application by sending an HTTP request and checking the response.

=============================================================================================================================
#!/bin/bash

# Define the URL and expected HTTP status code
URL="http://example.com"
EXPECTED_STATUS=200

# Send an HTTP request and get the status code
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)
if [ $STATUS -ne $EXPECTED_STATUS ]; then
    echo "Alert: Web application is not healthy. Status code: $STATUS"
    # Send email or other alert here (e.g., using mail command)
else
    echo "Web application is healthy. Status code: $STATUS"
fi
============================================================================================================================
🔹 Question 15: Write a script to automate the configuration of a new server with necessary packages and settings.
=============================================================================================================================
#!/bin/bash

# Define the list of packages to install
PACKAGES=("nginx" "mysql-server" "redis")
# Define firewall rules to allow
FIREWALL_RULES=("80/tcp" "443/tcp")

# Update package list and install packages
sudo apt-get update
for PACKAGE in "${PACKAGES[@]}"; do
    sudo apt-get install -y $PACKAGE
done

# Configure the firewall to allow specified rules
for RULE in "${FIREWALL_RULES[@]}"; do
    sudo ufw allow $RULE
done
sudo ufw enable
echo "Server configuration completed."
====================================================================================================================
1. Backup Script 
====================================================================================================================
Script 
#!/bin/bash 
SOURCE="/home/ubuntu/aditya" 
DESTINATION="/home/ubuntu/jaiswal/" 
DATE=$(date +%Y-%m-%d_%H-%M-%S)  
# Create backup directory and copy files
mkdir -p $DESTINATION/$DATE 
cp -r $SOURCE $DESTINATION/$DATE 
echo "Backup completed on $DATE" 

Explanation 
• SOURCE: The directory to be backed up. 
• DESTINATION: The directory where the backup will be stored. 
• DATE: Captures the current date and time to create a unique backup folder. 
• mkdir -p $DESTINATION/$DATE: Creates the backup directory if it does not exist. 
• cp -r $SOURCE $DESTINATION/$DATE: Copies the contents of the source directory to the backup directory. 
• echo "Backup completed on $DATE": Outputs a message indicating the completion of the backup. 

Scheduling with Cron:
To run the backup script at regular intervals, use crontab -e to edit the crontab file and add: 
* * * * * /path/to/backup_script.sh This example runs the script every minute. Adjust the schedule as needed.  
================================================================================================================
2. Disk Usage Check Script 
================================================================================================================
Script 
#!/bin/bash THRESHOLD=80 
# Check disk usage and print a warning if usage is above the threshold 
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | 
while read output; 
do   usage=$(echo $output | awk '{ print $1}' | cut -d'%' -f1)   
partition=$(echo $output | awk '{ print $2 }')   
if [ $usage -ge $THRESHOLD ]; then     
echo "Warning: Disk usage on $partition is at ${usage}%"   
fi done 

Explanation 
• THRESHOLD: Sets the disk usage percentage threshold. 
• df -H: Lists disk usage in human-readable format. 
• grep -vE '^Filesystem|tmpfs|cdrom': Filters out unnecessary lines. 
• awk '{ print $5 " " $1 }': Extracts the usage percentage and partition name. 
• while read output: Iterates over each line of the filtered output. 
• usage=$(echo $output | awk '{ print $1}' | cut -d'%' -f1): Extracts the usage percentage. 
• partition=$(echo $output | awk '{ print $2 }'): Extracts the partition name. 
• if [ $usage -ge $THRESHOLD ]; then: Checks if the usage exceeds the threshold. 
• echo "Warning: Disk usage on 𝑝𝑎𝑟𝑡𝑖𝑡𝑖𝑜𝑛𝑖𝑠𝑎𝑡{usage}%": Prints a warning message.   
================================================================================================================
3. Service Health Check Script 
================================================================================================================
Script 
#!/bin/bash SERVICE="nginx" 
# Check if the service is running, if not, start it if systemctl is-active --quiet $SERVICE;
then   echo "$SERVICE is running" 
else   echo "$SERVICE is not running"   
systemctl start $SERVICE fi 

Explanation 
• SERVICE: The name of the service to check. 
• systemctl is-active --quiet $SERVICE: Checks if the service is running. 
• echo "$SERVICE is running": Prints a message if the service is running. 
• systemctl start $SERVICE: Starts the service if it is not running.  
================================================================================================================
4. Network Connectivity Check Script 
================================================================================================================
Script 
#!/bin/bash HOST="google.com" 
# Output file OUTPUT_FILE="/home/ubuntu/output.txt" 
# Check if the host is reachable if ping -c 1 $HOST &> /dev/null then   
echo "$HOST is reachable" >> $OUTPUT_FILE 
else   echo "$HOST is not reachable" >> $OUTPUT_FILE 
fi 

Explanation 
• HOST: The hostname to check.
• OUTPUT_FILE: The file to write the output to. 
• ping -c 1 $HOST &> /dev/null: Pings the host once, suppressing output. 
• echo "$HOST is reachable" >> $OUTPUT_FILE: Writes to the output file if the host is reachable. 
• echo "$HOST is not reachable" >> $OUTPUT_FILE: Writes to the output file if the host is not reachable.  
================================================================================================================
5. Database Backup Script 
================================================================================================================
Installation 
Install MySQL: 
sudo apt install mysql-server 
Set up MySQL password: 
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES; 

Script 
#!/bin/bash 
DB_NAME="mydatabase" BACKUP_DIR="/path/to/backup" 
DATE=$(date +%Y-%m-%d_%H-%M-%S) 
# Perform a database backup and save it to the backup directory m
ysqldump -u root -p $DB_NAME > $BACKUP_DIR/$DB_NAME-$DATE.sql 
echo "Database backup completed: $BACKUP_DIR/$DB_NAME-$DATE.sql" 

Explanation 
• DB_NAME: The name of the database to back up. 
• BACKUP_DIR: The directory where the backup will be stored. 
• DATE: Captures the current date and time. 
• mysqldump -u root -p $DB_NAME > $BACKUP_DIR/$DB_NAME-$DATE.sql: Dumps the database to a SQL file. 
• echo "Database backup completed: $BACKUP_DIR/$DB_NAME-$DATE.sql": Outputs a message indicating the completion of the backup.   
================================================================================================================
6. System Uptime Check Script 
================================================================================================================
Script 
#!/bin/bash # Print the system uptime uptime -p 
Explanation 
• uptime -p: Prints the system uptime in a human-readable format.  
================================================================================================================
7. Listening Ports Script 
================================================================================================================
Installation 
Install net-tools: 
sudo apt install net-tools 

Script 
#!/bin/bash # List all listening ports and the associated services
netstat -tuln | grep LISTEN 

Explanation 
• netstat -tuln: Lists all TCP and UDP listening ports. • grep LISTEN: Filters the output to show only listening ports.
================================================================================================================
8. Automatic Package Updates Script 
================================================================================================================
Script 
#!/bin/bash # Update system packages and clean up unnecessary packages 

apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get clean echo "System packages updated and cleaned up" 

Explanation 
• apt-get update: Updates the package list. 
• apt-get upgrade -y: Upgrades all installed packages.
• apt-get autoremove -y: Removes unnecessary packages. 
• apt-get clean: Cleans up the package cache. 
• echo "System packages updated and cleaned up": Outputs a message indicating the completion of the update and cleanup.  
================================================================================================================
9. HTTP Response Times Script 
================================================================================================================
Script 
#!/bin/bash 
URLS=("https://www.devopsshack.com/" "https://www.linkedin.com/") # Check HTTP response times 
for multiple URLs for URL in "${URLS[@]}"; 
do   RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}\n' $URL)   
echo "Response time for $URL: $RESPONSE_TIME seconds" 
done 

Explanation 
• URLS: An array of URLs to check. 
• for URL in "${URLS[@]}": Iterates over each URL.
• curl -o /dev/null -s -w '%{time_total}\n' $URL: Uses curl to fetch the URL and measure the total response time. 
• echo "Response time for $URL: $RESPONSE_TIME seconds": Prints the response time for each URL.    
================================================================================================================
10. Monitor System Processes and Memory Usage Script
================================================================================================================
Script 
#!/bin/bash # Monitor system processes and their memory usage 
ps aux --sort=-%mem | head -n 10 

Explanation 
• ps aux: Lists all running processes. 
• --sort=-%mem: Sorts the processes by memory usage in descending order. 
• head -n 10: Displays the top 10 processes by memory usage.
