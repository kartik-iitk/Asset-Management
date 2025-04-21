-- filepath: scripts/reports/lab_fund_usage.sql
USE AssetManagement;

SELECT  
  D.DeptName,  
  L.LabName,  
  L.FundsAvailable,  
  COALESCE(actlogs.Added,0) AS TotalAllocated,
  COALESCE(actlogs.Spent,0) AS TotalSpent,
  COALESCE(po.Purchase,0)   AS SpentOnPOs
FROM Lab L  
JOIN Department D USING(DeptId)  
LEFT JOIN (
    SELECT LA.LabId,
           SUM(CASE WHEN LAL.ActionTaken='Added' THEN LAL.Funds ELSE 0 END) AS Added,
           SUM(CASE WHEN LAL.ActionTaken='Spent' THEN LAL.Funds ELSE 0 END) AS Spent
      FROM LabActivityLog LAL
      JOIN LabActivity LA ON LA.ActivityId = LAL.ActivityId
     GROUP BY LA.LabId
) actlogs ON actlogs.LabId = L.LabId
LEFT JOIN (
    SELECT LA.LabId, SUM(PO.Amount) AS Purchase
      FROM PurchaseOrder PO
      JOIN LabActivity LA ON LA.ActivityId = PO.ActivityId
     WHERE PO.POStatus='Closed'
     GROUP BY LA.LabId
) po ON po.LabId = L.LabId
GROUP BY D.DeptName, L.LabName;