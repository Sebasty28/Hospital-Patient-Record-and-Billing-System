--Deliverable Number 4.1 DAILY PATIENT LIST PER DOCTOR

DELIMITER $$
CREATE PROCEDURE query_GetDailyPatientsByDoctor(
    IN p_DoctorID INT,
    IN p_Date DATE
)
BEGIN
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
END $$
DELIMITER ;

--Test Script: 
CALL query_GetDailyPatientsByDoctor(101, '2025-01-05');

--Deliverable Number 4.2 REVENUE BY DEPARTMENT

DELIMITER $$
CREATE PROCEDURE query_GetRevenueByDepartment(
    IN p_StartDate DATE,
    IN p_EndDate DATE
)
BEGIN
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
END $$
DELIMITER ;

--Test Script: 
CALL query_GetRevenueByDepartment('2025-01-01', '2025-01-31');