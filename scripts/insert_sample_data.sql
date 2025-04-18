-- Inserts for table `Roles`
INSERT INTO Roles (RoleId, RoleName, RoleDesc, DateCreated, IsActive) VALUES (1, 'Admin', 'Administrator', '2023-12-01 00:00:00', 1);
INSERT INTO Roles (RoleId, RoleName, RoleDesc, DateCreated, IsActive) VALUES (2, 'HOD', 'Head of the Department', '2023-12-01 00:00:00', 1);
INSERT INTO Roles (RoleId, RoleName, RoleDesc, DateCreated, IsActive) VALUES (3, 'Lab Incharge', NULL, '2023-12-01 00:00:00', 1);
INSERT INTO Roles (RoleId, RoleName, RoleDesc, DateCreated, IsActive) VALUES (4, 'Lab Assistant', NULL, '2023-12-01 00:00:00', 1);
INSERT INTO Roles (RoleId, RoleName, RoleDesc, DateCreated, IsActive) VALUES (5, 'Student', NULL, '2023-12-01 00:00:00', 1);

-- Inserts for table `Users`
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (1, 'A00001', 'A00001', 'A00001', 'User1', NULL, NULL, 'Male', '1988-01-01 00:00:00', 'xyz@mail.com', 9999999999, NULL, 1, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (2, 'A00001', 'A00001', 'A00001', 'User2', NULL, NULL, 'Male', '1988-01-01 00:00:00', 'xyz1@mail.com', 9999999999, NULL, 1, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (3, 'A00002', 'A00002', 'A00002', 'User3', NULL, NULL, 'Male', '1988-01-01 00:00:00', 'xyz2@mail.com', 9999999999, NULL, 1, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (4, 'A00003', 'A00003', 'A00003', 'User4', NULL, NULL, 'Female', '1988-01-01 00:00:00', 'xyz3@mail.com', 9999999999, NULL, 1, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (5, 'A00004', 'A00004', 'A00004', 'User5', NULL, NULL, 'Female', '1988-01-01 00:00:00', 'xyz4@mail.com', 9999999999, NULL, 1, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (6, 'A00005', 'A00005', 'A00005', 'User6', NULL, NULL, 'Male', '1988-01-01 00:00:00', 'xyz5@mail.com', 9999999999, NULL, 1, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (7, 'A00006', 'A00006', 'A00006', 'User7', NULL, NULL, 'Male', '1988-01-01 00:00:00', 'xyz6@mail.com', 9999999999, NULL, 1, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (8, 'A00007', 'A00007', 'A00007', 'User8', NULL, NULL, 'Female', '2000-01-01 00:00:00', 'xyz7@mail.com', 9999999999, NULL, 1, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (9, 'A00008', 'A00008', 'A00008', 'User9', NULL, NULL, 'Male', '2000-01-01 00:00:00', 'xyz8@mail.com', 9999999999, NULL, 1, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (10, 'A00009', 'A00009', 'A00009', 'User10', NULL, NULL, 'Male', '2000-01-01 00:00:00', 'xyz9@mail.com', 9999999999, NULL, 1, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (11, 'A00010', 'A00010', 'A00010', 'User11', NULL, NULL, 'Female', '2000-01-01 00:00:00', 'xyz10@mail.com', 9999999999, NULL, 1, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (12, NULL, NULL, 'A00011', 'User12', NULL, NULL, 'Male', '2000-01-01 00:00:00', 'xyz11@mail.com', 9999999999, NULL, 0, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (13, NULL, NULL, 'A00012', 'User13', NULL, NULL, 'Female', '2000-01-01 00:00:00', 'xyz12@mail.com', 9999999999, NULL, 0, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (14, NULL, NULL, 'A00013', 'User14', NULL, NULL, 'Male', '2000-01-01 00:00:00', 'xyz13@mail.com', 9999999999, NULL, 0, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (15, NULL, NULL, 'A00014', 'User15', NULL, NULL, 'Male', '2000-01-01 00:00:00', 'xyz14@mail.com', 9999999999, NULL, 0, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (16, NULL, NULL, 'A00015', 'User16', NULL, NULL, 'Female', '2000-01-01 00:00:00', 'xyz15@mail.com', 9999999999, NULL, 0, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (17, NULL, NULL, 'A00016', 'User17', NULL, NULL, 'Male', '2000-01-01 00:00:00', 'xyz11@mail.com', 9999999999, NULL, 0, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (18, NULL, NULL, 'A00017', 'User18', NULL, NULL, 'Female', '2000-01-01 00:00:00', 'xyz12@mail.com', 9999999999, NULL, 0, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (19, NULL, NULL, 'A00018', 'User19', NULL, NULL, 'Male', '2000-01-01 00:00:00', 'xyz13@mail.com', 9999999999, NULL, 0, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (20, NULL, NULL, 'A00019', 'User20', NULL, NULL, 'Male', '2000-01-01 00:00:00', 'xyz14@mail.com', 9999999999, NULL, 0, '2023-12-01 00:00:00', 1);
INSERT INTO Users (UserId, UserName, UserPassword, InstituteId, FirstName, MiddleName, LastName, Gender, DOB, Email, Contact, UserAddress, IsAppUser, DateCreated, IsActive) VALUES (21, NULL, NULL, 'A00020', 'User21', NULL, NULL, 'Female', '2000-01-01 00:00:00', 'xyz15@mail.com', 9999999999, NULL, 0, '2023-12-01 00:00:00', 1);

-- Inserts for table `Department`
INSERT INTO Department (DeptId, DeptName, DeptDesc, DateCreated, IsActive) VALUES (1, 'CSE', 'Computer Science Engineeing', '2023-12-01 00:00:00', 1);
INSERT INTO Department (DeptId, DeptName, DeptDesc, DateCreated, IsActive) VALUES (2, 'EE', 'Electrical Engineering', '2023-12-01 00:00:00', 1);

-- Inserts for table `Lab`
INSERT INTO Lab (LabId, DeptId, LabName, FundsAvailable, DateCreated, DateModified, IsActive) VALUES (1, 1, 'Lab1', 5850000, '2023-12-01 00:00:00', '2024-01-10 00:00:00', 1);
INSERT INTO Lab (LabId, DeptId, LabName, FundsAvailable, DateCreated, DateModified, IsActive) VALUES (2, 1, 'Lab2', 1000000, '2023-12-01 00:00:00', '2023-12-12 00:00:00', 1);
INSERT INTO Lab (LabId, DeptId, LabName, FundsAvailable, DateCreated, DateModified, IsActive) VALUES (3, 2, 'Lab3', 1000000, '2023-12-01 00:00:00', '2023-12-12 00:00:00', 1);

-- Inserts for table `UserRole`
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (1, 1, NULL, NULL, 1, '2021-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (2, 2, 1.0, NULL, 2, '2021-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (3, 3, 2.0, NULL, 2, '2021-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (4, 4, 1.0, 1.0, 3, '2021-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (5, 5, 1.0, 2.0, 3, '2021-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (6, 6, 2.0, 3.0, 3, '2021-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (7, 7, 1.0, 1.0, 4, '2021-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (8, 8, 1.0, 1.0, 4, '2021-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (9, 9, 1.0, 2.0, 4, '2021-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (10, 10, 1.0, 2.0, 4, '2022-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (11, 11, 2.0, 3.0, 4, '2022-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (12, 12, 1.0, 1.0, 5, '2022-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (13, 13, 1.0, 1.0, 5, '2023-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (14, 14, 1.0, 1.0, 5, '2023-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (15, 15, 1.0, 1.0, 5, '2024-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (16, 16, 1.0, 1.0, 5, '2024-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (17, 17, 1.0, 2.0, 5, '2022-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (18, 18, 1.0, 2.0, 5, '2022-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (19, 19, 1.0, 2.0, 5, '2023-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (20, 20, 1.0, 2.0, 5, '2023-01-01 00:00:00', NULL, NULL, 1);
INSERT INTO UserRole (UserRoleId, UserId, DeptID, LabId, RoleId, DateJoined, DateLeft, DateCreated, IsActive) VALUES (21, 21, 1.0, 2.0, 5, '2024-01-01 00:00:00', NULL, NULL, 1);

-- Inserts for table `LabLog`
INSERT INTO LabLog (LabLogId, LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount, DateCreated) VALUES (1, 1, 2, 'Added', 'Initial Funds', 5000000, '2023-12-01 00:00:00');
INSERT INTO LabLog (LabLogId, LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount, DateCreated) VALUES (2, 2, 2, 'Added', 'Initial Funds', 800000, '2023-12-01 00:00:00');
INSERT INTO LabLog (LabLogId, LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount, DateCreated) VALUES (3, 3, 3, 'Added', 'Initial Funds', 800000, '2023-12-01 00:00:00');
INSERT INTO LabLog (LabLogId, LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount, DateCreated) VALUES (4, 1, 2, 'Added', 'Alumini Funds', 1000000, '2023-12-12 00:00:00');
INSERT INTO LabLog (LabLogId, LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount, DateCreated) VALUES (5, 2, 2, 'Added', 'Alumini Funds', 200000, '2023-12-12 00:00:00');
INSERT INTO LabLog (LabLogId, LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount, DateCreated) VALUES (6, 3, 3, 'Added', 'Alumini Funds', 200000, '2023-12-12 00:00:00');
INSERT INTO LabLog (LabLogId, LabId, ActionTakenBy, ActionTaken, ActionDescription, Amount, DateCreated) VALUES (7, 1, 4, 'Spent', 'Activity 1', 150000, '2024-01-10 00:00:00');

-- Inserts for table `Item`
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (1, 'Catagory1', 'Make1', NULL, 12.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (2, 'Catagory2', 'Make2', NULL, 12.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (3, 'Catagory3', 'Make3', NULL, 12.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (4, 'Catagory4', 'Make4', NULL, 12.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (5, 'Catagory5', 'Make5', NULL, 12.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (6, 'Catagory6', 'Make6', NULL, 12.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (7, 'Catagory7', 'Make7', NULL, 12.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (8, 'Catagory8', 'Make8', NULL, 12.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (9, 'Catagory9', 'Make9', NULL, 24.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (10, 'Catagory10', 'Make10', NULL, 24.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (11, 'Catagory11', 'Make11', NULL, 12.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (12, 'Catagory12', 'Make12', NULL, 6.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (13, 'Catagory13', 'Make13', NULL, 6.0, NULL, 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (14, 'Catagory14', 'Make14', NULL, 12.0, '1 subsription', 7, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (15, 'Catagory15', 'Make15', NULL, 12.0, NULL, 8, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (16, 'Catagory16', 'Make16', NULL, NULL, NULL, 8, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (17, 'Catagory17', 'Make17', NULL, NULL, 'Pack of 10', 8, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (18, 'Catagory18', 'Make18', NULL, NULL, '1 pack', 8, '2024-01-06 00:00:00', 1);
INSERT INTO Item (ItemId, Category, Make, Model, WarrantyPeriodMonths, ItemDescription, CreatedBy, DateCreated, IsActive) VALUES (19, 'Catagory19', 'Make19', NULL, NULL, '2 feet X 2 feet', 8, '2024-01-06 00:00:00', 1);

-- Inserts for table `LabActivity`
INSERT INTO LabActivity (ActivityId, LabId, InitiatorId, ActivityType, ActivityDescription, FundsAllocated, FundsAvailable, StartDate, EndDate, IsClosed, DateCreated, DateModified) VALUES (1, 1, 4, 'Research', 'Activity 1', 150000, 49000, '2024-01-03 00:00:00', NULL, 0, '2024-01-03 00:00:00', '2024-01-10 00:00:00');

-- Inserts for table `LabActivityLog`
INSERT INTO LabActivityLog (ActivityLogId , ActivityId, ActionTakenBy, ActionTaken, ActionDescription, Funds, DateCreated) VALUES (1, 1, 4, 'Added', 'Initial Funds', 150000, '2024-01-03 00:00:00');
INSERT INTO LabActivityLog (ActivityLogId , ActivityId, ActionTakenBy, ActionTaken, ActionDescription, Funds, DateCreated) VALUES (2, 1, 4, 'Spent', NULL, 101000, '2024-01-10 00:00:00');

-- Inserts for table `Request`
INSERT INTO Request (RequestId, ActivityID, RequestDate, Requestor, RequestStatus, IsActive, DateCreated, DateModified) VALUES (1, 1, '2025-01-06 00:00:00', 12, 'Closed', 0, '2024-01-06 00:00:00', '2024-01-11 00:00:00');

-- Inserts for table `RequestItem`
INSERT INTO RequestItem (RItemID, RequestId, ItemId, Isunknown, QuantityRequested, DateCreated) VALUES (1, 1, 1, 1, 2, '2024-01-06 00:00:00');
INSERT INTO RequestItem (RItemID, RequestId, ItemId, Isunknown, QuantityRequested, DateCreated) VALUES (2, 1, 2, 1, 2, '2024-01-06 00:00:00');
INSERT INTO RequestItem (RItemID, RequestId, ItemId, Isunknown, QuantityRequested, DateCreated) VALUES (3, 1, 3, 1, 2, '2024-01-06 00:00:00');
INSERT INTO RequestItem (RItemID, RequestId, ItemId, Isunknown, QuantityRequested, DateCreated) VALUES (4, 1, 4, 1, 2, '2024-01-06 00:00:00');
INSERT INTO RequestItem (RItemID, RequestId, ItemId, Isunknown, QuantityRequested, DateCreated) VALUES (5, 1, 14, 1, 2, '2024-01-06 00:00:00');

-- Inserts for table `RequestLog`
INSERT INTO RequestLog (RequestLogId, RequestId, ActionTakenBy, RequestStatus, RequestDescription, DateCreated) VALUES (1, 1, 7, 'Created', NULL, '2024-01-06 00:00:00');
INSERT INTO RequestLog (RequestLogId, RequestId, ActionTakenBy, RequestStatus, RequestDescription, DateCreated) VALUES (2, 1, 4, 'Approved', NULL, '2024-01-07 00:00:00');
INSERT INTO RequestLog (RequestLogId, RequestId, ActionTakenBy, RequestStatus, RequestDescription, DateCreated) VALUES (3, 1, 7, 'Closed', NULL, '2024-01-11 00:00:00');

-- Inserts for table `PurchaseOrder`
INSERT INTO PurchaseOrder (POId, ActivityId, OrderDate, Amount, POStatus, DateCreated, DateModified, IsActive) VALUES (1, 1, '2024-01-08 00:00:00', 101000, 'Closed', '2024-01-07 00:00:00', '2024-01-10 00:00:00', 0);

-- Inserts for table `POItem`
INSERT INTO POItem (POItemId, POId, ItemID, QuantityOrdered, CostPerUnit, DateCreated) VALUES (1, 1, 1, 2, 10000, '2024-01-07 00:00:00');
INSERT INTO POItem (POItemId, POId, ItemID, QuantityOrdered, CostPerUnit, DateCreated) VALUES (2, 1, 2, 2, 30000, '2024-01-07 00:00:00');
INSERT INTO POItem (POItemId, POId, ItemID, QuantityOrdered, CostPerUnit, DateCreated) VALUES (3, 1, 3, 2, 2000, '2024-01-07 00:00:00');
INSERT INTO POItem (POItemId, POId, ItemID, QuantityOrdered, CostPerUnit, DateCreated) VALUES (4, 1, 4, 2, 500, '2024-01-07 00:00:00');
INSERT INTO POItem (POItemId, POId, ItemID, QuantityOrdered, CostPerUnit, DateCreated) VALUES (5, 1, 14, 2, 8000, '2024-01-07 00:00:00');

-- Inserts for table `POLog`
INSERT INTO POLog (POLogId, POId, POCreatedBy, POStatus, POStatusDescription, DateCreated) VALUES (1, 1, 7, 'Created', NULL, '2024-01-07 00:00:00');
INSERT INTO POLog (POLogId, POId, POCreatedBy, POStatus, POStatusDescription, DateCreated) VALUES (2, 1, 4, 'Approved', NULL, '2024-01-08 00:00:00');
INSERT INTO POLog (POLogId, POId, POCreatedBy, POStatus, POStatusDescription, DateCreated) VALUES (3, 1, 7, 'Closed', NULL, '2024-01-10 00:00:00');

-- Inserts for table `Asset`
INSERT INTO Asset (AssetId, LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription, DateCreated, DateModified) VALUES (1, 1, 1, 'I0001', 0, 'Location1', NULL, '2024-01-10 00:00:00', '2024-02-03 00:00:00');
INSERT INTO Asset (AssetId, LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription, DateCreated, DateModified) VALUES (2, 1, 2, 'I0002', 0, 'Location1', NULL, '2024-01-10 00:00:00', '2024-02-03 00:00:00');
INSERT INTO Asset (AssetId, LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription, DateCreated, DateModified) VALUES (3, 1, 3, 'I0003', 0, 'Location1', NULL, '2024-01-10 00:00:00', '2024-02-03 00:00:00');
INSERT INTO Asset (AssetId, LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription, DateCreated, DateModified) VALUES (4, 1, 4, 'I0005', 0, 'Location1', NULL, '2024-01-10 00:00:00', '2024-02-03 00:00:00');
INSERT INTO Asset (AssetId, LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription, DateCreated, DateModified) VALUES (5, 1, 1, 'I0006', 0, 'Location1', NULL, '2024-01-10 00:00:00', '2024-01-11 00:00:00');
INSERT INTO Asset (AssetId, LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription, DateCreated, DateModified) VALUES (6, 1, 2, 'I0007', 0, 'Location1', NULL, '2024-01-10 00:00:00', '2024-01-11 00:00:00');
INSERT INTO Asset (AssetId, LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription, DateCreated, DateModified) VALUES (7, 1, 3, 'I0008', 0, 'Location1', NULL, '2024-01-10 00:00:00', '2024-01-11 00:00:00');
INSERT INTO Asset (AssetId, LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription, DateCreated, DateModified) VALUES (8, 1, 4, 'I0009', 0, 'Location1', NULL, '2024-01-10 00:00:00', '2024-01-11 00:00:00');
INSERT INTO Asset (AssetId, LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription, DateCreated, DateModified) VALUES (9, 1, 14, NULL, 0, NULL, 'Licenece ', '2024-01-10 00:00:00', '2024-02-03 00:00:00');

-- Inserts for table `AssetTransactionLog`
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (1, 1, 7, 'Added', 1, NULL, '2024-01-10 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (2, 2, 7, 'Added', 1, NULL, '2024-01-10 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (3, 3, 7, 'Added', 1, NULL, '2024-01-10 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (4, 4, 7, 'Added', 1, NULL, '2024-01-10 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (5, 5, 7, 'Added', 1, NULL, '2024-01-10 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (6, 6, 7, 'Added', 1, NULL, '2024-01-10 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (7, 7, 7, 'Added', 1, NULL, '2024-01-10 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (8, 8, 7, 'Added', 1, NULL, '2024-01-10 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (9, 9, 7, 'Added', 2, NULL, '2024-01-10 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (10, 1, 7, 'Issued', 1, NULL, '2024-01-11 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (11, 2, 7, 'Issued', 1, NULL, '2024-01-11 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (12, 3, 7, 'Issued', 1, NULL, '2024-01-11 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (13, 4, 7, 'Issued', 1, NULL, '2024-01-11 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (14, 5, 7, 'Issued', 1, NULL, '2024-01-11 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (15, 6, 7, 'Issued', 1, NULL, '2024-01-11 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (16, 7, 7, 'Issued', 1, NULL, '2024-01-11 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (17, 8, 7, 'Issued', 1, NULL, '2024-01-11 00:00:00');
INSERT INTO AssetTransactionLog (TransactionId, AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription, DateCreated) VALUES (18, 9, 7, 'Issued', 2, NULL, '2024-01-11 00:00:00');

-- Inserts for table `ActivityItemTransaction`
INSERT INTO ActivityItemTransaction (ActivityTrasId, ActivityId, AssetID, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription) VALUES (1, 1, 1, 12, 7, 'Issued', '2024-01-11 00:00:00', 1, NULL);
INSERT INTO ActivityItemTransaction (ActivityTrasId, ActivityId, AssetID, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription) VALUES (2, 1, 2, 12, 7, 'Issued', '2024-01-11 00:00:00', 1, NULL);
INSERT INTO ActivityItemTransaction (ActivityTrasId, ActivityId, AssetID, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription) VALUES (3, 1, 3, 12, 7, 'Issued', '2024-01-11 00:00:00', 1, NULL);
INSERT INTO ActivityItemTransaction (ActivityTrasId, ActivityId, AssetID, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription) VALUES (4, 1, 4, 12, 7, 'Issued', '2024-01-11 00:00:00', 1, NULL);
INSERT INTO ActivityItemTransaction (ActivityTrasId, ActivityId, AssetID, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription) VALUES (5, 1, 5, 12, 7, 'Issued', '2024-01-11 00:00:00', 1, NULL);
INSERT INTO ActivityItemTransaction (ActivityTrasId, ActivityId, AssetID, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription) VALUES (6, 1, 6, 12, 7, 'Issued', '2024-01-11 00:00:00', 1, NULL);
INSERT INTO ActivityItemTransaction (ActivityTrasId, ActivityId, AssetID, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription) VALUES (7, 1, 7, 12, 7, 'Issued', '2024-01-11 00:00:00', 1, NULL);
INSERT INTO ActivityItemTransaction (ActivityTrasId, ActivityId, AssetID, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription) VALUES (8, 1, 8, 12, 7, 'Issued', '2024-01-11 00:00:00', 1, NULL);
INSERT INTO ActivityItemTransaction (ActivityTrasId, ActivityId, AssetID, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription) VALUES (9, 1, 9, 12, 7, 'Issued', '2024-01-11 00:00:00', 2, NULL);
