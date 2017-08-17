

%Macro Main(GitHub_Path,Version,Bank_Name);
*--- Set X path variable to the default directory ---;
*X "cd H:\StV\Open Banking\SAS\Data\Temp";

%Let Path = C:\inetpub\wwwroot\sasweb\Data;
*--- Change directory to default location on PC to save data extracted from Google API ---;
X "CD &Path\Temp";

*--- Set the Library path where the permanent datasets will be saved ---;
Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";

*--- Assign Global Macro variable to use in all Macros in the various code sections ---;
%Global H_Num;
%Global No_Obs;
%Global API;

*--- Set the SYSTEM Error macro variable to zero ---;
%Let SYSTEM_ERROR = 0;

*--- Set system options to track comments in the log file ---;
*Options DMSSYNCHK;
Options MLOGIC MPRINT SOURCE SOURCE2 SYMBOLGEN;


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

	Length Bank_API $ 8 Var2 $ 250 Var3 $ 250 P1 - P&H_Num $ 250 ;

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
		Length Hierarchy $ 250;
	Run;

%Do i = 1 %To %Eval(&HierCnt);

	%Put i = &i;

	Data Work.Unique_Columns&i;
		Set Work.&JSON._2(Where=(HierCnt = &i));
		By HierCnt Counter;

		If Last.HierCnt and Last.Counter;

		%Let Cnt = %Eval(&&Test_&HierCnt);

			%Do j = 1 %To &Cnt;
				%Put j = &j;
				Length &&Variable_Name_&i._&j  $ 250;

				%Let Varname = %Sysfunc(Translate(&&Variable_Name_&i._&j.,' ','_'));

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
		enum1 - enum33)*/;
		Set Work.Schema_Columns
			Work.Unique_Columns&i;

			Hierarchy = (Tranwrd(Trim(Left(Hierarchy)),'items-',''));

/*		If Hierarchy EQ '' then Delete;*/
	Run;

	Proc Sort Data = Work.Schema_Columns
		Out = OBData.Schema_Output;
		By Hierarchy;
	Run;

%End;


%Mend VarVal;
%VarVal();

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
	    Put '<INPUT TYPE=hidden NAME=_WebUser VALUE="vamola@mac.com">';
	    Put '<INPUT TYPE=hidden NAME=_WebPass VALUE="Test">';
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


*--- The Header Macro inserts the OB Test Application Banner on top of the web reports ---;
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
	Put '<img src="http://localhost/sasweb/images/london.jpg" alt="Cant find image" style="width:100%;height:8%px;">';
      Put '</td>';
   Put '</tr>';
Put '</table>';
Put '</BODY>';

		Put '<p><br></p>';

Put '</HTML>';

Run;
%Mend Header;



%Macro No_Errors(Bank_Name, Version);
*=================================================================================================
						NO ERROR REPORT
==================================================================================================;

/*%Header();*/

*--- Set Output Delivery Parameters  ---;
		ODS _All_ Close;
/*
		ODS HTML Body="&Bank._&API._Body_%sysfunc(datetime(),B8601DT15.).html" 
			Contents="&Bank._&API._Contents.html" 
			Frame="&Bank._&API._Frame.html" 
			Style=HTMLBlue;
*/
  		ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;

		Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
		Title2 "%Sysfunc(UPCASE(&Bank_Name)) %Sysfunc(UPCASE(&Version)) SCHEMA DATA REPORT - %Sysfunc(UPCASE(&Fdate))";

		Proc Print Data =  OBData.Schema_Output;
		Run;

*--- Add bottom of report Menu ReturnButton code here ---;
			%ReturnButton();

			*--- Close Output Delivery Parameters  ---;
		ODS HTML Close;
		ODS Listing;	

	%Mend No_Errors;
	%No_Errors(&Bank_Name, &Version);


%Mend Schema;
%Schema(&GitHub_Path,&Version,&Bank_Name);

%Mend Main;

*====================================================================================
*				MACRO HEADER
*%Macro Main(GitHub_Path,Github_API,API_Path,Main_API,Version,Bank_Name);
*====================================================================================;
*--- COMMERCIAL-CREDIT-CARDS ---;
%Main(http://localhost/sasweb/Data/Temp/JSON/business_current_account.json,
V2,
Sch_v2);


/*
%Main(&SCH_Link,
&SCH_Name,
&API_Link,
&API_Name,
&Perm_Sch_Table,
&Version_C,
&BankName_C);


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


