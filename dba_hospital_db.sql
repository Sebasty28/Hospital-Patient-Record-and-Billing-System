-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jan 07, 2026 at 12:41 PM
-- Server version: 9.1.0
-- PHP Version: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dba_hospital_db`
--

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `bkp_CheckBackupStatus`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `bkp_CheckBackupStatus` ()   BEGIN
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
END$$

DROP PROCEDURE IF EXISTS `bkp_FullDatabaseBackup`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `bkp_FullDatabaseBackup` ()   BEGIN
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
END$$

DROP PROCEDURE IF EXISTS `bkp_RestoreFromBackup`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `bkp_RestoreFromBackup` (IN `p_TableName` VARCHAR(50))   BEGIN
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
END$$

DROP PROCEDURE IF EXISTS `crud_AssignDoctor`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `crud_AssignDoctor` (IN `p_AppointmentID` INT, IN `p_PatientID` INT, IN `p_DoctorID` INT, IN `p_AppointmentDate` DATETIME, IN `p_AppointmentType` VARCHAR(50), IN `p_ReasonForVisit` VARCHAR(500))   BEGIN
    INSERT INTO Appointments (AppointmentID, PatientID, DoctorID, AppointmentDate, 
                             AppointmentType, Status, ReasonForVisit)
    VALUES (p_AppointmentID, p_PatientID, p_DoctorID, p_AppointmentDate, 
            p_AppointmentType, 'Scheduled', p_ReasonForVisit);
    
    SELECT 'Appointment scheduled successfully' AS Message, p_AppointmentID AS AppointmentID;
END$$

DROP PROCEDURE IF EXISTS `crud_DeactivatePatient`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `crud_DeactivatePatient` (IN `p_PatientID` INT)   BEGIN
    UPDATE Patients 
    SET IsActive = 0
    WHERE PatientID = p_PatientID;
    
    SELECT 'Patient deactivated successfully' AS Message;
END$$

DROP PROCEDURE IF EXISTS `crud_RegisterPatient`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `crud_RegisterPatient` (IN `p_PatientID` INT, IN `p_FirstName` VARCHAR(50), IN `p_LastName` VARCHAR(50), IN `p_DateOfBirth` DATE, IN `p_Gender` CHAR(1), IN `p_ContactNumber` VARCHAR(20), IN `p_Email` VARCHAR(100), IN `p_Address` VARCHAR(200), IN `p_EmergencyContact` VARCHAR(100), IN `p_EmergencyPhone` VARCHAR(20), IN `p_BloodGroup` VARCHAR(5), IN `p_Allergies` VARCHAR(500))   BEGIN
    INSERT INTO Patients (PatientID, FirstName, LastName, DateOfBirth, Gender, ContactNumber, 
                         Email, Address, EmergencyContact, EmergencyPhone, BloodGroup, Allergies)
    VALUES (p_PatientID, p_FirstName, p_LastName, p_DateOfBirth, p_Gender, p_ContactNumber,
            p_Email, p_Address, p_EmergencyContact, p_EmergencyPhone, p_BloodGroup, p_Allergies);
    
    SELECT 'Patient registered successfully' AS Message, p_PatientID AS PatientID;
END$$

DROP PROCEDURE IF EXISTS `crud_UpdatePatient`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `crud_UpdatePatient` (IN `p_PatientID` INT, IN `p_ContactNumber` VARCHAR(20), IN `p_Email` VARCHAR(100), IN `p_Address` VARCHAR(200), IN `p_EmergencyContact` VARCHAR(100), IN `p_EmergencyPhone` VARCHAR(20))   BEGIN
    UPDATE Patients 
    SET ContactNumber = p_ContactNumber,
        Email = p_Email,
        Address = p_Address,
        EmergencyContact = p_EmergencyContact,
        EmergencyPhone = p_EmergencyPhone
    WHERE PatientID = p_PatientID;
    
    SELECT 'Patient information updated successfully' AS Message;
END$$

DROP PROCEDURE IF EXISTS `query_GetDailyPatientsByDoctor`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `query_GetDailyPatientsByDoctor` (IN `p_DoctorID` INT, IN `p_Date` DATE)   BEGIN
    SELECT 
        a.AppointmentID,
        a.AppointmentDate,
        CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
        p.ContactNumber,
        a.AppointmentType,
        a.Status,
        a.ReasonForVisit,
        CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName
    FROM Appointments a
    JOIN Patients p ON a.PatientID = p.PatientID
    JOIN Doctors d ON a.DoctorID = d.DoctorID
    WHERE a.DoctorID = p_DoctorID
    AND DATE(a.AppointmentDate) = p_Date
    ORDER BY a.AppointmentDate;
END$$

DROP PROCEDURE IF EXISTS `query_GetRevenueByDepartment`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `query_GetRevenueByDepartment` (IN `p_StartDate` DATE, IN `p_EndDate` DATE)   BEGIN
    SELECT 
        COALESCE(dep.DepartmentName, 'General/Multiple') AS Department,
        COUNT(DISTINCT b.BillingID) AS TotalBills,
        SUM(b.TotalAmount) AS TotalRevenue,
        AVG(b.TotalAmount) AS AverageRevenue,
        SUM(CASE WHEN b.PaymentStatus = 'Paid' THEN b.TotalAmount ELSE 0 END) AS PaidAmount,
        SUM(CASE WHEN b.PaymentStatus = 'Unpaid' THEN b.TotalAmount ELSE 0 END) AS UnpaidAmount
    FROM Billing b
    JOIN Appointments a ON b.AppointmentID = a.AppointmentID
    JOIN Treatments t ON b.TreatmentID = t.TreatmentID
    LEFT JOIN Departments dep ON t.DepartmentID = dep.DepartmentID
    WHERE DATE(a.AppointmentDate) BETWEEN p_StartDate AND p_EndDate
    GROUP BY dep.DepartmentName
    ORDER BY TotalRevenue DESC;
END$$

DROP PROCEDURE IF EXISTS `sp_GenerateBilling`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GenerateBilling` (IN `p_BillingID` INT, IN `p_AppointmentID` INT, IN `p_TreatmentID` INT, IN `p_Quantity` INT, IN `p_Discount` DECIMAL(5,2), IN `p_TaxRate` DECIMAL(5,2), IN `p_PaymentMethod` VARCHAR(50), IN `p_InsuranceClaimNumber` VARCHAR(100))   BEGIN
    DECLARE v_UnitPrice DECIMAL(10,2);
    DECLARE v_SubTotal DECIMAL(10,2);
    DECLARE v_DiscountAmount DECIMAL(10,2);
    DECLARE v_TaxAmount DECIMAL(10,2);
    DECLARE v_TotalAmount DECIMAL(10,2);
    
    -- Get unit price from Treatments table
    SELECT StandardCost INTO v_UnitPrice
    FROM Treatments
    WHERE TreatmentID = p_TreatmentID;
    
    -- Calculate totals
    SET v_SubTotal = v_UnitPrice * p_Quantity;
    SET v_DiscountAmount = v_SubTotal * (p_Discount / 100);
    SET v_SubTotal = v_SubTotal - v_DiscountAmount;
    SET v_TaxAmount = v_SubTotal * (p_TaxRate / 100);
    SET v_TotalAmount = v_SubTotal + v_TaxAmount;
    
    -- Insert billing record
    INSERT INTO Billing (BillingID, AppointmentID, TreatmentID, Quantity, UnitPrice, 
                        Discount, TaxRate, TotalAmount, PaymentStatus, PaymentMethod, 
                        InsuranceClaimNumber)
    VALUES (p_BillingID, p_AppointmentID, p_TreatmentID, p_Quantity, v_UnitPrice,
            p_Discount, p_TaxRate, v_TotalAmount, 'Unpaid', p_PaymentMethod, 
            p_InsuranceClaimNumber);
    
    SELECT 'Billing generated successfully' AS Message, 
           v_TotalAmount AS TotalAmount,
           p_BillingID AS BillingID;
END$$

DROP PROCEDURE IF EXISTS `subquery_GetUnpaidBalances`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `subquery_GetUnpaidBalances` ()   BEGIN
    SELECT 
        p.PatientID,
        CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
        p.ContactNumber,
        p.Email,
        (SELECT SUM(b.TotalAmount) 
         FROM Billing b
         JOIN Appointments a ON b.AppointmentID = a.AppointmentID
         WHERE a.PatientID = p.PatientID 
         AND b.PaymentStatus = 'Unpaid') AS UnpaidBalance,
        (SELECT COUNT(*) 
         FROM Billing b
         JOIN Appointments a ON b.AppointmentID = a.AppointmentID
         WHERE a.PatientID = p.PatientID 
         AND b.PaymentStatus = 'Unpaid') AS UnpaidBills
    FROM Patients p
    WHERE EXISTS (
        SELECT 1 
        FROM Billing b
        JOIN Appointments a ON b.AppointmentID = a.AppointmentID
        WHERE a.PatientID = p.PatientID 
        AND b.PaymentStatus = 'Unpaid'
    )
    ORDER BY UnpaidBalance DESC;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
CREATE TABLE IF NOT EXISTS `appointments` (
  `AppointmentID` int NOT NULL,
  `PatientID` int NOT NULL,
  `DoctorID` int NOT NULL,
  `AppointmentDate` datetime NOT NULL,
  `AppointmentType` varchar(50) NOT NULL,
  `Status` varchar(20) DEFAULT 'Scheduled',
  `ReasonForVisit` varchar(500) DEFAULT NULL,
  `Diagnosis` varchar(1000) DEFAULT NULL,
  `Prescription` varchar(1000) DEFAULT NULL,
  `Notes` varchar(1000) DEFAULT NULL,
  `CreatedDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `ModifiedDate` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`AppointmentID`),
  KEY `PatientID` (`PatientID`),
  KEY `DoctorID` (`DoctorID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `appointments`
--

INSERT INTO `appointments` (`AppointmentID`, `PatientID`, `DoctorID`, `AppointmentDate`, `AppointmentType`, `Status`, `ReasonForVisit`, `Diagnosis`, `Prescription`, `Notes`, `CreatedDate`, `ModifiedDate`) VALUES
(3007, 1007, 101, '2025-01-07 10:00:00', 'Follow-up', 'Scheduled', 'Heart palpitations', NULL, NULL, 'Stress test scheduled', '2026-01-07 18:28:00', '2026-01-07 18:28:00'),
(3006, 1006, 102, '2025-01-06 15:30:00', 'Consultation', 'Completed', 'Memory issues', 'Mild cognitive impairment', 'Donepezil 5mg', 'MRI scheduled', '2026-01-07 18:28:00', '2026-01-07 18:28:00'),
(3005, 1005, 105, '2025-01-06 11:00:00', 'Emergency', 'Completed', 'Severe headache', 'Migraine', 'Sumatriptan 50mg', 'ER visit', '2026-01-07 18:28:00', '2026-01-07 18:28:00'),
(3004, 1004, 104, '2025-01-06 09:30:00', 'Consultation', 'Completed', 'Vaccination', 'Healthy', 'N/A', 'Next vaccine due in 6 months', '2026-01-07 18:28:00', '2026-01-07 18:28:00'),
(3003, 1003, 103, '2025-01-05 14:00:00', 'Consultation', 'Completed', 'Knee pain', 'Osteoarthritis', 'Ibuprofen 400mg', 'Physical therapy recommended', '2026-01-07 18:28:00', '2026-01-07 18:28:00'),
(3002, 1002, 104, '2025-01-05 10:30:00', 'Follow-up', 'Completed', 'Routine checkup', 'Healthy', 'Vitamins', 'Annual visit', '2026-01-07 18:28:00', '2026-01-07 18:28:00'),
(3001, 1001, 101, '2025-01-05 09:00:00', 'Consultation', 'Completed', 'Chest pain', 'Angina', 'Aspirin 81mg daily', 'Follow up in 2 weeks', '2026-01-07 18:28:00', '2026-01-07 18:28:00'),
(3008, 1008, 107, '2025-01-07 13:00:00', 'Consultation', 'Scheduled', 'Back pain', NULL, NULL, 'Imaging required', '2026-01-07 18:28:00', '2026-01-07 18:28:00'),
(3009, 1001, 106, '2025-01-08 09:00:00', 'Follow-up', 'Scheduled', 'Post-surgery checkup', NULL, NULL, NULL, '2026-01-07 18:28:00', '2026-01-07 18:28:00'),
(3010, 1003, 103, '2025-01-08 14:00:00', 'Follow-up', 'Scheduled', 'Physical therapy evaluation', NULL, NULL, NULL, '2026-01-07 18:28:00', '2026-01-07 18:28:00'),
(3011, 1009, 101, '2025-01-10 14:00:00', 'Consultation', 'Scheduled', 'Routine checkup', NULL, NULL, NULL, '2026-01-07 18:38:34', '2026-01-07 18:38:34');

-- --------------------------------------------------------

--
-- Table structure for table `appointmentsbackup`
--

DROP TABLE IF EXISTS `appointmentsbackup`;
CREATE TABLE IF NOT EXISTS `appointmentsbackup` (
  `AppointmentID` int NOT NULL,
  `PatientID` int NOT NULL,
  `DoctorID` int NOT NULL,
  `AppointmentDate` datetime NOT NULL,
  `AppointmentType` varchar(50) NOT NULL,
  `Status` varchar(20) DEFAULT NULL,
  `ReasonForVisit` varchar(500) DEFAULT NULL,
  `Diagnosis` varchar(1000) DEFAULT NULL,
  `Prescription` varchar(1000) DEFAULT NULL,
  `Notes` varchar(1000) DEFAULT NULL,
  `BackupDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`AppointmentID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `appointmentsbackup`
--

INSERT INTO `appointmentsbackup` (`AppointmentID`, `PatientID`, `DoctorID`, `AppointmentDate`, `AppointmentType`, `Status`, `ReasonForVisit`, `Diagnosis`, `Prescription`, `Notes`, `BackupDate`) VALUES
(3007, 1007, 101, '2025-01-07 10:00:00', 'Follow-up', 'Scheduled', 'Heart palpitations', NULL, NULL, 'Stress test scheduled', '2026-01-07 19:31:29'),
(3006, 1006, 102, '2025-01-06 15:30:00', 'Consultation', 'Completed', 'Memory issues', 'Mild cognitive impairment', 'Donepezil 5mg', 'MRI scheduled', '2026-01-07 19:31:29'),
(3005, 1005, 105, '2025-01-06 11:00:00', 'Emergency', 'Completed', 'Severe headache', 'Migraine', 'Sumatriptan 50mg', 'ER visit', '2026-01-07 19:31:29'),
(3004, 1004, 104, '2025-01-06 09:30:00', 'Consultation', 'Completed', 'Vaccination', 'Healthy', 'N/A', 'Next vaccine due in 6 months', '2026-01-07 19:31:29'),
(3003, 1003, 103, '2025-01-05 14:00:00', 'Consultation', 'Completed', 'Knee pain', 'Osteoarthritis', 'Ibuprofen 400mg', 'Physical therapy recommended', '2026-01-07 19:31:29'),
(3002, 1002, 104, '2025-01-05 10:30:00', 'Follow-up', 'Completed', 'Routine checkup', 'Healthy', 'Vitamins', 'Annual visit', '2026-01-07 19:31:29'),
(3001, 1001, 101, '2025-01-05 09:00:00', 'Consultation', 'Completed', 'Chest pain', 'Angina', 'Aspirin 81mg daily', 'Follow up in 2 weeks', '2026-01-07 19:31:29'),
(3008, 1008, 107, '2025-01-07 13:00:00', 'Consultation', 'Scheduled', 'Back pain', NULL, NULL, 'Imaging required', '2026-01-07 19:31:29'),
(3009, 1001, 106, '2025-01-08 09:00:00', 'Follow-up', 'Scheduled', 'Post-surgery checkup', NULL, NULL, NULL, '2026-01-07 19:31:29'),
(3010, 1003, 103, '2025-01-08 14:00:00', 'Follow-up', 'Scheduled', 'Physical therapy evaluation', NULL, NULL, NULL, '2026-01-07 19:31:29'),
(3011, 1009, 101, '2025-01-10 14:00:00', 'Consultation', 'Scheduled', 'Routine checkup', NULL, NULL, NULL, '2026-01-07 19:31:29');

-- --------------------------------------------------------

--
-- Table structure for table `billing`
--

DROP TABLE IF EXISTS `billing`;
CREATE TABLE IF NOT EXISTS `billing` (
  `BillingID` int NOT NULL,
  `AppointmentID` int NOT NULL,
  `TreatmentID` int NOT NULL,
  `Quantity` int DEFAULT '1',
  `UnitPrice` decimal(10,2) NOT NULL,
  `Discount` decimal(5,2) DEFAULT '0.00',
  `TaxRate` decimal(5,2) DEFAULT '0.00',
  `TotalAmount` decimal(10,2) NOT NULL,
  `PaymentStatus` varchar(20) DEFAULT 'Unpaid',
  `PaymentDate` datetime DEFAULT NULL,
  `PaymentMethod` varchar(50) DEFAULT NULL,
  `InsuranceClaimNumber` varchar(100) DEFAULT NULL,
  `CreatedDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `ModifiedDate` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`BillingID`),
  UNIQUE KEY `InsuranceClaimNumber` (`InsuranceClaimNumber`),
  KEY `AppointmentID` (`AppointmentID`),
  KEY `TreatmentID` (`TreatmentID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `billing`
--

INSERT INTO `billing` (`BillingID`, `AppointmentID`, `TreatmentID`, `Quantity`, `UnitPrice`, `Discount`, `TaxRate`, `TotalAmount`, `PaymentStatus`, `PaymentDate`, `PaymentMethod`, `InsuranceClaimNumber`, `CreatedDate`, `ModifiedDate`) VALUES
(4018, 3005, 2008, 1, 3500.00, 0.00, 12.00, 3920.00, 'Paid', NULL, 'Insurance\r', NULL, '2026-01-07 19:50:09', '2026-01-07 19:50:09'),
(4008, 3006, 2001, 1, 500.00, 0.00, 12.00, 560.00, 'Unpaid', NULL, NULL, NULL, '2026-01-07 18:29:10', '2026-01-07 18:29:10'),
(4007, 3005, 2005, 1, 600.00, 0.00, 12.00, 672.00, 'Unpaid', NULL, NULL, NULL, '2026-01-07 18:29:10', '2026-01-07 18:29:10'),
(4005, 3003, 2004, 1, 1200.00, 0.00, 12.00, 1344.00, 'Paid', '2025-01-05 15:00:00', 'Cash', NULL, '2026-01-07 18:29:10', '2026-01-07 18:29:10'),
(4006, 3004, 2007, 1, 800.00, 0.00, 12.00, 896.00, 'Paid', '2025-01-06 10:00:00', 'Insurance', 'INS-2025-002', '2026-01-07 18:29:10', '2026-01-07 18:29:10'),
(4004, 3003, 2001, 1, 500.00, 0.00, 12.00, 560.00, 'Paid', '2025-01-05 15:00:00', 'Cash', NULL, '2026-01-07 18:29:10', '2026-01-07 18:29:10'),
(4003, 3002, 2001, 1, 500.00, 50.00, 12.00, 504.00, 'Paid', '2025-01-05 11:30:00', 'Card', NULL, '2026-01-07 18:29:10', '2026-01-07 18:29:10'),
(4002, 3001, 2002, 1, 1500.00, 0.00, 12.00, 1680.00, 'Paid', '2025-01-05 10:00:00', 'Insurance', 'INS-2025-003', '2026-01-07 18:29:10', '2026-01-07 19:06:24'),
(4001, 3001, 2001, 1, 500.00, 0.00, 12.00, 560.00, 'Paid', '2025-01-05 10:00:00', 'Insurance', 'INS-2025-001', '2026-01-07 18:29:10', '2026-01-07 18:29:10'),
(4017, 3008, 2004, 1, 1200.00, 0.00, 12.00, 1344.00, 'Unpaid', NULL, 'Card\r', NULL, '2026-01-07 19:50:09', '2026-01-07 19:50:09'),
(4016, 3007, 2010, 1, 4500.00, 0.00, 8.00, 4860.00, 'Unpaid', NULL, 'Cash\r', NULL, '2026-01-07 19:50:09', '2026-01-07 19:50:09');

--
-- Triggers `billing`
--
DROP TRIGGER IF EXISTS `trg_BillingAudit_Delete`;
DELIMITER $$
CREATE TRIGGER `trg_BillingAudit_Delete` BEFORE DELETE ON `billing` FOR EACH ROW BEGIN
    INSERT INTO BillingAudit (BillingID, ActionType, OldTotalAmount, NewTotalAmount,
                             OldPaymentStatus, NewPaymentStatus, ModifiedBy)
    VALUES (OLD.BillingID, 'DELETE', OLD.TotalAmount, NULL,
            OLD.PaymentStatus, NULL, USER());
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_BillingAudit_Update`;
DELIMITER $$
CREATE TRIGGER `trg_BillingAudit_Update` AFTER UPDATE ON `billing` FOR EACH ROW BEGIN
    IF OLD.TotalAmount <> NEW.TotalAmount
       OR OLD.PaymentStatus <> NEW.PaymentStatus THEN

        INSERT INTO BillingAudit
        (BillingID, ActionType, OldTotalAmount, NewTotalAmount,
         OldPaymentStatus, NewPaymentStatus, ModifiedBy)
        VALUES
        (OLD.BillingID, 'UPDATE',
         OLD.TotalAmount, NEW.TotalAmount,
         OLD.PaymentStatus, NEW.PaymentStatus,
         USER());
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `billingaudit`
--

DROP TABLE IF EXISTS `billingaudit`;
CREATE TABLE IF NOT EXISTS `billingaudit` (
  `AuditID` int NOT NULL AUTO_INCREMENT,
  `BillingID` int NOT NULL,
  `ActionType` varchar(10) NOT NULL,
  `OldTotalAmount` decimal(10,2) DEFAULT NULL,
  `NewTotalAmount` decimal(10,2) DEFAULT NULL,
  `OldPaymentStatus` varchar(20) DEFAULT NULL,
  `NewPaymentStatus` varchar(20) DEFAULT NULL,
  `ModifiedBy` varchar(100) DEFAULT NULL,
  `ModifiedDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`AuditID`)
) ENGINE=MyISAM AUTO_INCREMENT=80 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `billingaudit`
--

INSERT INTO `billingaudit` (`AuditID`, `BillingID`, `ActionType`, `OldTotalAmount`, `NewTotalAmount`, `OldPaymentStatus`, `NewPaymentStatus`, `ModifiedBy`, `ModifiedDate`) VALUES
(79, 4018, 'DELETE', 3920.00, NULL, 'Paid', NULL, 'root@localhost', '2026-01-07 19:49:24'),
(78, 4017, 'DELETE', 1344.00, NULL, 'Unpaid', NULL, 'root@localhost', '2026-01-07 19:49:24'),
(77, 4016, 'DELETE', 4860.00, NULL, 'Unpaid', NULL, 'root@localhost', '2026-01-07 19:49:24'),
(76, 4009, 'DELETE', 5040.00, NULL, 'Paid', NULL, 'root@localhost', '2026-01-07 19:15:50'),
(75, 4009, 'UPDATE', 5040.00, 5040.00, 'Unpaid', 'Paid', 'root@localhost', '2026-01-07 19:13:22'),
(74, 4009, 'DELETE', 20160.00, NULL, 'Paid', NULL, 'root@localhost', '2026-01-07 19:11:41');

-- --------------------------------------------------------

--
-- Table structure for table `billingbackup`
--

DROP TABLE IF EXISTS `billingbackup`;
CREATE TABLE IF NOT EXISTS `billingbackup` (
  `BillingID` int NOT NULL,
  `AppointmentID` int NOT NULL,
  `TreatmentID` int NOT NULL,
  `Quantity` int DEFAULT NULL,
  `UnitPrice` decimal(10,2) NOT NULL,
  `Discount` decimal(5,2) DEFAULT NULL,
  `TaxRate` decimal(5,2) DEFAULT NULL,
  `TotalAmount` decimal(10,2) NOT NULL,
  `PaymentStatus` varchar(20) DEFAULT NULL,
  `PaymentDate` datetime DEFAULT NULL,
  `PaymentMethod` varchar(50) DEFAULT NULL,
  `InsuranceClaimNumber` varchar(100) DEFAULT NULL,
  `BackupDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`BillingID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `billingbackup`
--

INSERT INTO `billingbackup` (`BillingID`, `AppointmentID`, `TreatmentID`, `Quantity`, `UnitPrice`, `Discount`, `TaxRate`, `TotalAmount`, `PaymentStatus`, `PaymentDate`, `PaymentMethod`, `InsuranceClaimNumber`, `BackupDate`) VALUES
(4008, 3006, 2001, 1, 500.00, 0.00, 12.00, 560.00, 'Unpaid', NULL, NULL, NULL, '2026-01-07 19:31:29'),
(4007, 3005, 2005, 1, 600.00, 0.00, 12.00, 672.00, 'Unpaid', NULL, NULL, NULL, '2026-01-07 19:31:29'),
(4005, 3003, 2004, 1, 1200.00, 0.00, 12.00, 1344.00, 'Paid', '2025-01-05 15:00:00', 'Cash', NULL, '2026-01-07 19:31:29'),
(4006, 3004, 2007, 1, 800.00, 0.00, 12.00, 896.00, 'Paid', '2025-01-06 10:00:00', 'Insurance', 'INS-2025-002', '2026-01-07 19:31:29'),
(4004, 3003, 2001, 1, 500.00, 0.00, 12.00, 560.00, 'Paid', '2025-01-05 15:00:00', 'Cash', NULL, '2026-01-07 19:31:29'),
(4003, 3002, 2001, 1, 500.00, 50.00, 12.00, 504.00, 'Paid', '2025-01-05 11:30:00', 'Card', NULL, '2026-01-07 19:31:29'),
(4002, 3001, 2002, 1, 1500.00, 0.00, 12.00, 1680.00, 'Paid', '2025-01-05 10:00:00', 'Insurance', 'INS-2025-003', '2026-01-07 19:31:29'),
(4001, 3001, 2001, 1, 500.00, 0.00, 12.00, 560.00, 'Paid', '2025-01-05 10:00:00', 'Insurance', 'INS-2025-001', '2026-01-07 19:31:29');

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
CREATE TABLE IF NOT EXISTS `departments` (
  `DepartmentID` int NOT NULL AUTO_INCREMENT,
  `DepartmentName` varchar(100) NOT NULL,
  `DepartmentHead` varchar(100) DEFAULT NULL,
  `ContactNumber` varchar(20) DEFAULT NULL,
  `CreatedDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `ModifiedDate` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`DepartmentID`),
  UNIQUE KEY `DepartmentName` (`DepartmentName`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`DepartmentID`, `DepartmentName`, `DepartmentHead`, `ContactNumber`, `CreatedDate`, `ModifiedDate`) VALUES
(6, 'Radiology', 'Dr. Peter Parker', '0908-257-9148', '2026-01-07 18:14:25', '2026-01-07 18:14:25'),
(5, 'Emergency Medicine', 'Dr. Scott Lang', '0975-493-8062', '2026-01-07 18:14:25', '2026-01-07 18:14:25'),
(4, 'Pediatrics', 'Dr. Tony Stark', '0998-165-7420', '2026-01-07 18:14:25', '2026-01-07 18:14:25'),
(3, 'Orthopedics', 'Dr. Thor Odinson', '0926-804-5173', '2026-01-07 18:14:25', '2026-01-07 18:14:25'),
(2, 'Neurology', 'Dr. Natasha Romanoff', '0905-731-2846', '2026-01-07 18:14:25', '2026-01-07 18:14:25'),
(1, 'Cardiology', 'Dr. Steve Rogers', '0917-482-6391', '2026-01-07 18:14:25', '2026-01-07 18:14:25');

-- --------------------------------------------------------

--
-- Table structure for table `departmentsbackup`
--

DROP TABLE IF EXISTS `departmentsbackup`;
CREATE TABLE IF NOT EXISTS `departmentsbackup` (
  `DepartmentID` int NOT NULL,
  `DepartmentName` varchar(100) NOT NULL,
  `DepartmentHead` varchar(100) DEFAULT NULL,
  `ContactNumber` varchar(20) DEFAULT NULL,
  `BackupDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`DepartmentID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `departmentsbackup`
--

INSERT INTO `departmentsbackup` (`DepartmentID`, `DepartmentName`, `DepartmentHead`, `ContactNumber`, `BackupDate`) VALUES
(6, 'Radiology', 'Dr. Peter Parker', '0908-257-9148', '2026-01-07 19:31:29'),
(5, 'Emergency Medicine', 'Dr. Scott Lang', '0975-493-8062', '2026-01-07 19:31:29'),
(4, 'Pediatrics', 'Dr. Tony Stark', '0998-165-7420', '2026-01-07 19:31:29'),
(3, 'Orthopedics', 'Dr. Thor Odinson', '0926-804-5173', '2026-01-07 19:31:29'),
(2, 'Neurology', 'Dr. Natasha Romanoff', '0905-731-2846', '2026-01-07 19:31:29'),
(1, 'Cardiology', 'Dr. Steve Rogers', '0917-482-6391', '2026-01-07 19:31:29');

-- --------------------------------------------------------

--
-- Table structure for table `doctors`
--

DROP TABLE IF EXISTS `doctors`;
CREATE TABLE IF NOT EXISTS `doctors` (
  `DoctorID` int NOT NULL,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `Specialization` varchar(100) NOT NULL,
  `DepartmentID` int NOT NULL,
  `LicenseNumber` varchar(50) NOT NULL,
  `ContactNumber` varchar(20) DEFAULT NULL,
  `Email` varchar(100) NOT NULL,
  `HireDate` date NOT NULL,
  `IsActive` bit(1) DEFAULT b'1',
  `CreatedDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `ModifiedDate` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`DoctorID`),
  UNIQUE KEY `LicenseNumber` (`LicenseNumber`),
  UNIQUE KEY `Email` (`Email`),
  KEY `DepartmentID` (`DepartmentID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `doctors`
--

INSERT INTO `doctors` (`DoctorID`, `FirstName`, `LastName`, `Specialization`, `DepartmentID`, `LicenseNumber`, `ContactNumber`, `Email`, `HireDate`, `IsActive`, `CreatedDate`, `ModifiedDate`) VALUES
(106, 'Sam', 'Wilson', 'Cardiologist', 1, 'LIC-CARD-006', '0917-100-1006', 'sam.wilson@hospital.com', '2021-04-12', b'1', '2026-01-07 19:41:59', '2026-01-07 19:41:59'),
(105, 'James', 'Rhodes', 'Emergency Physician', 5, 'LIC-EMER-005', '0917-100-1005', 'james.rhodes@hospital.com', '2016-11-30', b'1', '2026-01-07 19:41:59', '2026-01-07 19:41:59'),
(104, 'Wanda', 'Maximoff', 'Pediatrician', 4, 'LIC-PEDI-004', '0917-100-1004', 'wanda.maximoff@hospital.com', '2020-01-05', b'1', '2026-01-07 19:41:59', '2026-01-07 19:41:59'),
(103, 'Stephen', 'Strange', 'Orthopedic Surgeon', 3, 'LIC-ORTH-003', '0917-100-1003', 'stephen.strange@hospital.com', '2017-09-10', b'1', '2026-01-07 19:41:59', '2026-01-07 19:41:59'),
(102, 'Clint', 'Barton', 'Neurologist', 2, 'LIC-NEUR-002', '0917-100-1002', 'clint.barton@hospital.com', '2019-06-20', b'1', '2026-01-07 19:41:59', '2026-01-07 19:41:59'),
(101, 'Bruce', 'Banner', 'Cardiologist', 1, 'LIC-CARD-001', '0917-100-1001', 'bruce.banner@hospital.com', '2018-03-15', b'1', '2026-01-07 19:41:59', '2026-01-07 19:41:59'),
(107, 'Bucky', 'Barnes', 'Radiologist', 6, 'LIC-RADI-007', '0917-100-1007', 'bucky.barnes@hospital.com', '2019-08-22', b'1', '2026-01-07 19:41:59', '2026-01-07 19:41:59');

-- --------------------------------------------------------

--
-- Table structure for table `doctorsbackup`
--

DROP TABLE IF EXISTS `doctorsbackup`;
CREATE TABLE IF NOT EXISTS `doctorsbackup` (
  `DoctorID` int NOT NULL,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `Specialization` varchar(100) NOT NULL,
  `DepartmentID` int NOT NULL,
  `LicenseNumber` varchar(50) NOT NULL,
  `ContactNumber` varchar(20) DEFAULT NULL,
  `Email` varchar(100) NOT NULL,
  `HireDate` date NOT NULL,
  `IsActive` bit(1) DEFAULT NULL,
  `BackupDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`DoctorID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `doctorsbackup`
--

INSERT INTO `doctorsbackup` (`DoctorID`, `FirstName`, `LastName`, `Specialization`, `DepartmentID`, `LicenseNumber`, `ContactNumber`, `Email`, `HireDate`, `IsActive`, `BackupDate`) VALUES
(106, 'Sam', 'Wilson', 'Cardiologist', 1, 'LIC-CARD-006', '0917-100-1006', 'sam.wilson@hospital.com', '2021-04-12', b'1', '2026-01-07 19:31:29'),
(105, 'James', 'Rhodes', 'Emergency Physician', 5, 'LIC-EMER-005', '0917-100-1005', 'james.rhodes@hospital.com', '2016-11-30', b'1', '2026-01-07 19:31:29'),
(104, 'Wanda', 'Maximoff', 'Pediatrician', 4, 'LIC-PEDI-004', '0917-100-1004', 'wanda.maximoff@hospital.com', '2020-01-05', b'1', '2026-01-07 19:31:29'),
(103, 'Stephen', 'Strange', 'Orthopedic Surgeon', 3, 'LIC-ORTH-003', '0917-100-1003', 'stephen.strange@hospital.com', '2017-09-10', b'1', '2026-01-07 19:31:29'),
(102, 'Clint', 'Barton', 'Neurologist', 2, 'LIC-NEUR-002', '0917-100-1002', 'clint.barton@hospital.com', '2019-06-20', b'1', '2026-01-07 19:31:29'),
(101, 'Bruce', 'Banner', 'Cardiologist', 1, 'LIC-CARD-001', '0917-100-1001', 'bruce.banner@hospital.com', '2018-03-15', b'1', '2026-01-07 19:31:29'),
(107, 'Bucky', 'Barnes', 'Radiologist', 6, 'LIC-RADI-007', '0917-100-1007', 'bucky.barnes@hospital.com', '2019-08-22', b'1', '2026-01-07 19:31:29');

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

DROP TABLE IF EXISTS `patients`;
CREATE TABLE IF NOT EXISTS `patients` (
  `PatientID` int NOT NULL,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `DateOfBirth` date NOT NULL,
  `Gender` char(1) DEFAULT NULL,
  `ContactNumber` varchar(20) NOT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Address` varchar(200) DEFAULT NULL,
  `EmergencyContact` varchar(100) DEFAULT NULL,
  `EmergencyPhone` varchar(20) DEFAULT NULL,
  `BloodGroup` varchar(5) DEFAULT NULL,
  `Allergies` varchar(500) DEFAULT NULL,
  `RegistrationDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `IsActive` bit(1) DEFAULT b'1',
  `CreatedDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `ModifiedDate` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`PatientID`)
) ;

--
-- Dumping data for table `patients`
--

INSERT INTO `patients` (`PatientID`, `FirstName`, `LastName`, `DateOfBirth`, `Gender`, `ContactNumber`, `Email`, `Address`, `EmergencyContact`, `EmergencyPhone`, `BloodGroup`, `Allergies`, `RegistrationDate`, `IsActive`, `CreatedDate`, `ModifiedDate`) VALUES
(1009, 'Jose', 'Reyes', '1990-05-15', 'M', '0917-300-1009', 'jose.reyes@email.com', '111 Mabini St, Quezon City', 'Maria Reyes', '0918-300-2009', 'O+', 'None', '2026-01-07 18:33:21', b'0', '2026-01-07 18:33:21', '2026-01-07 18:40:35'),
(1007, 'William', 'Mendoza', '1995-02-05', 'M', '0916-233-9088', 'william.mendoza@email.com', '147 Degirogorgio St, Manila City', 'Maria Mendoza', '0917-664-1029', 'B-', 'None', '2025-09-22 13:35:00', b'1', '2025-09-22 13:35:00', '2025-09-22 13:35:00'),
(1008, 'Elizabeth', 'Flores', '1973-09-30', 'F', '0928-540-6712', 'elizabeth.flores@email.com', '258 Boulevard Ave, Makati City', 'Jose Flores', '0929-882-3310', 'AB-', 'Sulfa drugs', '2025-11-11 10:50:00', b'1', '2025-11-11 10:50:00', '2025-11-11 10:50:00'),
(1006, 'Jennifer', 'Garcia', '1988-11-17', 'F', '0975-412-8890', 'jennifer.garcia@email.com', '987 Cedar St, Sta. Rosa City', 'Carlos Garcia', '0976-701-3456', 'A-', 'Nuts', '2025-03-09 16:00:00', b'1', '2025-03-09 16:00:00', '2025-03-09 16:00:00'),
(1005, 'Miguel', 'Torres', '1965-07-28', 'M', '0908-645-2201', 'miguel.torres@email.com', '654 Maple St, San Pedro City', 'Linda Torres', '0909-557-9033', 'O-', 'Aspirin', '2026-01-03 11:10:00', b'1', '2026-01-03 11:10:00', '2026-01-03 11:10:00'),
(1004, 'Patricia', 'Cruz', '2010-03-10', 'F', '0998-301-7765', 'patricia.cruz@email.com', '321 Maple St, San Pedro City', 'George Cruz', '0999-884-1139', 'AB+', 'None', '2025-07-18 08:20:00', b'1', '2025-07-18 08:20:00', '2025-07-18 08:20:00'),
(1003, 'Roberto', 'Reyes', '1978-12-03', 'M', '0926-534-1198', 'roberto.reyes@email.com', '789 National Rd, Sta. Rosa City', 'Ana Reyes', '0927-667-4402', 'B+', 'Latex', '2025-04-20 14:45:00', b'1', '2025-04-20 14:45:00', '2025-04-20 14:45:00'),
(1001, 'Juan', 'Dela Cruz', '1985-05-15', 'M', '0917-999-1001', 'juan.delacruz.updated@email.com', '999 Aurora Blvd, Quezon City', 'Maria Dela Cruz', '0918-888-1001', 'O+', 'Penicillin', '2025-01-05 09:15:00', b'1', '2025-01-05 09:15:00', '2026-01-07 18:35:39'),
(1002, 'Maria', 'Santos', '1992-08-22', 'F', '0905-812-4497', 'maria.santos@email.com', '456 Rizal Ave, Manila City', 'Jose Santos', '0906-998-2314', 'A+', 'None', '2025-02-12 10:30:00', b'1', '2025-02-12 10:30:00', '2025-02-12 10:30:00');

-- --------------------------------------------------------

--
-- Table structure for table `patientsbackup`
--

DROP TABLE IF EXISTS `patientsbackup`;
CREATE TABLE IF NOT EXISTS `patientsbackup` (
  `PatientID` int NOT NULL,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `DateOfBirth` date NOT NULL,
  `Gender` char(1) DEFAULT NULL,
  `ContactNumber` varchar(20) NOT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Address` varchar(200) DEFAULT NULL,
  `EmergencyContact` varchar(100) DEFAULT NULL,
  `EmergencyPhone` varchar(20) DEFAULT NULL,
  `BloodGroup` varchar(5) DEFAULT NULL,
  `Allergies` varchar(500) DEFAULT NULL,
  `RegistrationDate` datetime DEFAULT NULL,
  `IsActive` bit(1) DEFAULT NULL,
  `BackupDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`PatientID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `patientsbackup`
--

INSERT INTO `patientsbackup` (`PatientID`, `FirstName`, `LastName`, `DateOfBirth`, `Gender`, `ContactNumber`, `Email`, `Address`, `EmergencyContact`, `EmergencyPhone`, `BloodGroup`, `Allergies`, `RegistrationDate`, `IsActive`, `BackupDate`) VALUES
(1009, 'Jose', 'Reyes', '1990-05-15', 'M', '0917-300-1009', 'jose.reyes@email.com', '111 Mabini St, Quezon City', 'Maria Reyes', '0918-300-2009', 'O+', 'None', '2026-01-07 18:33:21', b'0', '2026-01-07 19:31:29'),
(1007, 'William', 'Mendoza', '1995-02-05', 'M', '0916-233-9088', 'william.mendoza@email.com', '147 Degirogorgio St, Manila City', 'Maria Mendoza', '0917-664-1029', 'B-', 'None', '2025-09-22 13:35:00', b'1', '2026-01-07 19:31:29'),
(1008, 'Elizabeth', 'Flores', '1973-09-30', 'F', '0928-540-6712', 'elizabeth.flores@email.com', '258 Boulevard Ave, Makati City', 'Jose Flores', '0929-882-3310', 'AB-', 'Sulfa drugs', '2025-11-11 10:50:00', b'1', '2026-01-07 19:31:29'),
(1006, 'Jennifer', 'Garcia', '1988-11-17', 'F', '0975-412-8890', 'jennifer.garcia@email.com', '987 Cedar St, Sta. Rosa City', 'Carlos Garcia', '0976-701-3456', 'A-', 'Nuts', '2025-03-09 16:00:00', b'1', '2026-01-07 19:31:29'),
(1005, 'Miguel', 'Torres', '1965-07-28', 'M', '0908-645-2201', 'miguel.torres@email.com', '654 Maple St, San Pedro City', 'Linda Torres', '0909-557-9033', 'O-', 'Aspirin', '2026-01-03 11:10:00', b'1', '2026-01-07 19:31:29'),
(1004, 'Patricia', 'Cruz', '2010-03-10', 'F', '0998-301-7765', 'patricia.cruz@email.com', '321 Maple St, San Pedro City', 'George Cruz', '0999-884-1139', 'AB+', 'None', '2025-07-18 08:20:00', b'1', '2026-01-07 19:31:29'),
(1003, 'Roberto', 'Reyes', '1978-12-03', 'M', '0926-534-1198', 'roberto.reyes@email.com', '789 National Rd, Sta. Rosa City', 'Ana Reyes', '0927-667-4402', 'B+', 'Latex', '2025-04-20 14:45:00', b'1', '2026-01-07 19:31:29'),
(1001, 'Juan', 'Dela Cruz', '1985-05-15', 'M', '0917-999-1001', 'juan.delacruz.updated@email.com', '999 Aurora Blvd, Quezon City', 'Maria Dela Cruz', '0918-888-1001', 'O+', 'Penicillin', '2025-01-05 09:15:00', b'1', '2026-01-07 19:31:29'),
(1002, 'Maria', 'Santos', '1992-08-22', 'F', '0905-812-4497', 'maria.santos@email.com', '456 Rizal Ave, Manila City', 'Jose Santos', '0906-998-2314', 'A+', 'None', '2025-02-12 10:30:00', b'1', '2026-01-07 19:31:29');

-- --------------------------------------------------------

--
-- Table structure for table `treatments`
--

DROP TABLE IF EXISTS `treatments`;
CREATE TABLE IF NOT EXISTS `treatments` (
  `TreatmentID` int NOT NULL,
  `TreatmentName` varchar(200) NOT NULL,
  `TreatmentCode` varchar(20) NOT NULL,
  `Description` varchar(500) DEFAULT NULL,
  `StandardCost` decimal(10,2) NOT NULL,
  `DepartmentID` int DEFAULT NULL,
  `IsActive` bit(1) DEFAULT b'1',
  `CreatedDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `ModifiedDate` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`TreatmentID`),
  UNIQUE KEY `TreatmentCode` (`TreatmentCode`),
  KEY `DepartmentID` (`DepartmentID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `treatments`
--

INSERT INTO `treatments` (`TreatmentID`, `TreatmentName`, `TreatmentCode`, `Description`, `StandardCost`, `DepartmentID`, `IsActive`, `CreatedDate`, `ModifiedDate`) VALUES
(2001, 'General Consultation', 'CONS-001', 'Standard medical consultation', 500.00, NULL, b'1', '2026-01-07 07:35:53', '2026-01-07 07:35:53'),
(2002, 'ECG Test', 'CARD-001', 'Electrocardiogram test', 1500.00, 1, b'1', '2026-01-07 07:35:53', '2026-01-07 07:35:53'),
(2003, 'MRI Scan', 'NEUR-001', 'Magnetic Resonance Imaging', 18000.00, 2, b'1', '2026-01-07 07:35:53', '2026-01-07 07:35:53'),
(2004, 'X-Ray', 'ORTH-001', 'Standard X-Ray imaging', 1200.00, 3, b'1', '2026-01-07 07:35:53', '2026-01-07 07:35:53'),
(2005, 'Blood Test', 'LAB-001', 'Complete blood count', 600.00, NULL, b'1', '2026-01-07 07:35:53', '2026-01-07 07:35:53'),
(2006, 'Physical Therapy Session', 'ORTH-002', 'Rehabilitation session', 1200.00, 3, b'1', '2026-01-07 07:35:53', '2026-01-07 07:35:53'),
(2007, 'Vaccination', 'PEDI-001', 'Childhood vaccination', 800.00, 4, b'1', '2026-01-07 07:35:53', '2026-01-07 07:35:53'),
(2008, 'Emergency Room Visit', 'EMER-001', 'Emergency treatment', 3500.00, 5, b'1', '2026-01-07 07:35:53', '2026-01-07 07:35:53'),
(2009, 'CT Scan', 'RADI-001', 'Computed Tomography scan', 10000.00, 6, b'1', '2026-01-07 07:35:53', '2026-01-07 07:35:53'),
(2010, 'Stress Test', 'CARD-002', 'Cardiac stress test', 4500.00, 1, b'1', '2026-01-07 07:35:53', '2026-01-07 07:35:53');

-- --------------------------------------------------------

--
-- Table structure for table `treatmentsbackup`
--

DROP TABLE IF EXISTS `treatmentsbackup`;
CREATE TABLE IF NOT EXISTS `treatmentsbackup` (
  `TreatmentID` int NOT NULL,
  `TreatmentName` varchar(200) NOT NULL,
  `TreatmentCode` varchar(20) NOT NULL,
  `Description` varchar(500) DEFAULT NULL,
  `StandardCost` decimal(10,2) NOT NULL,
  `DepartmentID` int DEFAULT NULL,
  `IsActive` bit(1) DEFAULT NULL,
  `BackupDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`TreatmentID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `treatmentsbackup`
--

INSERT INTO `treatmentsbackup` (`TreatmentID`, `TreatmentName`, `TreatmentCode`, `Description`, `StandardCost`, `DepartmentID`, `IsActive`, `BackupDate`) VALUES
(2001, 'General Consultation', 'CONS-001', 'Standard medical consultation', 500.00, NULL, b'1', '2026-01-07 19:31:29'),
(2002, 'ECG Test', 'CARD-001', 'Electrocardiogram test', 1500.00, 1, b'1', '2026-01-07 19:31:29'),
(2003, 'MRI Scan', 'NEUR-001', 'Magnetic Resonance Imaging', 18000.00, 2, b'1', '2026-01-07 19:31:29'),
(2004, 'X-Ray', 'ORTH-001', 'Standard X-Ray imaging', 1200.00, 3, b'1', '2026-01-07 19:31:29'),
(2005, 'Blood Test', 'LAB-001', 'Complete blood count', 600.00, NULL, b'1', '2026-01-07 19:31:29'),
(2006, 'Physical Therapy Session', 'ORTH-002', 'Rehabilitation session', 1200.00, 3, b'1', '2026-01-07 19:31:29'),
(2007, 'Vaccination', 'PEDI-001', 'Childhood vaccination', 800.00, 4, b'1', '2026-01-07 19:31:29'),
(2008, 'Emergency Room Visit', 'EMER-001', 'Emergency treatment', 3500.00, 5, b'1', '2026-01-07 19:31:29'),
(2009, 'CT Scan', 'RADI-001', 'Computed Tomography scan', 10000.00, 6, b'1', '2026-01-07 19:31:29'),
(2010, 'Stress Test', 'CARD-002', 'Cardiac stress test', 4500.00, 1, b'1', '2026-01-07 19:31:29');

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_billingexport`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `vw_billingexport`;
CREATE TABLE IF NOT EXISTS `vw_billingexport` (
`AppointmentDate` datetime
,`AppointmentID` int
,`BillingID` int
,`DepartmentName` varchar(100)
,`Discount` decimal(5,2)
,`DoctorName` varchar(101)
,`InsuranceClaimNumber` varchar(100)
,`PatientName` varchar(101)
,`PatientPhone` varchar(20)
,`PaymentDate` datetime
,`PaymentMethod` varchar(50)
,`PaymentStatus` varchar(20)
,`Quantity` int
,`TaxRate` decimal(5,2)
,`TotalAmount` decimal(10,2)
,`TreatmentCode` varchar(20)
,`TreatmentName` varchar(200)
,`UnitPrice` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_doctorperformance`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `vw_doctorperformance`;
CREATE TABLE IF NOT EXISTS `vw_doctorperformance` (
`AverageRevenuePerAppointment` decimal(14,6)
,`CancelledAppointments` decimal(23,0)
,`CompletedAppointments` decimal(23,0)
,`DepartmentName` varchar(100)
,`DoctorID` int
,`DoctorName` varchar(101)
,`Specialization` varchar(100)
,`TotalAppointments` bigint
,`TotalRevenueGenerated` decimal(32,2)
,`UniquePatients` bigint
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_monthlyrevenuesummary`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `vw_monthlyrevenuesummary`;
CREATE TABLE IF NOT EXISTS `vw_monthlyrevenuesummary` (
`AverageBillAmount` decimal(14,6)
,`Month` int
,`MonthName` varchar(9)
,`PaidRevenue` decimal(32,2)
,`PartialRevenue` decimal(32,2)
,`TotalAppointments` bigint
,`TotalBills` bigint
,`TotalRevenue` decimal(32,2)
,`UniquePatients` bigint
,`UnpaidRevenue` decimal(32,2)
,`Year` year
,`YearMonth` varchar(7)
);

-- --------------------------------------------------------

--
-- Structure for view `vw_billingexport`
--
DROP TABLE IF EXISTS `vw_billingexport`;

DROP VIEW IF EXISTS `vw_billingexport`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_billingexport`  AS SELECT `b`.`BillingID` AS `BillingID`, `b`.`AppointmentID` AS `AppointmentID`, `a`.`AppointmentDate` AS `AppointmentDate`, concat(`p`.`FirstName`,' ',`p`.`LastName`) AS `PatientName`, `p`.`ContactNumber` AS `PatientPhone`, concat(`d`.`FirstName`,' ',`d`.`LastName`) AS `DoctorName`, `dep`.`DepartmentName` AS `DepartmentName`, `t`.`TreatmentName` AS `TreatmentName`, `t`.`TreatmentCode` AS `TreatmentCode`, `b`.`Quantity` AS `Quantity`, `b`.`UnitPrice` AS `UnitPrice`, `b`.`Discount` AS `Discount`, `b`.`TaxRate` AS `TaxRate`, `b`.`TotalAmount` AS `TotalAmount`, `b`.`PaymentStatus` AS `PaymentStatus`, `b`.`PaymentDate` AS `PaymentDate`, `b`.`PaymentMethod` AS `PaymentMethod`, `b`.`InsuranceClaimNumber` AS `InsuranceClaimNumber` FROM (((((`billing` `b` join `appointments` `a` on((`b`.`AppointmentID` = `a`.`AppointmentID`))) join `patients` `p` on((`a`.`PatientID` = `p`.`PatientID`))) join `doctors` `d` on((`a`.`DoctorID` = `d`.`DoctorID`))) join `departments` `dep` on((`d`.`DepartmentID` = `dep`.`DepartmentID`))) join `treatments` `t` on((`b`.`TreatmentID` = `t`.`TreatmentID`))) ORDER BY `b`.`BillingID` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `vw_doctorperformance`
--
DROP TABLE IF EXISTS `vw_doctorperformance`;

DROP VIEW IF EXISTS `vw_doctorperformance`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_doctorperformance`  AS SELECT `d`.`DoctorID` AS `DoctorID`, concat(`d`.`FirstName`,' ',`d`.`LastName`) AS `DoctorName`, `d`.`Specialization` AS `Specialization`, `dep`.`DepartmentName` AS `DepartmentName`, count(distinct `a`.`AppointmentID`) AS `TotalAppointments`, count(distinct `a`.`PatientID`) AS `UniquePatients`, sum(`b`.`TotalAmount`) AS `TotalRevenueGenerated`, avg(`b`.`TotalAmount`) AS `AverageRevenuePerAppointment`, sum((case when (`a`.`Status` = 'Completed') then 1 else 0 end)) AS `CompletedAppointments`, sum((case when (`a`.`Status` = 'Cancelled') then 1 else 0 end)) AS `CancelledAppointments` FROM (((`doctors` `d` join `departments` `dep` on((`d`.`DepartmentID` = `dep`.`DepartmentID`))) left join `appointments` `a` on((`d`.`DoctorID` = `a`.`DoctorID`))) left join `billing` `b` on((`a`.`AppointmentID` = `b`.`AppointmentID`))) WHERE (`d`.`IsActive` = 1) GROUP BY `d`.`DoctorID`, `d`.`FirstName`, `d`.`LastName`, `d`.`Specialization`, `dep`.`DepartmentName` ORDER BY `TotalRevenueGenerated` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `vw_monthlyrevenuesummary`
--
DROP TABLE IF EXISTS `vw_monthlyrevenuesummary`;

DROP VIEW IF EXISTS `vw_monthlyrevenuesummary`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_monthlyrevenuesummary`  AS SELECT year(`a`.`AppointmentDate`) AS `Year`, month(`a`.`AppointmentDate`) AS `Month`, date_format(`a`.`AppointmentDate`,'%Y-%m') AS `YearMonth`, monthname(`a`.`AppointmentDate`) AS `MonthName`, count(distinct `b`.`BillingID`) AS `TotalBills`, count(distinct `a`.`AppointmentID`) AS `TotalAppointments`, count(distinct `a`.`PatientID`) AS `UniquePatients`, sum(`b`.`TotalAmount`) AS `TotalRevenue`, sum((case when (`b`.`PaymentStatus` = 'Paid') then `b`.`TotalAmount` else 0 end)) AS `PaidRevenue`, sum((case when (`b`.`PaymentStatus` = 'Unpaid') then `b`.`TotalAmount` else 0 end)) AS `UnpaidRevenue`, sum((case when (`b`.`PaymentStatus` = 'Partial') then `b`.`TotalAmount` else 0 end)) AS `PartialRevenue`, avg(`b`.`TotalAmount`) AS `AverageBillAmount` FROM (`appointments` `a` join `billing` `b` on((`a`.`AppointmentID` = `b`.`AppointmentID`))) GROUP BY year(`a`.`AppointmentDate`), month(`a`.`AppointmentDate`), date_format(`a`.`AppointmentDate`,'%Y-%m'), monthname(`a`.`AppointmentDate`) ORDER BY `Year` DESC, `Month` DESC ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
