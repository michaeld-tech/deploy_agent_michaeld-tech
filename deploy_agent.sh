#!/bin/bash

# ==========================================================
# Student Attendance Tracker
# Automated Deployment and Process Management
# ==========================================================


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
# Deployment interruption handler

deployment_interrupted() {

    signal="$1"

    echo
    echo "Deployment interrupted by $signal"

    if [ -n "$project_dir" ] && [ -d "$project_dir" ]
    then
        archive_file="${project_dir}_archive.zip"

        echo "Creating archive of the incomplete deployment..."

        (
            cd "$SCRIPT_DIR" || exit 1
            zip -r "$archive_file" "$(basename "$project_dir")" >/dev/null
        )

        echo "Incomplete project archived to:"
        echo "$archive_file"
    else
        echo "No project directory was created."
        echo "Nothing to archive."
    fi

    trap - INT TSTP
    exit 1
}
# Pre-flight checks

check_requirements() {
    echo
    echo "Checking required programs..."

    if ! command -v python3 >/dev/null 2>&1
    then
        echo "ERROR: python3 is not installed."
        return 1
    fi

    if ! command -v zip >/dev/null 2>&1
    then
        echo "ERROR: zip is not installed."
        return 1
    fi

    echo "python3: OK"
    echo "zip: OK"

    return 0
}
#  template files

check_templates() {
    echo
    echo "Checking template files..."

    if [ ! -f "$TEMPLATES_DIR/attendance_checker.py" ]
    then
        echo "ERROR: templates/attendance_checker.py not found."
        return 1
    fi

    if [ ! -f "$TEMPLATES_DIR/assets.csv" ]
    then
        echo "ERROR: templates/assets.csv not found."
        return 1
    fi

    if [ ! -f "$TEMPLATES_DIR/config.json" ]
    then
        echo "ERROR: templates/config.json not found."
        return 1
    fi

    echo "attendance_checker.py: OK"
    echo "assets.csv: OK"
    echo "config.json: OK"

    return 0
}
#  attendance alert thresholds

update_thresholds() {

    config_file="$project_dir/Helpers/config.json"

    echo
    read -p "Do you want to update the attendance alert thresholds? (y/n): " update

    if [ "$update" = "y" ] || [ "$update" = "Y" ]
    then
        read -p "Enter warning threshold [75]: " warning
        read -p "Enter failure threshold [50]: " failure

       
        if [ -z "$warning" ]
        then
            warning=75
        fi

        if [ -z "$failure" ]
        then
            failure=50
        fi

        
        if ! [[ "$warning" =~ ^[0-9]+$ ]]
        then
            echo "ERROR: Warning threshold must be a number."
            return 1
        fi

        if ! [[ "$failure" =~ ^[0-9]+$ ]]
        then
            echo "ERROR: Failure threshold must be a number."
            return 1
        fi

        
        sed -i "s/\"warning\": [0-9]*/\"warning\": $warning/" "$config_file"
        sed -i "s/\"failure\": [0-9]*/\"failure\": $failure/" "$config_file"

        echo
        echo "Thresholds updated successfully."
        echo "Warning threshold: $warning"
        echo "Failure threshold: $failure"
    else
        echo "Keeping the default thresholds."
    fi
}
# Deploy application

deploy_application() {

    echo
    echo "       DEPLOY APPLICATION"
    

    
    check_requirements || return 1

   
    check_templates || return 1

   
    read -p "Enter a project name: " project_name

    if [ -z "$project_name" ]
    then
        echo "ERROR: Project name cannot be empty."
        return 1
    fi

    project_dir="$SCRIPT_DIR/attendance_tracker_${project_name}"

    echo
    echo "Project directory:"
    echo "$project_dir"

trap 'deployment_interrupted "SIGINT"' INT
trap 'deployment_interrupted "SIGTSTP"' TSTP
    # Handle existing project
    # ------------------------------------------------------

    if [ -d "$project_dir" ]
    then
        echo
        echo "WARNING: $project_dir already exists."

        read -p "Do you want to overwrite it? (y/n): " overwrite

        if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]
        then
            echo "Deployment cancelled."
            return 1
        fi

        rm -rf "$project_dir"

        echo "Existing project removed."
    fi
    #  directory structure
    # ------------------------------------------------------

    echo
    echo "Creating project structure..."

    mkdir -p "$project_dir/Helpers"
    mkdir -p "$project_dir/reports"
    mkdir -p "$project_dir/archives/attendance"
    mkdir -p "$project_dir/archives/absent"

    echo "Directories created."

    # Copy application files

    echo
    echo "Copying application files..."

cp "$TEMPLATES_DIR/attendance_checker.py" "$project_dir/Helpers/attendance_checker.py"

    if [ $? -ne 0 ]
    then
        echo "ERROR: Failed to copy attendance_checker.py."
        return 1
    fi

    cp "$TEMPLATES_DIR/config.json" \
       "$project_dir/Helpers/config.json"

    if [ $? -ne 0 ]
    then
        echo "ERROR: Failed to copy config.json."
        return 1
    fi

    echo "attendance_checker.py copied."
    echo "config.json copied."
#  the student roster

echo
echo "How would you like to build the student roster?"
echo
echo "1. Copy students from the template"
echo "2. Generate a fresh roster"
echo

read -p "Choose an option (1 or 2): " roster_option

case "$roster_option" in

    1)
        echo
        read -p "How many students would you like to copy? " student_count

        if ! [[ "$student_count" =~ ^[0-9]+$ ]]
        then
            echo "ERROR: Please enter a valid number."
            return 1
        fi

        if [ "$student_count" -lt 1 ]
        then
            echo "ERROR: Number of students must be at least 1."
            return 1
        fi

        
        available_students=$(tail -n +2 "$TEMPLATES_DIR/assets.csv" | wc -l)

        if [ "$student_count" -gt "$available_students" ]
        then
            echo "ERROR: The template only contains $available_students students."
            return 1
        fi

        
        head -n $((student_count + 1)) \
            "$TEMPLATES_DIR/assets.csv" \
            > "$project_dir/Helpers/assets.csv"

       
        sed -i 's/"total_sessions": [0-9]*/"total_sessions": 5/' \
            "$project_dir/Helpers/config.json"

        echo
        echo "$student_count students copied from the template."
        echo "total_sessions set to 5."

        ;;

    2)
        echo
        read -p "How many students would you like to generate? " student_count

        if ! [[ "$student_count" =~ ^[0-9]+$ ]]
        then
            echo "ERROR: Please enter a valid number."
            return 1
        fi

        if [ "$student_count" -lt 1 ]
        then
            echo "ERROR: Number of students must be at least 1."
            return 1
        fi

       
        names=(
    "Alice Johnson"
    "Bob Smith"
    "Charlie Davis"
    "Diana Prince"
    "Ethan Cole"
    "Fatima Noor"
    "George Mensah"
    "Hannah Kim"
    "Ibrahim Osei"
    "Jasmine Lee"
)

emails=(
    "alice@example.com"
    "bob@example.com"
    "charlie@example.com"
    "diana@example.com"
    "ethan@example.com"
    "fatima@example.com"
    "george@example.com"
    "hannah@example.com"
    "ibrahim@example.com"
    "jasmine@example.com"
)

        if [ "$student_count" -gt "${#names[@]}" ]
        then
            echo "ERROR: You can generate a maximum of ${#names[@]} students."
            return 1
        fi

        
        echo "Email,Names,Attendance Count,Absence Count" \
            > "$project_dir/Helpers/assets.csv"

        
        for ((i=0; i<student_count; i++))
        do
            echo "${emails[$i]},${names[$i]},0,0" \
                >> "$project_dir/Helpers/assets.csv"
        done

        
        sed -i 's/"total_sessions": [0-9]*/"total_sessions": 1/' \
            "$project_dir/Helpers/config.json"

        echo
        echo "$student_count fresh students generated."
        echo "Attendance Count: 0"
        echo "Absence Count: 0"
        echo "total_sessions set to 1."

        ;;

    *)
        echo "ERROR: Invalid roster option."
        return 1
        ;;

esac
    #  permissions

    echo
    echo "Setting permissions..."

    chmod +x "$project_dir/Helpers/attendance_checker.py"
    chmod 600 "$project_dir/Helpers/config.json"

    echo "attendance_checker.py: executable"
    echo "Helpers/config.json: owner read/write only"
update_thresholds
    #  deployed structure

    echo
    echo "Deployment structure:"
    find "$project_dir" -maxdepth 3 -print

    echo
    echo "Deployment completed successfully."


trap - INT TSTP

echo
echo "Starting Student Attendance Tracker..."
echo

(
    cd "$project_dir" || exit 1
    python3 Helpers/attendance_checker.py
)

status=$?

echo
echo "Attendance Tracker finished."

return "$status"
}

# Run application

run_application() {

    read -p "Enter the deployed project name: " project_name

    if [ -z "$project_name" ]
    then
        echo "ERROR: Project name cannot be empty."
        return 1
    fi

    project_dir="$SCRIPT_DIR/attendance_tracker_${project_name}"

    if [ ! -d "$project_dir" ]
    then
        echo "ERROR: Project does not exist:"
        echo "$project_dir"
        return 1
    fi

    if [ ! -f "$project_dir/Helpers/attendance_checker.py" ]
    then
        echo "ERROR: attendance_checker.py was not found."
        return 1
    fi

    echo
    echo "Starting Student Attendance Tracker..."
    echo

    cd "$project_dir" || return 1

    python3 Helpers/attendance_checker.py
}
# Archive logs

archive_logs() {

    read -p "Enter the deployed project name: " project_name

    if [ -z "$project_name" ]
    then
        echo "ERROR: Project name cannot be empty."
        return 1
    fi

    project_dir="$SCRIPT_DIR/attendance_tracker_${project_name}"

    if [ ! -d "$project_dir" ]
    then
        echo "ERROR: Project does not exist."
        return 1
    fi

    timestamp=$(date +"%Y%m%d_%H%M%S")

    mkdir -p "$project_dir/archives/attendance"
    mkdir -p "$project_dir/archives/absent"

    # Archive attendance log
    if [ -f "$project_dir/reports/attendance.log" ]
    then
        attendance_archive="$project_dir/archives/attendance/attendance_${timestamp}.log"

        cp "$project_dir/reports/attendance.log" \
           "$attendance_archive"

        echo "Attendance log archived:"
        echo "$attendance_archive"
    else
        echo "No attendance.log found. Nothing to archive."
    fi

    # Archive absent log
    if [ -f "$project_dir/reports/absent.log" ]
    then
        absent_archive="$project_dir/archives/absent/absent_${timestamp}.log"

        cp "$project_dir/reports/absent.log" \
           "$absent_archive"

        echo "Absent log archived:"
        echo "$absent_archive"
    else
        echo "No absent.log found. Nothing to archive."
    fi
}
# Main menu

while true
do
    echo
    echo "   STUDENT ATTENDANCE TRACKER AGENT"
    echo
    echo "1. Deploy application"
    echo "2. Run application"
    echo "3. Archive logs"
    echo "4. Exit"
    echo

    read -p "Choose an option: " choice

    case "$choice" in

        1)
            deploy_application
            ;;

        2)
            run_application
            ;;

        3)
            archive_logs
            ;;

        4)
            echo "Goodbye!"
            exit 0
            ;;

        *)
            echo "ERROR: Invalid option."
            ;;

    esac
done
