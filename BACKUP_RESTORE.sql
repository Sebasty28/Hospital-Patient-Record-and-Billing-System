--9. Backup/Restore simulation.

-- Backup table for Patients
CREATE TABLE IF NOT EXISTS PatientsBackup (
    PatientID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender CHAR(1),
    ContactNumber VARCHAR(20) NOT NULL,
    Email VARCHAR(100),
    Address VARCHAR(200),
    EmergencyContact VARCHAR(100),
    EmergencyPhone VARCHAR(20),
    BloodGroup VARCHAR(5),
    Allergies VARCHAR(500),
    RegistrationDate DATETIME,
    IsActive BIT,
    BackupDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Backup table for Doctors
CREATE TABLE IF NOT EXISTS DoctorsBackup (
    DoctorID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Specialization VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    LicenseNumber VARCHAR(50) NOT NULL,
    ContactNumber VARCHAR(20),
    Email VARCHAR(100) NOT NULL,
    HireDate DATE NOT NULL,
    IsActive BIT,
    BackupDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Backup table for Appointments
CREATE TABLE IF NOT EXISTS AppointmentsBackup (
    AppointmentID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATETIME NOT NULL,
    AppointmentType VARCHAR(50) NOT NULL,
    Status VARCHAR(20),
    ReasonForVisit VARCHAR(500),
    Diagnosis VARCHAR(1000),
    Prescription VARCHAR(1000),
    Notes VARCHAR(1000),
    BackupDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Backup table for Billing
CREATE TABLE IF NOT EXISTS BillingBackup (
    BillingID INT PRIMARY KEY,
    AppointmentID INT NOT NULL,
    TreatmentID INT NOT NULL,
    Quantity INT,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Discount DECIMAL(5,2),
    TaxRate DECIMAL(5,2),
    TotalAmount DECIMAL(10,2) NOT NULL,
    PaymentStatus VARCHAR(20),
    PaymentDate DATETIME,
    PaymentMethod VARCHAR(50),
    InsuranceClaimNumber VARCHAR(100),
    BackupDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Backup table for Treatments
CREATE TABLE IF NOT EXISTS TreatmentsBackup (
    TreatmentID INT PRIMARY KEY,
    TreatmentName VARCHAR(200) NOT NULL,
    TreatmentCode VARCHAR(20) NOT NULL,
    Description VARCHAR(500),
    StandardCost DECIMAL(10,2) NOT NULL,
    DepartmentID INT,
    IsActive BIT,
    BackupDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Backup table for Departments
CREATE TABLE IF NOT EXISTS DepartmentsBackup (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    DepartmentHead VARCHAR(100),
    ContactNumber VARCHAR(20),
    BackupDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$
CREATE PROCEDURE bkp_FullDatabaseBackup()
BEGIN
    -- Clear existing backup data
    TRUNCATE TABLE PatientsBackup;
    TRUNCATE TABLE DoctorsBackup;
    TRUNCATE TABLE AppointmentsBackup;
    TRUNCATE TABLE BillingBackup;
    TRUNCATE TABLE TreatmentsBackup;
    TRUNCATE TABLE DepartmentsBackup;
    
    -- Backup Departments
    INSERT INTO DepartmentsBackup (DepartmentID, DepartmentName, DepartmentHead, ContactNumber)
    SELECT DepartmentID, DepartmentName, DepartmentHead, ContactNumber
    FROM Departments;
    
    -- Backup Patients
    INSERT INTO PatientsBackup (PatientID, FirstName, LastName, DateOfBirth, Gender, 
                                ContactNumber, Email, Address, EmergencyContact, 
                                EmergencyPhone, BloodGroup, Allergies, RegistrationDate, IsActive)
    SELECT PatientID, FirstName, LastName, DateOfBirth, Gender, 
           ContactNumber, Email, Address, EmergencyContact, 
           EmergencyPhone, BloodGroup, Allergies, RegistrationDate, IsActive
    FROM Patients;
    
    -- Backup Doctors
    INSERT INTO DoctorsBackup (DoctorID, FirstName, LastName, Specialization, DepartmentID, 
                               LicenseNumber, ContactNumber, Email, HireDate, IsActive)
    SELECT DoctorID, FirstName, LastName, Specialization, DepartmentID, 
           LicenseNumber, ContactNumber, Email, HireDate, IsActive
    FROM Doctors;
    
    -- Backup Treatments
    INSERT INTO TreatmentsBackup (TreatmentID, TreatmentName, TreatmentCode, Description, 
                                  StandardCost, DepartmentID, IsActive)
    SELECT TreatmentID, TreatmentName, TreatmentCode, Description, 
           StandardCost, DepartmentID, IsActive
    FROM Treatments;
    
    -- Backup Appointments
    INSERT INTO AppointmentsBackup (AppointmentID, PatientID, DoctorID, AppointmentDate, 
                                    AppointmentType, Status, ReasonForVisit, Diagnosis, 
                                    Prescription, Notes)
    SELECT AppointmentID, PatientID, DoctorID, AppointmentDate, 
           AppointmentType, Status, ReasonForVisit, Diagnosis, 
           Prescription, Notes
    FROM Appointments;
    
    -- Backup Billing
    INSERT INTO BillingBackup (BillingID, AppointmentID, TreatmentID, Quantity, UnitPrice, 
                               Discount, TaxRate, TotalAmount, PaymentStatus, PaymentDate, 
                               PaymentMethod, InsuranceClaimNumber)
    SELECT BillingID, AppointmentID, TreatmentID, Quantity, UnitPrice, 
           Discount, TaxRate, TotalAmount, PaymentStatus, PaymentDate, 
           PaymentMethod, InsuranceClaimNumber
    FROM Billing;
    
    -- Report backup statistics
    SELECT 'Backup Completed Successfully' AS Status,
           (SELECT COUNT(*) FROM DepartmentsBackup) AS Departments,
           (SELECT COUNT(*) FROM PatientsBackup) AS Patients,
           (SELECT COUNT(*) FROM DoctorsBackup) AS Doctors,
           (SELECT COUNT(*) FROM TreatmentsBackup) AS Treatments,
           (SELECT COUNT(*) FROM AppointmentsBackup) AS Appointments,
           (SELECT COUNT(*) FROM BillingBackup) AS BillingRecords,
           NOW() AS BackupTimestamp;
END $$
DELIMITER ;

--Test Script:
CALL bkp_FullDatabaseBackup();

DELIMITER $$
CREATE PROCEDURE sp_CheckBackupStatus()
BEGIN
    SELECT 
        'PatientsBackup' AS BackupTable,
        COUNT(*) AS RecordCount,
        MAX(BackupDate) AS LastBackupDate
    FROM PatientsBackup
    UNION ALL
    SELECT 
        'DoctorsBackup',
        COUNT(*),
        MAX(BackupDate)
    FROM DoctorsBackup
    UNION ALL
    SELECT 
        'AppointmentsBackup',
        COUNT(*),
        MAX(BackupDate)
    FROM AppointmentsBackup
    UNION ALL
    SELECT 
        'BillingBackup',
        COUNT(*),
        MAX(BackupDate)
    FROM BillingBackup;
END $$
DELIMITER ;

--Test Script:
CALL bkp_CheckBackupStatus();

DELIMITER $$
CREATE PROCEDURE bkp_RestoreFromBackup(IN p_TableName VARCHAR(50))
BEGIN
    DECLARE v_Message VARCHAR(200);
    
    CASE p_TableName
        WHEN 'Patients' THEN
            DELETE FROM Patients;
            INSERT INTO Patients (PatientID, FirstName, LastName, DateOfBirth, Gender, 
                                 ContactNumber, Email, Address, EmergencyContact, 
                                 EmergencyPhone, BloodGroup, Allergies, RegistrationDate, IsActive)
            SELECT PatientID, FirstName, LastName, DateOfBirth, Gender, 
                   ContactNumber, Email, Address, EmergencyContact, 
                   EmergencyPhone, BloodGroup, Allergies, RegistrationDate, IsActive
            FROM PatientsBackup;
            SET v_Message = CONCAT('Restored ', ROW_COUNT(), ' patient records');
            
        WHEN 'Doctors' THEN
            DELETE FROM Doctors;
            INSERT INTO Doctors (DoctorID, FirstName, LastName, Specialization, DepartmentID, 
                                LicenseNumber, ContactNumber, Email, HireDate, IsActive)
            SELECT DoctorID, FirstName, LastName, Specialization, DepartmentID, 
                   LicenseNumber, ContactNumber, Email, HireDate, IsActive
            FROM DoctorsBackup;
            SET v_Message = CONCAT('Restored ', ROW_COUNT(), ' doctor records');
            
        WHEN 'Appointments' THEN
            DELETE FROM Appointments;
            INSERT INTO Appointments (AppointmentID, PatientID, DoctorID, AppointmentDate, 
                                     AppointmentType, Status, ReasonForVisit, Diagnosis, 
                                     Prescription, Notes)
            SELECT AppointmentID, PatientID, DoctorID, AppointmentDate, 
                   AppointmentType, Status, ReasonForVisit, Diagnosis, 
                   Prescription, Notes
            FROM AppointmentsBackup;
            SET v_Message = CONCAT('Restored ', ROW_COUNT(), ' appointment records');
            
        WHEN 'Billing' THEN
            DELETE FROM Billing;
            INSERT INTO Billing (BillingID, AppointmentID, TreatmentID, Quantity, UnitPrice, 
                                Discount, TaxRate, TotalAmount, PaymentStatus, PaymentDate, 
                                PaymentMethod, InsuranceClaimNumber)
            SELECT BillingID, AppointmentID, TreatmentID, Quantity, UnitPrice, 
                   Discount, TaxRate, TotalAmount, PaymentStatus, PaymentDate, 
                   PaymentMethod, InsuranceClaimNumber
            FROM BillingBackup;
            SET v_Message = CONCAT('Restored ', ROW_COUNT(), ' billing records');
            
        ELSE
            SET v_Message = 'Invalid table name. Use: Patients, Doctors, Appointments, or Billing';
    END CASE;
    
    SELECT v_Message AS RestoreStatus, NOW() AS RestoreTimestamp;
END $$
DELIMITER ;

--Test Script:
CALL bkp_RestoreFromBackup('Patients');