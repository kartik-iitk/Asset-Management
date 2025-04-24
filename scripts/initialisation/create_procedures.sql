USE AssetManagement;

-- Consolidating DROP PROCEDURE statements 
DROP PROCEDURE IF EXISTS sp_create_user;
DROP PROCEDURE IF EXISTS sp_create_lab;
DROP PROCEDURE IF EXISTS sp_allocate_funds_to_lab;
DROP PROCEDURE IF EXISTS sp_create_activity;
DROP PROCEDURE IF EXISTS sp_allocate_funds_to_activity;
DROP PROCEDURE IF EXISTS sp_issue_assets;
DROP PROCEDURE IF EXISTS sp_create_item;
DROP PROCEDURE IF EXISTS sp_raise_request;
DROP PROCEDURE IF EXISTS sp_approve_request;
DROP PROCEDURE IF EXISTS sp_create_PO;
DROP PROCEDURE IF EXISTS sp_log_PO_item;
DROP PROCEDURE IF EXISTS sp_approve_PO;
DROP PROCEDURE IF EXISTS sp_receive_items;
DROP PROCEDURE IF EXISTS sp_close_request;
DROP PROCEDURE IF EXISTS sp_return_assets;
DROP PROCEDURE IF EXISTS sp_deallocate_funds_from_activity;
DROP PROCEDURE IF EXISTS sp_destroy_asset;
DROP PROCEDURE IF EXISTS sp_close_activity;
DROP PROCEDURE IF EXISTS sp_get_asset_quantity;
DROP PROCEDURE IF EXISTS sp_get_lab_funds;

DELIMITER $$

-- add_user procedure
CREATE PROCEDURE sp_create_user(
  IN p_Username      VARCHAR(20),
  IN p_Password      VARCHAR(100),
  IN p_InstituteId   VARCHAR(50),
  IN p_FirstName     VARCHAR(50),
  IN p_MiddleName    VARCHAR(50),
  IN p_LastName      VARCHAR(50),
  IN p_Gender        VARCHAR(10),
  IN p_DOB           DATE,
  IN p_Email         VARCHAR(50),
  IN p_Contact       VARCHAR(50),
  IN p_UserAddress   VARCHAR(100),
  IN p_RoleName      VARCHAR(20),
  IN p_LabName       VARCHAR(50)
)
BEGIN
  DECLARE v_UserId, v_LabId, v_DeptId, v_RoleId INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    -- Insert the new user based on the Users table definition
    INSERT INTO Users (
      UserName, 
      UserPassword, 
      InstituteId, 
      FirstName, 
      MiddleName, 
      LastName, 
      Gender, 
      DOB, 
      Email, 
      Contact, 
      UserAddress, 
      IsActive
    ) VALUES (
      p_Username, 
      p_Password, 
      p_InstituteId, 
      p_FirstName, 
      p_MiddleName, 
      p_LastName, 
      p_Gender, 
      p_DOB, 
      p_Email, 
      p_Contact, 
      p_UserAddress, 
      True
    );

    -- Get the auto-generated user ID
	SET v_UserId = LAST_INSERT_ID();

    SELECT RoleId INTO v_RoleId
    FROM Roles 
    WHERE RoleName = p_RoleName
    AND IsActive = 1; 

	SELECT LabId, DeptID 
    INTO v_LabId, v_DeptId 
    FROM Lab 
    WHERE LabName = p_LabName
    AND IsActive = 1;
    
    -- Assign the role to the user
    INSERT INTO UserRole (UserId, DeptId, LabId, RoleId, DateJoined, IsActive)
    VALUES (v_UserId, v_DeptId, v_LabId, v_RoleId, NOW(), True);
    
  COMMIT;
END$$

CREATE PROCEDURE sp_create_lab(
  IN p_DeptName      VARCHAR(50),
  IN p_LabName      VARCHAR(50),
  IN p_FundsAvailable   FLOAT
)
BEGIN
	DECLARE v_DeptId INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
	
    SELECT DeptId INTO v_DeptId
    FROM Department 
    WHERE DeptName = p_DeptName
    AND IsActive = 1; 
    
    -- Insert the new Lab under a Department
    INSERT INTO Lab (
      DeptId, 
      LabName, 
      FundsAvailable,
      IsActive
      ) VALUES (
      v_DeptId, 
      p_LabName, 
      p_FundsAvailable,
      True
    );

	COMMIT;
END$$

CREATE PROCEDURE sp_allocate_funds_to_lab(
  IN p_LabId   INT,
  IN p_Amount  FLOAT
)
BEGIN
  START TRANSACTION;
    UPDATE Lab
      SET FundsAvailable = FundsAvailable + p_Amount,
          RecentActionTaken = 'Added'
    WHERE LabId = p_LabId;
  COMMIT;
END$$

CREATE PROCEDURE sp_create_activity(
  IN p_LabId          INT,
  IN p_InitiatorId    INT,
  IN p_Type           VARCHAR(20),
  IN p_Description    VARCHAR(100),
  IN p_InitialFunds   FLOAT,
  IN p_StartDate      DATETIME,
  IN p_EndDate        DATETIME
)
BEGIN
  DECLARE v_FundsAvail FLOAT;
 
  SELECT FundsAvailable
    INTO v_FundsAvail
  FROM Lab
  WHERE LabId = p_LabId
  FOR UPDATE;

  IF v_FundsAvail < p_InitialFunds THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Insufficient funds for allocation';
  ELSEIF v_FundsAvail >= p_InitialFunds THEN
    START TRANSACTION;
    UPDATE Lab
      SET FundsAvailable = FundsAvailable - p_InitialFunds,
          RecentActionTaken = 'Allocated'
    WHERE LabId = p_LabId;

    INSERT INTO LabActivity
      (LabId, InitiatorId, ActivityType, ActivityDescription,
       FundsAvailable, StartDate, EndDate, IsClosed, DateCreated)
    VALUES
      (p_LabId, p_InitiatorId, p_Type, p_Description,
       p_InitialFunds, p_StartDate, p_EndDate, FALSE, NOW());
    COMMIT;
  END IF;

END$$


CREATE PROCEDURE sp_allocate_funds_to_activity(
  IN p_LabId       INT,
  IN p_ActivityId  INT,
  IN p_Amount      FLOAT
)
BEGIN
  DECLARE v_FundsAvail FLOAT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;
 
  SELECT FundsAvailable
    INTO v_FundsAvail
  FROM Lab
  WHERE LabId = p_LabId
  FOR UPDATE;

  IF v_FundsAvail < p_Amount THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Insufficient funds for allocation';
  ELSEIF v_FundsAvail >= p_Amount THEN
    START TRANSACTION;
    UPDATE Lab
      SET FundsAvailable = FundsAvailable - p_Amount,
          RecentActionTaken = 'Allocated'
    WHERE LabId = p_LabId;

    UPDATE LabActivity
      SET FundsAvailable = FundsAvailable + p_Amount
    WHERE ActivityId = p_ActivityId;
    COMMIT;
  END IF;
  
END$$

-- issue_assets procedure
CREATE PROCEDURE sp_issue_assets(
  IN p_ActivityId     INT,
  IN p_AssetId        INT,
  IN p_Requestor      INT,
  IN p_ProcessedBy    INT,
  IN p_Quantity       INT,
  IN p_ShortDesc      VARCHAR(100)
)
BEGIN
  DECLARE v_QuantityAvailable INT;

  START TRANSACTION;
    SELECT QuantityAvailable
      INTO v_QuantityAvailable
    FROM Asset
    WHERE AssetId = p_AssetId
    FOR UPDATE;

    IF v_QuantityAvailable < p_Quantity THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient asset quantity in the lab';
    END IF;

    INSERT INTO ActivityItemTransaction  
      (ActivityId, AssetId, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription)  
    VALUES  
      (p_ActivityId, p_AssetId, p_Requestor, p_ProcessedBy, 'Issued', NOW(), p_Quantity, p_ShortDesc);

    UPDATE Asset  
      SET QuantityAvailable = QuantityAvailable - p_Quantity  
    WHERE AssetId = p_AssetId;
  COMMIT;
END$$

-- create_item procedure
CREATE PROCEDURE sp_create_item(
    IN p_Category VARCHAR(20),
    IN p_Make VARCHAR(100),
    IN p_Model VARCHAR(100),
    IN p_WarrantyPeriodMonths INT,
    IN p_ItemDescription VARCHAR(100),
    IN p_CreatedBy INT
  )
  BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      ROLLBACK;
      RESIGNAL;
    END;

    START TRANSACTION;
      INSERT INTO Item (
        Category,
        Make,
        Model,
        WarrantyPeriodMonths,
        ItemDescription,
        CreatedBy,
        IsActive
      )
      VALUES (
        p_Category,
        p_Make,
        p_Model,
        p_WarrantyPeriodMonths,
        p_ItemDescription,
        p_CreatedBy,
        TRUE
      );
    COMMIT;
END$$

-- raise_request procedure
CREATE PROCEDURE sp_raise_request(
  IN p_ActivityId  INT,
  IN p_Requestor   INT,
  IN p_ItemId     INT,
  IN p_Quantity   INT
)
BEGIN
  START TRANSACTION;
    INSERT INTO Request  
      (ActivityID, RequestDate, Requestor, RequestStatus, ItemId, QuantityRequested)
    VALUES  
      (p_ActivityId, NOW(), p_Requestor, 'Pending', p_ItemId, p_Quantity);
  COMMIT;
END$$


-- create_request_item procedure
CREATE PROCEDURE sp_approve_request(
  IN p_RequestId INT,
  IN p_Approve BOOLEAN
)
BEGIN
  DECLARE v_RequestStatus VARCHAR(20);
  DECLARE v_DateApproved DATETIME DEFAULT NULL;
  DECLARE v_DateRejected DATETIME DEFAULT NULL;
  DECLARE v_CurrentStatus VARCHAR(20);

  -- Check if the request id is valid and if its status is still pending
  SELECT RequestStatus INTO v_CurrentStatus
  FROM Request
  WHERE RequestId = p_RequestId;

  IF v_CurrentStatus <> 'Pending' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The request is already completed and cannot be updated';
  END IF;

  IF p_Approve THEN
    SET v_RequestStatus = 'Approved';
    SET v_DateApproved = NOW();
  ELSE
    SET v_RequestStatus = 'Rejected';
    SET v_DateRejected = NOW();
  END IF;

  START TRANSACTION;
    UPDATE Request
      SET RequestStatus = v_RequestStatus
    WHERE RequestId = p_RequestId;
  COMMIT;
END$$

CREATE PROCEDURE sp_create_PO(
  IN p_ActivityId INT,
  OUT p_POId      INT
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    INSERT INTO PurchaseOrder
      (ActivityId, OrderDate, Amount, POStatus)
    VALUES
      (p_ActivityId, NOW(), 0, 'Pending');

    SET p_POId = LAST_INSERT_ID();
  COMMIT;
END$$


CREATE PROCEDURE sp_log_PO_item(
  IN p_POId INT,
  IN p_ItemId INT,
  IN p_QuantityOrdered INT,
  IN p_CostPerUnit FLOAT
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    INSERT INTO POItem (POId, ItemId, QuantityOrdered, CostPerUnit)
    VALUES (p_POId, p_ItemId, p_QuantityOrdered, p_CostPerUnit);

    UPDATE PurchaseOrder
    SET Amount = Amount + (p_QuantityOrdered * p_CostPerUnit)
    WHERE POId = p_POId;

  COMMIT;
END$$

CREATE PROCEDURE sp_approve_PO(
  IN p_POId INT
)
BEGIN
  DECLARE v_ActivityId  INT;
  DECLARE v_POAmount    FLOAT;
  DECLARE v_FundsAvail  FLOAT;
  DECLARE v_POStatus    VARCHAR(20);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    -- Validate that the PO exists and is not already approved/rejected
    SELECT POStatus, ActivityId, Amount
      INTO v_POStatus, v_ActivityId, v_POAmount
    FROM PurchaseOrder
    WHERE POId = p_POId
    FOR UPDATE;

    IF v_POStatus <> 'Pending' THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PO is already completed or invalid';
    END IF;

    -- Check funds available for the related activity
    SELECT FundsAvailable
      INTO v_FundsAvail
    FROM LabActivity
    WHERE ActivityId = v_ActivityId
    FOR UPDATE;

    IF v_POAmount > v_FundsAvail THEN
      -- Insufficient funds: reject PO, update status, and return error message
      UPDATE PurchaseOrder
      SET POStatus = 'Rejected',
        DateModified = NOW()
      WHERE POId = p_POId;
      
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Insufficient funds: PO is rejected';
    ELSE
      -- Sufficient funds: approve PO and update activity funds
      UPDATE PurchaseOrder
      SET POStatus = 'Approved',
        DateModified = NOW()
      WHERE POId = p_POId;

      UPDATE LabActivity
      SET FundsAvailable = FundsAvailable - v_POAmount
      WHERE ActivityId = v_ActivityId;
    END IF;

  COMMIT;
END$$

-- receive_items procedure
CREATE PROCEDURE sp_receive_items(
  IN p_POId           INT,
  IN p_StorageLoc     VARCHAR(100),
  IN p_ShortDesc      VARCHAR(100),
  IN p_SerialNo       VARCHAR(100)
)
BEGIN
  START TRANSACTION;
    INSERT INTO Asset (LabId, ItemId, QuantityAvailable, StorageLocation, ShortDescription, SerialNo)
    SELECT L.LabId, PI.ItemId, PI.QuantityOrdered, p_StorageLoc, p_ShortDesc, p_SerialNo
    FROM POItem PI  
      JOIN PurchaseOrder PO USING (POId)  
      JOIN LabActivity LA ON LA.ActivityId = PO.ActivityId  
      JOIN Lab L ON L.LabId = LA.LabId  
    WHERE PI.POId = p_POId
    ON DUPLICATE KEY UPDATE
      QuantityAvailable = QuantityAvailable + VALUES(QuantityAvailable),
      StorageLocation = IF(StorageLocation IS NULL OR StorageLocation = '', VALUES(StorageLocation), StorageLocation),
      ShortDescription = IF(ShortDescription IS NULL OR ShortDescription = '', VALUES(ShortDescription), ShortDescription),
      SerialNo = IF(SerialNo IS NULL OR SerialNo = '', VALUES(SerialNo), SerialNo);

    UPDATE PurchaseOrder  
      SET POStatus = 'Closed',
          DateModified = NOW()
    WHERE POId = p_POId;
  COMMIT;
END$$

-- close_request procedure
CREATE PROCEDURE sp_close_request(
  IN p_RequestId INT
)
BEGIN
  DECLARE v_ActivityId INT;
  DECLARE v_AssetId INT;
  DECLARE v_ReqQuantity INT;
  DECLARE v_StockQuantity INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    -- Fetch activity ID, the asset being requested, and the required quantity
    SELECT ActivityId, AssetId, RequestedQuantity
      INTO v_ActivityId, v_AssetId, v_ReqQuantity
    FROM Request
    WHERE RequestId = p_RequestId
    FOR UPDATE;

    -- Check if sufficient quantity is available in the asset stock
    SELECT QuantityAvailable
      INTO v_StockQuantity
    FROM Asset
    WHERE AssetId = v_AssetId
    FOR UPDATE;

    IF v_StockQuantity < v_ReqQuantity THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient asset stock to close the request';
    END IF;

    -- Close the request only if sufficient stock is available
    UPDATE Request
      SET RequestStatus = 'Closed',
          DateModified   = NOW()
    WHERE RequestId = p_RequestId;
    
  COMMIT;
END$$

CREATE PROCEDURE sp_return_assets(
  IN p_ActivityId     INT,
  IN p_AssetId        INT,
  IN p_Requestor      INT,
  IN p_ProcessedBy    INT,
  IN p_Quantity       INT,
  IN p_ShortDesc      VARCHAR(100)
)
BEGIN
  START TRANSACTION;
    INSERT INTO ActivityItemTransaction  
      (ActivityId, AssetId, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription)  
    VALUES  
      (p_ActivityId, p_AssetId, p_Requestor, p_ProcessedBy, 'Returned', NOW(), p_Quantity, p_ShortDesc);

    UPDATE Asset  
      SET QuantityAvailable = QuantityAvailable + p_Quantity  
    WHERE AssetId = p_AssetId;
  COMMIT;
END$$


CREATE PROCEDURE sp_deallocate_funds_from_activity(
  IN p_LabId INT,
  IN p_ActivityId INT,
  IN p_Amount FLOAT
)
BEGIN
  DECLARE v_ActivityFunds FLOAT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
  ROLLBACK;
  RESIGNAL;
  END;

  START TRANSACTION;
  SELECT FundsAvailable
    INTO v_ActivityFunds
  FROM LabActivity
  WHERE ActivityId = p_ActivityId
  FOR UPDATE;

  IF v_ActivityFunds < p_Amount THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient funds in the activity for deallocation';
  END IF;

  UPDATE LabActivity
    SET FundsAvailable = FundsAvailable - p_Amount
  WHERE ActivityId = p_ActivityId;

  UPDATE Lab
    SET FundsAvailable = FundsAvailable + p_Amount,
      RecentActionTaken = 'Refunded'
  WHERE LabId = p_LabId;
  COMMIT;
END$$


CREATE PROCEDURE sp_destroy_asset(
  IN p_AssetId INT,
  IN p_Quantity INT,
  IN p_ProcessedBy INT,
  IN p_ShortDesc VARCHAR(100)
)
BEGIN
  DECLARE v_QuantityAvailable INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    SELECT QuantityAvailable
      INTO v_QuantityAvailable
    FROM Asset
    WHERE AssetId = p_AssetId
    FOR UPDATE;

    IF v_QuantityAvailable < p_Quantity THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient asset quantity to destroy';
    END IF;

    UPDATE Asset
      SET QuantityAvailable = QuantityAvailable - p_Quantity
    WHERE AssetId = p_AssetId;

    INSERT INTO AssetTransactionLog (AssetId, ActionTakenBy, TransactionAction, Quantity, ShortDescription)
    VALUES (p_AssetId, p_ProcessedBy, 'Destroyed', p_Quantity, p_ShortDesc);
  COMMIT;
END$$

CREATE PROCEDURE sp_close_activity(
  IN p_ActivityId INT
)
BEGIN
  DECLARE v_LabId INT;
  DECLARE v_FundsAvail FLOAT;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    -- Refund remaining funds from the activity back to the lab
    SELECT LabId, FundsAvailable
      INTO v_LabId, v_FundsAvail
    FROM LabActivity
    WHERE ActivityId = p_ActivityId
    FOR UPDATE;
    
    UPDATE Lab
      SET FundsAvailable = FundsAvailable + v_FundsAvail,
          RecentActionTaken = 'Refunded'
    WHERE LabId = v_LabId;
    
    -- Close the activity: reset funds and update the isClosed flag
    UPDATE LabActivity
      SET FundsAvailable = 0,
          IsClosed = TRUE,
		      EndDate =  NOW()
    WHERE ActivityId = p_ActivityId;

    -- Return all issued assets: add back quantities to Asset and mark transactions as returned
    UPDATE Asset A
      JOIN (
        SELECT AssetId, SUM(Quantity) AS TotalIssued
        FROM ActivityItemTransaction
        WHERE ActivityId = p_ActivityId AND ActionTaken = 'Issued'
        GROUP BY AssetId
      ) AS T ON A.AssetId = T.AssetId
      SET A.QuantityAvailable = A.QuantityAvailable + T.TotalIssued;

    UPDATE ActivityItemTransaction
      SET ActionTaken = 'Returned'
    WHERE ActivityId = p_ActivityId
      AND ActionTaken = 'Issued';
      
  COMMIT;
END$$

CREATE PROCEDURE sp_get_asset_quantity(
  IN p_AssetId INT,
  IN p_LabId INT,
  OUT p_Quantity INT
)
BEGIN
  SELECT QuantityAvailable
    INTO p_Quantity
  FROM Asset
  WHERE AssetId = p_AssetId
    AND LabId = p_LabId;
END$$

CREATE PROCEDURE sp_get_lab_funds(
  IN p_LabId INT,
  OUT p_TotalFunds FLOAT
)
BEGIN
  SELECT FundsAvailable
    INTO p_TotalFunds
  FROM Lab
  WHERE LabId = p_LabId;
END$$

DELIMITER ;
