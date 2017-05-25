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
*===============================================================================================*;

*--- Set X path variable to the default directory ---;
X "cd H:\STV\Open Banking\SAS\Temp\";

*--- Set the Library path where the permanent datasets will be saved ---;
Libname OpenData "H:\STV\Open Banking\SAS\Temp";

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


*--- The Main macro will execute the code to extract data from the API end points ---;
%Macro Main(Url,Bank,Api);
 
Filename API Temp;
/*Filename API "H:\STV\Open Banking\SAS\Temp";*/
 
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

/*Proc Print Data = Work.&Bank._&API;*/
/**	Where V NE 0;*/
/*Run;*/

%Mend Main;
/*
*------------------------------------------------------------------------------------------------------
											ATMS
-------------------------------------------------------------------------------------------------------;

%Main(https://openapi.bankofireland.com/open-banking/v1.2/atms,Bank_of_Ireland,ATMS);
%Main(https://api.bankofscotland.co.uk/open-banking/v1.2/atms,Bank_of_Scotland,ATMS);
%Main(https://atlas.api.barclays/open-banking/v1.3/atms,Barclays,ATMS);
%Main(https://obp-api.danskebank.com/open-banking/v1.2/atms,Danske_Bank,ATMS);
%Main(https://api.firsttrustbank.co.uk/open-banking/v1.2/atms,First_Trust_Bank,ATMS);
%Main(https://api.halifax.co.uk/open-banking/v1.2/atms,Halifax,ATMS);
%Main(https://api.hsbc.com/open-banking/v1.2/atms,HSBC,ATMS);
%Main(https://api.lloydsbank.com/open-banking/v1.2/atms,Lloyds_Bank,ATMS);
%Main(https://openapi.nationwide.co.uk/open-banking/v1.2/atms,Nationwide,ATMS);
%Main(https://openapi.natwest.com/open-banking/v1.2/atms,Natwest,ATMS);
%Main(https://openapi.rbs.co.uk/open-banking/v1.2/atms,RBS,ATMS);
%Main(https://api.santander.co.uk/retail/open-banking/v1.2/atms,Santander,ATMS);
%Main(https://openapi.ulsterbank.co.uk/open-banking/v1.2/atms,Ulster_Bank,ATMS);

*--- Find unique Hierarchy values for ATMS ---;
%Macro UniqueATM(API);
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

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OpenData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniqueATM;
%UniqueATM(ATMS);


*--- Append ATMS Datasets ---;
Data OpenData.CMA9_ATMS(Drop = P1-P7);
	Merge OpenData.NoDUP_CMA9_ATMS
	Bank_of_Ireland_ATMS
	Bank_of_Scotland_ATMS
	Barclays_ATMS
	Danske_Bank_ATMS
	Halifax_ATMS
	HSBC_ATMS
	Lloyds_Bank_ATMS
	Nationwide_ATMS
	Natwest_ATMS
	RBS_ATMS
	Santander_ATMS
	Ulster_Bank_ATMS;
	By Hierarchy;

*--- Call the macro in the Where statement to filter the required data elements ---;
*	Where Data_Element in (%Filter);

Run;

*------------------------------------------------------------------------------------------------------
											BRANCHES
-------------------------------------------------------------------------------------------------------;
%Main(https://openapi.bankofireland.com/open-banking/v1.2/branches,Bank_of_Ireland,BRANCHES);
%Main(https://api.bankofscotland.co.uk/open-banking/v1.2/branches,Bank_of_Scotland,BRANCHES);
%Main(https://atlas.api.barclays/open-banking/v1.3/branches,Barclays,BRANCHES);
%Main(https://obp-api.danskebank.com/open-banking/v1.2/branches,Danske_Bank,BRANCHES);
%Main(https://api.firsttrustbank.co.uk/open-banking/v1.2/branches,First_Trust_Bank,BRANCHES);
%Main(https://api.halifax.co.uk/open-banking/v1.2/branches,Halifax,BRANCHES);
%Main(https://api.hsbc.com/open-banking/v1.2/branches,HSBC,BRANCHES);
%Main(https://api.lloydsbank.com/open-banking/v1.2/branches,Lloyds_Bank,BRANCHES);
%Main(https://openapi.nationwide.co.uk/open-banking/v1.2/branches,Nationwide,BRANCHES);
%Main(https://openapi.natwest.com/open-banking/v1.2/branches,Natwest,BRANCHES);
%Main(https://openapi.rbs.co.uk/open-banking/v1.2/branches,RBS,BRANCHES);
%Main(https://api.santander.co.uk/retail/open-banking/v1.2/branches,Santander,BRANCHES);
%Main(https://openapi.ulsterbank.co.uk/open-banking/v1.2/branches,Ulster_Bank,BRANCHES);

*--- Get unique Hierarchy values for Branches ---;
%Macro UniqueBRANCHES(API);
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

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OpenData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniqueBRANCHES;
%UniqueBRANCHES(BRANCHES);

*--- Append BRANCHES Datasets ---;
Data OpenData.CMA9_BRANCHES(Drop = P1-P7);
	Merge OpenData.NoDUP_CMA9_BRANCHES
	Work.Bank_of_Ireland_BRANCHES
	Work.Bank_of_Scotland_BRANCHES
	Work.Barclays_BRANCHES
	Work.Danske_Bank_BRANCHES
	Work.Halifax_BRANCHES
	Work.HSBC_BRANCHES
	Work.Lloyds_Bank_BRANCHES
	Work.Nationwide_BRANCHES
	Work.Natwest_BRANCHES
	Work.RBS_BRANCHES
	Work.Santander_BRANCHES
	Work.Ulster_Bank_BRANCHES;
	By Hierarchy;

*--- Call the macro in the Where statement to filter the required data elements ---;
*	Where Data_Element in (%Filter);

Run;
*/
*------------------------------------------------------------------------------------------------------
											PCA
-------------------------------------------------------------------------------------------------------;
%Main(https://openapi.bankofireland.com/open-banking/v1.2/personal-current-accounts,Bank_of_Ireland,PCA);
%Main(https://api.bankofscotland.co.uk/open-banking/v1.2/personal-current-accounts,Bank_of_Scotland,PCA);
%Main(https://atlas.api.barclays/open-banking/v1.3/personal-current-accounts,Barclays,PCA);
%Main(https://obp-api.danskebank.com/open-banking/v1.2/personal-current-accounts,Danske_Bank,PCA);
%Main(https://api.firsttrustbank.co.uk/open-banking/v1.2/personal-current-accounts,First_Trust_Bank,PCA);
%Main(https://api.halifax.co.uk/open-banking/v1.2/personal-current-accounts,Halifax,PCA);
%Main(https://api.hsbc.com/open-banking/v1.2/personal-current-accounts,HSBC,PCA);
%Main(https://api.lloydsbank.com/open-banking/v1.2/personal-current-accounts,Lloyds_Bank,PCA);
%Main(https://openapi.nationwide.co.uk/open-banking/v1.2/personal-current-accounts,Nationwide,PCA);
%Main(https://openapi.natwest.com/open-banking/v1.2/personal-current-accounts,Natwest,PCA);
%Main(https://openapi.rbs.co.uk/open-banking/v1.2/personal-current-accounts,RBS,PCA);
%Main(https://api.santander.co.uk/retail/open-banking/v1.2/personal-current-accounts,Santander,PCA);
%Main(https://openapi.ulsterbank.co.uk/open-banking/v1.2/personal-current-accounts,Ulster_Bank,PCA);

*--- Get unique Hierarchy values for PCA ---;
%Macro UniquePCA(API);
Data Work.NoDUP_CMA9_&API;
	Set Work.Bank_of_Ireland_&API
		Work.Bank_of_Scotland_&API
		Work.Barclays_&API
		Work.Danske_Bank_&API
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
		Out = OpenData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniquePCA;
%UniquePCA(PCA);

*--- Append PCA Datasets ---;
Data OpenData.CMA9_PCA(Drop = P1-P7);
	Merge OpenData.NoDUP_CMA9_PCA
	Work.Bank_of_Ireland_PCA
	Work.Bank_of_Scotland_PCA
	Work.Barclays_PCA
	Work.Danske_Bank_PCA
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

Data OpenData.CMA9_PCA;
	Set OpenData.CMA9_PCA;
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

*------------------------------------------------------------------------------------------------------
											BCA
-------------------------------------------------------------------------------------------------------;
%Main(https://api.aibgb.co.uk/open-banking/v1.2/business-current-accounts,AIB_Group,BCA);
%Main(https://openapi.bankofireland.com/open-banking/v1.2/business-current-accounts,Bank_of_Ireland,BCA);
%Main(https://api.bankofscotland.co.uk/open-banking/v1.2/business-current-accounts,Bank_of_Scotland,BCA);
%Main(https://atlas.api.barclays/open-banking/v1.3/business-current-accounts,Barclays,BCA);
%Main(https://obp-api.danskebank.com/open-banking/v1.2/business-current-accounts,Danske_Bank,BCA);
%Main(https://api.firsttrustbank.co.uk/open-banking/v1.2/business-current-accounts,First_Trust_Bank,BCA);
/*%Main(https://api.halifax.co.uk/open-banking/v1.2/business-current-accounts,Halifax,BCA);*/
%Main(https://api.hsbc.com/open-banking/v1.2/personal-current-accounts,HSBC,BCA);
%Main(https://api.lloydsbank.com/open-banking/v1.2/business-current-accounts,Lloyds_Bank,BCA);
/*%Main(https://openapi.nationwide.co.uk/open-banking/v1.2/business-current-accounts,Nationwide,BCA);*/
%Main(https://openapi.natwest.com/open-banking/v1.2/business-current-accounts,Natwest,BCA);
%Main(https://openapi.rbs.co.uk/open-banking/v1.2/business-current-accounts,RBS,BCA);
%Main(https://api.santander.co.uk/retail/open-banking/v1.2/business-current-accounts,Santander,BCA);
%Main(https://openapi.ulsterbank.co.uk/open-banking/v1.2/business-current-accounts,Ulster_Bank,BCA);

*--- Get unique Hierarchy values for BCA ---;
%Macro UniqueBCA(API);
Data Work.NoDUP_CMA9_&API;
	Set Work.AIB_Group_&API
		Work.Bank_of_Ireland_&API
		Work.Bank_of_Scotland_&API
		Work.Barclays_&API
		Work.Danske_Bank_&API
		Work.First_Trust_Bank_&API
	/*	Work.Halifax_BCA*/
		Work.HSBC_&API
		Work.Lloyds_Bank_&API
	/*	Work.Nationwide_BCA*/
		Work.Natwest_&API
		Work.RBS_&API
		Work.Santander_&API
		Work.Ulster_Bank_&API;
	By P1-P7;
	Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OpenData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniqueBCA;
%UniqueBCA(BCA);

*--- Append BCA Datasets ---;
Data OpenData.CMA9_BCA(Drop = P1-P7);
	Merge OpenData.NoDUP_CMA9_BCA
	Work.AIB_Group_BCA
	Work.Bank_of_Ireland_BCA
	Work.Bank_of_Scotland_BCA
	Work.Barclays_BCA
	Work.Danske_Bank_BCA
	Work.First_Trust_Bank_BCA
/*	Work.Halifax_BCA*/
	Work.HSBC_BCA
	Work.Lloyds_Bank_BCA
/*	Work.Nationwide_BCA*/
	Work.Natwest_BCA
	Work.RBS_BCA
	Work.Santander_BCA
	Work.Ulster_Bank_BCA;
	By Hierarchy;
Run;

Data OpenData.CMA9_BCA;
	Set OpenData.CMA9_BCA;
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

*------------------------------------------------------------------------------------------------------
											SME
-------------------------------------------------------------------------------------------------------;
%Main(https://api.aibgb.co.uk/open-banking/v1.2/unsecured-sme-loans,AIB_Group, SME);
%Main(https://openapi.bankofireland.com/open-banking/v1.2/unsecured-sme-loans,Bank_of_Ireland,SME);
%Main(https://api.bankofscotland.co.uk/open-banking/v1.2/unsecured-sme-loans,Bank_of_Scotland,SME);
%Main(https://atlas.api.barclays/open-banking/v1.3/unsecured-sme-loans,Barclays,SME);
%Main(https://obp-api.danskebank.com/open-banking/v1.2/unsecured-sme-loans,Danske_Bank,SME);
%Main(https://api.firsttrustbank.co.uk/open-banking/v1.2/unsecured-sme-loans,First_Trust_Bank,SME);
/*%Main(https://api.halifax.co.uk/open-banking/v1.2/unsecured-sme-loans,Halifax,SME);*/
%Main(https://api.hsbc.com/open-banking/v1.2/unsecured-sme-loans,HSBC,SME);
%Main(https://api.lloydsbank.com/open-banking/v1.2/unsecured-sme-loans,Lloyds_Bank,SME);
/*%Main(https://openapi.nationwide.co.uk/open-banking/v1.2/unsecured-sme-loans,Nationwide,SME);*/
%Main(https://openapi.natwest.com/open-banking/v1.2/unsecured-sme-loans,Natwest,SME);
%Main(https://openapi.rbs.co.uk/open-banking/v1.2/unsecured-sme-loans,RBS,SME);
%Main(https://api.santander.co.uk/retail/open-banking/v1.2/unsecured-sme-loans,Santander,SME);
%Main(https://openapi.ulsterbank.co.uk/open-banking/v1.2/unsecured-sme-loans,Ulster_Bank,SME);

*--- Get unique Hierarchy values for SME ---;
%Macro UniqueSME(API);
Data Work.NoDUP_CMA9_&API;

	Set Work.AIB_Group_&API
		Work.Bank_of_Ireland_&API
		Work.Bank_of_Scotland_&API
		Work.Barclays_&API
		Work.Danske_Bank_&API
		Work.First_Trust_Bank_&API
	/*	Work.Halifax_SME*/
		Work.HSBC_&API
		Work.Lloyds_Bank_&API
	/*	Work.Nationwide_SME*/
		Work.Natwest_&API
		Work.RBS_&API
		Work.Santander_&API
		Work.Ulster_Bank_&API;
	By P1-P7;
	Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OpenData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniqueSME;
%UniqueSME(SME);


*--- Append SME Datasets ---;
Data OpenData.CMA9_SME(Drop = P1-P7);
	Merge OpenData.NoDUP_CMA9_SME
	Work.AIB_Group_SME
	Work.Bank_of_Ireland_SME
	Work.Bank_of_Scotland_SME
	Work.Barclays_SME
	Work.Danske_Bank_SME
	Work.First_Trust_Bank_SME
/*	Work.Halifax_SME*/
	Work.HSBC_SME
	Work.Lloyds_Bank_SME
/*	Work.Nationwide_SME*/
	Work.Natwest_SME
	Work.RBS_SME
	Work.Santander_SME
	Work.Ulster_Bank_SME;
	By Hierarchy;
Run;

Data OpenData.CMA9_SME;
	Set OpenData.CMA9_SME;
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

*------------------------------------------------------------------------------------------------------
											CCC
-------------------------------------------------------------------------------------------------------;
%Main(https://openapi.bankofireland.com/open-banking/v1.2/commercial-credit-cards,Bank_of_Ireland,CCC);
/*%Main(https://api.bankofscotland.co.uk/open-banking/v1.2/commercial-credit-cards,Bank_of_Scotland,CCC);*/
%Main(https://atlas.api.barclays/open-banking/v1.3/commercial-credit-cards,Barclays,CCC);
/*%Main(https://obp-api.danskebank.com/open-banking/v1.2/commercial-credit-cards,Danske_Bank,CCC);*/
/*%Main(https://api.halifax.co.uk/open-banking/v1.2/commercial-credit-cards,Halifax,CCC);*/
%Main(https://api.hsbc.com/open-banking/v1.2/commercial-credit-cards,HSBC,CCC);
%Main(https://api.lloydsbank.com/open-banking/v1.2/commercial-credit-cards,Lloyds_Bank,CCC);
/*%Main(https://openapi.nationwide.co.uk/open-banking/v1.2/commercial-credit-cards,Nationwide,CCC);*/
%Main(https://openapi.natwest.com/open-banking/v1.2/commercial-credit-cards,Natwest,CCC);
%Main(https://openapi.rbs.co.uk/open-banking/v1.2/commercial-credit-cards,RBS,CCC);
%Main(https://api.santander.co.uk/retail/open-banking/v1.2/commercial-credit-cards,Santander,CCC);
/*%Main(https://openapi.ulsterbank.co.uk/open-banking/v1.2/commercial-credit-cards,Ulster_Bank,CCC);*/

*--- Get unique Hierarchy values for CCC ---;
%Macro UniqueCCC(API);
Data Work.NoDUP_CMA9_&API;

	Set Work.Bank_of_Ireland_CCC
	/*	Work.Bank_of_Scotland_CCC*/
		Work.Barclays_CCC
	/*	Work.Danske_Bank_CCC*/
	/*	Work.Halifax_CCC*/
		Work.HSBC_CCC
		Work.Lloyds_Bank_CCC
	/*	Work.Nationwide_CCC*/
		Work.Natwest_CCC
		Work.RBS_CCC
		Work.Santander_CCC
	/*	Work.Ulster_Bank_CCC;*/;
	By P1-P7;
	Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy) 
		Out = OpenData.NoDUP_CMA9_&API NoDupKey;
		By Hierarchy;
	Run;

%Mend UniqueCCC;
%UniqueCCC(CCC);


*--- Append CCC Datasets ---;
Data OpenData.CMA9_CCC(Drop = P1-P7);
	Merge OpenData.NoDUP_CMA9_CCC
	Work.Bank_of_Ireland_CCC
/*	Work.Bank_of_Scotland_CCC*/
	Work.Barclays_CCC
/*	Work.Danske_Bank_CCC*/
/*	Work.Halifax_CCC*/
	Work.HSBC_CCC
	Work.Lloyds_Bank_CCC
/*	Work.Nationwide_CCC*/
	Work.Natwest_CCC
	Work.RBS_CCC
	Work.Santander_CCC
/*	Work.Ulster_Bank_CCC;*/;
	By Hierarchy;
Run;

Data OpenData.CMA9_CCC;
	Set OpenData.CMA9_CCC;
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

*--- Set Title Date in Proc Print ---;
%Macro Fdate(Fmt);
   %Global Fdate;
   Data _Null_;
      Call Symput("Fdate",Left(Put("&Sysdate"d,&Fmt)));
   Run;
%Mend Fdate;
%Fdate(Worddate.)

*--- Run Macro to Print the CMA9 Reports for ATMS, BRANCHES, PCA, etc ---;
%Macro CMA9_Reports(API);
*--- Set Output Delivery Parameters  ---;
ODS _All_ Close;
ODS HTML Body="Compare_CMA9_&API..html" 
	Contents="Compare_contents_&API..html" 
	Frame="Compare_frame_&API..html" 
	Style=HTMLBlue;
ODS Graphics On;

*--- Sort dataset by the RowCnt value to set the table in the original JSON script order ---; 
Proc Sort Data = OpenData.CMA9_&API;
	By RowCnt;
Run;

*--- Print ATMS Report ---;
Proc Print Data = OpenData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;

/*
PROC EXPORT DATA = OPENDATA.CMA9_&API(Drop=Bank_API P Count RowCnt) 
            OUTFILE= "H:\STV\Open Banking\SAS\Temp\CMA9_&API..csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
*/

*--- Close Output Delivery Parameters  ---;
ODS HTML Close;


ODS CSV File="H:\STV\Open Banking\SAS\Temp\CMA9_&API..csv";
Proc Print Data=OpenData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
ODS CSV Close;

ODS HTML File="H:\STV\Open Banking\SAS\Temp\CMA9_&API..xls";
Proc Print Data=OpenData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
ODS HTML Close;

ODS Listing;

%Mend CMA9_Reports;
*%CMA9_Reports(ATMS);
*%CMA9_Reports(BRANCHES);
%CMA9_Reports(PCA);
%CMA9_Reports(BCA);
%CMA9_Reports(SME);
%CMA9_Reports(CCC);

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
