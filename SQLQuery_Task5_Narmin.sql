-- 1. Curators
CREATE TABLE Curators (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(MAX) NOT NULL,
    CONSTRAINT CK_Curators_name CHECK (name <> ''),
    surname NVARCHAR(MAX) NOT NULL,
    CONSTRAINT CK_Curators_surname CHECK (surname <> '')
);
INSERT INTO Curators (name, surname) VALUES
('Narmin', 'Murshudova'),
('Ayan', 'Aliyeva'),
('Banovsha', 'Rahimova'),
('Nigar', 'Khalilova');

---------------------------------------------------------------------
-- 2. Faculties
CREATE TABLE Faculties (
    id INT PRIMARY KEY IDENTITY(1,1),
    financing MONEY NOT NULL DEFAULT 0,
    CONSTRAINT CK_Faculties_financing CHECK (financing >= 0),
    name NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_Faculties_name UNIQUE(name),
    CONSTRAINT CK_Faculties_name CHECK (name <> '')
);

INSERT INTO Faculties (name, financing) VALUES
('Engineering', 500000),
('Natural Sciences', 350000),
('Humanities', 250000);
---------------------------------------------------------------------
-- 3. Departments
CREATE TABLE Departments (
    id INT PRIMARY KEY IDENTITY(1,1),
    building INT NOT NULL,
    CONSTRAINT CK_Departments_building CHECK (building BETWEEN 1 AND 5),
    financing MONEY NOT NULL DEFAULT 0,
    CONSTRAINT CK_Departments_financing CHECK (financing >= 0),
    name NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_Departments_name UNIQUE(name),
    CONSTRAINT CK_Departments_name CHECK (name <> ''),
    facultyId INT NOT NULL,
    CONSTRAINT FK_Departments_facultyId FOREIGN KEY (facultyId) REFERENCES Faculties(id)
);

INSERT INTO Departments (name, building, financing, facultyId) VALUES
('Computer Science', 1, 200000, 1),
('Mechanical Engineering', 2, 150000, 1),
('Physics', 3, 100000, 2),
('Philosophy', 4, 80000, 3);
---------------------------------------------------------------------
-- 4. Groups
CREATE TABLE Groups (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(10) NOT NULL,
    CONSTRAINT UQ_Groups_name UNIQUE(name),
    CONSTRAINT CK_Groups_name CHECK (name <> ''),
    groupYear INT NOT NULL,
    CONSTRAINT CK_Groups_groupYear CHECK (groupYear BETWEEN 1 AND 5),
    departmentId INT NOT NULL,
    CONSTRAINT FK_Groups_departmentId FOREIGN KEY (departmentId) REFERENCES Departments(id)
);
INSERT INTO Groups (name, groupYear, departmentId) VALUES
('FSDE_24A', 1, 2), 
('FSDE_24B', 2, 4), 
('FSDE_44', 3, 3),  
('FSDE_34', 3, 4);
---------------------------------------------------------------------
-- 5. GroupsCurators
CREATE TABLE GroupsCurators (
    id INT PRIMARY KEY IDENTITY(1,1),
    curatorId INT NOT NULL,
    CONSTRAINT FK_GroupsCurators_curatorId FOREIGN KEY (curatorId) REFERENCES Curators(id),
    groupId INT NOT NULL,
    CONSTRAINT FK_GroupsCurators_groupId FOREIGN KEY (groupId) REFERENCES Groups(id)
);
INSERT INTO GroupsCurators (curatorId, groupId) VALUES
(1, 3),  
(2, 4),  
(3, 6),  
(4, 5);  
---------------------------------------------------------------------
-- 8. Lectures
CREATE TABLE Lectures (
    id INT PRIMARY KEY IDENTITY(1,1),
    lectureDate DATE NOT NULL,
    CONSTRAINT CK_Lectures_lectureDate CHECK (lectureDate <= GETDATE()),
    classroom NVARCHAR(MAX) NOT NULL,
    CONSTRAINT CK_Lectures_classroom CHECK (classroom <> ''),
    subjectId INT NOT NULL,
    CONSTRAINT FK_Lectures_subjectId FOREIGN KEY (subjectId) REFERENCES Subjects(id),
    teacherId INT NOT NULL,
    CONSTRAINT FK_Lectures_teacherId FOREIGN KEY (teacherId) REFERENCES Teachers(id)
);

INSERT INTO Lectures (lectureDate, classroom, subjectId, teacherId) VALUES
('2025-07-14', N'A1', 4, 1),
('2025-07-20', N'A1', 1, 1),
('2025-07-21', N'B2', 2, 2),
('2025-07-22', N'C3', 3, 3);
-----------------------------------------------------------------------------
-- 6. GroupsLectures
CREATE TABLE GroupsLectures (
    id INT PRIMARY KEY IDENTITY(1,1),
    lectureId INT NOT NULL,
    CONSTRAINT FK_GroupsLectures_lectureId FOREIGN KEY (lectureId) REFERENCES Lectures(id),
    groupId INT NOT NULL,
    CONSTRAINT FK_GroupsLectures_groupId FOREIGN KEY (groupId) REFERENCES Groups(id)
);
INSERT INTO GroupsLectures (lectureId, groupId) VALUES
(3, 3), 
(4, 4), 
(5, 5), 
(11, 6);
select * from Groups
select * from Lectures
-----------------------------------------------------------------------------
-- 7. GroupsStudents
CREATE TABLE GroupsStudents (
    id INT PRIMARY KEY IDENTITY(1,1),
    groupId INT NOT NULL,
    CONSTRAINT FK_GroupsStudents_groupId FOREIGN KEY (groupId) REFERENCES Groups(id),
    studentId INT NOT NULL,
    CONSTRAINT FK_GroupsStudents_studentId FOREIGN KEY (studentId) REFERENCES Students(id)
);
INSERT INTO GroupsStudents (groupId, studentId) VALUES
(3, 4), -- Rauf in CS101
(4, 5), -- Narmin in PHY202
(5, 6), -- Narmin in PHY202
(6, 7); -- Samira in PHL303
select * from Groups
-----------------------------------------------------------------------------
-- 9. Students
CREATE TABLE Students (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(MAX) NOT NULL,
    CONSTRAINT CK_Students_name CHECK (name <> ''),
    surname NVARCHAR(MAX) NOT NULL,
    CONSTRAINT CK_Students_surname CHECK (surname <> ''),
    rating INT NOT NULL,
    CONSTRAINT CK_Students_rating CHECK (rating BETWEEN 0 AND 5)
);
INSERT INTO Students (name, surname, rating) VALUES
(N'Rauf', N'Quliyev', 5),
(N'Narmin', N'Murshudova', 4),
(N'Nargiz', N'Mammadova', 4),
(N'Samira', N'Aliyeva', 3);
select * from Students
-----------------------------------------------------------------------------
-- 10. Subjects
CREATE TABLE Subjects (
    id INT PRIMARY KEY IDENTITY(1,1),
    subjectName NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_Subjects_subjectName UNIQUE(subjectName),
    CONSTRAINT CK_Subjects_subjectName CHECK (subjectName <> '')
);
INSERT INTO Subjects (subjectName) VALUES
 (N'Algorithms'),
 (N'Quantum Physics'),
 (N'Ethics'),
 (N'Programming');

-----------------------------------------------------------------------------
-- 11. Teachers
CREATE TABLE Teachers (
    id INT PRIMARY KEY IDENTITY(1,1),
    isProfessor BIT NOT NULL DEFAULT 0,
    teacherName NVARCHAR(MAX) NOT NULL,
    CONSTRAINT CK_Teachers_teacherName CHECK (teacherName <> ''),
    teacherSurname NVARCHAR(MAX) NOT NULL,
    CONSTRAINT CK_Teachers_teacherSurname CHECK (teacherSurname <> ''),
    salary MONEY NOT NULL,
    CONSTRAINT CK_Teachers_salary CHECK (salary > 0)
);
INSERT INTO Teachers (isProfessor, teacherName, teacherSurname, salary) VALUES
(1, N'Elchin', N'Ismayilov', 1200),
(1, N'Kamran', N'Əliyev', 1300),
(0, N'Nigar', N'Sadigova', 900),
(1, N'Taleh', N'Hasanov', 1500);

-----------------------------------------------------------------------------
------------------------------- QUERIES--------------------------------------

--1. Print numbers of buildings if the total financing fund of the departments located in them exceeds 100,000

select building, COUNT(*) as department_count
from Departments
group by building
having SUM(financing) > 100000;
-----------------------------------------------------------------------------
--2.. Print names of the 5th year groups of the Software Development department that have more than 10 double periods in
--the first week.

SELECT G.name
FROM Groups AS G, Departments AS D, GroupsLectures AS GL, Lectures AS L
WHERE 
    G.departmentId = D.id
    AND G.id = GL.groupId
    AND GL.lectureId = L.id
    AND G.groupYear = 5
    AND D.name = 'Software Development'
    AND L.lectureDate BETWEEN '2025-09-01' AND '2025-09-07'
GROUP BY G.name
HAVING COUNT(*) > 10;
-----------------------------------------------------------------------------
--3.Print names of the groups whose rating (average rating of all students in the group) is greater than the rating of the "D221" group

SELECT G.name
FROM Groups AS G, Students AS S
WHERE G.id = S.id
GROUP BY G.name
HAVING AVG(S.rating) > (
    SELECT AVG(S2.rating)
    FROM Groups AS G2, Students AS S2
    WHERE G2.id = S2.id AND G2.name = 'D221'
);
-----------------------------------------------------------------------------
--4.Print full names of teachers whose wage rate is higher than the average wage rate of professors.

SELECT tc.teacherName, tc.teacherSurname
FROM Teachers AS tc
WHERE tc.salary > (
    SELECT AVG(tc2.salary)
    FROM Teachers AS tc2
    WHERE tc2.isProfessor = 1
);
-----------------------------------------------------------------------------
--5. Print names of groups with more than one curator
select [name]
from groups as g, GroupsCurators as gc  
where g.id=gc.groupId
group by g.name
HAVING COUNT(GC.curatorId) > 1;
-----------------------------------------------------------------------------
--6. Print names of the groups whose rating (the average rating of all students of the group) is less than the minimum rating
--of the 5th year groups.

SELECT gr.name
FROM Groups AS G, Students AS st
WHERE gr.id = st.id
GROUP BY gr.name
HAVING AVG(st.rating) < (
    SELECT MIN(avg_rating)
    FROM (
        SELECT AVG(st2.rating) AS avg_rating
        FROM Groups AS gr2, Students AS st2
        WHERE gr2.id = S2.id AND G2.groupYear = 5
        GROUP BY gr2.id
    ) AS sub
);
-----------------------------------------------------------------------------
--7.Print names of the faculties with total financing fund of the departments greater than the total financing fund of the Computer
--Science department.

SELECT fc.name
FROM Faculties AS fc, Departments AS dp
WHERE fc.id = dp.facultyId
GROUP BY fc.name
HAVING SUM(dp.financing) > (
    SELECT SUM(dp2.financing)
    FROM Departments AS dp2
    WHERE dp2.name = 'Computer Science'
);
-----------------------------------------------------------------------------
--8.Print names of the subjects and full names of the teachers who
--deliver the greates number of lectures in them

SELECT st.subjectName AS subjectName, tr.teacherName, tr.teacherSurname
FROM Subjects AS st, Lectures AS L, Teachers AS tr
WHERE st.id = L.subjectId AND tr.id = L.teacherId
GROUP BY st.subjectName, T.teacherName, tr.teacherSurname
HAVING COUNT(*) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM Lectures AS L2
        GROUP BY L2.subjectId
    ) AS sub
);
-----------------------------------------------------------------------------
--9. Print name of the subject in which the least number of lectures are delivered

select st.subjectName as subjectName
from Subjects as st, Lectures as lt
where st.id = lt.subjectId 
group by st.subjectName
having COUNT(*) = (
    select MIN(cnt)
    from (
        select COUNT(*) as cnt
        from Lectures as lt2
        group by lt2.subjectId
    ) as sub
);
-----------------------------------------------------------------------------
--10. Print number of students and subjects taught at the Software Development department.

select count(*) as student_count
from Students as st, Groups as gp, Departments as dp
where st.id = gp.id AND gp.departmentId = dp.id and dp.name = 'Software Development';