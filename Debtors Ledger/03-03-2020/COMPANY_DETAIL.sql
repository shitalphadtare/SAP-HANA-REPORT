CREATE VIEW COMPANY_DETAIL AS SELECT
	 IFNULL("Block" || ' ',
	 '') || IFNULL("Street" || ' ',
	 '') || IFNULL("StreetNo" || ' ',
	 '') || IFNULL("Building" || ' ',
	 '') || IFNULL("City" || ' ',
	 '') || IFNULL(OCRY."Name" || ' - ',
	 '') || IFNULL("ZipCode" || ' ',
	 '') AS "Address" 
FROM ADM1 
LEFT OUTER JOIN OCRY ON OCRY."Code" = ADM1."Country" 