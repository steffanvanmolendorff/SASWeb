/*
*===============================================================================================*
*																								*
*	Program Name: CMA9 Product Comparison V1.0													*																							*
*	Version 1.0																					*
*	Open Data APIs': PCA, BCA, SME and CCC														*
*																								*
*	During the last CMA9 Steering Committee meeting LBG raised some								*
*	concerns in relation to the interpretation of the Open Data									*
*	Data Dictionary. It was agreed that Open Banking will perform								*
*	some comparison analysis on the data fields and values present								*
*	within the CMA9 API end points.																*
*																								*
*	The SAS code below extracts information from the CMA9 Open Data API end points.				*
*																								*
*	Author: Steffan van Molendorff																*
*	Date: 27 March 2017																			*
*																								*
*	Updates - 7 April 2017:																		*
*	Version 1.1 created on 7 April 2017.														*
*	Includes an update of the ODS CSV export code. This was implemented because Proc Export		*
*	include new line characters from Excel and splits the data over multiple lines whereby the	*
*	structure of the CSV file is broken. ODS CSV functionality does a direct export of the		*
*	data in SAS to Excel/CSV.																	*
*																								*
*																								*
*	Nex Update:																					*
*																								*
*===============================================================================================;
*/
*--- Set Default Data Library as macro variable ---;
Option Source Source2 MLogic MPrint Symbolgen;
*--- Alternatively set the Data library in Proc Appsrv ---;

%Let Path = C:\inetpub\wwwroot\sasweb\Data\Perm;

*--- Set X path variable to the default directory ---;
X "cd &Path";

*--- Set the Library path where the permanent datasets will be saved ---;
Libname OBData "&Path";



*--- The Main macro will execute the code to extract data from the API end points ---;
%Macro Main(Url,Bank,Api);
 
/*Filename API Temp;*/
Filename API "&Path\API_Test.json";
 
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

Data Work.&Bank._&API
	(Keep = RowCnt Count P Bank_API Var2 Var3 P1 - P7 Value 
	Rename=(Var3 = Data_Element Var2 = Hierarchy Value = &Bank));

	Length Bank_API $ 8 Var2 Value1 Value2 $ 1000 Var3 $ 100 P1 - P7 Value $ 1000;

	RowCnt = _N_;

*--- The variable V contains the first level of the Hierarchy which has no Bank information ---;
	Set LibAPIs.Alldata(Where=(V NE 0));
*--- Create Array concatenate variables P1 to P7 which will create the Hierarchy ---;
	Array Cat{7} P1 - P7;

*--- The Do-Loop will create the Hierarchy of Level 1 to 7 (P1 - P7) ---;
Do i = 1 to P;
		If i = 1 Then 
		Do;
*--- If it is the first data field then do ---;
			Var2 = (Left(Trim(Cat{i})));
			Count = i;
		End;
*--- All subsequent data fields are concatenated to form the Hierarchy variable as in the reports ---;
		Else Do;
			Var2 = Compress(Var2||'-'||Cat{i});
			Count = i;
		End;
		Retain Var2;
	End;

	*--- Create variable to list the API value i.e. ATM or Branches ---;
	Bank_API = "&API";

*--- Extract only the last level of the Hierarchy ---;
Var3 = Reverse(Scan(Left(Trim(Reverse(Var2))),1,'-',' '));

	If "&Bank" EQ 'Bank_of_Ireland' and "&API" EQ 'CCC' Then
	Do;
		Value1 = Tranwrd(CompBl(Value),"-"," ");
		Value2 = Tranwrd(Value1,":"," ");
		Value = Value2;
		Test = 1; 
	End;

Run;

*--- Sort data by Data_Element ---;
Proc Sort Data = Work.&Bank._&API;
 By P1 - P7;
Run;

Proc Print Data = Work.&Bank._&API;
*	Where V NE 0;
Run;


%Mend Main;
*------------------------------------------------------------------------------------------------------
											PCA
-------------------------------------------------------------------------------------------------------;

%Main(https://openapi.bankofireland.com/open-banking/v1.2/personal-current-accounts,Bank_of_Ireland,PCA);
%Main(https://api.bankofscotland.co.uk/open-banking/v1.2/personal-current-accounts,Bank_of_Scotland,PCA);
%Main(https://atlas.api.barclays/open-banking/v1.3/personal-current-accounts,Barclays,PCA);
%Main(https://api.firsttrustbank.co.uk/open-banking/v1.2/personal-current-accounts,First_Trust_Bank,PCA);
%Main(https://api.halifax.co.uk/open-banking/v1.2/personal-current-accounts,Halifax,PCA);
%Main(https://api.hsbc.com/open-banking/v1.2/personal-current-accounts,HSBC,PCA);
%Main(https://api.lloydsbank.com/open-banking/v1.2/personal-current-accounts,Lloyds_Bank,PCA);
%Main(https://openapi.nationwide.co.uk/open-banking/v1.2/personal-current-accounts,Nationwide,PCA);
%Main(https://openapi.natwest.com/open-banking/v1.2/personal-current-accounts,Natwest,PCA);
%Main(https://openapi.rbs.co.uk/open-banking/v1.2/personal-current-accounts,RBS,PCA);
%Main(https://api.santander.co.uk/retail/open-banking/v1.2/personal-current-accounts,Santander,PCA);
%Main(https://openapi.ulsterbank.co.uk/open-banking/v1.2/personal-current-accounts,Ulster_Bank,PCA);
/*
%Main(https://obp-api.danskebank.com/open-banking/v1.2/personal-current-accounts,Danske_Bank,PCA);
*/


*--- Get unique Hierarchy values for PCA ---;
%Macro UniquePCA(API);
Data Work.NoDUP_CMA9_&API;
	Set Work.Bank_of_Ireland_&API
		Work.Bank_of_Scotland_&API
		Work.Barclays_&API
/*		Work.Danske_Bank_&API*/
		Work.First_Trust_Bank_&API
		Work.Halifax_&API
		Work.HSBC_&API
		Work.Lloyds_Bank_&API
		Work.Nationwide_&API
		Work.Natwest_&API
		Work.RBS_&API
		Work.Santander_&API
		Work.Ulster_Bank_&API;
	By P1-P7;
	Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OBData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniquePCA;
%UniquePCA(PCA);

*--- Append PCA Datasets ---;
Data OBData.CMA9_PCA(Drop = P1-P7);
	Merge OBData.NoDUP_CMA9_PCA
	Work.Bank_of_Ireland_PCA
	Work.Bank_of_Scotland_PCA
	Work.Barclays_PCA
/*	Work.Danske_Bank_PCA*/
	Work.First_Trust_Bank_PCA
	Work.Halifax_PCA
	Work.HSBC_PCA
	Work.Lloyds_Bank_PCA
	Work.Nationwide_PCA
	Work.Natwest_PCA
	Work.RBS_PCA
	Work.Santander_PCA
	Work.Ulster_Bank_PCA;
	By Hierarchy;
Run;

Data OBData.CMA9_PCA;
	Set OBData.CMA9_PCA;
*--- Call the macro in the Where statement to filter the required data elements ---;

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

		Put '<FORM NAME=check METHOD=get ACTION="http://localhost/scripts/broker.exe">';

		Put '<Table align="center" style="width: 100%; height: 15%" border="0">';
		Put '<tr>';
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit Name="_action" VALUE="RETURN" align="center">';
		Put '<p><br></p>';
		Put '</td>';

		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit Name="_action" VALUE="EXPORT CMA9" align="center">';
		Put '<p><br></p>';
		Put '</td>';

		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.SelectSASProgram.sas">';
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

%Macro CMA9_Reports(API);
*--- Set Output Delivery Parameters  ---;
ODS _All_ Close;

/*
ODS HTML Body="Compare_CMA9_&API..html" 
	Contents="Compare_contents_&API..html" 
	Frame="Compare_frame_&API..html" 
	Style=HTMLBlue;
*/

ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;

ODS Graphics On;

*--- Sort dataset by the RowCnt value to set the table in the original JSON script order ---; 
Proc Sort Data = OBData.CMA9_&API;
	By RowCnt;
Run;

*--- Print ATMS Report ---;
Proc Print Data = OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;


%ReturnButton();

/*
PROC EXPORT DATA = OBData.CMA9_&API(Drop=Bank_API P Count RowCnt) 
            OUTFILE= "H:\STV\Open Banking\SAS\Temp\CMA9_&API..csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
*/

*--- Close Output Delivery Parameters  ---;

/*
ODS CSV File="&Path\CMA9_&API..csv";
Proc Print Data=OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
ODS CSV Close;

ODS HTML File="&Path\CMA9_&API..xls";
Proc Print Data=OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
*/

ODS HTML;
ODS Listing;

%Mend CMA9_Reports;
%CMA9_Reports(PCA);
