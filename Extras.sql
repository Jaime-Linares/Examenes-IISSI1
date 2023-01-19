USE jailinbar_tipo;

-- 7. Dime aquellas atracciones en las que no se ha montado nadie
SELECT nombre 
FROM atracciones a1
WHERE NOT EXISTS(
SELECT nombre
FROM viajesatracciones 
NATURAL JOIN atracciones a2 WHERE a1.atraccionId=a2.atraccionId);

	-- Otra forma
SELECT a.nombre
FROM atracciones a
WHERE NOT EXISTS(
	SELECT a.nombre
	FROM viajesatracciones v
	WHERE v.atraccionId = a.atraccionId);


-- 8. Trigger que no te deja tener 50 bonos express en un dia para una atraccion
DELIMITER //
CREATE OR REPLACE TRIGGER numBonosDiarios
BEFORE INSERT ON viajesatracciones FOR EACH ROW
BEGIN
	DECLARE fecha DATE;
	DECLARE sumaAntes INT;
	DECLARE sumaFinal INT;
	SET fecha = DATE(NEW.fechayhora);
	SELECT SUM(numPersonasBono) INTO sumaAntes FROM viajesatracciones WHERE ((atraccionId=NEW.atraccionId) AND (DATE(fechayhora)=fecha));
	SET sumaFinal = sumaAntes + NEW.numPersonasBono;
	IF(sumaFinal>50) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
		'No puedes';
	END IF;
END //
DELIMITER ;


-- 9. Media de personas que usan bono en todas las atracciones
SELECT SUM(numPersonasBono)/SUM(numPersonas) ratioUsoBonos
FROM viajesatracciones;


-- 10. Dia que mas personas han ido al parque
DELIMITER //
CREATE OR REPLACE FUNCTION diaMasPersonas() RETURNS DATE
BEGIN
	DECLARE personasMax INT;
	SELECT SUM(numPersonas) INTO personasMax
	FROM viajesAtracciones
	GROUP BY DATE(fechayhora)
	ORDER BY 1 DESC
	LIMIT 1;
	RETURN(
		SELECT DATE(fechayhora)
		FROM viajesAtracciones
		GROUP BY DATE(fechayhora)
		HAVING SUM(numPersonas)=personasMax	
	);
END //
DELIMITER ;

SELECT diaMasPersonas();

	-- Otra forma
DELIMITER //
CREATE OR REPLACE FUNCTION diaMasPersonas2() RETURNS DATE
BEGIN
	RETURN(
		SELECT DATE(fechayhora)
		FROM viajesatracciones
		GROUP BY DATE(fechayhora)
		HAVING SUM(numPersonas) >= ALL(
			SELECT SUM(numPersonas) 
			FROM viajesatracciones
			GROUP BY DATE(fechayhora))															
	);
END //
DELIMITER ;

SELECT diaMasPersonas2();

