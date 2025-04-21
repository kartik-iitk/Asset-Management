USE AssetManagement;

SELECT  
  LA.ActivityDescription,  
  LA.FundsAllocated,  
  LA.FundsAvailable,  
  (LA.FundsAllocated - LA.FundsAvailable)    AS Spent,  
  COALESCE(po.purchase,0)                   AS Purchased  
FROM LabActivity LA  
LEFT JOIN (
    SELECT ActivityId, SUM(Amount) AS purchase
      FROM PurchaseOrder
     WHERE POStatus='Closed'
     GROUP BY ActivityId
  ) po ON po.ActivityId = LA.ActivityId  
ORDER BY Spent DESC;