-- 1. CREACIÓN DE ÍNDICES PARA OPTIMIZACIÓN
-- Índice compuesto en control_medico para fecha_asistencia e idreceta
CREATE INDEX idx_control_medico_fecha_receta ON control_medico(fecha_asistencia, idreceta);

-- Índice en receta para idreceta (clave primaria si no existe)
CREATE INDEX idx_receta_id ON receta(idreceta);

-- Índice en receta_medicamento para las claves foráneas
CREATE INDEX idx_receta_medicamento_receta ON receta_medicamento(receta_idreceta);
CREATE INDEX idx_receta_medicamento_medicamento ON receta_medicamento(medicamento_idmedicamento);

-- Índice en medicamento para idmedicamento (clave primaria si no existe)
CREATE INDEX idx_medicamento_id ON medicamento(idmedicamento);

-- 2. CREACIÓN DE VISTA MATERIALIZADA (MySQL no soporta vistas materializadas nativas, 
-- pero podemos crear una tabla temporal que se actualice periódicamente)
CREATE TABLE medicamentos_por_anio_cache AS
SELECT 
    YEAR(cm.fecha_asistencia) AS anio,
    m.idmedicamento,
    m.nombre,
    COUNT(*) AS total_recetas
FROM medicamento m
INNER JOIN receta_medicamento rm ON m.idmedicamento = rm.medicamento_idmedicamento
INNER JOIN receta r ON rm.receta_idreceta = r.idreceta
INNER JOIN control_medico cm ON r.idreceta = cm.idreceta
WHERE cm.fecha_asistencia IS NOT NULL
GROUP BY YEAR(cm.fecha_asistencia), m.idmedicamento, m.nombre;

-- Índice en la tabla cache
CREATE INDEX idx_cache_anio_total ON medicamentos_por_anio_cache(anio, total_recetas DESC);

-- 3. CONSULTA OPTIMIZADA USANDO LA TABLA CACHE
SELECT anio, nombre, total_recetas
FROM (
    SELECT 
        anio,
        nombre,
        total_recetas,
        ROW_NUMBER() OVER (PARTITION BY anio ORDER BY total_recetas DESC) AS rn
    FROM medicamentos_por_anio_cache
) ranked
WHERE rn = 1
ORDER BY anio;

DELIMITER //
CREATE PROCEDURE ActualizarCacheMedicamentos()
BEGIN
    TRUNCATE TABLE medicamentos_por_anio_cache;
    
    INSERT INTO medicamentos_por_anio_cache
    SELECT 
        YEAR(cm.fecha_asistencia) AS anio,
        m.idmedicamento,
        m.nombre,
        COUNT(*) AS total_recetas
    FROM medicamento m
    INNER JOIN receta_medicamento rm ON m.idmedicamento = rm.medicamento_idmedicamento
    INNER JOIN receta r ON rm.receta_idreceta = r.idreceta
    INNER JOIN control_medico cm ON r.idreceta = cm.idreceta
    WHERE cm.fecha_asistencia IS NOT NULL
    GROUP BY YEAR(cm.fecha_asistencia), m.idmedicamento, m.nombre;
END //
DELIMITER ;

-- 5. PARTICIONAMIENTO DE TABLA control_medico POR AÑO (si es posible)
-- Nota: Esto requeriría recrear la tabla con particiones
/*
ALTER TABLE control_medico 
PARTITION BY RANGE (YEAR(fecha_asistencia)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
*/

-- 6. CONSULTA ORIGINAL OPTIMIZADA CON HINTS
SELECT anio, nombre, total_recetas
FROM (
    SELECT 
        YEAR(cm.fecha_asistencia) AS anio,
        m.nombre,
        COUNT(*) AS total_recetas,
        ROW_NUMBER() OVER (PARTITION BY YEAR(cm.fecha_asistencia) ORDER BY COUNT(*) DESC) AS rn
    FROM medicamento m
    INNER JOIN receta_medicamento rm ON m.idmedicamento = rm.medicamento_idmedicamento
    INNER JOIN receta r ON rm.receta_idreceta = r.idreceta
    INNER JOIN control_medico cm ON r.idreceta = cm.idreceta
    WHERE cm.fecha_asistencia IS NOT NULL
    GROUP BY YEAR(cm.fecha_asistencia), m.idmedicamento, m.nombre
) ranked
WHERE rn = 1
ORDER BY anio;