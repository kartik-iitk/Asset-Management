SELECT  
  D.DeptName,  
  L.LabName,  
  L.FundsAvailable,  
  SUM(LA.FundsAllocated - LA.FundsAvailable) AS UsedByActivities  
FROM Lab L  
JOIN Department D USING(DeptId)  
LEFT JOIN LabActivity LA USING(LabId)  
GROUP BY D.DeptName, L.LabName;