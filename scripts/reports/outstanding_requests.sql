SELECT
  R.RequestId,
  U.FirstName,
  U.LastName,
  LA.ActivityDescription,
  R.RequestDate,
  R.RequestStatus
FROM Request  AS R
JOIN Users    AS U  ON U.UserId       = R.Requestor
JOIN LabActivity AS LA ON LA.ActivityId = R.ActivityID
WHERE R.RequestStatus IN ('Generated','Approved')
ORDER BY R.RequestDate;