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
    Review_Text TEXT,
    Rating INT,
    Recommended_IND TINYINT,
    Positive_Feedback_Count INT,
    Division_Name VARCHAR(100),
    Department_Name VARCHAR(100),
    Class_Name VARCHAR(100)
);

# Importar CSV
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\feedback.csv'
INTO TABLE feedback
FIELDS TERMINATED BY ';'
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
(SELECT Transaction_ID, Clothing_ID, Age, Title, Review_Text, Rating, Recommended_IND, Positive_Feedback_Count, Division_Name, Department_Name, Class_Name FROM feedback)
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\feedback_limpio.csv'
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n';
