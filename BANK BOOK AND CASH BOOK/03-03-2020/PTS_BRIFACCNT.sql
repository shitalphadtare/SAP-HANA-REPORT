CREATE VIEW  PTS_BRIFACCNT  AS SELECT
	 jt1."TransId",
	 (CASE WHEN act."Segment_0" <> '' 
	THEN act."Segment_0" || '-' || act."Segment_1" || ' ' || act."AcctName" 
	ELSE act."AcctCode" || ' ' || act."AcctName" 
	END) AS "AcctCode",
	 "Debit" - "Credit" AS "AcctTotal",
	 "Line_ID",
	 act."Finanse",
	 act."AcctName",
	 "FCDebit" - "FCCredit" AS "FCAcctTotal" 
FROM JDT1 jt1 
LEFT OUTER JOIN OACT act ON jt1."Account" = act."AcctCode" 
LEFT OUTER JOIN OACT act1 ON jt1."ContraAct" = act1."AcctCode" 
LEFT OUTER JOIN OVPM T1 ON jt1."CreatedBy" = T1."DocEntry" 
AND jt1."BaseRef" = T1."DocNum" 
AND jt1."TransType" = 46 
LEFT OUTER JOIN ORCT T4 ON jt1."CreatedBy" = T4."DocEntry" 
AND jt1."BaseRef" = T4."DocNum" 
AND jt1."TransType" = 24 
WHERE jt1."TransId" IN (SELECT
	 "TransId" 
	FROM JDT1 
	WHERE "Line_ID" > 1) 
AND "TransType" IN (46,
	24)