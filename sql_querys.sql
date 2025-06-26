/*     Consultas SQL para la fase 2 del proyecto Base de datos      */

-- Consulta 1 --
-- Todos los pacientes que se atendieron durante el mes de abril y que recibieron receta
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

-- Consulta 2
-- Todos los pacientes femeninos que tengan previsión fonasa, sean de valparaíso y se atendieron con DANIEL HERNAN ARANEDA
-- SELECT DISTINCT p.*
-- FROM paciente p
-- INNER JOIN control_medico cm ON p.rut_paciente = cm.rut_paciente
-- INNER JOIN profesionalmedico pm ON cm.rut_profesionalmedico = pm.rut_profesionalmedico
-- INNER JOIN sexo s ON p.idsexo = s.idsexo
-- INNER JOIN prevision pr ON p.idprevision = pr.idprevision
-- INNER JOIN comuna c ON p.cod_comuna = c.cod_comuna
-- WHERE s.idsexo = 2
--  AND pr.nombre_prevision = 'Fonasa'
--  AND c.nombre_comuna = 'Valparaíso'
--  AND pm.rut_profesionalmedico = 17235988
--  AND pm.dig_rut = 7
-- INTO OUTFILE '/var/lib/mysql-files/consulta2.csv'
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n';

-- Consulta 3
-- Todos los profesionales médicos especialidad Neurología que han atendido a más de 6 pacientes en el mes de abril
SELECT pm.*, COUNT(DISTINCT cm.rut_paciente) as total_pacientes
FROM profesionalmedico pm
INNER JOIN control_medico cm ON pm.rut_profesionalmedico = cm.rut_profesionalmedico
WHERE pm.especialidad = 'Neurología'
 AND MONTH(cm.fecha_asistencia) = 4
 AND cm.fecha_asistencia IS NOT NULL
GROUP BY pm.rut_profesionalmedico
HAVING COUNT(DISTINCT cm.rut_paciente) > 6
INTO OUTFILE '/var/lib/mysql-files/consulta3.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';