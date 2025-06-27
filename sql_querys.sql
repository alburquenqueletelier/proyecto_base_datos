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
-- Todos los pacientes que se han atendido con todos los doctores
*/--,COUNT(DISTINCT cm.rut_paciente) as total_pacientes

SELECT pm.* 
FROM profesionalmedico pm
INNER JOIN control_medico cm ON pm.rut_profesionalmedico = cm.rut_profesionalmedico
WHERE pm.especialidad COLLATE utf8_general_ci = 'Neurología'
 AND YEAR(cm.fecha_asistencia) = 2022
 AND cm.fecha_asistencia IS NOT NULL
GROUP BY pm.rut_profesionalmedico
HAVING COUNT(DISTINCT cm.rut_paciente) > 1
INTO OUTFILE '/var/lib/mysql-files/consulta3.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

/*
-- Consulta 4
-- Listar nombre y apellido de todos los doctores que han entregado más licencias que el promedio de licencias durante el año 2024
*/
-- SELECT pm.nombres, pm.ap_paterno, COUNT(l.folio) as total_licencias
-- FROM profesionalmedico pm
-- INNER JOIN control_medico cm ON pm.rut_profesionalmedico = cm.rut_profesionalmedico
-- INNER JOIN licencia l ON cm.licencia_folio = l.folio
-- WHERE YEAR(cm.fecha_asistencia) = 2024
--  AND cm.fecha_asistencia IS NOT NULL
-- GROUP BY pm.rut_profesionalmedico, pm.nombres, pm.ap_paterno
-- HAVING COUNT(l.folio) > (
--    SELECT AVG(licencias_por_doctor)
--    FROM (
--        SELECT COUNT(l2.folio) as licencias_por_doctor
--        FROM profesionalmedico pm2
--        INNER JOIN control_medico cm2 ON pm2.rut_profesionalmedico = cm2.rut_profesionalmedico
--        INNER JOIN licencia l2 ON cm2.licencia_folio = l2.folio
--        WHERE cm2.fecha_asistencia IS NOT NULL
--        GROUP BY pm2.rut_profesionalmedico
--    ) as subconsulta
-- )
-- INTO OUTFILE '/var/lib/mysql-files/consulta4.csv'
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n';

/*
-- Consulta 5
-- Listar todos los pacientes que han tenido licencia medica el 2025
*/
-- SELECT DISTINCT * 
-- FROM paciente p
-- INNER JOIN control_medico cm ON p.rut_paciente = cm.rut_paciente
-- INNER JOIN licencia l ON cm.licencia_folio = l.folio
-- WHERE YEAR(cm.fecha_asistencia) = 2025
-- INTO OUTFILE '/var/lib/mysql-files/consulta5.csv'
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n';
