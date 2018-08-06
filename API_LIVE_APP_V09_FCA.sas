*--- Run the SAS code manually on desktop ---;
/*
%Global _APIName;
%Let _APIName = PCA;
*/

%Macro Select_OD_RW(_API);
%If "&_API" EQ "PMT" or "&_API" EQ "ACC" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\source\API_LIVE_APP_RW_V01.sas";
%End;
%Else %Do;
*=====================================================================================================================================================
--- Set system options to track comments in the log file ---
======================================================================================================================================================;

Options MLOGIC MPRINT SOURCE SOURCE2 SYMBOLGEN SPOOL;
OPTIONS NOSYNTAXCHECK;


Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";

*--- Uncomment to run on local laptop/pc machine ---;

%Global _BankName;
%Global _APIName;
%Global _VersionNo;

%Let _BankName = Danske;
%Let _APIName = PCA;
%Let _VersionNo = v2.2.1;

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

%Let _WebUser = &_WebUser;
%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;





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
*--- Add the Tranwrd function to test from local directories ---;
	Call Symput('SCH_Link',Tranwrd(SCH_Link,'.','_'));
	Call Symput('SCH_Name',SCH_Name);
	Call Symput('Perm_Sch_Table',Perm_Sch_Table);
*--- Add the Tranwrd function to test from local directories ---;
	Call Symput('Version_C',Tranwrd(Version,'.','_'));
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
	%Put Sch_Version = "&Sch_Version";
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

/*
*--- Create a date for the export of thr Report filenames ---;
%Macro FileNameDate();
%Global FileDateTime;
Data _Null_x;
	FileDateTime = Put(DateTime(),datetime.);
	FileDateTime1 = Tranwrd(FileDateTime,":","_");
	Call Symputx('FileDateTime1',FileDateTime1);
Run;
%Mend FileNameDate;
%FileNameDate();
*/

%let fname = %sysfunc(DateTime(),datetime.);
%put fname= &fname;



%Macro Sys_Errors(Bank, API);

*=====================================================================================================================================================
--- Run Header code to include OPEN BANKING Image at the top of the Report ---
======================================================================================================================================================;
%Header();
*=====================================================================================================================================================
--- Set Output Delivery Parameters  ---
======================================================================================================================================================;
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
*=====================================================================================================================================================
--- The Main macro will execute the code to extract data from the API end points ---
======================================================================================================================================================;
%Macro Schema(Url,JSON,API_SCH);
*=====================================================================================================================================================
--- Set a temporary file name to extract the content of the Schema JSON file into ---
======================================================================================================================================================;
Filename API Temp;
%ErrorCheck;
*=====================================================================================================================================================
--- Proc HTTP assigns the GET method in the URL to access the data contained within the Schema ---
======================================================================================================================================================;
Proc HTTP
	Url = "&Url."
 	Method = "GET" Verbose
 	Out = API;
Run;
%ErrorCheck;
*=====================================================================================================================================================
--- The JSON engine will extract the data from the JSON script ---
======================================================================================================================================================;
Libname LibAPIs JSON Fileref=API;
%ErrorCheck;
*=====================================================================================================================================================
--- Proc datasets will create the datasets to examine resulting tables and structures ---
======================================================================================================================================================;
Proc Datasets Lib = LibAPIs; 
Run;
%ErrorCheck;
*=====================================================================================================================================================
--- Create the Bank Schema dataset ---
======================================================================================================================================================;
Data Work.&JSON;
	Set LibAPIs.Alldata(Where=(V NE 0));
Run;
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

	Length Bank_API $ 8 Var2 $ 500 Var3 $ 500 P1 - P&H_Num $ 500;

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

Data Work.&JSON(Drop = Value1 Value2);
	Set Work.&JSON;

	Length New_Data_Element New_Data_Element1 New_Data_Element2 $ 500 Value $ 1000;

	Value1 = Compbl(Trim(Left(Tranwrd(Value,"'"," "))));
	Value2 = Compbl(Trim(Left(Tranwrd(Value1,'"'," "))));
	Value = Value2;
	

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

	Data_Element = Compress(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Hierarchy,'properties-',''),'-enum',''),'-items',''),'-required',''),'items-',''));

Run;

Proc Sort Data = Work.&JSON
	Out = Work.&JSON;
	By Hierarchy;
Run;

Data Work.&JSON(Drop=Hierarchy Rename=(Data_Element_1 = Hierarchy));
	Set Work.&JSON;
	By Hierarchy;

	Length Data_Element_1 Attribute Hierarchy_1 $ 500;

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
		Length Hierarchy $ 500;
	Run;

%Do i = 1 %To %Eval(&HierCnt);

	%Put i = &i;

	Data Work.Unique_Columns&i;
		Set Work.&JSON._2(Where=(HierCnt = &i));
		By HierCnt Counter;

		If Last.HierCnt and Last.Counter;

			%Do j = 1 %To &&Test_&i;
	*--- Create a list of characters to search. All variable names that only have numbers, then 
				append an underscore to avoid program errors. Variable names must start with 
				an underscore if only numbers are present in the macro variable ---;
				charlist = 'abcdefghijklmnopqrstuvwxyz';
				%If %Index(&&Variable_Name_&i._&j,charlist) EQ 0 %Then
				%Do;
					%Let Variable_Name_&i._&j = _&&Variable_Name_&i._&j;
				%End;
			
				%Put j = &j;
				%If "&&Variable_Name_&i._&j" EQ "description" %Then
				%Do;
					Length &&Variable_Name_&i._&j  $ 1000;
				%End;
		*--- Test if the Variable Name only contains numbers - if yes - add underscore ---;
				%If "&&Variable_Name_&i._&j" NE "description" %Then
				%Do;
					Length &&Variable_Name_&i._&j  $ 300;
				%End;
*--- Some variable names has a space i.e. Status Code - tranword (blanks,_) to Status_Code ---;
				%Let Varname = %Sysfunc(Tranwrd(&&Variable_Name_&i._&j.,'','_'));
				&Varname = %UNQUOTE(%STR(%')"&&Variable_Value_&i._&j."%STR(%'));
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
/*
	Proc Sort Data = Work.Schema_Columns
		Out = OBData.&API_SCH._&Sch_Version;
		By Hierarchy;
	Run;
*/
	%IF "&_VersionNo" EQ "v2.2" and "&Bank_Name" EQ "BOI" 
		and "&_APIName" EQ "PCA" %Then
	%Do;
		Data Work.Schema_Columns;
			Set Work.Schema_Columns;
				If Find(Hierarchy,'Brand') NE 0 Then
				Do;
					Hierarchy = Substr(Hierarchy,Find(Hierarchy,'Brand'));
				End;
		Run;

/*
	Proc Sort Data = Work.Schema_Columns
		Out = OBData.&API_SCH._&Sch_Version;
		By Hierarchy;
	Run;
*/

	%End;
	%IF "&_VersionNo" EQ "v2.2" and "&Bank_Name" EQ "BOI" 
		and "&_APIName" EQ "BCA" %Then
	%Do;
		Data Work.Schema_Columns;
			Set Work.Schema_Columns;
				If Find(Hierarchy,'Brand') NE 0 Then
				Do;
					Hierarchy = Substr(Hierarchy,Find(Hierarchy,'Brand'));
				End;
		Run;

/*
	Proc Sort Data = Work.Schema_Columns
		Out = OBData.&API_SCH._&Sch_Version;
		By Hierarchy;
	Run;
*/

	%End;
	%IF "&_VersionNo" EQ "v2.2" and "&Bank_Name" EQ "BOI" 
		and "&_APIName" EQ "BCH" %Then
	%Do;
		Data Work.Schema_Columns;
			Set Work.Schema_Columns;
				If Find(Hierarchy,'Brand') NE 0 Then
				Do;
					Hierarchy = Substr(Hierarchy,Find(Hierarchy,'Brand'));
				End;
		Run;

/*
	Proc Sort Data = Work.Schema_Columns
		Out = OBData.&API_SCH._&Sch_Version;
		By Hierarchy;
	Run;
*/

	%End;
	*--- Add this section to extract the path from Brand in the Swagger Path to 
		match the FCA API file structure ---;
	%IF "&_VersionNo" EQ "v1.0" and "&_APIName" EQ "FCP" or "&_APIName" EQ "FCB" %Then
	%Do;
		Data Work.Schema_Columns;
			Set Work.Schema_Columns;
				If Find(Hierarchy,'Brand') NE 0 Then
				Do;
					Hierarchy = Substr(Hierarchy,Find(Hierarchy,'Brand'));
				End;
		Run;

/*
	Proc Sort Data = Work.Schema_Columns
		Out = OBData.&API_SCH._&Sch_Version;
		By Hierarchy;
	Run;
*/

	%End;

	%Else %Do;
		Proc Sort Data = Work.Schema_Columns
			Out = OBData.&API_SCH._&Sch_Version;
			By Hierarchy;
		Run;
	%End;

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
%ErrorCheck;
*=====================================================================================================================================================
--- The JSON engine will extract the data from the JSON script ---
======================================================================================================================================================;
Libname LibAPIs JSON Fileref=API;
%ErrorCheck;
*=====================================================================================================================================================
--- Proc datasets will create the datasets to examine resulting tables and structures ---
======================================================================================================================================================;
Proc Datasets Lib = LibAPIs; 
Run;
%ErrorCheck;

Data Work.&Bank._API Work.X1;
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
Data Work.&Bank._API(Drop = Hierarchy_X Find) Work.X2;
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
	OBData.&API_SCH._&Sch_Version(In=b);

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

/*
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
*/
Run;

%Mend Test_VarLength;
%Test_VarLength(&Bank, &API);

*=====================================================================================================================================================
--- Test for the URI & Date-Time & Date Format if the Bank value = http / date-time or date ---
======================================================================================================================================================;
%Macro Test_Format(Bank, API);

Data Work.&Bank._API;
	Set Work.&Bank._API;

	Length Test_Format_Value_Desc $ 100
	Test_Format_Value $ 6;
	
	If Format NE '' Then
	Do;

*--- Test URI Format ---;
		If Scan(&Bank._Value,1,'//') in ('http:','https:') then 
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
		End;

*--- Test Date-Time Format ---;
		If Format EQ 'date-time' Then
		Do;
			Format_Value = Substr(&Bank._Value,1);

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

*--- Test Date-Time Format ---;
		If Format EQ 'date' Then
		Do;

			Format_Value = Substr(&Bank._Value,1);

			If Format_Value EQ ('date') and Substr(&Bank._Value,1,4) in ('1','2','3','4','5','6','7','8','9','0')
				and Substr(&Bank._Value,5,1) in ('-')
				and Substr(&Bank._Value,6,2) in ('1','2','3','4','5','6','7','8','9','0') 
				and Substr(&Bank._Value,8,1) in ('-') 
				and Substr(&Bank._Value,9,2) in ('1','2','3','4','5','6','7','8','9','0') then 
			Do;
				Test_Format_Value = 'Pass';
			End;
			If Format_Value in ('date') and &Bank._Value EQ '' then
			Do;
				Test_Format_Value = 'Failed';
				Test_Format_Value_Desc = "&Bank Value is blank";
			End;
			If Format_Value EQ ('date') and Substr(&Bank._Value,1,4) Notin ('1','2','3','4','5','6','7','8','9','0')
				and Substr(&Bank._Value,5,1) Notin ('-')
				and Substr(&Bank._Value,6,2) Notin ('1','2','3','4','5','6','7','8','9','0') 
				and Substr(&Bank._Value,8,1) Notin ('-') 
				and Substr(&Bank._Value,9,2) Notin ('1','2','3','4','5','6','7','8','9','0') then
			Do; 
				Test_Format_Value = 'Failed';
				Test_Format_Value_Desc = "&Bank Value may be in the wrong date format";
			End;
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
	%If "&Bankname_C" EQ "OB" %Then
	%Do;
/*		Where Name contains 'enum';*/
	%End;
	%Else %Do;
		Where Name contains 'enum';
	%End;
	RowCount + 1;
Run;

Data _Null_;
	%If "&Bankname_C" EQ "OB" %Then
	%Do;
		Set Varlist;
	%End;
	%Else %Do;
		Set Varlist(where=(Name contains ('enum')));
	%End;
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
/*		Title2 "%Sysfunc(UPCASE(&Bank)) - %Sysfunc(UPCASE(&API))";*/
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
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._NO_MISMATCHES._%sysfunc(datetime(),datetime13.).csv);

%Macro SendMail();
/*
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._Matches.csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName..csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_SCH_&Bank._&_APIName..csv";
	*/
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._Matches_%sysfunc(datetime(),datetime13.).csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._%sysfunc(datetime(),datetime13.).csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_SCH_&Bank._&_APIName._%sysfunc(datetime(),datetime13.).csv";
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\&Bank._&_APIName._Fail_%sysfunc(datetime(),datetime13.).csv";
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
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._Matches_%sysfunc(today(),date9.).csv);

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
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\&Bank._&_APIName._Fail_%sysfunc(today(),date9.).csv);

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
%If "&Bankname_C" EQ "OB" %Then
%Do;
	*--- Note the difference between the 2 lines i.e. &_API_Name vs &API_Name macro variable ---;
	%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&API_Name._%sysfunc(today(),date9.).csv);
%End;
%Else %Do;
	%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._%sysfunc(today(),date9.).csv);
%End;

%End;


%Macro SendMail();
/*
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._Matches.csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName..csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_SCH_&Bank._&_APIName..csv";
	*/
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._Matches_%sysfunc(today(),date9.).csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_API_&Bank._&_APIName._%sysfunc(today(),date9.).csv"
	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_SCH_&Bank._&_APIName._%sysfunc(today(),date9.).csv"
/*	Attach="C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\&Bank._&_APIName._Fail_%sysfunc(datetime(),datetime13.).csv"*/
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
Proc Export Data = Work._SCH_&Bank._API(Keep = Hierarchy Table Flag &Bank._Value OB_Comment /*Description*/)
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
%Mend ExportXL;
%If "&Bankname_C" EQ "OB" %Then
%Do;
	*--- Note the difference between the 2 lines i.e. &_API_Name vs &API_Name macro variable ---;
	%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_SCH_&Bank._&API_Name._%sysfunc(today(),date9.).csv);
%End;
%Else %Do;
	%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\&BankName_C\_SCH_&Bank._&_APIName._%sysfunc(today(),date9.).csv);
%End;

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
*--- For json files end point - remove *.json* in %API(&API_Path/&Main_API) ---;
%If "&_VersionNo" EQ "v1.0" and "&BankName_C" EQ "OB" %Then
%Do;
	%API(&API_Path/&Version/%Sysfunc(Tranwrd(&API_Name,'.','_')).json,&Bank_Name,%Sysfunc(Tranwrd(&API_Name,'.','_')));
%End;

*--- For json files end point - remove *.json* in %API(&API_Path/&Main_API) ---;
%If "&_VersionNo" EQ "v1.2" or "&_VersionNo" = "v1.3" %Then
%Do;
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;


*--- BOI - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "BOI" %Then
%Do;
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;
*--- BOI - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.2" and "&BankName_C" EQ "BOI" %Then
%Do;
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;
*--- NBS - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "NBS" %Then
%Do;
*	%API(&API_Path/&API_JSON..json,&Bank_Name,&Main_API);
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;
%If "&_VersionNo" EQ "v1.0" and "&BankName_C" EQ "NBS" and "&_APIName" EQ "FCP" %Then
%Do;
	%API(&API_Path/&API_JSON..json,&Bank_Name,&Main_API);
*	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;
/*
%Put _VersionNo = &_VersionNo;
%Put BankName_C = &BankName_C;
*/
*--- HSBC - For json files end point - remove *.json* in %API(&API_Path/&Main_API) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "HSBC" %Then
%Do;
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;
*--- Santander - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "Santander" %Then
%Do;
	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);
/*	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);*/
%End;
*--- BARCLAYS - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "Barclays" %Then
%Do;
/*	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);*/
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;

*--- LLOYDS - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "Lloyds" %Then
%Do;
/*	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);*/
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;

*--- BOS - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "BOS" %Then
%Do;
/*	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);*/
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;

*--- HALIFAX - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "Halifax" %Then
%Do;
/*	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);*/
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;

*--- Danske - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.2.1" and "&BankName_C" EQ "Danske" %Then
%Do;
	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);
/*	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);*/
%End;

*--- RBS - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "RBS" %Then
%Do;
/*	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);*/
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;
*--- NATWEST - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "Natwest" %Then
%Do;
/*	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);*/
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;
*--- Ulster - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "Ulster" %Then
%Do;
/*	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);*/
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;
*--- Adam & Co - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "AdamCo" %Then
%Do;
/*	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);*/
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;
*--- ESME - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "ESME" %Then
%Do;
/*	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);*/
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;
*--- Coutts - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "Coutts" %Then
%Do;
/*	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);*/
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;
*--- AIB - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "AIB" %Then
%Do;
/*	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);*/
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;
*--- First Trust Bank - For json files on local directory - not end point - add *.json* in %API(&API_Path/&Main_API..json) ---;
%If "&_VersionNo" EQ "v2.1" and "&BankName_C" EQ "Firsttrust" %Then
%Do;
/*	%API(&API_Link/&API_JSON..json,&Bank_Name,&Main_API);*/
	%API(&API_Path/&Version/&Main_API,&Bank_Name,&Main_API);
%End;

*=================================================================================================
--- The values are passed from the Main macro to resolve in the macro below which allows 
	execution of the API data extract ---
==================================================================================================;
%Mend Schema;
*%Schema(&GitHub_Path/%Sysfunc(Tranwrd(&Github_API..json,'-','_')),&Bank_Name,&API_SCH);
*--- Added the conditional logic because BOI is using Swagger v2.2.1 file in a v2.2 live endpoint 
	- Note the _v221.json extention in macro Schema() calll below ---;
%IF "&_VersionNo" EQ "v2.2" and "&Bank_Name" EQ "BOI" 
	and "&Main_API" EQ "personal-current-accounts" %Then
%Do;
	%Schema(&GitHub_Path/pca_swagger_v221.json,&Bank_Name,&API_SCH);
%End;
%Else %IF "&_VersionNo" EQ "v2.2" and "&Bank_Name" EQ "BOI" 
	and "&Main_API" EQ "business-current-accounts"%Then
%Do;
	%Schema(&GitHub_Path/bca_swagger_v221.json,&Bank_Name,&API_SCH);
%End;
%Else %IF "&_VersionNo" EQ "v2.2" and "&Bank_Name" EQ "BOI" 
	and "&_APIName" EQ "BCH"%Then
%Do;
	%Schema(&GitHub_Path/branch_swagger_v22.json,&Bank_Name,&API_SCH);
%End;
%Else %IF "&_VersionNo" EQ "v1.0" and "&Bank_Name" EQ "OB" 
	and "&_APIName" EQ "SQ1"%Then
%Do;
	%Schema(&GitHub_Path/sqm_swagger.json,&Bank_Name,&API_SCH);
%End;
%Else %Do;
	%Schema(&GitHub_Path/%Sysfunc(Tranwrd(&Github_API..json,'-','_')),&Bank_Name,&API_SCH);
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

%Put _All_;
*--- This End statement closes the If statement of code line 6 at the top of the program ---;
%End;
%Mend Select_OD_RW;
%Select_OD_RW(&_APIName);

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

