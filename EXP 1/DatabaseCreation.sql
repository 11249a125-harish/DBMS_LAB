-- Experiment 1: Database Creation and Information Retrieval
--
-- AIM:
-- To build a student database and retrieve its records
-- through filtering, sorting, and aggregate queries.

-- Program

-- Step 1: Create Database
CREATE DATABASE IF NOT EXISTS LAB_EXPERIMENT_1;

-- Step 2: Select Database
USE LAB_EXPERIMENT_1;

-- Step 3: Create Student Table
CREATE TABLE IF NOT EXISTS Student (
    StudentID INT PRIMARY KEY,
    StudentName VARCHAR(30),
    Department VARCHAR(20),
    Age INT,
    CGPA DECIMAL(3,2)
);

-- Step 4: Insert Student Records
INSERT INTO Student VALUES
(101, 'Anu', 'CSE', 20, 8.90),
(102, 'Bala', 'ECE', 21, 8.50),
(103, 'Charles', 'IT', 20, 9.10),
(104, 'Divya', 'CSE', 22, 8.70),
(105, 'Esha', 'AIDS', 21, 9.20);

-- Step 5: Display All Students
SELECT * FROM Student;

-- Step 6: Display CSE Students
SELECT * FROM Student
WHERE Department = 'CSE';

-- Step 7: Display Students with CGPA Above 8.8
SELECT * FROM Student
WHERE CGPA > 8.8;

-- Step 8: Sort Students by CGPA in Descending Order
SELECT * FROM Student
ORDER BY CGPA DESC;

-- Step 9: Count Total Students
SELECT COUNT(*) AS TotalStudents
FROM Student;

-- Step 10: Calculate Average CGPA
SELECT AVG(CGPA) AS AverageCGPA
FROM Student;

-- RESULT:
-- The database and student table are created, records are inserted,
-- and filtering, sorting, counting, and averaging are performed.