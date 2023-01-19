CREATE DATABASE IF NOT EXISTS jailinbar_sep2022;
USE jailinbar_sep2022;

-- 0. Ejecute la consulta SELECT COUNT(*) FROM Students; y compruebe que el resultado que devuelve es 21.
SELECT COUNT(*)
FROM students;


/*
1. Añada el requisito de información Publicación. Una publicación es un artículo publicado en una revista
por un profesor. Sus atributos son: el título de la publicación, el profesor que es el autor principal, el
número total de autores, la fecha de publicación (día), y el nombre de la revista donde ha sido publicada.
Hay que tener en cuenta las siguientes restricciones:
- Un profesor no puede tener varias publicaciones en la misma revista, el mismo día.
- El número de autores debe ser al menos 1 y como máximo 10.
- Todos los atributos son obligatorios a excepción de la fecha de publicación.
*/
DROP TABLE IF EXISTS publicaciones;

CREATE TABLE publicaciones(
publicacionId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
titulo VARCHAR(128) NOT NULL,
professorId INT NOT NULL,
numAutores INT NOT NULL,
fechaPublicacion DATE,
revista VARCHAR(128) NOT NULL,
FOREIGN KEY (professorId) REFERENCES professors(professorId),
CONSTRAINT numAutoresInvalido CHECK (numAutores>=1 AND numAutores<=10)
);

DELIMITER //
CREATE OR REPLACE TRIGGER tVariasPublicaciones
BEFORE INSERT ON publicaciones
FOR EACH ROW
BEGIN
	DECLARE numPublicaciones INT;
	SET numPublicaciones = (SELECT COUNT(*) 
									FROM publicaciones 
									WHERE (NEW.revista=revista AND NEW.fechaPublicacion=fechaPublicacion));
	IF(numPublicaciones>0) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
		'Un profesor no puede tener varias publicaciones en la misma revista, el mismo día';
	END IF;
END //
DELIMITER ;


/*
2. Cree y ejecute un procedimiento almacenado llamado pInsertPublications() que cree las siguientes
publicaciones:
- Publicación titulada “Publicación 1” del profesor con ID=1, con 3 autores, publicada en la
revista “Revista 1”.
- Publicación titulada “Publicación 2”, del profesor con ID=1, con 5 autores, publicada el 1 de
Enero de 2018 en la revista “Revista 2”.
- Publicación titulada “Publicación 3”, del profesor con ID=2, con 2 autores, publicada en la
revista “Revista 3”.
*/
DELIMITER //
CREATE OR REPLACE PROCEDURE 
pInsertPublications(tit VARCHAR(128), professor INT, numAut INT, fechaPubli DATE, rev VARCHAR(128))
BEGIN 
	INSERT INTO publicaciones(titulo, professorId, numAutores, fechaPublicacion, revista) VALUE
	(tit, professor, numAut, fechaPubli, rev);
END //
DELIMITER ;

CALL pInsertPublications('Publicacion 1', 1, 3, NULL, 'Revista 1');
CALL pInsertPublications('Publicacion 2', 1, 5, '2018-01-01', 'Revista 2');
CALL pInsertPublications('Publicacion 3', 2, 2, NULL, 'Revista 3');


/*
3. Cree un disparador llamado tCorrectAuthors que, al actualizarse una publicación, si el número de autores
fuera a pasar a ser más de 10, lo cambie a 10 en su lugar.
*/
DELIMITER //
CREATE OR REPLACE TRIGGER tCorrectAuthors
AFTER UPDATE ON publicaciones 
FOR EACH ROW
BEGIN
	IF(NEW.numAutores>10) THEN
		UPDATE publicaciones SET numAutores=10 WHERE NEW.publicacionId=publicacionId;
	END IF;
END //
DELIMITER ;


/*
4. Cree un procedimiento almacenado llamado pUpdatePublications(p, n) que actualiza el número de
autores de las publicaciones del profesor p con el valor n. Ejecute la llamada a pUpdatePublications(1,10).
Cree un procedimiento almacenado llamado pDeletePublications(p) que elimina las publicaciones del
profesor con ID=p. Ejecute la llamada pDeletePublications(2).
*/
DELIMITER //
CREATE OR REPLACE PROCEDURE pUpdatePublications(p INT, n INT)
BEGIN
	UPDATE publicaciones SET numAutores=n WHERE professorId=p;
END //
DELIMITER ;

CALL pUpdatePublications(1, 10);

DELIMITER //
CREATE OR REPLACE PROCEDURE pDeletePublications(p INT)
BEGIN
	DELETE FROM publicaciones WHERE professorId=p;
END //
DELIMITER ;

CALL pDeletePublications(2);


/*
5. Cree una consulta que devuelva el nombre del grado, el nombre de la asignatura, el número de créditos
de la asignatura y su tipo, para todas las asignaturas que pertenecen a todos los grados. Ordene los
resultados por el nombre del grado
*/
SELECT D.name, S.name, S.credits, S.`type`
FROM degrees D
JOIN subjects S ON(D.degreeId=S.degreeId)
ORDER BY 1; 


-- 6. Cree una consulta que devuelva las tutorías con al menos una cita.
SELECT T.tutoringHoursId
FROM tutoringhours T
NATURAL JOIN appointments A;


/*
 7. Cree una consulta que devuelva la carga media en créditos de docencia del profesor cuyo ID=1. Un
ejemplo de resultado de esta consulta es el siguiente
*/
SELECT AVG(credits) avgCreditsProfessor1
FROM teachingloads
WHERE professorId=1;


/*
8. Cree una consulta que devuelva el nombre y los apellidos de los dos estudiantes con mayor nota media,
sus notas medias, y su nota más baja.
*/
SELECT firstName, surname, AVG(VALUE) avgGrade, MIN(VALUE) minGrade
FROM grades 
NATURAL JOIN students
GROUP BY studentId
ORDER BY avgGrade DESC
LIMIT 2;


/*
9. Cree una consulta que devuelva el nombre y los apellidos del estudiante que ha sacado la nota
más alta del grupo con ID=10.
*/
SELECT s.firstName, s.surname
FROM grades g
NATURAL JOIN students s
WHERE g.groupId=10 AND g.value = ALL (SELECT MAX(VALUE) 
													FROM grades 
													WHERE groupId=10);
													
	-- Otra forma
SELECT s.firstName, s.surname
FROM grades g
NATURAL JOIN students s
WHERE g.groupId=10 AND g.value >= ALL (SELECT VALUE 
													FROM grades 
													WHERE groupId=10);
																		
	-- Otra forma
SELECT s.firstName, s.surname
FROM grades g
NATURAL JOIN students s
WHERE g.groupId=10
ORDER BY g.value DESC
LIMIT 1;


