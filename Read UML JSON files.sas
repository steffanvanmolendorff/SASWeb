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
      informat XPath $100. ;
      informat Name $14. ;
      informat ConstraintID $2. ;
      informat MinOccurs best32. ;
      informat MaxOccurs $9. ;
      informat Data_type $26. ;
      informat Length $1. ;
      informat MinLength $ 250. ;
      informat MaxLength $ 250. ;
      informat Pattern $20. ;
      informat Code_Name $25. ;
      informat EnhancedDefinition $1024. ;
      informat XMLTag $4. ;
      format XPath $100. ;
      format Name $14. ;
      format ConstraintID $2. ;
      format MinOccurs best12. ;
      format MaxOccurs $9. ;
      format Data_type $26. ;
      format Length $1. ;
      format MinLength $ 250. ;
      format MaxLength $ 250. ;
      format Pattern $20. ;
      format Code_Name $25. ;
      format EnhancedDefinition $1024. ;
      format XMLTag $4. ;

	  input @;

	  If Substr(Xpath,1,1) EQ '"' then
	  Do;
			_Infile_ = Tranwrd(_Infile_,',','');
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
	Length Table $ 16 Pattern Hierarchy ATM_Lev1 $ 250;
	Set Work.&Dsn;
	If XPath NE '';
	Table = "&Dsn";

	Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),16),'/','-');

	ATM_Lev1 = Hierarchy;
Run;

Proc Sort Data = OBData.&Dsn;
	By Hierarchy;
Run;

%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Temp\UML\atml_001_001_01DD.csv,ATM);


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
		Length Table $ 16 Hierarchy1 Swagger_Lev1 $ 250;
		Set Work.Schema_Columns
			Work.Unique_Columns&i;

/*			Hierarchy = (Tranwrd(Trim(Left(Hierarchy)),'items-',''));*/

/*		If Hierarchy EQ '' then Delete;*/

/*		Hierarchy1 = Trim(Left(Substr(Hierarchy, index(Hierarchy, '-D') + 1)));*/
		Table  = 'Swagger_Sch';
	Run;


%End;


	Proc Sort Data = Work.Schema_Columns
		Out = OBData.&API_SCH/*(Drop = Hierarchy Rename=(Hierarchy1 = Hierarchy))*/;
		By Hierarchy1;
	Run;


%Mend VarVal;
%VarVal();





%Mend Schema;
%Schema(http://localhost/sasweb/data/temp/json/atm.json,ATM,Swagger_SCH);

Data OBData.Compare/*(Keep = Hierarchy Table MinLength MaxLength type Class
	ATM_Lev1
	ClassLength EnhancedDefinition Description Desc_Flag UML_MaxLength UML_MinLength
	Min_Length_Flag Max_Length_Flag)*/;

	Length Table $ 16
	Infile $ 4
	Hierarchy $ 250
	Swagger_Lev1 $ 250
	ATM_Lev1 $ 250
	Description $ 1024
	EnhancedDefinition $ 1024
	Desc_Flag $ 8
	XPath $ 100 
	Codes $ 30;

	Merge OBData.Swagger_Sch(In=a)
	OBdata.ATM(In=b);

	If a and b then Infile = 'Both';
	If a and not b then Infile = 'Swag';
	If b and not a then Infile = 'ATM';

	By Hierarchy;

	Swagger_Lev1 = Hierarchy;

*--- Find mismatches between EhancedDefinition and Description variables ---;
If Trim(Left(EnhancedDefinition)) NE Trim(Left(Description)) then 
	Do;
		Desc_Flag = 'Mismatch';
	End;
	Else Do;
		Desc_Flag = 'Match';
	End;
/*
*--- Compare the length values of the Class and MinLength/MacLength variablesv ---;
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
*/
Run;



Proc Sort Data = OBData.Compare;
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
	Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
	Title2 "Comparison of UML and JSON File Structures - %Sysfunc(UPCASE(&Fdate))";

Proc Print Data = OBData.Compare;
Run;

/*%ReturnButton;*/

ODS HTML Close;
ODS Listing;
