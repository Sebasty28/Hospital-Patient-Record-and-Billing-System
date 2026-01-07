CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE,
    DepartmentHead VARCHAR(100),
    ContactNumber VARCHAR(20),
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Specialization VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    LicenseNumber VARCHAR(50) UNIQUE NOT NULL,
    ContactNumber VARCHAR(20),
    Email VARCHAR(100) UNIQUE NOT NULL,
    HireDate DATE NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Patients (
    PatientID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F', 'O')),
    ContactNumber VARCHAR(20) NOT NULL,
    Email VARCHAR(100),
    Address VARCHAR(200),
    EmergencyContact VARCHAR(100),
    EmergencyPhone VARCHAR(20),
    BloodGroup VARCHAR(5),
    Allergies VARCHAR(500),
    RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATETIME NOT NULL,
    AppointmentType VARCHAR(50) NOT NULL,
    Status VARCHAR(20) DEFAULT 'Scheduled',
    ReasonForVisit VARCHAR(500),
    Diagnosis VARCHAR(1000),
    Prescription VARCHAR(1000),
    Notes VARCHAR(1000),
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

CREATE TABLE Treatments (
    TreatmentID INT PRIMARY KEY,
    TreatmentName VARCHAR(200) NOT NULL,
    TreatmentCode VARCHAR(20) UNIQUE NOT NULL,
    Description VARCHAR(500),
    StandardCost DECIMAL(10,2) NOT NULL,
    DepartmentID INT,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Billing (
    BillingID INT PRIMARY KEY,
    AppointmentID INT NOT NULL,
    TreatmentID INT NOT NULL,
    Quantity INT DEFAULT 1,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Discount DECIMAL(5,2) DEFAULT 0.00,
    TaxRate DECIMAL(5,2) DEFAULT 0.00,
    TotalAmount DECIMAL(10,2) NOT NULL,
    PaymentStatus VARCHAR(20) DEFAULT 'Unpaid',
    PaymentDate DATETIME NULL,
    PaymentMethod VARCHAR(50),
    InsuranceClaimNumber VARCHAR(100),
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID),
    FOREIGN KEY (TreatmentID) REFERENCES Treatments(TreatmentID)
);

CREATE TABLE BillingAudit (
    AuditID INT PRIMARY KEY AUTO_INCREMENT,
    BillingID INT NOT NULL,
    ActionType VARCHAR(10) NOT NULL,
    OldTotalAmount DECIMAL(10,2),
    NewTotalAmount DECIMAL(10,2),
    OldPaymentStatus VARCHAR(20),
    NewPaymentStatus VARCHAR(20),
    ModifiedBy VARCHAR(100),
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

--INSERTING SAMPLE DATA

INSERT INTO Departments (DepartmentID, DepartmentName, DepartmentHead, ContactNumber) VALUES
(1, 'Cardiology', 'Dr. Steve Rogers', '0917-482-6391'),
(2, 'Neurology', 'Dr. Natasha Romanoff', '0905-731-2846'),
(3, 'Orthopedics', 'Dr. Thor Odinson', '0926-804-5173'),
(4, 'Pediatrics', 'Dr. Tony Stark', '0998-165-7420'),
(5, 'Emergency Medicine', 'Dr. Scott Lang', '0975-493-8062'),
(6, 'Radiology', 'Dr. Peter Parker', '0908-257-9148');

INSERT INTO Doctors (DoctorID, FirstName, LastName, Specialization, DepartmentID, LicenseNumber, ContactNumber, Email, HireDate, IsActive) 
VALUES
(101, 'Bruce', 'Banner', 'Cardiologist', 1, 'LIC-CARD-001', '0917-100-1001', 'bruce.banner@hospital.com', '2018-03-15', 1),
(102, 'Clint', 'Barton', 'Neurologist', 2,'LIC-NEUR-002', '0917-100-1002', 'clint.barton@hospital.com', '2019-06-20', 1),
(103, 'Stephen', 'Strange', 'Orthopedic Surgeon', 3,'LIC-ORTH-003', '0917-100-1003', 'stephen.strange@hospital.com', '2017-09-10', 1),
(104, 'Wanda', 'Maximoff', 'Pediatrician', 4, 'LIC-PEDI-004', '0917-100-1004', 'wanda.maximoff@hospital.com', '2020-01-05', 1),
(105, 'James', 'Rhodes', 'Emergency Physician', 5, 'LIC-EMER-005', '0917-100-1005', 'james.rhodes@hospital.com', '2016-11-30', 1),
(106, 'Sam', 'Wilson', 'Cardiologist', 1, 'LIC-CARD-006', '0917-100-1006', 'sam.wilson@hospital.com', '2021-04-12', 1),
(107, 'Bucky', 'Barnes', 'Radiologist', 6, 'LIC-RADI-007', '0917-100-1007', 'bucky.barnes@hospital.com', '2019-08-22', 1);

INSERT INTO Patients (PatientID, FirstName, LastName, DateOfBirth, Gender, ContactNumber, Email, Address, EmergencyContact, EmergencyPhone, BloodGroup, Allergies) 
VALUES
(1001, 'Juan', 'Dela Cruz', '1985-05-15', 'M', '0917-345-7821', 'juan.delacruz@email.com', '123 Cataran St, Manila City', 'Maria Dela Cruz', '0918-456-9023', 'O+', 'Penicillin'),
(1002, 'Maria', 'Santos', '1992-08-22', 'F', '0905-812-4497', 'maria.santos@email.com', '456 Rizal Ave, Manila City', 'Jose Santos', '0906-998-2314', 'A+', 'None'),
(1003, 'Roberto', 'Reyes', '1978-12-03', 'M', '0926-534-1198', 'roberto.reyes@email.com', '789 National Rd, Sta. Rosa City', 'Ana Reyes', '0927-667-4402', 'B+', 'Latex'),
(1004, 'Patricia', 'Cruz', '2010-03-10', 'F', '0998-301-7765', 'patricia.cruz@email.com', '321 Maple St, San Pedro City', 'George Cruz', '0999-884-1139', 'AB+', 'None'),
(1005, 'Miguel', 'Torres', '1965-07-28', 'M', '0908-645-2201', 'miguel.torres@email.com', '654 Maple St, San Pedro City', 'Linda Torres', '0909-557-9033', 'O-', 'Aspirin'),
(1006, 'Jennifer', 'Garcia', '1988-11-17', 'F', '0975-412-8890', 'jennifer.garcia@email.com', '987 Cedar St, Sta. Rosa City', 'Carlos Garcia', '0976-701-3456', 'A-', 'Nuts'),
(1007, 'William', 'Mendoza', '1995-02-05', 'M', '0916-233-9088', 'william.mendoza@email.com', '147 Degirogorgio St, Manila City', 'Maria Mendoza', '0917-664-1029', 'B-', 'None'),
(1008, 'Elizabeth', 'Flores', '1973-09-30', 'F', '0928-540-6712', 'elizabeth.flores@email.com', '258 Boulevard Ave, Makati City', 'Jose Flores', '0929-882-3310', 'AB-', 'Sulfa drugs');

INSERT INTO Treatments 
(TreatmentID, TreatmentName, TreatmentCode, Description, StandardCost, DepartmentID, IsActive) 
VALUES
(2001, 'General Consultation', 'CONS-001', 'Standard medical consultation', 500.00, NULL, 1),
(2002, 'ECG Test', 'CARD-001', 'Electrocardiogram test', 1500.00, 1, 1),
(2003, 'MRI Scan', 'NEUR-001', 'Magnetic Resonance Imaging', 18000.00, 2, 1),
(2004, 'X-Ray', 'ORTH-001', 'Standard X-Ray imaging', 1200.00, 3, 1),
(2005, 'Blood Test', 'LAB-001', 'Complete blood count', 600.00, NULL, 1),
(2006, 'Physical Therapy Session', 'ORTH-002', 'Rehabilitation session', 1200.00, 3, 1),
(2007, 'Vaccination', 'PEDI-001', 'Childhood vaccination', 800.00, 4, 1),
(2008, 'Emergency Room Visit', 'EMER-001', 'Emergency treatment', 3500.00, 5, 1),
(2009, 'CT Scan', 'RADI-001', 'Computed Tomography scan', 10000.00, 6, 1),
(2010, 'Stress Test', 'CARD-002', 'Cardiac stress test', 4500.00, 1, 1);

INSERT INTO Appointments (AppointmentID, PatientID, DoctorID, AppointmentDate, AppointmentType, Status, ReasonForVisit, Diagnosis, Prescription, Notes) VALUES
(3001, 1001, 101, '2025-01-05 09:00:00', 'Consultation', 'Completed', 'Chest pain', 'Angina', 'Aspirin 81mg daily', 'Follow up in 2 weeks'),
(3002, 1002, 104, '2025-01-05 10:30:00', 'Follow-up', 'Completed', 'Routine checkup', 'Healthy', 'Vitamins', 'Annual visit'),
(3003, 1003, 103, '2025-01-05 14:00:00', 'Consultation', 'Completed', 'Knee pain', 'Osteoarthritis', 'Ibuprofen 400mg', 'Physical therapy recommended'),
(3004, 1004, 104, '2025-01-06 09:30:00', 'Consultation', 'Completed', 'Vaccination', 'Healthy', 'N/A', 'Next vaccine due in 6 months'),
(3005, 1005, 105, '2025-01-06 11:00:00', 'Emergency', 'Completed', 'Severe headache', 'Migraine', 'Sumatriptan 50mg', 'ER visit'),
(3006, 1006, 102, '2025-01-06 15:30:00', 'Consultation', 'Completed', 'Memory issues', 'Mild cognitive impairment', 'Donepezil 5mg', 'MRI scheduled'),
(3007, 1007, 101, '2025-01-07 10:00:00', 'Follow-up', 'Scheduled', 'Heart palpitations', NULL, NULL, 'Stress test scheduled'),
(3008, 1008, 107, '2025-01-07 13:00:00', 'Consultation', 'Scheduled', 'Back pain', NULL, NULL, 'Imaging required'),
(3009, 1001, 106, '2025-01-08 09:00:00', 'Follow-up', 'Scheduled', 'Post-surgery checkup', NULL, NULL, NULL),
(3010, 1003, 103, '2025-01-08 14:00:00', 'Follow-up', 'Scheduled', 'Physical therapy evaluation', NULL, NULL, NULL);

INSERT INTO Billing 
(BillingID, AppointmentID, TreatmentID, Quantity, UnitPrice, Discount, TaxRate, TotalAmount, PaymentStatus, PaymentDate, PaymentMethod, InsuranceClaimNumber) 
VALUES
(4001, 3001, 2001, 1, 500.00, 0.00, 12.00, 560.00, 'Paid', '2025-01-05 10:00:00', 'Insurance', 'INS-2025-001'),
(4002, 3001, 2002, 1, 1500.00, 0.00, 12.00, 1680.00, 'Paid', '2025-01-05 10:00:00', 'Insurance', 'INS-2025-003'),
(4003, 3002, 2001, 1, 500.00, 50.00, 12.00, 504.00, 'Paid', '2025-01-05 11:30:00', 'Card', NULL),
(4004, 3003, 2001, 1, 500.00, 0.00, 12.00, 560.00, 'Paid', '2025-01-05 15:00:00', 'Cash', NULL),
(4005, 3003, 2004, 1, 1200.00, 0.00, 12.00, 1344.00, 'Paid', '2025-01-05 15:00:00','Cash', NULL),
(4006, 3004, 2007, 1, 800.00, 0.00, 12.00, 896.00, 'Paid', '2025-01-06 10:00:00', 'Insurance', 'INS-2025-002'),
(4007, 3005, 2005, 1, 600.00, 0.00, 12.00, 672.00, 'Unpaid', NULL, NULL, NULL),
(4008,3006, 2001, 1, 500.00, 0.00, 12.00, 560.00, 'Unpaid', NULL, NULL, NULL),
(4009,3006, 2003, 1, 18000.00, 0.00, 12.00, 20160.00, 'Unpaid', NULL, NULL, NULL);
