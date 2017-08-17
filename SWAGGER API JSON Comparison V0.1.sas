%Global _APINamme;
/*%Let _APIName = BCA;*/

%Macro Main(API_DSN,File);
/*
Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";
Options MPrint MLogic Source Source2 Symbolgen;
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
	(Rename=(Var3 = Data_Element Var2 = Hierarchy)) Work.X1;

	Length Bank_API $ 8 Var2 $ 1000 Var3 $ 1000 P1 - P&H_Num $ 1000 Value $ 1000;

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


Data Work.&JSON Work.X2;
	Set Work.&JSON;

	Length New_Data_Element1 $ 1000;

	If Reverse(Scan(Reverse(Trim(Left(Data_Element))),1,'-')) = 'required' then Flag = 'Mandatory';
	Else Flag = 'Optional';

	Array Col{&H_Num} P1 - P&H_Num;

	Do i = 1 to P;

		If i = P then
		Do;
			New_Data_Element = Compress(Trim(Left(Data_Element))||'-'||Trim(Left(Col{i})));
*--- Remove properties- from the Data_Element variable ---;
			New_Data_Element1 = Trim(Left(Tranwrd(New_Data_Element,'properties-','')));
/*			New_Data_Element2 = Trim(Left(Tranwrd(New_Data_Element1,'items-','')));*/
*--- Remove items- from the Data_Element variable ---;
/*			New_Data_Element = New_Data_Element2;*/
		End;

	End;

/*	Data_Element = Compress(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Hierarchy,'data-',''),'properties-',''),'-enum',''),'-items',''),'-required',''),'items-',''));*/

	Data_Element = Compress(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Hierarchy,'data-',''),'properties-',''),'-enum',''),'-items',''),'-required',''));

Run;


Data Work.&JSON Work.X3(Drop = Word New_Word1 New_Word2 New_Data_Element3 New_Data_Element4 New_Data_Element6);
	Set Work.&JSON;

	Length New_Data_Element1 New_Data_Element2 New_Data_Element3 New_Data_Element4 New_Data_Element6 $ 1000;

	New_Data_Element2 = Reverse(Reverse(Trim(Left(New_Data_Element1))));
	New_Data_Element3 = Reverse(Scan(Reverse(Trim(Left(New_Data_Element1))),2,'-'));

	If New_Data_Element3 NE 'items' Then
	Do;
		New_Data_Element4 = Compress(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Hierarchy,'data-',''),'properties-',''),'-enum',''),'-items',''),'-required',''),'items-',''));
		Hierarchy = New_Data_Element4;
	End;
	Else If New_Data_Element3 EQ 'items' Then
	Do;
/*		New_Data_Element5 = Scan(Trim(Left(Reverse(New_Data_Element2))),1,'-');*/
		NWords = CountW(New_Data_Element2,'-');
		Length New_Word1 New_Word2 $ 500;
		Do i = 1 to NWords-2;
			If i = 1 Then
			Do;
      			Word = Compress(Trim(Left(Scan(New_Data_Element2,i,'-'))));
				New_Word1 = Compress(Tranwrd(Word,'items-',''));
			End;
			Else Do;
      			Word = Compress(Trim(Left(Scan(New_Data_Element2,i,'-'))));
				New_Word1 = Compress(Tranwrd(Compress(Trim(Left(New_Word1))||'-'||Word),'items-',''));
			End;
		End;


		Do i = NWords-1 to NWords;
      		Word = Compress(Trim(Left(Scan(New_Data_Element2,i,'-'))));
			New_Word2 = Compress(Compress(Trim(Left(New_Word2))||'-'||Word));
		End;

		New_Data_Element6 = Compress(New_Word1||New_Word2);
		Hierarchy = New_Data_Element6;

	End;

Run;

Proc Sort Data = Work.&JSON
	Out = Work.&JSON;
	By Hierarchy;
Run;



Data Work.&JSON/*(Drop=Hierarchy Rename=(Data_Element_1 = Hierarchy))*/ Work.X4;
	Set Work.&JSON;
	By Hierarchy;

	Length Data_Element_1 $ 1000;

	If First.Hierarchy then
	Do;
		Count = 1;
		Attribute = Reverse(Scan(Reverse(Hierarchy),1,'-'));

*--- In some instances the Hierarchy value ends with - then the first word in blank. Look then for the second word to populate the variable Attribute---;
		If Reverse(Scan(Reverse(Hierarchy),1,'-')) = '' Then
		Do;
			Attribute = Reverse(Scan(Reverse(Hierarchy),2,'-'));
		End;
/*
		If Attribute = 'required' then 
		Do;
			Hierarchy_1 = Compress(Tranwrd(Hierarchy,'required',Value));
			Data_Element_1 = Compress(Data_Element||'-'||Value);
		End;
		Else Do;
			Data_Element_1 = Data_Element;
		End;
*/
	End;
	If not First.Hierarchy then
	Do;
		Count + 1;
		Attribute = Reverse(Scan(Reverse(Hierarchy),1,'-'));

*--- In some instances the Hierarchy value ends with - then the first word in blank. Look then for the second word to populate the variable Attribute---;
		If Reverse(Scan(Reverse(Hierarchy),1,'-')) = '' Then
		Do;
			Attribute = Reverse(Scan(Reverse(Hierarchy),2,'-'));
		End;

/*
		If Attribute = 'required' then 
		Do;
			Hierarchy_1 = Compress(Tranwrd(Hierarchy,'required',Value));
			Data_Element_1 = Compress(Data_Element||'-'||Value);
		End;
		Else Do;
			Data_Element_1 = Data_Element;
		End;
*/
	End;

Run;


Proc Sort Data = Work.&JSON
	Out = Work.&JSON;
	By Hierarchy;
Run;


Data Work.&JSON Work.X5;
	Set Work.&JSON;

	By Hierarchy;

	Length Columns Columns1 $ 32 Value $ 1000;

*--- Create Mandatory flag ---;
/*If Attribute = 'required' then */
/*	Do;*/
/*		Columns = 'mandatory';*/
/*		New_Data_Element = Compress(Hierarchy||'-'||Columns); */
/*	End;*/

/*	If Attribute = 'enum' then */
/*	Do;*/
/*		Columns = Attribute;*/
/*	End;*/


*--- This step search for the first word (value) to build the Culumns variable value ---;
	If Reverse(Scan(Reverse(Trim(Left(New_Data_Element))),1,'-')) in 
		('type','description','minLength','maxLength','notes','format','additionalProperties','title','uniqueItems','pattern','minItems','mandatory',
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
		'enum101','enum102','enum103','enum104','enum105','enum106','enum107','enum108','enum109','enum110','-enum-') then
	Do;
		Columns = Reverse(Scan(Reverse(New_Data_Element),1,'-'));
	End;

*--- This step search for the first word only for Hirarchy values which have -items- after the Notes i.e. Notes-items-minLength (value)to build the Culumns variable value ---;
		If Reverse(Scan(Reverse(Trim(Left(Hierarchy))),1,'-')) in 
		('type','description','minLength','maxLength','notes','format','additionalProperties','title','uniqueItems','pattern','minItems','mandatory',
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
		'enum101','enum102','enum103','enum104','enum105','enum106','enum107','enum108','enum109','enum110','-enum-') then
	Do;
		Columns1 = Reverse(Scan(Reverse(Hierarchy),1,'-'));
		Columns = 'Items_'||Trim(Left(Columns1));
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

Data Work.&JSON Work.X6;
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
Proc Sort Data = Work.&JSON
	Out = Work.&JSON;
	By Data_Element;
Run;

Data Work.&JSON._1 Work.X7;
	Set Work.&JSON;
	By Data_Element;

	If First.Data_Element then 
	Do;
		HierCnt + 1;
		Counter = 1;
	End;
	If not First.Data_Element then 
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
Data Work.&JSON._2 Work.X8;
	Set Work.&JSON._1(Where=(Columns NE ''));
	By HierCnt Counter;

		Call Symput(Compress('Variable_Name'||'_'||Put(HierCnt,8.)||'_'||Put(Counter,8.)),Trim(Left(Columns)));
		Call Symput(Compress('Variable_Value'||'_'||Put(HierCnt,8.)||'_'||Put(Counter,8.)),Tranwrd(Trim(Left(Value)),'"',''));

/*		Call Symput(Compress('Variable_Value'||'_'||Put(HierCnt,8.)||'_'||Put(Counter,8.)),Trim(Left(Value)));*/

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
		Length Hierarchy $ 1000;
	Run;

%Do i = 1 %To %Eval(&HierCnt);

	%Put i = &i;

	Data Work.Unique_Columns&i;
		Length Hierarchy $ 1000  Description $ 1000 Items_MaxLength Items_MinLength $ 25;
		Set Work.&JSON._2(Where=(HierCnt = &i));
		By HierCnt Counter;

		If Last.HierCnt and Last.Counter;

		%Let Cnt = %Eval(&&Test_&i);
		%Put Cnt = &Cnt;

			%Do j = 1 %To &Cnt;
				%Put j = &j;

/**--- Set the length of the description variable to $1000, all other $250 else a runtime error is emcounterred ---;*/
/*				%If &&Variable_Name_&i._&j NE 'description' %Then*/
/*				%Do;*/
					Length &&Variable_Name_&i._&j  $ 250;
/*				%End;*/
/*				%Else %Do;*/
/*					Length &&Variable_Name_&i._&j  $ 1000;*/
/*				%End;*/
/*				%Let Varname = %Sysfunc(Translate(&&Variable_Name_&i._&j.,' ','_'));*/
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
		Table)*/ Work.X9;
		Length Table $ 16 Swagger_&API_DSN._Lev1 $ 1000;
		Set Work.Schema_Columns
			Work.Unique_Columns&i;

/*			Hierarchy = (Tranwrd(Trim(Left(Hierarchy)),'items-',''));*/

		If Hierarchy EQ '' then Delete;

/*		Hierarchy1 = Trim(Left(Substr(Hierarchy, index(Hierarchy, '-D') + 1)));*/
		Table  = 'Swagger_Sch';

		Swagger_&API_DSN._Lev1 = Hierarchy;
	Run;
%End;


	Proc Sort Data = Work.Schema_Columns
		Out = OBData.&API_SCH(Rename=(Hierarchy = Hierarchy_Full Data_Element = Hierarchy));
		By Data_Element;
	Run;


%Mend VarVal;
%VarVal();


%Mend Schema;
%Schema(http://localhost/sasweb/data/temp/json/&File..json,&API_DSN,Swagger_&API_DSN);

%Macro ReturnButton();
Data _Null_;
		File _Webout;

		Put '<html xmlns="http://www.w3.org/1999/xhtml">';
		Put '<head>';
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

		Put '<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>';

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
	Define style style.OBStyle;
 	notes "My Simple Style";
 	class body /
 	backgroundcolor = white
 	color = black
 	fontfamily = "Palatino";

 	Class systemtitle /
 	fontfamily = "Verdana, Arial"
 	fontsize = 16pt
 	fontweight = bold;

 	Class table /
 	backgroundcolor = #f0f0f0
 	bordercolor = red
 	borderstyle = solid
 	borderwidth = 1pt
 	cellpadding = 5pt
 	cellspacing = 0pt
 	frame = void
 	rules = groups;

 	Class header, footer /
 	backgroundcolor = #c0c0c0
 	fontfamily = "Verdana, Arial"
 	fontweight = bold;

	Class data /
 	fontfamily = "Palatino";
 	End; 
Run;

%Mend Template;
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

/*
ODS HTML File="C:\inetpub\wwwroot\sasweb\data\Results\&API_DSN._JSON_COMPARE_&FDate..xls";

Proc Print Data=OBData.Compare_&API_DSN;
	Title1 "Open Banking - &API_DSN";
	Title2 "&API_DSN Comparison Report - %Sysfunc(UPCASE(&Fdate))";
Run;

ODS HTML Close;
ODS Listing;

ODS _ALL_ Close;
*/


/*ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;*/

ods listing close; 
/*ods tagsets.tableeditor file="C:\inetpub\wwwroot\sasweb\Data\Results\Sales_Report_1.html" */
ods tagsets.tableeditor file=_Webout 
    style=styles./*meadow*/OBStyle 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="10em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ) ; 
/*
Proc Print Data=OBData.Compare_&API_DSN;
	Title1 "Open Banking - &API_DSN";
	Title2 "&API_DSN Comparison Report - %Sysfunc(UPCASE(&Fdate))";
Run;

%ReturnButton;
*/
ods tagsets.tableeditor close; 
ods listing; 


%Mend Main;

%Macro SelectAPI();
/*
	%Main(BCA,business_current_account);
	%Main(PCA,personal_current_account);
	%Main(ATM,atm);
	%Main(BCH,branch);
	%Main(SME,sme_loan);
	%Main(CCC,commercial_credit_card);
*/
	%Main(SWA,master_swagger);

%Mend SelectAPI;
%SelectAPI();
