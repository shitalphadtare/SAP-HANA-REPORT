CREATE PROCEDURE PTS_BANK_BOOK
(
IN Fromdate Timestamp
,IN ToDate Timestamp
,IN Bank nvarchar(500)
/*,@Narration bit
,@Cheque bit
,@Daily bit
,@Monthly bit
,@Yearly bit*/
,IN Currency nvarchar(10))
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
--READ SQL DATA 
AS
 Begin
with Query1 as(
SELECT T0."AcctCode", T0."AcctName" || '(' || t0."FormatCode" || ')' || ' ' AS "AcctName", 
(CASE WHEN T0."ActCurr" = 'INR' OR T0."ActCurr" = '##' THEN '(Local)' ELSE '(FC)' END) AS "Currency", 
T2."RefDate" AS "Date1", (
CASE WHEN T2."TransType" = 46 THEN (CASE WHEN (:Currency = 'Local') THEN IFNULL(T1."Debit", 0) ELSE IFNULL(T1."FCDebit", 0) END) 
     WHEN T2."TransType" = 24 THEN (CASE WHEN (:Currency = 'Local') THEN IFNULL(T1."Debit", 0) ELSE IFNULL(T1."FCDebit", 0) END) 
     WHEN T2."TransType" = 30 THEN (CASE WHEN (:Currency = 'Local') THEN IFNULL(T1."Debit", 0) ELSE IFNULL(T1."FCDebit", 0) END)
     END) AS "Debit", 
(CASE WHEN T2."TransType" = 46 THEN (CASE WHEN (:Currency = 'Local') THEN IFNULL(T1."Credit", 0) ELSE IFNULL(T1."FCCredit", 0) END) 
	  WHEN T2."TransType" = 24 THEN (CASE WHEN (:Currency = 'Local') THEN IFNULL(T1."Credit", 0) ELSE IFNULL(T1."FCCredit", 0) END) 
	  WHEN T2."TransType" = 30 THEN (CASE WHEN (:Currency = 'Local') THEN IFNULL(T1."Credit", 0) ELSE IFNULL(T1."FCCredit", 0) END) END) AS "Credit", 
	  T1."TransId", 
	  T2."TransType", 
(CASE WHEN T2."TransType" = 46 THEN IFNULL(T5."SeriesName",'') || '/' || CAST(T4."DocNum" AS char) 
      WHEN T2."TransType" = 24 THEN IFNULL(T7."SeriesName",'') || '/' || CAST(T6."DocNum" AS char) 
      WHEN T2."TransType" = 30 THEN IFNULL(T10."SeriesName",'') || '/' || CAST(T2."Number" AS char) END) AS "Document No", 
(CASE WHEN T2."TransType" = 30 THEN 'Journal Entry' WHEN T2."TransType" = 140000009 THEN 'Outgoing Ex Invoice' 
WHEN T2."TransType" = 24 THEN 'Incoming Payment' ELSE 'Outgoing Payment' END) AS "Transction Name", 
(CASE WHEN T2."TransType" = 24 AND T6."DocType" <> 'A' THEN T6."CardName" WHEN T2."TransType" = 46 AND T4."DocType" <> 'A' 
THEN T4."CardName" ELSE CASE WHEN (SELECT COUNT("Line_ID") FROM JDT1 WHERE "TransId" = t1."TransId") > 2 
---changes done on 11-11-2019
THEN 'Payment To/From GL Accounts' ELSE (CASE WHEN T3."Segment_0" <> '' 
THEN IFNULL(T3."Segment_0",'') || '-' || IFNULL(T3."Segment_1",'') || ' ' || IFNULL(T3."AcctName",'') ELSE IFNULL(T3."AcctCode",'')
 || ' ' || IFNULL(T3."AcctName",'') END) END END) AS "BP/GL Code", 
--CASE WHEN :Narration = 1 THEN 
(CASE WHEN T2."TransType" = 46 THEN T11."Descrip" WHEN T2."TransType" = 24 THEN T12."Descrip" WHEN T2."TransType" = 30 
THEN T2."Memo" END) "Description 1", 
--CASE WHEN :Narration = 1 THEN 
(CASE WHEN T2."TransType" = 46 THEN T4."Comments" WHEN T2."TransType" = 24 THEN T6."Comments" END) "Description 3", 
--(CASE WHEN :Cheque = 1 THEN 
----changes on 24-10-2019
--- CAST((CASE WHEN T2."TransType" = 46 THEN T8."CheckNum" WHEN T2."TransType" = 24 THEN T9."CheckNum" END) AS char) 
 CAST((CASE WHEN T2."TransType" = 46 THEN 'Ch No. ' ||t8."CheckNum" 
 WHEN T2."TransType" = 24 THEN 'Ch No. ' ||t9."CheckNum" end) as varchar)
"Description 2", 
DAYOFMONTH(T2."RefDate") "Dt"
--,left  EXTRACT (Month FROM  TO_DATE (Cast(T2."RefDate" as CHAR), 'YYYY-MM-DD')) as "Mnth"  --  CONVERT(VARCHAR(10),T2."RefDate",101),2) as "Mnth"  
,year(T2."RefDate") "yr1"        
 ,month(T2."RefDate") "Mnth" ,
(SELECT COUNT("Line_ID") FROM JDT1 WHERE "TransId" = t1."TransId") AS "Count" 
FROM OACT T0 INNER JOIN JDT1 T1 ON T1."Account" = T0."AcctCode" 
LEFT OUTER JOIN OACT T3 ON T1."ContraAct" = T3."AcctCode" 
INNER JOIN OJDT T2 ON T1."TransId" = T2."TransId" AND T2."TransType" IN (30,140000009,24,46) 
LEFT OUTER JOIN (SELECT W1."Series", W1."SeriesName", W2."TransId" FROM NNM1 W1 INNER JOIN OJDT W2 ON W1."Series" = W2."Series") AS T10 ON T10."Series" = T2."Series" AND T2."TransId" = T10."TransId" 
LEFT OUTER JOIN OVPM T4 ON T4."DocNum" = (CASE WHEN T1."TransType" = 46 THEN T1."BaseRef" ELSE NULL END) AND T1."RefDate" = T4."DocDate" 
LEFT OUTER JOIN (SELECT W1."Series", "SeriesName", W2."DocNum" FROM NNM1 W1 INNER JOIN OVPM W2 ON W1."Series" = W2."Series") AS T5 ON T4."Series" = T5."Series" AND T4."DocNum" = T5."DocNum" 
LEFT OUTER JOIN (SELECT "CheckNum" , "DocNum" FROM VPM1 where "LineID"=0) AS T8 ON T8."DocNum" = T4."DocEntry"
 LEFT OUTER JOIN (SELECT "Descrip", "DocNum", "LineId" FROM VPM4  ) AS T11 ON T11."DocNum" = T4."DocEntry" AND T11."LineId" = 0 
 LEFT OUTER JOIN ORCT T6 ON T6."DocNum" = (CASE WHEN T1."TransType" = 24 THEN T1."BaseRef" ELSE null END) AND T1."RefDate" = T6."DocDate"
  LEFT OUTER JOIN (SELECT W1."Series", "SeriesName", W2."DocNum" FROM NNM1 W1 INNER JOIN ORCT W2 ON W1."Series" = W2."Series") AS T7 ON T6."Series" = T7."Series" AND T6."DocNum" = T7."DocNum" 
  LEFT OUTER JOIN (SELECT top 1 "CheckNum", "DocNum" FROM RCT1) AS T9 ON T9."DocNum" = T6."DocEntry" 
  LEFT OUTER JOIN (SELECT "Descrip", "DocNum", "LineId" FROM RCT4) AS T12 ON T12."DocNum" = T6."DocEntry" AND T12."LineId" = 0 
	  WHERE T0."Finanse" = 'Y' AND T0."AcctName" = :Bank AND T2."RefDate" >= :Fromdate AND T2."RefDate" <= :ToDate
	  group by T0."AcctCode", T0."AcctName",t0."FormatCode",T0."ActCurr",T2."RefDate",T2."TransType" ,T1."FCCredit",T1."FCDebit",T1."Debit",T1."Credit"
	  ,T1."TransId",T5."SeriesName" ,T7."SeriesName" ,T10."SeriesName",T4."DocNum",T6."DocNum",T2."Number",T3."AcctCode"
	  ,T3."AcctName",T3."Segment_0",T3."Segment_1",T6."DocType",T6."CardName",T4."DocType",T4."CardName",T11."Descrip"
	  ,T12."Descrip",T2."Memo",T4."Comments",T6."Comments",T8."CheckNum",T9."CheckNum",T4."Address"
),
--------------------------------------------------------**************************-----------------------------------------------------
Query2 as(

SELECT T0."AcctCode", SUM((CASE WHEN :Currency = 'Local' 
THEN (CASE WHEN T2."RefDate" < :Fromdate THEN IFNULL(T1."Debit", 0) ELSE 0 END) 
ELSE (CASE WHEN T2."RefDate" < :Fromdate THEN IFNULL(T1."FCDebit", 0) ELSE 0 END) END)) - 
SUM((CASE WHEN :Currency = 'Local' THEN (CASE WHEN T2."RefDate" < :Fromdate THEN IFNULL(T1."Credit", 0) ELSE 0 END) 
ELSE (CASE WHEN T2."RefDate" < :Fromdate THEN IFNULL(T1."FCCredit", 0) ELSE 0 END) END)) AS "Opening Balance"
 FROM OACT T0 
 INNER JOIN JDT1 T1 ON T1."Account" = T0."AcctCode" 
 INNER JOIN OJDT T2 ON T1."TransId" = T2."TransId" 
 WHERE T0."Finanse" = 'Y' AND T0."AcctName" = :Bank GROUP BY T0."AcctCode" )


-------------------------------------------------*******************************---------------------------------------------------

select *
from 
Query1 C1
inner join Query2 C2 on C1."AcctCode" = C2."AcctCode"
order by C1."TransId" asc;
end