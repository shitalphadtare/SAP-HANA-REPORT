CREATE VIEW RECONCILATION_DETAILS AS select
	 STRING_AGG("D"."C",
	 ' ,') "Recon_Doc",
	"ReconNum" 
from (Select
	 case when res."A"<>'' 
	then res."A" when res."B"<>'' 
	then res."B" when res."Q"<>'' 
	then res."Q" when res."W"<>'' 
	then res."W" when res."R"<>'' 
	then res."R" when res."T"<>'' 
	then res."T" when res."Y"<>'' 
	then res."Y" when res."O"<>'' 
	then res."O" 
	else res."I" 
	end "C",
	"ReconNum" 
	from (select
	 JDT."TransId",
	Nm1."SeriesName"||'/'||inv."DocNum" A,
	 Nm2."SeriesName"||'/'||RIN."DocNum" b,
	 (nm3."SeriesName")||'/'||PCH."DocNum" q,
	 (nm4."SeriesName")||'/'||RPC."DocNum" w,
	 (nm9."SeriesName")||'/'||DPI."DocNum" r,
	 (nm8."SeriesName")||'/'||DPO."DocNum"t,
	 (nm6."SeriesName")||'/'|| RCT."DocNum" y,
	 (nm7."SeriesName")||'/'||JDT."BaseRef"i,
	 (nm5."SeriesName")||'/'||VPM."DocNum" o ,
	ir1."ReconNum" 
		from ITR1 Ir1 
		left outer join OJDT JDT on jDT."CreatedBy"=IR1."ReconNum" 
		and jdt."TransType"=321 
		left outer join oinv INV on IR1."TransId"=INV."TransId" 
		left outer join NNM1 nm1 on INV."Series"=nm1."Series" 
		left outer join ORIN RIN on RIN."TransId"=IR1."TransId" 
		left outer join nnm1 nm2 on RIN."Series"=nm2."Series" 
		left outer join OPCH PCH on Ir1."TransId"=PCH."TransId" 
		left outer join nnm1 nm3 on PCH."Series"=nm3."Series" 
		left outer join ORPC RPC on Ir1."TransId"=RPC."TransId" 
		left outer join nnm1 nm4 on RPC."Series"=nm4."Series" 
		left outer join OVPM VPM on Ir1."TransId"=VPM."TransId" 
		left outer join nnm1 nm5 on VPM."Series"=nm5."Series" 
		left outer join ORCT RCT on Ir1."TransId"=RCT."TransId" 
		left outer join nnm1 nm6 on RCT."Series"=nm6."Series" 
		left outer join ODPO DPO on Ir1."TransId"=DPO."TransId" 
		left outer join nnm1 nm8 on DPO."Series"=nm8."Series" 
		left outer join ODPI DPI on Ir1."TransId"=DPI."TransId" 
		left outer join nnm1 nm9 on DPI."Series"=nm9."Series" 
		left outer join nnm1 nm7 on jdt."Series"=nm7."Series" 
		order by ir1."LineSeq" ) RES) D 
group by "ReconNum"