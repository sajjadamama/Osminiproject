#!/bin/bash

data_file="students.txt"

touch "$data_file"  # Ensure file exists

# Function to add a student
add_student() {
    if [ $(wc -l < "$data_file") -ge 20 ]; then
        echo "Cannot add more students. Limit reached."
        return
    fi
    read -p "Enter Roll No: " roll
    read -p "Enter Name: " name
    read -p "Enter Marks: " marks
    gpa=$(calculate_gpa "$marks")
    echo "$roll|$name|$marks|$gpa" >> "$data_file"
    echo "Student added successfully."
}

# Function to view student details
view_students() {
    echo "Roll No | Name | Marks | GPA"
    echo "--------------------------------"
    cat "$data_file" | awk -F'|' '{print $1, "|", $2, "|", $3, "|", $4}'
}

# Function to update student marks
update_student() {
    read -p "Enter Roll No to update: " roll
    if grep -q "^$roll|" "$data_file"; then
        read -p "Enter new marks: " new_marks
        new_gpa=$(calculate_gpa "$new_marks")
        sed -i "/^$roll|/s/|[^|]*|[^|]*\$/|$new_marks|$new_gpa/" "$data_file"
        echo "Marks updated successfully."
    else
        echo "Student not found."
    fi
}

# Function to delete a student
delete_student() {
    read -p "Enter Roll No to delete: " roll
    if grep -q "^$roll|" "$data_file"; then
        sed -i "/^$roll|/d" "$data_file"
        echo "Student deleted successfully."
    else
        echo "Student not found."
    fi
}

# Function to calculate GPA
calculate_gpa() {
    marks=$1
    if [ "$marks" -ge 85 ]; then
        echo "4.0"
    elif [ "$marks" -ge 75 ]; then
        echo "3.5"
    elif [ "$marks" -ge 65 ]; then
        echo "3.0"
    elif [ "$marks" -ge 50 ]; then
        echo "2.5"
    else
        echo "0.0"
    fi
}

# Function to calculate grades
calculate_grades() {
    awk -F'|' '{
        grade="F"
        gpa="0.0"
        if ($3 >= 85) { grade="A"; gpa="4.0" }
        else if ($3 >= 75) { grade="B"; gpa="3.5" }
        else if ($3 >= 65) { grade="C"; gpa="3.0" }
        else if ($3 >= 50) { grade="D"; gpa="2.5" }
        print $1 "|" $2 "|" $3 "|" gpa "|" grade
    }' "$data_file" > grades.txt
    echo "Grades and GPA calculated. View in grades.txt"
}

# Function for student to view their own grade and GPA
view_student_grade() {
    read -p "Enter your Roll No: " roll
    if grep -q "^$roll|" "$data_file"; then
        grep "^$roll|" "$data_file" | awk -F'|' '{
            grade="F"
            gpa="0.0"
            if ($3 >= 85) { grade="A"; gpa="4.0" }
            else if ($3 >= 75) { grade="B"; gpa="3.5" }
            else if ($3 >= 65) { grade="C"; gpa="3.0" }
            else if ($3 >= 50) { grade="D"; gpa="2.5" }
            print "Your Marks: "$3" | GPA: "$4" | Grade: "grade
        }'
    else
        echo "Student not found."
    fi
}

# Function to display passing and failing students
display_pass_fail_students() {
    echo "Passing Students (Marks >= 50):"
    awk -F'|' '$3 >= 50 {print $1, "|", $2, "|", $3, "|", $4}' "$data_file"
    echo "Failing Students (Marks < 50):"
    awk -F'|' '$3 < 50 {print $1, "|", $2, "|", $3, "|", $4}' "$data_file"
}

# Function for teacher menu
display_teacher_menu() {
    echo "1. Add Student"
    echo "2. View Students"
    echo "3. Update Student Marks"
    echo "4. Delete Student"
    echo "5. Calculate Grades and GPA"
    echo "6. View Passing & Failing Students"
    echo "7. Exit"
}

# Function for student menu
display_student_menu() {
    echo "1. View Your Grade and GPA"
    echo "2. Exit"
}

# Main role selection
read -p "Are you a Teacher or a Student? (T/S): " role
if [[ "$role" == "T" || "$role" == "t" ]]; then
    while true; do
        display_teacher_menu
        read -p "Enter choice: " choice
        case $choice in
            1) add_student ;;
            2) view_students ;;
            3) update_student ;;
            4) delete_student ;;
            5) calculate_grades ;;
            6) display_pass_fail_students ;;
            7) exit ;;
            *) echo "Invalid choice, try again." ;;
        esac
    done
elif [[ "$role" == "S" || "$role" == "s" ]]; then
    while true; do
        display_student_menu
        read -p "Enter choice: " choice
        case $choice in
            1) view_student_grade ;;
            2) exit ;;
            *) echo "Invalid choice, try again." ;;
        esac
    done
else
    echo "Invalid role selection. Exiting."
    exit 1
fi

