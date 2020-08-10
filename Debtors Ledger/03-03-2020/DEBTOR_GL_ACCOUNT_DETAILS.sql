CREATE VIEW  DEBTOR_GL_ACCOUNT_DETAILS  AS SELECT
	 "A"."TransId" ,
	 "A"."ACCTNAME" ,
	 "A"."AmountPaid" ,
	 "A"."AmountPaidFC" 
FROM (SELECT
	 b."TransId",
	 d."FormatCode" || '-' || d."AcctName" AS "ACCTNAME",
	 c."Credit" - c."Debit" AS "AmountPaid",
	 c."FCCredit" - c."FCDebit" AS "AmountPaidFC" 
	FROM OINV A 
	INNER JOIN OJDT B ON A."TransId" = B."TransId" 
	INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
	INNER JOIN OACT D ON D."AcctCode" = C."Account" 
	INNER JOIN NNM1 E ON E."Series" = A."Series" 
	INNER JOIN OCRD cd ON cd."CardCode" = a."CardCode" 
	WHERE cd."CardCode" <> C."ShortName" 
	AND B."TransType" = 13 
	AND a.CANCELED = 'N' --changes 25-11-2019 AND a."DocType" = 'S' 
 
	UNION ALL SELECT
	 a."TransId",
	 d."FormatCode" || '-' || d."AcctName" AS "ACCTNAME",
	 c."Credit" - c."Debit" AS "AmountPaid",
	 c."FCCredit" - c."FCDebit" AS "AmountPaidFC" 
	FROM ORIN A 
	INNER JOIN OJDT B ON A."TransId" = B."TransId" 
	INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
	INNER JOIN OACT D ON D."AcctCode" = C."Account" 
	INNER JOIN NNM1 E ON E."Series" = A."Series" 
	WHERE A."CardCode" <> C."ShortName" 
	AND B."TransType" = 14 
	AND a.CANCELED = 'N' --changes 25-11-2019  AND a."DocType" = 'S' 
 
	UNION ALL SELECT
	 a."TransId",
	 d."FormatCode" || '-' || d."AcctName" AS "ACCTNAME",
	 c."Credit" - c."Debit" AS "AmountPaid",
	 c."FCCredit" - c."FCDebit" AS "AmountPaidFC" 
	FROM ODPI A 
	INNER JOIN OJDT B ON A."TransId" = B."TransId" 
	INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
	INNER JOIN OACT D ON D."AcctCode" = C."Account" 
	INNER JOIN NNM1 E ON E."Series" = A."Series" 
	WHERE A."CardCode" <> C."ShortName" 
	AND B."TransType" = 203 
	AND a.CANCELED = 'N' --changes 25-11-2019  AND a."DocType" = 'S' 
 
	UNION ALL SELECT
	 a."TransId",
	 d."FormatCode" || '-' || d."AcctName" AS "ACCTNAME",
	 c."Credit" - c."Debit" AS "AmountPaid",
	 c."FCCredit" - c."FCDebit" AS "AmountPaidFC" 
	FROM OJDT A 
	INNER JOIN NNM1 B ON A."Series" = b."Series" 
	INNER JOIN JDT1 C ON A."TransId" = C."TransId" 
	INNER JOIN OACT d ON d."AcctCode" = c."Account" 
	INNER JOIN OCRD F ON F."CardCode" = C."ContraAct" 
	WHERE A."TransType" NOT IN (13,
	 14,
	 18,
	 19,
	 24,
	 46) 
	UNION ALL SELECT
	 rc."TransId",
	 'On Account' AS "AcctName",
	 rc."NoDocSum" AS "AmountPaid",
	 rc."NoDocSumFC" AS "AmountPaidFC" 
	FROM OCRD a 
	INNER JOIN ORCT rc ON rc."CardCode" = a."CardCode" 
	WHERE rc."Canceled" = 'N' 
	AND rc."NoDocSum" > 0 
	AND a."CardType" = 'C' 
	UNION ALL SELECT
	 pm."TransId",
	 'On Account' AS "AcctName",
	 pm."NoDocSum" AS "AmountPaid",
	 pm."NoDocSumFC" AS "AmountPaidFC" 
	FROM OCRD a 
	INNER JOIN OVPM pm ON pm."CardCode" = a."CardCode" 
	WHERE pm."Canceled" = 'N' 
	AND pm."NoDocSum" > 0 
	AND a."CardType" = 'C') 