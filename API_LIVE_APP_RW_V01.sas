*=====================================================================================================================================================
--- Set system options to track comments in the log file ---
======================================================================================================================================================;
Options MLOGIC MPRINT SOURCE SOURCE2 SYMBOLGEN SPOOL;
OPTIONS NOSYNTAXCHECK;

Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";

%Global SCH_Name;
%Global SCH_Link;
%Global API_Link;
%Global API_Name;
%Global API_JSON;
%Global Perm_Sch_Table;
%Global BankName_C;
%Global Version_C;
%Global Sch_Version;
%Global FDate;
%Global _WebUser;
%Global _Attach_Email;

%Global _Host;
%Global _Path;

%Let _WebUser = /*&_WebUser*/vamola@mac.com;
%Let _Host = /*&_SRVNAME*/localhost;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;


*--- Uncomment to run on local laptop/pc machine ---;
/*
%Let _BankName = HSBC;
%Let _APIName = PMT;
%Let _VersionNo = v1.1;
*/


*=====================================================================================================================================================
--- Macro Imports read the API_Config CSV sheet and saves the values in macro variables to use in program below ---
======================================================================================================================================================;
%Macro Import(Filename);
 *=====================================================================================================================================================
 *   PRODUCT:   SAS
 *   VERSION:   9.4
 *   CREATOR:   External File Interface
 *   DATE:      04JUL17
 *   DESC:      Generated SAS Datastep Code
 *   TEMPLATE SOURCE:  (None Specified.)
======================================================================================================================================================;
Data Work.API_CONFIG    ;
    %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile 'C:\inetpub\wwwroot\sasweb\Data\Perm\API_Config.csv' delimiter = ',' MISSOVER
	DSD lrecl=32767 firstobs=2 ;
       informat Bank_Name $20. ;
       informat API_Abb $3. ;
       informat API_Link $100. ;
       informat API_Name $25. ;
       informat SCH_Link $100. ;
       informat SCH_Name $24. ;
       informat Perm_SCH_Table $10. ;
       informat Version $6. ;
	   informat API_JSON $25.;
       format Bank_Name $20. ;
       format API_Abb $3. ;
       format API_Link $100. ;
       format API_Name $25. ;
       format SCH_Link $100. ;
       format SCH_Name $24. ;
       format Perm_SCH_Table $10. ;
       format Version $6. ;
	   format API_JSON $25.;
    input
                Bank_Name $
                API_Abb $
                API_Link $
                API_Name $
                SCH_Link $
                SCH_Name $
                Perm_SCH_Table $
                Version $
				API_JSON $

    ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
Run;

Data OBDATA.API_Config;
	Set Work.API_Config(Where=(Trim(Left(Bank_Name)) EQ "&_BankName" and Trim(Left(API_Abb)) EQ "&_APIName" and Trim(Left(Version)) EQ "&_VersionNo"));
	Call Symput('BankName_C',Bank_Name);
	Call Symput('API_Link',API_Link);
	Call Symput('API_Name',API_Name);
	Call Symput('SCH_Link',SCH_Link);
	Call Symput('SCH_Name',SCH_Name);
	Call Symput('Perm_Sch_Table',Perm_Sch_Table);
	Call Symput('Version_C',Version);
	Call Symput('Sch_Version',Tranwrd(Version,'.','_'));
	Call Symput('API_JSON',Trim(Left(API_JSON)));
Run;

%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Perm\API_Config.csv);


*=====================================================================================================================================================
--- MAIN MACRO START ---
======================================================================================================================================================;
%Macro Main(GitHub_Path,Github_API,API_Path,Main_API,API_SCH,Version,Bank_Name);
*=====================================================================================================================================================
--- Assign Global Macro variable to use in all Macros in the various code sections ---
======================================================================================================================================================;
%Global H_Num;
%Global No_Obs;
%Global API;
%Global ErrorCode;
%Global ErrorDesc;

	%Let BankName_C = &BankName_C;
	%Let API_Link = &API_Link;
	%Let API_Name = &API_Name;
	%Let SCH_Link = &SCH_Link;
	%Let SCH_Name = &SCH_Name;
	%Let Perm_Sch_Table = &Perm_Sch_Table;
	%Let Version_C = &Version_C;
	%Let Sch_Version = &Sch_Version;

	%Let ErrorCode = 0;
	%Let ErrorDesc=;


	%Put Bank_Name = "&BankName_C";
	%Put API_Link = "&API_Link";
	%Put API_Name = "&API_Name";
	%Put SCH_Link = "&SCH_Link";
	%Put SCH_Name = "&SCH_Name";
	%Put Perm_Sch_Table = "&Perm_Sch_Table";
	%Put Version = "&Version_C";
	%Put Sch_Version = "Sch_Version";
*=====================================================================================================================================================
--- Set the ERROR Code macro variables ---
======================================================================================================================================================;
%Macro ErrorCheck();
;Run;Quit;
%If &SysErr > 0 %Then
%Do;
	%Let ErrorCode = &SysErr;
	%Let ErrorDesc = &SysErrorText;
%End;
%Mend ErrorCheck;
%ErrorCheck;
*=====================================================================================================================================================
--- Set Title Date in Proc Print ---
======================================================================================================================================================;
%Macro Fdate(Fmt,Fmt2);
   %Global Fdate FdateTime;
   Data _Null_;
      Call Symput("Fdate",Left(Put("&Sysdate"d,&Fmt)));
      Call Symput("FdateTime",Left(Put("&Sysdate"d,&Fmt2)));
  Run;
%Mend Fdate;


*--- Run Header code to include OPEN BANKING Image at the top of the Report ---;
%Macro Sys_Errors(Bank, API);
%Header();
*--- Set Output Delivery Parameters  ---;
		ODS _All_ Close;
  		ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;

	Data Work.System_Error;
		Length ERROR_DESC $ 100;

					ERROR_DESC = '';
					Output;
					ERROR_DESC = "     There are crytical system Errors in the execution of the program    ";
					Output;
					ERROR_DESC = '';
					Output;
					ERROR_DESC = '   Validate that the correct Version no was selected in the previous screen   ';
					Output;
					ERROR_DESC = '';
					Output;
					ERROR_DESC = "   *** Error Code: &ErrorCode - Error Description: &ErrorDesc ***   ";
					Output;
					ERROR_DESC = '';
					Output;
					ERROR_DESC = '   Contact the OBIE System Administrator - Email: steffan.vanmolendorff@openbanking.org.uk - Mobile: +44 749 7002 765   ';
					Output;
					ERROR_DESC = '';
					Output;
				Run;


				Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";

				Proc Report Data =  OBData.System_Error nowd
					style(report)=[rules=all cellspacing=0 bordercolor=gray] 
					style(header)=[background=lightskyblue foreground=black] 
					style(column)=[background=lightcyan foreground=black];

					Columns ERROR_DESC;

					Define ERROR_DESC / display 'System Execution Error' left;

					Compute ERROR_DESC;
					If ERROR_DESC NE '' then 
						Do;
							call define(_col_,'style',"style=[foreground=Red background=pink font_weight=bold]");
						End;
					Endcomp;

				Run;
*=====================================================================================================================================================
--- Add bottom of report Menu ReturnButton code here ---
======================================================================================================================================================;
		%ReturnButton();

	ODS Listing;

%Mend Sys_Errors;
/*	%Sys_Errors(&_BankName, &_APIName);*/
*=====================================================================================================================================================
--- Macro code for the Resubmit-Return button at the bottom of the reports ---
======================================================================================================================================================;
%Macro ReturnButton();
Data _Null_;
		File _Webout;

		Put '<HTML>';
		Put '<HEAD>';
		Put '<html xmlns="http://www.w3.org/1999/xhtml">';
		Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
		Put '<meta http-equiv="X-UA-Compatible" content="IE=10"/>';
		Put '<title>OB TESTING</title>';

		Put '<meta charset="utf-8" />';
		Put '<title>Open Data Test Harness</title>';
		Put '<meta name="description" content="">';
		Put '<meta name="author" content="">';

		Put '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />'; 

		Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
		Put '<title>LRM</title>';

		Put '<script type="text/javascript" src="'"&_Path/js/jquery.js"'">';
		Put '</script>';

		Put '<link rel="stylesheet" type="text/css" href="'"&_Path/css/style.css"'">';

		Put '</HEAD>';
		Put '<BODY>';

		Put '<p></p>';
		Put '<HR>';
		Put '<p></p>';

		Put '<Table align="center" style="width: 100%; height: 15%" border="0">';
		Put '<td valign="center" align="center" style="background-color: #D4E6F1; color: White">';
		Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit VALUE="Return" align="center">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.Validate_Login.sas">';
		Put '<INPUT TYPE=hidden NAME=_service VALUE=' /
			"&_service"
			'>';
	    Put '<INPUT TYPE=hidden NAME=_debug VALUE=' /
			"&_debug"
			'>';
		Put '<INPUT TYPE=hidden NAME=_WebUser VALUE=' /
			"&_WebUser"
			'>';
		Put '<INPUT TYPE=hidden NAME=_WebPass VALUE=' /
			"&_WebPass"
			'>';
		Put '</Form>';
		Put '</td>';
		Put '</tr>';
		Put '</Table>';

		Put '<Table align="center" style="width: 100%; height: 15%" border="0">';
		Put '<td valign="top" style="background-color: White; color: black">';
		Put '<H3>All Rights Reserved</H3>';
		Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
		Put '</td>';
		Put '</Table>';

		Put '</BODY>';
		Put '<HTML>';
		
Run;
%Mend ReturnButton;



*--- API EXTRACT - The Main macro will execute the code to extract data from the API end points ---;
%Macro API(Url,Bank,API);

Filename API Temp;
*======================================================================================
--- Proc HTTP assigns the GET method in the URL to access the data ---
=======================================================================================;
Proc HTTP
	Url = "&Url."
 	Method = "GET"
 	Out = API;
Run;
%ErrorCheck;
*======================================================================================
--- The JSON engine will extract the data from the JSON script ---
=======================================================================================;
Libname LibAPIs JSON Fileref=API;
%ErrorCheck;
*======================================================================================
--- Proc datasets will create the datasets to examine resulting tables and structures ---
=======================================================================================;
Proc Datasets Lib = LibAPIs; 
Run;
%ErrorCheck;

Data Work.&Bank._API;
	Set LibAPIs.Alldata;
Run;
%ErrorCheck;

*=====================================================================================================================================================
--- Sort the Bank Schema file ---
======================================================================================================================================================;
Proc Sort Data = Work.&Bank._API
	Out = Work.H_Num;
	By Descending P;
Run;

Data Work._Null_;
*=====================================================================================================================================================
--- The variable V contains the first level of the Hierarchy which has no Bank information ---
--- Keep only the highest value of P which will be used in the macro variable H_Num ---
======================================================================================================================================================;
	Set Work.H_Num(Obs=1 Keep = P);
*=====================================================================================================================================================
--- Create a macro variable H_Num to store the hiighest number of Hierarchical levels which will be used in code iterations ---
======================================================================================================================================================;
	Call Symput('H_Num', Compress(Put(P,3.)));
Run;

Data Work.&Bank._API;

	Length Bank_API $ 32 Var2 Value1 Value2 $ 500 Var3 $ 500 P1 - P&H_Num $ 500 Value $ 700;

	RowCnt = _N_;

*=====================================================================================================================================================
--- The variable V contains the first level of the Hierarchy which has no Bank information ---
======================================================================================================================================================;
	Set LibAPIs.Alldata(Where=(V NE 0));
*=====================================================================================================================================================
--- Create Array concatenate variables P1 to P7 which will create the Hierarchy ---
======================================================================================================================================================;
	Array Cat{&H_Num} P1 - P&H_Num;
*=====================================================================================================================================================
--- The Do-Loop will create the Hierarchy of Level 1 to 7 (P1 - P7) ---
======================================================================================================================================================;
	Do i = 1 to P;
		If i = 1 Then 
		Do;
*=====================================================================================================================================================
--- If it is the first data field then do ---
======================================================================================================================================================;
			Var2 = Trim(Left(Cat{i}));
			Count = i;
		End;
*=====================================================================================================================================================
--- All subsequent data fields are concatenated to form the Hierarchy variable as in the reports ---
======================================================================================================================================================;
		Else Do;
			If Var2 NE '' then
			Do;
				Var2 = Trim(Left(Var2))||'-'||Trim(Left(Cat{i}));
				Count = i;
			End;
		End;
		Retain Var2;
	End;
*=====================================================================================================================================================
--- Create variable to list the API value i.e. ATM or Branches ---
======================================================================================================================================================;
	Bank_API = "&API";
*=====================================================================================================================================================
--- Extract only the last level of the Hierarchy ---
======================================================================================================================================================;
	Var3 = Reverse(Scan(Left(Trim(Reverse(Var2))),1,'-',' '));

	If "&Bank" EQ 'Bank_of_Ireland' and "&API" EQ 'commercial-credit-cards' Then
	Do;
		Value1 = Tranwrd(CompBl(Value),"-"," ");
		Value2 = Tranwrd(Value1,":"," ");
		Value = Value2;
	End;

Run;

Data Work.&Bank._API
	(Keep = RowCnt Count P Bank_API Var2 Var3 P1 - P&H_Num Value
	Rename=(Var3 = Data_Element Var2 = Hierarchy Value = &Bank));

	Set Work.&Bank._API;

Run;
*=====================================================================================================================================================
--- Remove the value data- from the Hierarchy value ---
======================================================================================================================================================;
Data Work.&Bank._API(Drop = Hierarchy_X Find);
	Set Work.&Bank._API;

*--- Remove the Data- value from Hierarchy as the schema spec does not have the value in Hierarchy ---;
	Hierarchy = Trim(Left(Tranwrd(Hierarchy,'data-','')));

*--- This step is required to remove the values 1,2,3,etc from the Hierarchy field added by the 
	SAS JSON Libname Engine during ETL. This is to ensure that the Hierarchy value matches with the
	Hierarchy value in the JSON specification file ---;
	If Substr(Reverse(Trim(Left(Hierarchy))),1,1) in ('1','2','3','4','5','6','7','8','9','0') Then
	Do;
		Hierarchy_X = Reverse(Trim(Left(Hierarchy)));
		Find = Find(Hierarchy_X,'-');
		Hierarchy = Trim(Left(Reverse(Substr(Hierarchy_X,Find+1))));
	End;
Run;
*=====================================================================================================================================================
--- Sort data by Data_Element ---
======================================================================================================================================================;
Proc Sort Data = Work.&Bank._API(Keep = Hierarchy &Bank RowCnt Rename=(&Bank = &Bank._Value));
 By Hierarchy &Bank._Value;
Run;
*=====================================================================================================================================================
--- Manually change the data (Edit Mode) in OpenData.&Bank._&API._Schema_Fail datasets ---
======================================================================================================================================================;
Data Work.&Bank._API
		Work._API_&Bank._API
		Work._SCH_&Bank._API
		OBDATA._&BANK._API_SCH;

	Length Hierarchy $ 500
	Table $ 32;

	Merge Work.&Bank._API(In=a)
	OBData.Swagger_Payments(In=b);

	By Hierarchy;

	If a and not b Then 
	Do;
		Table = "&Main_API";
		Output Work._API_&Bank._API;
	End;
	If b and not a Then 
	Do;
		Table = 'Schema';
		Output Work._SCH_&Bank._API;
	End;
	If a and b Then 
	Do;
		Table = 'Both'; 
		Output Work.&Bank._API;
		Output OBDATA._&BANK._API_SCH;
	End;
Run;
*=====================================================================================================================================================
--- Sort data by Data_Element ---
======================================================================================================================================================;
Proc Sort Data = Work.&Bank._API;
 By RowCnt;
Run;


*=====================================================================================================================================================
--- Test if the all Enum variable values are unique ---
======================================================================================================================================================;
%Macro Test_Enum(Bank, API);

Proc Contents Data = Work.&Bank._API
    Memtype = DATA 
    Out = Work.Varlist;
run;

Data Work.Varlist(Keep = Name RowCount);
	Length RowCount 8.;
	Set Work.Varlist;
	Where Name contains 'enum';
	RowCount + 1;
Run;

Data _Null_;
	Set Varlist(where=(Name contains ('enum')));
	Call Symput(Compress('Varlist'||'_'||Put(_N_,2.)),Name);
	Call Symput('VarObs',Compress(RowCount));
Run;


%Macro Loop();
	%Do i = 1 %To &VarObs;

		%Put Varlist_&i = "&&Varlist_&i";

	%End;
%Mend Loop;
%Loop;


Data Work.&Bank._API(Drop = i j FailCnt Title Type additionalProperties Description Table);
	Set Work.&Bank._API;
	
	   	Array TestEnum{&VarObs} $250 enum1 - enum&VarObs;
		Array Against{&VarObs} $250 enum1 - enum&VarObs;
		Do i = 1 to &VarObs;
		If TestEnum{i} Not = '' then
			Do;
			FailCnt = 0;
				Do j = 1 to &VarObs;
					If TestEnum{i} = Against{j} then 
					Do;
						FailCnt+1;
						If FailCnt > 1 then 
						Do;
							Length Test_Enum_Desc $ 100
							Test_Enum $ 6;
							Test_Enum = 'Failed';
							Test_Enum_Value = Against{j};
							Test_Enum_Desc = 'Repetitive Enum values are present in the data';
						End;
					End;
				End;
			End;				
		End;
Run;

%Mend Test_Enum;
*%Test_Enum(&Bank, &API);


*=====================================================================================================================================================
--- Test if the Fail dataset contains any observations to select the correct report to print ---
======================================================================================================================================================;
%Let dsid = %sysfunc(open(Work.Fail)); 
%Let NOBS = %sysfunc(attrn(&dsid,nobs)); 
%Let rc = %sysfunc(close(&dsid)); 
%Put NOBS = &NOBS;
*=====================================================================================================================================================
--- Test if the Bank_API_SCH dataset contains any observations to select the correct report to print ---
======================================================================================================================================================;
%Let dsid = %sysfunc(open(OBDATA._&BANK._API_SCH)); 
%Let MATCHOBS = %sysfunc(attrn(&dsid,nobs)); 
%Let rc = %sysfunc(close(&dsid)); 
%Put MATCHOBS = &MATCHOBS;
*=====================================================================================================================================================
--- Test if the _API_BANK_API dataset contains any observations which did not match with the Schema values ---
======================================================================================================================================================;
%Let dsid = %sysfunc(open(Work._API_&Bank._API)); 
%Let NOBS_API = %sysfunc(attrn(&dsid,nobs)); 
%Let rc = %sysfunc(close(&dsid)); 
%Put NOBS_API = &NOBS_API;
*=====================================================================================================================================================
--- Test if the _SCH_BANK_API dataset contains any observations which did not match with the API values ---
======================================================================================================================================================;
%Let dsid = %sysfunc(open(Work._SCH_&Bank._API)); 
%Let NOBS_SCH = %sysfunc(attrn(&dsid,nobs)); 
%Let rc = %sysfunc(close(&dsid)); 
%Put NOBS_SCH = &NOBS_SCH;
*=====================================================================================================================================================
--- Create a temporary dataset to store the details of the current request being executed ---
======================================================================================================================================================;
Data Work.Stats;
	Length Date_Time 8.
	User_Name $ 50
	Bank_Name $ 30
	API_Name $ 30
	Version_No $ 12
	Fail_Obs $ 10
	NOBS_API $ 10
	MATCHOBS_API $ 10
	NOBS_SCH $ 10
	API_Link $ 250
	SCH_Link $ 250;

*--- Save the macro variable values in dataset variables and append to existing Stats table ---;
	User_Name = "&_WebUser";
	Date_Time = DateTime();
	Bank_Name = "&_BankName";
	API_Name = "&_APINAME";
	VERSION_No = "&_VersionNo";
	FAIL_OBS = "&NOBS";
	NOBS_API = "&NOBS_API";
	MATCHOBS = "&MATCHOBS";
	NOBS_SCH = "&NOBS_SCH";
	API_Link = "&API_Link./&Main_API";
	SCH_Link = "&SCH_Link";
	Format Date_Time datetime.;
Run;
*=====================================================================================================================================================
--- Append current request values to historic Stats table ---
======================================================================================================================================================;
Data OBData.Stats;
	Set OBData.Stats
	Work.Stats;
Run;

*--- Sort Stats history by Date Time to show the latest executed process results on the 1st line of the report ---;
Proc Sort Data = OBData.Stats_RW;
	By Descending Date_Time;
Run;

%Fdate(worddate12., datetime.);
*=====================================================================================================================================================
--- The Header Macro inserts the OB Test Application Banner on top of the web reports ---
======================================================================================================================================================;
%Macro Header();

Data _Null_;
		File _Webout;

Put '<HTML>';
Put '<HEAD>';
Put '<TITLE>OB TESTING</TITLE>';
Put '</HEAD>';

Put '<BODY>';

Put '<table style="width: 100%; height: 5%" border="0">';
   Put '<tr>';
      Put '<td valign="top" style="background-color: #D4E6F1; color: orange">';
	Put '<img src="'"&_Path/images/london.jpg"'" alt="Cant find image" style="width:100%;height:8%px;">';
      Put '</td>';
   Put '</tr>';
Put '</table>';
Put '</BODY>';

		Put '<p><br></p>';

		Put '<div id="container"></div>';

Put '</HTML>';

Run;
%Mend Header;
*=====================================================================================================================================================
--- Proc Template creates the style SASWeb and the macro is called by Proc Report ---
======================================================================================================================================================;
%Macro Template;
Proc Template;
 	Define style Style.Sasweb;
	End;
Run; 
%Mend Template;
%Template;
*=====================================================================================================================================================
--- Run Macro to Print the CMA9 Reports for ATMS, BRANCHES, PCA, etc ---
======================================================================================================================================================;
%Macro Print_Results(Bank, API);

%If &ErrorCode > 0 %Then 
%Do;
	%Sys_Errors(&_BankName, &_APIName);
%End;


*=====================================================================================================================================================
						DEFAULT REPORT IF NO MISMATCHES HAVE BEEN IDENTIFIED
=====================================================================================================================================================;
%If &ErrorCode = 0 and &NOBS_API = 0 %Then 
%Do;
%Macro API_NO_ERRORS(Bank, API);

*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
=====================================================================================================================================================;
%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
=====================================================================================================================================================;
ODS _All_ Close;
ods listing close; 


ods tagsets.tableeditor file=_Webout
    style=styles.SASWeb 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

		Data Work.No_Mismatches;
			Bank = "&Bank";
			API = "&API";
			Description = "There were no Mismatches reported in the &API JSON File";
		Run;

		Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
		Title2 "NO MISMATCES FOUND IN THE %Sysfunc(UPCASE(&Bank)) - %Sysfunc(UPCASE(&API)) REPORT - %Sysfunc(UPCASE(&Fdate))";
		Footnote1 "API LOCATION: &API_Link";
		Footnote2 "SCHEMA LOCATION: &SCH_Link";

		Proc Print Data = Work.No_Mismatches;
		Run;
*=====================================================================================================================================================
--- Add bottom of report Menu ReturnButton code here ---
======================================================================================================================================================;
	%ReturnButton();
*=====================================================================================================================================================
--- Open Output Delivery Parameters  ---
======================================================================================================================================================;
		ODS HTML Close;	
		ODS Listing;	

	%Mend API_NO_ERRORS;
	%API_NO_ERRORS(&Bank, &API);

ods tagsets.tableeditor close; 
ods listing; 

*=====================================================================================================================================================
						EXPORT REPORT NO-ERROR REPORT RESULTS TO RESULTS FOLDER
=====================================================================================================================================================;
%Macro ExportXL(Path);
Proc Export Data = Work.No_Mismatches
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
%Mend ExportXL;
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._NO_MISMATCHES.csv);

%Macro SendMail();
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._NO_MISMATCHES.csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._Matches.csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_SCH_&Bank._&_APIName..csv";
%Mend;

%End;
*=====================================================================================================================================================
						LIST OF MATCHED RECORDS REPORT
=====================================================================================================================================================;
%If &ErrorCode = 0 and &MATCHOBS > 0 %Then 
%Do;
%Macro API_Matches(Bank, API);

*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
=====================================================================================================================================================;
%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
=====================================================================================================================================================;
ODS _All_ Close;
ods listing close; 


ods tagsets.tableeditor file=_Webout
    style=styles.SASWeb 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

		Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
		Title2 "%Sysfunc(UPCASE(&Bank)) - %Sysfunc(UPCASE(&API))";
		Title3 "RECORDS IN BOTH %Sysfunc(UPCASE(&API)) AND SCHEMA FILES - %Sysfunc(UPCASE(&Fdate))";
		Footnote1 "API LOCATION: &API_Link";
		Footnote2 "SCHEMA LOCATION: &SCH_Link";

		Proc Summary Data = OBDATA._&BANK._API_SCH NWAY Missing;
			Class Hierarchy Flag;
			Var RowCnt;
			Output Out = Work.Matches(Drop=_Type_ _Freq_ RowCnt) Sum=;
		Run;

		Proc Report Data = Work.Matches nowd;

		Columns Hierarchy
		Flag;

		Define Hierarchy / display 'Data Hierarchy' left;
		Define Flag / display "Mandatory/Optional" left;

		Compute Hierarchy;

		If Hierarchy NE '' then 
			Do;
				call define(_col_,'style',"style=[foreground=blue background=#D4E6F1 font_weight=bold]");
			End;
		Endcomp;

		Run;
*=====================================================================================================================================================
--- Add bottom of report Menu ReturnButton code here ---
======================================================================================================================================================;
	%ReturnButton();
*=====================================================================================================================================================
--- Open Output Delivery Parameters  ---
======================================================================================================================================================;
		ODS HTML Close;	
		ODS Listing;	

	%Mend API_Matches;
	%API_Matches(&Bank, &API);

ods tagsets.tableeditor close; 
ods listing; 

*=====================================================================================================================================================
						EXPORT REPORT RESULTS TO RESULTS FOLDER
=====================================================================================================================================================;
%Macro ExportXL(Path);
Proc Export Data = Work.Matches
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
%Mend ExportXL;
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._Matches.csv);

%End;

%If &ErrorCode = 0 and &NOBS > 0 %Then 
%Do;
*=====================================================================================================================================================
						LIST OF ERRORS REPORT
=====================================================================================================================================================;
%Macro API_Errors(Bank, API);

*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
=====================================================================================================================================================;
	ODS _All_ Close;

	%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
=====================================================================================================================================================;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.SASWeb
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

		Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
		Title2 "%Sysfunc(UPCASE(&Bank)) - %Sysfunc(UPCASE(&API))";
		Title3 "FAILED VALIDATION REPORT - %Sysfunc(UPCASE(&Fdate))";
		Footnote1 "API LOCATION: &API_Link";
		Footnote2 "SCHEMA LOCATION: &SCH_Link";

		Proc Report Data =  Work.Fail nowd;

		Columns Hierarchy 
		&Bank._Value
		Test_Var_Length_Desc
		Test_Format_Value_Desc
		Test_Mandatory_Flag_Desc
		Test_Enum_Desc
		Pattern_Result_1_Desc
		Pattern_Result_2_Desc
		Pattern_Result_3_Desc
		Pattern_Result_4_Desc
		Pattern_Result_5_Desc
		Pattern_Result_6_Desc;
*=====================================================================================================================================================
--- Define columns in the report output ---
=====================================================================================================================================================;
		Define Hierarchy / display 'Hierarchy' left;
		Define &Bank._Value  / display "&Bank Value" left;

		Define Test_Var_Length_Desc / display 'Field Length Failed Reason' left;
		define Test_Format_Value_Desc / display 'URI Failed Reason' left;

		Define Test_Mandatory_Flag_Desc / display 'Mandatory Failed Reason' left;

		Define Test_Enum_Desc / display 'Duplicate Value Failed Reason' left;

		Define Pattern_Result_1_Desc / display 'Pattern: Failed Reason 1' left;
		Define Pattern_Result_2_Desc / display 'Pattern: Failed Reason 2' left;
		Define Pattern_Result_3_Desc / display 'Pattern: Failed Reason 3' left;
		Define Pattern_Result_4_Desc / display 'Pattern: Failed Reason 4' left;
		Define Pattern_Result_5_Desc / display 'Pattern: Failed Reason 5' left;
		Define Pattern_Result_6_Desc / display 'Pattern: Failed Reason 6' left;


		Compute Test_Var_Length_Desc;

		If Scan(Test_Var_Length_Desc,1,': ') = 'Failed' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;

		Compute Test_Format_Value_Desc;
			If Scan(Test_Format_Value_Desc,1,': ') = 'Failed' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;

		Compute Test_Mandatory_Flag_Desc;
			If Scan(Test_Mandatory_Flag_Desc,1,':') EQ 'Failed' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;

		Compute Test_Enum_Desc;
			If Scan(Test_Enum_Desc,1,':') EQ 'Failed' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;

		Compute Pattern_Result_1_Desc;
			If Scan(Pattern_Result_1_Desc,1,':') EQ 'Failed' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;

		Compute Pattern_Result_2_Desc;
			If Scan(Pattern_Result_2_Desc,1,':') EQ 'Failed' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;

		Compute Pattern_Result_3_Desc;
			If Scan(Pattern_Result_3_Desc,1,':') EQ 'Failed' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;

		Compute Pattern_Result_4_Desc;
			If Scan(Pattern_Result_4_Desc,1,':') EQ 'Failed' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;

		Compute Pattern_Result_5_Desc;
			If Scan(Pattern_Result_5_Desc,1,':') EQ 'Failed' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;

		Compute Pattern_Result_6_Desc;
			If Scan(Pattern_Result_6_Desc,1,':') EQ 'Failed' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;

Run;
*=====================================================================================================================================================
--- Add bottom of report Menu ReturnButton code here ---
======================================================================================================================================================;
	%ReturnButton();

%Mend API_Errors;
%API_Errors(&Bank, &API);

ods tagsets.tableeditor close; 
ods listing; 

*=====================================================================================================================================================
						EXPORT REPORT RESULTS TO RESULTS FOLDER
=====================================================================================================================================================;
%Macro ExportXL(Path);
Proc Export Data = Work.Fail
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
%Mend ExportXL;
*%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\&Bank._&_APIName._Fail.csv);

%End;

%If &ErrorCode = 0 and &NOBS_API > 0 %Then 
%Do;
*=====================================================================================================================================================
						LIST OF DATA RECORDS ONLY IN BANK API TABLE REPORT
======================================================================================================================================================;
%Macro API_MisMatch(Bank, API);

*=====================================================================================================================================================
--- Print Report with reocrds only in the Bank API dataset ---
=====================================================================================================================================================;

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.SASWeb 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

		Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
		Title2 "%Sysfunc(UPCASE(&Bank)) - %Sysfunc(UPCASE(&API))";
		Title3 color=red "RECORDS ONLY IN %Sysfunc(UPCASE(&API)) API OUTPUT FILE - %Sysfunc(UPCASE(&Fdate))";
		Footnote1 "API LOCATION: &API_Link";
		Footnote2 "SCHEMA LOCATION: &SCH_Link";

		Proc Summary Data = Work._API_&Bank._API Nway Missing;
			Class Hierarchy &Bank._Value;
			Var RowCnt;
			Output Out = Work._API_&Bank._API_Sum(Drop = _Freq_ _Type_)Sum=;
		Run;

		Proc Report Data =  Work._API_&Bank._API_Sum nowd;

		Columns Hierarchy
		&Bank._Value;

		Define Hierarchy / display 'Data Hierarchy' left;
		Define &Bank._Value / display "&Bank. Value" left;

		Compute Hierarchy;

		If Hierarchy NE '' then 
			Do;
				call define(_col_,'style',"style=[foreground=blue background=#D4E6F1 font_weight=bold]");
			End;
		Endcomp;

		Run;
*=====================================================================================================================================================
--- Add bottom of report Menu ReturnButton code here ---
======================================================================================================================================================;
%ReturnButton();
*=====================================================================================================================================================
--- Open Output Delivery Parameters  ---
======================================================================================================================================================;
		ODS HTML Close;	
		ODS Listing;	

	%Mend API_Mismatch;
	%API_Mismatch(&Bank, &API);

ods tagsets.tableeditor close; 
ods listing; 


*=====================================================================================================================================================
						EXPORT REPORT RESULTS TO RESULTS FOLDER
=====================================================================================================================================================;
%Macro ExportXL(Path);
Proc Export Data = Work._API_&Bank._API(Keep = Hierarchy &Bank._Value Table)
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
%Mend ExportXL;
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName..csv);


%Macro SendMail();
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._Matches.csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName..csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_SCH_&Bank._&_APIName..csv";
%Mend;


%End;

%If &ErrorCode = 0 and &NOBS_SCH > 0 %Then 
%Do;
*=====================================================================================================================================================
						LIST OF DATA RECORDS ONLY IN BANK API TABLE REPORT
======================================================================================================================================================;
%Macro API_MisMatch(Bank, API);

*=====================================================================================================================================================
--- Print Report with reocrds only in the Bank API dataset ---
======================================================================================================================================================;

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";

*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.SASWeb 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

		Proc Format;
			Value $NoValue ' ' = "&Bank Value not provided";
		Run;

		Data Work._SCH_&Bank._API;
			Set Work._SCH_&Bank._API;

			If &Bank._Value EQ '' and Flag EQ 'Mandatory' then 
			Do;
				OB_Comment = 'Note: Review conditional lower level Optional/Mandatory values';
			End;
		Run;

		Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
		Title2 "%Sysfunc(UPCASE(&Bank)) - %Sysfunc(UPCASE(&API))";
		Title3 color=red "RECORDS ONLY IN %Sysfunc(UPCASE(&API)) OB SCHEMA OUTPUT FILE - %Sysfunc(UPCASE(&Fdate))";
		Footnote1 "API LOCATION: &API_Link";
		Footnote2 "SCHEMA LOCATION: &SCH_Link";

		Proc Report Data = Work._SCH_&Bank._API nowd;

		Columns Hierarchy
		Flag
		&Bank._Value
		OB_Comment;

		Define Hierarchy / display 'Data Hierarchy' style(column)=[width=65%] left;
		Define Flag / display 'Mandatory Flag' style(column)=[width=5%] left;
		Define &Bank._Value / display "&Bank. Value" style(column)=[width=10%] left format = $NoValue.;
		Define OB_Comment / display 'OB Comment' style(column)=[width=20%] left;

		Compute Hierarchy;
		If Hierarchy NE '' then 
			Do;
				call define(_col_,'style',"style=[foreground=blue background=#D4E6F1 font_weight=bold]");
			End;
		Endcomp;

		Compute Flag;
		If Flag EQ 'Mandatory' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=#D4E6F1 font_weight=bold]");
			End;
		Endcomp;

		Compute &Bank._Value;
		If &Bank._Value EQ '' and Flag EQ 'Mandatory' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=#D4E6F1 font_weight=bold]");
			End;
		Endcomp;

		Compute OB_Comment;
		If OB_Comment NE '' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=#D4E6F1 font_weight=bold]");
			End;
		Endcomp;

		Run;
*=====================================================================================================================================================
--- Add bottom of report Menu ReturnButton code here ---
======================================================================================================================================================;
	%ReturnButton();
*=====================================================================================================================================================
--- Open Output Delivery Parameters  ---
======================================================================================================================================================;
		ODS HTML Close;	
		ODS Listing;	

	%Mend API_Mismatch;
	%API_Mismatch(&Bank, &API);

ods tagsets.tableeditor close; 
ods listing; 

*=====================================================================================================================================================
						EXPORT REPORT RESULTS TO RESULTS FOLDER
=====================================================================================================================================================;
%Macro ExportXL(Path);
Proc Export Data = Work._SCH_&Bank._API(Keep = Hierarchy Table Flag &Bank._Value OB_Comment Description)
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
%Mend ExportXL;
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_SCH_&Bank._&_APIName..csv);

%End;

%Else %If &ErrorCode = 0 and &NOBS = 0 %Then 
%Do;
*=====================================================================================================================================================
						NO ERROR REPORT
======================================================================================================================================================;
%Macro No_Errors(Bank, API);

*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
	ODS _All_ Close;
	%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style= styles.SASWeb
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

		Data Work.No_Obs;

		Length ERROR_DESC $ 100;

			ERROR_DESC = '';
			Output;
			ERROR_DESC = "There are NO DATA VALIDATION ERRORS recorded in the &Bank API Data";
			Output;
			ERROR_DESC = '';
			Output;
			ERROR_DESC = " *** All Data Validation Test Cases Passed Successfuly *** ";
			Output;
			ERROR_DESC = '';
			Output;
		Run;

		Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
		Title2 "%Sysfunc(UPCASE(&Bank)) %Sysfunc(UPCASE(&API)) SCHEMA vs. API VALIDATION REPORT - %Sysfunc(UPCASE(&Fdate))";
		Footnote1 "API LOCATION: &API_Link";
		Footnote2 "SCHEMA LOCATION: &SCH_Link";

		Proc Report Data =  Work.No_Obs nowd;

		Columns ERROR_DESC ;

		Define ERROR_DESC / display 'CLEAN SCHEMA vs. API VALIDATION REPORT' left;

		Compute ERROR_DESC;

		If ERROR_DESC NE '' then 
			Do;
				call define(_col_,'style',"style=[foreground=blue background=#D4E6F1 font_weight=bold]");
			End;
		Endcomp;

		Run;
*=====================================================================================================================================================
--- Add bottom of report Menu ReturnButton code here ---
======================================================================================================================================================;
	%ReturnButton();
*=====================================================================================================================================================
--- Open Output Delivery Parameters  ---
======================================================================================================================================================;

	%Mend No_Errors;
	%No_Errors(&Bank, &API);

ods tagsets.tableeditor close; 
ods listing; 

*=====================================================================================================================================================
						EXPORT REPORT RESULTS TO RESULTS FOLDER
=====================================================================================================================================================;
%Macro ExportXL(Path);
Proc Export Data = Work.No_Obs
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
%Mend ExportXL;
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\&Bank._&APIName._No_Obs.csv);


%End;


*================================================================================
					EMAIL REPORTS TO WEBUSER
=================================================================================;
options emailhost=
 (
   "smtp.office365.com" 
   /* alternate: port=487 SSL */
   port=587 STARTTLS 
   auth=login
   /* your Gmail address */
   id="steffan.vanmolendorff@qlick2.com"
   /* optional: encode PW with PROC PWENCODE */
   pw="@FDi2014" 
 )
;

Filename myemail EMAIL
  To=("steffan.vanmolendorff@openbanking.org.uk" "&_WebUser") 
  Subject="JSON VALIDATION - &_BankName &_APIName &_VersionNo"
		%SendMail;

Data _Null_;
  File Myemail;
  Put "Dear &_WebUser,";
  Put " ";
  Put "This email contains the results of the &_BankName &_APIName &_VersionNo API validation test.";
  Put " ";
  Put "Regards";
  Put " ";
  Put "Open Banking - Test Team";
Run;
 
Filename Myemail Clear;



%Mend Print_Results;
%Print_Results(&Bank, &API);
*=====================================================================================================================================================
--- The values are passed from the Main macro to resolve in the macro below which allows execution of the API data extract ---
======================================================================================================================================================;
%Mend API;

%Put _VersionNo = &_VersionNo;
%Put BankName_C = &BankName_C;
/*
*--- HSBC - For json files end point - remove *.json* in %API(&API_Path/&Main_API) ---;
%If "&_VersionNo" EQ "V1.1" and "&BankName_C" EQ "HSBC" %Then
%Do;
	%API(&API_Link/&API_JSON,&Bank_Name,&Main_API);
%End;
*/
*--- BARCLAYS - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v1.1" and "&BankName_C" EQ "HSBC" %Then
%Do;
	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);
%End;

*=================================================================================================
--- The values are passed from the UI to resolve in the macro below which allows 
	execution of the API data extract ---
===================================================================================================;
%Mend Main;

%Main(&SCH_Link,
&SCH_Name,
&API_Link,
&API_Name,
&Perm_Sch_Table,
&Version_C,
&BankName_C);

