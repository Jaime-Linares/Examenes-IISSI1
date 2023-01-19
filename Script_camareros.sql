CREATE DATABASE IF NOT EXISTS jailinbar_turnosmñn;
USE jailinbar_turnosmñn;

DROP TABLE IF EXISTS Turnos;
DROP TABLE IF EXISTS Camareros;

CREATE TABLE IF NOT EXISTS Camareros(
	idCamarero 		INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	dni        		CHAR(9) NOT NULL UNIQUE,
	nombre        	VARCHAR(50) NOT NULL UNIQUE,
	apellidos 		VARCHAR(50) NOT NULL,
	fechaNacimiento	DATE NOT NULL,  
	sexo			VARCHAR(50) NOT NULL
); 

CREATE TABLE IF NOT EXISTS Turnos(
	idTurno	 		INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	diaSemana    	ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo') NOT NULL,
	horaInicio 		TIME NOT NULL,
	horaFin 		TIME NOT NULL,
	idCamarero		INT NOT NULL,
	CHECK (horaInicio < horaFin),
	FOREIGN KEY (idCamarero) REFERENCES Camareros(idCamarero) ON DELETE CASCADE
);

INSERT INTO Camareros (dni, nombre, apellidos, fechaNacimiento, sexo) VALUES
	('12345678A','Chavela', 'Vargas', '1919-04-17', 'M'),
	('23456789B', 'Eren', 'Jaeger', '1983-08-20', 'H'),
	('34567891C', 'Manuel', 'Pelegrini', '1953-11-16', 'H'),
	('45678912D', 'Marilyn', 'Monroe', '1926-06-01', 'M');
 
INSERT INTO Turnos (diaSemana, horaInicio, horaFin, idCamarero) VALUES 
	('Lunes','8:00:00','14:00:00', 1),
	('Martes','14:00:00','22:00:00', 1),
	('Miércoles','14:00:00','22:00:00', 1),
	('Jueves','14:00:00','22:00:00', 1),
	('Viernes','9:00:00','15:00:00', 1),
	('Lunes','10:00:00','16:00:00', 2),
	('Martes','9:30:00','18:30:00', 2),
	('Miércoles','6:30:00','12:30:00', 2),
	('Jueves','10:00:00','22:00:00', 2),
	('Viernes','5:00:00','10:00:00', 2),
	('Sábado','18:00:00','23:00:00', 3),
	('Domingo','15:00:00','20:00:00', 3),
	('Sábado','23:00:00','23:59:59', 4),
	('Domingo','00:00:00','7:00:00', 4);
	
