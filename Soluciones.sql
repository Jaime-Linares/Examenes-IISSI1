USE jailinbar_turnosmñn;


/*
1. Ejecute el script SQL proporcionado y para asegurar que todo es correcto y ejecute 
la consulta SELECT count(*) FROM Camareros;. Compruebe que el resultado devuelto es 4.
*/
SELECT count(*) FROM camareros;


/*
2. Se requiere añadir el requisito de información Bajas. Suponga que un Camarero puede tener varias Bajas. 
Para cada Baja se requiere guardar la siguiente información:
▪ El tipo de baja del que se trata (puede ser ‘Permanente’ o ‘Temporal’)
▪ Fecha inicio de la baja (por defecto será la fecha actual).
▪ Fecha fin de baja.
▪ Fecha en la que se ha aceptado la baja (se considerará no aceptada mientras tenga valor nulo).
Hay que tener en cuenta las siguientes restricciones adicionales:
- El tipo de baja no tiene en cuenta las mayúsculas o minúsculas. Esto quiere decir que es 
	válido tanto ‘permanente’ como ‘PERMANENTE’. 0.5
- Las bajas deben borrarse del sistema cuando un camarero es eliminado. 0.5
- La fecha de inicio debe ser anterior a la fecha de finalización. Además, la fecha de inicio debe ser 
	posterior o igual a la fecha de aceptación 0.5
*/
DROP TABLE IF EXISTS Bajas;

CREATE TABLE Bajas(
	idBajas INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	tipo ENUM ('Permanente', 'Temporal'), -- collate utf8_general_ci,
	fechaInicio DATE DEFAULT(DATE(SYSDATE())),
	fechaFinal DATE,
	fechaAceptacion DATE,
	idCamarero INT NOT NULL,
	FOREIGN KEY (idCamarero) REFERENCES camareros(idCamarero) ON DELETE CASCADE,
	CONSTRAINT fechasInvalidad CHECK ((fechaInicio < fechaFinal) AND (fechaInicio >= fechaAceptacion))
);


/*
3. Cree y ejecute (tantas veces como sea necesario) un procedimiento almacenado llamado insertarBaja() 
que, recibiendo los valores como parámetros, inserte las siguientes bajas
*/
DELIMITER //
CREATE OR REPLACE PROCEDURE insertarBaja(t VARCHAR(90), fi DATE, ff DATE, fa DATE, idC INT)
BEGIN
	INSERT INTO bajas(tipo, fechaInicio, fechaFinal, fechaAceptacion, idCamarero) VALUE
	(t, fi, ff, fa, idC);
END //
DELIMITER ;

CALL insertarBaja('TEMPORAl', '2022-12-10', '2022-12-12', '2022-12-04', 2);
CALL insertarBaja('Permanente', '2023-01-01', NULL, '2022-12-15', 2);
CALL insertarBaja('TEmPoral', '2022-12-01', '2023-03-01', '2022-11-22', 3);


/*
4. Cree una consulta que devuelva la ratio de Camareros hombres. La ratio se calcula dividiendo
el número de camareros de dicho sexo entre el número total de camareros
*/
SELECT ((SELECT COUNT(*) FROM camareros WHERE sexo='H')/COUNT(*)) ratio
FROM camareros;

/*
5. Cree una consulta que devuelva los Camareros, sus Turnos y sus Bajas. Los Camareros
deben aparecer, aunque no tengan Bajas. Un ejemplo de resultado de esta consulta es el
siguiente
*/
SELECT *
FROM camareros c
LEFT JOIN bajas b ON (c.idCamarero=b.idCamarero)
LEFT JOIN turnos t ON (c.idCamarero=t.idCamarero);


/*
6. Cree una consulta que devuelva el identificador, nombre y apellidos de los Camareros que
nunca han solicitado una baja. Un ejemplo de resultado de esta consulta es el siguiente
*/
SELECT idCamarero, CONCAT(nombre, ' ', apellidos) nombreapellidos
FROM camareros  
EXCEPT
SELECT idCamarero, CONCAT(nombre, ' ', apellidos) nombreapellidos
FROM camareros
NATURAL JOIN bajas;

	-- Otra forma
SELECT c.idCamarero, CONCAT(c.nombre, ' ', c.apellidos) nombreapellidos
FROM camareros  c
WHERE NOT EXISTS (SELECT c.idCamarero, CONCAT(c.nombre, ' ', c.apellidos) nombreapellidos
						FROM bajas b
						WHERE c.idCamarero=b.idCamarero);


-- 7. Cree una función que, dado un idCamarero, devuelva el número de turnos que tiene asignados
DELIMITER //
CREATE OR REPLACE FUNCTION fNumTurnos(idC INT) RETURNS INT 
BEGIN
	RETURN(
		SELECT COUNT(*)
		FROM turnos
		WHERE idCamarero=idC
	);
END //
DELIMITER ;

SELECT idCamarero, fNumTurnos(idCamarero) FROM camareros;


-- 8. Implemente la restricción que no permita que un camarero tenga más de 5 turnos.
DELIMITER //
CREATE OR REPLACE TRIGGER tTurnosCamarero
BEFORE INSERT ON turnos FOR EACH ROW
BEGIN
	DECLARE numTurnos INT;
	SET numTurnos = (SELECT COUNT(*) FROM turnos WHERE idCamarero=NEW.idCamarero);
	if(numTurnos>4) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
		'Un camarero no puede tener mas de 5 turnos';
	END if;
END //
DELIMITER ;



