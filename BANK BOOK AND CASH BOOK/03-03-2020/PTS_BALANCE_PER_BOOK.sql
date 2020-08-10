CREATE VIEW  PTS_BALANCE_PER_BOOK AS select
	 "Account",
	"MthDate",
	"RefDate",
	 ("Debit"-"Credit") "Bal_Perbook",
	 ( select
	 "AcctName" 
	from OACT 
	where "AcctCode"="Account") "Acctname" 
from jdt1