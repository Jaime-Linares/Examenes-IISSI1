CREATE OR REPLACE DATABASE jailinbar_tipo;
USE jailinbar_tipo;

CREATE TABLE atracciones (
atraccionId mediumint AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(50) UNIQUE, 
capacidadMaxima INT NOT NULL,
zona VARCHAR(30), 
estaturaMin INT NOT NULL, 
CONSTRAINT zonasParque CHECK (zona IN ('Tanzania', 'Plateado','Katmandu','Cascada','Orilla','Carbonera'))
);


INSERT INTO atracciones (nombre, capacidadMaxima,zona,estaturaMin) VALUES
('Anaconda',85,'Plateado',145),
('Caida Libre',85,'Katmandu',150),
('Rapidos del Orinoco',34,'Tanzania',100),
('Latigo',65,'Katmandu',100),
('Nepal',65,'Katmandu',100),
('Lluvia',25,'Cascada',100),
('Copos',36,'Cascada',100),
('La noche',42,'Katmandu',100),
('Embarcadero',16,'Katmandu',120);