#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct student {
    int id;
    char name[50];
    char branch[10];
    int sem;
    char address[50];
};

void insertStudent() {
    FILE *file = fopen("student.dat", "ab");
    if (file == NULL) {
        printf("Error opening file!\n");
        return;
    }
    struct student std;
    printf("Enter student ID: ");
    scanf("%d", &std.id);
    printf("Enter student name: ");
    scanf("%s", std.name);
    printf("Enter branch: ");
    scanf("%s", std.branch);
    printf("Enter semester: ");
    scanf("%d", &std.sem);
    printf("Enter address: ");
    scanf("%s", std.address);

    fwrite(&std, sizeof(struct student), 1, file);
    fclose(file);
    printf("Student record inserted successfully\n");
}

void modifyAddress(int sid) {
    FILE *file = fopen("student.dat", "rb+");
    if (file == NULL) {
        printf("Error opening file!\n");
        return;
    }
    struct student std;
    int found = 0;
    while (fread(&std, sizeof(struct student), 1, file)) {
        if (std.id == sid) {
            found = 1;
            printf("Enter new Address\n");
            scanf("%s", std.address);
            fseek(file, -sizeof(struct student), SEEK_CUR);
            fwrite(&std, sizeof(struct student), 1, file);
            printf("Address record updated successfully\n");
            break;
        }
    }

    if (!found) {
        printf("Student record not found\n");
    }
    fclose(file);
}

void deleteStudent(int id) {
    FILE *file = fopen("student.dat", "rb");
    FILE *temp = fopen("temp.dat", "wb");
    if (file == NULL || temp == NULL) {
        printf("Error opening file!\n");
        return;
    }
    struct student std;
    int found = 0;
    while (fread(&std, sizeof(struct student), 1, file)) {
        if (std.id != id) {
            fwrite(&std, sizeof(struct student), 1, temp);
        } else {
            found = 1;
        }
    }
    fclose(file);
    fclose(temp);
    remove("student.dat");
    rename("temp.dat", "student.dat");
    if (found) {
        printf("Student record deleted successfully\n");
    } else {
        printf("Student record not found\n");
    }
}

void listAllStudents() {
    FILE *file = fopen("student.dat", "rb");
    if (file == NULL) {
        printf("Error opening file!\n");
        return;
    }
    struct student std;
    printf("List of all students\n");
    while (fread(&std, sizeof(struct student), 1, file)) {
        printf("\nStudent ID: %d\nStudent Name: %s\nBranch: %s\n Semester: %d\n Address: %s\n\n", std.id, std.name, std.branch, std.sem, std.address);
    }
    fclose(file);
}

void listStudentByBranch(char *branch) {
    FILE *file = fopen("student.dat", "rb");
    if (file == NULL) {
        printf("Error opening file!\n");
        return;
    }

    struct student std;
    printf("List of students in branch: %s\n", branch);
    int found = 0;

    while (fread(&std, sizeof(struct student), 1, file)) {
        if (strcmp(std.branch, branch) == 0) {
            printf("\nStudent ID: %d\nStudent Name: %s\nBranch: %s\nSemester: %d\nAddress: %s\n\n",
                   std.id, std.name, std.branch, std.sem, std.address);
            found = 1;
        }
    }

    if (!found) {
        printf("No students found in branch: %s\n", branch);
    }
    fclose(file);
}

void listStudentsByBranchAndAddress(char *branch, char *address) {
    FILE *file = fopen("student.dat", "rb");
    if (file == NULL) {
        printf("Error opening file!\n");
        return;
    }

    struct student std;
    printf("List of students in branch %s and address %s:\n", branch, address);
    int found = 0;

    while (fread(&std, sizeof(struct student), 1, file)) {
        if (strcmp(std.branch, branch) == 0 && strcmp(std.address, address) == 0) {
            printf("\nStudent ID: %d\nStudent Name: %s\nBranch: %s\nSemester: %d\nAddress: %s\n\n",
                   std.id, std.name, std.branch, std.sem, std.address);
            found = 1;
        }
    }

    if (!found) {
        printf("No students found in branch %s with address %s\n", branch, address);
    }
    fclose(file);
}

int main() {

    int choice, id;
    char branch[10], address[100];

    while (1) {
        printf("\nMenu:\n");
        printf("1. Insert Student\n");
        printf("2. Modify Address\n");
        printf("3. Delete Student\n");
        printf("4. List All Students\n");
        printf("5. List Students by Branch\n");
        printf("6. List Students by Branch and Address\n");
        printf("7. Exit\n");
        printf("Enter your choice: ");
        scanf("%d", &choice);
        switch (choice) {
            case 1:
                insertStudent();
                break;
            case 2:
                printf("Enter student ID to modify address: ");
                scanf("%d", &id);
                modifyAddress(id);
                break;
            case 3:
                printf("Enter student ID to delete: ");
                scanf("%d", &id);
                deleteStudent(id);
                break;
            case 4:
                listAllStudents();
                break;
            case 5:
                printf("Enter branch: ");
                scanf("%s", branch);
                listStudentByBranch(branch);
                break;
            case 6:
                printf("Enter branch: ");
                scanf("%s", branch);
                printf("Enter address: ");
                scanf("%s", address);
                listStudentsByBranchAndAddress(branch, address);
                break;
            case 7:
                exit(0);
            default:
                printf("Invalid choice! Please try again.\n");
        }
    }
    return 0;
}
