%Global _service;
%Global _Host;
%Global _Path;

%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

*=================================================================================================
	THIS SECTION CREATES THE API_COLUMNS TABLE IN THE OBDATA LIBRARY TO POPULATE THE ADHOC
	REPORTS DROP DOWN BOXES IN THE SAS AD-HOC REPORT SECTION
==================================================================================================;
/*
%Macro Columns(Dsn);
Libname OBData "C:\inetpub\wwwroot\sasweb\data\perm";
Proc Contents Data=OBData.&Dsn 
	Out=Work.&Dsn (Keep=Name); 
Run; 
Data Work.&Dsn(Keep=&Dsn);
	Set Work.&Dsn;
	&Dsn = Name;
Run;

Proc Summary Data = OBData.&Dsn(Keep = Bank Count);
	Class Bank;
	Var Count;
	Output Out = Work.&Dsn._BankName(Keep = Bank) Sum=;
Run;

Data Work.&Dsn._BankName(Drop = Bank);
	Set Work.&Dsn._BankName;

	&Dsn._Bank = Bank;
	
	&Dsn._Bank_Desc = Tranwrd(Trim(Left(Bank)),' ','_');

	If Bank EQ '' Then Delete;
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
	SME_geographic

	ATM_geographic_BankName
	BCH_geographic_BankName
	BCA_geographic_BankName
	PCA_geographic_BankName
	CCC_geographic_BankName
	SME_geographic_BankName;

Run;
*/


%Macro Login();

%If "&_action" EQ "ATM" %Then
%Do;
	%Let _API_Val = ATM;
%End;
%Else %If "&_action" EQ "BRANCH" %Then
%Do;
	%Let _API_Val = BCH;
%End;
%Else %If "&_action" EQ "PERSONAL CURRENT ACCOUNT" %Then
%Do;
	%Let _API_Val = PCA;
%End;
%Else %If "&_action" EQ "BUSINESS CURRENT ACCOUNT" %Then
%Do;
	%Let _API_Val = BCA;
%End;
%Else %If "&_action" EQ "COMMERCIAL CREDIT CARD" %Then
%Do;
	%Let _API_Val = CCC;
%End;
%Else %If "&_action" EQ "SME LOAN" %Then
%Do;
	%Let _API_Val = SME;
%End;

%Macro Import(Filename);

 /**********************************************************************
 *   PRODUCT:   SAS
 *   VERSION:   9.4
 *   CREATOR:   External File Interface
 *   DATE:      21JUN17
 *   DESC:      Generated SAS Datastep Code
 *   TEMPLATE SOURCE:  (None Specified.)
 ***********************************************************************/
/*
 data Work.BANK_API_LIST OBData.Bank_API_List;
    %let _EFIERR_ = 0; 
    infile "&Filename" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
       informat Bank_Name $10. ;
       informat Bank_Description $27. ;
       informat API_Name $3. ;
       informat API_Desc $25. ;
       format Bank_Name $10. ;
       format Bank_Description $27. ;
       format API_Name $3. ;
       format API_Desc $25. ;
    input
                Bank_Name $
                Bank_Description $
                API_Name $
                API_Desc $
    ;
    if _ERROR_ then call symputx('_EFIERR_',1); 
	Bank_Desc = Tranwrd(Trim(Left(Bank_Description)),' ','_');
 run;	

Proc Sort Data = Work.Bank_API_List(Keep = Bank_Name Bank_Desc Bank_Description)
	Out = Work.Bank_Name Nodupkey;
	By Bank_Desc;
Run;


Data Work.Bank_Name;
	Set OBData.&_API_Val._geographic(Keep = Bank);
	Bank_Desc = Tranwrd(Trim(Left(Bank_Description)),' ','_');
Run;

Proc Summary Data = OBData.&_API_Val._geographic(Keep = Bank &_API_Val.Count);
	Class Bank;
	Var &_API_Val.Count;
	Output Out = Work.Bank_Name(Keep = Bank Bank_Desc) Sum=;
Run;

Data Work.Bank_Name;
	Set Work.Bank_Name;
	Bank_Desc = Tranwrd(Trim(Left(Bank_Description)),' ','_');
Run;

Proc Sort Data = Work.Bank_Name Nodupkey;
	By Bank Bank_Desc;
Run;
*/
%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Perm\Bank_API_List.csv);

Data _NULL_;
File _Webout;
	Put '<HTML>';
	Put '<HEAD>';
	Put '<html xmlns="http://www.w3.org/1999/xhtml">';
	Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
	Put '<meta http-equiv="X-UA-Compatible" content="IE=10"/>';
	Put '<title>OB TESTING</title>';

	Put '<meta charset="utf-8" />';
	Put '<title>Open Data Test Application</title>';
	Put '<meta name="description" content="">';
	Put '<meta name="author" content="">';
		
	Put '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />'; 
		
	Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
	Put '<title>OBIE</title>';

	Put '<script type="text/javascript" src="'"&_Path/js/jquery.js"'">';
	Put '</script>';

	Put '<link rel="stylesheet" type="text/css" href="'"&_Path/css/style.css"'">';

	Put '</HEAD>';

	Put '<BODY>';
	*--- Table 1 - Image ---;
	Put '<table style="width: 100%; height: 5%" border="0">';
	Put '<tr>';
	Put '<td valign="top" style="background-color: lightblue; color: orange">';
	Put '<img src="'"&_Path/images/london.jpg"'" alt="Cannot find image" style="width:100%;height:8%px;">';
	Put '</td>';
	Put '</tr>';
	Put '</table>';

	*--- Space below image ---;
	Put '<p><br></p>';
	Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';

	*--- Table 2 - Drop Down Table ---;
	Put '<table align = "center" style="width: 60%; height: 5%" border="1">';
	Put '<tr>';

	Put '<td valign="top" style="background-color: white; color: black" border="1">';
		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<b>API ' /
		"&_API_Val." 
		' SELECTED</b>';
		Put '<p></p>';

	*--- Read Dataset UniqueNames ---;
		 	%Let Dsn = %Sysfunc(Open(OBData.API_Columns(Keep = &_API_Val._geographic)));
	*--- Count Observations ---;
		    %Let Count = %Eval(%Sysfunc(Attrn(&Dsn,Nobs))+1);

	*--- Populate Drop Down Box on HTML Page ---;
			Put	'<select name="_API_Selected" size="2" Selected>' /;
							Put '<option value='
								"&_action"
								'>' /
								"&_action"
								'</option>' /;
		Put '</div>';
	Put '</td>';


	Put '<td valign="top" style="background-color: white; color: black" border="1">';
		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<b>SELECT BANK NAME</b>';
		Put '<p></p>';


	*--- Read Dataset UniqueNames ---;
		 	%Let Dsn = %Sysfunc(Open(OBData.API_Columns));
	*--- Count Observations ---;
		    %Let Count = %Eval(%Sysfunc(Attrn(&Dsn,Nobs))+1);

			Put	'<select name="_Bank_Selected" size="15" multiple>' /;
	*--- Populate Drop Down Box on HTML Page ---;
			%Do I = 1 %To &Count;
		        %Let Rc = %Sysfunc(fetch(&Dsn,&i));
				%Let Start=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,&_API_Val._geographic_Bank_Desc))));
				%Let Label=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,&_API_Val._geographic_Bank))));
					%If "&Start" ne " " %Then
					%Do;
						%If &I=1 %Then 
						%Do;
							Put '<option value='
								"&Start"
								'>' /
								"&Label"
								'</option>' /;
						%End;
						%Else
						%Do;
				            Put '<option value='
								"&Start"
								'>' /
								"&Label"
								'</option>' /;
						%End;
					%End;
						%Else %Let I = &Count;
					%End;

					%Let Rc = %Sysfunc(Close(&Dsn));

		Put '</div>';
	Put '</td>';






	Put '<td valign="top" style="background-color: white; color: black" border="1">';
		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<b>SELECT ' /
		"&_API_Val." 
		' FIELD NAMES </b>';
		Put '<p></p>';

	*--- Read Dataset UniqueNames ---;
		 	%Let Dsn = %Sysfunc(Open(OBData.API_Columns(Keep = &_API_Val._geographic)));
	*--- Count Observations ---;
		    %Let Count = %Eval(%Sysfunc(Attrn(&Dsn,Nobs))+1);

	*--- Populate Drop Down Box on HTML Page ---;
			Put	'<select name="_API_Field" size="20" multiple>' /;
			%Do I = 1 %To &Count;
		        %Let Rc = %Sysfunc(fetch(&Dsn,&i));
				%Let Start=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,&_API_Val._geographic))));
				%Let Label=%Sysfunc(GETVARC(&Dsn,%Sysfunc(VARNUM(&Dsn,&_API_Val._geographic))));
					%If "&Start" ne " " %Then
					%Do;
						%If &I=1 %Then 
						%Do;
							Put '<option value='
								"&Start"
								'>' /
								"&Label"
								'</option>' /;
						%End;
						%Else
						%Do;
				            Put '<option value='
								"&Start"
								'>' /
								"&Label"
								'</option>' /;
						%End;
					%End;
						%Else %Let I = &Count;
					%End;

					%Let Rc = %Sysfunc(Close(&Dsn));

		Put '</div>';
	Put '</td>';
	Put '</tr>';
	Put '</table>';

	*--- Space below image ---;
	Put '<p><br></p>';

	*--- Table 3 - Submit button ---;
	Put '<table style="width: 100%; height: 5%" border="0">';
	Put '<td valign="center" align="center" border="1" style="background-color: lightblue; color: Black">';
	Put '<INPUT TYPE=submit VALUE="Submit Details" valign="center">';

	Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.API_Columns_Report.sas">';
	Put '<INPUT TYPE=hidden NAME=_service VALUE=' /
		"&_service"
		'>';

	Put '<INPUT TYPE=hidden NAME=_debug VALUE=' /
		"&_debug"
		'>';
	Put '<INPUT TYPE=hidden NAME=_API_Val VALUE=' /
		"&_API_Val"
		'>';
	Put '<INPUT TYPE=hidden NAME=_WebUser VALUE=' /
		"&_WebUser"
		'>';
	Put '<INPUT TYPE=hidden NAME=_WebPass VALUE=' /
		"&_WebPass"
		'>';

	Put '</FORM>';
	Put '</td>';
	Put '</tr>';
	Put '</table>';

	*--- Table 4 - All Rights Reserved ---;
	Put '<table style="width: 100%; height: 10%" border="0">';
	Put '<td valign="top" style="background-color: White; color: black">';
	Put '<H3>All Rights Reserved</H3>';
	Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
	Put '</td>';
	Put '</table>';

	Put '</BODY>';
	Put '<HTML>';

Run;
%Mend Login;
%Login();
