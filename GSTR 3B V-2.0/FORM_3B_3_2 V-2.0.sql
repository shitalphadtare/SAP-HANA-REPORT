create PROCEDURE FORM_3B_3_2

(IN LOCATIONGSTIN  nvarchar(100),
IN Month nvarchar(100),
IN Year  nvarchar(100))

LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
AS
 Begin 
  with LOCAL_SALES_BPGSTN_NULL_IGST as
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
	   		(CASE WHEN "ObjType" = 13 THEN ("freight") ELSE 0 END) AS "AR_INV_freight", 
	   		(CASE WHEN "ObjType" = 14 THEN ("freight") ELSE 0 END) AS "CREDIT_NOTE_freight", 
	   		(CASE WHEN "ObjType" = 203 THEN ("freight") ELSE 0 END) AS "AR_DOWN_freight", 
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
	   				"BpStateCode", "BpGSTN", "BpStateGSTN" FROM PTS_GSTR3 
	   				WHERE "BpGSTN" = '' AND "ImpOrExp" = 'N' AND TAX_CODE = 'IGST' 
	   				AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :Month AND "PIndicator" = :Year 
					GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, 
					F_CESS, "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", 
					"BpGSTType", "BpStateCode", "BpGSTN", "Year", "BpStateGSTN"
					) AS a 
		    GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", F_CGST, F_SGST, F_IGST, F_CESS, "DocEntry", "freight"
		    ) AS b 
		GROUP BY "LocGSTN", "PIndicator", "Month", "Year"
  ),
  ------------------------------------------------------------------------------------------
LOCAL_SALES_BPGSTTYPE_COMPOSITE_LEVY_IGST as
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
	   		(CASE WHEN "ObjType" = 13 THEN ("freight") ELSE 0 END) AS "AR_INV_freight", 
	   		(CASE WHEN "ObjType" = 14 THEN ("freight") ELSE 0 END) AS "CREDIT_NOTE_freight", 
	   		(CASE WHEN "ObjType" = 203 THEN ("freight") ELSE 0 END) AS "AR_DOWN_freight", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AR_INV_cgst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "CREDIT_NOTE_cgst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("cgst_sum") + (F_CGST) ELSE 0 END) AS "AR_DOWN_cgst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AR_INV_sgst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "CREDIT_NOTE_sgst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("sgst_sum") + (F_SGST) ELSE 0 END) AS "AR_DOWN_sgst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("igst_sum") + SUM(F_IGST) ELSE 0 END) AS "AR_INV_igst_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("igst_sum") + SUM(F_IGST) ELSE 0 END) AS "CREDIT_NOTE_igst_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("igst_sum") + SUM(F_IGST) ELSE 0 END) AS "AR_DOWN_igst_sum", 
	   		(CASE WHEN "ObjType" = 13 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AR_INV_cess_sum", 
	   		(CASE WHEN "ObjType" = 14 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "CREDIT_NOTE_cess_sum", 
	   		(CASE WHEN "ObjType" = 203 THEN SUM("cess_sum") + F_CESS ELSE 0 END) AS "AR_DOWN_cess_sum", 
	   		"LocGSTN", "PIndicator", "Month", "Year" 
	   		FROM (SELECT "DocEntry", "ObjType", "PIndicator", "Month", "Year", SUM("BaseSum") AS "basesum", 
	   			   SUM("CGST_Sum") AS "cgst_sum", SUM("SGST_Sum") AS "sgst_sum", SUM("IGST_Sum") AS "igst_sum", 
	   			   SUM("Cess_Sum") AS "cess_sum", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "ImpOrExp", 
	   			   "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
	   			   "BpStateCode", "BpGSTN", "BpStateGSTN" FROM PTS_GSTR3 
	   			   WHERE "ImpOrExp" = 'N' AND "BpGSTType" = 3 AND TAX_CODE = 'IGST' 
	   			   AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :Month AND "PIndicator" = :Year 
                   GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, 
                   F_CESS, "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", 
                   "BpGSTType", "BpStateCode", "BpGSTN", "Year", "BpStateGSTN"
                   ) AS a 
             GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", F_CGST, F_SGST, F_IGST, F_CESS, "DocEntry", "freight"
             ) AS b 
         GROUP BY "LocGSTN", "PIndicator", "Month", "Year"

  ),
--------------------------------------------------------------------------------------------
LOCAL_SALES_BPGSTTYPE_UN_AGENCY as
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
	   		(CASE WHEN "ObjType" = 13 THEN ("freight") ELSE 0 END) AS "AR_INV_freight", 
	   		(CASE WHEN "ObjType" = 14 THEN ("freight") ELSE 0 END) AS "CREDIT_NOTE_freight", 
	   		(CASE WHEN "ObjType" = 203 THEN ("freight") ELSE 0 END) AS "AR_DOWN_freight", 
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
	   			  "BpGSTType", "BpStateCode", "BpGSTN", "BpStateGSTN" 
	   			  FROM PTS_GSTR3 WHERE "ImpOrExp" = 'N' AND "BpGSTType" = 6 AND TAX_CODE = 'IGST' 
	   			  AND "LocGSTN" = :LOCATIONGSTIN AND "Month" = :Month AND "PIndicator" = :Year 
				  GROUP BY "DocEntry", "ObjType", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, 
				  "ImpOrExp", "Reverse_Charge", "isgsttax", "GSTTranTyp", "LocGSTType", "LocGSTN", "LocStateGSTN", "BpGSTType", 
				  "BpStateCode", "BpGSTN", "Year", "BpStateGSTN"
				  ) AS a 
		    GROUP BY "ObjType", "LocGSTN", "PIndicator", "Month", "Year", "freight", F_CGST, F_SGST, F_IGST, F_CESS, "DocEntry"
		    ) AS b GROUP BY "LocGSTN", "PIndicator", "Month", "Year"

)
-------------------------------------------------------------------------------------


  select distinct b1."TOTAL_SALE" as "b1_TOTAL_SALE",b1."freight"as "b1_freight" ,b1."IGST_SUM" as "b1_IGST_SUM",
				  b2."TOTAL_SALE" as "b2_TOTAL_SALE",b2."freight"as "b2_freight" ,b2."IGST_SUM" as "b2_IGST_SUM",
				  b3."TOTAL_SALE" as "b3_TOTAL_SALE",b3."freight"as "b3_freight" ,b3."IGST_SUM" as "b3_IGST_SUM"

   from PTS_GSTR3 C
   left Outer join LOCAL_SALES_BPGSTN_NULL_IGST B1  on c."LocGSTN"=B1."LocGSTN" and c."PIndicator"=B1."PIndicator" and c."Month"=B1."Month"
   left outer join LOCAL_SALES_BPGSTTYPE_COMPOSITE_LEVY_IGST B2 on c."LocGSTN"=B2."LocGSTN" and c."PIndicator"=B2."PIndicator" and c."Month"=B2."Month"
   left outer join LOCAL_SALES_BPGSTTYPE_UN_AGENCY B3 on c."LocGSTN"=B3."LocGSTN" and c."PIndicator"=B3."PIndicator" and c."Month"=B3."Month"
   where c."LocGSTN"=:LOCATIONGSTIN and c."Month"=:Month and c."PIndicator"=:Year;
   end
  