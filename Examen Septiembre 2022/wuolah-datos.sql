-- Creado por Daniel Ayala, David Ruiz, Agustin Borrego, e Inma Hernandez
-- Script de creacion de base de datos para examen de laboratorio de IISSI1
-- En este scripts se encuentran procedimientos para la creacion de tablas
-- (incluido el uso del procedimiento), la inserción de datos (incluido el
-- uso del procedimiento), y algunos procedimientos adicionales que pueden
-- usarse como referencia a 

-- Definicion del procedimiento de creacion de tablas
DELIMITER //
CREATE OR REPLACE PROCEDURE
	createTables()
BEGIN
	SET FOREIGN_KEY_CHECKS=0;
	DROP TABLE IF EXISTS Degrees;
	DROP TABLE IF EXISTS Subjects;
	DROP TABLE IF EXISTS Groups;
	DROP TABLE IF EXISTS Students;
	DROP TABLE IF EXISTS GroupsStudents;
	DROP TABLE IF EXISTS Grades;
	DROP TABLE IF EXISTS Offices;
	DROP TABLE IF EXISTS Classrooms;
	DROP TABLE IF EXISTS Departments;
	DROP TABLE IF EXISTS TutoringHours;
	DROP TABLE IF EXISTS TeachingLoads;
	DROP TABLE IF EXISTS Appointments;
	DROP TABLE IF EXISTS Professors;
	SET FOREIGN_KEY_CHECKS=1;

	CREATE TABLE Offices (
		officeId INT NOT NULL AUTO_INCREMENT,
		name VARCHAR(60) NOT NULL,
		floor INT NOT NULL, 
		capacity INT NOT NULL,
		PRIMARY KEY (officeId),
		CONSTRAINT invalidFloor CHECK (floor >= 0),
		CONSTRAINT invalidCapacity CHECK (capacity > 0),
		UNIQUE (name)
	);

	CREATE TABLE Classrooms (
		classroomId INT NOT NULL AUTO_INCREMENT,
		name VARCHAR(60) NOT NULL UNIQUE,
		floor INT NOT NULL, 
		capacity INT NOT NULL,
		hasProjector BOOLEAN NOT NULL,
		hasLoudSpeakers BOOLEAN NOT NULL,
		PRIMARY KEY (classroomId),
		CONSTRAINT invalidFloor CHECK (floor >= 0),
		CONSTRAINT invalidCapacity CHECK (capacity > 0)
	);

	CREATE TABLE Departments (
		departmentId INT NOT NULL AUTO_INCREMENT,
		name VARCHAR(60) NOT NULL UNIQUE,
		PRIMARY KEY (departmentId)
	);

	CREATE TABLE Degrees(
		degreeId INT NOT NULL AUTO_INCREMENT,
		name VARCHAR(60) NOT NULL UNIQUE,
		years INT DEFAULT 4 NOT NULL,
		PRIMARY KEY (degreeId),
		CONSTRAINT invalidDegreeYear CHECK (years >=3 AND years <=5)
	);

	CREATE TABLE Subjects(
		subjectId INT NOT NULL AUTO_INCREMENT,
		name VARCHAR(100) NOT NULL UNIQUE,
		acronym VARCHAR(8) NOT NULL UNIQUE,
		credits INT NOT NULL,
		course INT NOT NULL,
		type VARCHAR(20) NOT NULL,
		degreeId INT NOT NULL,
		departmentId INT NOT NULL,
		PRIMARY KEY (subjectId),
		FOREIGN KEY (degreeId) REFERENCES Degrees (degreeId),
		FOREIGN KEY (departmentId) REFERENCES Departments (departmentId),
		CONSTRAINT negativeSubjectCredits CHECK (credits > 0),
		CONSTRAINT invalidSubjectCourse CHECK (course > 0 AND course < 6),
		CONSTRAINT invalidSubjectType CHECK (type IN ('Formacion Basica',
																	'Optativa',
																	'Obligatoria'))
	);

	CREATE TABLE Groups(
		groupId INT NOT NULL AUTO_INCREMENT,
		name VARCHAR(30) NOT NULL,
		activity VARCHAR(20) NOT NULL,
		year INT NOT NULL,
		subjectId INT NOT NULL,
		classroomId INT NOT NULL,
		PRIMARY KEY (groupId),
		FOREIGN KEY (subjectId) REFERENCES Subjects (subjectId),
		FOREIGN KEY (classroomId) REFERENCES Classrooms (classroomId),
		UNIQUE (name, year, subjectId),
		CONSTRAINT negativeGroupYear CHECK (year > 0),
		CONSTRAINT invalidGroupActivity CHECK (activity IN ('Teoria',
																			'Laboratorio'))
	);

	CREATE TABLE Students(
		studentId INT NOT NULL AUTO_INCREMENT,
		accessMethod VARCHAR(30) NOT NULL,
		dni CHAR(9) NOT NULL UNIQUE,
		firstName VARCHAR(100) NOT NULL,
		surname VARCHAR(100) NOT NULL,
		birthDate DATE NOT NULL,
		email VARCHAR(250) NOT NULL UNIQUE,
		PRIMARY KEY (studentId),
		CONSTRAINT invalidStudentAccessMethod CHECK (accessMethod IN ('Selectividad',
																						'Ciclo',
																						'Mayor',
																						'Titulado Extranjero'))
	);

	CREATE TABLE GroupsStudents(
		groupStudentId INT NOT NULL AUTO_INCREMENT,
		groupId INT NOT NULL,
		studentId INT NOT NULL,
		PRIMARY KEY (groupStudentId),
		FOREIGN KEY (groupId) REFERENCES Groups (groupId) ON DELETE CASCADE,
		FOREIGN KEY (studentId) REFERENCES Students (studentId),
		UNIQUE (groupId, studentId)
	);

	CREATE TABLE Grades(
		gradeId INT NOT NULL AUTO_INCREMENT,
		value DECIMAL(4,2) NOT NULL,
		gradeCall INT NOT NULL,
		withHonours BOOLEAN NOT NULL,
		studentId INT NOT NULL,
		groupId INT NOT NULL,
		PRIMARY KEY (gradeId),
		FOREIGN KEY (studentId) REFERENCES Students (studentId),
		FOREIGN KEY (groupId) REFERENCES Groups (groupId) ON DELETE CASCADE,
		CONSTRAINT invalidGradeValue CHECK (value >= 0 AND value <= 10),
		CONSTRAINT invalidGradeCall CHECK (gradeCall >= 1 AND gradeCall <= 3),
		CONSTRAINT duplicatedCallGrade UNIQUE (gradeCall, studentId, groupId)
	);

	CREATE TABLE Professors (
		professorId INT NOT NULL AUTO_INCREMENT,
		officeId INT NOT NULL,
		departmentId INT NOT NULL,
		category VARCHAR(5) NOT NULL,
		dni CHAR(9) NOT NULL UNIQUE,
		firstName VARCHAR(100) NOT NULL,
		surname VARCHAR(100) NOT NULL,
		birthDate DATE NOT NULL,
		email VARCHAR(250) NOT NULL UNIQUE,
		PRIMARY KEY (professorId),
		FOREIGN KEY (officeId) REFERENCES Offices (officeId),
		FOREIGN KEY (departmentId) REFERENCES Departments (departmentId),
		CONSTRAINT invalidCategory CHECK (category IN ('CU',
														'TU',
														'PCD',
														'PAD'))
	);

	CREATE TABLE TutoringHours(
		tutoringHoursId INT NOT NULL AUTO_INCREMENT,
		professorId INT NOT NULL,
		dayOfWeek INT NOT NULL,
		startHour TIME,
		endHour TIME,
		PRIMARY KEY (tutoringHoursId),
		FOREIGN KEY (professorId) REFERENCES Professors (professorId),
		CONSTRAINT invalidDayOfWeek CHECK (dayOfWeek >= 0 AND dayOfWeek <= 6)
	);

	CREATE TABLE Appointments(
		appointmentId INT NOT NULL AUTO_INCREMENT,
		tutoringHoursId INT NOT NULL,
		studentId INT NOT NULL,
		hour TIME NOT NULL,
		date DATE NOT NULL,
		PRIMARY KEY (appointmentId),
		FOREIGN KEY (tutoringHoursId) REFERENCES TutoringHours (tutoringHoursId),
		FOREIGN KEY (studentId) REFERENCES Students (studentId)
	);

	CREATE TABLE TeachingLoads(
		teachingLoadId INT NOT NULL AUTO_INCREMENT,
		professorId INT NOT NULL,
		groupId INT NOT NULL,
		credits INT NOT NULL,
		PRIMARY KEY (teachingLoadId),
		FOREIGN KEY (professorId) REFERENCES Professors (professorId),
		FOREIGN KEY (groupId) REFERENCES Groups (groupId),
		CONSTRAINT invalidCredits CHECK (credits > 0)
	);
END //
DELIMITER ;

-- Llamada al procedimiento de creacion de tablas
CALL createTables();

-- Definicion del procedimiento de insercion de datos
DELIMITER //
CREATE OR REPLACE PROCEDURE
	populate()
BEGIN
	SET FOREIGN_KEY_CHECKS=0;
	DELETE FROM Degrees;
	DELETE FROM Subjects;
	DELETE FROM Groups;
	DELETE FROM Students;
	DELETE FROM GroupsStudents;
	DELETE FROM Grades;
	DELETE FROM Offices;
	DELETE FROM Classrooms;
	DELETE FROM Departments;
	DELETE FROM TutoringHours;
	DELETE FROM TeachingLoads;
	DELETE FROM Appointments;
	DELETE FROM Professors;
	SET FOREIGN_KEY_CHECKS=1;
	ALTER TABLE Degrees AUTO_INCREMENT=1;
	ALTER TABLE Subjects AUTO_INCREMENT=1;
	ALTER TABLE Groups AUTO_INCREMENT=1;
	ALTER TABLE Students AUTO_INCREMENT=1;
	ALTER TABLE GroupsStudents AUTO_INCREMENT=1;
	ALTER TABLE Grades AUTO_INCREMENT=1;
	ALTER TABLE Offices AUTO_INCREMENT=1;
	ALTER TABLE Classrooms AUTO_INCREMENT=1;
	ALTER TABLE Departments AUTO_INCREMENT=1;
	ALTER TABLE TutoringHours AUTO_INCREMENT=1;
	ALTER TABLE TeachingLoads AUTO_INCREMENT=1;
	ALTER TABLE Appointments AUTO_INCREMENT=1;
	ALTER TABLE Professors AUTO_INCREMENT=1;
	
	INSERT INTO Offices (name, floor, capacity) VALUES
		('F1.85', 1, 5),
		('F0.45', 0, 3);
	
	INSERT INTO Classrooms (name, floor, capacity, hasProjector, hasLoudSpeakers) VALUES
		('F1.31', 1, 30, TRUE, FALSE),
		('F1.33', 1, 35, TRUE, FALSE),
		('A0.31', 1, 80, TRUE, TRUE);
	
	INSERT INTO Departments (name) VALUES
		('Lenguajes y Sistemas Informáticos'),
		('Matemáticas');
	
	INSERT INTO Degrees (name, years) VALUES
		('Ingeniería del Software', 4),
		('Ingeniería de Computadores', 4),
		('Tecnologías Informáticas', 4);
	
	INSERT INTO Subjects (name, acronym, credits, course, type, degreeId, departmentId) VALUES
		('Diseño y Pruebas', 'DP', 12, 3, 'Obligatoria', 1, 1),
		('Acceso Inteligente a la Informacion', 'AII', 6, 4, 'Optativa', 1, 1),
		('Optimizacion de Sistemas', 'OS', 6, 4, 'Optativa', 1, 1),
		('Ingeniería de Requisitos', 'IR', 6, 2, 'Obligatoria', 1, 1),
		('Análisis y Diseño de Datos y Algoritmos', 'ADDA', 12, 2, 'Obligatoria', 1, 1),
	-- 5/6
		('Introducción a la Matematica Discreta', 'IMD', 6, 1, 'Formacion Basica', 2, 2),
		('Redes de Computadores', 'RC', 6, 2, 'Obligatoria', 2, 1),
		('Teoría de Grafos', 'TG', 6, 3, 'Obligatoria', 2, 2),
		('Aplicaciones de Soft Computing', 'ASC', 6, 4, 'Optativa', 2, 1),
	-- 9/10
		('Fundamentos de Programación', 'FP', 12, 1, 'Formacion Basica', 3, 1),
		('Lógica Informatica', 'LI', 6, 2, 'Optativa', 3, 2),
		('Gestión y Estrategia Empresarial', 'GEE', 12, 3, 'Optativa', 3, 1),
		('Trabajo de Fin de Grado', 'TFG', 12, 4, 'Obligatoria', 3, 1);
		
	INSERT INTO Groups (name, activity, year, subjectId, classroomId) VALUES
		('T1', 'Teoria', 2018, 1, 1),
		('T2', 'Teoria', 2018, 1, 2),
		('L1', 'Laboratorio', 2018, 1, 3),
		('L2', 'Laboratorio', 2018, 1, 1),
		('L3', 'Laboratorio', 2018, 1, 2),
		('T1', 'Teoria', 2019, 1, 3),
		('T2', 'Laboratorio', 2019, 1, 1),
		('L1', 'Laboratorio', 2019, 1, 2),
		('L2', 'Laboratorio', 2019, 1, 3),
	-- 9/10
		('Teor1', 'Teoria', 2018, 2, 1),
		('Teor2', 'Teoria', 2018, 2, 2),
		('Lab1', 'Laboratorio', 2018, 2, 3),
		('Lab2', 'Laboratorio', 2018, 2, 1),
		('Teor1', 'Teoria', 2019, 2, 2),
		('Lab1', 'Laboratorio', 2019, 2, 3),
		('Lab2', 'Laboratorio', 2019, 2, 1),
	-- 16/17
		('T1', 'Teoria', 2019, 10, 2),
		('T2', 'Teoria', 2019, 10, 3),
		('T3', 'Teoria', 2019, 10, 1),
		('L1', 'Laboratorio', 2019, 10, 2),
		('L2', 'Laboratorio', 2019, 10, 3),
		('L3', 'Laboratorio', 2019, 10, 1),
		('L4', 'Laboratorio', 2019, 10, 2),
	-- 23/24
		('Clase', 'Teoria', 2019, 12, 3),
		('T1', 'Teoria', 2019, 6, 1);
		
	INSERT INTO Students (accessMethod, dni, firstname, surname, birthdate, email) VALUES
		('Selectividad', '12345678A', 'Daniel', 'Pérez', '1991-01-01', 'daniel@alum.us.es'),
		('Selectividad', '22345678A', 'Rafael', 'Ramírez', '1992-01-01', 'rafael@alum.us.es'),
		('Selectividad', '32345678A', 'Gabriel', 'Hernández', '1993-01-01', 'gabriel@alum.us.es'),
		('Selectividad', '42345678A', 'Manuel', 'Fernández', '1994-01-01', 'manuel@alum.us.es'),
		('Selectividad', '52345678A', 'Joel', 'Gómez', '1995-01-01', 'joel@alum.us.es'),
		('Selectividad', '62345678A', 'Abel', 'López', '1996-01-01', 'abel@alum.us.es'),
		('Selectividad', '72345678A', 'Azael', 'González', '1997-01-01', 'azael@alum.us.es'),
		('Selectividad', '8345678A', 'Uriel', 'Martínez', '1998-01-01', 'uriel@alum.us.es'),
		('Selectividad', '92345678A', 'Gael', 'Sánchez', '1999-01-01', 'gael@alum.us.es'),
		('Titulado Extranjero', '12345678B', 'Noel', 'Álvarez', '1991-02-02', 'noel@alum.us.es'),
		('Titulado Extranjero', '22345678B', 'Ismael', 'Antúnez', '1992-02-02', 'ismael@alum.us.es'),
		('Titulado Extranjero', '32345678B', 'Nathanael', 'Antolinez', '1993-02-02', 'nathanael@alum.us.es'),
		('Titulado Extranjero', '42345678B', 'Ezequiel', 'Aznárez', '1994-02-02', 'ezequiel@alum.us.es'),
		('Titulado Extranjero', '52345678B', 'Ángel', 'Chávez', '1995-02-02', 'angel@alum.us.es'),
		('Titulado Extranjero', '62345678B', 'Matusael', 'Gutiérrez', '1996-02-02', 'matusael@alum.us.es'),
		('Titulado Extranjero', '72345678B', 'Samael', 'Gálvez', '1997-02-02', 'samael@alum.us.es'),
		('Titulado Extranjero', '82345678B', 'Baraquiel', 'Ibáñez', '1998-02-02', 'baraquiel@alum.us.es'),
		('Titulado Extranjero', '92345678B', 'Otoniel', 'Idiáquez', '1999-02-02', 'otoniel@alum.us.es'),
		('Titulado Extranjero', '12345678C', 'Niriel', 'Benítez', '1991-03-03', 'niriel@alum.us.es'),
		('Titulado Extranjero', '22345678C', 'Múriel', 'Bermúdez', '1992-03-03', 'muriel@alum.us.es'),
		('Titulado Extranjero', '32345678C', 'John', 'AII', '2000-01-01', 'john@alum.us.es');
		
	INSERT INTO GroupsStudents (groupId, studentId) VALUES
		(1, 1),
		(3, 1),
		(7, 1),
		(8, 1),
		(10, 1),
		(12, 1),
	-- 6/7
		(2, 2),
		(3, 2),
		(10, 2),
		(12, 2),
	-- 10/11
		(18, 21),
		(21, 21),
	-- 12/13
		(1, 9);
		
	INSERT INTO Grades (value, gradeCall, withHonours, studentId, groupId) VALUES
		(4.50, 1, 0, 1, 1),
		(3.25, 2, 0, 1, 1),
		(9.95, 1, 0, 1, 7),
		(7.5, 1, 0, 1, 10),
	-- 4/5
		(2.50, 1, 0, 2, 2),
		(5.00, 2, 0, 2, 2),
		(10.00, 1, 1, 2, 10),
	-- 7/8
		(0.00, 1, 0, 21, 18),
		(1.25, 2, 0, 21, 18),
		(0.5, 3, 0, 21, 18);
	
	INSERT INTO Professors (officeId, departmentId, category, dni, firstname, surname, birthdate, email) VALUES
		(1, 1, 'PAD', '42345678C', 'Fernando', 'Ramírez', '1960-05-02', 'fernando@us.es'),
		(1, 1, 'TU', '52345678C', 'David', 'Zuir', '1902-01-01', 'dzuir@us.es'),
		(1, 1, 'TU', '62345678C', 'Antonio', 'Zuir', '1902-01-01', 'azuir@us.es'),
		(1, 2, 'CU', '72345678C', 'Rafael', 'Gómez', '1959-12-12', 'rdgomez@us.es'),
		(2, 1, 'TU', '82345678C', 'Inma', 'Hernández', '1234-5-6', 'inmahrdz@us.es');
	
	INSERT INTO TutoringHours (professorId, dayOfWeek, startHour, endHour) VALUES
		(1, 0, '12:00:00', '14:00:00'),
		(1, 1, '18:00:00', '19:00:00'),
		(1, 1, '11:30:00', '12:30:00'),
		(2, 2, '10:00:00', '20:00:00');
	
	INSERT INTO Appointments (tutoringHoursId, studentId, hour, date) VALUES
		(1, 1, '13:00:00', '2019-11-18'),
		(2, 2, '18:20:00', '2019-11-19'),
		(4, 1, '15:00:00', '2019-11-20');
	
	INSERT INTO TeachingLoads (professorId, groupId, credits) VALUES
		(1, 1, 6),
		(2, 1, 12),
		(1, 2, 6),
		(1, 3, 12);
END //
DELIMITER ;

-- Llamada al proceso de insercion de datos
CALL populate();

-- Procedimientos varios

-- RF-001
DELIMITER //
CREATE OR REPLACE PROCEDURE 
    createGrade(groupId INT, studentId INT, gradeCall INT, withHonours BOOLEAN, value DECIMAL(4,2))
BEGIN
	INSERT INTO Grades (groupId, studentId, gradeCall, withHonours, value) VALUES (groupId, studentId, gradeCall, withHonours, value);
END //
DELIMITER ;

-- RF-006
DELIMITER //
CREATE OR REPLACE PROCEDURE 
	procedureDeleteGrades(studentDni CHAR(9))
BEGIN
	DECLARE id INT;
	SET id = (SELECT studentId FROM Students WHERE dni=studentDni);
	DELETE FROM Grades WHERE studentId=id;
END //
DELIMITER ;

-- Triggers

-- RN-006
DELIMITER //
CREATE OR REPLACE TRIGGER triggerWithHonours
	BEFORE INSERT ON Grades
	FOR EACH ROW
	BEGIN
		IF (new.withHonours = 1 AND new.value < 9.0) THEN
			SIGNAL SQLSTATE '45000' SET message_text =
			'Para obtener matrícula hay que sacar al menos un 9';
		END IF;
	END//
DELIMITER ;