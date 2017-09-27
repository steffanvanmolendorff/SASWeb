Libname OBData "C:\inetpub\wwwroot\sasweb\data\perm";

%Macro Columns(Dsn);
Proc Contents Data=OBData.&Dsn 
	Out=Work.&Dsn (Keep=Name); 
Run; 
Data Work.&Dsn(Keep=&Dsn);
	Set Work.&Dsn;
	&Dsn = Name;
Run;
%Mend Columns;
%Columns(ATM_geographic);
%Columns(BCH_geographic);
%Columns(BCA_geographic);
%Columns(PCA_geographic);
%Columns(CCC_geographic);
%Columns(SME_geographic);

Data OBData.API_Columns;
	Merge ATM_geographic
	BCH_geographic
	BCA_geographic
	PCA_geographic
	CCC_geographic
	SME_geographic;
Run;
