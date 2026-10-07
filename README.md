#AUTOMATED DEPLOYMENT AGENT FOR STUDENT ATTENDANCE TRACKER
The script deploy_agent.sh is used for deploying the attendance tracker,running it and keeping attendance logs. The projects show scripting, files management,permissions, management and signal handling.

#Project structure

deploy_agent.sh
 templates/
 ├── attendance_checker.py
 ├── assets.csv
 └── config.json 

When the script runs, it creates the project with this structure;

attendance_tracker_<project_name>/ 
├── Helpers/
 │ ├── attendance_checker.py
 │ ├── assets.csv 
 │ └── config.json 
 ├── reports/
 └── archives/
 ├── attendance/ 
 └── absent/ 
The python is kept in the templates and copied into the deployed project 

#Requirements
Bash 
 Python 3 
 Zip 

#how to run the script
Make it executable
chmod +x deploy_agent.sh 
Run the deployment agent
./deploy_agent.sh 

A menu will be displayed with
1. Deploy application
 2. Run application
 3. Archive logs
 4. Exit 
#Feature 1: Deploy application
Select 1 to deploy a new student attendance tracker
It then asks for project name
For example enter : demo
The result will be 
attendance_tracker_demo/ 
If it exists , the script will ask if you want to overwrite it or cancel it
The following directories are then created
`attendance_checker.py`
  `assets.csv`
  `config.json` 
The scripts then ask how the roster should be created
Option 1:copy students from the template
It then asks you how many students you want to copy from the template
The selected students retain their previous attendance counts
Option 2 ; generate a fresh roster
It creates a new roster using students names and email
The generated students begin with both zero attendance and absence count.

#File permissions
The script sets required permissions
Python application is made executable
chmod +x Helpers/attendance_checker.py 
The config file can only be accessed by the owner
chmod 600 Helpers/config.json 
#Updating attendance thresholds
The script asks whether the attendance warning and failure should be changed
Once changed they are updated on the config.json
Python uses the thresholds to calculate the attendance percentage

#Automatic application startup
After complete deployment the attendance tracker is automatically started and it asks for attendance . entering P marks the student present and A absent.

#Feature 2:  run the application
Select 2 from the main menu to run the deployed attendance tracker
It asks for project name
It automatically starts the python

The application reads:
 Helpers/config.json
 Helpers/assets.csv 

and writes its reports to:
 reports/ 

#Feature 3: archive logs
Select option 3 from the main menu
The script asks for project name and checks the reports directory

Attendance logs are stored in:
 reports/attendance.log

 When an attendance log exists, it is copied to:
 archives/attendance/ 

The archived filename contains a timestamp in the following format: attendance_YYYYMMDD_HHMMSS.log 

Absent logs are stored in:
 reports/absent.log

 When an absent log exists, it is copied to:
 archives/absent/ 

The filename follows the same timestamp format:
 absent_YYYYMMDD_HHMMSS.log 

#Ctrl+C test
Run the shell script
Select 1
Enter project name
When the deployment is running, click Ctrl+C . The script displays an interruption message.
It creates a zip archive containing files that had already been created
On the Ctrl+Z test the same procedure is followed
The deployment interruption handler creates an archive of the incomplete  project before exiting

After a successful deployment, the project structure was tested using:
 find attendance_tracker_<project_name> -maxdepth 3 -print 

#Testing summary
Successful deployment of a new attendance tracker. 
 overwrite confirmation. 
 Template roster copying. 
 New roster generation. 
 Attendance threshold updates. 
 Python executable permissions. 
 Restricted configuration file permissions. 
 Automatic startup after deployment. 
Generation of attendance and absent logs. 
Timestamped log archiving. 
 Handling missing log files. 
 `Ctrl+C` deployment interruption. 
 `Ctrl+Z` deployment interruption. 
 Creation of ZIP archives after interrupted deployments. 
 










