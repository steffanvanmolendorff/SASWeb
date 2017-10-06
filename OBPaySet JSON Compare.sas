Options MLOGIC MPRINT SOURCE SOURCE2 SYMBOLGEN;

Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";


%Macro Import(Filename,Dsn);
/**********************************************************************
*   PRODUCT:   SAS
*   VERSION:   9.4
*   CREATOR:   External File Interface
*   DATE:      21JUN17
*   DESC:      Generated SAS Datastep Code
*   TEMPLATE SOURCE:  (None Specified.)
***********************************************************************/
   data WORK.&Dsn    ;
   %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
   infile "&Filename" Delimiter = ',' MISSOVER DSD Lrecl=32767 Firstobs=2 Termstr=CRLF;
      informat Name $262. ;
      informat Occurrence $4. ;
      informat XPath $58. ;
      informat EnhancedDefinition $1024. ;
      informat Class $49. ;
      informat Codes $6. ;
      informat Pattern $12. ;
      informat TotalDigits $1. ;
      informat FractionDigits $1. ;
      format Name $262. ;
      format Occurrence $4. ;
      format XPath $58. ;
      format EnhancedDefinition $1024. ;
      format Class $49. ;
      format Codes $6. ;
      format Pattern $12. ;
      format TotalDigits $1. ;
      format FractionDigits $1. ;

	  input @;

	  If Substr(Xpath,1,1) EQ '"' then
	  Do;
			_Infile_ = Tranwrd(_Infile_,',','');
	  End;

   input
               Name $
               Occurrence $
               XPath $
               EnhancedDefinition $
               Class $
               Codes $
               Pattern $
               TotalDigits $
               FractionDigits $
   ;
   if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */

   *--- This line will identify any line or carriage returns within the description field ---;
      		EnhancedDefinition = Compress(EnhancedDefinition,'0D0A'x);

   run;


Data OBData.&Dsn(Drop = Hierarchy Position Want Rename=(Hierarchy1 = Hierarchy));
	Length Table $ 16 Pattern Hierarchy Hierarchy1 &Dsn._Lev1 Position Want $ 250;
	Set Work.&Dsn;
	If XPath NE '';
	Table = "&Dsn";
	NewPath = Compress('D'||Scan(XPath,2,'/D'));
	Hierarchy = Trim(Left(Tranwrd(Trim(Left(Substr(XPath, index(XPath, '/D') + 1))),'/','-'))); 

	Position = Scan(Hierarchy,2,'-');
	want = substr(Hierarchy,1,length(Hierarchy)-indexc(reverse(trim(Hierarchy)),'-'));

	If Trim(Left(Name)) EQ 'Data' Then
	Do;
		Hierarchy1 = Trim(Left(Name));
	End;
	If Trim(Left(Name)) NE 'Data' Then
	Do;
		Hierarchy1 = Trim(Left(Want))||'-'||Trim(Left(Name));
	End;

	&Dsn._Lev1 = Hierarchy1;
Run;

Proc Sort Data = OBData.&Dsn;
	By Hierarchy;
Run;

%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Temp\V1_1_1\OBPaySet.csv,OBPaySet);
%Import(C:\inetpub\wwwroot\sasweb\Data\Temp\V1_1_1\OBPaySetResponse.csv,OBPaySetResponse);
%Import(C:\inetpub\wwwroot\sasweb\Data\Temp\V1_1_1\OBPaySub.csv,OBPaySub);
%Import(C:\inetpub\wwwroot\sasweb\Data\Temp\V1_1_1\OBPaySubResponse.csv,OBPaySubResponse);


/*
*====================================================================================================
=								API EXTRACT															=
=====================================================================================================;
*--- The Main macro will execute the code to extract data from the API end points ---;
%Macro API(Url,Bank,API);

Filename API Temp;
 
*--- Proc HTTP assigns the GET method in the URL to access the data ---;
Proc HTTP
	Url = "&Url."
 	Method = "GET"
 	Out = API;
Run;
 
*--- The JSON engine will extract the data from the JSON script ---; 
Libname LibAPIs JSON Fileref=API;

*--- Proc datasets will create the datasets to examine resulting tables and structures ---;
Proc Datasets Lib = LibAPIs; 
Quit;


Data Work.&Bank._API;
	Set LibAPIs.Alldata;
Run;
%Mend API;
%API(http://localhost/sasweb/data/temp/payment_initiation_swagger.json,Test,PIS);
*/



*--- Set system options to track comments in the log file ---;
*Options DMSSYNCHK;

*--- The Main macro will execute the code to extract data from the API end points ---;
%Macro Schema(Url,JSON,API_SCH);
*--- Set a temporary file name to extract the content of the Schema JSON file into ---;
Filename API Temp;
 
*--- Proc HTTP assigns the GET method in the URL to access the data contained within the Schema ---;
Proc HTTP
	Url = "&Url."
 	Method = "GET" Verbose
 	Out = API;
Run;
 
*--- The JSON engine will extract the data from the JSON script ---; 
Libname LibAPIs JSON Fileref=API;

*--- Proc datasets will create the datasets to examine resulting tables and structures ---;
Proc Datasets Lib = LibAPIs; 
Quit;

*--- Capture any error codes at this point, specifically if the Schema file did no load ---;
%If &SYSERR > 0 %Then
%Do;
	%Let SYSTEM_ERROR = &SYSERR;
%End;

*--- Create the Bank Schema dataset ---;
Data Work.&JSON;
	Set LibAPIs.Alldata(Where=(V NE 0));
Run;

*--- Sort the Bank Schema file ---;
Proc Sort Data = Work.&JSON
	Out = Work.H_Num;
	By Descending P;
Run;

Data Work._Null_;
*--- The variable V contains the first level of the Hierarchy which has no Bank information ---;
*--- Keep only the highest value of P which will be used in the macro variable H_Num ---;
	Set Work.H_Num(Obs=1 Keep = P);
*--- Create a macro variable H_Num to store the hiighest number of Hierarchical levels which will be used in code iterations ---;
	Call Symput('H_Num', Compress(Put(P,3.)));
Run;

Data Work.&JSON
	(Rename=(Var3 = Data_Element Var2 = Hierarchy));

	Length Bank_API $ 8 Var2 $ 250 Var3 $ 250 P1 - P&H_Num $ 250 Value $ 1024;

	RowCnt = _N_;

	Set Work.&JSON;

*--- Create Array concatenate variables P1 to P7 which will create the Hierarchy ---;
	Array Cat{&H_Num} P1 - P&H_Num;

*--- The Do-Loop will create the Hierarchy of Level 1 to 7 (P1 - P7) ---;
	If P = 1 Then
	Do;
		Do i = 1 to P;
	*--- If it is the first data field then do ---;
			Var2 = Trim(Left(Cat{i}));
			Count = i;
		End;
	End;

	If P > 1 then
	Do;
		Do i = 1 to P-1;
			If i = 1 Then 
			Do;
	*--- If it is the first data field then do ---;
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

	*--- Create variable to list the API value i.e. ATM or Branches ---;
	Bank_API = "Schema";

*--- Extract only the last level of the Hierarchy ---;
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

	Length Columns $ 30 Value $ 1024;

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
		'enum21','enum22','enum23','enum24','enum25','enum26','enum27','enum28','enum29','enum30'
		'enum31','enum32','enum33','enum34','enum35','enum36','enum37','enum38','enum39','enum40') then
	Do;
		Columns = Reverse(Scan(Reverse(New_Data_Element),1,'-'));
	End;

*--- Ensure that the Column variable has no blank spaces to avoide errors to avoide macro Variable_Name failure ---; 
	If Columns = '' then 
	Do;
		Columns = Attribute;
	End;
Run;


*--- Create Enum Counter (EnumCnt)to append to Columns variable values where Columns contain enum ---; 
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

*--- TBC ---;
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
		Length Hierarchy $ 250  Description $ 1024;
	Run;

%Do i = 1 %To %Eval(&HierCnt);

	%Put i = &i;

	Data Work.Unique_Columns&i;
		Length Hierarchy $ 250  Description $ 1024;
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
		/*(Keep = Hierarchy 
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
		enum1 - enum33
		Hierarchy1
		Table)*/   OBData.X;
		Length Table $ 16 Hierarchy1 $ 250;
		Set Work.Schema_Columns
			Work.Unique_Columns&i;

/*			Hierarchy = (Tranwrd(Trim(Left(Hierarchy)),'items-',''));*/

/*		If Hierarchy EQ '' then Delete;*/

		Hierarchy1 = Trim(Left(Substr(Hierarchy, index(Hierarchy, '-D') + 1)));
		Table  = 'Swagger_Sch';

 *--- This line will identify any line or carriage returns within the description field ---;
 		Definition = Compress(Definition,'0D0A'x);


		If Find(Hierarchy,'-Risk') > 0 Then
		Do;

			If Substr(Hierarchy1,1,Find(Hierarchy1,'-Risk')) = 'paths-/payments-post-parameters-schema-' Then
			Do;
				Hierarchy1 = Compress('OBPaymentSetup1'||Substr(Hierarchy1,Find(Hierarchy1,'-Risk')));
			End;

			If Substr(Hierarchy1,1,Find(Hierarchy1,'-Risk')) = 'paths-/payments-post-responses-201-schema-' Then
			Do;
				Hierarchy1 = Compress('OBPaymentSetupResponse1'||Substr(Hierarchy1,Find(Hierarchy1,'-Risk')));
			End;

			If Substr(Hierarchy1,1,Find(Hierarchy1,'-Risk')) = 'paths-/payment-submissions-post-parameters-schema-' Then
			Do;
				Hierarchy1 = Compress('OBPaymentSubmission1'||Substr(Hierarchy1,Find(Hierarchy1,'-Risk')));
			End;

			If Substr(Hierarchy1,1,Find(Hierarchy1,'-Risk')) = 'paths-/payments/{PaymentId}-get-responses-200-schema-' Then
			Do;
				Hierarchy1 = Compress('OBPaymentSubmissionResponse1'||Substr(Hierarchy1,Find(Hierarchy1,'-Risk')));
			End;

		End;

	Run;


%End;


	Proc Sort Data = Work.Schema_Columns
		Out = OBData.&API_SCH(Drop = Hierarchy Rename=(Hierarchy1 = Hierarchy));
		By Hierarchy1;
	Run;


%Mend VarVal;
%VarVal();


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




%Mend Schema;
%Schema(http://localhost/sasweb/data/temp/V1_1_1/payment_initiation_swagger.json,Test,Swagger_SCH);

Data OBData.Compare(Keep = Hierarchy Table MinLength MaxLength type Class
	OBPaySet_Lev1
	OBPaySetResponse_Lev1
	OBPaySub_Lev1
	OBPaySubResponse_Lev1 
	ClassLength EnhancedDefinition Description Desc_Flag UML_MaxLength UML_MinLength
	Min_Length_Flag Max_Length_Flag);

	Length Table $ 16
	Hierarchy 
	OBPaySet_Lev1
	OBPaySetResponse_Lev1
	OBPaySub_Lev1
	OBPaySubResponse_Lev1 
	Description $ 1024
	EnhancedDefinition $ 1024
	Desc_Flag $ 8
	XPath $ 100 
	Codes $ 30 
	NewPath $ 70;

	Merge OBData.Swagger_Sch(In=a)
	OBData.OBPaySet(In=b)
	OBData.OBPaySub(In=d)
	OBData.OBPaySetResponse(In=c)
	OBData.OBPaySubResponse(In=e);

	By Hierarchy;

	If maxLength ~= '' Then
	Do;
		ClassLength = Length(Class);
	End;

/*
	If a and b then Infile = 'a and b';
	If a and c then Infile = 'a and c';
	If a and d then Infile = 'a and d';
	If a and e then Infile = 'a and e';
*/

*--- Find mismatches between EhancedDefinition and Description variables ---;
If Strip(Trim(Left(EnhancedDefinition))) NE Strip(Trim(Left(Description))) then 
	Do;
		Desc_Flag = 'Mismatch';
	End;
	Else Do;
		Desc_Flag = 'Match';
	End;

*--- Compare the length values of the Class and MinLength/MacLength variables ---;
If Substr(Class,1,3) in ('Min','Max') Then
Do;

	If Substr(Class,1,3) EQ "Min" Then
	Do;
		UML_MinLength = Scan(Substr(Trim(Left(Class)),4),1,'Min');
		UML_MaxLength = Scan(Substr(Reverse(Trim(Left(Class))),5),1,'xaM');
	End;
	If Substr(Class,1,3) EQ "Max" Then
	Do;
		UML_MaxLength = Reverse(Substr(Reverse(Substr(Trim(Left(Class)),4)),5));
		UML_MinLength = '0';
	End;

	If MaxLength NE UML_MaxLength Then
	Do;
		Max_Length_Flag = 'Mismatch';
	End;
	Else Do;
		Max_Length_Flag = 'Match';
	End;

	If MinLength NE UML_MinLength Then
	Do;
		Min_Length_Flag = 'Mismatch';
	End;
	Else Do;
		Min_Length_Flag = 'Match';
	End;
End;

Run;



Proc Sort Data = OBData.Compare NoDupKey;
	By Hierarchy;
Run;

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

		Put '<script type="text/javascript" src="http://localhost/sasweb/js/jquery.js">';
		Put '</script>';

		Put '<link rel="stylesheet" type="text/css" href="http://localhost/sasweb/css/style.css">';

		Put '</HEAD>';
		Put '<BODY>';

		Put '<p></p>';
		Put '<HR>';
		Put '<p></p>';

		Put '<Table align="center" style="width: 100%; height: 15%" border="0">';
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';
		Put '<FORM NAME=check METHOD=get ACTION="http://localhost/scripts/broker.exe">';
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

*--- Set Title Date in Proc Print ---;
%Macro Fdate(Fmt,Fmt2);
   %Global Fdate FdateTime;
   Data _Null_;
      Call Symput("Fdate",Left(Put("&Sysdate"d,&Fmt)));
      Call Symput("FdateTime",Left(Put("&Sysdate"d,&Fmt2)));
  Run;
%Mend Fdate;
%Fdate(worddate12., datetime.);

/*
ODS _All_ Close;
ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;
*/

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
title "Listing of Product Sales"; 
ods listing close; 
/*ods tagsets.tableeditor file="C:\inetpub\wwwroot\sasweb\Data\Results\Sales_Report_1.html" */
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
	Title2 "Comparison of UML and JSON File Structures - %Sysfunc(UPCASE(&Fdate))";

/*
Proc Print Data = OBData.Compare;
Run;
*/

Proc Report Data = OBData.Compare nowd
			style(report)=[rules=all cellspacing=0 bordercolor=gray] 
			style(header)=[background=lightskyblue foreground=black] 
			style(column)=[background=lightcyan foreground=black];

			Columns Table
			Hierarchy
			OBPaySet_Lev1
			OBPaySetResponse_Lev1
			OBPaySub_Lev1
			OBPaySubResponse_Lev1
			Description
			EnhancedDefinition
			Desc_Flag
			Type
			MinLength
			MaxLength
			Class
			ClassLength
			UML_MinLength
			UML_MaxLength
			Min_Length_Flag
			Max_Length_Flag;

			Define Table / display 'Table' left;
			Define Hierarchy / display 'Data Hierarchy' left;
			Define OBPaySet_Lev1 / display 'OB Payset Data Level' left;
			Define OBPaySetResponse_Lev1 / display 'OB Payset Response Data Level' left;
			Define OBPaySub_Lev1 / display 'OB Pay Sub Level' left;
			Define OBPaySubResponse_Lev1 / display 'OB Pay Sub Response Level' left;
			Define Description / display 'Description' left;
			Define EnhancedDefinition / display 'Enhanced Definition' left;
			Define Desc_Flag / display 'Description Flag' left;
			Define Type / display 'Type' left;
			Define MinLength / display 'Min Length' left;
			Define MaxLength / display 'Max Length' left;
			Define Class / display 'Class' left;
			Define ClassLength / display 'Class Length' left;
			Define UML_MinLength / display 'UML Min Length' left;
			Define UML_MaxLength / display 'UML Max Length' left;
			Define Min_Length_Flag / display 'Min Length Flag' left;
			Define Max_Length_Flag / display 'Max Length Flag' left;

		Compute Desc_Flag;
		If Desc_Flag = 'Mismatch' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;

		Compute Min_Length_Flag;
		If Min_Length_Flag = 'Mismatch' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;

		Compute Max_Length_Flag;
		If Max_Length_Flag = 'Mismatch' then 
			Do;
				call define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
			End;
		Endcomp;
		
Run;

%ReturnButton;

*=====================================================================================================================================================
						EXPORT REPORT RESULTS TO RESULTS FOLDER
=====================================================================================================================================================;
%Macro ExportXL(Path);
Proc Export Data = OBData.Compare
 	Outfile = "&Path"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
%Mend ExportXL;
%ExportXL(C:\inetpub\wwwroot\sasweb\Data\Results\OBPAYSET_SUB_RESPONSE.csv);

ODS CSV File="C:\inetpub\wwwroot\sasweb\data\results\OBPAYSET_SUB_RESPONSE.csv";
Proc Print Data=OBData.Compare;
	Title1 "OPEN BANKING - &API";
	Title2 "OBPAYSET DATA STRUCTURE REPORT - &Fdate";
Run;
ODS CSV Close;

/*
ODS HTML Close;
ODS Listing;
*/

ods tagsets.tableeditor close; 
ods listing; 
