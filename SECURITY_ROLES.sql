--10. Security roles and access demo.

-- 1. ADMIN ROLE - Full access
CREATE USER IF NOT EXISTS 'hospital_admin'@'localhost' IDENTIFIED BY 'Admin@2025';
GRANT ALL PRIVILEGES ON dba_hospital_db.* TO 'hospital_admin'@'localhost';

-- 2. DOCTOR ROLE - Read patient data, appointments, update appointments
CREATE USER IF NOT EXISTS 'hospital_doctor'@'localhost' IDENTIFIED BY 'Doctor@2025';
GRANT SELECT ON dba_hospital_db.Patients TO 'hospital_doctor'@'localhost';
GRANT SELECT ON dba_hospital_db.Appointments TO 'hospital_doctor'@'localhost';
GRANT SELECT, UPDATE ON dba_hospital_db.Appointments TO 'hospital_doctor'@'localhost';
GRANT SELECT ON dba_hospital_db.Billing TO 'hospital_doctor'@'localhost';
GRANT SELECT ON dba_hospital_db.Treatments TO 'hospital_doctor'@'localhost';
GRANT SELECT ON dba_hospital_db.Doctors TO 'hospital_doctor'@'localhost';
GRANT SELECT ON dba_hospital_db.Departments TO 'hospital_doctor'@'localhost';
GRANT EXECUTE ON PROCEDURE dba_hospital_db.query_GetDailyPatientsByDoctor TO 'hospital_doctor'@'localhost';

-- 3. CLERK ROLE - Manage billing, patient registration
CREATE USER IF NOT EXISTS 'hospital_clerk'@'localhost' IDENTIFIED BY 'Clerk@2025';
GRANT SELECT, INSERT, UPDATE ON dba_hospital_db.Patients TO 'hospital_clerk'@'localhost';
GRANT SELECT, INSERT, UPDATE ON dba_hospital_db.Appointments TO 'hospital_clerk'@'localhost';
GRANT SELECT, INSERT, UPDATE ON dba_hospital_db.Billing TO 'hospital_clerk'@'localhost';
GRANT SELECT ON dba_hospital_db.Doctors TO 'hospital_clerk'@'localhost';
GRANT SELECT ON dba_hospital_db.Departments TO 'hospital_clerk'@'localhost';
GRANT SELECT ON dba_hospital_db.Treatments TO 'hospital_clerk'@'localhost';
GRANT EXECUTE ON PROCEDURE dba_hospital_db.crud_RegisterPatient TO 'hospital_clerk'@'localhost';
GRANT EXECUTE ON PROCEDURE dba_hospital_db.crud_UpdatePatient TO 'hospital_clerk'@'localhost';
GRANT EXECUTE ON PROCEDURE dba_hospital_db.crud_AssignDoctor TO 'hospital_clerk'@'localhost';
GRANT EXECUTE ON PROCEDURE dba_hospital_db.sp_GenerateBilling TO 'hospital_clerk'@'localhost';
GRANT EXECUTE ON PROCEDURE dba_hospital_db.subquery_GetUnpaidBalances TO 'hospital_clerk'@'localhost';

-- Apply privileges
FLUSH PRIVILEGES;