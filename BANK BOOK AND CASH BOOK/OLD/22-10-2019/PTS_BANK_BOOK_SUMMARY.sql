
alter PROCEDURE PTS_BANK_BOOK_SUMMARY

(
IN Fromdate Timestamp
,IN ToDate Timestamp
,IN Bank nvarchar(500)
)
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
--READ SQL DATA 
AS
 Begin
SELECT T1."AcctName", T1."BP/GL Code", T1."BP/GL Description", SUM(T1."Credit") AS "Credit", SUM(T1."Debit") AS "Debit" FROM (SELECT T0."AcctName", (CASE WHEN T3."AcctCode" IS NULL OR T3."AcctCode" = '' AND T3."Segment_0" IS NULL THEN (CASE WHEN T2."TransType" = 46 THEN T4."CardCode" WHEN T2."TransType" = 24 THEN T6."CardCode" END) ELSE t3."FormatCode" END) AS "BP/GL Code", (CASE WHEN T3."AcctCode" IS NULL OR T3."AcctCode" = '' AND T3."Segment_0" IS NULL THEN (CASE WHEN T2."TransType" = 46 THEN T4."CardName" WHEN T2."TransType" = 24 THEN T6."CardName" END) ELSE t3."AcctName" END) AS "BP/GL Description", T1."Credit", T1."Debit" FROM OACT T0 INNER JOIN JDT1 T1 ON T1."Account" = T0."AcctCode" LEFT OUTER JOIN OACT T3 ON T1."ContraAct" = T3."AcctCode" INNER JOIN OJDT T2 ON T1."TransId" = T2."TransId" LEFT OUTER JOIN OVPM T4 ON T4."DocNum" = (CASE WHEN T1."TransType" = 46 THEN T1."BaseRef" ELSE NULL END) AND T1."RefDate" = T4."TaxDate" LEFT OUTER JOIN ORCT T6 ON T6."DocNum" = (CASE WHEN T1."TransType" = 24 THEN T1."BaseRef" ELSE NULL END) AND T1."RefDate" = T6."TaxDate" WHERE T0."Finanse" = 'Y' AND T0."AcctName" = :Bank AND T2."RefDate" >= :Fromdate AND T2."RefDate" <= :ToDate) AS T1 GROUP BY T1."BP/GL Code", T1."BP/GL Description", T1."AcctName" ORDER BY T1."BP/GL Code", T1."BP/GL Description", T1."AcctName";
end




