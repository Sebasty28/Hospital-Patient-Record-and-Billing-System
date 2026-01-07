--CRUD OPERATIONS

DELIMITER $$
CREATE PROCEDURE crud_RegisterPatient(
    IN p_PatientID INT,
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_DateOfBirth DATE,
    IN p_Gender CHAR(1),
    IN p_ContactNumber VARCHAR(20),
    IN p_Email VARCHAR(100),
    IN p_Address VARCHAR(200),
    IN p_EmergencyContact VARCHAR(100),
    IN p_EmergencyPhone VARCHAR(20),
    IN p_BloodGroup VARCHAR(5),
    IN p_Allergies VARCHAR(500)
)
BEGIN
    INSERT INTO Patients (PatientID, FirstName, LastName, DateOfBirth, Gender, ContactNumber, 
                         Email, Address, EmergencyContact, EmergencyPhone, BloodGroup, Allergies)
    VALUES (p_PatientID, p_FirstName, p_LastName, p_DateOfBirth, p_Gender, p_ContactNumber,
            p_Email, p_Address, p_EmergencyContact, p_EmergencyPhone, p_BloodGroup, p_Allergies);
    
    SELECT 'Patient registered successfully' AS Message, p_PatientID AS PatientID;
END $$
DELIMITER ;

--Test Script: 
CALL crud_RegisterPatient(
    1009,                          -- PatientID
    'Jose',                        -- FirstName
    'Reyes',                       -- LastName
    '1990-05-15',                  -- DateOfBirth
    'M',                           -- Gender
    '0917-300-1009',               -- ContactNumber
    'jose.reyes@email.com',        -- Email
    '111 Mabini St, Quezon City',  -- Address
    'Maria Reyes',                 -- EmergencyContact
    '0918-300-2009',               -- EmergencyPhone
    'O+',                          -- BloodGroup
    'None'                         -- Allergies
);

DELIMITER $$
CREATE PROCEDURE crud_UpdatePatient(
    IN p_PatientID INT,
    IN p_ContactNumber VARCHAR(20),
    IN p_Email VARCHAR(100),
    IN p_Address VARCHAR(200),
    IN p_EmergencyContact VARCHAR(100),
    IN p_EmergencyPhone VARCHAR(20)
)
BEGIN
    UPDATE Patients 
    SET ContactNumber = p_ContactNumber,
        Email = p_Email,
        Address = p_Address,
        EmergencyContact = p_EmergencyContact,
        EmergencyPhone = p_EmergencyPhone
    WHERE PatientID = p_PatientID;
    
    SELECT 'Patient information updated successfully' AS Message;
END $$
DELIMITER ;

--Test Script: 
CALL crud_UpdatePatient(
    1001,                          -- PatientID
    '0917-999-1001',               -- New ContactNumber (PH format)
    'juan.delacruz.updated@email.com', -- New Email
    '999 Aurora Blvd, Quezon City', -- New Address
    'Maria Dela Cruz',             -- New EmergencyContact
    '0918-888-1001'                -- New EmergencyPhone (PH format)
);

DELIMITER $$
CREATE PROCEDURE crud_AssignDoctor(
    IN p_AppointmentID INT,
    IN p_PatientID INT,
    IN p_DoctorID INT,
    IN p_AppointmentDate DATETIME,
    IN p_AppointmentType VARCHAR(50),
    IN p_ReasonForVisit VARCHAR(500)
)
BEGIN
    INSERT INTO Appointments (AppointmentID, PatientID, DoctorID, AppointmentDate, 
                             AppointmentType, Status, ReasonForVisit)
    VALUES (p_AppointmentID, p_PatientID, p_DoctorID, p_AppointmentDate, 
            p_AppointmentType, 'Scheduled', p_ReasonForVisit);
    
    SELECT 'Appointment scheduled successfully' AS Message, p_AppointmentID AS AppointmentID;
END $$
DELIMITER ;

--Test Script:
CALL crud_AssignDoctor(
    3011,                        -- AppointmentID
    1009,                        -- PatientID
    101,                         -- DoctorID
    '2025-01-10 14:00:00',      -- AppointmentDate
    'Consultation',              -- AppointmentType
    'Routine checkup'            -- ReasonForVisit
);

DELIMITER $$
CREATE PROCEDURE crud_DeactivatePatient(
    IN p_PatientID INT
)
BEGIN
    UPDATE Patients 
    SET IsActive = 0
    WHERE PatientID = p_PatientID;
    
    SELECT 'Patient deactivated successfully' AS Message;
END $$
DELIMITER ;

--Test Script:
CALL crud_DeactivatePatient(1009);