CREATE VIEW "WINTAC_LIVE"."PTS_BALANCE_PER_BOOK" ( "Account",
	 "MthDate",
	 "RefDate",
	 "Bal_Perbook",
	 "Acctname" ) AS select
	 "Account",
	"MthDate",
	"RefDate",
	 ("Debit"-"Credit") "Bal_Perbook",
	 ( select
	 "AcctName" 
	from OACT 
	where "AcctCode"="Account") "Acctname" 
from jdt1