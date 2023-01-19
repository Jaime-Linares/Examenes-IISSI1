USE jailinbar_tipo;

-- 1. Ejecute el script SQL proporcionado y, para asegurar que todo es correcto, ejecute la consulta 
-- SELECT count(*) FROM Atracciones; Compruebe que el resultado devuelto es 9.
SELECT count(*) FROM atracciones;


-- 2.Se requiere añadir el requisito de información Viajes de las atracciones. De cada viaje habrá que almacenar la atracción en cuestión, 
-- la fecha y hora del viaje, el número de personas que participan en el viaje, el número de personas que acceden con bono exprés en cada viaje.
-- Hay que tener en cuenta las siguientes restricciones:
-- - La atracción debe existir en la tabla de atracciones.
-- - La fecha y hora no puede ser nula.
-- - En cada viaje, el número máximo de personas que pueden acceder con bono exprés es 5
DROP TABLE if EXISTS viajesAtracciones;

CREATE TABLE viajesAtracciones(
viajesAtraccionId INT AUTO_INCREMENT PRIMARY KEY,
atraccionId MEDIUMINT NOT NULL,
fechayhora DATETIME NOT NULL,
numPersonas INT,
numPersonasBono INT,
FOREIGN KEY (atraccionId) REFERENCES atracciones(atraccionId) ON DELETE CASCADE,
CONSTRAINT verificaBonoExpres CHECK (numPersonasBono<= 5)
);


-- 3. Cree y ejecute un procedimiento almacenado llamado creaViajes() que 
-- inserte cuatro viajes: uno en Anaconda, otro en Caída Libre y dos viajes en el Látigo, durante el día 24 de diciembre de 2021.
DELIMITER //
CREATE OR REPLACE PROCEDURE creaViajes(atraccId MEDIUMINT)
BEGIN
	DECLARE fecha DATETIME;
	SET fecha = '2021-12-24 12:00:00';
	INSERT INTO viajesatracciones VALUES
	(NULL, atraccId, fecha, 10, 3);
END //
DELIMITER ;

CALL creaViajes(1);
CALL creaViajes(2);
CALL creaViajes(4);
CALL creaViajes(4);


-- 4. Cree una consulta que devuelva el número de viajes que ha dado cada atracción
SELECT nombre, COUNT(*)
FROM atracciones 
NATURAL JOIN viajesatracciones
GROUP BY nombre;


-- 5. Cree una consulta que devuelva el número de atracciones que hay en cada zona del parque
SELECT zona, COUNT(*)
FROM atracciones 
GROUP BY zona;


-- 6. Implemente la restricción que impida que durante un viaje se supere la capacidad de una atracción determinada
DELIMITER //
CREATE OR REPLACE TRIGGER noSupera
BEFORE INSERT ON viajesatracciones FOR EACH ROW
BEGIN
	DECLARE capacidadMax INT;
	SELECT capacidadMaxima INTO capacidadMax FROM atracciones WHERE atraccionId=NEW.atraccionId;
	IF(NEW.numPersonas > capacidadMax) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
		'No puede haber mas personas en un viaje que su capacidad maxima.';
	END IF;
END //
DELIMITER ;

