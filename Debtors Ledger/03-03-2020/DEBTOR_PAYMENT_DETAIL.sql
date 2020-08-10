CREATE VIEW  DEBTOR_PAYMENT_DETAIL AS ((SELECT
	 rc."TransId",
	 CASE WHEN r2."InvType" = 13 
		THEN IFNULL(e."NumAtCard" || ' -',
	 '') || ' (Doc. No. ' || CAST(e."DocNum" AS varchar) || ')' WHEN r2."InvType" = 14 
		THEN IFNULL(g."NumAtCard" || ' -',
	 '') || ' (Doc. No. ' || CAST(g."DocNum" AS varchar) || ')' WHEN r2."InvType" = 203 
		THEN IFNULL(dpo."NumAtCard" || ' -',
	 '') || ' (Doc. No. ' || CAST(dpo."DocNum" AS varchar) || ')' 
		END AS "invoiceref",
	 r2."SumApplied" AS "AmountPaid",
	 r2."AppliedFC" AS "AmountPaidFC" 
		FROM OCRD a 
		INNER JOIN ORCT rc ON rc."CardCode" = a."CardCode" 
		LEFT OUTER JOIN NNM1 H ON RC."Series" = H."Series" 
		INNER JOIN RCT2 r2 ON rc."DocEntry" = r2."DocNum" 
		LEFT OUTER JOIN OINV e ON e."DocEntry" = r2."DocEntry" 
		AND r2."InvType" = E."ObjType" 
		LEFT OUTER JOIN ORIN g ON G."DocEntry" = r2."DocEntry" 
		AND r2."InvType" = G."ObjType" 
		LEFT OUTER JOIN ODPI DPO ON DPO."DocEntry" = r2."DocEntry" 
		AND r2."InvType" = DPO."ObjType" 
		WHERE rc."Canceled" = 'N' 
		AND a."CardType" = 'C') 
	UNION ALL (SELECT
	 pm."TransId",
	 CAST(COALESCE(e."DocNum",
	 g."DocNum",
	 p2."DocTransId") AS varchar) AS "invoiceref",
	 p2."SumApplied" AS "AmountPaid",
	 p2."AppliedFC" AS "AmountPaidFC" 
		FROM OCRD a 
		INNER JOIN OVPM pm ON pm."CardCode" = a."CardCode" 
		INNER JOIN VPM2 p2 ON pm."DocEntry" = p2."DocNum" 
		LEFT OUTER JOIN OINV e ON e."DocEntry" = p2."DocEntry" 
		AND p2."InvType" = 13 
		LEFT OUTER JOIN NNM1 f ON e."Series" = f."Series" 
		LEFT OUTER JOIN ORIN g ON e."DocEntry" = p2."DocEntry" 
		AND p2."InvType" = 14 
		LEFT OUTER JOIN NNM1 h ON g."Series" = h."Series" 
		WHERE pm."Canceled" = 'N' 
		AND a."CardType" = 'C')) 