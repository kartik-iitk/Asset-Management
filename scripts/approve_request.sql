USE AssetManagement;
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_approve_request $$
CREATE PROCEDURE sp_approve_request (IN p_RequestId INT)
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
        UPDATE `Request`
           SET RequestStatus = 'Rejected',
               DateModified  = NOW()
         WHERE RequestId = p_RequestId;
    ELSE
        UPDATE `Request`
           SET RequestStatus = 'Approved',
               DateModified  = NOW()
         WHERE RequestId = p_RequestId;
    END IF;

    COMMIT;        -- all done
END $$
DELIMITER ;
