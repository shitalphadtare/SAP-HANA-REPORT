CREATE VIEW PAYMENT_DETAIL  AS ((SELECT
	 rc."TransId",
	 CASE WHEN r2."InvType" = 19 
		THEN IFNULL(e."NumAtCard",
	'') || ' - (Doc. No. ' || CAST(e."DocNum" AS varchar) || ')' WHEN r2."InvType" = 18 
		THEN IFNULL(g."NumAtCard",
	'') || ' - (Doc. No. ' || CAST(g."DocNum" AS varchar) || ')' WHEN r2."InvType" = 204 
		THEN IFNULL(dpo."NumAtCard",
	 '') || ' - (Doc. No. ' || CAST(dpo."DocNum" AS varchar) || ')' WHEN r2."InvType" = 30 
		THEN '(Doc. No. ' || CAST(jdt."TransId" AS varchar) || ')' -----------------Changes On 23-11-2019 another Incoming payment adjust	
 WHEN r2."InvType" = 24 
		THEN '(Doc. No. ' || CAST(VPM."DocNum" AS varchar) || ')' 
		END AS "invoiceref",
	 r2."SumApplied" AS "AmountPaid",
	 r2."AppliedFC" AS "AmountPaidFC" 
		FROM OCRD a 
		INNER JOIN ORCT rc ON rc."CardCode" = a."CardCode" 
		INNER JOIN RCT2 r2 ON rc."DocEntry" = r2."DocNum" 
		LEFT OUTER JOIN ORPC e ON e."DocEntry" = r2."DocEntry" 
		AND r2."InvType" = 19 
		LEFT OUTER JOIN OPCH g ON e."DocEntry" = r2."DocEntry" 
		AND r2."InvType" = 18 
		LEFT OUTER JOIN ODPO dpo ON dpo."DocEntry" = r2."DocEntry" 
		AND r2."InvType" = 204 
		LEFT OUTER JOIN OJDT jdt ON jdt."TransId" = r2."DocEntry" 
		AND r2."InvType" = 30 -----------------Changes On 23-11-2019 another Incoming payment adjust
 
		left outer join ORCT vpm ON R2."baseAbs"=VPM."DocEntry" 
		and r2."InvType" = 24 
		WHERE rc."Canceled" = 'N' 
		AND a."CardType" = 'S') 
	UNION ALL (SELECT
	 pm."TransId",
	 CASE WHEN p2."InvType" = 18 
		THEN IFNULL(e."NumAtCard",
	 '') || ' - (Doc. No. ' || CAST(e."DocNum" AS varchar) || ')' WHEN p2."InvType" = 19 
		THEN IFNULL(g."NumAtCard",
	 '') || ' - (Doc. No. ' || CAST(g."DocNum" AS varchar) || ')' WHEN p2."InvType" = 204 
		THEN IFNULL(dpo."NumAtCard",
	 '') || ' - (Doc. No. ' || CAST(dpo."DocNum" AS varchar) || ')' WHEN p2."InvType" = 30 
		THEN '(Doc. No. ' || CAST(jdt."TransId" AS varchar) || ')' -----------------Changes On 23-11-2019 another outgoing payment adjust	
 WHEN p2."InvType" = 46 
		THEN '(Doc. No. ' || CAST(VPM."DocNum" AS varchar) || ')' 
		END AS "invoiceref",
	 p2."SumApplied" AS "AmountPaid",
	 p2."AppliedFC" AS "AmountPaidFC" 
		FROM OCRD a 
		INNER JOIN OVPM pm ON pm."CardCode" = a."CardCode" 
		INNER JOIN VPM2 p2 ON pm."DocEntry" = p2."DocNum" 
		LEFT OUTER JOIN OPCH e ON e."DocEntry" = p2."DocEntry" 
		AND p2."InvType" = 18 
		LEFT OUTER JOIN ORPC g ON e."DocEntry" = p2."DocEntry" 
		AND p2."InvType" = 19 
		LEFT OUTER JOIN ODPO dpo ON dpo."DocEntry" = p2."DocEntry" 
		AND p2."InvType" = 204 
		LEFT OUTER JOIN OJDT JDT ON JDT."TransId" = p2."DocEntry" 
		AND p2."InvType" = 30 -----------------Changes On 23-11-2019 another outgoing payment adjust
 
		left outer join ovpm vpm ON p2."baseAbs"=VPM."DocEntry" 
		and p2."InvType" = 46 
		WHERE pm."Canceled" = 'N' 
		AND a."CardType" = 'S'))