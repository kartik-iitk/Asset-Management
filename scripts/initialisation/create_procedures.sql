USE AssetManagement;

-- Consolidating DROP PROCEDURE statements 
DROP PROCEDURE IF EXISTS sp_add_Lab;
DROP PROCEDURE IF EXISTS sp_add_user;
DROP PROCEDURE IF EXISTS sp_add_lab_funds;
DROP PROCEDURE IF EXISTS sp_allocate_funds;
DROP PROCEDURE IF EXISTS sp_approve_po;
DROP PROCEDURE IF EXISTS sp_approve_request;
DROP PROCEDURE IF EXISTS sp_close_activity;
DROP PROCEDURE IF EXISTS sp_create_asset;
DROP PROCEDURE IF EXISTS sp_create_item;
DROP PROCEDURE IF EXISTS sp_create_lab_activity;
DROP PROCEDURE IF EXISTS sp_create_purchase;
DROP PROCEDURE IF EXISTS sp_deactivate_user;
DROP PROCEDURE IF EXISTS sp_issue_assets;
DROP PROCEDURE IF EXISTS sp_raise_request;
DROP PROCEDURE IF EXISTS sp_receive_items;
DROP PROCEDURE IF EXISTS sp_return_assets;

DELIMITER $$

CREATE PROCEDURE sp_add_Lab(
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
      FundsAvailable
      ) VALUES (
      v_DeptId, 
      p_LabName, 
      p_FundsAvailable
    );

	COMMIT;
END$$

-- add_user procedure
CREATE PROCEDURE sp_add_user(
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

-- add_lab_funds procedure
-- To invoke:
-- CALL sp_add_lab_funds(1, 5000.00);

CREATE PROCEDURE sp_add_lab_funds(
  IN p_LabId   INT,
  IN p_Amount  FLOAT
)
BEGIN
  START TRANSACTION;
    UPDATE Lab
      SET FundsAvailable = FundsAvailable + p_Amount,
          RecentActionTaken = 'Added Funds to Lab'
    WHERE LabId = p_LabId;
  COMMIT;
END$$

-- allocate_funds procedure
CREATE PROCEDURE sp_allocate_funds(
  IN p_LabId       INT,
  IN p_ActivityId  INT,
  IN p_Amount      FLOAT
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  DECLARE v_FundsAvail FLOAT;
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
          RecentActionTaken = 'Allocated Funds to Activity'
    WHERE LabId = p_LabId;

    UPDATE LabActivity
      SET FundsAvailable = FundsAvailable + p_Amount
    WHERE ActivityId = p_ActivityId;
    COMMIT;
  END IF;

  
END$$


-- approve_po procedure
CREATE PROCEDURE sp_approve_po(
  IN p_POId INT
)
BEGIN
  DECLARE v_ActivityId  INT;
  DECLARE v_POAmount    FLOAT;
  DECLARE v_FundsAvail  FLOAT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    -- fetch PO's amount & activity
    SELECT ActivityId, Amount
      INTO v_ActivityId, v_POAmount
    FROM PurchaseOrder
    WHERE POId = p_POId
    FOR UPDATE;

    -- check activity funds
    SELECT FundsAvailable
      INTO v_FundsAvail
    FROM LabActivity
    WHERE ActivityId = v_ActivityId
    FOR UPDATE;

    IF v_POAmount > v_FundsAvail THEN
      -- insufficient funds: reject this PO
      UPDATE PurchaseOrder
        SET POStatus='Rejected',
            DateModified=NOW()
      WHERE POId = p_POId;
    ELSEIF v_POAmount <= v_FundsAvail THEN
      -- sufficient funds: approve this PO
      UPDATE PurchaseOrder
        SET POStatus='Approved',
            DateModified=NOW()
      WHERE POId = p_POId;

      UPDATE LabActivity
        SET FundsAvailable = FundsAvailable - v_POAmount
      WHERE ActivityId = v_ActivityId;
    END IF;

  COMMIT;
END$$

-- approve_request procedure
CREATE PROCEDURE sp_approve_request (IN p_RequestId INT, OUT p_HasMissing INT)
BEGIN
    DECLARE v_missing_count      INT DEFAULT 0;
    DECLARE v_insufficient_count INT DEFAULT 0;

    /*  Roll back everything if *anything* goes wrong  */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    /* ------------------ 1) any item missing in the lab? ------------------ */
    SELECT COUNT(*)
      INTO v_missing_count
      FROM RequestItem  ri
      JOIN `Request`    r   USING (RequestId)
      JOIN LabActivity  la  USING (ActivityId)
      LEFT JOIN Asset   a
             ON  a.ItemId = ri.ItemId
             AND a.LabId  = la.LabId
     WHERE ri.RequestId = p_RequestId
       AND a.AssetId IS NULL;

    /* -------- 2) any item requested in quantity greater than stock? ------ */
    IF v_missing_count = 0 THEN     -- do step‑2 only when step‑1 passed
        SELECT COUNT(*)
          INTO v_insufficient_count
          FROM (
                SELECT ri.ItemId,
                       SUM(IFNULL(a.QuantityAvailable,0)) AS AvailQty,
                       ri.QuantityRequested                AS ReqQty
                  FROM RequestItem  ri
                  JOIN `Request`    r   USING (RequestId)
                  JOIN LabActivity  la  USING (ActivityId)
                  JOIN Asset        a
                         ON  a.ItemId = ri.ItemId
                         AND a.LabId  = la.LabId
                 WHERE ri.RequestId = p_RequestId
                 GROUP BY ri.ItemId, ri.QuantityRequested
                 HAVING AvailQty < ri.QuantityRequested
               ) AS subq;
    END IF;

    /* -------- 3) decide the final status in ONE place -------------------- */
    IF v_missing_count  > 0
       OR v_insufficient_count > 0
    THEN
        
    ELSE
        UPDATE `Request`
           SET RequestStatus = 'Approved',
               DateModified  = NOW()
         WHERE RequestId = p_RequestId;
    END IF;

    /* set OUT parameter: 1 if any missing, else 0 */
    SET p_HasMissing = IF(v_missing_count > 0, 1, 0);

    COMMIT;        -- all done

    
END $$

-- close_activity procedure
CREATE PROCEDURE sp_close_activity(
  IN p_ActivityId INT
)
BEGIN
  DECLARE v_LabId      INT;
  DECLARE v_FundsAvail FLOAT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    -- fetch lab and remaining funds for this activity
    SELECT LabId, FundsAvailable
      INTO v_LabId, v_FundsAvail
    FROM LabActivity
    WHERE ActivityId = p_ActivityId
    FOR UPDATE;

    -- refund leftover funds back to the lab
    UPDATE Lab
      SET FundsAvailable = FundsAvailable + v_FundsAvail,
          RecentActionTaken = 'Refunded Funds from Activity'
    WHERE LabId = v_LabId;

    -- close the activity
    UPDATE LabActivity
      SET FundsAvailable = 0,
          IsClosed       = TRUE,
          DateModified   = NOW()
    WHERE ActivityId = p_ActivityId;
  COMMIT;
END$$

-- create_asset procedure
-- example usage:
-- CALL sp_create_asset(1, 3, 'SN-0001', 10, 'Shelf A', 'New Microscope');

CREATE PROCEDURE sp_create_asset(
  IN p_LabId             INT,
  IN p_ItemId            INT,
  IN p_SerialNo          VARCHAR(20),
  IN p_QuantityAvailable INT,
  IN p_StorageLocation   VARCHAR(100),
  IN p_ShortDescription  VARCHAR(100)
)
BEGIN
  START TRANSACTION;
    INSERT INTO Asset
      (LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription)
    VALUES
      (p_LabId, p_ItemId, p_SerialNo, p_QuantityAvailable, p_StorageLocation, p_ShortDescription);
  COMMIT;
END$$

-- create_item procedure
-- To invoke from mysql> prompt:
-- CALL sp_create_item(
--   'Camera',       -- p_Category
--   'Canon',        -- p_Make
--   'EOS 1500D',    -- p_Model
--   24,             -- p_WarrantyMonths
--   'DSLR camera',  -- p_ItemDescription
--   1,              -- p_CreatedByUserId
--   TRUE            -- p_IsActive
-- );

CREATE PROCEDURE sp_create_item(
  IN p_Category           VARCHAR(50),
  IN p_Make               VARCHAR(100),
  IN p_Model              VARCHAR(100),
  IN p_WarrantyMonths     INT,
  IN p_ItemDescription    VARCHAR(255),
  IN p_CreatedByUserId    INT,
  IN p_IsActive           BOOLEAN
)
BEGIN
  START TRANSACTION;
    INSERT INTO Item
      (Category
      ,Make
      ,Model
      ,WarrantyPeriodMonths
      ,ItemDescription
      ,CreatedBy
      ,DateCreated
      ,IsActive)
    VALUES
      (p_Category
      ,p_Make
      ,p_Model
      ,p_WarrantyMonths
      ,p_ItemDescription
      ,p_CreatedByUserId
      ,NOW()
      ,p_IsActive);
  COMMIT;
END$$

-- create_lab_activity procedure
-- To invoke:
-- CALL sp_create_lab_activity(
--   1,            -- LabId
--   5,            -- InitiatorId
--   'Research',   -- Type
--   'Desc here',  -- Description
--   5000.00,      -- InitialFunds
--   NOW(),        -- StartDate
--   NULL,         -- EndDate
--   FALSE         -- IsClosed
-- );

CREATE PROCEDURE sp_create_lab_activity(
  IN p_LabId          INT,
  IN p_InitiatorId    INT,
  IN p_Type           VARCHAR(20),
  IN p_Description    VARCHAR(100),
  IN p_InitialFunds   FLOAT,
  IN p_StartDate      DATETIME,
  IN p_EndDate        DATETIME,
  IN p_IsClosed       BOOLEAN
)
BEGIN
  START TRANSACTION;
    INSERT INTO LabActivity
      (LabId, InitiatorId, ActivityType, ActivityDescription,
       FundsAvailable, StartDate, EndDate, IsClosed, DateCreated)
    VALUES
      (p_LabId, p_InitiatorId, p_Type, p_Description,
       p_InitialFunds, p_StartDate, p_EndDate, p_IsClosed, NOW());
  COMMIT;
END$$

-- create_purchase procedure
-- To invoke:
-- CALL sp_create_purchase(<ActivityId>, <Amount>);

CREATE PROCEDURE sp_create_purchase(
  IN p_ActivityId INT,
  IN p_Amount     FLOAT
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
      (p_ActivityId, NOW(), p_Amount, 'Generated');
  COMMIT;
END$$

-- deactivate_user procedure
CREATE PROCEDURE sp_deactivate_user(
  IN p_UserId INT
)
BEGIN
  START TRANSACTION;
    UPDATE Users
      SET IsActive     = FALSE,
          DateModified = NOW()
    WHERE UserId = p_UserId;
  COMMIT;
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
  START TRANSACTION;
    INSERT INTO ActivityItemTransaction  
      (ActivityId, AssetId, Requestor, ProcessedBy, ActionTaken, ActionDate, Quantity, ShortDescription)  
    VALUES  
      (p_ActivityId, p_AssetId, p_Requestor, p_ProcessedBy, 'Issued', NOW(), p_Quantity, p_ShortDesc);

    UPDATE Asset  
      SET QuantityAvailable = QuantityAvailable - p_Quantity  
    WHERE AssetId = p_AssetId;
  COMMIT;
END$$

-- raise_request procedure
CREATE PROCEDURE sp_raise_request(
  IN p_ActivityId  INT,
  IN p_Requestor   INT
)
BEGIN
  START TRANSACTION;
    INSERT INTO Request  
      (ActivityID, RequestDate, Requestor, RequestStatus)  
    VALUES  
      (p_ActivityId, NOW(), p_Requestor, 'Generated');
  COMMIT;
END$$

-- receive_items procedure
CREATE PROCEDURE sp_receive_items(
  IN p_POId           INT,
  IN p_StorageLoc     VARCHAR(100),
  IN p_ShortDesc      VARCHAR(100)
)
BEGIN
  START TRANSACTION;
    -- 1) mark PO received
    UPDATE PurchaseOrder  
      SET POStatus='Received', DateModified=NOW()  
    WHERE POId = p_POId;

    -- 2) for each POItem, insert into Asset
    INSERT INTO Asset (LabId, ItemId, SerialNo, QuantityAvailable, StorageLocation, ShortDescription)  
    SELECT L.LabId, PI.ItemId, CONCAT('PO',p_POId,'-',PI.POItemId),
           PI.QuantityOrdered, p_StorageLoc, p_ShortDesc
    FROM POItem PI  
    JOIN PurchaseOrder PO USING (POId)  
    JOIN LabActivity LA ON LA.ActivityId=PO.ActivityId  
    JOIN Lab L ON L.LabId=LA.LabId  
    WHERE PI.POId = p_POId;

    -- 3) close the PO
    UPDATE PurchaseOrder  
      SET POStatus='Closed', DateModified=NOW()  
    WHERE POId = p_POId;
  COMMIT;
END$$

-- return_assets procedure
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

DELIMITER ;
