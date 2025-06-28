/*     Consultas SQL para la fase 2 del proyecto Base de datos      */

/*
-- Consulta 1 --
-- Todos los pacientes que se atendieron durante el mes de abril y que recibieron receta
*/
-- SELECT DISTINCT p.*
-- FROM paciente p
-- INNER JOIN control_medico cm ON p.rut_paciente = cm.rut_paciente
-- INNER JOIN receta r ON cm.idreceta = r.idreceta
-- WHERE MONTH(cm.fecha_asistencia) = 4 
--  AND cm.fecha_asistencia IS NOT NULL
-- INTO OUTFILE '/var/lib/mysql-files/consulta1.csv'
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n';

/*
-- Consulta 2
-- Todos los pacientes femeninos que tengan previsión fonasa y se atendieron con DANIEL HERNAN ARANEDA
*/
-- SELECT DISTINCT p.*
-- FROM paciente p
-- INNER JOIN control_medico cm ON p.rut_paciente = cm.rut_paciente
-- INNER JOIN profesionalmedico pm ON cm.rut_profesionalmedico = pm.rut_profesionalmedico
-- INNER JOIN sexo s ON p.idsexo = s.idsexo
-- INNER JOIN prevision pr ON p.idprevision = pr.idprevision
-- WHERE s.idsexo = 2
--  AND pr.nombre_prevision = 'Fonasa'
--  AND pm.rut_profesionalmedico = 17235988
--  AND pm.dig_rut = 7
-- INTO OUTFILE '/var/lib/mysql-files/consulta2.csv'
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n';

/*
-- Consulta 3
-- Total de controles efectuados por cada año en el que se tenga registros
*/

SELECT YEAR(fecha_asistencia) AS año, COUNT(*) AS total_controles
FROM control_medico
WHERE fecha_asistencia IS NOT NULL
GROUP BY YEAR(fecha_asistencia)
ORDER BY año
INTO OUTFILE '/var/lib/mysql-files/consulta3_pacientes.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

/*
-- Consulta 4
-- Controles agendados vs controles efectuados por cada año
*/
SELECT 
    YEAR(fecha_agendada) AS año,
    COUNT(*) AS controles_registrados,
    COUNT(fecha_asistencia) AS controles_efectuados,
    COUNT(*) - COUNT(fecha_asistencia) AS diferencia
FROM control_medico
WHERE fecha_agendada IS NOT NULL
GROUP BY YEAR(fecha_agendada)
ORDER BY año;
-- INTO OUTFILE '/var/lib/mysql-files/consulta4.csv'
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n';

/*
-- Consulta 5
-- Listar los nombres del medicamento más recetado por cada año
*/
SELECT año, nombre, total_recetas
FROM (
    SELECT 
        YEAR(cm.fecha_asistencia) AS año,
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
ORDER BY año;
-- INTO OUTFILE '/var/lib/mysql-files/consulta5.csv'
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n';
