create PROCEDURE FORM_3B_3_3

(IN LOCATIONGSTIN  nvarchar(100),
IN Month nvarchar(100),
IN Year  nvarchar(100))


LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
AS
 Begin 
  with IMPORT_PURCHASE_ITEM_HSN_NOT_NULL as
  (
  SELECT SUM(AP_INVOICE) - SUM(DEBIT_NOTE) + SUM(AP_DOWNPAYMENT) AS "TOTAL_PURCHASE", 
SUM("AP_INV_freight") - SUM("DEBIT_NOTE_freight") + SUM("AP_DOWN_freight") AS "freight", 
SUM("AP_INV_cgst_sum") - SUM("DEBIT_NOTE_cgst_sum") + SUM("AP_DOWN_cgst_sum") AS "CGST_SUM", 
SUM("AP_INV_sgst_sum") - SUM("DEBIT_NOTE_sgst_sum") + SUM("AP_DOWN_sgst_sum") AS "SGST_SUM", 
SUM("AP_INV_igst_sum") - SUM("DEBIT_NOTE_igst_sum") + SUM("AP_DOWN_igst_sum") AS "IGST_SUM", 
SUM("AP_INV_cess_sum") - SUM("DEBIT_NOTE_cess_sum") + SUM("AP_DOWN_cess_sum") AS "Cess_sum", "LocGSTN", "PIndicator", "Month", "Year"
 FROM (SELECT "DocEntry", (CASE WHEN "ObjType" = 18 THEN SUM("basesum") ELSE 0 END) AS "AP_INVOICE", 
 			(CASE WHEN "ObjType" = 19 THEN SUM("basesum") ELSE 0 END) AS "DEBIT_NOTE", 
 			(CASE WHEN "ObjType" = 204 THEN SUM("basesum") ELSE 0 END) AS "AP_DOWNPAYMENT", 
 			(CASE WHEN "ObjType" = 18 THEN ("freight") ELSE 0 END) AS "AP_INV_freight", 
 			(CASE WHEN "ObjType" = 19 THEN ("freight") ELSE 0 END) AS "DEBIT_NOTE_freight", 
 			(CASE WHEN "ObjType" = 204 THEN ("freight") ELSE 0 END) AS "AP_DOWN_freight", 
 			(CASE WHEN "ObjType" = 18 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AP_INV_cgst_sum", 
 			(CASE WHEN "ObjType" = 19 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "DEBIT_NOTE_cgst_sum", 
 			(CASE WHEN "ObjType" = 204 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AP_DOWN_cgst_sum", 
 			(CASE WHEN "ObjType" = 18 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AP_INV_sgst_sum", 
 			(CASE WHEN "ObjType" = 19 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "DEBIT_NOTE_sgst_sum", 
 			(CASE WHEN "ObjType" = 204 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AP_DOWN_sgst_sum", 
 			(CASE WHEN "ObjType" = 18 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AP_INV_igst_sum", 
 			(CASE WHEN "ObjType" = 19 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "DEBIT_NOTE_igst_sum", 
 			(CASE WHEN "ObjType" = 204 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AP_DOWN_igst_sum", 
 			(CASE WHEN "ObjType" = 18 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_INV_cess_sum", 
 			(CASE WHEN "ObjType" = 19 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "DEBIT_NOTE_cess_sum", 
 			(CASE WHEN "ObjType" = 204 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_DOWN_cess_sum", 
 			"LocGSTN", "PIndicator", "Month", "Year" 
 			FROM (SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", 
 				  SUM("CGST_Sum") AS "cgst_sum", SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", 
 				  SUM("Cess_Sum") AS "cess_sum", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", "Reverse_Charge", 
 				  "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", "BpStateCode", "BpStateGSTN", 
 				  "BpGSTN", "HSN Code" FROM PTS_GSTR3 
 				  WHERE "ImpOrExp" = 'Y' AND IFNULL("HSN Code", '') <> ''-- AND "Reverse_Charge" = 'N' changes on 16-07-2020
 				  AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :Month AND "PIndicator" = :Year 
			      GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, 
			      "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
			      "BpStateCode", "BpStateGSTN", "Year", "BpGSTN", "HSN Code") AS a 
			GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "DocEntry") 
	AS b GROUP BY "LocGSTN", "PIndicator", "Month", "Year"

  
  ),
  --------------------------------------------
  IMPORT_PURCHASE_SERVICE_SAC_NOT_NULL as 
  (
  SELECT SUM(AP_INVOICE) - SUM(DEBIT_NOTE) + SUM(AP_DOWNPAYMENT) AS "TOTAL_PURCHASE",
SUM("AP_INV_freight") - SUM("DEBIT_NOTE_freight") + SUM("AP_DOWN_freight") AS "freight", 
SUM("AP_INV_cgst_sum") - SUM("DEBIT_NOTE_cgst_sum") + SUM("AP_DOWN_cgst_sum") AS "CGST_SUM", 
SUM("AP_INV_sgst_sum") - SUM("DEBIT_NOTE_sgst_sum") + SUM("AP_DOWN_sgst_sum") AS "SGST_SUM", 
SUM("AP_INV_igst_sum") - SUM("DEBIT_NOTE_igst_sum") + SUM("AP_DOWN_igst_sum") AS "IGST_SUM", 
SUM("AP_INV_cess_sum") - SUM("DEBIT_NOTE_cess_sum") + SUM("AP_DOWN_cess_sum") AS "Cess_sum", 
"LocGSTN", "PIndicator", "Month", "Year" 
		FROM (SELECT (CASE WHEN "ObjType" = 18 THEN SUM("basesum") ELSE 0 END) AS "AP_INVOICE", 
				  (CASE WHEN "ObjType" = 19 THEN SUM("basesum") ELSE 0 END) AS "DEBIT_NOTE", 
				  (CASE WHEN "ObjType" = 204 THEN SUM("basesum") ELSE 0 END) AS "AP_DOWNPAYMENT", 
				  (CASE WHEN "ObjType" = 18 THEN SUM("freight") ELSE 0 END) AS "AP_INV_freight", 
				  (CASE WHEN "ObjType" = 19 THEN SUM("freight") ELSE 0 END) AS "DEBIT_NOTE_freight", 
				  (CASE WHEN "ObjType" = 204 THEN SUM("freight") ELSE 0 END) AS "AP_DOWN_freight", 
				  (CASE WHEN "ObjType" = 18 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AP_INV_cgst_sum", 
				  (CASE WHEN "ObjType" = 19 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "DEBIT_NOTE_cgst_sum", 
				  (CASE WHEN "ObjType" = 204 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AP_DOWN_cgst_sum", 
				  (CASE WHEN "ObjType" = 18 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AP_INV_sgst_sum", 
				  (CASE WHEN "ObjType" = 19 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "DEBIT_NOTE_sgst_sum", 
				  (CASE WHEN "ObjType" = 204 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AP_DOWN_sgst_sum", 
				  (CASE WHEN "ObjType" = 18 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AP_INV_igst_sum", 
				  (CASE WHEN "ObjType" = 19 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "DEBIT_NOTE_igst_sum", 
				  (CASE WHEN "ObjType" = 204 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AP_DOWN_igst_sum", 
				  (CASE WHEN "ObjType" = 18 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_INV_cess_sum", 
				  (CASE WHEN "ObjType" = 19 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "DEBIT_NOTE_cess_sum", 
				  (CASE WHEN "ObjType" = 204 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_DOWN_cess_sum", 
				  "LocGSTN", "PIndicator", "Month", "Year" 
			FROM (SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", 
					SUM("CGST_Sum") AS "cgst_sum", SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", 
					SUM("Cess_Sum") AS "cess_sum", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", 
					"Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
					"BpStateCode", "BpStateGSTN", "BpGSTN", "HSN Code" FROM PTS_GSTR3 
					WHERE "ImpOrExp" = 'Y' AND "DocType" = 'S' AND IFNULL("HSN Code", '') <> '' 
					AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :Month AND "PIndicator" = :Year 
			       GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, 
			       "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
			       "BpStateCode", "BpStateGSTN", "Year", "BpGSTN", "HSN Code") AS a 
			GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "DocEntry") 
			AS b GROUP BY "LocGSTN", "PIndicator", "Month", "Year"
 
  ),
  ---------------------------------------------------------------
  LOCAL_PURCHASE_NOT_REVERSE_GSTTYPE_NOT_3 as 
  (
  
SELECT SUM(AP_INVOICE) - SUM(DEBIT_NOTE) + SUM(AP_DOWNPAYMENT) AS "TOTAL_PURCHASE", 
	 SUM("AP_INV_freight") - SUM("DEBIT_NOTE_freight") + SUM("AP_DOWN_freight") AS "freight", 
	 SUM("AP_INV_cgst_sum") - SUM("DEBIT_NOTE_cgst_sum") + SUM("AP_DOWN_cgst_sum") AS "CGST_SUM", 
	 SUM("AP_INV_sgst_sum") - SUM("DEBIT_NOTE_sgst_sum") + SUM("AP_DOWN_sgst_sum") AS "SGST_SUM", 
	 SUM("AP_INV_igst_sum") - SUM("DEBIT_NOTE_igst_sum") + SUM("AP_DOWN_igst_sum") AS "IGST_SUM", 
	 SUM("AP_INV_cess_sum") - SUM("DEBIT_NOTE_cess_sum") + SUM("AP_DOWN_cess_sum") AS "Cess_sum", 
	 "LocGSTN", "PIndicator", "Month", "Year" 
	 FROM (SELECT (CASE WHEN "ObjType" = 18 THEN SUM("basesum") ELSE 0 END) AS "AP_INVOICE", 
	 		      (CASE WHEN "ObjType" = 19 THEN SUM("basesum") ELSE 0 END) AS "DEBIT_NOTE", 
	 		      (CASE WHEN "ObjType" = 204 THEN SUM("basesum") ELSE 0 END) AS "AP_DOWNPAYMENT", 
	 		      (CASE WHEN "ObjType" = 18 THEN ("freight") ELSE 0 END) AS "AP_INV_freight", 
	 		      (CASE WHEN "ObjType" = 19 THEN ("freight") ELSE 0 END) AS "DEBIT_NOTE_freight", 
	 		      (CASE WHEN "ObjType" = 204 THEN ("freight") ELSE 0 END) AS "AP_DOWN_freight", 
	 		      (CASE WHEN "ObjType" = 18 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AP_INV_cgst_sum", 
	 		      (CASE WHEN "ObjType" = 19 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "DEBIT_NOTE_cgst_sum", 
	 		      (CASE WHEN "ObjType" = 204 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AP_DOWN_cgst_sum", 
	 		      (CASE WHEN "ObjType" = 18 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AP_INV_sgst_sum", 
	 		      (CASE WHEN "ObjType" = 19 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "DEBIT_NOTE_sgst_sum", 
	 		      (CASE WHEN "ObjType" = 204 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AP_DOWN_sgst_sum", 
	 		      (CASE WHEN "ObjType" = 18 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AP_INV_igst_sum", 
	 		      (CASE WHEN "ObjType" = 19 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "DEBIT_NOTE_igst_sum", 
	 		      (CASE WHEN "ObjType" = 204 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AP_DOWN_igst_sum", 
	 		      (CASE WHEN "ObjType" = 18 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_INV_cess_sum", 
	 		      (CASE WHEN "ObjType" = 19 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "DEBIT_NOTE_cess_sum", 
	 		      (CASE WHEN "ObjType" = 204 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_DOWN_cess_sum", 
	 		      "LocGSTN", "PIndicator", "Month", "Year", "DocEntry" 
	 		      FROM (SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", 
	 		            SUM("CGST_Sum") AS "cgst_sum", SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", 
	 		            SUM("Cess_Sum") AS "cess_sum", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", "Reverse_Charge", 
	 		            "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", "BpStateCode", "BpStateGSTN", 
	 		            "BpGSTN", "HSN Code" 
	 		            FROM PTS_GSTR3 WHERE "ImpOrExp" = 'N' AND "Reverse_Charge" = 'N' AND "BpGSTType" <> 3 
	 		            AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :Month AND "PIndicator" = :Year 
						GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, 
						"ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
						"BpStateCode", "BpStateGSTN", "Year", "BpGSTN", "HSN Code") AS a 
				 GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", F_CGST, F_SGST, F_IGST, 
				 "freight", F_CESS, "DocEntry") AS b GROUP BY "LocGSTN", "PIndicator", "Month", "Year"

),
-------------------------------------------------------------
LOCAL_PURCHASE_REVERSE_CHARGE_TAX as 
(
SELECT SUM(AP_INVOICE) - SUM(DEBIT_NOTE) + SUM(AP_DOWNPAYMENT) AS "TOTAL_PURCHASE", 
	   SUM("AP_INV_freight") - SUM("DEBIT_NOTE_freight") + SUM("AP_DOWN_freight") AS "freight", 
	   SUM("AP_INV_cgst_sum") - SUM("DEBIT_NOTE_cgst_sum") + SUM("AP_DOWN_cgst_sum") AS "CGST_SUM", 
	   SUM("AP_INV_sgst_sum") - SUM("DEBIT_NOTE_sgst_sum") + SUM("AP_DOWN_sgst_sum") AS "SGST_SUM", 
	   SUM("AP_INV_igst_sum") - SUM("DEBIT_NOTE_igst_sum") + SUM("AP_DOWN_igst_sum") AS "IGST_SUM", 
	   SUM("AP_INV_cess_sum") - SUM("DEBIT_NOTE_cess_sum") + SUM("AP_DOWN_cess_sum") AS "Cess_sum", 
	   "LocGSTN", "PIndicator", "Month", "Year" 
	   FROM (SELECT "DocEntry", (CASE WHEN "ObjType" = 18 THEN SUM("basesum") ELSE 0 END) AS "AP_INVOICE", 
	   				(CASE WHEN "ObjType" = 19 THEN SUM("basesum") ELSE 0 END) AS "DEBIT_NOTE", 
	   				(CASE WHEN "ObjType" = 204 THEN SUM("basesum") ELSE 0 END) AS "AP_DOWNPAYMENT", 
	   				(CASE WHEN "ObjType" = 18 THEN ("freight") ELSE 0 END) AS "AP_INV_freight", 
	   				(CASE WHEN "ObjType" = 19 THEN ("freight") ELSE 0 END) AS "DEBIT_NOTE_freight", 
	   				(CASE WHEN "ObjType" = 204 THEN ("freight") ELSE 0 END) AS "AP_DOWN_freight", 
	   				(CASE WHEN "ObjType" = 18 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AP_INV_cgst_sum", 
	   				(CASE WHEN "ObjType" = 19 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "DEBIT_NOTE_cgst_sum", 
	   				(CASE WHEN "ObjType" = 204 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AP_DOWN_cgst_sum", 
	   				(CASE WHEN "ObjType" = 18 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AP_INV_sgst_sum", 
	   				(CASE WHEN "ObjType" = 19 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "DEBIT_NOTE_sgst_sum", 
	   				(CASE WHEN "ObjType" = 204 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AP_DOWN_sgst_sum", 
	   				(CASE WHEN "ObjType" = 18 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AP_INV_igst_sum", 
	   				(CASE WHEN "ObjType" = 19 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "DEBIT_NOTE_igst_sum", 
	   				(CASE WHEN "ObjType" = 204 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AP_DOWN_igst_sum", 
	   				(CASE WHEN "ObjType" = 18 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_INV_cess_sum", 
	   				(CASE WHEN "ObjType" = 19 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "DEBIT_NOTE_cess_sum", 
	   				(CASE WHEN "ObjType" = 204 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AP_DOWN_cess_sum", 
	   				"LocGSTN", "PIndicator", "Month", "Year" 
	   				FROM (SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", 
	   					  SUM("CGST_Sum") AS "cgst_sum", SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", 
	   					  SUM("Cess_Sum") AS "cess_sum", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", 
	   					  "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
	   					  "BpStateCode", "BpStateGSTN", "BpGSTN", "HSN Code" 
	   					  FROM PTS_GSTR3 WHERE "ImpOrExp" = 'N' AND "Reverse_Charge" = 'Y'
	   					  AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :Month AND "PIndicator" = :Year 
                          GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", 
                          F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", "Reverse_Charge", "isgsttax", 
                          "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", "BpStateCode", 
                          "BpStateGSTN", "Year", "BpGSTN", "HSN Code"
                          ) AS a 
                    GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, 
                    F_CESS, "DocEntry"
                ) AS b 
                GROUP BY "LocGSTN", "PIndicator", "Month", "Year"
)



  select distinct C1."IGST_SUM" "C1_IGST_SUM",C1."SGST_SUM" "C1_SGST_SUM"
			   ,C1."CGST_SUM" "C1_CGST_SUM",C1."Cess_sum" "C1_Cess_sum",
			   -----------------------------------------------------------
			    C2."IGST_SUM" "C2_IGST_SUM",C2."SGST_SUM" "C2_SGST_SUM"
			   ,C2."CGST_SUM" "C2_CGST_SUM",C2."Cess_sum" "C2_Cess_sum",
			      -----------------------------------------------------------
			    C3."IGST_SUM" "C3_IGST_SUM",C3."SGST_SUM" "C3_SGST_SUM"
			   ,C3."CGST_SUM" "C3_CGST_SUM",C3."Cess_sum" "C3_Cess_sum",
			      -----------------------------------------------------------
			    C4."IGST_SUM" "C4_IGST_SUM",C4."SGST_SUM" "C4_SGST_SUM"
			   ,C4."CGST_SUM" "C4_CGST_SUM",C4."Cess_sum" "C4_Cess_sum"

   from PTS_GSTR3 C
   left outer join IMPORT_PURCHASE_ITEM_HSN_NOT_NULL C1 on c."LocGSTN"=C1."LocGSTN" and c."PIndicator"=C1."PIndicator" and c."Month"=C1."Month"
   left outer join IMPORT_PURCHASE_SERVICE_SAC_NOT_NULL C2 on c."LocGSTN"=C2."LocGSTN" and c."PIndicator"=C2."PIndicator" and c."Month"=C2."Month"
   left outer join  LOCAL_PURCHASE_REVERSE_CHARGE_TAX C3 on c."LocGSTN"=C3."LocGSTN" and c."PIndicator"=C3."PIndicator" and c."Month"=C3."Month" 
   left outer join LOCAL_PURCHASE_NOT_REVERSE_GSTTYPE_NOT_3 C4   on c."LocGSTN"=C4."LocGSTN" and c."PIndicator"=C4."PIndicator" and c."Month"=C4."Month" 
   where c."LocGSTN"=:LOCATIONGSTIN and c."Month"=:Month and c."PIndicator"=:Year;
 END

 