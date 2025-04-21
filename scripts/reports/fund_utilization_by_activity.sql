-- filepath: scripts/reports/fund_utilization_by_activity.sql
USE AssetManagement;

SELECT  
  LA.ActivityDescription,  
  LA.FundsAvailable,  
  COALESCE(lal.Spent,0)    AS Spent,
  COALESCE(po.Purchased,0) AS Purchased
FROM LabActivity LA
LEFT JOIN (
  SELECT ActivityId,
         SUM(CASE WHEN ActionTaken='Added' THEN Funds ELSE 0 END)
       - SUM(CASE WHEN ActionTaken IN ('Spent','Closed') THEN Funds ELSE 0 END)
         AS Spent
    FROM LabActivityLog
   GROUP BY ActivityId
) lal ON lal.ActivityId = LA.ActivityId
LEFT JOIN (
  SELECT ActivityId, SUM(Amount) AS Purchased
    FROM PurchaseOrder
   WHERE POStatus='Closed'
   GROUP BY ActivityId
) po ON po.ActivityId = LA.ActivityId
ORDER BY Spent DESC;