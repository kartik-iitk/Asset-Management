USE AssetManagement;
-- ============================================================================
-- +++++++++++++++++++++++++++++++++++++++++
--  Part 1: Everything is New, Lab, item etc
-- ============================================================================
--  Check data in tables  
-- ============================================================================
SELECT * FROM Roles;
SELECT * FROM Department;
SELECT * FROM Lab;
SELECT * FROM Users; 

-- Create Lab4 in EE dept
CALL sp_create_lab(
  'EE', 	-- p_DeptName
  'Lab4', 	-- p_LabName
  100000	-- p_FundsAvailable
);

SELECT * FROM Department WHERE DeptName = 'EE'; -- DeptId = 2

SELECT * FROM Lab WHERE LabName = 'Lab4'; -- labId = 4, FundsAvailable = 100000, DeptId = 2, RecentActionTaken = NULL
SELECT * FROM LabLog WHERE LabId = 4 ; -- ActionTaken = Added, Desc = Initial Funds, Amount = 100000 

-- ============================================================================
--  Create 3 user with roles Lab Incharge, Lab Assistant, Student 
-- ============================================================================

CALL sp_create_user(
  'Test',          -- p_Username
  'password123',       -- p_Password
  'IITK123',           -- p_InstituteId
  'John',              -- p_FirstName
  'A.',                -- p_MiddleName
  'Doe',               -- p_LastName
  'Male',              -- p_Gender
  '1995-05-15',        -- p_DOB
  'john.doe@iitk.ac.in', -- p_Email
  '9876543210',        -- p_Contact
  'Hostel 5, Room 101', -- p_UserAddress
  'Lab Incharge',           -- p_RoleName
  'Lab4'             -- p_LabName
);

CALL sp_create_user(
  'Test1',          -- p_Username
  'password123',       -- p_Password
  'IITK123',           -- p_InstituteId
  'Tom',              -- p_FirstName
  'A.',                -- p_MiddleName
  'Doe',               -- p_LastName
  'Male',              -- p_Gender
  '1995-05-15',        -- p_DOB
  'tom.doe@iitk.ac.in', -- p_Email
  '9876543211',        -- p_Contact
  'Hostel 5, Room 102', -- p_UserAddress
  'Lab Assistant',           -- p_RoleName
  'Lab4'             -- p_LabName
);

CALL sp_create_user(
  NULL,          -- p_Username
  NULL,       -- p_Password
  'IITK123',           -- p_InstituteId
  'Stud1',              -- p_FirstName
  'A.',                -- p_MiddleName
  'S1',               -- p_LastName
  'Male',              -- p_Gender
  '1995-05-15',        -- p_DOB
  'Stud1.A@iitk.ac.in', -- p_Email
  '9876543212',        -- p_Contact
  'Hostel 9, Room 102', -- p_UserAddress
  'Student',           -- p_RoleName
  'Lab4'             -- p_LabName
);

SELECT * FROM Users WHERE FirstName IN ( 'John', 'Tom', 'Stud1');  -- UserId = 22, 23, 24 respectively 
SELECT * FROM Roles WHERE RoleName IN ('Lab Incharge', 'Lab Assistant', 'Student') ; -- RoleId = 3, 4, 5 respectively
SELECT * FROM Lab WHERE LabName = 'Lab4'; -- labId = 4, DeptId = 2
SELECT * FROM Department WHERE DeptId = 2; -- DeptName = 'EE'

SELECT * FROM UserRole WHERE UserId IN (22, 23, 24); -- RoleId 3,4,5 respectively

-- userid = 22 (John) Lab Incharge
-- userid = 23 (Tom) Lab Assistant
-- userid = 24 (Stud1) Student

-- ============================================================================
-- Allocated more funds to Lab4 
-- ============================================================================

SELECT * FROM Lab WHERE LabId = 4;
SELECT * FROM LabLog WHERE LabId = 4;

CALL sp_allocate_funds_to_lab(
  4, -- p_LabId   INT,
  10000 -- p_Amount  FLOAT
);

SELECT * FROM Lab WHERE LabId = 4; -- FundsAvailable = 110000, RecentActionTaken = 'Added'
SELECT * FROM LabLog WHERE LabId = 4;  -- (2 records)Recent->  ActionTaken = Added, Desc = Funds added, 10000

-- ============================================================================
-- Create a new Activity (Research) in Lab4 
-- ============================================================================

SELECT * FROM LabActivity; -- 5 records

CALL sp_create_activity(
  4,                 -- p_LabId (Assuming LabId = 1 for the lab where the activity is created)
  22,                 -- p_InitiatorId (UserId of the user creating the activity)
  'Research',        -- p_Type (Type of activity, e.g., 'Research', 'Workshop')
  'AI Research',     -- p_Description (Description of the activity)
  50000.00,          -- p_InitialFunds (Initial funds allocated for the activity)
  '2024-03-01 00:00:00', -- p_StartDate (Start date of the activity)
  '2025-05-31 23:59:59' -- p_EndDate (End date of the activity)
);

SELECT * FROM LabActivity WHERE LabId = 4;  -- Created  ActivityId = 6,   IsClosed = 0 FundsAvailable = 50000
SELECT * FROM LabActivityLog WHERE ActivityId = 6; -- Added, Initial Funds = 50000

SELECT * FROM Lab WHERE LabId = 4;  -- Funds Reduced from Lab FundsAvailable = 60000, RecentActionTaken = 'Allocated'
SELECT * FROM LabLog WHERE LabId = 4;  -- (3 records)Recent->  ActionTaken = Allocated, Desc = Funds Allocated 50000

-- ============================================================================
-- allocate more funds to Activity 
-- ============================================================================
-- ##### 1) Testing Error: Funds to be allocated are more than available Lab Funds

CALL sp_allocate_funds_to_activity(
  4,          -- p_LabId (LabId associated with the activity, here LabId = 1)
  6,          -- p_ActivityId (ActivityId = 6)
  100000.00   -- p_Amount (Amount to allocate) 
); 
--  Error message Insufficient Funds to allocation

SELECT * FROM LabActivity WHERE LabId = 4;  -- No change
SELECT * FROM LabActivityLog WHERE ActivityId = 6; -- No change

SELECT * FROM Lab WHERE LabId = 4;  -- No change
SELECT * FROM LabLog WHERE LabId = 4;  --  No change 

-- ####  2) Funds to be allocated are less than available Lab Funds

CALL sp_allocate_funds_to_activity(
  4,          -- p_LabId (LabId associated with the activity, here LabId = 1)
  6,          -- p_ActivityId (ActivityId = 6)
  1000.00   -- p_Amount (Amount to allocate) 
); 

SELECT * FROM LabActivity WHERE LabId = 4;  -- ActivityId = 6,  FundsAvailable = 51000
SELECT * FROM LabActivityLog WHERE ActivityId = 6; -- (2 records)Recent-> Added, Funds Added,  1000

SELECT * FROM Lab WHERE LabId = 4;  -- FundsAvailable = 59000, RecentActionTaken = 'Allocated'
SELECT * FROM LabLog WHERE LabId = 4;  -- (4 records)Recent-> ActionTaken = Allocated, Desc = Funds Allocated 1000

-- ============================================================================
-- Request Can not be raised as requested item is not there in list
-- Procedure sp_raise_request will give error message 
-- Cannot add or update a child row: a foreign key constraint fails......
-- ============================================================================
--  First Create New Items  
-- ============================================================================

SELECT * FROM Item; -- (16 records)

CALL sp_create_item(
    'Cat1',-- p_Category VARCHAR(20),
    'Mak1',-- p_Make VARCHAR(100),
    'Mod1',-- p_Model VARCHAR(100),
    10,-- p_WarrantyPeriodMonths INT,
    NULL,-- p_ItemDescription VARCHAR(100),
    23-- p_CreatedBy INT
  );

CALL sp_create_item(
    'Cat2',-- p_Category VARCHAR(20),
    'Mak2',-- p_Make VARCHAR(100),
    'Mod2',-- p_Model VARCHAR(100),
    12,-- p_WarrantyPeriodMonths INT,
    NULL,-- p_ItemDescription VARCHAR(100),
    23-- p_CreatedBy INT
  );

SELECT * FROM Item WHERE Category IN ('Cat1', 'Cat2'); -- ItemId  = 17,18

-- ============================================================================
--  Raise request for Item for performing Activity 
-- ============================================================================ 

SELECT * FROM Request WHERE ActivityId = 6; -- no record

CALL sp_raise_request(
  6,-- p_ActivityId  INT,
  24,-- p_Requestor   INT,
  17,-- p_ItemId     INT,
  2-- p_Quantity   INT
);

CALL sp_raise_request(
  6,-- p_ActivityId  INT,
  24,-- p_Requestor   INT,
  18,-- p_ItemId     INT,
  1-- p_Quantity   INT
);

SELECT * FROM Request WHERE ActivityId = 6; -- (2 records) RequestId IN (26,27) Pending
SELECT * FROM RequestLog WHERE RequestId IN (26,27); -- (2 records) Pending, Request Created

-- ============================================================================
--  Approve request for Item for performing Activity 
-- ============================================================================ 

CALL sp_approve_request(
  26, -- p_RequestId INT,
  1 -- p_Approve BOOLEAN
);

CALL sp_approve_request(
  27, -- p_RequestId INT,
  1 -- p_Approve BOOLEAN
);

SELECT * FROM Request WHERE ActivityId = 6; -- RequestId IN (26,27) Approved
SELECT * FROM RequestLog WHERE RequestId IN (26,27) order by DateCreated; 
-- (4 Records)Recent2 -> Approved, Status changed From Pending to Approved

-- ============================================================================
--  Create purchase order with amount 0 for requested Item  
-- ============================================================================ 

SELECT * FROM PurchaseOrder WHERE ActivityId = 6; 

SET @result=0;
CALL sp_create_po(
	6, -- p_ActivityId INT
    @result -- p_POId      INT
);
SELECT @result AS result; -- POId = 7

SELECT * FROM PurchaseOrder WHERE ActivityId = 6; -- POId = 7 Amount 0, POStatus = Pending
SELECT * FROM POLog WHERE POId = 7; -- Pending
SELECT * FROM POItem WHERE POId = 7; -- no records

-- ============================================================================
--  Add the requested item against the created purchase order and update Amount   
-- ============================================================================ 

SELECT * FROM Item WHERE Category IN ('Cat1', 'Cat2');

CALL sp_log_PO_item(
  7, -- p_POId INT,
  17,-- p_ItemId INT,
  2,-- p_QuantityOrdered INT,
  10000 -- p_CostPerUnit FLOAT
);


CALL sp_log_PO_item(
  7, -- p_POId INT,
  18,-- p_ItemId INT,
  1,-- p_QuantityOrdered INT,
  20000 -- p_CostPerUnit FLOAT
);

SELECT * FROM PurchaseOrder WHERE ActivityId = 6; -- POId = 7 Amount 40000, POStatus = Pending
SELECT * FROM POItem WHERE POId = 7; -- (2 records 18,19; item 17,18)
SELECT * FROM POLog WHERE POId = 7; -- Pending

-- ============================================================================
--  Approve the purchase order   
-- ============================================================================ 

CALL sp_approve_PO(
  7 -- p_POId INT
);

SELECT * FROM PurchaseOrder WHERE ActivityId = 6; -- POId = 7 Amount 40000, POStatus = Approved
SELECT * FROM POLog WHERE POId = 7; -- (2 Records)Recent-> Approved, Status changed From Pending to Approved

SELECT * FROM LabActivity WHERE ActivityId = 6; -- Reduced funds  FundsAvailable = 11000
SELECT * FROM LabActivityLog WHERE ActivityId = 6; -- (3 Records) Recent-> Spent Funds Spent 40000

-- ============================================================================
--  Receive requested item (purchase order) and add it to asset  
-- ============================================================================

SELECT * FROM Asset WHERE LabId = 4; -- no record

CALL sp_receive_items(
  7, -- p_POId           INT,
  'Loc1',-- p_StorageLoc     VARCHAR(100),
  NULL,-- p_ShortDesc      VARCHAR(100),
  'S1'-- p_SerialNo       VARCHAR(100)
);

SELECT * FROM PurchaseOrder WHERE ActivityId = 6; -- POId = 7 Amount 40000, POStatus = Closed
SELECT * FROM POLog WHERE POId = 7; -- (3 Records) Recent->  Closed, Status changed From Approved to Closed
SELECT * FROM POItem WHERE POId = 7; -- No Change

SELECT * FROM Asset WHERE LabId = 4; -- AssetId IN (17,18)  Quantity 2,1
SELECT * FROM AssetTransactionLog WHERE AssetId IN (17,18); -- Added Quantity 2,1

-- ============================================================================
--  Close the Request for Items  
-- ============================================================================ 

SELECT * FROM Request WHERE ActivityId = 6; -- RequestId (26,27) Approved and is not closed
SELECT * FROM RequestLog WHERE RequestId IN (26,27) order by DateCreated;

 -- solved
CALL sp_close_request(
  26 -- p_RequestId INT
);

CALL sp_close_request(
  27 -- p_RequestId INT
);

SELECT * FROM Request WHERE ActivityId = 6; -- Request  closed
SELECT * FROM RequestLog WHERE RequestId IN (26,27) order by DateCreated; 
-- (6 Records) Recent 2-> Closed, Status changed From Approved to Closed

-- ============================================================================
--  Issue requested item to requestor and update asset  
-- ============================================================================ 

SELECT * FROM ActivityItemTransaction WHERE AssetId IN (17,18); -- No record

CALL sp_issue_assets(
  6, -- p_ActivityId     INT,
  17, -- p_AssetId        INT,
  24, -- p_Requestor      INT,
  23, -- p_ProcessedBy    INT,
  2, -- p_Quantity       INT,
  NULL -- p_ShortDesc      VARCHAR(100)
);

CALL sp_issue_assets(
  6, -- p_ActivityId     INT,
  18, -- p_AssetId        INT,
  24, -- p_Requestor      INT,
  23, -- p_ProcessedBy    INT,
  1, -- p_Quantity       INT,
  NULL -- p_ShortDesc      VARCHAR(100)
);

SELECT * FROM Asset WHERE LabId = 4; -- AssetId IN (17,18)  Quantity 0,0 
SELECT * FROM AssetTransactionLog WHERE AssetId IN (17,18) order by DateCreated; 
-- (4 records) recent 2 -> Issued Quantity 2,1

SELECT * FROM ActivityItemTransaction WHERE AssetId IN (17,18); -- Requestor 24 Issued Quantity 2,1

-- ============================================================================
--  If requestor returns item, then update asset 
-- ============================================================================

 CALL sp_return_assets(
  6, -- p_ActivityId     INT,
  17, -- p_AssetId        INT,
  24, -- p_Requestor      INT,
  23, -- p_ProcessedBy    INT,
  1, -- p_Quantity       INT,
  NULL-- p_ShortDesc      VARCHAR(100)
);  

SELECT * FROM Asset WHERE LabId = 4; 
-- AssetId IN (17,18), (updated for asset 17) Quantity 1,0 

SELECT * FROM AssetTransactionLog WHERE AssetId IN (17,18) order by DateCreated; 
-- (5 Records) Recent 1-> AssetId 17 Returned 1

SELECT * FROM ActivityItemTransaction WHERE AssetId IN (17,18) order by ActionDate; 
-- (3 records) recent-> AssetId 17 Returned 1

-- ============================================================================
--  If Some funds are to be removed/revoked from Activity, 
-- 	update lab funds as well as activity funds  
-- ============================================================================

SELECT * FROM LabActivity WHERE ActivityId = 6;  -- FundsAvailable = 11000
SELECT * FROM Lab WHERE LabId = 4; -- FundsAvailable = 59000, RecentActionTaken = 'Allocated'

CALL sp_deallocate_funds_from_activity(
  4,-- p_LabId INT,
  6,-- p_ActivityId INT,
  4000 -- p_Amount FLOAT
);

SELECT * FROM Lab WHERE LabId = 4; -- FundsAvailable = 63000, RecentActionTaken = 'Refunded'
SELECT * FROM LabLog WHERE LabId = 4; -- (5 Records) recent-> Refunded, Funds Refunded, Amount= 4000
 
 SELECT * FROM LabActivity WHERE ActivityId = 6; -- FundsAvailable = 7000
 SELECT * FROM LabActivityLog WHERE ActivityId = 6; -- (4 Records)Recent-> Refunded 4000

-- ============================================================================
-- If Activity is closed, then update lab funds, activity funds, 
-- take back items from requestor, update asset  
-- ============================================================================

CALL sp_close_activity(
  6 -- IN p_ActivityId INT
);

SELECT * FROM Lab WHERE LabId = 4; --  FundsAvailable = 70000, RecentActionTaken = 'Refunded'
SELECT * FROM LabLog WHERE LabId = 4; -- (6 Records)Recent 1-> Refunded, Funds Refunded, Amount= 7000
 
 SELECT * FROM LabActivity WHERE ActivityId = 6; -- IsClosed = 1 FundsAvailable = 0
 SELECT * FROM LabActivityLog WHERE ActivityId = 6; -- (5 Records)Recent 1-> Refunded Funds Refunded 7000

SELECT * FROM Asset WHERE LabId = 4; -- AssetId IN (17,18)  Quantity 2,1
SELECT * FROM AssetTransactionLog WHERE AssetId IN (17,18) order by dateCreated; 
-- (7 Records)Recent 2-> Returned 1,1

SELECT * FROM ActivityItemTransaction WHERE AssetId IN (17,18) order by ActionDate;  
-- (5 Records)Recent 2-> Returned 1,1

-- ============================================================================
--  Procedure to destroy asset and update asset accordingly 
-- ============================================================================
SELECT * FROM Asset WHERE LabId = 4; -- AssetId IN (17,18)  Quantity 2,1

CALL sp_destroy_asset(
  17, -- p_AssetId INT,
  1, -- p_Quantity INT,
  23, -- p_ProcessedBy INT,
  'Broken' -- p_ShortDesc VARCHAR(100)
);

SELECT * FROM Asset WHERE LabId = 4; -- AssetId IN (17,18)  Quantity 1,1
SELECT * FROM AssetTransactionLog WHERE AssetId IN (17, 18) order by dateCreated; 
-- Recent -> assetId 17,  Destroyed 1

-- ============================================================================
--  Procedure to get quantity item quantity available for item   
-- ============================================================================ 

SET @Quantity=0;
CALL sp_get_asset_quantity(
  17,--  p_AssetId INT,
  4, -- p_LabId INT,
 @Quantity -- p_Quantity INT
);
SELECT @Quantity AS Quantity; -- 1


SET @Quantity=0;
CALL sp_get_asset_quantity(
  18,--  p_AssetId INT,
  4, -- p_LabId INT,
 @Quantity -- p_Quantity INT
);
SELECT @Quantity AS Quantity; -- 1

-- ============================================================================
--  Procedure to get lab funds available for item  
-- ============================================================================

SET @TotalFund=0;
CALL sp_get_lab_funds(
  4, -- p_LabId INT,
  @TotalFund -- p_TotalFunds FLOAT
);
SELECT @TotalFund AS TotalFund; -- 70000

-- ============================================================================
-- +++++++++++++++++++++++++++++++++++++++++
-- Part 2:  check If enough quantity is available and no PO is required 
-- ============================================================================
-- Create Activity
-- ============================================================================

SELECT * FROM Lab WHERE LabId = 4;   -- FundsAvailable = 70000, RecentActionTaken = 'Refunded'
SELECT * FROM LabActivity WHERE LabId = 4;  -- ActivityId = 6,   IsClosed = 1 FundsAvailable = 0

CALL sp_create_activity(
  4,                 -- p_LabId (Assuming LabId = 1 for the lab where the activity is created)
  22,                 -- p_InitiatorId (UserId of the user creating the activity)
  'Lab',        -- p_Type (Type of activity, e.g., 'Research', 'Workshop')
  'AI Lab',     -- p_Description (Description of the activity)
  50000.00,          -- p_InitialFunds (Initial funds allocated for the activity)
  '2024-03-01 00:00:00', -- p_StartDate (Start date of the activity)
  '2025-05-31 23:59:59' -- p_EndDate (End date of the activity)
);

SELECT * FROM LabActivity WHERE LabId = 4;  -- ActivityId = 7,   IsClosed = 0 FundsAvailable = 50000
SELECT * FROM LabActivityLog WHERE ActivityId = 7; -- Added, Initial Funds = 50000

SELECT * FROM Lab WHERE LabId = 4;  -- FundsAvailable = 20000, RecentActionTaken = 'Allocated'
SELECT * FROM LabLog WHERE LabId = 4;  -- (7 records)Recent 1-> Allocated, 50000

-- No issue with RecentActionTaken

-- ============================================================================
-- Request Item for Activity
-- ============================================================================

SELECT * FROM Request WHERE ActivityId = 7; -- no record

CALL sp_raise_request(
  7,-- p_ActivityId  INT,
  24,-- p_Requestor   INT,
  17,-- p_ItemId     INT,
  1 -- p_Quantity   INT
);

SELECT * FROM Request WHERE ActivityId = 7; -- RequestId IN (28) Pending
SELECT * FROM RequestLog WHERE RequestId IN (28); -- Pending, Request Created

-- ============================================================================
-- Approve Request
-- ============================================================================

CALL sp_approve_request(
  28, -- p_RequestId INT,
  1 -- p_Approve BOOLEAN
);

SELECT * FROM Request WHERE ActivityId = 7; -- RequestId IN (28) Approved
SELECT * FROM RequestLog WHERE RequestId IN (28) order by DateCreated; -- (2 records)Recent-> Approved, Status changed From Pending to Approved

-- ============================================================================
-- Close request as item is available in Asset
-- ============================================================================

SELECT * FROM Asset WHERE LabId = 4; -- AssetId IN (17,18)  Quantity 1,1

CALL sp_close_request(
  28 -- p_RequestId INT
);

SELECT * FROM Request WHERE ActivityId = 7; -- Request  closed
SELECT * FROM RequestLog WHERE RequestId IN (28) order by DateCreated; -- (3 records)Recent- Closed, Status changed From Approved to Approved

-- ============================================================================
-- Issue requested item and update Asset
-- ============================================================================

CALL sp_issue_assets(
  7, -- p_ActivityId     INT,
  17, -- p_AssetId        INT,
  24, -- p_Requestor      INT,
  23, -- p_ProcessedBy    INT,
  1, -- p_Quantity       INT,
  NULL -- p_ShortDesc      VARCHAR(100)
);

SELECT * FROM Asset WHERE LabId = 4; -- AssetId IN (17,18)  Quantity 0,1 means item 17 issued
SELECT * FROM AssetTransactionLog WHERE AssetId IN (17,18) order by DateCreated; 
-- (10 records)Recent-> Issued asset 17 Quantity 1

SELECT * FROM ActivityItemTransaction WHERE AssetId IN (17,18) order by ActionDate; 
-- Activity 7  Issued asset 17 Quantity 1

-- ============================================================================
-- +++++++++++++++++++++++++++++++++++++++++
-- Part 3: Now again request one more item with Quantity 0
-- ============================================================================
-- Request Item for Activity
-- ============================================================================

SELECT * FROM Request order by DateCreated desc; -- Activity 7 closed
SELECT * FROM RequestLog order by DateCreated desc;

SELECT * FROM Asset WHERE LabId = 4; -- AssetId IN (17,18)  Quantity 0,1 means item 17 issued

-- raised request for item 17 quantity 0 in asset
CALL sp_raise_request(
  7,-- p_ActivityId  INT,
  24,-- p_Requestor   INT,
  17,-- p_ItemId     INT,
  1 -- p_Quantity   INT
); 

SELECT * FROM Request WHERE ActivityId = 7; -- RequestId IN (29) Pending
SELECT * FROM RequestLog WHERE RequestId IN (29); -- Pending, Request Created

-- ============================================================================
-- Approve Request
-- ============================================================================

CALL sp_approve_request(
  29, -- p_RequestId INT,
  1 -- p_Approve BOOLEAN
);

SELECT * FROM Request WHERE ActivityId = 7; -- RequestId IN (29) Approved
SELECT * FROM RequestLog WHERE RequestId IN (29) order by DateCreated; -- Approved, Status changed From Pending to Approved

-- ============================================================================
-- Close request as item is available in Asset
-- sp_close_request should give error message
-- ============================================================================

SELECT * FROM Asset WHERE LabId = 4; -- AssetId IN (17,18)  Quantity 0,1 means item17 quantity 0

CALL sp_close_request(
  29 -- p_RequestId INT
);  
-- Error: Insufficient asset stock to close the request 


SELECT * FROM Request WHERE ActivityId = 7; -- No change
SELECT * FROM RequestLog WHERE RequestId IN (29) order by DateCreated; -- No change

-- ============================================================================
--  AGAIN Repeat same procedure to CREATE PO and then ISSUE
-- ============================================================================

/*
items table item 16 isActive = null ?? should be 1

-- Problem in procedure sp_close_request
## Replace SQL by following 
SELECT r.ActivityId, a.AssetId, r.QuantityRequested
INTO v_ActivityId, v_AssetId, v_ReqQuantity
    FROM Request r, Asset a
    WHERE r.ItemId = a.ItemId
    AND	r.RequestId = p_RequestId
    FOR UPDATE;

-- Problem in procedure sp_deallocate_funds_from_activity
sp_deallocate_funds_from_activity Refund in Lab and in ActivityLog Spent
## Change order of update i.e. 1st lab then LabActivity

-- Problem in procedure sp_close_activity
Count miss-match asset and ActivityItemTransaction all records updated??? 
## Replace SQL by following
 UPDATE Asset A
      JOIN (
		SELECT A.AssetId, (A.Issued - COALESCE(B.Returned, 0)) TotalIssued
		FROM	(SELECT AssetId, SUM(Quantity) AS Issued
				FROM ActivityItemTransaction
			    WHERE ActivityId = p_ActivityId AND ActionTaken = 'Issued'
				GROUP BY AssetId) A
		LEFT OUTER JOIN 
				(SELECT AssetId, SUM(Quantity) AS Returned
				FROM ActivityItemTransaction
			    WHERE ActivityId = p_ActivityId AND ActionTaken = 'Returned'
				GROUP BY AssetId) B
		ON B.AssetId = A.AssetId
	) AS T ON A.AssetId = T.AssetId
	SET A.QuantityAvailable = A.QuantityAvailable + T.TotalIssued;
    
    INSERT INTO ActivityItemTransaction  
      (ActivityId, AssetId, Requestor, ActionTaken, ActionDate, Quantity)  
	SELECT F.ActivityId, F.AssetId, F.Requestor, 'Returned', NOW(), C.TotalIssued
	FROM ActivityItemTransaction F, 
		(SELECT A.AssetId, (A.Issued - COALESCE(B.Returned, 0)) TotalIssued
		FROM (SELECT AssetId, SUM(Quantity) AS Issued
				FROM ActivityItemTransaction
				WHERE ActivityId = p_ActivityId AND ActionTaken = 'Issued'
				GROUP BY AssetId) A
		LEFT OUTER JOIN 
				(SELECT AssetId, SUM(Quantity) AS Returned
				FROM ActivityItemTransaction
				WHERE ActivityId = p_ActivityId AND ActionTaken = 'Returned'
				GROUP BY AssetId) B
		ON B.AssetId = A.AssetId) C
	WHERE F.AssetId = C.AssetId
	AND F.ActivityId = p_ActivityId
	AND F.ActionTaken = 'Issued';
*/



  
    
 