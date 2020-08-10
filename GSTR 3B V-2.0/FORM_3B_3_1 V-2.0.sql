create PROCEDURE FORM_3B_3_1

(IN LOCATIONGSTIN  nvarchar(100),
IN Month nvarchar(100),
IN Year  nvarchar(100))

LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
AS
 Begin
 with LOCAL_SALES_TAXR_0 as
 (	
SELECT SUM(AR_INVOICE) - SUM("CREDIT_NOTE") + SUM(AR_DOWNPAYMENT) AS "TOTAL_SALE", 
	   SUM("AR_INV_freight") - SUM("CREDIT_NOTE_freight") + SUM("AR_DOWN_freight") AS "freight", 
	   SUM("AR_INV_cgst_sum") - SUM("CREDIT_NOTE_cgst_sum") + SUM("AR_DOWN_cgst_sum") AS "CGST_SUM", 
	   SUM("AR_INV_sgst_sum") - SUM("CREDIT_NOTE_sgst_sum") + SUM("AR_DOWN_sgst_sum") AS "SGST_SUM", 
	   SUM("AR_INV_igst_sum") - SUM("CREDIT_NOTE_igst_sum") + SUM("AR_DOWN_igst_sum") AS "IGST_SUM", 
	   SUM("AR_INV_cess_sum") - SUM("CREDIT_NOTE_cess_sum") + SUM("AR_DOWN_cess_sum") AS "Cess_sum", 
	   "LocGSTN", "PIndicator", "Month", "Year" 
	   FROM (SELECT "DocEntry", (CASE WHEN "ObjType" = 13 THEN SUM("basesum") ELSE 0 END) AS "AR_INVOICE", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("basesum") ELSE 0 END) AS "CREDIT_NOTE", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("basesum") ELSE 0 END) AS "AR_DOWNPAYMENT", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("freight") ELSE 0 END) AS "AR_INV_freight", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("freight") ELSE 0 END) AS "CREDIT_NOTE_freight", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("freight") ELSE 0 END) AS "AR_DOWN_freight", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AR_INV_cgst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "CREDIT_NOTE_cgst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AR_DOWN_cgst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AR_INV_sgst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "CREDIT_NOTE_sgst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AR_DOWN_sgst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AR_INV_igst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "CREDIT_NOTE_igst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AR_DOWN_igst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AR_INV_cess_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "CREDIT_NOTE_cess_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AR_DOWN_cess_sum", 
	   		"LocGSTN", "PIndicator", "Month", "Year" 
	   		FROM (SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", 
	   			  SUM("CGST_Sum") AS "cgst_sum", SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", 
	   			  SUM("Cess_Sum") AS "cess_sum", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", "Reverse_Charge", 
	   			  "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", "BpStateCode", "BpStateGSTN" 
	   			  FROM PTS_GSTR3 WHERE "VatPercent" <> 0 AND "ImpOrExp" = 'N' 
	   			  AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :Month AND "PIndicator" = :Year 
				  GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, 
				  "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
				  "BpStateCode", "BpStateGSTN", "Year"
		           ) AS a 
		       GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", "DocEntry",
				   F_CGST, F_SGST, F_IGST, F_CESS
	) AS b GROUP BY "LocGSTN", "PIndicator", "Month", "Year"

),
-------------------------------------------------------------------------------------------------------------------------------------
LOCAL_SALES_TAXRATE0_ITEM_0 as
(
SELECT SUM(AR_INVOICE) - SUM(CREDIT_NOTE) + SUM(AR_DOWNPAYMENT) AS "TOTAL_SALE", 
	   SUM("AR_INV_freight") - SUM("CREDIT_NOTE_freight") + SUM("AR_DOWN_freight") AS "freight", 
	   SUM("AR_INV_cgst_sum") - SUM("CREDIT_NOTE_cgst_sum") + SUM("AR_DOWN_cgst_sum") AS "CGST_SUM", 
	   SUM("AR_INV_sgst_sum") - SUM("CREDIT_NOTE_sgst_sum") + SUM("AR_DOWN_sgst_sum") AS "SGST_SUM", 
	   SUM("AR_INV_igst_sum") - SUM("CREDIT_NOTE_igst_sum") + SUM("AR_DOWN_igst_sum") AS "IGST_SUM", 
	   SUM("AR_INV_cess_sum") - SUM("CREDIT_NOTE_cess_sum") + SUM("AR_DOWN_cess_sum") AS "Cess_sum", 
	   "LocGSTN", "PIndicator", "Month", "Year" 
	   FROM (SELECT "DocEntry", (CASE WHEN "ObjType" = 13 THEN SUM("basesum") ELSE 0 END) AS "AR_INVOICE", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("basesum") ELSE 0 END) AS "CREDIT_NOTE", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("basesum") ELSE 0 END) AS "AR_DOWNPAYMENT", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("freight") ELSE 0 END) AS "AR_INV_freight", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("freight") ELSE 0 END) AS "CREDIT_NOTE_freight", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("freight") ELSE 0 END) AS "AR_DOWN_freight", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AR_INV_cgst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "CREDIT_NOTE_cgst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AR_DOWN_cgst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AR_INV_sgst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "CREDIT_NOTE_sgst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AR_DOWN_sgst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AR_INV_igst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "CREDIT_NOTE_igst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AR_DOWN_igst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AR_INV_cess_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "CREDIT_NOTE_cess_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AR_DOWN_cess_sum", 
	   		"LocGSTN", "PIndicator", "Month", "Year" 
	   		FROM (SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", 
	   			  SUM("CGST_Sum") AS "cgst_sum", SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", 
	   			  SUM("Cess_Sum") AS "cess_sum", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", 
	   			  "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
	   			  "BpStateCode", "BpStateGSTN" FROM PTS_GSTR3 WHERE "VatPercent" = 0 AND "ImpOrExp" = 'N' AND "Item_Tax_Type" IN ('N')
	   			   AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :Month AND "PIndicator" = :Year 
				  GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, 
				  "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
				  "BpStateCode", "BpStateGSTN", "Year"
				  ) AS a 
			GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", "DocEntry", F_CGST, F_SGST, F_IGST, F_CESS
			) AS b 
	GROUP BY "LocGSTN", "PIndicator", "Month", "Year"
),
-------------------------------------------------------------------------------------------------------------------------------------
EXPORT_SALES_TAXRATE0 as
(
SELECT SUM(AR_INVOICE) - SUM(CREDIT_NOTE) + SUM(AR_DOWNPAYMENT) AS "TOTAL_SALE", 
	   SUM("AR_INV_freight") - SUM("CREDIT_NOTE_freight") + SUM("AR_DOWN_freight") AS "freight", 
	   SUM("AR_INV_cgst_sum") - SUM("CREDIT_NOTE_cgst_sum") + SUM("AR_DOWN_cgst_sum") AS "CGST_SUM", 
	   SUM("AR_INV_sgst_sum") - SUM("CREDIT_NOTE_sgst_sum") + SUM("AR_DOWN_sgst_sum") AS "SGST_SUM", 
	   SUM("AR_INV_igst_sum") - SUM("CREDIT_NOTE_igst_sum") + SUM("AR_DOWN_igst_sum") AS "IGST_SUM", 
	   SUM("AR_INV_cess_sum") - SUM("CREDIT_NOTE_cess_sum") + SUM("AR_DOWN_cess_sum") AS "Cess_sum", 
	   "LocGSTN", "PIndicator", "Month", "Year" 
	   FROM (SELECT "DocEntry", (CASE WHEN "ObjType" = 13 THEN SUM("basesum") ELSE 0 END) AS "AR_INVOICE", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("basesum") ELSE 0 END) AS "CREDIT_NOTE", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("basesum") ELSE 0 END) AS "AR_DOWNPAYMENT", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("freight") ELSE 0 END) AS "AR_INV_freight", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("freight") ELSE 0 END) AS "CREDIT_NOTE_freight", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("freight") ELSE 0 END) AS "AR_DOWN_freight", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AR_INV_cgst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "CREDIT_NOTE_cgst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AR_DOWN_cgst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AR_INV_sgst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "CREDIT_NOTE_sgst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AR_DOWN_sgst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AR_INV_igst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "CREDIT_NOTE_igst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AR_DOWN_igst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AR_INV_cess_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "CREDIT_NOTE_cess_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AR_DOWN_cess_sum", 
	   		"LocGSTN", "PIndicator", "Month", "Year" 
	   		FROM (SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", 
	   			  SUM("CGST_Sum") AS "cgst_sum", SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", 
	   			  SUM("Cess_Sum") AS "cess_sum", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", "Reverse_Charge", 
	   			  "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", "BpStateCode", "BpStateGSTN" 
	   			  FROM PTS_GSTR3 WHERE "VatPercent" = 0 AND "ImpOrExp" = 'Y' 
	   			  GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, 
	   			  "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
	   			  "BpStateCode", "BpStateGSTN", "Year"
	   			  ) AS a 
	   		GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", "DocEntry", F_CGST, F_SGST, F_IGST, F_CESS
	   		) AS b 
	   GROUP BY "LocGSTN", "PIndicator", "Month", "Year"
),
------------------------------------------------------------------------------------------------------------
LOCAL_PURCHASE_REVERSE as
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
	   			  "BpStateCode", "BpStateGSTN" FROM PTS_GSTR3 
	   			  WHERE "ImpOrExp" = 'N' AND "Reverse_Charge" = 'Y' 
	   			  AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :Month AND "PIndicator" = :Year 
				  GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, 
				  "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
				  "BpStateCode", "BpStateGSTN", "Year"
				  ) AS a 
		    GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", "DocEntry", F_CGST, F_SGST, F_IGST, F_CESS
		) AS b 
		GROUP BY "LocGSTN", "PIndicator", "Month", "Year"
),
------------------------------------------------------------------------------------------------------------------------------
SALES_NOTGST as
(
SELECT SUM(AR_INVOICE) - SUM(CREDIT_NOTE) + SUM(AR_DOWNPAYMENT) AS "TOTAL_SALE", 
	   SUM("AR_INV_freight") - SUM("CREDIT_NOTE_freight") + SUM("AR_DOWN_freight") AS "freight", 
	   SUM("AR_INV_cgst_sum") - SUM("CREDIT_NOTE_cgst_sum") + SUM("AR_DOWN_cgst_sum") AS "CGST_SUM", 
	   SUM("AR_INV_sgst_sum") - SUM("CREDIT_NOTE_sgst_sum") + SUM("AR_DOWN_sgst_sum") AS "SGST_SUM", 
	   SUM("AR_INV_igst_sum") - SUM("CREDIT_NOTE_igst_sum") + SUM("AR_DOWN_igst_sum") AS "IGST_SUM", 
	   SUM("AR_INV_cess_sum") - SUM("CREDIT_NOTE_cess_sum") + SUM("AR_DOWN_igst_sum") AS "Cess_sum", 
	   "LocGSTN", "PIndicator", "Month", "Year" 
	   FROM (SELECT "DocEntry", (CASE WHEN "ObjType" = 13 THEN SUM("basesum") ELSE 0 END) AS "AR_INVOICE", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("basesum") ELSE 0 END) AS "CREDIT_NOTE", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("basesum") ELSE 0 END) AS "AR_DOWNPAYMENT", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("freight") ELSE 0 END) AS "AR_INV_freight", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("freight") ELSE 0 END) AS "CREDIT_NOTE_freight", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("freight") ELSE 0 END) AS "AR_DOWN_freight", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AR_INV_cgst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "CREDIT_NOTE_cgst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AR_DOWN_cgst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AR_INV_sgst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "CREDIT_NOTE_sgst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AR_DOWN_sgst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AR_INV_igst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "CREDIT_NOTE_igst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("igst_sum") + (F_IGST) ELSE 0 END) AS "AR_DOWN_igst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AR_INV_cess_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "CREDIT_NOTE_cess_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AR_DOWN_cess_sum", 
	   		"LocGSTN", "PIndicator", "Month", "Year" 
	   		FROM (SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", 
	   			  SUM("CGST_Sum") AS "cgst_sum", SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", 
	   			  SUM("Cess_Sum") AS "cess_sum", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", 
	   			  "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", 
	   			  "BpGSTType", "BpStateCode", "BpStateGSTN" FROM PTS_GSTR3 WHERE "isgsttax" = 'N' 
	   			  AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :Month AND "PIndicator" = :Year 
				  GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, 
				  "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
				  "BpStateCode", "BpStateGSTN", "Year"
				  ) AS a
		    GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", F_CGST, F_SGST, F_IGST, F_CESS, "DocEntry"
		) AS b GROUP BY "LocGSTN", "PIndicator", "Month", "Year"
)

select distinct a1."TOTAL_SALE" as "a1_TOTAL_SALE",a1."freight" as "a1_freight"
			   ,a1."IGST_SUM" as "a1_IGST_SUM",a1."SGST_SUM" as "a1_SGST_SUM"
			   ,a1."CGST_SUM" as "A1_CGST_SUM",a1."Cess_sum" as "a1_Cess_sum"
			   --------------
			   ,a2."TOTAL_SALE" as "a2_TOTAL_SALE",a2."freight" as "a2_freight"
			   ,a2."IGST_SUM" as "a2_IGST_SUM",a2."SGST_SUM" as "a2_SGST_SUM"
			   ,a2."CGST_SUM" as "a3_CGST_SUM",a2."Cess_sum" as "a2_Cess_sum"
			   -------------------
			   ,a3."TOTAL_SALE" as "a3_TOTAL_SALE",a3."freight" as "a3_freight"
			   ,a3."IGST_SUM" as "a3_IGST_SUM",a3."SGST_SUM" as "a3_SGST_SUM"
			   ,a3."CGST_SUM" as "a3_CGST_SUM",a3."Cess_sum" as "a3_Cess_sum"
			   -------------------
			   ,a4."TOTAL_PURCHASE" as "a4_TOTAL_PURCHASE",a4."freight" as "a4_freight"
			   ,a4."IGST_SUM" as "a4_IGST_SUM",a4."SGST_SUM" as "a4_SGST_SUM"
			   ,a4."CGST_SUM" as "a4_CGST_SUM",a4."Cess_sum" as "a4_Cess_sum"
			   -------------------
			   ,a5."TOTAL_SALE" as "a5_TOTAL_SALE",a5."freight" as "a5_freight"
			   ,a5."IGST_SUM" as "a5_IGST_SUM",a5."SGST_SUM" as "a5_SGST_SUM"
			   ,a5."CGST_SUM" as "a5_CGST_SUM",a5."Cess_sum" as "a5_Cess_sum"

 from PTS_GSTR3 C
left outer join LOCAL_SALES_TAXR_0 A1 on c."LocGSTN"=a1."LocGSTN" and c."PIndicator"=a1."PIndicator" and c."Month"=a1."Month"
left outer join  LOCAL_SALES_TAXRATE0_ITEM_0 A2 on c."LocGSTN"=c."LocGSTN" and c."PIndicator"=c."PIndicator" and c."Month"=A2."Month"
left outer join  EXPORT_SALES_TAXRATE0 A3 on c."LocGSTN"=A3."LocGSTN" and c."PIndicator"=A3."PIndicator" and c."Month"=A3."Month"
left outer join LOCAL_PURCHASE_REVERSE A4 on c."LocGSTN"=A4."LocGSTN" and c."PIndicator"=A4."PIndicator" and c."Month"=A4."Month"
left outer join SALES_NOTGST A5 on c."LocGSTN"=A5."LocGSTN" and c."PIndicator"=A5."PIndicator" and c."Month"=A5."Month"
where c."LocGSTN"=:LOCATIONGSTIN and c."Month"=:Month and c."PIndicator"=:Year;
 END
 