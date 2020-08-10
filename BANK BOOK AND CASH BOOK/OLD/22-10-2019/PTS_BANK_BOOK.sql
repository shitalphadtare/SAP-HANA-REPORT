
alter PROCEDURE PTS_BANK_BOOK
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
(CASE WHEN T2."TransType" = 46 THEN T5."SeriesName" || '-' || CAST(T4."DocNum" AS char) 
      WHEN T2."TransType" = 24 THEN T7."SeriesName" || '-' || CAST(T6."DocNum" AS char) 
      WHEN T2."TransType" = 30 THEN T10."SeriesName" || '-' || CAST(T2."Number" AS char) END) AS "Document No", 
(CASE WHEN T2."TransType" = 30 THEN 'Journal Entry' WHEN T2."TransType" = 140000009 THEN 'Outgoing Ex Invoice' 
WHEN T2."TransType" = 24 THEN 'Incoming Payment' ELSE 'Outgoing Payment' END) AS "Transction Name", 
(CASE WHEN T2."TransType" = 24 AND T6."DocType" <> 'A' THEN T6."CardName" WHEN T2."TransType" = 46 AND T4."DocType" <> 'A' 
THEN T4."CardName" ELSE CASE WHEN (SELECT COUNT("Line_ID") FROM JDT1 WHERE "TransId" = t1."TransId") > 2 
THEN 'Payment To/From GL Accounts' ELSE (CASE WHEN T3."Segment_0" <> '' 
THEN T3."Segment_0" || '-' || T3."Segment_1" || ' ' || T3."AcctName" ELSE T3."AcctCode" || ' ' || T3."AcctName" END) END END) AS "BP/GL Code", 
--CASE WHEN :Narration = 1 THEN 
(CASE WHEN T2."TransType" = 46 THEN T11."Descrip" WHEN T2."TransType" = 24 THEN T12."Descrip" WHEN T2."TransType" = 30 
THEN T2."Memo" END) "Description 1", 
--CASE WHEN :Narration = 1 THEN 
(CASE WHEN T2."TransType" = 46 THEN T4."Comments" WHEN T2."TransType" = 24 THEN T6."Comments" END) "Description 3", 
--(CASE WHEN :Cheque = 1 THEN 
'Ch No.' || CAST((CASE WHEN T2."TransType" = 46 THEN T8."CheckNum" WHEN T2."TransType" = 24 THEN T9."CheckNum" END) AS char) "Description 2", 
(CASE WHEN RIGHT(LEFT(right(T2."RefDate", 23), 5), 1) = '' THEN '0' ELSE RIGHT(LEFT(right(T2."RefDate", 23), 5), 1) END) || (CASE WHEN RIGHT(LEFT(right(T2."RefDate", 23), 6), 1) = '' THEN '0' ELSE RIGHT(LEFT(right(T2."RefDate", 23), 6), 1) END) AS "Dt", 
left(CAST(T2."RefDate" AS varchar(10)), 2) AS "Mnth", 
RIGHT(LEFT(right(T2."RefDate", 23), 12), 5) AS "yr1", 
(SELECT COUNT("Line_ID") FROM JDT1 WHERE "TransId" = t1."TransId") AS "Count" 
FROM OACT T0 INNER JOIN JDT1 T1 ON T1."Account" = T0."AcctCode" 
LEFT OUTER JOIN OACT T3 ON T1."ContraAct" = T3."AcctCode" 
INNER JOIN OJDT T2 ON T1."TransId" = T2."TransId" AND T2."TransType" IN (30,140000009,24,46) 
LEFT OUTER JOIN (SELECT W1."Series", W1."SeriesName", W2."TransId" FROM NNM1 W1 INNER JOIN OJDT W2 ON W1."Series" = W2."Series") AS T10 ON T10."Series" = T2."Series" AND T2."TransId" = T10."TransId" 
LEFT OUTER JOIN OVPM T4 ON T4."DocNum" = (CASE WHEN T1."TransType" = 46 THEN T1."BaseRef" ELSE NULL END) AND T1."RefDate" = T4."DocDate" LEFT OUTER JOIN (SELECT W1."Series", "SeriesName", W2."DocNum" FROM NNM1 W1 INNER JOIN OVPM W2 ON W1."Series" = W2."Series") AS T5 ON T4."Series" = T5."Series" AND T4."DocNum" = T5."DocNum" LEFT OUTER JOIN (SELECT "CheckNum", "DocNum" FROM VPM1) AS T8 ON T8."DocNum" = T4."DocEntry" LEFT OUTER JOIN (SELECT "Descrip", "DocNum", "LineId" FROM VPM4) AS T11 ON T11."DocNum" = T4."DocEntry" AND T11."LineId" = 0 LEFT OUTER JOIN ORCT T6 ON T6."DocNum" = (CASE WHEN T1."TransType" = 24 THEN T1."BaseRef" ELSE null END) AND T1."RefDate" = T6."DocDate" LEFT OUTER JOIN (SELECT W1."Series", "SeriesName", W2."DocNum" FROM NNM1 W1 INNER JOIN ORCT W2 ON W1."Series" = W2."Series") AS T7 ON T6."Series" = T7."Series" AND T6."DocNum" = T7."DocNum" LEFT OUTER JOIN (SELECT "CheckNum", "DocNum" FROM RCT1) AS T9 ON T9."DocNum" = T6."DocEntry" LEFT OUTER JOIN (SELECT "Descrip", "DocNum", "LineId" FROM RCT4) AS T12 ON T12."DocNum" = T6."DocEntry" AND T12."LineId" = 0 
	  WHERE T0."Finanse" = 'Y' AND T0."AcctName" = :Bank AND T2."RefDate" >= :Fromdate AND T2."RefDate" <= :ToDate
),
--------------------------------------------------------**************************-----------------------------------------------------
Query2 as(

SELECT T0."AcctCode", SUM((CASE WHEN :Currency = 'Local' THEN (CASE WHEN T2."RefDate" < :Fromdate THEN IFNULL(T1."Debit", 0) ELSE 0 END) ELSE (CASE WHEN T2."RefDate" < :Fromdate THEN IFNULL(T1."FCDebit", 0) ELSE 0 END) END)) - SUM((CASE WHEN :Currency = 'Local' THEN (CASE WHEN T2."RefDate" < :Fromdate THEN IFNULL(T1."Credit", 0) ELSE 0 END) ELSE (CASE WHEN T2."RefDate" < :Fromdate THEN IFNULL(T1."FCCredit", 0) ELSE 0 END) END)) AS "Opening Balance" FROM OACT T0 INNER JOIN JDT1 T1 ON T1."Account" = T0."AcctCode" INNER JOIN OJDT T2 ON T1."TransId" = T2."TransId" WHERE T0."Finanse" = 'Y' AND T0."AcctName" = :Bank GROUP BY T0."AcctCode" )


-------------------------------------------------*******************************---------------------------------------------------

select *
from 
Query1 C1
inner join Query2 C2 on C1."AcctCode" = C2."AcctCode"
order by C1."Date1",C1."TransId" asc;
end




