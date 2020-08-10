CREATE VIEW  TDS_DETAIL  AS ((SELECT
	 pch."TransId",
	 -(pch."DocTotal" + IFNULL(pch."WTSum",
	 0)) AS "DocTotal",
	 pch."WTSum" 
		FROM OPCH pch) 
	UNION ALL (SELECT
	 dpo."TransId",
	 -(dpo."DocTotal" + IFNULL(dpo."WTSum",
	 0)) AS "DocTotal",
	 dpo."WTSum" 
		FROM ODPO dpo 
		WHERE dpo."TransId" IS NOT NULL))