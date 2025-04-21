-- filepath: scripts/reports/lab_fund_usage.sql
USE AssetManagement;

SELECT  
  D.DeptName,  
  L.LabName,  
  L.FundsAvailable,  
  SUM(LA.FundsAllocated - LA.FundsAvailable)    AS UsedByActivities,
  COALESCE(po_total.purchase,0)                 AS SpentOnPOs
FROM Lab L  
JOIN Department D USING(DeptId)  
LEFT JOIN LabActivity LA USING(LabId)  
LEFT JOIN (
    SELECT ActivityId, SUM(Amount) AS purchase
      FROM PurchaseOrder
     WHERE POStatus = 'Closed'
     GROUP BY ActivityId
  ) po ON po.ActivityId = LA.ActivityId
LEFT JOIN (
    SELECT ActivityId, SUM(purchase) AS purchase
      FROM (
         SELECT ActivityId, SUM(Amount) AS purchase
           FROM PurchaseOrder
          WHERE POStatus = 'Closed'
          GROUP BY ActivityId
       ) t
     GROUP BY ActivityId
  ) po_total ON po_total.ActivityId = LA.ActivityId
GROUP BY D.DeptName, L.LabName;