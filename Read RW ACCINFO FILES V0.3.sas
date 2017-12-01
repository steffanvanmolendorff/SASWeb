/*
Libname OBData "C:\inetpub\wwwroot\sasweb\data\perm";

Options MPrint MLogic Symbolgen Source Source2;
*/

%Global _Host;
%Let _Host = &_SRVNAME /*localhost*/;
%Put _Host = &_Host;


%Macro Main();

%Macro AccInfo(Path,Dsn);
/**********************************************************************
*   PRODUCT:   SAS
*   VERSION:   9.4
*   CREATOR:   External File Interface
*   DATE:      19SEP17
*   DESC:      Generated SAS Datastep Code
*   TEMPLATE SOURCE:  (None Specified.)

	READ ALL CSV FILES FROM DIRECTORY PATH INTO SAS
***********************************************************************/
   Data Work.&Dsn;
   %let _EFIERR_ = 0;
   Infile "&Path.\&Dsn..csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 Termstr=CRLF;
      Informat Name $1000. ;
      Informat Occurrence $100. ;
      Informat XPath $1000. ;
      Informat EnhancedDefinition $1000. ;
      Informat Class $100. ;
      Informat Codes $25. ;
      Informat Pattern $50. ;
      Informat TotalDigits $10. ;
      Informat FractionDigits $10. ;
      Format Name $1000. ;
      Format Occurrence $100. ;
      Format XPath $1000. ;
      Format EnhancedDefinition $1000. ;
      Format Class $100. ;
      Format Codes $25. ;
      Format Pattern $50. ;
      Format TotalDigits $10. ;
      Format FractionDigits $10. ;

	  	If Substr(Xpath,1,1) EQ '"' then
	  	Do;
			_Infile_ = Tranwrd(_Infile_,',','');
	  	End;

		Input Name $
        Occurrence $
        XPath $
        EnhancedDefinition $
        Class $
        Codes $
		Pattern $
		TotalDigits $
		FractionDigits $
		;
	If _ERROR_ then call symputx('_EFIERR_',1);

	Length Filename $ 25;
	Filename = "&Dsn";
Run;

%Mend AccInfo;
%AccInfo(C:\inetpub\wwwroot\sasweb\Data\Temp\RW\ob\v1_1,OBACCOUNT);
%AccInfo(C:\inetpub\wwwroot\sasweb\Data\Temp\RW\ob\v1_1,OBBALANCE);
%AccInfo(C:\inetpub\wwwroot\sasweb\Data\Temp\RW\ob\v1_1,OBBENEFICIARY);
%AccInfo(C:\inetpub\wwwroot\sasweb\Data\Temp\RW\ob\v1_1,OBDIRECTDEBIT);
%AccInfo(C:\inetpub\wwwroot\sasweb\Data\Temp\RW\ob\v1_1,OBPRODUCT);
%AccInfo(C:\inetpub\wwwroot\sasweb\Data\Temp\RW\ob\v1_1,OBREQUEST);
%AccInfo(C:\inetpub\wwwroot\sasweb\Data\Temp\RW\ob\v1_1,OBRESPONSE);
%AccInfo(C:\inetpub\wwwroot\sasweb\Data\Temp\RW\ob\v1_1,OBSTANDINGORDER);
%AccInfo(C:\inetpub\wwwroot\sasweb\Data\Temp\RW\ob\v1_1,OBTRANSACTION);




*--- Concatenate datasets to output to perm library OBData. ---;
%Let Datasets =;
%Macro Concat(Dsn);
%If %Sysfunc(exist(&Dsn)) %Then
%Do;
%Let DSNX = &Dsn;
%Put DSNX = &DSNX;

%Let Datasets = &Datasets &DSNX;
%Put Datasets = &Datasets;
%End;
%Mend Concat;
%Concat(OBACCOUNT);
%Concat(OBBALANCE);
%Concat(OBBENEFICIARY);
%Concat(OBPRODUCT);
%Concat(OBDIRECTDEBIT);
%Concat(OBREQUEST);
%Concat(OBRESPONSE);
%Concat(OBSTANDINGORDER);
%Concat(OBTRANSACTION);

*--- Create the OBData.ATM dataset ---;
Data OBData.AccInfo_DD;
	Length Hierarchy $ 1000;
	Set &Datasets;
	Hierarchy = XPath;
	If Hierarchy NE '';

	Hierarchy = Tranwrd(Hierarchy,'/','-');

	Hierarchy_Merge = Hierarchy;

Run;

Proc Sort Data = OBData.AccInfo_DD;
	By Hierarchy_Merge;
Run;




*====================================================================================================
=								SCHEMA EXTRACT															=
=====================================================================================================;


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
Data Work.&JSON Work.X0;
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

	Length Bank_API $ 8 Var2 $ 1000 Var3 $ 1000 P1 - P&H_Num $ 50 Value $ 1000;

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


Data Work.&JSON Work.X3(Drop = Word New_Word1 New_Word2 New_Data_Element3 New_Data_Element4 
	New_Data_Element6 FindData Data1 Data2 ReadPost ReadGet);
	Set Work.&JSON;

	Length Hierarchy_GetPost New_Data_Element1 New_Data_Element2 New_Data_Element3
	New_Data_Element4 New_Data_Element6 $ 1000;

*===============================================================================================================
			THIS SECTION WILL CREATE THE RESPONSE & REQUEST HIERARCHIES FOR THE SWAGGER FILE.
			THE RESPONSE & CREATE HIERARCHIES ARE NOT SPECIFICALY LISTED IN THE SWAGGER BUT
			APPEARS AS OBJECTS WITHIN THE OTHER HIERARCHIES I.E. BALANCES OR BENEFICIARIES
================================================================================================================;

	FindData = Find(Data_Element,'Data');
	If FindData > 0 Then 
	Do;
		Data1 = Substr(Data_Element,FindData);
		Data2 = Reverse(Scan(Reverse(Data1),2,'-'));
	End;

	ReadPost = Find(Data_Element,'post');
	ReadGet  = Find(Data_Element,'get');

	If Data2 = 'Data' Then
	Do;
		If ReadPost > 0 Then 
		Do;
			Hierarchy_GetPost = Compress('OBReadRequest1-'||Data1);
		End;

		If ReadGet > 0 Then 
		Do;
			Hierarchy_GetPost = Compress('OBReadResponse1-'||Data1);
		End;
	End;
*--- END ---;

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
		Length New_Word1 New_Word2 $ 1000;
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

	Length Attribute Data_Element_1 $ 1000;

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

	Length Columns Columns1 $ 50 Value $ 1000;


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
/*%Put Test_HierCnt = &&Test_&HierCnt;*/
%Put Test_HierCnt = &Test_&HierCnt;
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

/**--- Set the length of the description variable to $1000, all other $1000 else a runtime error is emcounterred ---;*/
				%If %Sysfunc(Trim(%Sysfunc(Left(&&Variable_Name_&i._&j)))) NE 'description' %Then
				%Do;
					Length &&Variable_Name_&i._&j  $ 250;
				%End;
				%Else %Do;
					Length &&Variable_Name_&i._&j  $ 1000;
				%End;
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
		Length Table $ 16 Hierarchy $ 1000;
		Set Work.Schema_Columns
			Work.Unique_Columns&i;

/*		If Hierarchy EQ '' then Delete;*/
		Table  = "&API_SCH";

/*		Hierarchy1 = Trim(Left(Substr(Hierarchy, index(Hierarchy, '-D') + 1)));*/
/*		Hierarchy = (Tranwrd(Trim(Left(Hierarchy)),'items-',''));*/

	Run;

Data Work.Schema_Columns1(Drop = Hierarchy Rename = (Hierarchy1 = Hierarchy));
	Set Work.Schema_Columns;

	%Macro Element(Type,OBRead);
	If Find(Hierarchy,"&Type") > 0 Then
	Do;
		If Find(Hierarchy, '-Data') > 0 Then
		Do;
			Hierarchy1 = Trim(Left("&OBRead"||'-'||Trim(Left(Substr(Hierarchy, index(Hierarchy, '-D') + 1)))));
		End;
	End;
	%Mend Element;
	%Element(paths-/accounts/{AccountId},OBReadAccount1);
	%Element(paths-/balances-,OBReadBalance1);
	%Element(paths-/beneficiaries-,OBReadBeneficiary1);
	%Element(paths-/direct-debits-,OBReadDirectDebit1);
	%Element(paths-/products-,OBReadProduct1);
	%Element(paths-/standing-orders-,OBReadStandingOrder1);
	%Element(paths-/transactions-,OBReadTransaction1);

	Hierarchy_Merge = Hierarchy1;

	If Hierarchy_GetPost NE '' Then
	Do;
		Hierarchy_Merge = Hierarchy_GetPost;
	End;
Run;

%End;


	Proc Sort Data = Work.Schema_Columns1
		Out = OBData.&API_SCH;
		By Hierarchy_Merge;
	Run;


%Mend VarVal;
%VarVal();


%Mend Schema;
%Schema(http://localhost/sasweb/Data/Temp/RW/ob/v1_1/accinfo_swagger.json,AccInfo,Swagger_AccInfo);


Data Work.AccInfo_DD_SWAGGER;
	Length Hierarchy_Merge $ 1000;

	Merge OBData.Swagger_AccInfo(Keep = Hierarchy
	Hierarchy_Merge
	Description
	Pattern
	MinLength
	MaxLength
	Rename = (Pattern = Pattern_SW
	Hierarchy = Hierarchy_SW)
	In=a)

	OBData.AccInfo_DD(Keep = Hierarchy
	Hierarchy_Merge
	XPath
	EnhancedDefinition
	Class
	Pattern
	TotalDigits
	FractionDigits
	FileName
	Rename = (Pattern = Pattern_DD
	Hierarchy = Hierarchy_DD)
	In=b);

	By Hierarchy_Merge;

	If a and not b Then InFile = 'Swagger'; 
	If b and not a Then InFile = 'Account'; 
	If a and b Then InFile = 'Both';
Run;

Data Work.AccInfo_DD_SWAGGER1;
	Set Work.AccInfo_DD_SWAGGER;

*--- Exclude all Hoerarchy_Merge values which only has 1 level because the Data Dictionary
	only contains multiple Hierarchical levels ---;
	If Find(Hierarchy_Merge,'-') > 0;

*--- Select only the records from the Account file and where records merge i.e. Both ---;
*--- Beacuse the Swagger File contains all of the Code which are not in the Account File ---;
/*	If InFile in ('Account','Both');*/

*--- Validate if the Descriptions values in both files match or not ---;
	If Description NE '' or EnhancedDefinition NE '' Then
	Do;
		If Description NE EnhancedDefinition Then
		Do;
			Desc_Flag = 'Mismatch';
		End;
		Else Do;
			Desc_Flag = 'Match';
		End;
	End;


*--- Validate if the Pattern values in both files match or not ---;
	If Pattern_DD NE '' or Pattern_SW NE '' Then
	Do;
		If Pattern_DD NE Pattern_SW Then
		Do;
			Pattern_Flag = 'Mismatch';
		End;
		Else Do;
			Pattern_Flag = 'Match';
		End;
	End;

*--- Validate if the XPAth values in both files match or not ---;
	If InFile EQ 'Account' Then
	Do;
		XPath_Flag = 'Only in Data Dictionary File';
	End;
	Else If InFile EQ 'Swagger' Then
	Do;
		XPath_Flag = 'Only in Swagger File';
	End;
	Else If InFile EQ 'Both' Then
	Do;
		XPath_Flag = 'Match';
	End;

Run;



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

		Put '<script type="text/javascript" src="'"&_Path/js/jquery.js"'">';
		Put '</script>';

		Put '<link rel="stylesheet" type="text/css" href="'"&_Path/css/style.css"'">';

		Put '<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>';

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

/*
ODS _All_ Close;

Proc Print Data=Work.AccInfo_DD_SWAGGER1;
	Title1 "Open Banking - Account Information API";
	Title2 "SWAGGER vs. DATA DICTIONARY Comparison Report - %Sysfunc(UPCASE(&Fdate))";
Run;

ODS HTML Close;
ODS Listing;
*/
ODS _ALL_ Close;
ODS Listing close; 

/*ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;*/

/*ods tagsets.tableeditor file="C:\inetpub\wwwroot\sasweb\Data\Results\Sales_Report_1.html";*/
ods tagsets.tableeditor file=_Webout 
    style=styles.OBStyle 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="10em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ) ; 


Proc Report Data = Work.AccInfo_DD_SWAGGER1 nowd
	style(report)=[width=100%]
	style(report)=[rules=all cellspacing=0 bordercolor=gray] 
	style(header)=[background=lightskyblue foreground=black] 
	style(column)=[background=lightcyan foreground=black];

	Title1 "Open Banking - Account Information API";
	Title2 "SWAGGER vs. DATA DICTIONARY Comparison Report - %Sysfunc(UPCASE(&Fdate))";

	Columns Hierarchy_Merge
	Hierarchy_DD
	Hierarchy_SW
	InFile
	XPath_Flag
	EnhancedDefinition
	Description
	Desc_Flag
	Pattern_DD
	Pattern_SW
	Pattern_Flag
	;


*--- Define columns in the report and associated parameters for output ---;
	Define Hierarchy_Merge / display 'Hierarchy Merge' left style(column)=[width=5%];
	Define Hierarchy_SW / display "Hierarchy SW" left;
	Define Hierarchy_DD / display 'Hierarchy DD' left style(column)=[width=15%];
	Define INFile / display "In File" left;
	Define XPath_Flag / display "XPath Flag" left;

	Define Description / display 'Description SW' left;
	Define EnhancedDefinition / display "Description DD" left;
	Define Desc_Flag / display 'Description Flag' left;

	Define Pattern_SW / display "Pattern SW" left;
	Define Pattern_DD / display 'Pattern DD' left;
	Define Pattern_Flag / display 'Pattern Flag' left;

*--- Based on the values of Desc_Flag variable change the style/colour parameters within the report ---;
	Compute XPath_Flag;
	If XPath_Flag = 'Only in Data Dictionary File' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	If XPath_Flag = 'Match' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	If XPath_Flag = 'Only in Swagger File' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=yellow background=pink font_weight=bold]");
	End;
	Endcomp;

*--- Based on the values of Desc_Flag variable change the style/colour parameters within the report ---;
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

*--- Based on the values of Pattern_Flag variable change the style/colour parameters within the report ---;
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
/*
*--- Export file to Directory - CSV ---;
Proc Export Data = Work.AccInfo_DD_SWAGGER1
	(Keep = Hierarchy_Merge
	Hierarchy_DD
	Hierarchy_SW
	InFile
	XPath_Flag
	EnhancedDefinition
	Description
	Desc_Flag
	Pattern_DD
	Pattern_SW
	Pattern_Flag)

	Outfile = "C:\inetpub\wwwroot\sasweb\Data\Results\AccInfo_SW_DD_Comparison_Final.csv"

	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;
*/
ODS CSV File="C:\inetpub\wwwroot\sasweb\data\results\AccInfo_SW_DD_Comparison_Final.csv";
Proc Print Data=Work.AccInfo_DD_SWAGGER1;
	Title1 "OPEN BANKING - &API";
	Title2 "ACCOUNT INFORMATION DATA STRUCTURE REPORT - &Fdate";
Run;
ODS CSV Close;


/*
FILENAME Mailbox EMAIL "&_WebUser" emailid = "Microsoft Outlook"
Subject='Test Mail message' ATTACH="C:\inetpub\wwwroot\sasweb\Data\Results\AccInfo_SW_DD_Comparison_Final.csv";
DATA _NULL_;
FILE Mailbox;
PUT "Hello";
PUT "Please find Report as an attachment";
PUT "Thank you";
RUN;
*/


/*
%Macro SendMail();

*Options Emailhost="smtp.123-reg.co.uk" 
	EmailId="steffan@vanmolendorff.com" 
	Emailpw="@Octa7700";

FILENAME Thunder EMAIL To=("&_WebUser")
	CC="steffan@vanmolendorff.com"
	Sender="steffan van Molendorff"
	EmailID="steffan@vanmolendorff.com"
 	Subject = "An automatic email sent from SAS"
	ATTACH="C:\inetpub\wwwroot\sasweb\data\Results\ACC_INFO_DD_SWAGGER_COMPARISON_&FDate..xls"; 

Data _Null_; 
   File Thunder; 
   put " "; 
   put "Read/Write Account Information API"; 
   put " "; 
   put "Data Dictionry vs. Swagger Comparison Report"; 
   put " "; 
   put "Please Review Mismatched in (Desc_Flag / Pattern_Flag / XPath_Flag) columns"; 
   put " "; 
   put "For any queries contact:"; 
   put " "; 
   put "Steffan van Molendorff"; 
run;

%Mend SendMail;
%SendMail();
*/
%ReturnButton;

ods tagsets.tableeditor close; 
ods listing; 


%Mend Main;
%Main();
