-- ===============================================
-- COMPARACIÓN SIMPLE DE TIEMPO - SOLO RESULTADOS CLAROS
-- ===============================================

-- Activar profiling
SET profiling = 1;

-- CONSULTA ORIGINAL (sin optimización)
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

-- CONSULTA OPTIMIZADA (con cache)
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

/*
    El tiempo de la query sin optimizar es de 1.739 segundos
    El tiempo de la query optimizada es de 0.0850 segundos
    Hay una mejora de más de 20 veces en el tiempo de ejecución
*/

-- -- Ver solo los tiempos (los últimos 2 queries)
-- SELECT 
--     CASE 
--         WHEN Query_ID = (SELECT MAX(Query_ID)-1 FROM INFORMATION_SCHEMA.PROFILING) THEN 'ORIGINAL'
--         WHEN Query_ID = (SELECT MAX(Query_ID) FROM INFORMATION_SCHEMA.PROFILING) THEN 'OPTIMIZADA'
--     END AS tipo_consulta,
--     ROUND(Duration, 4) AS tiempo_segundos
-- FROM INFORMATION_SCHEMA.PROFILING 
-- WHERE Query_ID >= (SELECT MAX(Query_ID)-1 FROM INFORMATION_SCHEMA.PROFILING)
-- ORDER BY Query_ID;