--Deliverable Number 5 STORED PROCEDURE - AUTO-GENERATE BILLING TOTAL

DELIMITER $$
CREATE PROCEDURE sp_GenerateBilling(
    IN p_BillingID INT,
    IN p_AppointmentID INT,
    IN p_TreatmentID INT,
    IN p_Quantity INT,
    IN p_Discount DECIMAL(5,2),
    IN p_TaxRate DECIMAL(5,2),
    IN p_PaymentMethod VARCHAR(50),
    IN p_InsuranceClaimNumber VARCHAR(100)
)
BEGIN
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
END $$
DELIMITER ;

--Test Script: 
CALL sp_GenerateBilling(
    4009,             -- BillingID
    3007,             -- AppointmentID
    2010,             -- TreatmentID (Stress Test)
    1,                -- Quantity
    0.00,             -- Discount percentage
    8.00,             -- Tax rate
    'Cash',           -- PaymentMethod
    NULL              -- InsuranceClaimNumber
);