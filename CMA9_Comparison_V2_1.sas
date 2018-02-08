/*===============================================================================================*
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
*===============================================================================================;*/
*--- Set Program Options ---;
/*Option Source Source2 MLogic MPrint Symbolgen;*/
Options NOERRORABEND;

%Global _action;
%Global ErrorCode;
%Global ErrorDesc;
%Global Datasets;
%Global _P_Val;

/*%Let _SRVNAME = localhost;*/
%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

*--- Un-comment this section to run program locally from Desktop ---;
/*%Let _action = CMA9 COMPARISON ATMS;*/

*--- Set Default Data Library as macro variable ---;
*--- Alternatively set the Data library in Proc Appsrv ---;
/*
%Let Path = C:\inetpub\wwwroot\sasweb\Data\Perm;

*--- Set X path variable to the default directory ---;
X "cd &Path";

*--- Set the Library path where the permanent datasets will be saved ---;
Libname OBData "&Path";
*/

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


*--- The Main macro will execute the code to extract data from the API end points ---;
%Macro Main(Url,Bank,Api);
 
Filename API Temp;

*--- Proc HTTP assigns the GET method in the URL to access the data ---;
Proc HTTP
	Url = "&Url."
 	Method = "GET"
 	Out = API;
%ErrorCheck;

Data _Null_;
	Sleeptime = Sleep(5);
Run;

*--- The JSON engine will extract the data from the JSON script ---; 
Options ERRORCHECK=NORMAL;
Libname LibAPIs JSON Fileref=API;
%ErrorCheck;

*--- Proc datasets will create the datasets to examine resulting tables and structures ---;
Proc Datasets Lib = LibAPIs; 
%ErrorCheck;

Data Work.&Bank._&API._Sort(Keep = P);
	Set LibAPIs.Alldata(Where=(V NE 0));
Run;

Proc Sort Data = Work.&Bank._&API._Sort;
	By Decending P;
Run;

Data _Null_;
	Set Work.&Bank._&API._Sort(Obs = 1);
	Call Symput('_P_Val',Trim(Left(Put(P,3.))));
Run;

Data Work.&Bank._&API
	(Keep = RowCnt Count P Bank_API Var2 Var3 P1 - P&_P_Val Value 
	Rename=(Var3 = Data_Element Var2 = Hierarchy Value = &Bank));

	Length Bank_API $ 8 Var2 Value1 Value2 $ 250 Var3 $ 100 P1 - P&_P_Val Value $ 300;

	RowCnt = _N_;

*--- The variable V contains the first level of the Hierarchy which has no Bank information ---;
	Set LibAPIs.Alldata(Where=(V NE 0));
*--- Create Array concatenate variables P1 to P&_P_Val which will create the Hierarchy ---;
	Array Cat{&_P_Val} P1 - P&_P_Val;

*--- The Do-Loop will create the Hierarchy of Level 1 to 7 (P1 - P&_P_Val) ---;
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
%ErrorCheck;

Proc Sort Data = Work.&Bank._&API;
	By P1-P&_P_Val;
Run;


/*Proc Print Data = Work.&Bank._&API;*/
/**	Where V NE 0;*/
/*Run;*/

%Mend Main;

%Macro RunAPI();
*------------------------------------------------------------------------------------------------------
											ATMS
-------------------------------------------------------------------------------------------------------;
%If "&_action" EQ "CMA9 COMPARISON ATMS" %Then
%Do;
/*	%If %sysfunc(fileexist(https://openapi.bankofireland.com/open-banking/v2.1/atms)) %Then*/
/*	%Do;*/
		%Main(https://openapi.bankofireland.com/open-banking/v2.1/atms,Bank_of_Ireland,ATM);
/*	%End;*/
	%Main(https://api.bankofscotland.co.uk/open-banking/v2.1/atms,Bank_of_Scotland,ATM);
	%Main(https://atlas.api.barclays/open-banking/v2.1/atms,Barclays,ATM);
	%Main(https://obp-data.danskebank.com/open-banking/v2.1/atms,Danske_Bank,ATM);
	%Main(https://openapi.firsttrustbank.co.uk/open-banking/v2.1/atms,First_Trust_Bank,ATM);
	%Main(https://api.halifax.co.uk/open-banking/v2.1/atms,Halifax,ATM);
	%Main(https://api.hsbc.com/open-banking/v2.1/atms,HSBC,ATM);
	%Main(https://api.lloydsbank.com/open-banking/v2.1/atms,Lloyds_Bank,ATM);
	%Main(https://openapi.nationwide.co.uk/open-banking/v2.1/atms,Nationwide,ATM);
	%Main(https://openapi.natwest.com/open-banking/v2.1/atms,Natwest,ATM);
	%Main(https://openapi.rbs.co.uk/open-banking/v2.1/atms,RBS,ATM);
	%Main(https://openbanking.santander.co.uk/sanuk/external/open-banking/v2.1/atms,Santander,ATM);
	%Main(https://openapi.ulsterbank.co.uk/open-banking/v2.1/atms,Ulster_Bank,ATM);
%End;

*--- Find unique Hierarchy values for ATMS ---;
%Macro UniqueATM(API);

	%Let Datasets =;
	%Macro TestDsn(DsName);
		%If %Sysfunc(exist(&DsName)) %Then
		%Do;
			%Let DSNX = &DsName;
			%Put DSNX = &DSNX;

			%Let Datasets = &Datasets &DSNX;
			%Put Datasets = &Datasets;
		%End;
	%Mend TestDsn;
	%TestDsn(Bank_of_Ireland_&API);
	%TestDsn(Bank_of_Scotland_&API);
	%TestDsn(Barclays_&API);
	%TestDsn(Danske_Bank_&API);
	%TestDsn(First_Trust_Bank_&API);
	%TestDsn(Halifax_&API);
	%TestDsn(HSBC_&API);
	%TestDsn(Lloyds_Bank_&API);
	%TestDsn(Nationwide_&API);
	%TestDsn(Natwest_&API);
	%TestDsn(RBS_&API);
	%TestDsn(Santander_&API);
	%TestDsn(Ulster_Bank_&API);

	Data Work.NoDUP_CMA9_&API;
		Set &Datasets;
	Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OBData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniqueATM;
%If "&_action" EQ "CMA9 COMPARISON ATMS" %Then
%Do;
%UniqueATM(ATM);
%End;

%If "&_action" EQ "CMA9 COMPARISON ATMS" %Then
%Do;

*--- Append ATMS Datasets ---;
Data OBData.CMA9_ATM(Drop = P1-P7);

	Merge OBData.NoDUP_CMA9_ATM
	&Datasets;

	By Hierarchy;

*--- Call the macro in the Where statement to filter the required data elements ---;
*	Where Data_Element in (%Filter);

Run;
%End;
*------------------------------------------------------------------------------------------------------
											BRANCHES
-------------------------------------------------------------------------------------------------------;
%If "&_action" EQ "CMA9 COMPARISON BRANCHES" %Then
%Do;
/*	%If %sysfunc(fileexist(https://openapi.bankofireland.com/open-banking/v2.1/branches)) %Then */
/*	%Do;*/
	%Main(https://openapi.bankofireland.com/open-banking/v2.1/branches,Bank_of_Ireland,BCH);
/*	%End;*/
	%Main(https://api.bankofscotland.co.uk/open-banking/v2.1/branches,Bank_of_Scotland,BCH);
	%Main(https://atlas.api.barclays/open-banking/v2.1/branches,Barclays,BCH);
	%Main(https://obp-data.danskebank.com/open-banking/v2.1/branches,Danske_Bank,BCH);
	%Main(https://openapi.firsttrustbank.co.uk/open-banking/v2.1/branches,First_Trust_Bank,BCH);
	%Main(https://api.halifax.co.uk/open-banking/v2.1/branches,Halifax,BCH);
	%Main(https://api.hsbc.com/open-banking/v2.1/branches,HSBC,BCH);
	%Main(https://api.lloydsbank.com/open-banking/v2.1/branches,Lloyds_Bank,BCH);
	%Main(https://openapi.nationwide.co.uk/open-banking/v2.1/branches,Nationwide,BCH);
	%Main(https://openapi.natwest.com/open-banking/v2.1/branches,Natwest,BCH);
	%Main(https://openapi.rbs.co.uk/open-banking/v2.1/branches,RBS,BCH);
	%Main(https://openbanking.santander.co.uk/sanuk/external/open-banking/v2.1/branches,Santander,BCH);
	%Main(https://openapi.ulsterbank.co.uk/open-banking/v2.1/branches,Ulster_Bank,BCH);
%End;

*--- Get unique Hierarchy values for Branches ---;
%Macro UniqueBRANCHES(API);


	%Let Datasets =;
	%Macro TestDsn(DsName);
		%If %Sysfunc(exist(&DsName)) %Then
		%Do;
			%Let DSNX = &DsName;
			%Put DSNX = &DSNX;

			%Let Datasets = &Datasets &DSNX;
			%Put Datasets = &Datasets;
		%End;
	%Mend TestDsn;
	%TestDsn(Bank_of_Ireland_&API);
	%TestDsn(Bank_of_Scotland_&API);
	%TestDsn(Barclays_&API);
	%TestDsn(Danske_Bank_&API);
	%TestDsn(First_Trust_Bank_&API);
	%TestDsn(Halifax_&API);
	%TestDsn(Lloyds_Bank_&API);
	%TestDsn(Nationwide_&API);
	%TestDsn(Natwest_&API);
	%TestDsn(RBS_&API);
	%TestDsn(Santander_&API);
	%TestDsn(Ulster_Bank_&API);

	Data Work.NoDUP_CMA9_&API;
		Set &Datasets;
	Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OBData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniqueBRANCHES;

%If "&_action" EQ "CMA9 COMPARISON BRANCHES" %Then
%Do;
%UniqueBRANCHES(BCH);
%End;

%If "&_action" EQ "CMA9 COMPARISON BRANCHES" %Then
%Do;

*--- Append BRANCHES Datasets ---;
Data OBData.CMA9_BCH(Drop = P1-P7);
	Merge OBData.NoDUP_CMA9_BCH
	&Datasets;
	By Hierarchy;

*--- Call the macro in the Where statement to filter the required data elements ---;
*	Where Data_Element in (%Filter);

Run;
%End;
*------------------------------------------------------------------------------------------------------
											PCA
-------------------------------------------------------------------------------------------------------;
%If "&_action" EQ "CMA9 COMPARISON PCA" %Then
%Do;
/*	%If %sysfunc(fileexist(https://openapi.bankofireland.com/open-banking/v2.1/personal-current-accounts)) %Then */
/*	%Do;*/
	%Main(https://openapi.bankofireland.com/open-banking/v2.1/personal-current-accounts,Bank_of_Ireland,PCA);
/*	%End;*/
	%Main(https://api.bankofscotland.co.uk/open-banking/v2.1/personal-current-accounts,Bank_of_Scotland,PCA);
	%Main(https://atlas.api.barclays/open-banking/v2.1/personal-current-accounts,Barclays,PCA);
	%Main(https://obp-data.danskebank.com/open-banking/v2.1/personal-current-accounts,Danske_Bank,PCA);
	%Main(https://openapi.firsttrustbank.co.uk/open-banking/v2.1/personal-current-accounts,First_Trust_Bank,PCA);
	%Main(https://api.halifax.co.uk/open-banking/v2.1/personal-current-accounts,Halifax,PCA);
	%Main(https://api.hsbc.com/open-banking/v2.1/personal-current-accounts,HSBC,PCA);
	%Main(https://api.lloydsbank.com/open-banking/v2.1/personal-current-accounts,Lloyds_Bank,PCA);
	%Main(https://openapi.nationwide.co.uk/open-banking/v2.1/personal-current-accounts,Nationwide,PCA);
	%Main(https://openapi.natwest.com/open-banking/v2.1/personal-current-accounts,Natwest,PCA);
	%Main(https://openapi.rbs.co.uk/open-banking/v2.1/personal-current-accounts,RBS,PCA);
	%Main(https://openbanking.santander.co.uk/sanuk/external/open-banking/v2.1/personal-current-accounts,Santander,PCA);
	%Main(https://openapi.ulsterbank.co.uk/open-banking/v2.1/personal-current-accounts,Ulster_Bank,PCA);
%End;
*--- Get unique Hierarchy values for PCA ---;
%Macro UniquePCA(API);


	%Let Datasets =;
	%Macro TestDsn(DsName);
		%If %Sysfunc(exist(&DsName)) %Then
		%Do;
			%Let DSNX = &DsName;
			%Put DSNX = &DSNX;

			%Let Datasets = &Datasets &DSNX;
			%Put Datasets = &Datasets;
		%End;
	%Mend TestDsn;
	%TestDsn(Bank_of_Ireland_&API);
	%TestDsn(Bank_of_Scotland_&API);
	%TestDsn(Barclays_&API);
	%TestDsn(Danske_Bank_&API);
	%TestDsn(First_Trust_Bank_&API);
	%TestDsn(Halifax_&API);
	%TestDsn(HSBC_&API);
	%TestDsn(Lloyds_Bank_&API);
	%TestDsn(Nationwide_&API);
	%TestDsn(Natwest_&API);
	%TestDsn(RBS_&API);
	%TestDsn(Santander_&API);
	%TestDsn(Ulster_Bank_&API);

	Data Work.NoDUP_CMA9_&API;
		Set &Datasets;
	Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OBData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniquePCA;
%If "&_action" EQ "CMA9 COMPARISON PCA" %Then
%Do;
	%UniquePCA(PCA);
%End;

%If "&_action" EQ "CMA9 COMPARISON PCA" %Then
%Do;
*--- Append PCA Datasets ---;
Data OBData.CMA9_PCA(Drop = P1-P7);
	Merge OBData.NoDUP_CMA9_PCA
	&Datasets;
	By Hierarchy;
Run;

%End;
*------------------------------------------------------------------------------------------------------
											BCA
-------------------------------------------------------------------------------------------------------;
%If "&_action" EQ "CMA9 COMPARISON BCA" %Then
%Do;
/*%If %sysfunc(fileexist(https://openapi.bankofireland.com/open-banking/v2.1/business-current-accounts)) %Then */
/*%Do;*/
	%Main(https://openapi.bankofireland.com/open-banking/v2.1/business-current-accounts,Bank_of_Ireland,BCA);
/*%End;*/
	%Main(https://openapi.aibgb.co.uk/open-banking/v2.1/business-current-accounts,AIB_Group,BCA);
	%Main(https://api.bankofscotland.co.uk/open-banking/v2.1/business-current-accounts,Bank_of_Scotland,BCA);
	%Main(https://atlas.api.barclays/open-banking/v2.1/business-current-accounts,Barclays,BCA);
	%Main(https://obp-data.danskebank.com/open-banking/v2.1/business-current-accounts,Danske_Bank,BCA);
	%Main(https://openapi.firsttrustbank.co.uk/open-banking/v2.1/personal-current-accounts,First_Trust_Bank,BCA);
	%Main(https://api.hsbc.com/open-banking/v2.1/personal-current-accounts,HSBC,BCA);
	%Main(https://api.lloydsbank.com/open-banking/v2.1/business-current-accounts,Lloyds_Bank,BCA);
	%Main(https://openapi.natwest.com/open-banking/v2.1/business-current-accounts,Natwest,BCA);
	%Main(https://openapi.rbs.co.uk/open-banking/v2.1/business-current-accounts,RBS,BCA);
	%Main(https://openbanking.santander.co.uk/sanuk/external/open-banking/v2.1/business-current-accounts,Santander,BCA);
	%Main(https://openapi.ulsterbank.co.uk/open-banking/v2.1/business-current-accounts,Ulster_Bank,BCA);
	%Main(https://openapi.coutts.com/open-banking/v2.1/business-current-accounts,Coutts,BCA);
	%Main(https://openapi.adambank.com/open-banking/v2.1/business-current-accounts,Adam_Bank,BCA);
%End;
*--- Get unique Hierarchy values for BCA ---;
%Macro UniqueBCA(API);

	%Let Datasets =;
	%Macro TestDsn(DsName);
		%If %Sysfunc(exist(&DsName)) %Then
		%Do;
			%Let DSNX = &DsName;
			%Put DSNX = &DSNX;

			%Let Datasets = &Datasets &DSNX;
			%Put Datasets = &Datasets;
		%End;
	%Mend TestDsn;
	%TestDsn(AIB_Group_&API);
	%TestDsn(Bank_of_Ireland_&API);
	%TestDsn(Bank_of_Scotland_&API);
	%TestDsn(Barclays_&API);
	%TestDsn(Danske_Bank_&API);
	%TestDsn(First_Trust_Bank_&API);
	%TestDsn(HSBC_&API);
	%TestDsn(Lloyds_Bank_&API);
	%TestDsn(Natwest_&API);
	%TestDsn(RBS_&API);
	%TestDsn(Santander_&API);
	%TestDsn(Ulster_Bank_&API);
	%TestDsn(Coutts_&API);
	%TestDsn(Adam_Bank_&API);


	Data Work.NoDUP_CMA9_&API;
		Set &Datasets;
/*		By P1-P&_P_Val;*/
	Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OBData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniqueBCA;
%If "&_action" EQ "CMA9 COMPARISON BCA" %Then
%Do;
	%UniqueBCA(BCA);
%End;

%If "&_action" EQ "CMA9 COMPARISON BCA" %Then
%Do;
*--- Append BCA Datasets ---;
Data OBData.CMA9_BCA(Drop = P1-P7);
	Merge OBData.NoDUP_CMA9_BCA
	&Datasets;

	By Hierarchy;
Run;

%End;
*------------------------------------------------------------------------------------------------------
											SME
-------------------------------------------------------------------------------------------------------;
%If "&_action" EQ "CMA9 COMPARISON SME" %Then
%Do;
/*	%If %sysfunc(fileexist(https://openapi.bankofireland.com/open-banking/v2.1/unsecured-sme-loans)) %Then */
/*	%Do;*/
	%Main(https://openapi.bankofireland.com/open-banking/v2.1/unsecured-sme-loans,Bank_of_Ireland,SME);
/*	%End;*/
	%Main(https://openapi.aibgb.co.uk/open-banking/v2.1/unsecured-sme-loans,AIB_Group, SME);
	%Main(https://api.bankofscotland.co.uk/open-banking/v2.1/unsecured-sme-loans,Bank_of_Scotland,SME);
	%Main(https://atlas.api.barclays/open-banking/v2.1/unsecured-sme-loans,Barclays,SME);
	%Main(https://obp-data.danskebank.com/open-banking/v2.1/unsecured-sme-loans,Danske_Bank,SME);
	%Main(https://openapi.esmeloans.com/open-banking/v2.1/unsecured-sme-loans,ESME,SME);
	%Main(https://openapi.firsttrustbank.co.uk/open-banking/v2.1/unsecured-sme-loans,First_Trust_Bank,SME);
	%Main(http://localhost/sasweb/data/temp/od/firsttrust/v2_1/json/unsecured-sme-loans.json,First_Trust_Bank,SME);
	%Main(https://api.hsbc.com/open-banking/v2.1/unsecured-sme-loans,HSBC,SME);
	%Main(https://api.lloydsbank.com/open-banking/v2.1/unsecured-sme-loans,Lloyds_Bank,SME);
	%Main(https://openapi.natwest.com/open-banking/v2.1/unsecured-sme-loans,Natwest,SME);
	%Main(https://openapi.rbs.co.uk/open-banking/v2.1/unsecured-sme-loans,RBS,SME);
	%Main(https://openbanking.santander.co.uk/sanuk/external/open-banking/v2.1/unsecured-sme-loans,Santander,SME);
	%Main(https://openapi.ulsterbank.co.uk/open-banking/v2.1/unsecured-sme-loans,Ulster_Bank,SME);
%End;
*--- Get unique Hierarchy values for SME ---;
%Macro UniqueSME(API);

	%Let Datasets =;
	%Macro TestDsn(DsName);
		%If %Sysfunc(exist(&DsName)) %Then
		%Do;
			%Let DSNX = &DsName;
			%Put DSNX = &DSNX;

			%Let Datasets = &Datasets &DSNX;
			%Put Datasets = &Datasets;
		%End;
	%Mend TestDsn;
	%TestDsn(AIB_Group_&API);
	%TestDsn(Bank_of_Ireland_&API);
	%TestDsn(Bank_of_Scotland_&API);
	%TestDsn(Barclays_&API);
	%TestDsn(Danske_Bank_&API);
	%TestDsn(ESME_&API);
	%TestDsn(First_Trust_Bank_&API);
	%TestDsn(HSBC_&API);
	%TestDsn(Lloyds_Bank_&API);
	%TestDsn(Natwest_&API);
	%TestDsn(RBS_&API);
	%TestDsn(Santander_&API);
	%TestDsn(Ulster_Bank_&API);

	Data Work.NoDUP_CMA9_&API;
		Set &Datasets;
	Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OBData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniqueSME;
%If "&_action" EQ "CMA9 COMPARISON SME" %Then
%Do;
	%UniqueSME(SME);
%End;

%If "&_action" EQ "CMA9 COMPARISON SME" %Then
%Do;
*--- Append SME Datasets ---;
Data OBData.CMA9_SME(Drop = P1-P7);
	Merge OBData.NoDUP_CMA9_SME
	&Datasets;
	By Hierarchy;
Run;

%End;
*------------------------------------------------------------------------------------------------------
											CCC
-------------------------------------------------------------------------------------------------------;
%If "&_action" EQ "CMA9 COMPARISON CCC" %Then
%Do;
/*	%If %sysfunc(fileexist(https://openapi.bankofireland.com/open-banking/v2.1/commercial-credit-cards)) %Then */
/*	%Do;*/
	%Main(https://openapi.bankofireland.com/open-banking/v2.1/commercial-credit-cards,Bank_of_Ireland,CCC);
/*	%End;*/
	%Main(https://api.bankofscotland.co.uk/open-banking/v2.1/commercial-credit-cards,Bank_of_Scotland,CCC);
	%Main(https://atlas.api.barclays/open-banking/v2.1/commercial-credit-cards,Barclays,CCC);
	%Main(https://api.hsbc.com/open-banking/v2.1/commercial-credit-cards,HSBC,CCC);
	%Main(https://api.lloydsbank.com/open-banking/v2.1/commercial-credit-cards,Lloyds_Bank,CCC);
	%Main(https://openapi.natwest.com/open-banking/v2.1/commercial-credit-cards,Natwest,CCC);
	%Main(https://openapi.rbs.co.uk/open-banking/v2.1/commercial-credit-cards,RBS,CCC);
	%Main(https://openbanking.santander.co.uk/sanuk/external/open-banking/v2.1/commercial-credit-cards,Santander,CCC);
%End;
*--- Get unique Hierarchy values for CCC ---;
%Macro UniqueCCC(API);

	%Let Datasets =;
	%Macro TestDsn(DsName);
		%If %Sysfunc(exist(&DsName)) %Then
		%Do;
			%Let DSNX = &DsName;
			%Put DSNX = &DSNX;

			%Let Datasets = &Datasets &DSNX;
			%Put Datasets = &Datasets;
		%End;
	%Mend TestDsn;
	%TestDsn(Bank_of_Ireland_&API);
	%TestDsn(Bank_of_Scotland_&API);
	%TestDsn(Barclays_&API);
	%TestDsn(HSBC_&API);
	%TestDsn(Lloyds_Bank_&API);
	%TestDsn(Natwest_&API);
	%TestDsn(RBS_&API);
	%TestDsn(Santander_&API);

	Data Work.NoDUP_CMA9_&API;
		Set &Datasets;
	Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OBData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniqueCCC;
%If "&_action" EQ "CMA9 COMPARISON CCC" %Then
%Do;
	%UniqueCCC(CCC);
%End;

%If "&_action" EQ "CMA9 COMPARISON CCC" %Then
%Do;
*--- Append CCC Datasets ---;
Data OBData.CMA9_CCC(Drop = P1-P7);
	Merge OBData.NoDUP_CMA9_CCC
	&Datasets;
	By Hierarchy;
Run;

%End;
%Mend RunAPI;
%RunAPI;



*--- Set Title Date in Proc Print ---;
%Macro Fdate(Fmt);
   %Global Fdate;
   Data _Null_;
      Call Symput("Fdate",Left(Put("&Sysdate"d,&Fmt)));
   Run;
%Mend Fdate;
%Fdate(Worddate.);


%Macro Template;
Proc Template;
 	Define style Style.Sasweb;
	End;
Run; 
%Mend Template;
%Template;

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
*--- CSS and JS ---;
		Put '<link rel="stylesheet" type="text/css" href="&_Path/css/loading-bar.css"/>';
		Put '<script type="text/javascript" src="&_Path/js/loading-bar.js"></script>';		

		Put '<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>';


		Put '<SCRIPT language="javascript">' /
		'function MySubmit()' /
		'{document.OBIE.submit();} ' /
		'</SCRIPT>' /;

		*--- Create styles for HTML links on page ---;
		Put '<style>' /
		'td{font-size:"25";color:"green"}' /

		'a' /
		'{' /
			'font-family:arial;' /
			'font-size:10px;' /
			'color:black;' /
			'font-weight:normal;' /
			'font-style:normal;' /
			'text-decoration:none;' /
		'}' /
		'a:hover' /
		'{' /
			'font-family:arial;' /
			'font-size:10px;' /
			'color:blue;' /
			'text-decoration:none;' /
		'}' /
		'.nav' /
		'{' /
			'font-family:arial;' /
			'font-size:10px;' /
			'color:#ffffff;' /
			'font-weight:normal;' /
			'font-style:normal;' /
			'text-decoration:none;' /
			'border:inset 0px #ececec;' /
			'cursor:hand;' /
		'}' /
		'</style>' /
		'</HEAD>';

		Put '<BODY>';

		*--- Include horizontal line under image ---;
/*		Put '<hr size="2" color="blue">'  /;*/

		*--- Create Progress Bar ---;
		Put '<table align="center"><tr><td>' /
			'<div style="font-size:8pt;padding:2px;border:solid black 0px">' /
			'<span id="progress1"> &nbsp; &nbsp;</span>' /
			'<span id="progress2"> &nbsp; &nbsp;</span>' /
			'<span id="progress3"> &nbsp; &nbsp;</span>' /
			'<span id="progress4"> &nbsp; &nbsp;</span>' /
			'<span id="progress5"> &nbsp; &nbsp;</span>' /
			'<span id="progress6"> &nbsp; &nbsp;</span>' /
			'<span id="progress7"> &nbsp; &nbsp;</span>' /
			'<span id="progress8"> &nbsp; &nbsp;</span>' /
			'<span id="progress9"> &nbsp; &nbsp;</span>'
			'</div>' /
			'</td></tr></table>';

		Put '<script language="javascript">' /
		'var progressEnd = 9;' /		
		'var progressColor = "blue";' /	
		'var progressInterval = 1000;' /	
		'var progressAt = progressEnd;' /
		'var progressTimer;' /

		'function progress_clear() {' /
		'	for (var i = 1; i <= progressEnd; i++) ' /
		"	document.getElementById('progress'+i).style.backgroundColor = 'transparent';" /
		'	progressAt = 0;' /
		'}' /

		'function progress_update() {' /
		'	progressAt++;' /
		'	if (progressAt > progressEnd) progress_clear();' /
		"	else document.getElementById('progress'+progressAt).style.backgroundColor = progressColor;" /
		"	progressTimer = setTimeout('progress_update()',progressInterval);" /
		'}' /

		'function progress_stop() {' /
		'	clearTimeout(progressTimer);' /
		'	progress_clear();' /
		'}' /

		'progress_update();' /		
		'</script>' /
		'<p>' /;

/*		Put '<p></p>';*/
/*		Put '<HR>';*/
/*		Put '<p></p>';*/

		Put '<Table align="center" style="width: 100%; height: 8%" border="0">';


		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';
		Put '<FORM ID=OBIE NAME=OBIE METHOD=get ACTION="http://localhost/scripts/broker.exe">';
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

		Put '<Table align="center" style="width: 100%; height: 5%" border="0">';
		Put '<td valign="top" style="background-color: White; color: black">';
		Put '<H3>All Rights Reserved</H3>';
		Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
		Put '</td>';
		Put '</Table>';
	Run;

	*--- Stop Progress Bar and close HTML page ---;
		Data _Null_;
		File _Webout;
		Put '<SCRIPT language="javascript">' /
			'progress_stop();' /
			'</SCRIPT>';

		Put '</BODY>';
		Put '<HTML>';
		
Run;
%Mend ReturnButton;



*--- Run Macro to Print the CMA9 Reports for ATMS, BRANCHES, PCA, etc ---;
%Macro CMA9_Reports(API);
*--- Set Output Delivery Parameters  ---;
/*ODS _All_ Close;*/

/*
ODS HTML Body="Compare_CMA9_&API..html" 
	Contents="Compare_contents_&API..html" 
	Frame="Compare_frame_&API..html" 
	Style=HTMLBlue;
*/
/*ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;*/


%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
title "Listing of Product Sales"; 
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

*--- Sort dataset by the RowCnt value to set the table in the original JSON script order ---; 
Proc Sort Data = OBData.CMA9_&API;
	By RowCnt;
Run;

*--- Create a Record-ID field for all records in the API JSON file ---;
*--- Each record in the API file starts with the Data_Element LEI ---;
*--- Every time the Data_Element value LEI is encountered a new records start in the JSON file ---;
Data OBData.CMA9_&API;
	Set OBData.CMA9_&API;
	If Data_Element = 'LEI' Then 
	Do;
		_Record_ID + 1;
	End;
	Retain _Record_ID;
Run;


*--- Print ATMS Report ---;
/*Proc Print Data = OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);*/
/*Run;*/


	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";

ods pdf file="C:\inetpub\wwwroot\sasweb\Data\Results\CMA9_&API._Comparison.pdf" style=styles.SASWeb;
proc print data=OBData.CMA9_&API(Keep = Hierarchy Data_Element HSBC RBS Barclays obs=25);
run; 


ods html file="C:\inetpub\wwwroot\sasweb\Data\Results\CMA9_&API._Comparison.html" style=styles.SASWeb;
proc print data=OBData.CMA9_&API(Keep = Hierarchy Data_Element HSBC RBS Barclays obs=25);
run; 

Proc Report Data = OBData.CMA9_&API(Drop=Bank_API P Count RowCnt) nowd;

	%If "&_action" EQ "CMA9 COMPARISON CCC" %Then
	%Do;

			Columns Hierarchy 
			Data_Element
			Bank_of_Ireland
			Bank_of_Scotland
			Barclays
			HSBC
			Lloyds_Bank
			Natwest
			RBS
			Santander;

			Define Hierarchy  / display 'Hierarchy' left;
			Define Data_Element / display 'Data Element' left;
			Define Bank_of_Ireland / display 'Bank of Ireland' left;
			Define Bank_of_Scotland / display 'Bank of Scotland' left;
			Define Barclays / display 'Barclays Bank' left;
			Define HSBC / display 'HSBC' left;
			Define Lloyds_Bank / display 'Lloyds Bank' left;
			Define Natwest / display 'Natwest' left;
			Define RBS / display 'RBS' left;
			Define Santander / display 'Santander' left;
	%End;

	%If "&_action" EQ "CMA9 COMPARISON SME" %Then
	%Do;
			Columns Hierarchy 
			Data_Element
			Bank_of_Ireland
			AIB_Group		
			Bank_of_Scotland
			Barclays
			ESME
			First_Trust_Bank
			HSBC
			Lloyds_Bank
			Natwest
			RBS
			Santander
			Ulster_Bank;

			Define Hierarchy  / display 'Hierarchy' left;
			Define Data_Element / display 'Data Element' left;
			Define Bank_of_Ireland / display 'Bank of Ireland' left;
			Drfine AIB_Group / display 'Allied Irish Bank' left;
			Define Bank_of_Scotland / display 'Bank of Scotland' left;
			Define Barclays / display 'Barclays Bank' left;
			Define ESME / display 'ESME Bank' left;
			Define First_Trust_Bank / display 'First Trust Bank' left;
			Define HSBC / display 'HSBC' left;
			Define Lloyds_Bank / display 'Lloyds Bank' left;
			Define Natwest / display 'Natwest' left;
			Define RBS / display 'RBS' left;
			Define Santander / display 'Santander' left;
			Define Ulster_Bank / display 'Ulster Bank' left;
	%End;

	%If "&_action" EQ "CMA9 COMPARISON BCA" %Then
	%Do;
			Columns Hierarchy 
			Data_Element
			AIB_Group
			Bank_of_Ireland
			Bank_of_Scotland
			Barclays
			Danske_Bank
			First_Trust_Bank
			HSBC
			Lloyds_Bank
			Natwest
			RBS
			Santander
			Ulster_Bank
			Coutts
			Adam_Bank
			;

			Define Hierarchy  / display 'Hierarchy' left;
			Define Data_Element / display 'Data Element' left;
			Define AIB_Group / display 'Allied Irish Bank' left;
			Define Bank_of_Ireland / display 'Bank of Ireland' left;
			Define Bank_of_Scotland / display 'Bank of Scotland' left;
			Define Barclays / display 'Barclays Bank' left;
			Define Danske_Bank / display 'Danske Bank' left;
			Define First_Trust_Bank / display 'First Trust Bank' left;
			Define HSBC / display 'HSBC' left;
			Define Lloyds_Bank / display 'Lloyds Bank' left;
			Define Natwest / display 'Natwest' left;
			Define RBS / display 'RBS' left;
			Define Santander / display 'Santander' left;
			Define Ulster_Bank / display 'Ulster Bank' left;
			Define Coutts / display 'Coutts' left;
			Define Adam_Bank / display 'Adam Bank' left;

	%End;

	%If "&_action" EQ "CMA9 COMPARISON PCA" %Then
	%Do;
			Columns Hierarchy 
			Data_Element
			Bank_of_Ireland
			Bank_of_Scotland
			Barclays
			Danske_Bank
			First_Trust_Bank
			Halifax
			HSBC
			Lloyds_Bank
			Nationwide
			Natwest
			RBS
			Santander
			Ulster_Bank;

			Define Hierarchy  / display 'Hierarchy' left;
			Define Data_Element / display 'Data Element' left;
			Define Bank_of_Ireland / display 'Bank of Ireland' left;
			Define Bank_of_Scotland / display 'Bank of Scotland' left;
			Define Barclays / display 'Barclays Bank' left;
			Define Danske_Bank / display 'Danske Bank' left;
			Define First_Trust_Bank / display 'First Trust Bank' left;
			Define Halifax / display 'Halifax Bank' left;
			Define HSBC / display 'HSBC' left;
			Define Lloyds_Bank / display 'Lloyds Bank' left;
			Define Nationwide / display 'Nationwide' left;
			Define Natwest / display 'Natwest' left;
			Define RBS / display 'RBS' left;
			Define Santander / display 'Santander' left;
			Define Ulster_Bank / display 'Ulster Bank' left;
	%End;

Run;



/*
PROC EXPORT DATA = OBData.CMA9_&API(Drop=Bank_API P Count RowCnt) 
            OUTFILE= "C:\inetpub\wwwroot\sasweb\data\results\CMA9_&API..csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
*/

*--- Close Output Delivery Parameters  ---;
ODS HTML Close;


ODS CSV File="C:\inetpub\wwwroot\sasweb\data\results\CMA9_&API..csv";

Proc Print Data=OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;

ODS CSV Close;

/*
ODS HTML File="&Path\Data\Results\CMA9_&API..xls";
Proc Print Data=OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
ODS HTML Close;
*/


%ReturnButton;

ods tagsets.tableeditor close; 
ods listing; 

%Mend CMA9_Reports;

%Macro APIReport;
%If "&_action" EQ "CMA9 COMPARISON ATMS" %Then
%Do;
	%CMA9_Reports(ATM);
%End;
%Else %If "&_action" EQ "CMA9 COMPARISON BRANCHES" %Then
%Do;
	%CMA9_Reports(BCH);
%End;
%Else %If "&_action" EQ "CMA9 COMPARISON PCA" %Then
%Do;
	%CMA9_Reports(PCA);
%End;
%Else %If "&_action" EQ "CMA9 COMPARISON BCA" %Then
%Do;
	%CMA9_Reports(BCA);
%End;
%Else %If "&_action" EQ "CMA9 COMPARISON SME" %Then
%Do;
	%CMA9_Reports(SME);
%End;
%Else %If "&_action" EQ "CMA9 COMPARISON CCC" %Then
%Do;
	%CMA9_Reports(CCC);
%End;
%Mend APIReport;
%APIReport;
