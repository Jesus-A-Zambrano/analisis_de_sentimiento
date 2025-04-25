# Crear database
CREATE DATABASE IF NOT EXISTS feedback_db;
USE feedback_db;

# Crear tabla
DROP TABLE IF EXISTS feedback;
CREATE TABLE feedback (
    Transaction_ID INT,
    Clothing_ID INT,
    Age INT,
    Title VARCHAR(255),
    Review_Text MEDIUMTEXT,
    Rating INT,
    Recommended_IND TINYINT,
    Positive_Feedback_Count INT,
    Division_Name VARCHAR(100),
    Department_Name VARCHAR(100),
    Class_Name VARCHAR(100)
);

# Importar CSV
LOAD DATA INFILE 'E:\\manager\\XAMPP\\mysql\\data\\feedback_db\\feedback.csv'
INTO TABLE feedback
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

# Limpiar saltos de línea (\n, \r, \r\n) en Review_Text
UPDATE feedback
SET Review_Text = REPLACE(REPLACE(REPLACE(Review_Text, '\r\n', ' '), '\r', ' '), '\n', ' ');


# Eliminar filas sin Review_Text
DELETE FROM feedback
WHERE Review_Text IS NULL OR TRIM(Review_Text) = '';


# Eliminar registros inválidos
DELETE FROM feedback WHERE Age IS NULL OR Age < 10 OR Age > 100;
DELETE FROM feedback WHERE Rating IS NULL OR Rating < 1 OR Rating > 5;
DELETE FROM feedback WHERE Transaction_ID IS NULL OR Clothing_ID IS NULL;


# Optimizar tipos
ALTER TABLE feedback MODIFY COLUMN Recommended_IND BOOLEAN;
ALTER TABLE feedback MODIFY COLUMN Age TINYINT UNSIGNED;
ALTER TABLE feedback MODIFY COLUMN Rating TINYINT UNSIGNED;
ALTER TABLE feedback MODIFY COLUMN Positive_Feedback_Count INT UNSIGNED;


# Reemplazar Transaction_ID con nuevos valores secuenciales
SET @new_id = 100000; -- O el número base que desees
UPDATE feedback SET Transaction_ID = (@new_id := @new_id + 1);


# Crear índices
CREATE INDEX idx_transaction ON feedback (Transaction_ID);
CREATE INDEX idx_clothing ON feedback (Clothing_ID);
CREATE INDEX idx_rating ON feedback (Rating);

# Exportar datos limpios
(SELECT 'Transaction_ID','Clothing_ID','Age','Title','Review_Text','Rating','Recommended_IND','Positive_Feedback_Count','Division_Name','Department_Name','Class_Name')
UNION ALL
(SELECT * FROM feedback)


INTO OUTFILE 'E:\\manager\\XAMPP\\mysql\\data\\feedback_db\\feedback_limpio.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n';



/* 
22-04-25


	#cambio en del punto y coma por coma en la division de campos debido a incompatibilidad con los campos de dataset

FIELDS TERMINATED BY ';' // reemplazado por // FIELDS TERMINATED BY ','



	#se elimino la clausala por incompatibilidad al momento de mostrar las casillas,

(SELECT 'Transaction_ID','Clothing_ID','Age','Title','Review_Text','Rating','Recommended_IND','Positive_Feedback_Count','Division_Name','Department_Name','Class_Name')
UNION ALL

fue reemplazado para debug por: (SELECT * FROM feedback) el cual entrega los datos filtrados sin problemas.




	# Informe de errores y Diagnosticos

-Error_1 :Los simbolos dentro de las cadenas de texto provocan desplazamiendo de filas

	Diagnostico_1:Al correr el script sin tratar los simbolos ocasiona un desplazamiento de mas de 120 filas corrompiendo las filas de la columna "rating"  y Recommended_IND


	Diagnostico_2:Al remplazar los simbolos por espacios y luego eliminarlos con TRIM reduce la cantidad de filas desplazadas a 6 filas, las cuales 3 de ellas se sospecha
se deben al uso de comillas dobles ("), y las otras no son concluyentes, son desplazos despues de una sola palabra y sin simbolos o factores aparentes que influyan en la fila


	Diagnostico_3:Se realizó un tratamiento en el datase delimitando todas las filas dentro de comillas dobles (") para, en teoria, impedir el desplazamiento

de filas por "Review_text" teniendo en cuenta # ENCLOSED BY '"' # el resultado fue un desplazamiento caotico de las filas



	Diagnostico_4:Se realizó una limpieza de formato al datase para purgar posibles errores de formatos en las casillas, sin resultados ni cambios notables


	Diagnostico_5:Se realizo una serie de pruebas mediante la filtracion de valores empleando REGEXP para la detección e eliminación de valores
no numericos dentro de "rating" y "Recommended_IND". sin resultados, los valores provenientes de "Review_text" desplazan las filas, pero MySQL no detecta sus
valores, por lo tanto no pueden ser filtrados directamente de la fila afectada

	

-Notas: no se ha probado otra forma de manipulación en review_text, como alternativa a no eliminar los simbolos de podria aplicar una

columna fantasma adyacente a review_text para que no desplace los valores de Rating, en consecuencia, tendrian que trabajarse los valores

de review_text para su proximo uso en el modelo como: review_text_1 y review_text2 respectivamente, sin perder ningun tipo de dato que contengan las reseñas


Resultado Final: limpieza del dataset y delimitacion de todas las filas y columnas en comillas dobles.

*\
