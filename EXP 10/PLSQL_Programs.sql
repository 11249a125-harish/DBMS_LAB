-- Experiment 10: PL/SQL Programming
--
-- AIM:
-- To practice PL/SQL control flow, exception handling,
-- procedures, functions, triggers, and cursors.

SET SERVEROUTPUT ON;

-- Step 1: Remove existing tables to allow rerunning the script

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE emp_audit CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE emp CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE dept CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- Step 2: Create department table

CREATE TABLE dept (
    deptno NUMBER(2) PRIMARY KEY,
    dname  VARCHAR2(20)
);

-- Step 3: Create employee table

CREATE TABLE emp (
    empno  NUMBER(4) PRIMARY KEY,
    ename  VARCHAR2(20) NOT NULL,
    job    VARCHAR2(15),
    sal    NUMBER(8,2),
    deptno NUMBER(2) REFERENCES dept(deptno)
);

-- Step 4: Create employee audit table

CREATE TABLE emp_audit (
    audit_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    empno    NUMBER,
    action   VARCHAR2(10),
    old_sal  NUMBER,
    new_sal  NUMBER,
    changed_on DATE DEFAULT SYSDATE
);

-- Step 5: Insert department data

INSERT INTO dept VALUES (10, 'ACCOUNTING');
INSERT INTO dept VALUES (20, 'RESEARCH');
INSERT INTO dept VALUES (30, 'SALES');

-- Step 6: Insert employee data

INSERT INTO emp VALUES (101, 'SMITH', 'CLERK', 8000, 20);
INSERT INTO emp VALUES (102, 'ALLEN', 'SALESMAN', 15000, 30);
INSERT INTO emp VALUES (103, 'WARD', 'SALESMAN', 12500, 30);
INSERT INTO emp VALUES (104, 'JONES', 'MANAGER', 29750, 20);
INSERT INTO emp VALUES (105, 'KING', 'PRESIDENT', 50000, 10);

COMMIT;

-- Step 7: IF-ELSIF-ELSE statement

DECLARE
    v_sal  emp.sal%TYPE;
    v_name emp.ename%TYPE;
BEGIN
    SELECT ename, sal
    INTO v_name, v_sal
    FROM emp
    WHERE empno = 102;

    IF v_sal >= 30000 THEN
        DBMS_OUTPUT.PUT_LINE(v_name || ': Grade A');
    ELSIF v_sal >= 10000 THEN
        DBMS_OUTPUT.PUT_LINE(v_name || ': Grade B');
    ELSE
        DBMS_OUTPUT.PUT_LINE(v_name || ': Grade C');
    END IF;
END;
/

-- Step 8: CASE statement

DECLARE
    v_job   emp.job%TYPE;
    v_sal   emp.sal%TYPE;
    v_bonus NUMBER;
BEGIN
    SELECT job, sal
    INTO v_job, v_sal
    FROM emp
    WHERE empno = 103;

    v_bonus := CASE v_job
        WHEN 'SALESMAN' THEN v_sal * 0.10
        WHEN 'MANAGER'  THEN v_sal * 0.15
        ELSE v_sal * 0.05
    END;

    DBMS_OUTPUT.PUT_LINE('Bonus: ' || v_bonus);
END;
/

-- Step 9: Predefined exception handling

DECLARE
    v_name emp.ename%TYPE;
BEGIN
    SELECT ename
    INTO v_name
    FROM emp
    WHERE empno = 999;

    DBMS_OUTPUT.PUT_LINE(v_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No employee with that number.');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('More than one row returned.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Step 10: User-defined exception

DECLARE
    e_low_salary EXCEPTION;
    v_sal emp.sal%TYPE;
BEGIN
    SELECT sal
    INTO v_sal
    FROM emp
    WHERE empno = 101;

    IF v_sal < 10000 THEN
        RAISE e_low_salary;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Salary is acceptable.');
EXCEPTION
    WHEN e_low_salary THEN
        DBMS_OUTPUT.PUT_LINE('Salary below minimum: ' || v_sal);
END;
/

-- Step 11: Duplicate employee exception

BEGIN
    INSERT INTO emp
    VALUES (101, 'DUP', 'CLERK', 5000, 10);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Employee number already exists.');
END;
/

-- Step 12: Create procedure to raise salary

CREATE OR REPLACE PROCEDURE raise_salary (
    p_empno   IN emp.empno%TYPE,
    p_percent IN NUMBER
) IS
BEGIN
    UPDATE emp
    SET sal = sal + sal * p_percent / 100
    WHERE empno = p_empno;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Employee not found');
    END IF;
END;
/

-- Step 13: Execute salary procedure

EXEC raise_salary(101, 10);

SELECT empno, ename, sal FROM emp WHERE empno = 101;

-- Step 14: Procedure with OUT parameters

CREATE OR REPLACE PROCEDURE get_emp_info (
    p_empno IN emp.empno%TYPE,
    p_name  OUT emp.ename%TYPE,
    p_sal   OUT emp.sal%TYPE
) IS
BEGIN
    SELECT ename, sal
    INTO p_name, p_sal
    FROM emp
    WHERE empno = p_empno;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_name := NULL;
        p_sal := NULL;
END;
/

-- Step 15: Call OUT parameter procedure

DECLARE
    v_name emp.ename%TYPE;
    v_sal  emp.sal%TYPE;
BEGIN
    get_emp_info(104, v_name, v_sal);
    DBMS_OUTPUT.PUT_LINE(v_name || ' earns ' || v_sal);
END;
/

-- Step 16: Procedure with IN OUT parameter

CREATE OR REPLACE PROCEDURE square_it (
    p_num IN OUT NUMBER
) IS
BEGIN
    p_num := p_num * p_num;
END;
/

-- Step 17: Execute IN OUT procedure

DECLARE
    n NUMBER := 7;
BEGIN
    square_it(n);
    DBMS_OUTPUT.PUT_LINE('Result: ' || n);
END;
/

-- Step 18: Create function to calculate annual salary

CREATE OR REPLACE FUNCTION annual_sal (
    p_empno IN emp.empno%TYPE
) RETURN NUMBER IS
    v_sal emp.sal%TYPE;
BEGIN
    SELECT sal
    INTO v_sal
    FROM emp
    WHERE empno = p_empno;

    RETURN v_sal * 12;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

-- Step 19: Call function

BEGIN
    DBMS_OUTPUT.PUT_LINE('Annual salary: ' || annual_sal(102));
END;
/

-- Step 20: Use function in SELECT

SELECT ename, annual_sal(empno) AS yearly_salary
FROM emp;

-- Step 21: Trigger to check salary and uppercase employee name

CREATE OR REPLACE TRIGGER trg_check_sal
BEFORE INSERT OR UPDATE OF sal, ename ON emp
FOR EACH ROW
BEGIN
    IF :NEW.sal < 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Salary cannot be negative');
    END IF;

    :NEW.ename := UPPER(:NEW.ename);
END;
/

-- Step 22: Test negative salary safely

BEGIN
    UPDATE emp
    SET sal = -100
    WHERE empno = 101;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Update rejected: ' || SQLERRM);
END;
/

-- Step 23: Trigger to audit INSERT, UPDATE, and DELETE

CREATE OR REPLACE TRIGGER trg_emp_audit
AFTER INSERT OR UPDATE OR DELETE ON emp
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO emp_audit (empno, action, new_sal)
        VALUES (:NEW.empno, 'INSERT', :NEW.sal);

    ELSIF UPDATING THEN
        INSERT INTO emp_audit (empno, action, old_sal, new_sal)
        VALUES (:OLD.empno, 'UPDATE', :OLD.sal, :NEW.sal);

    ELSIF DELETING THEN
        INSERT INTO emp_audit (empno, action, old_sal)
        VALUES (:OLD.empno, 'DELETE', :OLD.sal);
    END IF;
END;
/

-- Step 24: Update employee salary

UPDATE emp
SET sal = 9000
WHERE empno = 101;

-- Step 25: Delete an employee

DELETE FROM emp
WHERE empno = 103;

-- Step 26: Display audit records and save the changes

SELECT * FROM emp_audit;

COMMIT;

-- Step 27: Trigger to prevent weekend changes

CREATE OR REPLACE TRIGGER trg_no_weekend
BEFORE INSERT OR UPDATE OR DELETE ON emp
BEGIN
    IF TO_CHAR(SYSDATE, 'DY',
               'NLS_DATE_LANGUAGE=ENGLISH') IN ('SAT', 'SUN') THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'Changes not allowed on weekends'
        );
    END IF;
END;
/

-- Step 28: Disable weekend trigger for the remaining examples

ALTER TRIGGER trg_no_weekend DISABLE;

-- Step 29: Update rows and display affected row count

BEGIN
    UPDATE emp
    SET sal = sal + 500
    WHERE deptno = 30;

    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' row(s) updated');

    ROLLBACK;
END;
/

-- Step 30: Explicit cursor

DECLARE
    CURSOR c_emp IS
        SELECT ename, sal
        FROM emp
        ORDER BY sal DESC;

    v_name emp.ename%TYPE;
    v_sal  emp.sal%TYPE;
BEGIN
    OPEN c_emp;

    LOOP
        FETCH c_emp INTO v_name, v_sal;
        EXIT WHEN c_emp%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(RPAD(v_name, 10) || v_sal);
    END LOOP;

    CLOSE c_emp;
END;
/

-- RESULT:
-- The PL/SQL program demonstrates control statements,
-- exception handling, procedures, functions, triggers,
-- transactions, and explicit cursors.