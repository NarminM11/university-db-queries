-- 1. Curators ++
CREATE TABLE Curators (
    id INT PRIMARY KEY IDENTITY(1,1) not null,
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
-- 2. Faculties ++
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
-- 3. Departments ++
CREATE TABLE Departments (
    id INT PRIMARY KEY IDENTITY(1,1),
    financing MONEY NOT NULL DEFAULT 0,
    CONSTRAINT CK_Departments_financing CHECK (financing >= 0),
    name NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_Departments_name UNIQUE(name),
    CONSTRAINT CK_Departments_name CHECK (name <> ''),  
    facultyId INT NOT NULL,
    CONSTRAINT FK_Departments_facultyId FOREIGN KEY (facultyId) REFERENCES Faculties(id)
);

INSERT INTO Departments (name, financing, facultyId) VALUES
('Computer Science', 200000, 1),
('Mechanical Engineering', 150000, 1),
('Physics',  100000, 2),
('Philosophy',  80000, 3);
---------------------------------------------------------------------
-- 4. Groups ++
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
-- 5. GroupsCurators ++
CREATE TABLE GroupsCurators (
    id INT PRIMARY KEY IDENTITY(1,1),
    curatorId INT NOT NULL,
    CONSTRAINT FK_GroupsCurators_curatorId FOREIGN KEY (curatorId) REFERENCES Curators(id),
    groupId INT NOT NULL,
    CONSTRAINT FK_GroupsCurators_groupId FOREIGN KEY (groupId) REFERENCES Groups(id)
);
INSERT INTO GroupsCurators (curatorId, groupId) VALUES
(1, 1),  
(2, 2),  
(3,3),  
(4, 4);  
---------------------------------------------------------------------
-- 8. Lectures ++
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
-- 6. GroupsLectures ++
CREATE TABLE GroupsLectures (
    id INT PRIMARY KEY IDENTITY(1,1),
    lectureId INT NOT NULL,
    CONSTRAINT FK_GroupsLectures_lectureId FOREIGN KEY (lectureId) REFERENCES Lectures(id),
    groupId INT NOT NULL,
    CONSTRAINT FK_GroupsLectures_groupId FOREIGN KEY (groupId) REFERENCES Groups(id)
);
INSERT INTO GroupsLectures (lectureId, groupId) VALUES
(3, 1), 
(4, 2), 
(5, 4), 
(6, 3);
select * from Groups
select * from Lectures
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
--------------------------------QUERIES--------------------------------------

--1. Print all possible pairs of lines of teachers and groups.
SELECT 
    tr.teacherName, tr.teacherSurname,
    gr.name AS groupName
FROM Teachers tr, Groups gr;
-----------------------------------------------------------------------------
--2.Print names of faculties, where financing fund of departments exceeds financing fund of the faculty.
SELECT fc.name
FROM Faculties fc
WHERE (
    SELECT SUM(dp.financing)
    FROM Departments dp
    WHERE dp.facultyId = fc.id
) > fc.financing;

-- 3. Print names of the group curators and groups names they are  supervising
SELECT 
    cr.name + ' ' + cr.surname AS curatorFullName,
    gp.name AS groupName
FROM GroupsCurators gc, Curators cr, Groups gp
WHERE gc.curatorId = cr.id AND gc.groupId = gp.id;

-- 4. Print names of the teachers who deliver lectures in the group "P107"
SELECT tr.teacherName, tr.teacherSurname
FROM Teachers tr, Lectures lt
WHERE lt.teacherId = tr.id
AND lt.id IN (
    SELECT gl.lectureId
    FROM GroupsLectures gl
    WHERE gl.groupId IN (
        SELECT gr.id FROM Groups gr WHERE gr.name = 'FSDE_24A'
    )
);

-- 5. Print names of the teachers and names of the faculties where they are lecturing
SELECT tr.teacherName, tr.teacherSurname, fc.name AS facultyName
FROM Teachers tr, Lectures lt, GroupsLectures GL, Groups gr, Departments dp, Faculties fc
WHERE lt.teacherId =tr.id
AND lt.id = GL.lectureId
AND GL.groupId = gr.id
AND gr.departmentId = dp.id
AND dp.facultyId = fc.id;

-- 6. Print names of the departments and names of the groups that relate to them
SELECT dp.name AS departmentName, gp.name AS groupName
FROM Departments dp, Groups gp
WHERE gp.departmentId = dp.id;

-- 7. Print names of the subjects that the teacher "Samantha Adams" teaches
SELECT sb.subjectName
FROM Subjects sb, Lectures lt, Teachers tr
WHERE lt.subjectId = sb.id AND lt.teacherId = tr.id
AND tr.teacherName = 'Samantha' AND tr.teacherSurname = 'Adams';

-- 8. Print names of the departments, where "Database Theory" is taught
SELECT dp.name
FROM Departments dp, Groups gr, GroupsLectures gl, Lectures lt, Subjects sb
WHERE gr.departmentId = dp.id
AND gr.id = gl.groupId
AND gl.lectureId = lt.id
AND lt.subjectId = sb.id
AND sb.subjectName = 'Database Theory';

-- 9. Print names of the groups that belong to the "Computer Science" faculty
SELECT gr.name
FROM Groups gr
WHERE gr.departmentId IN (
    SELECT dp.id
    FROM Departments dp
    WHERE dp.name = 'Computer Science'
);

-- 10. Print names of the 5th year groups, as well as names of the faculties to which they relate
SELECT gr.name AS groupName, fc.name AS facultyName
FROM Groups gr, Departments dp, Faculties fc
WHERE gr.groupYear = 5
AND gr.departmentId = dp.id
AND dp.facultyId = fc.id;


-- 11. Print full names of the teachers and lectures they deliver (names
-- of subjects and groups), and select only those lectures that are
-- delivered in the classroom "B103"

SELECT 
    tr.teacherName + ' ' + tr.teacherSurname AS teacherFullName,
    sb.subjectName,
    gr.name AS groupName
FROM Teachers tr, Lectures lt, Subjects sb, GroupsLectures gl, Groups gr
WHERE lt.teacherId = tr.id
AND lt.subjectId = sb.id
AND lt.classroom = 'B103'
AND lt.id = gl.lectureId
AND gl.groupId = gr.id;
