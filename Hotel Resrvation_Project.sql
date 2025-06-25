create database  HOTELRESERVATIONSYSTEM ;
use  HOTELRESERVATIONSYSTEM ;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    MealPreferences TEXT,
    SpecialRequests TEXT
);
CREATE TABLE Rooms (
    RoomID INT PRIMARY KEY AUTO_INCREMENT,
    RoomNumber VARCHAR(10),
    RoomType VARCHAR(50), -- Single, Double, Suite, etc.
    BedCount INT,
    PricePerNight DECIMAL(10,2)
);
CREATE TABLE Reservations (
    ReservationID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    RoomID INT,
    CheckInDate DATE,
    CheckOutDate DATE,
    SpecialServices TEXT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);
CREATE TABLE Billing (
    BillID INT PRIMARY KEY AUTO_INCREMENT,
    ReservationID INT,
    Amount DECIMAL(10,2),
    BillingDate DATE,
    FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID)
);
CREATE TABLE RoomAvailability (
    RoomAvailabilityID INT PRIMARY KEY AUTO_INCREMENT,
    RoomID INT,
    AvailableDate DATE,
    IsAvailable BOOLEAN,
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);
CREATE TABLE Services (
    ServiceID INT PRIMARY KEY AUTO_INCREMENT,
    ReservationID INT,
    ServiceDescription TEXT,
    ServiceCharge DECIMAL(10,2),
    FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID)
);
CREATE TABLE CheckInsCheckOuts (
    CheckID INT PRIMARY KEY AUTO_INCREMENT,
    ReservationID INT,
    CheckInTime DATETIME,
    CheckOutTime DATETIME,
    FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID)
);

INSERT INTO Rooms (RoomNumber, RoomType, BedCount, PricePerNight) VALUES
('101', 'Single', 1, 80.00),
('102', 'Double', 2, 120.00),
('201', 'Suite', 3, 200.00),
('202', 'Double', 2, 150.00),
('301', 'Single', 1, 90.00);

INSERT INTO Customers (FullName, Email, Phone, MealPreferences, SpecialRequests) VALUES
('Ahmed Ali', 'ahmed@example.com', '0100000001', 'Vegetarian', 'Late check-in'),
('Sara Mostafa', 'sara@example.com', '0100000002', 'Gluten-free', 'Sea view'),
('Mohamed Hassan', 'mohamed@example.com', '0100000003', NULL, NULL),
('Laila Tarek', 'laila@example.com', '0100000004', 'No dairy', NULL),
('Omar Khaled', 'omar@example.com', '0100000005', NULL, 'Baby crib');

INSERT INTO Reservations (CustomerID, RoomID, CheckInDate, CheckOutDate, SpecialServices) VALUES
(1, 1, '2025-05-19', '2025-05-21', 'Extra towels'),
(2, 2, '2025-06-01', '2025-06-03', 'Airport pickup'),
(3, 3, '2025-05-25', '2025-05-28', NULL),
(4, 4, '2025-04-10', '2025-04-12', NULL),
(1, 5, '2025-03-15', '2025-03-16', 'Flower bouquet');

INSERT INTO CheckInsCheckOuts (ReservationID, CheckInTime, CheckOutTime) VALUES
(1, '2025-05-19 14:00:00', '2025-05-21 12:00:00'),
(2, '2025-06-01 13:30:00', '2025-06-03 11:00:00'),
(3, '2025-05-25 14:00:00', '2025-05-28 12:00:00'),
(4, '2025-04-10 15:00:00', '2025-04-12 11:30:00'),
(5, '2025-03-15 12:00:00', '2025-03-16 10:00:00');

INSERT INTO Billing (ReservationID, Amount, BillingDate) VALUES
(1, 240.00, '2025-05-21'),
(2, 360.00, '2025-06-03'),
(3, 600.00, '2025-05-28'),
(4, 300.00, '2025-04-12'),
(5, 100.00, '2025-03-16');

INSERT INTO Services (ReservationID, ServiceDescription, ServiceCharge) VALUES
(1, 'Extra towels', 20.00),
(2, 'Airport pickup', 50.00),
(5, 'Flower bouquet', 30.00);

INSERT INTO RoomAvailability (RoomID, AvailableDate, IsAvailable) VALUES
(1, CURDATE(), FALSE),
(2, CURDATE(), TRUE),
(3, CURDATE(), TRUE),
(4, CURDATE(), TRUE),
(5, CURDATE(), FALSE);

SELECT r.RoomID, r.RoomNumber, r.RoomType, r.BedCount, r.PricePerNight
FROM Rooms r
JOIN RoomAvailability ra ON r.RoomID = ra.RoomID
WHERE ra.AvailableDate = CURDATE()
  AND ra.IsAvailable = TRUE;
  
  SELECT * FROM Reservations
WHERE CheckInDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);

SELECT CustomerID, FullName, MealPreferences
FROM Customers
WHERE MealPreferences IS NOT NULL AND MealPreferences != '';

SELECT * FROM Billing
WHERE Amount > 1000;

SELECT c.FullName, ch.CheckInTime, ch.CheckOutTime
FROM Customers c
JOIN Reservations r ON c.CustomerID = r.CustomerID
JOIN CheckInsCheckOuts ch ON r.ReservationID = ch.ReservationID;

SELECT r.RoomID, r.RoomNumber,
       CASE 
           WHEN ra.IsAvailable = TRUE THEN 'Vacant'
           ELSE 'Occupied'
       END AS OccupancyStatus
FROM Rooms r
JOIN RoomAvailability ra ON r.RoomID = ra.RoomID
WHERE ra.AvailableDate = CURDATE();

SELECT c.CustomerID, c.FullName, COUNT(r.ReservationID) AS StayCount
FROM Customers c
JOIN Reservations r ON c.CustomerID = r.CustomerID
GROUP BY c.CustomerID, c.FullName
HAVING COUNT(r.ReservationID) > 5;

SELECT * FROM Reservations
WHERE SpecialServices IS NOT NULL AND SpecialServices != '';

SELECT * FROM Rooms
WHERE RoomID NOT IN (
    SELECT RoomID FROM Reservations
);
SELECT c.CustomerID, c.FullName, SUM(b.Amount) AS TotalAmount
FROM Customers c
JOIN Reservations r ON c.CustomerID = r.CustomerID
JOIN Billing b ON r.ReservationID = b.ReservationID
GROUP BY c.CustomerID, c.FullName
HAVING SUM(b.Amount) > (
    SELECT AVG(Total) FROM (
        SELECT SUM(b2.Amount) AS Total
        FROM Reservations r2
        JOIN Billing b2 ON r2.ReservationID = b2.ReservationID
        GROUP BY r2.CustomerID
    ) AS CustomerTotals
);




















