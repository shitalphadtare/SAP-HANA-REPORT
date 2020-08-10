create PROCEDURE FORM_3B_3_4

(IN LOCATIONGSTIN  nvarchar(100),
IN Month nvarchar(100),
IN Year  nvarchar(100))

LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
AS
 Begin 
 with PURCHASE_INTERSTATE_GSTINTYPE_COMPO_ITEM_NILRATED as
 (
 SELECT SUM(AP_INVOICE) - SUM(DEBIT_NOTE) + SUM(AP_DOWNPAYMENT) AS "TOTAL_PURCHASE", 
SUM("AP_INV_freight") - SUM("DEBIT_NOTE_freight") + SUM("AP_DOWN_freight") AS "freight", 
SUM("AP_INV_cgst_sum") - SUM("DEBIT_NOTE_cgst_sum") + SUM("AP_DOWN_cgst_sum") AS "CGST_SUM", 
SUM("AP_INV_sgst_sum") - SUM("DEBIT_NOTE_sgst_sum") + SUM("AP_DOWN_sgst_sum") AS "SGST_SUM", 
SUM("AP_INV_igst_sum") - SUM("DEBIT_NOTE_igst_sum") + SUM("AP_DOWN_igst_sum") AS "IGST_SUM", 
SUM("AP_INV_cess_sum") - SUM("DEBIT_NOTE_cess_sum") + SUM("AP_DOWN_cess_sum") AS "Cess_sum", "LocGSTN", "PIndicator", 
"Month", "Year" 

FROM (SELECT "DocEntry", (CASE WHEN "ObjType" = 18 THEN SUM("basesum") ELSE 0 END) AS "AP_INVOICE", 
	 (CASE WHEN "ObjType" = 19 THEN SUM("basesum") ELSE 0 END) AS "DEBIT_NOTE", 
	 (CASE WHEN "ObjType" = 204 THEN SUM("basesum") ELSE 0 END) AS "AP_DOWNPAYMENT", 
	 (CASE WHEN "ObjType" = 18 THEN SUM("freight") ELSE 0 END) AS "AP_INV_freight", 
	 (CASE WHEN "ObjType" = 19 THEN SUM("freight") ELSE 0 END) AS "DEBIT_NOTE_freight", 
	 (CASE WHEN "ObjType" = 204 THEN SUM("freight") ELSE 0 END) AS "AP_DOWN_freight", 
	 (CASE WHEN "ObjType" = 18 THEN SUM("cgst_sum") + ("F_CGST") ELSE 0 END) AS "AP_INV_cgst_sum", 
	 (CASE WHEN "ObjType" = 19 THEN SUM("cgst_sum") + ("F_CGST") ELSE 0 END) AS "DEBIT_NOTE_cgst_sum", 
	 (CASE WHEN "ObjType" = 204 THEN SUM("cgst_sum") + ("F_CGST") ELSE 0 END) AS "AP_DOWN_cgst_sum", 
	 (CASE WHEN "ObjType" = 18 THEN SUM("sgst_sum") + ("F_SGST") ELSE 0 END) AS "AP_INV_sgst_sum", 
	 (CASE WHEN "ObjType" = 19 THEN SUM("sgst_sum") + ("F_SGST") ELSE 0 END) AS "DEBIT_NOTE_sgst_sum", 
	 (CASE WHEN "ObjType" = 204 THEN SUM("sgst_sum") + ("F_SGST") ELSE 0 END) AS "AP_DOWN_sgst_sum", 
	 (CASE WHEN "ObjType" = 18 THEN SUM("igst_sum") + ("F_IGST") ELSE 0 END) AS "AP_INV_igst_sum", 
	 (CASE WHEN "ObjType" = 19 THEN SUM("igst_sum") + ("F_IGST") ELSE 0 END) AS "DEBIT_NOTE_igst_sum", 
	 (CASE WHEN "ObjType" = 204 THEN SUM("igst_sum") + ("F_IGST") ELSE 0 END) AS "AP_DOWN_igst_sum", 
	 (CASE WHEN "ObjType" = 18 THEN SUM("cess_sum") + "F_CESS" ELSE 0 END) AS "AP_INV_cess_sum", 
	 (CASE WHEN "ObjType" = 19 THEN SUM("cess_sum") + "F_CESS" ELSE 0 END) AS "DEBIT_NOTE_cess_sum", 
	 (CASE WHEN "ObjType" = 204 THEN SUM("cess_sum") + "F_CESS" ELSE 0 END) AS "AP_DOWN_cess_sum", 
	 "LocGSTN", "PIndicator", "Month", "Year" 
	 FROM (SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", SUM("CGST_Sum") AS "cgst_sum", 
	 		SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", SUM("Cess_Sum") AS "cess_sum", "freight", 
	 		F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", 
	 		"LocStateGSTN", "BpGSTType", "BpStateCode", "BpStateGSTN", "BpGSTN", "HSN Code" 
	 		FROM PTS_GSTR3 
	 		WHERE "Item_Tax_Type" IN ('E','N') AND "BpGSTType" = 3 AND "LocStateCode" <> "BpStateCode" 
	 		AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :LOCATIONGSTIN AND "PIndicator" = :Year 
GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", 
"Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", "BpStateCode", "BpStateGSTN", 
"Year", "BpGSTN", "HSN Code") AS a GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", "freight", "F_CGST", "F_SGST",
 "F_IGST", F_CESS, "DocEntry") AS b 
GROUP BY "LocGSTN", "PIndicator", "Month", "Year"

 ),
 -----------------------------------------------------
 PURCHASE_INTRASTATE_GSTINTYPE_COMPO_ITEM_NILRATED as
 (
 SELECT SUM(AP_INVOICE) - SUM(DEBIT_NOTE) + SUM(AP_DOWNPAYMENT) AS "TOTAL_PURCHASE", 
SUM("AP_INV_freight") - SUM("DEBIT_NOTE_freight") + SUM("AP_DOWN_freight") AS "freight", 
SUM("AP_INV_cgst_sum") - SUM("DEBIT_NOTE_cgst_sum") + SUM("AP_DOWN_cgst_sum") AS "CGST_SUM", 
SUM("AP_INV_sgst_sum") - SUM("DEBIT_NOTE_sgst_sum") + SUM("AP_DOWN_sgst_sum") AS "SGST_SUM", 
SUM("AP_INV_igst_sum") - SUM("DEBIT_NOTE_igst_sum") + SUM("AP_DOWN_igst_sum") AS "IGST_SUM", 
SUM("AP_INV_cess_sum") - SUM("DEBIT_NOTE_cess_sum") + SUM("AP_DOWN_cess_sum") AS "Cess_sum", 
"LocGSTN", "PIndicator", "Month", "Year" 
FROM 
	(SELECT "DocEntry", (CASE WHEN "ObjType" = 18 THEN SUM("basesum") ELSE 0 END) AS "AP_INVOICE", 
	(CASE WHEN "ObjType" = 19 THEN SUM("basesum") ELSE 0 END) AS "DEBIT_NOTE", 
	(CASE WHEN "ObjType" = 204 THEN SUM("basesum") ELSE 0 END) AS "AP_DOWNPAYMENT", 
	(CASE WHEN "ObjType" = 18 THEN SUM("freight") ELSE 0 END) AS "AP_INV_freight", 
	(CASE WHEN "ObjType" = 19 THEN SUM("freight") ELSE 0 END) AS "DEBIT_NOTE_freight", 
	(CASE WHEN "ObjType" = 204 THEN SUM("freight") ELSE 0 END) AS "AP_DOWN_freight", 
	(CASE WHEN "ObjType" = 18 THEN SUM("cgst_sum") + ("F_CGST") ELSE 0 END) AS "AP_INV_cgst_sum", 
	(CASE WHEN "ObjType" = 19 THEN SUM("cgst_sum") + ("F_CGST") ELSE 0 END) AS "DEBIT_NOTE_cgst_sum", 
	(CASE WHEN "ObjType" = 204 THEN SUM("cgst_sum") + ("F_CGST") ELSE 0 END) AS "AP_DOWN_cgst_sum", 
	(CASE WHEN "ObjType" = 18 THEN SUM("sgst_sum") + ("F_SGST") ELSE 0 END) AS "AP_INV_sgst_sum", 
	(CASE WHEN "ObjType" = 19 THEN SUM("sgst_sum") + ("F_SGST") ELSE 0 END) AS "DEBIT_NOTE_sgst_sum", 
	(CASE WHEN "ObjType" = 204 THEN SUM("sgst_sum") + ("F_SGST") ELSE 0 END) AS "AP_DOWN_sgst_sum", 
	(CASE WHEN "ObjType" = 18 THEN SUM("igst_sum") + ("F_IGST") ELSE 0 END) AS "AP_INV_igst_sum", 
	(CASE WHEN "ObjType" = 19 THEN SUM("igst_sum") + ("F_IGST") ELSE 0 END) AS "DEBIT_NOTE_igst_sum", 
	(CASE WHEN "ObjType" = 204 THEN SUM("igst_sum") + ("F_IGST") ELSE 0 END) AS "AP_DOWN_igst_sum", 
	(CASE WHEN "ObjType" = 18 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_INV_cess_sum", 
	(CASE WHEN "ObjType" = 19 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "DEBIT_NOTE_cess_sum", 
	(CASE WHEN "ObjType" = 204 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_DOWN_cess_sum", 
	"LocGSTN", "PIndicator", "Month", "Year" FROM 
	(SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", SUM("CGST_Sum") AS "cgst_sum", 
			SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", SUM("Cess_Sum") AS "cess_sum", "freight", 
			F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", 
			"LocGSTN", "LocStateGSTN", "BpGSTType", "BpStateCode", "BpStateGSTN", "BpGSTN", "HSN Code" 
			FROM PTS_GSTR3 WHERE "Item_Tax_Type" IN ('E','N') AND "BpGSTType" = 3 AND "LocStateCode" = "BpStateCode" 
			AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :LOCATIONGSTIN AND "PIndicator" = :Year 
			GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", 
			F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", 
			"LocGSTN", "LocStateGSTN", "BpGSTType", "BpStateCode", "BpStateGSTN", "Year", "BpGSTN", "HSN Code"
	) AS a GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", "freight", "F_CGST", "F_SGST", "F_IGST", 
	F_CESS, "DocEntry") AS b GROUP BY "LocGSTN", "PIndicator", "Month", "Year"

 ),
 PURCHASE_INTERSTATE_NONGST as
 (
 SELECT SUM(AP_INVOICE) - SUM(DEBIT_NOTE) + SUM(AP_DOWNPAYMENT) AS "TOTAL_PURCHASE", 
SUM("AP_INV_freight") - SUM("DEBIT_NOTE_freight") + SUM("AP_DOWN_freight") AS "freight", 
SUM("AP_INV_cgst_sum") - SUM("DEBIT_NOTE_cgst_sum") + SUM("AP_DOWN_cgst_sum") AS "CGST_SUM", 
SUM("AP_INV_sgst_sum") - SUM("DEBIT_NOTE_sgst_sum") + SUM("AP_DOWN_sgst_sum") AS "SGST_SUM", 
SUM("AP_INV_igst_sum") - SUM("DEBIT_NOTE_igst_sum") + SUM("AP_DOWN_igst_sum") AS "IGST_SUM", 
SUM("AP_INV_cess_sum") - SUM("DEBIT_NOTE_cess_sum") + SUM("AP_DOWN_cess_sum") AS "Cess_sum", 
"LocGSTN", "PIndicator", "Month", "Year" 
	FROM (SELECT "DocEntry", 
		 (CASE WHEN "ObjType" = 18 THEN SUM("basesum") ELSE 0 END) AS "AP_INVOICE", 
		 (CASE WHEN "ObjType" = 19 THEN SUM("basesum") ELSE 0 END) AS "DEBIT_NOTE", 
		 (CASE WHEN "ObjType" = 204 THEN SUM("basesum") ELSE 0 END) AS "AP_DOWNPAYMENT", 
		 (CASE WHEN "ObjType" = 18 THEN SUM("freight") ELSE 0 END) AS "AP_INV_freight", 
		 (CASE WHEN "ObjType" = 19 THEN SUM("freight") ELSE 0 END) AS "DEBIT_NOTE_freight", 
		 (CASE WHEN "ObjType" = 204 THEN SUM("freight") ELSE 0 END) AS "AP_DOWN_freight", 
		 (CASE WHEN "ObjType" = 18 THEN SUM("cgst_sum") + ("F_CGST") ELSE 0 END) AS "AP_INV_cgst_sum", 
		 (CASE WHEN "ObjType" = 19 THEN SUM("cgst_sum") + ("F_CGST") ELSE 0 END) AS "DEBIT_NOTE_cgst_sum", 
		 (CASE WHEN "ObjType" = 204 THEN SUM("cgst_sum") + ("F_CGST") ELSE 0 END) AS "AP_DOWN_cgst_sum", 
		 (CASE WHEN "ObjType" = 18 THEN SUM("sgst_sum") + ("F_SGST") ELSE 0 END) AS "AP_INV_sgst_sum", 
		 (CASE WHEN "ObjType" = 19 THEN SUM("sgst_sum") + ("F_SGST") ELSE 0 END) AS "DEBIT_NOTE_sgst_sum", 
		 (CASE WHEN "ObjType" = 204 THEN SUM("sgst_sum") + ("F_SGST") ELSE 0 END) AS "AP_DOWN_sgst_sum", 
		 (CASE WHEN "ObjType" = 18 THEN SUM("igst_sum") + ("F_IGST") ELSE 0 END) AS "AP_INV_igst_sum", 
		 (CASE WHEN "ObjType" = 19 THEN SUM("igst_sum") + ("F_IGST") ELSE 0 END) AS "DEBIT_NOTE_igst_sum", 
		 (CASE WHEN "ObjType" = 204 THEN SUM("igst_sum") + ("F_IGST") ELSE 0 END) AS "AP_DOWN_igst_sum", 
		 (CASE WHEN "ObjType" = 18 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_INV_cess_sum", 
		 (CASE WHEN "ObjType" = 19 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "DEBIT_NOTE_cess_sum", 
		 (CASE WHEN "ObjType" = 204 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_DOWN_cess_sum", 
		 "LocGSTN", "PIndicator", "Month", "Year" 
		  FROM (SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", 
		  		SUM("CGST_Sum") AS "cgst_sum", SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", 
		  		SUM("Cess_Sum") AS "cess_sum", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", 
		  		"Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
		  		"BpStateCode", "BpStateGSTN", "BpGSTN", "HSN Code" 
		  		FROM PTS_GSTR3 WHERE "isgsttax" = 'N' AND "LocStateCode" <> "BpStateCode" AND "LocStateCode" = "BpStateCode" 
		  		AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :LOCATIONGSTIN AND "PIndicator" = :Year 
               GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, 
               "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
               "BpStateCode", "BpStateGSTN", "Year", "BpGSTN", "HSN Code") AS a 
       GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", "freight", "F_CGST", "F_SGST", "F_IGST", F_CESS, "DocEntry") 
       AS b GROUP BY "LocGSTN", "PIndicator", "Month", "Year"


 ),
 ----------------------------------------------------------------------
 PURCHASE_INTRASTATE_NONGST as (
SELECT SUM(AP_INVOICE) - SUM(DEBIT_NOTE) + SUM(AP_DOWNPAYMENT) AS "TOTAL_PURCHASE", 
SUM("AP_INV_freight") - SUM("DEBIT_NOTE_freight") + SUM("AP_DOWN_freight") AS "freight", 
SUM("AP_INV_cgst_sum") - SUM("DEBIT_NOTE_cgst_sum") + SUM("AP_DOWN_cgst_sum") AS "CGST_SUM", 
SUM("AP_INV_sgst_sum") - SUM("DEBIT_NOTE_sgst_sum") + SUM("AP_DOWN_sgst_sum") AS "SGST_SUM", 
SUM("AP_INV_igst_sum") - SUM("DEBIT_NOTE_igst_sum") + SUM("AP_DOWN_igst_sum") AS "IGST_SUM", 
SUM("AP_INV_cess_sum") - SUM("DEBIT_NOTE_cess_sum") + SUM("AP_DOWN_igst_sum") AS "Cess_sum", 
"LocGSTN", "PIndicator", "Month", "Year" 
  	FROM (SELECT "DocEntry", (CASE WHEN "ObjType" = 18 THEN SUM("basesum") ELSE 0 END) AS "AP_INVOICE", 
  				 (CASE WHEN "ObjType" = 19 THEN SUM("basesum") ELSE 0 END) AS "DEBIT_NOTE", 
  				 (CASE WHEN "ObjType" = 204 THEN SUM("basesum") ELSE 0 END) AS "AP_DOWNPAYMENT", 
  				 (CASE WHEN "ObjType" = 18 THEN SUM("freight") ELSE 0 END) AS "AP_INV_freight", 
  				 (CASE WHEN "ObjType" = 19 THEN SUM("freight") ELSE 0 END) AS "DEBIT_NOTE_freight", 
  				 (CASE WHEN "ObjType" = 204 THEN SUM("freight") ELSE 0 END) AS "AP_DOWN_freight", 
  				 (CASE WHEN "ObjType" = 18 THEN SUM("cgst_sum") + ("F_CGST") ELSE 0 END) AS "AP_INV_cgst_sum", 
  				 (CASE WHEN "ObjType" = 19 THEN SUM("cgst_sum") + ("F_CGST") ELSE 0 END) AS "DEBIT_NOTE_cgst_sum", 
  				 (CASE WHEN "ObjType" = 204 THEN SUM("cgst_sum") + ("F_CGST") ELSE 0 END) AS "AP_DOWN_cgst_sum", 
  				 (CASE WHEN "ObjType" = 18 THEN SUM("sgst_sum") + ("F_SGST") ELSE 0 END) AS "AP_INV_sgst_sum", 
  				 (CASE WHEN "ObjType" = 19 THEN SUM("sgst_sum") + ("F_SGST") ELSE 0 END) AS "DEBIT_NOTE_sgst_sum", 
  				 (CASE WHEN "ObjType" = 204 THEN SUM("sgst_sum") + ("F_SGST") ELSE 0 END) AS "AP_DOWN_sgst_sum", 
  				 (CASE WHEN "ObjType" = 18 THEN SUM("igst_sum") + ("F_IGST") ELSE 0 END) AS "AP_INV_igst_sum", 
  				 (CASE WHEN "ObjType" = 19 THEN SUM("igst_sum") + ("F_IGST") ELSE 0 END) AS "DEBIT_NOTE_igst_sum", 
  				 (CASE WHEN "ObjType" = 204 THEN SUM("igst_sum") + ("F_IGST") ELSE 0 END) AS "AP_DOWN_igst_sum", 
  				 (CASE WHEN "ObjType" = 18 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_INV_cess_sum", 
  				 (CASE WHEN "ObjType" = 19 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "DEBIT_NOTE_cess_sum", 
  				 (CASE WHEN "ObjType" = 204 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_DOWN_cess_sum", 
  				 "LocGSTN", "PIndicator", "Month", "Year"
  				  FROM (SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", 
  				  		SUM("CGST_Sum") AS "cgst_sum", SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", 
  				  		SUM("Cess_Sum") AS "cess_sum", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", 
  				  		"Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
  				  		"BpStateCode", "BpStateGSTN", "BpGSTN", "HSN Code" 
  				  		FROM PTS_GSTR3 WHERE "isgsttax" = 'N' AND "LocStateCode" = IFNULL("BpStateCode", "LocStateCode") 
  				  		AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :LOCATIONGSTIN AND "PIndicator" = :Year 
                        GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS,
                         "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
                         "BpStateCode", "BpStateGSTN", "Year", "BpGSTN", "HSN Code"
                      ) AS a 
                  GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", "freight", "F_CGST", "F_SGST", "F_IGST", 
                  F_CESS, "DocEntry") AS b GROUP BY "LocGSTN", "PIndicator", "Month", "Year"

 )

 Select distinct a1."IGST_SUM" "A1.IGST_SUM",a2."CGST_SUM" "A2_CGST_SUM",a2."SGST_SUM" "A2_SGST_SUM",A3."TOTAL_PURCHASE" "A3_Total_Purchase"
 ,A4."TOTAL_PURCHASE" "A4_Total_Purchase"

  from PTS_GSTR3 C
left outer join PURCHASE_INTERSTATE_GSTINTYPE_COMPO_ITEM_NILRATED A1 on c."LocGSTN"=a1."LocGSTN" and c."PIndicator"=a1."PIndicator" and c."Month"=a1."Month"
left outer join  PURCHASE_INTRASTATE_GSTINTYPE_COMPO_ITEM_NILRATED A2 on c."LocGSTN"=c."LocGSTN" and c."PIndicator"=c."PIndicator" and c."Month"=A2."Month"
left outer join  PURCHASE_INTERSTATE_NONGST A3 on c."LocGSTN"=A3."LocGSTN" and c."PIndicator"=A3."PIndicator" and c."Month"=A3."Month"
left outer join PURCHASE_INTRASTATE_NONGST A4 on c."LocGSTN"=A4."LocGSTN" and c."PIndicator"=A4."PIndicator" and c."Month"=A4."Month"
where c."LocGSTN"=:LOCATIONGSTIN and c."Month"=:LOCATIONGSTIN and c."PIndicator"=:Year;

end