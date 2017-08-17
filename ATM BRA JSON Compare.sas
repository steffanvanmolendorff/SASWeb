%Global _APINamme;

%Macro Main(API_DSN,File);

Options MLOGIC MPRINT SOURCE SOURCE2 SYMBOLGEN;

Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Temp";

%Macro Import(Filename,Dsn);
/**********************************************************************
*   PRODUCT:   SAS
*   VERSION:   9.4
*   CREATOR:   External File Interface
*   DATE:      22JUN17
*   DESC:      Generated SAS Datastep Code
*   TEMPLATE SOURCE:  (None Specified.)
***********************************************************************/
Data WORK.&Dsn    ;
   %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
   infile "&Filename" delimiter = ',' Termstr=CRLF
MISSOVER DSD lrecl=32767 firstobs=2 ;
      informat XPath $250. ;
      informat Name $14. ;
      informat ConstraintID $2. ;
      informat MinOccurs best32. ;
      informat MaxOccurs $9. ;
      informat Data_type $26. ;
      informat Length $1. ;
      informat MinLength $ 25. ;
      informat MaxLength $ 25. ;
      informat Pattern $20. ;
      informat Code_Name $25. ;
      informat EnhancedDefinition $1024. ;
      informat XMLTag $4. ;
      format XPath $250. ;
      format Name $14. ;
      format ConstraintID $2. ;
      format MinOccurs best12. ;
      format MaxOccurs $9. ;
      format Data_type $26. ;
      format Length $1. ;
      format MinLength $ 25. ;
      format MaxLength $ 25. ;
      format Pattern $20. ;
      format Code_Name $25. ;
      format EnhancedDefinition $1024. ;
      format XMLTag $4. ;

	  input @;

	  If Substr(Xpath,1,1) EQ '"' then
	  Do;
/*			_Infile_ = Tranwrd(_Infile_,',','');*/
	  End;

   input
               XPath $
               Name $
               ConstraintID $
               MinOccurs
               MaxOccurs $
               Data_type $
               Length $
               MinLength
               MaxLength
               Pattern $
               Code_Name $
               EnhancedDefinition $
               XMLTag $
   ;
   if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
   run;

Data OBData.&Dsn/*(Drop = Hierarchy Position Want Rename=(Hierarchy1 = Hierarchy))*/;
	Length Pattern Hierarchy $ 500 &API_DSN._Lev1 $ 250;
	Set Work.&Dsn;

	If XPath NE '';

	If "&Dsn" EQ 'ATM' Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),16),'/','-');
	End;

	If "&Dsn" EQ 'BRA' Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),19),'/','-');
	End;

	If "&Dsn" EQ 'PCA' Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),16),'/','-');
	End;

	&API_DSN._Lev1 = Hierarchy;
Run;

Proc Sort Data = OBData.&Dsn;
	By Hierarchy;
Run;

%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Temp\UML\&API_DSN.l_001_001_01DD.csv,&API_DSN);
/*%Import(C:\inetpub\wwwroot\sasweb\Data\Temp\UML\bral_001_001_01DD.csv,BCH);*/


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
		Length Hierarchy $ 500  Description $ 1024;
	Run;

%Do i = 1 %To %Eval(&HierCnt);

	%Put i = &i;

	Data Work.Unique_Columns&i;
		Length Hierarchy $ 500  Description $ 1024;
		Set Work.&JSON._2(Where=(HierCnt = &i));
		By HierCnt Counter;

		If Last.HierCnt and Last.Counter;

			%Do j = 1 %To %Eval(&&Test_&i);
				%Put j = &j;
/*				Length &&Variable_Name_&i._&j  $ 250;*/

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
		Table)*/;
/*		Length Table $ 16 Hierarchy1 Swagger_Lev1 $ 250;*/
		Set Work.Schema_Columns
			Work.Unique_Columns&i;

/*			Hierarchy = (Tranwrd(Trim(Left(Hierarchy)),'items-',''));*/

/*		If Hierarchy EQ '' then Delete;*/

/*		Hierarchy1 = Trim(Left(Substr(Hierarchy, index(Hierarchy, '-D') + 1)));*/
/*		Table  = 'Swagger_Sch';*/

		Swagger_&API_DSN._Lev1 = Hierarchy;
	Run;


%End;


	Proc Sort Data = Work.Schema_Columns
		Out = OBData.&API_SCH/*(Drop = Hierarchy Rename=(Hierarchy1 = Hierarchy))*/;
		By Hierarchy;
	Run;


%Mend VarVal;
%VarVal();






Data OBData.Compare_&API_DSN(Keep = Hierarchy 
	&API_DSN._Lev1
	Swagger_&API_DSN._Lev1
	EnhancedDefinition
	Description
	Desc_Flag
	&API_DSN._MaxLength 
	&API_DSN._MinLength
	Swag_MinLength
	Swag_MaxLength
	MinLength_Flag
	MaxLength_Flag
	Swagger_Pattern
	&API_DSN._Pattern
	Pattern_Flag 
	Rename=(Description = Swagger_Desc 
	EnhancedDefinition = &API_DSN._Desc ));

	Length Hierarchy $ 500
	Swagger_&API_DSN._Lev1 $ 250
	&API_DSN._Lev1 $ 250

	Description $ 1024
	EnhancedDefinition $ 1024
	Desc_Flag $ 8

	Swag_MinLength $ 25
	&API_DSN._MinLength $ 25
	MinLength_Flag $ 8

	Swag_MaxLength $ 25
	&API_DSN._MaxLength $ 25
	MaxLength_Flag $ 8;

	Merge OBData.Swagger_&API_DSN(In=a
	Rename=(Pattern = Swagger_Pattern
	MinLength = Swag_MinLength
	MaxLength = Swag_MaxLength))

	OBdata.&API_DSN(In=b
	Rename=(Pattern = &API_DSN._Pattern
	MinLength = &API_DSN._MinLength
	MaxLength = &API_DSN._MaxLength));

	By Hierarchy;

	Where Hierarchy in ("Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitIte");

/*	If a and b then Infile = 'Both';*/
/*	If a and not b then Infile = 'Swag';*/
/*	If b and not a then Infile = 'ATM';*/

	Swagger_&API_DSN._Lev1 = Hierarchy;

*--- Find mismatches between EhancedDefinition and Description variables ---;
If Trim(Left(EnhancedDefinition)) NE Trim(Left(Description)) then 
	Do;
		Desc_Flag = 'Mismatch';
	End;
	Else Do;
		Desc_Flag = 'Match';
	End;


*--- Find mismatches between Swagger_Pattern and API_Pattern variables ---;
If Trim(Left(Swagger_Pattern)) NE '' or Trim(Left(&API_DSN._Pattern)) NE '' Then 
Do;
	If Trim(Left(Swagger_Pattern)) NE Trim(Left(&API_DSN._Pattern)) then 
	Do;
		Pattern_Flag = 'Mismatch';
	End;
	Else Do;
		Pattern_Flag = 'Match';
	End;
End;

*--- Compare the length values of the Swagger and API MinLength/MaxLength variables ---;
If Swag_MinLength NE '' or &API_DSN._MinLength NE '' Then
Do;
	If Swag_MinLength NE &API_DSN._MinLength Then
	Do;
		MinLength_Flag = 'Mismatch';
	End;
	Else Do;
		MinLength_Flag = 'Match';
	End;
End;

If Swag_MaxLength NE '' or &API_DSN._MaxLength NE '' Then
Do;
	If Swag_MaxLength NE &API_DSN._MaxLength Then
	Do;
		MaxLength_Flag = 'Mismatch';
	End;
	Else Do;
		MaxLength_Flag = 'Match';
	End;
End;

/*
If Name NE '' or Code_Name NE '' Then
Do;
	If Name NE Code_Name Then
	Do;
		CodeName_Flag = 'Mismatch';
	End;
	Else Do;
		CodeName_Flag = 'Match';
	End;
End;
*/
Run;



Proc Sort Data = OBData.Compare_&API_DSN;
	By Hierarchy;
Run;

%Mend Schema;
%Schema(http://localhost/sasweb/data/temp/json/&File..json,&API_DSN,Swagger_&API_DSN);

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


ODS _All_ Close;
/*
ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;
	Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
	Title2 "Comparison of %Sysfunc(UPCASE(&File)) UML and JSON File Structures - %Sysfunc(UPCASE(&Fdate))";

Proc Print Data = OBData.Compare_&API_DSN	;
Run;

%ReturnButton;
*/

/*ODS HTML File="C:\inetpub\wwwroot\sasweb\data\Results\&API_DSN._JSON_COMPARE_&FDate..xls";*/

/*
Proc Print Data=OBData.Compare_&API_DSN;
	Title1 "Open Banking - &API_DSN";
	Title2 "&API_DSN Comparison Report - %Sysfunc(UPCASE(&Fdate))";
Run;
*/

/*ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;*/

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
title "Listing of Product Sales"; 
*--- Set Output Delivery Parameters  ---;
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



Proc Report Data = OBData.Compare_&API_DSN nowd
	style(report)=[width=100%]
	style(report)=[rules=all cellspacing=0 bordercolor=gray] 
	style(header)=[background=lightskyblue foreground=black] 
	style(column)=[background=lightcyan foreground=black];

	Title1 "Open Banking - &API_DSN";
	Title2 "&API_DSN Comparison Report - %Sysfunc(UPCASE(&Fdate))";


	Columns Hierarchy
	Swagger_&API_DSN._Lev1
	&API_DSN._Lev1

	Swagger_Desc
	&API_DSN._Desc
	Desc_Flag

	Swag_MinLength
	&API_DSN._MinLength
	MinLength_Flag

	Swag_MaxLength
	&API_DSN._MaxLength
	MaxLength_Flag

	Swagger_Pattern
	&API_DSN._Pattern
	Pattern_Flag;


*--- Define columns in the report output ---;
	Define Hierarchy / display 'Hierarchy' left style(column)=[width=15%];
	Define Swagger_&API_DSN._Lev1 / display "Swagger &API_DSN Data Structure" left;
	Define &API_DSN._Lev1 / display "API &API_DSN Data Structure" left;

	Define Swagger_Desc / display 'Swagger Description' left;
	Define &API_DSN._Desc / display "&API_DSN Description" left;
	Define Desc_Flag / display 'Description Flag' left;

	Define Swag_MinLength / display 'Swagger Min Length' left;
	Define &API_DSN._MinLength / display "&API_DSN Min Length" left;
	Define MinLength_Flag / display 'Min Length Flag' left;

	Define Swag_MaxLength / display 'Swagger Max Length' left;
	Define &API_DSN._MaxLength / display "&API_DSN Max Length" left;
	Define MaxLength_Flag / display 'Max Length Flag' left;

	Define Swagger_Pattern / display 'Swagger Pattern' left;
	Define &API_DSN._Pattern / display "&API_DSN Pattern" left;
	Define Pattern_Flag / display 'Pattern Flag' left;

	Compute Desc_Flag;
	If Desc_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	If Desc_Flag = 'Match' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	Endcomp;

	Compute MinLength_Flag;
	If MinLength_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	If MinLength_Flag = 'Match' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	Endcomp;

	Compute MaxLength_Flag;
	If MaxLength_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	If MaxLength_Flag = 'Match' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	Endcomp;

	Compute Pattern_Flag;
	If Pattern_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	If Pattern_Flag = 'Match' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	Endcomp;

Run;
%ReturnButton;

*--- Open Output Delivery Parameters  ---;
ods tagsets.tableeditor close; 
ods listing; 


%Mend Main;
/*
%Macro SelectAPI();
%If "&_APIName" EQ "ATM" %Then
%Do;
	%Main(&_APIName,ATM);
%End;
%Else %If "&_APIName" EQ "BCH" %Then
%Do;
*--- API Config file contains BCH - change manually below to BRA ---;
	%Main(BRA,branch);
%End;
%Else %If "&_APIName" EQ "PCA" %Then
%Do;
	%Main(&_APIName,personal_current_account);
%End;
%Else %If "&_APIName" EQ "BCA" %Then
%Do;
	%Main(&_APIName,personal_current_account);
%End;
%Else %If "&_APIName" EQ "SME" %Then
%Do;
	%Main(&_APIName,personal_current_account);
%End;
%Else %If "&_APIName" EQ "CCC" %Then
%Do;
	%Main(&_APIName,personal_current_account);
%End;
%Mend SelectAPI;
%SelectAPI();
*/
/*
%Main(ATM,ATM);
%Main(BRA,branch);
*/
%Main(PCA,personal_current_account);





