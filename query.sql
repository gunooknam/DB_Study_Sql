-- Query 0 Retrieve the birth date and address of the employee(s) whose name is 'john B.smith'.
SELECT Bdate, Address
FROM   employee
WHERE  Fname='john' AND Minit='B' AND Lname='Smith';


-- Query 1 Retrieve the name and address of all employees who work for the 'Research' department.
SELECT  Fname, Lname, Address
FROM 	EMPLOYEE, DEPARTMENT
WHERE 	Dname='Research' AND Dnumber=Dno;

-- Query 2 For every project located in 'Stafford', list the project number, the controlling department number, 
-- and the department manager's last name, address, and birth date.
SELECT  Pnumber, Dnum, Lname, Address, Bdate
FROM 	PROJECT AS P, DEPARTMENT AS D, employee AS E
WHERE   P.Dnum=D.Dnumber AND D.Mgr_ssn=E.Ssn AND P.Plocation='Stafford';

-- Query 1A : Ambigous Attribute Name
SELECT  Fname, EMPLOYEE.Lname, Address
FROM 	EMPLOYEE, DEPARTMENT
WHERE 	DEPARTMENT.name = 'Research' AND
		DEPARTMENT.Dnumber = EMPLOYEE.Dnumber;
        
-- Query 8. For each employee. retrieve the employee's first and last name
-- and the first and last name of his or her immediate supervisor.
SELECT E.Fname, E.Lname, S.Fname, S.Lname
FROM   EMPLOYEE AS E, EMPLOYEE AS S
WHERE  E.Super_ssn = S.Ssn;


-- Query 9 and 10 Select all EMPLOYEE Ssns (Q9) and all combinations of EMPLOYEE Ssn and DEPARTMENT
-- Dname (Q10) in the database.
SELECT  Ssn
FROM	EMPLOYEE;

SELECT  Ssn,Dname
FROM	EMPLOYEE, DEPARTMENT;

-- Query 1C, 1D, 10A
SELECT  *
FROM	EMPLOYEE
WHERE	Dno=5;

SELECT  *
FROM	EMPLOYEE,DEPARTMENT
WHERE	Dname='Research' AND Dno=Dnumber;

SELECT  *
FROM EMPLOYEE, DEPARTMENT;

-- Query 11. Retrieve the salary of every employee (Q11) and all distinct salary values(Q11A)ALTER
SELECT ALL  Salary
FROM	   	EMPLOYEE;

SELECT DISTINCT Salary
FROM			EMPLOYEE;

-- Query 4. Make a list of all project numbers for projects that involve an employee whose last name is 'Smith', either as a worker or as 
-- a manager of the department that controls the project.
( 
SELECT DISTINCT Pnumber
FROM PROJECT, DEPARTMENT, EMPLOYEE
WHERE Dnum=Dnumber AND Mgr_ssn=Ssn
AND Lname='Smith' 
)
UNION  -- 중복을 제거한다. DISTINCT 필요 없다.
( 
SELECT DISTINCT Pnumber
FROM PROJECT, WORKS_ON, EMPLOYEE
WHERE Pnumber=Pno AND Essn=Ssn
AND Lname='Smith'
);

-- LIKE 
SELECT Ssn, Fname, Lname
FROM EMPLOYEE
WHERE Address LIKE '%Houston TX%';

SELECT Ssn, Fname, Lname
FROM EMPLOYEE
WHERE Ssn LIKE '__8__5555'; -- 언더바를 붙인 부분은 제외하고 일치하는 것을 찾는다. 

-- BETWEEN AND
SELECT *
FROM EMPLOYEE
WHERE (Salary BETWEEN 30000 AND 40000) AND Dno = 5;

-- ORDER BY
SELECT DISTINCT Salary
FROM			EMPLOYEE
ORDER BY Salary DESC;

SELECT DISTINCT Salary
FROM			EMPLOYEE
ORDER BY Salary ASC;
-- ascending가 디폴트이다. 뒤에 ASC 안붙여도 된다. 

-- Standard arithmetic operation *, -, +, /
-- Query 13 Show the resulting salaries if every employee working on the 'ProductX' project is given a 10 percent raise.

SELECT  E.Fname, E.Lname, 1.1*E.Salary AS Increased_sal
FROM	EMPLOYEE AS E, WORKS_ON AS W, PROJECT AS P
WHERE E.Ssn=W.Essn AND W.Pno=P.Pnumber AND P.Pname='ProductX';

-- 이런식으로도 넣을 수 있다. select 받아온 것에다가 넣음
INSERT INTO WORKS_ON_INFO(Emp_name, Proj_name, Hours_per_week)
SELECT E.Lname, P.Pname, W.Hours
FROM 	PROJECT P, WORKS_ON W, EMPLOYEE E
WHERE P.Pnumber=W.Pno AND W.Essn=E.Ssn;

-- Example : Give all employees in the Research department a 10% raise in salary.
UPDATE	employee
SET	 	SALARY = SALARY*1.1
WHERE	DNO IN (SELECT DNUMBER
				FROM   DEPARTMENT
				WHERE  DNAME='Research');
-- select문으로 찾은 dno에 대해서 1.1배를 해준다.  => IN을 써주었다. 


-- Query 18 Retrieve the names of all employees who do not have supervisors
SELECT  Fname, Lname
FROM 	employee
WHERE	super_ssn IS NULL;

-- Nested Queries 
-- Query4A  Make a list of all project numbers for projects that involve an employee whose last name is 'Smith', 
-- either as a worker or as a manager of the department that controls the project

SELECT DISTINCT Pnumber
FROM	PROJECT 
WHERE	Pnumber IN
	    ( SELECT  Pnumber 
          FROM    PROJECT, DEPARTMENT, EMPLOYEE 
          WHERE   Dnum=Dnumber AND Mgr_ssn=Ssn AND Lname ='Smith')
		OR 
        Pnumber IN
	    ( SELECT  Pno
          FROM 	  WORKS_ON, EMPLOYEE 
          WHERE   Essn=Ssn AND Lname ='Smith');



-- Query same combination
SELECT  Essn
FROM	WORKS_ON
WHERE	(pno, Hours) IN (SELECT Pno, Hours
						 FROM   WORKS_ON
						 WHERE  Essn='123456789'
					     );
                        
-- query Returns the name of employees whose salary is greater than the salary of all the employees in department 5
-- SELECT  Lname, Fname 
-- FROM	EMPLOYEE
-- WHERE	Salary  >   ALL (  SELECT  Salary
-- 					           FROM	EMPLOYEE
-- 				    	       WHERE   Dno=5 );  -- 되기는 되나 빨간줄뜸;

-- query Retrieve the name of each employee who has a dependent with the same first name and is the same sex as the employee
SELECT  E.Fname, E.Lname
FROM	employee AS E
WHERE	E.ssn IN ( SELECT Essn
				   FROM DEPENDENT AS D
					WHERE D.sex=E.sex 
                    AND   E.Fname=D.Dependent_name );

-- can be collaped into one single block 
SELECT  E.Fname, E.Lname
FROM    employee AS E, dependent AS D
WHERE	E.sex= D.sex and E.Fname=D.Dependent_name and E.ssn=D.Essn; -- E.ssn=D.Essn 네스트쿼리가 이것 때문에 붕괴된다.

SELECT E.ssn,E.Fname, E.Lname
FROM   employee E
WHERE NOT EXISTS( SELECT * 
				  FROM DEPENDENT D
				  WHERE E.ssn=D.Essn);
                  

SELECT * 
FROM DEPENDENT,employee
WHERE ssn=Essn;


-- QUery List the name of manager who have at least one department
SELECT Fname, Lname
FROM  EMPLOYEE
WHERE	EXISTS ( SELECT * 
			     FROM Department
				 WHERE Ssn=Mgr_ssn)
		AND
        EXISTS ( SELECT * 
				 FROM DEPENDENT
				 WHERE Ssn=Essn);
                 
                 
-- Query Q3A Retrieve the name of each employee who works on all the projects controlled by department number 5
SELECT  Fname, Lname
FROM	employee
WHERE	NOT EXISTS(  
					    SELECT Pnumber 
					    FROM  PROJECT
					    WHERE Dnum=5 AND Pnumber NOT IN 
                      ( SELECT DISTINCT pno 
						FROM  WORKS_ON
						WHERE ssn=Essn
					   )
					);
                    
                    
-- 위, 아래 똑같

SELECT Lname, Fname
FROM EMPLOYEE
WHERE NOT EXISTS ( SELECT *
FROM WORKS_ON B
WHERE ( B.Pno IN ( SELECT Pnumber
FROM PROJECT
WHERE Dnum=5 )
AND
NOT EXISTS ( SELECT *
FROM WORKS_ON C
WHERE C.Essn=Ssn
AND C.Pno=B.Pno )));

-- 명시적인 set의 형태를 밝힌다.
SELECT DISTINCT Essn
FROM WORKS_ON
WHERE Pno IN (1,2,3);

SELECT Fname, Lname, Address
FROM (EMPLOYEE JOIN DEPARTMENT ON Dno=Dnumber)
WHERE Dname = 'Research';


-- Rename attribute of one relation so it can be join with another using NATURAL JOIN 
SELECT Fname, Lname, Address
FROM  (
       EMPLOYEE NATURAL JOIN
	   DEPARTMENT ) -- 동일 칼럼을 내부적으로 찾기 때문에 알리아싱을 안줘도 된다. 
WHERE Dname='Research';


SELECT E.ssn, E.Lname AS Employee_Name,
	   S.Lname AS Supervisor_Name

FROM (EMPLOYEE AS E LEFT OUTER JOIN   -- FULL OUTER JOIN은 안되나 보다.
	  EMPLOYEE AS S ON E.super_ssn = S.ssn);


-- Q2A  stafford 찾는 것
SELECT Pnumber, Dnum, Lname, Address, Bdate
FROM ((PROJECT JOIN DEPARTMENT ON Dnum=Dnumber) JOIN EMPLOYEE ON Mgr_ssn =Ssn)
WHERE Plocation='Stafford';

-- built in aggregation function 이다. 
SELECT MAX(Salary), MIN(Salary), AVG(Salary), SUM(Salary)
FROM EMPLOYEE;



SELECT * 
FROM (EMPLOYEE JOIN DEPARTMENT ON Dno=Dnumber)
WHERE Dname='Research';

SELECT COUNT(*) 
FROM  EMPLOYEE, DEPARTMENT
WHERE DNO=Dnumber AND Dname='Research';

-- GROUPING EXAMPLE 
SELECT Dno, COUNT(*), AVG(Salary)
FROM EMPLOYEE
GROUP BY Dno;


SELECT Pnumber, Pname, COUNT(*)
FROM PROJECT, WORKS_ON
WHERE Pnumber = Pno
GROUP BY Pnumber, Pname;

SELECT Pnumber, Pname, COUNT(*)
FROM PROJECT, WORKS_ON
WHERE Pnumber=Pno
GROUP BY Pnumber, Pname
HAVING COUNT(*) > 2;


SELECT Dno, COUNT(*)
FROM EMPLOYEE
WHERE Salary>30000
GROUP BY Dno
HAVING COUNT(*) > 2;

set global sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
set session sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';

-- 아래 쿼리 뜰 때 이거 뜰 때 위에 두줄 설정하면 된다. Error Code: 1140. In aggregated query without GROUP BY, expression #1 of SELECT list 
-- contains nonaggregated column 'fds.EMPLOYEE.Dno'; this is incompatible with sql_mode=only_full_group_by	0.000 sec
-- Query 28. For each department that has more than five employees, retrieve
-- the department number and the number of its employees who are making
-- more than $40,000.

SELECT Dno, COUNT(*)
FROM EMPLOYEE
WHERE Salary >30000 AND Dno IN
(SELECT Dno FROM EMPLOYEE
GROUP BY Dno HAVING COUNT(*) > 2)
GROUP BY Dno;


/*
WITH BIGDEPTS(Dno) AS
(SELECT Dno
FROM EMPLOYEE
GROUP BY Dno
HAVING COUNT(*) > 5)
SELECT Dno, COUNT(*)
FROM EMPLOYEE
WHERE Salary>40000 AND Dno IN BIGDEPTS
GROUP BY Dno;
-- mysql은 안되는게 너무 많다. 저렇게 with 절은 mysql에서 지원하지 않는다. 
*/


UPDATE EMPLOYEE
SET Salary =
CASE WHEN Dno = 5 THEN Salary + 2000
WHEN Dno = 4 THEN Salary + 1500
WHEN Dno = 1 THEN Salary + 3000
END;



CREATE VIEW DEPT5EMP AS
SELECT *
FROM EMPLOYEE
WHERE Dno = 5;
-- 위에서 만든 뷰를 아래서 보여준다. 
SELECT *
FROM DEPT5EMP;

CREATE VIEW DEPT_INFO(Dept_name, No_of_emps, Total_sal)
AS SELECT Dname,Count(*), Sum(Salary)
FROM department, employee
GROUP BY Dname;

SELECT * FROM
DEPT_INFO;
