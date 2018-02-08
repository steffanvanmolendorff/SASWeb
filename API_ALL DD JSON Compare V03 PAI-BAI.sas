*--- Uncomment to run locally on laptop ---;

%Global _APINamme;
%Global _APIVersion;
%Global _SRVNAME;
%GLOBAL _Host;
/*
%Let _SRVNAME = localhost;
%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _APIName = PAI;
%Let _APIVersion = V2_2;
*/
%Global _Host;
%Global _Path;

%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

%Macro Main(API_DSN,File);

Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";
Options MPrint MLogic Source Source2 Symbolgen;

%Macro Import(Filename,Dsn);
/**********************************************************************
*   PRODUCT:   SAS
*   VERSION:   9.4
*   CREATOR:   External File Interface
*   DATE:      22JUN17
*   DESC:      Generated SAS Datastep Code
*   TEMPLATE SOURCE:  (None Specified.)
***********************************************************************/
     data OBData.&Dsn;
     %let _EFIERR_ = 0; 
     infile "&Filename" delimiter = ','
  	MISSOVER DSD lrecl=32767 firstobs=2 Termstr=CRLF;
        informat XPath $1000. ;
        informat FieldName $91. ;
        informat ConstraintID $25. ;
        informat MinOccurs best32. ;
        informat MaxOccurs $9. ;
        informat DataType $50. ;
        informat Length $5. ;
        informat MinLength $25. ;
        informat MaxLength $25. ;
        informat Pattern $250. ;
        informat CodeName $1000. ;
        informat CodeDescription $1000. ;
        informat EnhancedDefinition $1000. ;
        informat XMLTag $25. ;
        format XPath $1000. ;
        format FieldName $91. ;
        format ConstraintID $25. ;
        format MinOccurs best12. ;
        format MaxOccurs $9. ;
        format DataType $50. ;
        format Length $5. ;
        format MinLength $25. ;
        format MaxLength $25. ;
        format Pattern $250. ;
        format CodeName $1000. ;
        format CodeDescription $1000. ;
        format EnhancedDefinition $1000. ;
        format XMLTag $25. ;

		If Substr(Xpath,1,1) EQ '"' then
	  	Do;
			_Infile_ = Tranwrd(_Infile_,',','');
	  	End;

     input
                 XPath $
                 FieldName $
                 ConstraintID $
                 MinOccurs
                 MaxOccurs $
                 DataType $
                 Length $
                 MinLength
                 MaxLength
                 Pattern $
                 CodeName $
                 CodeDescription $
                 EnhancedDefinition $
                 XMLTag $
     ;
     if _ERROR_ then call symputx('_EFIERR_',1);  
     run;


Data OBData.&Dsn/*(Drop = Hierarchy Position Want Rename=(Hierarchy1 = Hierarchy))*/;
	Length Pattern Hierarchy $ 1000 &DSN._Lev1 $ 1000;
	Set OBData.&Dsn;

	If XPath NE '';

	If "&Dsn" EQ "BCH" Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),19),'/','-');
	End;
	Else If "&Dsn" EQ "SME" Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),20),'/','-');
	End;
	Else If "&Dsn" EQ "&_APIName" Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),21),'/','-');
	End;

	&DSN._Lev1 = Compress(/*'Brand-'||*/Hierarchy);

*--- Delete the Hierarchy records which list the Mnemonics codes as the Swagger file does not have the Hierarchy values with Mnemonics ---;
	Mnemonics = Substr(Reverse(Trim(Left(Hierarchy))),5,1);
	If Mnemonics NE ':';
	If &DSN._Lev1 NE '';

*--- Remove double quotes from the EnhancedDefinition column to ensure these type of mismatches are suppressed in the reports ---;
	EnhancedDefinition = Tranwrd(EnhancedDefinition,'"','');

Run;

*--- Include this step to change the \\ to \ to match the data in the Swagger File ---;
	Data OBData.&Dsn(Drop = Pattern Rename=(Pattern1 = Pattern));
		Set OBData.&Dsn;
	
		If Trim(Left(Pattern)) NE '' Then
		Do;
			Pattern1 = Tranwrd(Trim(Left(Pattern)),"\\","\");
		End;
		Else Do;
			Pattern1 = Pattern;
		End;
		
	Run;

*--- Extract the data structure for PCA only from PCA- onwards to match Schema structure ---;
	Data OBData.&Dsn;
		Set OBData.&Dsn;
		If Find(Hierarchy,"&API_DSN") > 0 Then
		Do;
			Hierarchy = Substr(Hierarchy,Find(Hierarchy,"&API_DSN"));
		End;
		Else Do;
			If Find(Hierarchy,"&API_DSN") = 0 Then Delete;
		End;
	Run;

Proc Sort Data = OBData.&Dsn
	Out = OBData.API_&Dsn.;
	By Hierarchy;
Run;

%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Temp\od\ob\&_APIVersion\&API_DSN.l_001_001_01DD.csv,&API_DSN);


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
Data Work.&JSON OBData.X;
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
	(Rename=(Var3 = Data_Element Var2 = Hierarchy)) OBData.&JSON._SWA;

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


Data Work.&JSON OBData.X2;
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
		End;

	End;

	Data_Element = Compress(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Tranwrd(Hierarchy,'data-',''),'properties-',''),'-enum',''),'-items',''),'-required',''));

Run;


Data Work.&JSON OBData.X3(Drop = Word New_Word1 New_Word2 New_Data_Element3 New_Data_Element4 New_Data_Element6);
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



Data Work.&JSON/*(Drop=Hierarchy Rename=(Data_Element_1 = Hierarchy))*/ OBData.X4;
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

	End;

Run;


Proc Sort Data = Work.&JSON
	Out = Work.&JSON;
	By Hierarchy;
Run;


Data Work.&JSON OBData.X5;
	Set Work.&JSON;

	By Hierarchy;

	Length Columns Columns1 $ 32 Value $ 1000;


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

Data Work.&JSON OBData.X6;
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

Data Work.&JSON._1 OBData.X7;
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
Data Work.&JSON._2 OBData.X8;
	Set Work.&JSON._1(Where=(Columns NE ''));
	By HierCnt Counter;

		Call Symput(Compress('Variable_Name'||'_'||Put(HierCnt,8.)||'_'||Put(Counter,8.)),Trim(Left(Columns)));
		Call Symput(Compress('Variable_Value'||'_'||Put(HierCnt,8.)||'_'||Put(Counter,8.)),Tranwrd(Trim(Left(Value)),'"',''));

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
				Length &&Variable_Name_&i._&j  $ 250;
				%Let Varname = &&Variable_Name_&i._&j.;

				&Varname = "&&Variable_Value_&i._&j.";
			%End;
	Run;


	Data Work.Schema_Columns(Drop = Hierarchy Rename=(Hier = Hierarchy))OBData.X9;
		Length Table $ 16 Swagger_&API_DSN._Lev1 $ 1000;
		Set Work.Schema_Columns
			Work.Unique_Columns&i;

		Table  = 'Swagger_Sch';

*--- Select the data structure from Brand ---;
		Hier = Substr(Hierarchy,find(Hierarchy,"&API_DSN"));
*--- Select the data structure from PCA ---;
		If Reverse(Substr(Reverse(Trim(Left(Hier))),1,11)) = '-items-type' then
		Do;
			Hier = Reverse(Substr(Reverse(Trim(Left(Hier))),12));
		End;

	Run;

%End;


	Proc Sort Data = Work.Schema_Columns
		Out = OBData.&API_SCH;
		By Hierarchy;
	Run;


%Mend VarVal;
%VarVal();

Data OBData.Compare_&API_DSN(Keep = Hierarchy 
	&API_DSN._Lev1
	Swagger_&API_DSN._Lev1
	Name
	CodeDescription
	EnhancedDefinition
	Description
	Desc_Flag
	&API_DSN._MaxLength 
	&API_DSN._MinLength
	Swag_MinLength
	Swag_MaxLength
	Items_MinLength
	Items_MaxLength
	MinLength_Flag
	MaxLength_Flag
	Swagger_Pattern
	&API_DSN._Pattern
	Items_Pattern
	Pattern_Flag
	Flag
	CountRows
	Code
	CodeName
	CodeName_Flag
	CodeNameDesc_Flag
	Rename=(Description = Swagger_Desc
	CodeDescription = &API_DSN._Desc
	Flag = Mandatory_Flag));

	Length Hierarchy $ 1000
	Swagger_&API_DSN._Lev1 $ 1000
	&API_DSN._Lev1 $ 1000
	Flag $ 9

	Description $ 1000
	CodeDescription $ 1000
	Desc_Flag $ 8

	Code $ 1000
	CodeName $ 1000
	CodeName_Flag $ 8

	Name $ 1000
	CodeDescription $ 1000
	CodeNameDesc_Flag $ 8

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

	OBdata.API_&API_DSN(In=b
	Rename=(Pattern = &API_DSN._Pattern
	MinLength = &API_DSN._MinLength
	MaxLength = &API_DSN._MaxLength));

	By Hierarchy;

	Format Swag_MinLength $25.
	&API_DSN._MinLength $25.
	Swag_MinLength $25.
	&API_DSN._MinLength $25.;

	Informat Swag_MinLength $25.
	&API_DSN._MinLength $25.
	Swag_MinLength $25.
	&API_DSN._MinLength $25.;

	Swagger_&API_DSN._Lev1 = Hierarchy;

*--- Find mismatches between EhancedDefinition and Description variables ---;
If Substr(Reverse(Trim(Left(Hierarchy))),5,1) NE ':' Then
Do;
	If EnhancedDefinition NE Description then 
	Do;
		Desc_Flag = 'Mismatch';
	End;
	Else Do;
		Desc_Flag = 'Match';
	End;

End;

*--- Find mismatches between EhancedDefinition and Description variables ---;
If Substr(Reverse(Trim(Left(Hierarchy))),5,1) EQ ':' Then
Do;
If Trim(Left(Code)) NE Trim(Left(CodeName)) then 
	Do;
		CodeName_Flag = 'Mismatch';
	End;
	Else Do;
		CodeName_Flag = 'Match';
	End;
End;

*--- Find mismatches between EhancedDefinition and Description variables ---;
If Substr(Reverse(Trim(Left(Hierarchy))),5,1) EQ ':' Then
Do;
If Trim(Left(Name)) NE Trim(Left(CodeDescription)) then 
	Do;
		CodeNameDesc_Flag = 'Mismatch';
	End;
	Else Do;
		CodeNameDesc_Flag = 'Match';
	End;
End;


*--- If Swagger_Pattern is missing and Items_Pattern is not missing set Swagger_Pattern = Items_Pattern ---
*--- This is to ensure that there are no missing Swagger_Pattern values in the output report when
	creating the comparison between Pattern values of the SWAGGER and API datasets ---;
If Trim(Left(Items_Pattern)) NE '' and Swagger_Pattern EQ '' Then 
Do;
	*--- This line will ensure that there are no decimal points in the Swagger_Pattern value in the report
		id the Items_Pattern value is missing. ---;
	If Trim(Left(Items_Pattern)) = '.' then Items_Pattern = '';

	Swagger_Pattern = Items_Pattern;

	*--- This line will ensure that there are no decimal points in the Swagger_Pattern value in the report
		id the Items_Pattern value is missing. ---;
	If Trim(Left(Swagger_Pattern)) = '.' then Swagger_Pattern = '';
End;

*--- Find mismatches between Swagger_Pattern and API_Pattern variables ---;
If Trim(Left(Swagger_Pattern)) NE '' or Trim(Left(&API_DSN._Pattern)) NE '' Then 
Do;
	If Trim(Left(Swagger_Pattern)) = '.' then Swagger_Pattern = '';

	If Trim(Left(Swagger_Pattern)) NE Trim(Left(&API_DSN._Pattern)) then 
	Do;
		Pattern_Flag = 'Mismatch';
	End;
	Else Do;
		Pattern_Flag = 'Match';
	End;
End;


*--- Set Swagger MaxLenngth value equal to Items_maxLength if Items_MaxLength is not missing in order to use only 1 variable in Proc Report ---;
	If Items_MaxLength NE '' then Swag_MaxLength = Trim(Left(Items_MaxLength));
	If Items_MinLength NE '' then Swag_MinLength = Trim(Left(Items_MinLength));

*--- Compare the length values of the Swagger and API MinLength/MaxLength variables ---;
If Swag_MinLength NE '' or &API_DSN._MinLength NE '' Then
Do;
	If Trim(Left(Swag_MinLength)) NE Trim(Left(&API_DSN._MinLength)) Then
	Do;
		MinLength_Flag = 'Mismatch';
	End;
	Else Do;
		MinLength_Flag = 'Match';
	End;
End;

If Swag_MaxLength NE '' or &API_DSN._MaxLength NE '' Then
Do;
	If Trim(Left(Swag_MaxLength)) NE Trim(Left(&API_DSN._MaxLength)) Then
	Do;
		MaxLength_Flag = 'Mismatch';
	End;
	Else Do;
		MaxLength_Flag = 'Match';
	End;
End;

	CountRows = _N_;
Run;



Proc Sort Data = OBData.Compare_&API_DSN;
	By Hierarchy;
Run;

%Mend Schema;
%Schema(http://&_Host/sasweb/data/temp/od/ob/&_APIVersion/&File..json,&API_DSN,Swagger_&API_DSN);

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
 	Define style Style.Sasweb;
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
    style=Styles.SASWeb
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="10em" 
 	    autofilter_endcol= "50" 
            frozen_headers="1" 
            frozen_rowheaders="1" 
            ) ; 


Proc Report Data = OBData.Compare_&API_DSN nowd;

	Title1 "Open Banking - &_APIName";
	Title2 "&_APIName &_APIVersion Comparison Report - %Sysfunc(UPCASE(&Fdate))";
	Title3 "&File";


	Columns CountRows
	Hierarchy
	Swagger_&API_DSN._Lev1
	&API_DSN._Lev1
	Mandatory_Flag

	Swagger_Desc
	EnhancedDefinition
	Desc_Flag

/*	Code*/
/*	CodeName*/
/*	CodeName_Flag*/
/**/
/*	Name*/
/*	CodeDescription*/
/*	CodeNameDesc_Flag*/

	Swag_MinLength
	&API_DSN._MinLength
	MinLength_Flag

	Swag_MaxLength
	&API_DSN._MaxLength
	MaxLength_Flag

	Swagger_Pattern
	&API_DSN._Pattern
	Pattern_Flag
	;


*--- Define columns in the report and associated parameters for output ---;
	Define CountRows / display 'Row Count' left/* style(column)=[width=5%]*/;
	Define Hierarchy / display 'Hierarchy' left/* style(column)=[width=15%]*/;
/*	Define Hierarchy / display 'Hierarchy' left style(column)= Styles.SASWeb;*/
	Define Swagger_&API_DSN._Lev1 / display "Swagger &API_DSN Data Structure" left;
	Define &API_DSN._Lev1 / display "API &API_DSN Data Structure" left;
	Define Mandatory_Flag / display "Mandatory Flag" left;

	Define Swagger_Desc / display 'Swagger Description' left;
	Define EnhancedDefinition / display "&API_DSN DD Description" left;
	Define Desc_Flag / display 'Description Flag' left;

/*	Define Code / display 'Swagger Code' left;*/
/*	Define CodeName / display "&API_DSN Code" left;*/
/*	Define CodeName_Flag / display 'Code Name Flag' left;*/
/**/
/*	Define Name / display 'Swagger Code Desc' left;*/
/*	Define CodeDescription / display "&API_DSN Code Desc" left;*/
/*	Define CodeNameDesc_Flag / display 'Code Name Desc Flag' left;*/

	Define Swag_MinLength / display 'Swagger Min Length' left;
	Define &API_DSN._MinLength / display "&API_DSN DD Min Length" left;
	Define MinLength_Flag / display 'Min Length Flag' left;

	Define Swag_MaxLength / display 'Swagger Max Length' left;
	Define &API_DSN._MaxLength / display "&API_DSN DD Max Length" left;
	Define MaxLength_Flag / display 'Max Length Flag' left;

	Define Swagger_Pattern / display 'Swagger Pattern' left;
	Define &API_DSN._Pattern / display "&API_DSN DD Pattern" left;
	Define Pattern_Flag / display 'Pattern Flag' left;

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

/*	Compute CodeName_Flag;*/
/*	If CodeName_Flag = 'Mismatch' then */
/*	Do;*/
/*		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");*/
/*	End;*/
/*	If CodeName_Flag = 'Match' then */
/*	Do;*/
/*		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");*/
/*	End;*/
/*	Endcomp;*/
/**/
/*	Compute CodeNameDesc_Flag;*/
/*	If CodeNameDesc_Flag = 'Mismatch' then */
/*	Do;*/
/*		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");*/
/*	End;*/
/*	If CodeNameDesc_Flag = 'Match' then */
/*	Do;*/
/*		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");*/
/*	End;*/
/*	Endcomp;*/


*--- Based on the values of MinLength_Flag variable change the style/colour parameters within the report ---;
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

*--- Based on the values of MaxLength_Flag variable change the style/colour parameters within the report ---;
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

Proc Export Data = OBData.Compare_&API_DSN
	(Keep = CountRows
	Hierarchy
	Swagger_&API_DSN._Lev1
	&API_DSN._Lev1
	Mandatory_Flag

	Swagger_Desc
	EnhancedDefinition
	Desc_Flag

	Swag_MinLength
	&API_DSN._MinLength
	MinLength_Flag

	Swag_MaxLength
	&API_DSN._MaxLength
	MaxLength_Flag

	Swagger_Pattern
	&API_DSN._Pattern
	Pattern_Flag)

	Outfile = "C:\inetpub\wwwroot\sasweb\Data\Results\&File._DD_Comparison_Final.csv"

	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;

%ReturnButton;

ods tagsets.tableeditor close; 
ods listing; 


/*%Include "C:\inetpub\wwwroot\sasweb\source\Swagger DD CodeName Comparison V0.1.sas";*/


%Mend Main;

%Macro SelectAPI();
%If "&_Swagger" EQ "SWAGGER" %Then
%Do;
	%If "&_APIName" EQ "BCA" %Then
	%Do;
		%Main(&_APIName,bca_swagger);
	%End;
	%Else %If "&_APIName" EQ "PCA" %Then
	%Do;
		%Main(&_APIName,pca_swagger);
	%End;
	%Else %If "&_APIName" EQ "ATM" %Then
	%Do;
		%Main(&_APIName,atm_swagger);
	%End;
	%Else %If "&_APIName" EQ "BCH" %Then
	%Do;
		%Main(&_APIName,branch_swagger);
	%End;
	%Else %If "&_APIName" EQ "SME" %Then
	%Do;
		%Main(&_APIName,sme_loan_swagger);
	%End;
	%Else %If "&_APIName" EQ "CCC" %Then
	%Do;
		%Main(&_APIName,ccc_swagger);
	%End;
	%Else %If "&_APIName" EQ "PAI" %Then
	%Do;
		%Let _APIName = PCA;
		%Main(&_APIName,pca_swagger);
	%End;
	%Else %If "&_APIName" EQ "BAI" %Then
	%Do;
		%Let _APIName = BCA;
		%Main(&_APIName,bca_swagger);
	%End;

%End;
%Else %Do;
	%If "&_APIName" EQ "BCA" %Then
	%Do;
		%Main(&_APIName,business_current_account);
	%End;
	%Else %If "&_APIName" EQ "PCA" %Then
	%Do;
		%Main(&_APIName,personal_current_account);
	%End;
	%Else %If "&_APIName" EQ "ATM" %Then
	%Do;
		%Main(&_APIName,atm);
	%End;
	%Else %If "&_APIName" EQ "BCH" %Then
	%Do;
		%Main(&_APIName,branch);
	%End;
	%Else %If "&_APIName" EQ "SME" %Then
	%Do;
		%Main(&_APIName,sme_loan);
	%End;
	%Else %If "&_APIName" EQ "CCC" %Then
	%Do;
		%Main(&_APIName,commercial_credit_card);
	%End;
	%Else %If "&_APIName" EQ "PAI" %Then
	%Do;
		%Let _APIName = PCA;
		%Main(&_APIName,personal_current_account);
	%End;
	%Else %If "&_APIName" EQ "BAI" %Then
	%Do;
		%Let _APIName = BCA;
		%Main(&_APIName,business_current_account);
	%End;
%End;
%Mend SelectAPI;
%SelectAPI();




