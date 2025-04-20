USE AssetManagement;
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_lab_activity$$
CREATE PROCEDURE sp_create_lab_activity(
  IN p_LabId          INT,
  IN p_InitiatorId    INT,
  IN p_Type           VARCHAR(20),
  IN p_Description    VARCHAR(100),
  IN p_FundsAllocated FLOAT,
  IN p_StartDate      DATETIME,
  IN p_EndDate        DATETIME,
  IN p_IsClosed       BOOLEAN
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
    INSERT INTO LabActivity
      (LabId, InitiatorId, ActivityType, ActivityDescription,
       FundsAllocated, FundsAvailable, StartDate, EndDate,
       IsClosed, DateCreated)
    VALUES
      (p_LabId, p_InitiatorId, p_Type, p_Description,
       p_FundsAllocated, p_FundsAllocated, p_StartDate,
       p_EndDate, p_IsClosed, NOW());
  COMMIT;
END$$
DELIMITER ;

-- To invoke:
-- CALL sp_create_lab_activity(
--   1,            -- LabId
--   5,            -- InitiatorId
--   'Research',   -- Type
--   'Desc here',  -- Description
--   5000.00,      -- FundsAllocated
--   NOW(),        -- StartDate
--   NULL,         -- EndDate
--   FALSE         -- IsClosed
-- );