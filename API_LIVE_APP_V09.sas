*=====================================================================================================================================================
--- Set system options to track comments in the log file ---
======================================================================================================================================================;
/*
Options MLOGIC MPRINT SOURCE SOURCE2 SYMBOLGEN SPOOL;
OPTIONS NOSYNTAXCHECK;

Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";
*/
Data Work._Null_;
_BankName = "&_BankName";
_APIName = "&_APIName";
_VersionNo = "&_VersionNo";

Call Symput('_BankName',_BankName);
Call Symput('_APIName',_APIName);
Call Symput('_VersionNo',_VersionNo);
Run;

%Global SCH_Name;
%Global SCH_Link;
%Global API_Link;
%Global API_Name;
%Global Perm_Sch_Table;
%Global BankName_C;
%Global Version_C;
%Global Sch_Version;
%Global FDate;
%Global _WebUser;

%Global _Host;
%Global _Path;

%Let _WebUser = &_WebUser;
%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

/*
%Let _BankName = Barclays;
%Let _APIName = BCA;
%Let _VersionNo = v1.3;
*/
*=====================================================================================================================================================
--- Macro Imports read the API_Config CSV sheet and saves the values in macro variables to use in program below ---
======================================================================================================================================================;
%Macro Import(Filename);
/*
PROC IMPORT DATAFILE="&Filename"
 	OUT=OBData.API_Config
 	DBMS=csv
 	REPLACE;
 	GETNAMES=Yes;
RUN;
*/
 *=====================================================================================================================================================
 **********************************************************************
 *   PRODUCT:   SAS
 *   VERSION:   9.4
 *   CREATOR:   External File Interface
 *   DATE:      04JUL17
 *   DESC:      Generated SAS Datastep Code
 *   TEMPLATE SOURCE:  (None Specified.)
 ***********************************************************************
======================================================================================================================================================;
Data Work.API_CONFIG    ;
    %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile 'C:\inetpub\wwwroot\sasweb\Data\Perm\API_Config.csv' delimiter = ',' MISSOVER
	DSD lrecl=32767 firstobs=2 ;
       informat Bank_Name $20. ;
       informat API_Abb $3. ;
       informat API_Link $60. ;
       informat API_Name $25. ;
       informat SCH_Link $81. ;
       informat SCH_Name $24. ;
       informat Perm_SCH_Table $10. ;
       informat Version $4. ;
       format Bank_Name $20. ;
       format API_Abb $3. ;
       format API_Link $60. ;
       format API_Name $25. ;
       format SCH_Link $81. ;
       format SCH_Name $24. ;
       format Perm_SCH_Table $10. ;
       format Version $4. ;
    input
                Bank_Name $
                API_Abb $
                API_Link $
                API_Name $
                SCH_Link $
                SCH_Name $
                Perm_SCH_Table $
                Version $
    ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
Run;

Data OBData._Null_;
	Set Work.API_Config(Where=(Trim(Left(Bank_Name)) EQ "&_BankName" and Trim(Left(API_Abb)) EQ "&_APIName" and Trim(Left(Version)) EQ "&_VersionNo"));
	Call Symput('BankName_C',Bank_Name);
	Call Symput('API_Link',API_Link);
	Call Symput('API_Name',API_Name);
	Call Symput('SCH_Link',SCH_Link);
	Call Symput('SCH_Name',SCH_Name);
	Call Symput('Perm_Sch_Table',Perm_Sch_Table);
	Call Symput('Version_C',Version);
	Call Symput('Sch_Version',Tranwrd(Version,'.','_'));
Run;

%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Perm\API_Config.csv);


*=====================================================================================================================================================
--- MAIN MACRO START ---
======================================================================================================================================================;
%Macro Main(GitHub_Path,Github_API,API_Path,Main_API,API_SCH,Version,Bank_Name);
*=====================================================================================================================================================
--- Set X path variable to the default directory ---
======================================================================================================================================================;
/*
X "cd H:\StV\Open Banking\SAS\Data\Temp";

%Let Path = C:\inetpub\wwwroot\sasweb\Data;
*=====================================================================================================================================================
--- Change directory to default location on PC to save data extracted from Google API ---
======================================================================================================================================================;
X "CD &Path\Perm";
*=====================================================================================================================================================
--- Set the Library path where the permanent datasets will be saved ---
======================================================================================================================================================;
Libname OBData "&Path\Perm";
*/
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


%Macro Sys_Errors(Bank, API);

*=====================================================================================================================================================
--- Run Header code to include OPEN BANKING Image at the top of the Report ---
======================================================================================================================================================;
%Header();
*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
		ODS _All_ Close;
	/*
				ODS HTML Body="&Bank._&API._Body_%sysfunc(datetime(),B8601DT15.).html" 
					Contents="&Bank._&API._Contents.html" 
					Frame="&Bank._&API._Frame.html" 
					Style=HTMLBlue;
	*/
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
	/*			Title2 "%Sysfunc(UPCASE(&Bank)) %Sysfunc(UPCASE(&API)) API HAS DATA VALIDATION ERRORS - %Sysfunc(UPCASE(&Fdate))";*/

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
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';
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
*=====================================================================================================================================================
--- The Main macro will execute the code to extract data from the API end points ---
======================================================================================================================================================;
%Macro Schema(Url,JSON,API_SCH);
*=====================================================================================================================================================
--- Set a temporary file name to extract the content of the Schema JSON file into ---
======================================================================================================================================================;
Filename API Temp;
/*%Let ErrorCode = %Eval(&SysErr);*/
/*%Let ErrorDesc = &SysErrorText;*/
%ErrorCheck;
*=====================================================================================================================================================
--- Proc HTTP assigns the GET method in the URL to access the data contained within the Schema ---
======================================================================================================================================================;
Proc HTTP
	Url = "&Url."
 	Method = "GET" Verbose
 	Out = API;
Run;
/*%Let ErrorCode = %Eval(&SysErr);*/
/*%Let ErrorDesc = &SysErrorText;*/
%ErrorCheck;
*=====================================================================================================================================================
--- The JSON engine will extract the data from the JSON script ---
======================================================================================================================================================;
Libname LibAPIs JSON Fileref=API;
/*%Let ErrorCode = %Eval(&SysErr);*/
/*%Let ErrorDesc = &SysErrorText;*/
%ErrorCheck;
*=====================================================================================================================================================
--- Proc datasets will create the datasets to examine resulting tables and structures ---
======================================================================================================================================================;
Proc Datasets Lib = LibAPIs; 
Run;
/*%Let ErrorCode = %Eval(&SysErr);*/
/*%Let ErrorDesc = &SysErrorText;*/
%ErrorCheck;
*=====================================================================================================================================================
--- Create the Bank Schema dataset ---
======================================================================================================================================================;
Data Work.&JSON;
	Set LibAPIs.Alldata(Where=(V NE 0));
Run;
/*%Let ErrorCode = %Eval(&SysErr);*/
/*%Let ErrorDesc = &SysErrorText;*/
%ErrorCheck;
*=====================================================================================================================================================
--- Sort the Bank Schema file ---
======================================================================================================================================================;
Proc Sort Data = Work.&JSON
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

Data Work.&JSON
	(Rename=(Var3 = Data_Element Var2 = Hierarchy));

	Length Bank_API $ 8 Var2 $ 250 Var3 $ 250 P1 - P&H_Num $ 250 ;

	RowCnt = _N_;

	Set Work.&JSON;
*=====================================================================================================================================================
--- Create Array concatenate variables P1 to P7 which will create the Hierarchy ---
======================================================================================================================================================;
	Array Cat{&H_Num} P1 - P&H_Num;
*=====================================================================================================================================================
--- The Do-Loop will create the Hierarchy of Level 1 to 7 (P1 - P7) ---
======================================================================================================================================================;
	If P = 1 Then
	Do;
		Do i = 1 to P;
*=====================================================================================================================================================
--- If it is the first data field then do ---
======================================================================================================================================================;
			Var2 = Trim(Left(Cat{i}));
			Count = i;
		End;
	End;

	If P > 1 then
	Do;
		Do i = 1 to P-1;
			If i = 1 Then 
			Do;
*=====================================================================================================================================================
--- If it is the first data field then do ---
======================================================================================================================================================;
				Var2 = Trim(Left(Cat{i}));
				Count = i;
			End;
			Else If i > 1 Then
			Do;
				Var2 = Trim(Left(Var2))||'-'||Trim(Left(Cat{i}));
				Count = i;
			End;
		End;
	End;
*=====================================================================================================================================================
--- Create variable to list the API value i.e. ATM or Branches ---
======================================================================================================================================================;
	Bank_API = "Schema";
*=====================================================================================================================================================
--- Extract only the last level of the Hierarchy ---
======================================================================================================================================================;
	Var3 = Left(Trim(Var2));
Run;

Data Work.&JSON;
	Set Work.&JSON;

	If Reverse(Scan(Reverse(Trim(Left(Data_Element))),1,'-')) = 'required' then Flag = 'Mandatory';
	Else Flag = 'Optional';

	Array Col{&H_Num} P1 - P&H_Num;

	Do i = 1 to P;

		If i = P then
		Do;
			New_Data_Element = Compress(Trim(Left(Data_Element))||'-'||Trim(Left(Col{i})));
			New_Data_Element1 = Trim(Left(Tranwrd(New_Data_Element,'properties-','')));
			New_Data_Element2 = Trim(Left(Tranwrd(New_Data_Element1,'items-','')));
			New_Data_Element = New_Data_Element2;
		End;

	End;

	Data_Element = Compress(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Hierarchy,'data-',''),'properties-',''),'-enum',''),'-items',''),'-required',''),'items-',''));

Run;

Proc Sort Data = Work.&JSON
	Out = Work.&JSON;
	By Hierarchy;
Run;

Data Work.&JSON(Drop=Hierarchy Rename=(Data_Element_1 = Hierarchy));
	Set Work.&JSON;
	By Hierarchy;

	Length Data_Element_1 $ 250;

	If First.Hierarchy then
	Do;
		Count = 1;
		Attribute = Reverse(Scan(Reverse(Hierarchy),1,'-'));

		If Attribute = 'required' then 
		Do;
			Hierarchy_1 = Compress(Tranwrd(Hierarchy,'required',Value));
			Data_Element_1 = Compress(Data_Element||'-'||Value);
		End;
		Else Do;
			Data_Element_1 = Data_Element;
		End;
	End;
	If not First.Hierarchy then
	Do;
		Count + 1;
		Attribute = Reverse(Scan(Reverse(Hierarchy),1,'-'));

		If Attribute = 'required' then 
		Do;
			Hierarchy_1 = Compress(Tranwrd(Hierarchy,'required',Value));
			Data_Element_1 = Compress(Data_Element||'-'||Value);
		End;
		Else Do;
			Data_Element_1 = Data_Element;
		End;
	End;

Run;

Proc Sort Data = Work.&JSON
	Out = Work.&JSON;
	By Hierarchy;
Run;

Data Work.&JSON;
	Set Work.&JSON;

	By Hierarchy;

	Length Columns $ 30;

	If Attribute = 'required' then 
	Do;
		Columns = 'mandatory';
		New_Data_Element = Compress(Hierarchy||'-'||Columns); 
	End;

	If Attribute = 'enum' then 
	Do;
		Columns = Attribute;
	End;

	If Reverse(Scan(Reverse(Trim(Left(New_Data_Element))),1,'-')) in 
		('type','description','minLength','maxLength','format','additionalProperties','title','uniqueItems','pattern','minItems','mandatory',
		'enum1','enum2','enum3','enum4','enum5','enum6','enum7','enum8','enum9','enum10',
		'enum11','enum12','enum13','enum14','enum15','enum16','enum17','enum18','enum19','enum20',
		'enum21','enum22','enum23','enum24','enum25','enum26','enum27','enum28','enum29','enum30',
		'enum31','enum32','enum33','enum34','enum35','enum36','enum37','enum38','enum39','enum40',
		'enum41','enum42','enum43','enum44','enum45','enum46','enum47','enum48','enum49','enum50',
		'enum51','enum52','enum53','enum54','enum55','enum56','enum57','enum58','enum59','enum60',
		'enum61','enum62','enum63','enum64','enum65','enum66','enum67','enum68','enum69','enum70',
		'enum71','enum72','enum73','enum74','enum75','enum76','enum77','enum78','enum79','enum80',
		'enum81','enum82','enum83','enum84','enum85','enum86','enum87','enum88','enum89','enum90',
		'enum91','enum92','enum93','enum94','enum95','enum96','enum97','enum98','enum99','enum100',
		'enum101','enum102','enum103','enum104','enum105','enum106','enum107','enum108','enum109','enum110') then
	Do;
		Columns = Reverse(Scan(Reverse(New_Data_Element),1,'-'));
	End;
*=====================================================================================================================================================
--- Ensure that the Column variable has no blank spaces to avoide errors to avoide macro Variable_Name failure ---
======================================================================================================================================================;
	If Columns = '' then 
	Do;
		Columns = Attribute;
	End;
Run;
*=====================================================================================================================================================
--- Create Enum Counter (EnumCnt)to append to Columns variable values where Columns contain enum ---
======================================================================================================================================================;
Proc Sort Data = Work.&JSON
	Out = Work.&JSON;
	By Hierarchy Attribute;
Run;

Data Work.&JSON;
	Set Work.&JSON;
	By Hierarchy Attribute;

	If Attribute = 'enum' then
	Do;
		EnumCnt + 1;
		Columns = Compress(Attribute||Put(EnumCnt,3.));
	End;
	Else Do;
		EnumCnt = 0;
	End;
Run;

*--- TBC ---;

Data Work.&JSON._1;
	Set Work.&JSON;
	By Hierarchy;

	If First.Hierarchy then 
	Do;
		HierCnt + 1;
		Counter = 1;
	End;
	If not First.Hierarchy then 
	Do;
		Counter + 1;
	End;
	Retain HierCnt;
Run;

Proc Sort Data = Work.&JSON._1
	Out = Work.&JSON._1;
	By HierCnt Counter;
Run;

%Macro VarVal();
*=====================================================================================================================================================
--- TBC ---
======================================================================================================================================================;
Data Work.&JSON._2;
	Set Work.&JSON._1(Where=(Columns NE ''));
	By HierCnt Counter;

		Call Symput(Compress('Variable_Name'||'_'||Put(HierCnt,8.)||'_'||Put(Counter,8.)),Trim(Left(Columns)));
		Call Symput(Compress('Variable_Value'||'_'||Put(HierCnt,8.)||'_'||Put(Counter,8.)),Trim(Left(Value)));

	If Last.HierCnt and Last.Counter then
	Do;
		Call Symput('HierCnt',Trim(Left(Put(HierCnt,6.))));
		Call Symput(Compress('Test'||'_'||Put(HierCnt,8.)),Trim(Left(Put(Counter,8.))));
	End;
Run;

%Put HierCnt = &HierCnt;
%Put ***;
%Put Test_HierCnt = &&Test_&HierCnt;
%Put ***;

%Put _ALL_;

	Data Work.Schema_Columns;
		Length Hierarchy $ 250;
	Run;

%Do i = 1 %To %Eval(&HierCnt);

	%Put i = &i;

	Data Work.Unique_Columns&i;
		Set Work.&JSON._2(Where=(HierCnt = &i));
		By HierCnt Counter;

		If Last.HierCnt and Last.Counter;

			%Do j = 1 %To %Eval(&&Test_&i);
				%Put j = &j;
				Length &&Variable_Name_&i._&j  $ 250;

				%Let Varname = &&Variable_Name_&i._&j.;
				&Varname = "&&Variable_Value_&i._&j.";
			%End;
	Run;

	Data Work.Schema_Columns
		(Keep = Hierarchy 
		Type
		Items
		Description
		minLength
		maxLength
		format
		additionalProperties
		title
		uniqueItems
		pattern
		minItems
		Flag
		enum1 - enum33);
		Set Work.Schema_Columns
			Work.Unique_Columns&i;

			Hierarchy = (Tranwrd(Trim(Left(Hierarchy)),'items-',''));

		If Hierarchy EQ '' then Delete;
	Run;

	Proc Sort Data = Work.Schema_Columns
		Out = OBData.&API_SCH._&Sch_Version;
		By Hierarchy;
	Run;

%End;

%Mend VarVal;
%VarVal();
*====================================================================================================
=								API EXTRACT															=
=====================================================================================================;
*====================================================================================================
--- The Main macro will execute the code to extract data from the API end points ---
=====================================================================================================;
%Macro API(Url,Bank,API);

Filename API Temp;
 
*=====================================================================================================================================================
--- Proc HTTP assigns the GET method in the URL to access the data ---
======================================================================================================================================================;
Proc HTTP
	Url = "&Url."
 	Method = "GET"
 	Out = API;
Run;
/*%Let ErrorCode = %Eval(&SysErr);*/
/*%Let ErrorDesc = &SysErrorText;*/
%ErrorCheck;
*=====================================================================================================================================================
--- The JSON engine will extract the data from the JSON script ---
======================================================================================================================================================;
Libname LibAPIs JSON Fileref=API;
/*%Let ErrorCode = %Eval(&SysErr);*/
/*%Let ErrorDesc = &SysErrorText;*/
%ErrorCheck;
*=====================================================================================================================================================
--- Proc datasets will create the datasets to examine resulting tables and structures ---
======================================================================================================================================================;
Proc Datasets Lib = LibAPIs; 
Run;
/*%Let ErrorCode = %Eval(&SysErr);*/
/*%Let ErrorDesc = &SysErrorText;*/
%ErrorCheck;

Data Work.&Bank._API;
	Set LibAPIs.Alldata;
Run;
/*%Let ErrorCode = %Eval(&SysErr);*/
/*%Let ErrorDesc = &SysErrorText;*/
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

	Length Bank_API $ 32 Var2 Value1 Value2 $ 250 Var3 $ 250 P1 - P&H_Num $ 250 Value $ 619;

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

*=====================================================================================================================================================
--- For ATMS do the following amendments to the Hierarchy values ---
======================================================================================================================================================;
	If Trim(Left(Bank_API)) = 'atms' then
	Do;

		If Trim(Left(Var2)) = 'data-ATMServices-ATMServic' then 
		Do;
			Var2 = 'data-ATMServices';
		End;

		If Trim(Left(Var2)) = 'data-AccessibilityTypes-Accessibi' then 
		Do;
			Var2 = 'data-AccessibilityTypes';
		End;

		If Trim(Left(Var2)) = 'data-Currency-Currency1' then 
		Do;
			Var2 = 'data-Currency';
		End;

		If Trim(Left(Var2)) = 'data-SupportedLanguages-Supported' then 
		Do;
			Var2 = 'data-SupportedLanguages';
		End;
	End;
*=====================================================================================================================================================
--- For BRANCHES do the following amendments to the Hierarchy values ---
======================================================================================================================================================;
	If Trim(Left(Bank_API)) = 'branches' then
	Do;

		If Trim(Left(Var2)) = 'data-BranchFacilitiesName-BranchFacil' then 
		Do;
			Var2 = 'BranchFacilitiesName';
		End;

		If Trim(Left(Var2)) = 'data-BranchMediatedServiceName-BranchMedia' then 
		Do;
			Var2 = 'BranchMediatedServiceName';
		End;

		If Trim(Left(Var2)) = 'data-BranchSelfServeServiceName-BranchSelfS' then 
		Do;
			Var2 = 'BranchSelfServeServiceName';
		End;

		If Trim(Left(Var2)) in ('data-CustomerSegment-CustomerSeg','data-CustomerSegment-Custome') then 
		Do;
			Var2 = 'CustomerSegment';
		End;
	End;
*=====================================================================================================================================================
--- For BUSINESS-CURRENT-ACCOUNTS do the following amendments to the Hierarchy values ---
======================================================================================================================================================;
/*	If Trim(Left(Bank_API)) = 'business-current-accounts' then*/
/*	Do;*/
/*		If Trim(Left(Var2)) in ('data-AccessChannels-Acces','AccessChannels-Acce') then */
/*		Do;*/
/*			Var2 = 'AccessChannels';*/
/*		End;*/
/*		If Trim(Left(Var2)) in ('data-CardType-CardT','CardType-Card') then */
/*		Do;*/
/*			Var2 = 'CardType';*/
/*		End;*/
/*		If Trim(Left(Var2)) in ('data-Currency-Curre','Currency-Curr') then */
/*		Do;*/
/*			Var2 = 'Currency';*/
/*		End;*/
/*		If Trim(Left(Var2)) in ('data-MobileWallet-Mobil','MobileWallet-','MobileWallet-MobileWallet1PayM') then */
/*		Do;*/
/*			Var2 = 'MobileWallet';*/
/*		End;*/
/*		If Trim(Left(Var2)) in ('data-ProductSegment-Produ','ProductSegment-Prod') then */
/*		Do;*/
/*			Var2 = 'ProductSegment';*/
/*		End;*/
/*		If Trim(Left(Var2)) in ('data-ProductURL-Produ','ProductURL-ProductURL1http:/') then */
/*		Do;*/
/*			Var2 = 'ProductURL';*/
/*		End;*/
/*		If Trim(Left(Var2)) in ('data-TsandCs-Tsand','TsandCs-TsandCs1http://www') then */
/*		Do;*/
/*			Var2 = 'TsandCs';*/
/*		End;*/
/*	End;*/

Run;
*=====================================================================================================================================================
--- Remove the value data- from the Hierarchy value ---
======================================================================================================================================================;
Data Work.&Bank._API;
	Set Work.&Bank._API;
	Hierarchy = Trim(Left(Tranwrd(Hierarchy,'data-','')));
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
		Work._A_&Bank._API
		Work._S_&Bank._API   OBData.X;

	Length Hierarchy $ 250
	Table $ 32;

	Merge Work.&Bank._API(In=a)
	OBData.&API_SCH._&Sch_Version(In=b);

	By Hierarchy;

	If a and not b Then 
	Do;
		Table = "&Main_API";
		Output Work._A_&Bank._API;
	End;
	If b and not a Then 
	Do;
		Table = 'Schema';
		Output Work._S_&Bank._API;
	End;
	If a and b then 
	Do;
		Table = 'Both'; 
		Output Work.&Bank._API;
	End;
Run;
*=====================================================================================================================================================
--- Sort data by Data_Element ---
======================================================================================================================================================;
Proc Sort Data = Work.&Bank._API;
 By RowCnt;
Run;
*=====================================================================================================================================================
--- Create Failed Test Dataset for Testing purposes in the output report ---
======================================================================================================================================================;
Data Work.&Bank._API_Failed;
	Set Work.&Bank._API;

	/*
	If Trim(Left(Hierarchy)) = 'BranchName' Then &Bank._Value = 'Barclays BankBarclays BankBarclays BankBarclays BankBarclays';
	If Trim(Left(Hierarchy)) = 'Organisation-Brand-TrademarkIPOCode' Then enum3 = 'EU';
	If Trim(Left(Hierarchy)) = 'BranchType' Then enum2 = 'Mobile';
	If Trim(Left(Hierarchy)) = 'Organisation-Brand-TrademarkID' Then Hierarchy = '';
	If Trim(Left(Hierarchy)) = 'Address-StreetName' Then Hierarchy = '';
	If Trim(Left(Hierarchy)) = 'BranchPhoto' Then &Bank._Value = 'PTTH:\\ZZZ.THIS_IS_WRONG.com';
	If Trim(Left(Hierarchy)) = 'Address-CountrySubDivision' Then &Bank._Value = '';
	If Trim(Left(Hierarchy)) = ('OpeningTimes-ClosingTime') Then &Bank._Value = Trim(Left(Barclays_Value ))||'_ABC';
	If Trim(Left(Hierarchy)) = ('OpeningTimes-OpeningTime') Then &Bank._Value = '';
	If Trim(Left(Pattern)) = ('^-?\d{1,3}\.\d{1,8}$') Then &Bank._Value = Trim(Left(Barclays_Value ))||'_ABC';;
	If Trim(Left(Pattern)) = ('^[+][0-9]{1,3}-[0-9()+-]{1,30}$') Then &Bank._Value = Trim(Left(Barclays_Value ))||'_ABC';;
*	If Trim(Left(Pattern)) = ('[A-Z]{6}[A-Z2-9][A-NP-Z0-9]([A-Z0-9]{3})?') Then Barclays_Value = '1_'||Trim(Left(Barclays_Value ))||'_OABC';;
*	If Trim(Left(Pattern)) = ('[A-Z]{6}[A-Z2-9][A-NP-Z0-9]([A-Z0-9]{3})?') Then Barclays_Value = Trim(Left(Barclays_Value ))||'OABC';
	If Trim(Left(Pattern)) = ('[A-Z]{6}[A-Z2-9][A-NP-Z0-9]([A-Z0-9]{3})?') Then &Bank._Value = Trim(Left(Barclays_Value ))||'_ABC';
*	If Trim(Left(Pattern)) = ('[A-Z]{6}[A-Z2-9][A-NP-Z0-9]([A-Z0-9]{3})?') Then Barclays_Value = '';
*/
Run;
*=====================================================================================================================================================
--- Test the minLength and maxLenght of a data value ---
======================================================================================================================================================;
%Macro Test_VarLength(Bank, API);

Data Work.&Bank._API;
	Set Work.&Bank._API_Failed;
	Length Test_Var_Length_Desc $ 100
	Test_Var_Length $ 6;

	If minLength NE '' Then
	Do;
		Variable_Length = Length(&Bank._Value);
		If Variable_Length >= InPut(minLength,8.) and Variable_Length <= InPut(maxLength,8.) and &Bank._Value NE '' then 
		Do;
			Test_Var_Length = 'Pass';
		End;
		Else Do;
			Test_Var_Length = 'Failed';
			If &Bank._Value NE '' then Test_Var_Length_Desc = "&Bank. Value field Length is out of range";
			If &Bank._Value EQ '' then Test_Var_Length_Desc = "&Bank. Value is missing";
		End;
	End;
Run;

%Mend Test_VarLength;
%Test_VarLength(&Bank, &API);

*=====================================================================================================================================================
--- Test for the URI Format of the Bank URI data value ---
======================================================================================================================================================;
%Macro Test_Format(Bank, API);

Data Work.&Bank._API;
	Set Work.&Bank._API;

	Length Test_Format_Value_Desc $ 100
	Test_Format_Value $ 6;
	
	If Format NE '' Then
	Do;
		Format_Value = Scan(&Bank._Value,1,'//');
		If Format_Value in ('http:','https:') then 
		Do;
			Test_Format_Value = 'Pass';
		End;
		Else If Format_Value EQ '' then
		Do;
			Test_Format_Value = 'Failed';
			Test_Format_Value_Desc = "&Bank Value is blank";
		End;
		Else If Format_Value not in ('http:','https:') and Substr(&Bank._Value,11,1) NE 'T' then
		Do;
			Test_Format_Value = 'Failed';
			Test_Format_Value_Desc = 'Value does not represent a Date-Time value or an uri address - i.e. https://';
		End;

		If Format_Value in ('date-time') and Substr(&Bank._Value,11,1) EQ 'T' then 
		Do;
			Test_Format_Value = 'Pass';
		End;
		If Format_Value in ('date-time') and Substr(&Bank._Value,11,1) NE 'T' then 
		Do;
			Test_Format_Value = 'Failed';
			Test_Format_Value_Desc = "&Bank Value doe not have the correct date-time format";
		End;
		Else If Format_Value in ('date-time') and &Bank._Value EQ '' then
		Do;
			Test_Format_Value = 'Failed';
			Test_Format_Value_Desc = "&Bank Value is blank";
		End;
	End;

Run;

%Mend Test_Format;
%Test_Format(&Bank, &API);


*=====================================================================================================================================================
--- Test if the Mandatory Flag does have a data value ---
======================================================================================================================================================;
%Macro Test_Mandatory(Bank, API);

Data Work.&Bank._API;
	Set Work.&Bank._API;

	Length Test_Mandatory_Flag_Desc $ 100
	Test_Mandatory_Flag $ 6;

	If Flag EQ 'Mandatory' and &Bank._Value NE '' Then
	Do;
			Test_Mandatory_Flag = 'Pass';
	End;
	Else If Flag EQ 'Mandatory' and &Bank._Value EQ '' Then
	Do;
		Test_Mandatory_Flag = 'Failed';
		Test_Mandatory_Flag_Desc = "1. Mandatory &Bank Value is blank";
	End;
Run;

%Mend Test_Mandatory;
%Test_Mandatory(&Bank, &API);

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
	
	   	array TestEnum{&VarObs} $250 enum1 - enum&VarObs;
		array Against{&VarObs} $250 enum1 - enum&VarObs;
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
%Test_Enum(&Bank, &API);


*=====================================================================================================================================================
--- Test if the all PATTERN variable values are unique ---
======================================================================================================================================================;
%Macro Pattern();

Data Work.&Bank._API;
	Set Work.&Bank._API;
	
	Length Pattern_Result_1_Desc 
	Pattern_Result_2_Desc 
	Pattern_Result_3_Desc 
	Pattern_Result_4_Desc
	Pattern_Result_3_Desc 
	Pattern_Result_5_Desc
	Pattern_Result_6_Desc $ 100
	Pattern_Result_1
	Pattern_Result_2
	Pattern_Result_3
	Pattern_Result_4 
	Pattern_Result_5 
	Pattern_Result_6 $ 6;

*=====================================================================================================================================================
*--- Test the 1st of 6 Pattern Values ---
======================================================================================================================================================;
	If Trim(Left(Pattern)) = '[A-Z]{2}' then
	Do;
		Pattern1 = Substr(Scan(Pattern,1,']'),2);
		Pattern2 = InPut(Scan(Scan(Pattern,1,'}'),2,'{'),2.);
/*		Pattern2a = IndexC(UPCASE(&Bank._Value),'0','1','2','3','4','5','6','7','8','9');*/



		If &Bank._Value EQ '' then
		Do;
			Pattern_Result_1 = 'Failed';
			Pattern_Result_1_Desc = "1. &Bank value is missing";
		End;

		Else If NotDigit(&Bank._Value) and Length(&Bank._Value) > Pattern2 then
		Do;
			Pattern_Result_1 = 'Failed';
			Pattern_Result_1_Desc = "2. Length of the &Bank value is too long";
		End;

		Else If IndexC(UPCASE(&Bank._Value),'0','1','2','3','4','5','6','7','8','9') > 0 then
		Do;
			Pattern_Result_1 = 'Failed';
			Pattern_Result_1_Desc = "3. &Bank value contains Numeric values";
		End;
		Else If NotDigit(&Bank._Value) and Length(&Bank._Value) <= Pattern2 then
		Do;
			Pattern_Result_1 = 'Pass';
		End;

	End;


*=====================================================================================================================================================
*--- Test the 1st of 6 Pattern Values ---
======================================================================================================================================================;
	If Trim(Left(Pattern)) = '^(([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9].\d{3})|(^24:00:00\.000)(?:Z|[+-](?:2[0-3]|[01][0-9]):[0-5][0-9])?$' then
	Do;
		Pattern3 = Input(Compress(Tranwrd(Tranwrd(Trim(Left(&Bank._Value)),':',''),'.','')),8.);
		Pattern4 = NotDigit(&Bank._Value);

		If &Bank._Value EQ '' then
		Do;
			Pattern_Result_2 = 'Failed';
			Pattern_Result_2_Desc = "4. &Bank value is missing";
		End;

*=====================================================================================================================================================
--- Pattern3 variable has the : and . translated to missing which creates a number value ---
--- Pattern4 variable identifies the number position of the : and sets a numeric value ---
--- If both Pattern3 and Pattern4 are numbers gt than 0 then there is no character values in the &Bank_Value variable ---
======================================================================================================================================================;
		Else If Pattern3 >= 0 and Pattern4 <= 0 then
		Do;
			Pattern_Result_2 = 'Failed';
			Pattern_Result_2_Desc = "5. &Bank value contains Character values";
		End;
		Else If IndexC(UPCASE(&Bank._Value),'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z') > 0 then
		Do;
			Pattern_Result_2 = 'Failed';
			Pattern_Result_2_Desc = "6. &Bank value contains Character values A - Z";
		End;

		Else If VType(Pattern3) = 'N' and VType(Pattern4) = 'N' Then
		Do;
			Pattern_Result_2 = 'Pass';
		End;

	End;



*=====================================================================================================================================================
--- Test the 3rd of 6 Pattern Values ---
======================================================================================================================================================;
	If Trim(Left(Pattern)) = '^-?\d{1,3}\.\d{1,8}$' then
	Do;
		Pattern5 = Input(Compress(Tranwrd(Trim(Left(&Bank._Value)),'.','')),8.);
		Pattern6 = NotDigit(&Bank._Value);

		If &Bank._Value EQ '' then
		Do;
			Pattern_Result_3 = 'Failed';
			Pattern_Result_3_Desc = "7. &Bank value is missing";
		End;

*=====================================================================================================================================================
--- Pattern5 variable has . translated to missing which creates a number value ---
--- Pattern6 variable identifies the number position of the . and sets a numeric value ---
--- If both Pattern3 and Pattern4 are numbers gt than 0 then there is no character values in the &Bank_Value variable ---
======================================================================================================================================================;
		Else If Pattern5 >= 0 and Pattern6 <= 0 then
		Do;
			Pattern_Result_3 = 'Failed';
			Pattern_Result_3_Desc = "8. &Bank value contains Character values";
		End;
		Else If IndexC(UPCASE(&Bank._Value),'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z') > 0 then
		Do;
			Pattern_Result_3 = 'Failed';
			Pattern_Result_3_Desc = "9. &Bank value contains Character values A - Z";
		End;

		Else If VType(Pattern5) = 'N' and VType(Pattern6) = 'N' Then
		Do;
			Pattern_Result_3 = 'Pass';
		End;

	End;

*=====================================================================================================================================================
--- Test the 4th of 6 Pattern Values ---
======================================================================================================================================================;
	If Trim(Left(Pattern)) = '^[+][0-9]{1,3}-[0-9()+-]{1,30}$' then
	Do;
		Pattern7 = Substr(&Bank._Value,1,1);
		Pattern8 = Substr(&Bank._Value,4,1);
		Pattern9 = Input(Substr(&Bank._Value,2,2),8.);
		Pattern10 = Input(Substr(&Bank._Value,5),8.);

		If &Bank._Value EQ '' then
		Do;
			Pattern_Result_4 = 'Failed';
			Pattern_Result_4_Desc = "10. &Bank value is missing";
		End;

*=====================================================================================================================================================
--- Pattern5 variable has . translated to missing which creates a number value ---
--- Pattern6 variable identifies the number position of the . and sets a numeric value ---
--- If both Pattern3 and Pattern4 are numbers gt than 0 then there is no character values in the &Bank_Value variable ---
======================================================================================================================================================;
		Else If Pattern7 NE '+' and Pattern8 NE '-' then
		Do;
			Pattern_Result_4 = 'Failed';
			Pattern_Result_4_Desc = "11. &Bank value does comply with the number format i.e. the symbols '+' and '-' are missing ";
		End;
		Else If IndexC(UPCASE(&Bank._Value),'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z') > 0 then
		Do;
			Pattern_Result_4 = 'Failed';
			Pattern_Result_4_Desc = "12. &Bank value contains Character values A - Z";
		End;

		Else If VType(Pattern7) = 'C' and VType(Pattern8) = 'C' and VType(Pattern9) = 'N' and VType(Pattern10) = 'N' Then
		Do;
			Pattern_Result_4 = 'Pass';
		End;

	End;


*=====================================================================================================================================================
--- Test the 5th of 6 Pattern Values ---
======================================================================================================================================================;
	If Trim(Left(Pattern)) = '[A-Z]{6}[A-Z2-9][A-NP-Z0-9]([A-Z0-9]{3})?' then
	Do;
		Pattern11 = Substr(&Bank._Value,1,6);
		Pattern12 = Substr(&Bank._Value,7);
		Pattern13 = 'O';
		Pattern14 = IndexC(Pattern12,Pattern13);

		If &Bank._Value EQ '' then
		Do;
			Pattern_Result_5 = 'Failed';
			Pattern_Result_5_Desc = "13. &Bank value is missing";
		End;

*=====================================================================================================================================================
--- Pattern5 variable has . translated to missing which creates a number value ---
--- Pattern6 variable identifies the number position of the . and sets a numeric value ---
--- If both Pattern3 and Pattern4 are numbers gt than 0 then there is no character values in the &Bank_Value variable ---
======================================================================================================================================================;
		Else If IndexC(Pattern11,"0","1","2","3","4","5","6","7","8","9") then
		Do;
			Pattern_Result_5 = 'Failed';
			Pattern_Result_5_Desc = "14. &Bank value contains number in the first 6 digits of the value";
		End;
		Else If IndexC(Pattern12,Pattern13) >0 then
		Do;
			Pattern_Result_5 = 'Failed';
			Pattern_Result_5_Desc = "15. &Bank value contains the illegal characters 'O'";
		End;

		Else If Length(&Bank._Value) > 9 then
		Do;
			Pattern_Result_5 = 'Failed';
			Pattern_Result_5_Desc = "16. &Bank value field length is more than 9 characters";
		End;

		Else If Length(Pattern11) = 6 and VType(Pattern11) = 'C' and Length(Pattern12) <= 3 and VType(Pattern12) = 'N' Then
		Do;
			Pattern_Result_5 = 'Pass';
		End;

	End;


*=====================================================================================================================================================
--- Test the 6th of 6 Pattern Values ---
======================================================================================================================================================;
	If Trim(Left(Pattern)) = '[A-Z]{3}' then
	Do;
		Pattern15 = Substr(Scan(Pattern,1,']'),2);
		Pattern16 = InPut(Scan(Scan(Pattern,1,'}'),2,'{'),3.);
		Pattern17 = Length(Trim(Left(&Bank._Value)));
		Pattern18 = IndexC(Trim(Left(&Bank._Value)),"0","1","2","3","4","5","6","7","8","9");

*		Pattern_Length = Length(&Bank._Value);

		If &Bank._Value EQ '' then
		Do;
			Pattern_Result_6 = 'Failed';
			Pattern_Result_6_Desc = "17. &Bank value is missing";
		End;

		Else If Length(&Bank._Value) > Pattern16 then
		Do;
			Pattern_Result_6 = 'Failed';
			Pattern_Result_6_Desc = "18. Length of the &Bank value is too long";
		End;

		Else If IndexC(Trim(Left(&Bank._Value)),"0","1","2","3","4","5","6","7","8","9") then
		Do;
			Pattern_Result_6 = 'Failed';
			Pattern_Result_6_Desc = "19. &Bank value contains Numeric values";
		End;

		Else If IndexC(Trim(Left(&Bank._Value)),"0","1","2","3","4","5","6","7","8","9") = 0 and Length(Trim(Left(&Bank._Value))) <= Pattern16 then
		Do;
			Pattern_Result_6 = 'Pass';
		End;

	End;

Run;

%Mend Pattern;
%Pattern();


*=====================================================================================================================================================
--- Create test PASS and FAIL datasets based on above test cases ---
======================================================================================================================================================;
Data Work.Pass
	Work.Fail1(Keep = Hierarchy &Bank._Value RowCnt Test_Var_Length_Desc Test_Var_Length)
	Work.Fail2(Keep = Hierarchy &Bank._Value RowCnt Test_Format_Value_Desc Test_Format_Value)
	Work.Fail3(Keep = Hierarchy &Bank._Value RowCnt Test_Mandatory_Flag_Desc Test_Mandatory_Flag)
	Work.Fail4(Keep = Hierarchy &Bank._Value RowCnt Test_Enum_Desc Test_Enum)
	Work.Fail5(Keep = Hierarchy &Bank._Value RowCnt Pattern_Result_1_Desc Pattern_Result_1)
	Work.Fail6(Keep = Hierarchy &Bank._Value RowCnt Pattern_Result_2_Desc Pattern_Result_2)
	Work.Fail7(Keep = Hierarchy &Bank._Value RowCnt Pattern_Result_3_Desc Pattern_Result_3)
	Work.Fail8(Keep = Hierarchy &Bank._Value RowCnt Pattern_Result_4_Desc Pattern_Result_4)
	Work.Fail9(Keep = Hierarchy &Bank._Value RowCnt Pattern_Result_5_Desc Pattern_Result_5)
	Work.Fail10(Keep = Hierarchy &Bank._Value RowCnt Pattern_Result_6_Desc Pattern_Result_6);

	Set Work.&Bank._API;

	Length Test_Var_Length_Desc $ 100 
	Test_Format_Value_Desc $ 100
	Test_Var_Length_Desc $ 100
	Pattern_Result_1_Desc $ 100
	Pattern_Result_2_Desc $ 100
	Pattern_Result_3_Desc $ 100
	Pattern_Result_4_Desc $ 100
	Pattern_Result_5_Desc $ 100
	Pattern_Result_6_Desc $ 100;

*=====================================================================================================================================================
--- Combine test results with test descriptions for each variable value being tested ---
======================================================================================================================================================;
		If Test_Var_Length EQ 'Failed' then
		Do;
			If Test_Var_Length = 'Failed' then
			Do;
				Test_Var_Length_Desc = Trim(Left(Test_Var_Length))||': '||Trim(Left(Test_Var_Length_Desc));
				Output Work.Fail1;
			End;
		End;
		Else If Test_Var_Length = 'Pass' then
		Do;
			Output Work.Pass;
		End;


		If Test_Format_Value EQ 'Failed' then
		Do;
				Test_Format_Value_Desc = Trim(Left(Test_Format_Value))||': '||Trim(Left(Test_Format_Value_Desc));
				Output Work.Fail2;
		End;
		Else If Test_Format_Value = 'Pass' then
		Do;
			Output Work.Pass;
		End;


		If Test_Mandatory_Flag EQ 'Failed' then
		Do;
			Test_Mandatory_Flag_Desc = Trim(Left(Test_Mandatory_Flag))||': '||Trim(Left(Test_Mandatory_Flag_Desc));
			Output Work.Fail3;
		End;
		Else If Test_Mandatory_Flag = 'Pass' then
		Do;
			Output Work.Pass;
		End;

		If Test_Enum EQ 'Failed' then
		Do;
			Test_Enum_Desc = Trim(Left(Test_Enum))||': '||Trim(Left(Test_Enum_Desc));
			Output Work.Fail4;
		End;
		Else If Test_Enum EQ 'Pass' then
		Do;
			Output Work.Pass;
		End;


		If Pattern_Result_1 EQ 'Failed' then
		Do;
			Pattern_Result_1_Desc = Trim(Left(Pattern_Result_1))||': '||Trim(Left(Pattern_Result_1_Desc));
			Output Work.Fail5;
		End;
		Else If Pattern_Result_1 EQ 'Pass' then
		Do;
			Output Work.Pass;
		End;

		If Pattern_Result_2 EQ 'Failed' then
		Do;
			Pattern_Result_2_Desc = Trim(Left(Pattern_Result_2))||': '||Trim(Left(Pattern_Result_2_Desc));
			Output Work.Fail6;
		End;
		Else If Pattern_Result_2 EQ 'Pass' then
		Do;
			Output Work.Pass;
		End;

		If Pattern_Result_3 EQ 'Failed' then
		Do;
			Pattern_Result_3_Desc = Trim(Left(Pattern_Result_3))||': '||Trim(Left(Pattern_Result_3_Desc));
			Output Work.Fail7;
		End;
		Else If Pattern_Result_3 EQ 'Pass' then
		Do;
			Output Work.Pass;
		End;

		If Pattern_Result_4 EQ 'Failed' then
		Do;
			Pattern_Result_4_Desc = Trim(Left(Pattern_Result_4))||': '||Trim(Left(Pattern_Result_4_Desc));
			Output Work.Fail8;
		End;
		Else If Pattern_Result_4 EQ 'Pass' then
		Do;
			Output Work.Pass;
		End;

		If Pattern_Result_5 EQ 'Failed' then
		Do;
			Pattern_Result_5_Desc = Trim(Left(Pattern_Result_5))||': '||Trim(Left(Pattern_Result_5_Desc));
			Output Work.Fail9;
		End;
		Else If Pattern_Result_5 EQ 'Pass' then
		Do;
			Output Work.Pass;
		End;

		If Pattern_Result_6 EQ 'Failed' then
		Do;
			Pattern_Result_6_Desc = Trim(Left(Pattern_Result_6))||': '||Trim(Left(Pattern_Result_6_Desc));
			Output Work.Fail10;
		End;
		Else If Pattern_Result_6 EQ 'Pass' then
		Do;
			Output Work.Pass;
		End;

Run;

*=====================================================================================================================================================
--- Sort FAIL datasets by RowCnt to get the dataset order correct  ---
======================================================================================================================================================;
%Macro Sort(Dsn);

Proc Sort Data = &Dsn;
	By RowCnt;
Run;
%Mend Sort;
%Sort(Work.Fail1);
%Sort(Work.Fail2);
%Sort(Work.Fail3);
%Sort(Work.Fail4);
%Sort(Work.Fail5);
%Sort(Work.Fail6);
%Sort(Work.Fail7);
%Sort(Work.Fail8);
%Sort(Work.Fail9);
%Sort(Work.Fail10);
*=====================================================================================================================================================
--- Merge all FAIL datasets by RowCnt for reporting purposes  ---
======================================================================================================================================================;
Data Work.Fail;
	Merge Work.Fail1
	Work.Fail2
	Work.Fail3
	Work.Fail4
	Work.Fail5
	Work.Fail6
	Work.Fail7
	Work.Fail8
	Work.Fail9
	Work.Fail10;
	By RowCnt;
Run;
*=====================================================================================================================================================
--- Test if the Fail dataset contains any observations to select the correct report to print ---
======================================================================================================================================================;
%Let dsid = %sysfunc(open(Work.Fail)); 
%Let NOBS = %sysfunc(attrn(&dsid,nobs)); 
%Let rc = %sysfunc(close(&dsid)); 
%Put NOBS = &NOBS;

*=====================================================================================================================================================
--- Test if the _A_BANK_API dataset contains any observations which did not match with the Schema values ---
======================================================================================================================================================;
%Let dsid = %sysfunc(open(Work._a_&Bank._API)); 
%Let NOBS_API = %sysfunc(attrn(&dsid,nobs)); 
%Let rc = %sysfunc(close(&dsid)); 
%Put NOBS_API = &NOBS_API;

*=====================================================================================================================================================
--- Test if the _S_BANK_API dataset contains any observations which did not match with the API values ---
======================================================================================================================================================;
%Let dsid = %sysfunc(open(Work._s_&Bank._API)); 
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
Proc Sort Data = OBData.Stats;
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
      Put '<td valign="top" style="background-color: lightblue; color: orange">';
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
--- Proc Template creates the style OBStyle and the macro is called by Proc Report ---
======================================================================================================================================================;
%Macro Template;
Proc Template;
 define style OBStyle;
 notes "My Simple Style";
 class body /
 backgroundcolor = white
 color = black
 fontfamily = "Palatino"
 ;
 class systemtitle /
 fontfamily = "Verdana, Arial"
 fontsize = 16pt
 fontweight = bold
 ;
 class table /
 backgroundcolor = #f0f0f0
 bordercolor = red
 borderstyle = solid
 borderwidth = 1pt
 cellpadding = 5pt
 cellspacing = 0pt
 frame = void
 rules = groups
 ;
 class header, footer /
 backgroundcolor = #c0c0c0
 fontfamily = "Verdana, Arial"
 fontweight = bold
 ;
 class data /
 fontfamily = "Palatino"
 ;
 end; 

Run;
%Mend Template
%Template;
*=====================================================================================================================================================
--- Run Macro to Print the CMA9 Reports for ATMS, BRANCHES, PCA, etc ---
======================================================================================================================================================;
%Macro Print_Results(Bank, API);

%If &ErrorCode > 0 %Then 
%Do;
	%Sys_Errors(&_BankName, &_APIName);
%End;



%If &ErrorCode = 0 and &NOBS > 0 %Then 
%Do;
*=====================================================================================================================================================
						LIST OF ERRORS REPORT
=====================================================================================================================================================;
%Macro API_Errors(Bank, API);

*=====================================================================================================================================================
--- Run Header code to include OPEN BANKING Imaage at the top of the Report ---
=====================================================================================================================================================;
/*%Header();*/

*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
=====================================================================================================================================================;
		ODS _All_ Close;
/*
		ODS HTML Body="&Bank._&API._Body_%sysfunc(datetime(),B8601DT15.).html" 
			Contents="&Bank._&API._Contents.html" 
			Frame="&Bank._&API._Frame.html" 
			Style=HTMLBlue;
*/
/*  		ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;*/

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
=====================================================================================================================================================;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.OBStyle 
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
		Title4 "";
		Title5 "&API_Link";
		Title6 "&SCH_Link";

		Proc Report Data =  Work.Fail nowd
			style(report)=[rules=all cellspacing=0 bordercolor=gray] 
			style(header)=[background=lightskyblue foreground=black] 
			style(column)=[background=lightcyan foreground=black];

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



ods tagsets.tableeditor close; 
ods listing; 

%Mend API_Errors;
%API_Errors(&Bank, &API);

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
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&Bank._&_APIName._Fail.csv);

%End;


%Else %If &ErrorCode = 0 and &NOBS_API > 0 %Then 
%Do;
*=====================================================================================================================================================
						LIST OF DATA RECORDS ONLY IN BANK API TABLE REPORT
======================================================================================================================================================;
%Macro API_MisMatch(Bank, API);

*=====================================================================================================================================================
--- Print Report with reocrds only in the Bank API dataset ---
=====================================================================================================================================================;

/*		ODS _All_ Close;*/
/*		ODS HTML Body="&Bank._&API._Body_%sysfunc(datetime(),B8601DT15.).html" 
			Contents="&Bank._&API._Contents.html" 
			Frame="&Bank._&API._Frame.html" 
			Style=Brick;
*/
/*   		ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;*/

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.OBStyle 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

		Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
		Title2 "%Sysfunc(UPCASE(&Bank)) - %Sysfunc(UPCASE(&API))";
		Title3 "RECORDS ONLY IN %Sysfunc(UPCASE(&API)) OUTPUT FILE - %Sysfunc(UPCASE(&Fdate))";
		Title4 "";
		Title5 "&API_Link";
		Title6 "&SCH_Link";

		Proc Report Data =  Work._a_&Bank._API nowd
			style(report)=[rules=all cellspacing=0 bordercolor=gray] 
			style(header)=[background=lightskyblue foreground=black] 
			style(column)=[background=lightcyan foreground=black];

		Columns Hierarchy
		&Bank._Value;

		Define Hierarchy / display 'Data Hierarchy' left;
		Define &Bank._Value / display "&Bank. Value" left;

		Compute Hierarchy;

		If Hierarchy NE '' then 
			Do;
				call define(_col_,'style',"style=[foreground=blue background=lightblue font_weight=bold]");
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
Proc Export Data = Work._a_&Bank._API
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
%Mend ExportXL;
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\_a_&Bank._&_APIName..csv);

%End;

%Else %If &ErrorCode = 0 and &NOBS_SCH > 0 %Then 
%Do;
*=====================================================================================================================================================
						LIST OF DATA RECORDS ONLY IN BANK API TABLE REPORT
======================================================================================================================================================;
%Macro API_MisMatch(Bank, API);

*=====================================================================================================================================================
--- Print Report with reocrds only in the Bank API dataset ---
======================================================================================================================================================;
/*		ODS _All_ Close;*/
/*		ODS HTML Body="&Bank._&API._Body_%sysfunc(datetime(),B8601DT15.).html" 
			Contents="&Bank._&API._Contents.html" 
			Frame="&Bank._&API._Frame.html" 
			Style=Brick;
*/
/*   		ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;*/

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";

*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.OBStyle 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

		Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
		Title2 "%Sysfunc(UPCASE(&Bank)) - %Sysfunc(UPCASE(&API))";
		Title3 "RECORDS ONLY IN %Sysfunc(UPCASE(&API)) OUTPUT FILE - %Sysfunc(UPCASE(&Fdate))";
		Title4 "";
		Title5 "&API_Link";
		Title6 "&SCH_Link";

		Proc Report Data =  Work._s_&Bank._API nowd
			style(report)=[rules=all cellspacing=0 bordercolor=gray] 
			style(header)=[background=lightskyblue foreground=black] 
			style(column)=[background=lightcyan foreground=black];

		Columns Hierarchy
		&Bank._Value;

		Define Hierarchy / display 'Data Hierarchy' left;
		Define &Bank._Value / display "&Bank. Value" left;


		Compute Hierarchy;

		If Hierarchy NE '' then 
			Do;
				call define(_col_,'style',"style=[foreground=blue background=lightblue font_weight=bold]");
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
Proc Export Data = Work._s_&Bank.&_API
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
%Mend ExportXL;
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\_s_&Bank._&_APIName..csv);

%End;

%Else %If &ErrorCode = 0 and &NOBS = 0 %Then 
%Do;
*=====================================================================================================================================================
						NO ERROR REPORT
======================================================================================================================================================;
%Macro No_Errors(Bank, API);

*=====================================================================================================================================================
--- Run Header code to include OPEN BANKING Imaage at the top of the Report ---
======================================================================================================================================================;
/*%Header();*/

*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
		ODS _All_ Close;
/*
		ODS HTML Body="&Bank._&API._Body_%sysfunc(datetime(),B8601DT15.).html" 
			Contents="&Bank._&API._Contents.html" 
			Frame="&Bank._&API._Frame.html" 
			Style=HTMLBlue;
*/
/*  		ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;*/

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style= OBStyle 
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
		Title4 "";
		Title5 "&API_Link";
		Title6 "&SCH_Link";

		Proc Report Data =  Work.No_Obs nowd
			style(report)=[rules=all cellspacing=0 bordercolor=gray] 
			style(header)=[background=lightskyblue foreground=black] 
			style(column)=[background=lightcyan foreground=black];

		Columns ERROR_DESC ;

		Define ERROR_DESC / display 'CLEAN SCHEMA vs. API VALIDATION REPORT' left;

		Compute ERROR_DESC;

		If ERROR_DESC NE '' then 
			Do;
				call define(_col_,'style',"style=[foreground=blue background=lightblue font_weight=bold]");
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
ods tagsets.tableeditor close; 
ods listing; 

	%Mend No_Errors;
	%No_Errors(&Bank, &API);

*=====================================================================================================================================================
						EXPORT REPORT RESULTS TO RESULTS FOLDER
=====================================================================================================================================================;
%Macro ExportXL(Path);
Proc Export Data = Work.No_Obs
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;


FILENAME Mailbox EMAIL "&_WebUser"
Subject='Test Mail message' ATTACH="&Path";
DATA _NULL_;
FILE Mailbox;
PUT "Hello";
PUT "Please find Report as an attachment";
PUT "Thank you";
RUN;

%Mend ExportXL;
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&Bank._&APIName._No_Obs.csv);


%End;

%Mend Print_Results;
%Print_Results(&Bank, &API);
*=====================================================================================================================================================
--- The values are passed from the Main macro to resolve in the macro below which allows execution of the API data extract ---
======================================================================================================================================================;
%Mend API;
%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
*=====================================================================================================================================================
--- The values are passed from the Main macro to resolve in the macro below which allows execution of the API data extract ---
======================================================================================================================================================;
%Mend Schema;
%Schema(&GitHub_Path/%Sysfunc(Tranwrd(&Github_API..json,'-','_')),&Bank_Name,&API_SCH);
*=====================================================================================================================================================
--- The values are passed from the UI to resolve in the macro below which allows execution of the API data extract ---
======================================================================================================================================================;
%Mend Main;

%Main(&SCH_Link,
&SCH_Name,
&API_Link,
&API_Name,
&Perm_Sch_Table,
&Version_C,
&BankName_C);

/*
https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master/personal_current_account.json
*====================================================================================
*				MACRO HEADER
*%Macro Main(GitHub_Path,Github_API,API_Path,Main_API,Version,Bank_Name);
*====================================================================================;
*--- COMMERCIAL-CREDIT-CARDS ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
commercial_credit_card,
https://atlas.api.barclays/open-banking,
commercial-credit-cards,
CCC_Schema,
v1.3,
Barclays);

*--- SME-LOANS ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
sme_loan,
https://atlas.api.barclays/open-banking,
unsecured-sme-loans,
v1.3,
Barclays);

*=====================================================================================================
		Run this macro to show Mis-matches bwteen 1.3 Schema structure between OB and 1.24 API
======================================================================================================;
*--- BRANCHES ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
branch,
https://obp-api.danskebank.com/open-banking,
branches,
v1.2,
Danske_Bank);

*==================================================================================================
		Run this macro to show matching Schema structure between OB V1.3 and and Barclays API V1.3
======================================================================================================;
*--- BRANCHES ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
branch,
https://atlas.api.barclays/open-banking,
branches,
v1.3,
Barclays);


/*
%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
business_current_account,
https://atlas.api.barclays/open-banking,
business-current-accounts,
BCA_Schema,
v1.3,
Barclays);


%Global SCH_Name;
%Global SCH_Link;
%Global API_Link;
%Global API_Name;
%Global Perm_Sch_Table;
%Global BankName_C;
%Global Version_C;


*=====================================================================================================
		Schema V1.3 - END
======================================================================================================;
*--- PERSONNAL-CURRENT-ACCOUNT ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
personal_current_account,
https://obp-api.danskebank.com/open-banking,
personal-current-accounts,
v1.2,
Danske_Bank);


/*
*--- BUSINESS-CURRENT-ACCOUNT ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
business_current_account,
https://obp-api.danskebank.com/open-banking,
business-current-accounts,
v1.2,
Danske_Bank);

*--- BUSINESS-CURRENT-ACCOUNT ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
business_current_account,
https://atlas.api.barclays/open-banking,
business-current-accounts,
v1.3,
Barclays);


*--- BUSINESS-CURRENT-ACCOUNT ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
business_current_account,
https://obp-api.danskebank.com/open-banking,
business-current-accounts,
v1.2,
Danske_Bank);

*--- BUSINESS-CURRENT-ACCOUNT V1.3 ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
business_current_account,
https://api.hsbc.com/open-banking,
business-current-accounts,
v1.2,
HSBC);

*--- BUSINESS-CURRENT-ACCOUNT V1.2.4 ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUKShared/opendata-test-harness/master/Schema/v1.2.4/BRANCH_v1.2.4.JSON?token=AZNlhSu99TD83rQXy2H0FFms5Cv4GvPCks5ZGVoFwA%3D%3D);
*%Main(http://localhost/openbanking,
branches124,
https://obp-api.danskebank.com/open-banking,
branches,
v1.2,
Danske_Bank);

*--- BUSINESS-CURRENT-ACCOUNT V1.2.4 ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUKShared/opendata-test-harness/master/Schema/v1.2.4/BRANCH_v1.2.4.JSON?token=AZNlhSu99TD83rQXy2H0FFms5Cv4GvPCks5ZGVoFwA%3D%3D);
*%Main(http://localhost/openbanking,
branches124,
https://api.hsbc.com/open-banking,
branches,
v1.2,
HSBC);

*--- ATMS DANSKE BANK---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
atm,
https://obp-api.danskebank.com/open-banking,
atms,
v1.2,
Danske_Bank);

*--- ATMS HSBC ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
atm,
https://api.hsbc.com/open-banking,
atms,
v1.2,
HSBC);

*--- ATMS BARCLAYS ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
atm,
https://atlas.api.barclays/open-banking,
atms,
v1.3,
Barclays);

*--- BRANCHES BARCLAYS ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
branch,
https://atlas.api.barclays/open-banking,
branches,
v1.3,
Barclays);
*/

*--- SWAGGER SPEC ---;
*%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
opendata-swagger,
https://obp-api.danskebank.com/open-banking,
personal-current-accounts,
v1.2,
Danske_Bank);

/*
%Main(https://raw.githubusercontent.com/OpenBankingUK/opendata-api-spec-compiled/master,
opendata-swagger,
https://obp-api.danskebank.com/open-banking,
personal-current-accounts,
v1.2,
Danske_Bank);
*/


/*
%API(https://openapi.bankofireland.com/open-banking/v1.2/&Path,Bank_of_Ireland,&Main_API);
%API(https://api.bankofscotland.co.uk/open-banking/v1.2/&Path,Bank_of_Scotland,&Main_API);
%API(https://atlas.api.barclays/open-banking/v1.3/&Path,Barclays,&Main_API);
%API(https://obp-api.danskebank.com/open-banking/v1.2/&Path,Danske_Bank,&Main_API);
%API(https://api.firsttrustbank.co.uk/open-banking/v1.2/&Path,First_Trust_Bank,&Main_API);
%API(https://api.halifax.co.uk/open-banking/v1.2/&Path,Halifax,&Main_API);
%API(https://api.hsbc.com/open-banking/v1.2/&Path,HSBC,&Main_API);
%API(https://api.lloydsbank.com/open-banking/v1.2/&Path,Lloyds_Bank,&Main_API);
%API(https://openapi.nationwide.co.uk/open-banking/v1.2/&Path,Nationwide,&Main_API);
%API(https://openapi.natwest.com/open-banking/v1.2/&Path,Natwest,&Main_API);
%API(https://openapi.rbs.co.uk/open-banking/v1.2/&Path,RBS,&Main_API);
%API(https://api.santander.co.uk/retail/open-banking/v1.2/&Path,Santander,&Main_API);
%API(https://openapi.ulsterbank.co.uk/open-banking/v1.2/&Path,Ulster_Bank,&Main_API);
*/


