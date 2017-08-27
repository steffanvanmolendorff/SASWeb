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

%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

*--- Set Default Data Library as macro variable ---;
*--- Alternatively set the Data library in Proc Appsrv ---;
/*
%Let Path = C:\inetpub\wwwroot\sasweb\Data\Perm;

*--- Set X path variable to the default directory ---;
X "cd &Path";

*--- Set the Library path where the permanent datasets will be saved ---;
Libname OBData "&Path";
*/

%Global _action;
%Global ErrorCode;
%Global ErrorDesc;
%Global Datasets;

*--- The Macro Filter executes in the Where statement when the OpenData datasets are created ---;
%Macro Filter();
'AnnualBusinessTurnover'
'ArrangementType'
'BenefitDescription'
'BenefitName'
'BenefitType'
'BenefitValue'
'CMADefinedIndicator'
'Code'
'CriteriaType'
'DateOfChange'
'DefaulttoAccounts'
'Description'
'EAR'
'EligibilityName'
'EligibilityNotes'
'EligibilityType'
'FeeAmount'
'FeeChargeAmount'
'FeeChargeApplicationFrequency'
'FeeChargeOtherApplicationFrequency'
'FeeChargeOtherType'
'FeeChargeRate'
'FeeChargeRateOtherType'
'FeeChargeRateType'
'FeeChargeType'
'FeeFrequency'
'FeeHigherTier'
'FeeLowerTier'
'FeeMax'
'FeeMin'
'FeeRate'
'FeesAndCharges'
'FeesandChargesNotes'
'FeeSubType'
'FeeType'
'IncomeCondition'
'IncomeTurnoverRelated'
'InterestProductSubType'
'LengthPromotionalindays'
'MarketingEligibility'
'MaximumAge'
'MaximumAgeToOpen'
'MaximumCriteria'
'MaximumMonthlyOverdraftCharge'
'MaximumOpeningAmount'
'MaxNumberOfAccounts'
'MinimumCriteria'
'MinimumIncomeFrequency'
'MinimumIncomeTurnoverAmount'
'MinimumIncomeTurnoverCurrency'
'MinimumOperatingBalance'
'MinimumOperatingBalanceCurrency'
'MinimumOperatingBalanceExists'
'MinIncomeTurnoverPaidIntoAccount'
'Name'
'Negotiable'
'Notes'
'OpeningDepositMaximumAmount'
'OpeningDepositMinimum'
'Other'
'OtherFinancialHoldingRequired'
'OverdraftProductState'
'OverdraftTierBandSet'
'OverdraftType'
'PreviousBankruptcy'
'Produ'
'Product'
'ProductDescription'
'ProductIdentifier'
'ProductName'
'ProductSegment1'
'ProductSegment1Ba'
'ProductSegment1Sm'
'ProductSegment1SME'
'ProductSegment1St'
'ProductState'
'ProductSubType'
'ProductType'
'ProductTypeName'
'ProductURL1htt'
'ProductURL1http'
'ProductURL1http:/'
'ProductURL1https:'
'ProductURL1htts:'
'PromotionEndDate'
'PromotionStartDate'
'RepresentativeRate'
'SingleJointIncome'
'StartPromotionOrFutureTerms'
'StopPromotionOrFutureTerms'
'Term'
'TierBandSetIdentification'

%Mend Filter;

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
	Sleeptime = Sleep(1);
Run;

*--- The JSON engine will extract the data from the JSON script ---; 
Options ERRORCHECK=NORMAL;
Libname LibAPIs JSON Fileref=API;
%ErrorCheck;

*--- Proc datasets will create the datasets to examine resulting tables and structures ---;
Proc Datasets Lib = LibAPIs; 
%ErrorCheck;

Data Work.&Bank._&API
	(Keep = RowCnt Count P Bank_API Var2 Var3 P1 - P7 Value 
	Rename=(Var3 = Data_Element Var2 = Hierarchy Value = &Bank));

	Length Bank_API $ 8 Var2 Value1 Value2 $ 500 Var3 $ 100 P1 - P7 Value $ 500;

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

%ErrorCheck;

*--- Sort data by Data_Element ---;
Proc Sort Data = Work.&Bank._&API;
 By P1 - P7;
%ErrorCheck;

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
	%If %sysfunc(fileexist(https://openapi.bankofireland.com/open-banking/v1.2/atms)) %Then 
	%Do;
	%Main(https://openapi.bankofireland.com/open-banking/v1.2/atms,Bank_of_Ireland,ATM);
	%End;
	%Main(https://api.bankofscotland.co.uk/open-banking/v1.2/atms,Bank_of_Scotland,ATM);
	%Main(https://atlas.api.barclays/open-banking/v1.3/atms,Barclays,ATM);
	%Main(https://obp-api.danskebank.com/open-banking/v1.2/atms,Danske_Bank,ATM);
	%Main(https://api.firsttrustbank.co.uk/open-banking/v1.2/atms,First_Trust_Bank,ATM);
	%Main(https://api.halifax.co.uk/open-banking/v1.2/atms,Halifax,ATM);
	%Main(https://api.hsbc.com/open-banking/v1.2/atms,HSBC,ATM);
	%Main(https://api.lloydsbank.com/open-banking/v1.2/atms,Lloyds_Bank,ATM);
	%Main(https://openapi.nationwide.co.uk/open-banking/v1.2/atms,Nationwide,ATM);
	%Main(https://openapi.natwest.com/open-banking/v1.3/atms,Natwest,ATM);
	%Main(https://openapi.rbs.co.uk/open-banking/v1.3/atms,RBS,ATM);
	%Main(https://api.santander.co.uk/retail/open-banking/v1.2/atms,Santander,ATM);
	%Main(https://openapi.ulsterbank.co.uk/open-banking/v1.3/atms,Ulster_Bank,ATM);
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
		By P1-P7;
	Run;

/*
	Data Work.NoDUP_CMA9_&API;
	Set Work.Bank_of_Ireland_&API
		Work.Bank_of_Scotland_&API
		Work.Barclays_&API
		Work.Danske_Bank_&API
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
*/

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OpenData.NoDUP_CMA9_&API NoDupKey;
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
Data OpenData.CMA9_ATM(Drop = P1-P7);

	Merge OpenData.NoDUP_CMA9_ATM
	&Datasets;

/*	
	Merge OpenData.NoDUP_CMA9_ATM
	Bank_of_Ireland_ATM
	Bank_of_Scotland_ATM
	Barclays_ATM
	Danske_Bank_ATM
	Halifax_ATM
	HSBC_ATM
	Lloyds_Bank_ATM
	Nationwide_ATM
	Natwest_ATM
	RBS_ATM
	Santander_ATM
	Ulster_Bank_ATM;
*/
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
	%If %sysfunc(fileexist(https://openapi.bankofireland.com/open-banking/v1.2/branches)) %Then 
	%Do;
	%Main(https://openapi.bankofireland.com/open-banking/v1.2/branches,Bank_of_Ireland,BCH);
	%End;
	%Main(https://api.bankofscotland.co.uk/open-banking/v1.2/branches,Bank_of_Scotland,BCH);
	%Main(https://atlas.api.barclays/open-banking/v1.3/branches,Barclays,BCH);
	%Main(https://obp-api.danskebank.com/open-banking/v1.2/branches,Danske_Bank,BCH);
	%Main(https://api.firsttrustbank.co.uk/open-banking/v1.2/branches,First_Trust_Bank,BCH);
	%Main(https://api.halifax.co.uk/open-banking/v1.2/branches,Halifax,BCH);
	%Main(https://api.hsbc.com/open-banking/v1.2/branches,HSBC,BCH);
	%Main(https://api.lloydsbank.com/open-banking/v1.2/branches,Lloyds_Bank,BCH);
	%Main(https://openapi.nationwide.co.uk/open-banking/v1.2/branches,Nationwide,BCH);
	%Main(https://openapi.natwest.com/open-banking/v1.2/branches,Natwest,BCH);
	%Main(https://openapi.rbs.co.uk/open-banking/v1.3/branches,RBS,BCH);
	%Main(https://api.santander.co.uk/retail/open-banking/v1.2/branches,Santander,BCH);
	%Main(https://openapi.ulsterbank.co.uk/open-banking/v1.3/branches,Ulster_Bank,BCH);
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
	%TestDsn(Halifax_&API);
	%TestDsn(Lloyds_Bank_&API);
	%TestDsn(Nationwide_&API);
	%TestDsn(Natwest_&API);
	%TestDsn(RBS_&API);
	%TestDsn(Santander_&API);
	%TestDsn(Ulster_Bank_&API);

	Data Work.NoDUP_CMA9_&API;
		Set &Datasets;
		By P1-P7;
	Run;

/*
Data Work.NoDUP_CMA9_&API;
	Set Work.Bank_of_Ireland_&API
		Work.Bank_of_Scotland_&API
		Work.Barclays_&API
		Work.Danske_Bank_&API
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
*/

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OpenData.NoDUP_CMA9_&API NoDupKey;
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
Data OpenData.CMA9_BCH(Drop = P1-P7);
	Merge OpenData.NoDUP_CMA9_BCH
	&Datasets;


/*
	Work.Bank_of_Ireland_BCH
	Work.Bank_of_Scotland_BCH
	Work.Barclays_BCH
	Work.Danske_Bank_BCH
	Work.Halifax_BCH
	Work.HSBC_BCH
	Work.Lloyds_Bank_BCH
	Work.Nationwide_BCH
	Work.Natwest_BCH
	Work.RBS_BCH
	Work.Santander_BCH
	Work.Ulster_Bank_BCH;
*/

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
	%If %sysfunc(fileexist(https://openapi.bankofireland.com/open-banking/v1.2/personal-current-accounts)) %Then 
	%Do;
	%Main(https://openapi.bankofireland.com/open-banking/v1.2/personal-current-accounts,Bank_of_Ireland,PCA);
	%End;
	%Main(https://api.bankofscotland.co.uk/open-banking/v1.2/personal-current-accounts,Bank_of_Scotland,PCA);
	%Main(https://atlas.api.barclays/open-banking/v1.3/personal-current-accounts,Barclays,PCA);
	%Main(https://api.firsttrustbank.co.uk/open-banking/v1.2/personal-current-accounts,First_Trust_Bank,PCA);
	%Main(https://api.halifax.co.uk/open-banking/v1.2/personal-current-accounts,Halifax,PCA);
	%Main(https://api.hsbc.com/open-banking/v1.2/personal-current-accounts,HSBC,PCA);
	%Main(https://api.lloydsbank.com/open-banking/v1.2/personal-current-accounts,Lloyds_Bank,PCA);
	%Main(https://openapi.nationwide.co.uk/open-banking/v1.2/personal-current-accounts,Nationwide,PCA);
	%Main(https://openapi.natwest.com/open-banking/v1.2/personal-current-accounts,Natwest,PCA);
	%Main(https://openapi.rbs.co.uk/open-banking/v1.3/personal-current-accounts,RBS,PCA);
	%Main(https://api.santander.co.uk/retail/open-banking/v1.2/personal-current-accounts,Santander,PCA);
	%Main(https://openapi.ulsterbank.co.uk/open-banking/v1.3/personal-current-accounts,Ulster_Bank,PCA);
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
	%TestDsn(Halifax_&API);
	%TestDsn(Lloyds_Bank_&API);
	%TestDsn(Nationwide_&API);
	%TestDsn(Natwest_&API);
	%TestDsn(RBS_&API);
	%TestDsn(Santander_&API);
	%TestDsn(Ulster_Bank_&API);

	Data Work.NoDUP_CMA9_&API;
		Set &Datasets;
		By P1-P7;
	Run;


/*
	Data Work.NoDUP_CMA9_&API;
	Set Work.Bank_of_Ireland_&API
		Work.Bank_of_Scotland_&API
		Work.Barclays_&API
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
*/
	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OpenData.NoDUP_CMA9_&API NoDupKey;
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
/*
	Work.Bank_of_Ireland_PCA
	Work.Bank_of_Scotland_PCA
	Work.Barclays_PCA
	Work.First_Trust_Bank_PCA
	Work.Halifax_PCA
	Work.HSBC_PCA
	Work.Lloyds_Bank_PCA
	Work.Nationwide_PCA
	Work.Natwest_PCA
	Work.RBS_PCA
	Work.Santander_PCA
	Work.Ulster_Bank_PCA;
*/
	By Hierarchy;
Run;

Data OBData.CMA9_PCA;
	Set OBData.CMA9_PCA;
*--- Call the macro in the Where statement to filter the required data elements ---;
/*	Where Data_Element in (%Filter);*/

*	Where Data_Element in ('InterestProductSubType'
	'ProductDescription'
	'ProductIdentifier'
	'ProductName'
	'ProductSegment1'
	'ProductSegment1Ba'
	'ProductSegment1St'
	'ProductSubType'
	'ProductType'
	'ProductURL1htt'
	'ProductURL1http'
	'ProductURL1htts:');
Run;
%End;
*------------------------------------------------------------------------------------------------------
											BCA
-------------------------------------------------------------------------------------------------------;
%If "&_action" EQ "CMA9 COMPARISON BCA" %Then
%Do;
%If %sysfunc(fileexist(https://openapi.bankofireland.com/open-banking/v1.2/business-current-accounts)) %Then 
%Do;
	%Main(https://api.aibgb.co.uk/open-banking/v1.2/business-current-accounts,AIB_Group,BCA);
%End;
	%Main(https://openapi.bankofireland.com/open-banking/v1.2/business-current-accounts,Bank_of_Ireland,BCA);
	%Main(https://api.bankofscotland.co.uk/open-banking/v1.2/business-current-accounts,Bank_of_Scotland,BCA);
	%Main(https://atlas.api.barclays/open-banking/v1.3/business-current-accounts,Barclays,BCA);
	%Main(https://obp-api.danskebank.com/open-banking/v1.2/business-current-accounts,Danske_Bank,BCA);
	%Main(https://api.firsttrustbank.co.uk/open-banking/v1.2/business-current-accounts,First_Trust_Bank,BCA);
	%Main(https://api.hsbc.com/open-banking/v1.2/personal-current-accounts,HSBC,BCA);
	%Main(https://api.lloydsbank.com/open-banking/v1.2/business-current-accounts,Lloyds_Bank,BCA);
	%Main(https://openapi.natwest.com/open-banking/v1.2/business-current-accounts,Natwest,BCA);
	%Main(https://openapi.rbs.co.uk/open-banking/v1.3/business-current-accounts,RBS,BCA);
	%Main(https://api.santander.co.uk/retail/open-banking/v1.2/business-current-accounts,Santander,BCA);
	%Main(https://openapi.ulsterbank.co.uk/open-banking/v1.3/business-current-accounts,Ulster_Bank,BCA);
	%Main(https://openapi.coutts.co.uk/open-banking/v1.3/business-current-accounts,Coutts,BCA);
	%Main(https://openapi.adambank.co.uk/open-banking/v1.3/business-current-accounts,Adam_Bank,BCA);

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
		By P1-P7;
	Run;


/*
Data Work.NoDUP_CMA9_&API;
	Set Work.AIB_Group_&API
		Work.Bank_of_Ireland_&API
		Work.Bank_of_Scotland_&API
		Work.Barclays_&API
		Work.Danske_Bank_&API
		Work.First_Trust_Bank_&API
		Work.HSBC_&API
		Work.Lloyds_Bank_&API
		Work.Natwest_&API
		Work.RBS_&API
		Work.Santander_&API
		Work.Ulster_Bank_&API
		;
	By P1-P7;
	Run;
*/

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

/*
	Work.AIB_Group_BCA
	Work.Bank_of_Ireland_BCA
	Work.Bank_of_Scotland_BCA
	Work.Barclays_BCA
	Work.Danske_Bank_BCA
	Work.First_Trust_Bank_BCA
	Work.HSBC_BCA
	Work.Lloyds_Bank_BCA
	Work.Natwest_BCA
	Work.RBS_BCA
	Work.Santander_BCA
	Work.Ulster_Bank_BCA
	;
*/
	By Hierarchy;
Run;

Data OBData.CMA9_BCA;
	Set OBData.CMA9_BCA;
*--- Call the macro in the Where statement to filter the required data elements ---;
/*	Where Data_Element in (%Filter);*/

*	Where Data_Element in ('InterestProductSubType'
	'OverdraftProductState'
	'Produ'
	'ProductDescription'
	'ProductIdentifier'
	'ProductName'
	'ProductSegmen'
	'ProductSegment'
	'ProductSegment1'
	'ProductState'
	'ProductSubType'
	'ProductType'
	'ProductURL1h'
	'ProductURL1http:/');
Run;
%End;
*------------------------------------------------------------------------------------------------------
											SME
-------------------------------------------------------------------------------------------------------;
%If "&_action" EQ "CMA9 COMPARISON SME" %Then
%Do;
	%If %sysfunc(fileexist(https://openapi.bankofireland.com/open-banking/v1.2/unsecured-sme-loans)) %Then 
	%Do;
	%Main(https://api.aibgb.co.uk/open-banking/v1.2/unsecured-sme-loans,AIB_Group, SME);
	%End;
	%Main(https://openapi.bankofireland.com/open-banking/v1.2/unsecured-sme-loans,Bank_of_Ireland,SME);
	%Main(https://api.bankofscotland.co.uk/open-banking/v1.2/unsecured-sme-loans,Bank_of_Scotland,SME);
	%Main(https://atlas.api.barclays/open-banking/v1.3/unsecured-sme-loans,Barclays,SME);
	%Main(https://obp-api.danskebank.com/open-banking/v1.2/unsecured-sme-loans,Danske_Bank,SME);
	%Main(https://api.firsttrustbank.co.uk/open-banking/v1.2/unsecured-sme-loans,First_Trust_Bank,SME);
	%Main(https://api.hsbc.com/open-banking/v1.2/unsecured-sme-loans,HSBC,SME);
	%Main(https://api.lloydsbank.com/open-banking/v1.2/unsecured-sme-loans,Lloyds_Bank,SME);
	%Main(https://openapi.natwest.com/open-banking/v1.2/unsecured-sme-loans,Natwest,SME);
	%Main(https://openapi.rbs.co.uk/open-banking/v1.3/unsecured-sme-loans,RBS,SME);
	%Main(https://api.santander.co.uk/retail/open-banking/v1.2/unsecured-sme-loans,Santander,SME);
	%Main(https://openapi.ulsterbank.co.uk/open-banking/v1.3/unsecured-sme-loans,Ulster_Bank,SME);
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
	%TestDsn(First_Trust_Bank_&API);
	%TestDsn(HSBC_&API);
	%TestDsn(Lloyds_Bank_&API);
	%TestDsn(Natwest_&API);
	%TestDsn(RBS_&API);
	%TestDsn(Santander_&API);
	%TestDsn(Ulster_Bank_&API);

	Data Work.NoDUP_CMA9_&API;
		Set &Datasets;
		By P1-P7;
	Run;

/*
Data Work.NoDUP_CMA9_&API;
	Set Work.AIB_Group_&API
		Work.Bank_of_Ireland_&API
		Work.Bank_of_Scotland_&API
		Work.Barclays_&API
		Work.Danske_Bank_&API
		Work.First_Trust_Bank_&API
		Work.HSBC_&API
		Work.Lloyds_Bank_&API
		Work.Natwest_&API
		Work.RBS_&API
		Work.Santander_&API
		Work.Ulster_Bank_&API;
	By P1-P7;
Run;
*/

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

/*
	Work.AIB_Group_SME
	Work.Bank_of_Ireland_SME
	Work.Bank_of_Scotland_SME
	Work.Barclays_SME
	Work.Danske_Bank_SME
	Work.First_Trust_Bank_SME
	Work.HSBC_SME
	Work.Lloyds_Bank_SME
	Work.Natwest_SME
	Work.RBS_SME
	Work.Santander_SME
	Work.Ulster_Bank_SME;
*/
	By Hierarchy;
Run;

Data OBData.CMA9_SME;
	Set OBData.CMA9_SME;
*--- Call the macro in the Where statement to filter the required data elements ---;
/*	Where Data_Element in (%Filter);*/

*	Where Data_Element in ('Produ'
	'Product'
	'ProductDescription'
	'ProductIdentifier'
	'ProductName'
	'ProductSegment1Sm'
	'ProductState'
	'ProductSubType'
	'ProductTypeName'
	'ProductURL1https:');
Run;
%End;
*------------------------------------------------------------------------------------------------------
											CCC
-------------------------------------------------------------------------------------------------------;
%If "&_action" EQ "CMA9 COMPARISON CCC" %Then
%Do;
	%If %sysfunc(fileexist(https://openapi.bankofireland.com/open-banking/v1.2/commercial-credit-cards)) %Then 
	%Do;
	%Main(https://openapi.bankofireland.com/open-banking/v1.2/commercial-credit-cards,Bank_of_Ireland,CCC);
	%End;
	%Main(https://atlas.api.barclays/open-banking/v1.3/commercial-credit-cards,Barclays,CCC);
	%Main(https://api.hsbc.com/open-banking/v1.2/commercial-credit-cards,HSBC,CCC);
	%Main(https://api.lloydsbank.com/open-banking/v1.2/commercial-credit-cards,Lloyds_Bank,CCC);
	%Main(https://openapi.natwest.com/open-banking/v1.2/commercial-credit-cards,Natwest,CCC);
	%Main(https://openapi.rbs.co.uk/open-banking/v1.3/commercial-credit-cards,RBS,CCC);
	%Main(https://api.santander.co.uk/retail/open-banking/v1.2/commercial-credit-cards,Santander,CCC);
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
	%TestDsn(Barclays_&API);
	%TestDsn(HSBC_&API);
	%TestDsn(Lloyds_Bank_&API);
	%TestDsn(Natwest_&API);
	%TestDsn(RBS_&API);
	%TestDsn(Santander_&API);

	Data Work.NoDUP_CMA9_&API;
		Set &Datasets;
		By P1-P7;
	Run;

/*
Data Work.NoDUP_CMA9_&API;
	Set Work.Bank_of_Ireland_CCC
		Work.Barclays_CCC
		Work.HSBC_CCC
		Work.Lloyds_Bank_CCC
		Work.Natwest_CCC
		Work.RBS_CCC
		Work.Santander_CCC;
	By P1-P7;
	Run;
*/
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
/*
	Work.Bank_of_Ireland_CCC
	Work.Barclays_CCC
	Work.HSBC_CCC
	Work.Lloyds_Bank_CCC
	Work.Natwest_CCC
	Work.RBS_CCC
	Work.Santander_CCC;
*/
	By Hierarchy;
Run;

Data OBData.CMA9_CCC;
	Set OBData.CMA9_CCC;
*--- Call the macro in the Where statement to filter the required data elements ---;
/*	Where Data_Element in (%Filter);*/

*	Where Data_Element in ('Produ'
	'Product'
	'ProductIdentifier'
	'ProductName'
	'ProductSegment1SME'
	'ProductType'
	'ProductURL1http:/');
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

		Put '<Table align="center" style="width: 100%; height: 10%" border="0">';
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

		Put '<Table align="center" style="width: 100%; height: 5%" border="0">';
		Put '<td valign="top" style="background-color: White; color: black">';
		Put '<H3>All Rights Reserved</H3>';
		Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
		Put '</td>';
		Put '</Table>';

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

*--- Sort dataset by the RowCnt value to set the table in the original JSON script order ---; 
Proc Sort Data = OBData.CMA9_&API;
	By RowCnt;
Run;

*--- Print ATMS Report ---;
/*Proc Print Data = OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);*/
/*Run;*/

	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";

Proc Report Data = OBData.CMA9_&API(Drop=Bank_API P Count RowCnt) nowd
			style(report)=[rules=all cellspacing=0 bordercolor=gray] 
			style(header)=[background=lightskyblue foreground=black] 
			style(column)=[background=lightcyan foreground=black];

%If "&_action" EQ "CMA9 COMPARISON CCC" %Then
%Do;

		Columns Hierarchy 
		Data_Element
		Bank_of_Ireland
		Barclays
		HSBC
		Lloyds_Bank
		Natwest
		RBS
		Santander;

		Define Hierarchy  / display 'Hierarchy' left;
		Define Data_Element / display 'Data Element' left;
		Define Bank_of_Ireland / display 'Bank of Ireland' left;
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
		Bank_of_Scotland
		Barclays
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
		Define Bank_of_Scotland / display 'Bank of Scotland' left;
		Define Barclays / display 'Barclays Bank' left;
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
		Bank_of_Ireland
		Bank_of_Scotland
		Barclays
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
		Define Bank_of_Ireland / display 'Bank of Ireland' left;
		Define Bank_of_Scotland / display 'Bank of Scotland' left;
		Define Barclays / display 'Barclays Bank' left;
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
		Define Bank_of_Scotland / display 'Bank of Scotland' left;
		Define Barclays / display 'Barclays Bank' left;
		Define First_Trust_Bank / display 'First Trust Bank' left;
		Define HSBC / display 'HSBC' left;
		Define Lloyds_Bank / display 'Lloyds Bank' left;
		Define Natwest / display 'Natwest' left;
		Define RBS / display 'RBS' left;
		Define Santander / display 'Santander' left;
		Define Ulster_Bank / display 'Ulster Bank' left;
%End;



Run;

/*
PROC EXPORT DATA = OPENDATA.CMA9_&API(Drop=Bank_API P Count RowCnt) 
            OUTFILE= "H:\STV\Open Banking\SAS\Temp\CMA9_&API..csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
*/

*--- Close Output Delivery Parameters  ---;
/*ODS HTML Close;*/

/*
ODS CSV File="&Path\CMA9_&API..csv";
Proc Print Data=OpenData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
ODS CSV Close;

ODS HTML File="&Path\CMA9_&API..xls";
Proc Print Data=OpenData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
ODS HTML Close;
*/

%ReturnButton;

ods tagsets.tableeditor close; 
ods listing; 

%Mend CMA9_Reports;
/*
%CMA9_Reports(ATMS);
%CMA9_Reports(BRANCHES);
*/

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



/*
PROC EXPORT DATA = Work.Danske_Bank_PCA
            OUTFILE= "H:\STV\Open Banking\SAS\Temp\Danske_Bank_PCA.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

PROC EXPORT DATA = Work.Danske_Bank_BCA
            OUTFILE= "H:\STV\Open Banking\SAS\Temp\Danske_Bank_BCA.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

PROC EXPORT DATA = Work.Danske_Bank_SME
            OUTFILE= "H:\STV\Open Banking\SAS\Temp\Danske_Bank_SME.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;




*--- Print BRANCHES Report ---;
Proc Print Data = OpenData.CMA9_BRANCHES;
Title1 "Open Banking - BRANCHES";
Title2 "CMA9 Raw Data Comparison &fdate";
Run;

*--- Print PCA Report ---;
Proc Print Data = OpenData.CMA9_PCA;
Title1 "Open Banking - PCA";
Title2 "CMA9 Raw Data Comparison &fdate";
Run;

*--- Print BCA Report ---;
Proc Print Data = OpenData.CMA9_BCA;
Title1 "Open Banking - BCA";
Title2 "CMA9 Raw Data Comparison &fdate";
Run;

*--- Print SME Report ---;
Proc Print Data = OpenData.CMA9_SME;
Title1 "Open Banking - SME";
Title2 "CMA9 Raw Data Comparison &fdate";
Run;

*--- Print CCC Report ---;
Proc Print Data = OpenData.CMA9_CCC;
Title1 "Open Banking - CCC";
Title2 "CMA9 Raw Data Comparison &fdate";
Run;

