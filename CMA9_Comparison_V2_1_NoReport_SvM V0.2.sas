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
*	Updates - 8 April 2017:																		*
*	Version 1.1 created on 7 April 2017.														*
*	Includes an update of the ODS CSV export code. This was implemented because Proc Export		*
*	include new line characters from Excel and splits the data over multiple lines whereby the	*
*	structure of the CSV file is broken. ODS CSV functionality does a direct export of the		*
*	data in SAS to Excel/CSV.																	*
*																								*
*	9 February 2018:																			*
*	Updated the P1-P7 with (P1-P&_P_Val) functionality to automate the number of P1 columns.						*
*	Update the URLs for AIB and First Trust Bank												*
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
%Global _P_Max;
%Global API;

%Let _SRVNAME = localhost;
%Let _Host = &_SRVNAME;
%Put _Host = &_Host;
%Let _P_Max = 0;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;


*--- Un-comment this section to run program locally from Desktop ---;
*%Let _action = CMA9 COMPARISON ATMS;
%Let _action = CMA9 COMPARISON BRANCHES;
*%Let _action = CMA9 COMPARISON BCA;
*%Let _action = CMA9 COMPARISON PCA;
*%Let _action = CMA9 COMPARISON SME;
*%Let _action = CMA9 COMPARISON CCC;


*--- Set Default Data Library as macro variable ---;
*--- Alternatively set the Data library in Proc Appsrv ---;

%Let Path = C:\inetpub\wwwroot\sasweb\Data\Perm;

*--- Set X path variable to the default directory ---;
X "cd &Path";

*--- Set the Library path where the permanent datasets will be saved ---;
Libname OBData "&Path";


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

Data Work.&Bank._&API._Sort(Keep = P) X;
	Set LibAPIs.Alldata/*(Where=(V NE 0))*/;
Run;

Proc Sort Data = Work.&Bank._&API._Sort;
	By Decending P;
Run;

*--- Set the P value in the _P_Val macro to loop through the number of P* columns to build Hierarchies ---;
Data _Null_;
	Set Work.&Bank._&API._Sort(Obs = 1);
	Call Symput('_P_Val',Trim(Left(Put(P,3.))));
Run;

*--- Keep the highest _P_Val in _P_Max to delete all P1 - P* columns from final dataset ---;
Data _Null_;
	Set Work.&Bank._&API._Sort(Obs = 1);
	If P > &_P_Max then
	Do;
		Call Symput('_P_Max',Trim(Left(Put(P,3.))));
	End;
Run;


Data Work.&Bank._&API
	(Keep = RowCnt Count P Bank_API Var2 Var3 V P1 - P&_P_Val Value 
	Rename=(Var3 = Data_Element Var2 = Hierarchy Value = &Bank)) X1;

	Length Bank_API $ 8 Var2 Value1 Value2 $ 250 Var3 $ 100 P1 - P&_P_Val Value $ 700;

	RowCnt = _N_;

*--- The variable V contains the first level of the Hierarchy which has no Bank information ---;
	Set LibAPIs.Alldata/*(Where=(V NE 0))*/;
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
/*
Data Work.X2;
	Set Work.X1;
	By RowCnt;

	If Var2 EQ 'data-Brand-PCA-Name' Then
	Do;
		_Record_ID + 1;
		_Hier_ID = 0;
		_Element_ID = 0;
	End;
	If V = 0 Then 
	Do;
		_Hier_ID + 1;
		_Element_ID = 0;
	End;
	Else If _Hier_ID = 0 and V = 1 Then
	Do;
		_Element_ID = 0;
	End;
	Else If _Hier_ID > 0 and V = 1 Then
	Do;
		_Element_ID + 1;
	End;
	Retain _Record_ID _Hier_ID _Element_ID;
Run;
*/

Proc Sort Data = Work.&Bank._&API;
	By P1-P&_P_Val;
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

*--- Create Unique Data_Element Names ---;
	Data Work.NoDUP_CMA9_&API;
		Set Work.NoDUP_CMA9_&API;

		If Hierarchy = 'data-Brand-ATM-Location-OtherLocationCategory-Code' Then Data_Element = 'OtherLocationCategoryCode';
		If Hierarchy = 'data-Brand-ATM-OtherAccessibility-Code' Then Data_Element = 'OtherAccessibilityCode';
		*--- Description ---;
		If Hierarchy = 'data-Brand-ATM-Location-OtherLocationCategory-Description' Then Data_Element = 'OtherLocationCategoryDesc';
		If Hierarchy = 'data-Brand-ATM-OtherATMServices-Description' Then Data_Element = 'OtherATMServicesDesc';
		If Hierarchy = 'data-Brand-ATM-OtherAccessibility-Description' Then Data_Element = 'OtherAccessibilityDesc';
		*--- Identification ---;
		If Hierarchy = 'data-Brand-ATM-Branch-Identification' Then Data_Element = 'BranchIdentification';
		If Hierarchy = 'data-Brand-ATM-Identification' Then Data_Element = 'ATMIdentification';
		If Hierarchy = 'data-Brand-ATM-Location-Site-Identification' Then Data_Element = 'LocationSiteIdentification';
		*--- Name ---;
		If Hierarchy = 'data-Brand-ATM-Location-OtherLocationCategory-Name' Then Data_Element = 'OtherLocationCategoryName';
		If Hierarchy = 'data-Brand-ATM-Location-Site-Name' Then Data_Element = 'LocationSiteName';
		If Hierarchy = 'data-Brand-ATM-OtherATMServices-Name' Then Data_Element = 'OtherATMServicesName';
		If Hierarchy = 'data-Brand-ATM-OtherAccessibility-Name' Then Data_Element = 'OtherAccessibilityName';
Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy Data_Element) 
	Out = Work.NoDUP_CMA9_&API Nodupkey;
	By Hierarchy;
	Run;

%Mend UniqueATM;
%If "&_action" EQ "CMA9 COMPARISON ATMS" %Then
%Do;
%UniqueATM(ATM);
%End;

%If "&_action" EQ "CMA9 COMPARISON ATMS" %Then
%Do;

	%Macro CreateIDs(APIDSN,Bankname);
	*--- Append PCA Datasets ---;
	Data Work.&APIDSN(Drop = P1-P&_P_Max);
		Merge Work.NoDUP_CMA9_ATM(In=a)
		Work.&APIDSN(In=b Drop = Data_Element);
		By Hierarchy;
		If a and b;
		Length Bank_Name $ 25;
		Bank_Name = "&Bankname";
	Run;
	*--- Sort by Row count to get the order of the rows correct ---;
	Proc Sort Data = Work.&APIDSN;
		By RowCnt;
	Run;
	Data Work.&APIDSN;
		Set Work.&APIDSN;
		If Hierarchy = 'data-Brand-BrandName' Then
		Do;
			_Record_ID = 0;
		End;
		If Hierarchy = 'data-Brand-ATM-Identification' Then
		Do;
			_Record_ID + 1;
			_MarkStateID = 1;
		End;
		/*
		If Hierarchy = 'data-Brand-PCA-PCAMarketingState' Then
		Do;
			_MarkStateID + 1;
	 	End;
		*/
		Retain _Record_ID _MarkStateID;
	Run;

	%Mend CreateIDs;
	%CreateIDs(Bank_of_Ireland_ATM,Bank_of_Ireland);
	%CreateIDs(Bank_of_Scotland_ATM,Bank_of_Scotland);
	%CreateIDs(Barclays_ATM,Barclays);
	%CreateIDs(Danske_Bank_ATM,Danske_Bank);
	%CreateIDs(First_Trust_Bank_ATM,First_Trust_Bank);
	%CreateIDs(Halifax_ATM,Halifax);
	%CreateIDs(HSBC_ATM,HSBC);
	%CreateIDs(Lloyds_Bank_ATM,Lloyds_Bank);
	%CreateIDs(Nationwide_ATM,Nationwide);
	%CreateIDs(Natwest_ATM,Natwest);	
	%CreateIDs(RBS_ATM,RBS);
	%CreateIDs(Santander_ATM,Santander);
	%CreateIDs(Ulster_Bank_ATM,Ulster_Bank);

	%Let Datasets =;
	%Macro ConcatDsn(DsName);
		%If %Sysfunc(exist(&DsName)) %Then
		%Do;
			%Let DSNX = &DsName;
			%Put DSNX = &DSNX;

			%Let Datasets = &Datasets &DSNX;
			%Put Datasets = &Datasets;
		%End;
	%Mend ConcatDsn;
	%ConcatDsn(Bank_of_Ireland_ATM);
	%ConcatDsn(Bank_of_Scotland_ATM);
	%ConcatDsn(Barclays_ATM);
	%ConcatDsn(Danske_Bank_ATM);
	%ConcatDsn(First_Trust_Bank_ATM);
	%ConcatDsn(Halifax_ATM);
	%ConcatDsn(HSBC_ATM);
	%ConcatDsn(Lloyds_Bank_ATM);
	%ConcatDsn(Nationwide_ATM);
	%ConcatDsn(Natwest_ATM);
	%ConcatDsn(RBS_ATM);
	%ConcatDsn(Santander_ATM);
	%ConcatDsn(Ulster_Bank_ATM);

	Data OBData.CMA9_ATM;
		Set &Datasets;
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

*--- Create Unique Data_Element Names ---;
	Data Work.NoDUP_CMA9_&API;
		Set Work.NoDUP_CMA9_&API;
		If Hierarchy = 'data-Brand-Branch-Availability-NonStandardAvailability-Day-OpeningHours-ClosingTime' Then Data_Element = 'NonStandardClosingTime';
		If Hierarchy = 'data-Brand-Branch-Availability-StandardAvailability-Day-OpeningHours-ClosingTime' Then Data_Element = 'StandardClosingTime';
		*--- Day ---;
		If Hierarchy = 'data-Brand-Branch-Availability-NonStandardAvailability-Day' Then Data_Element = 'NonStandardAvailabilityDay';
		If Hierarchy = 'data-Brand-Branch-Availability-StandardAvailability-Day' Then Data_Element = 'StandardAvailabilityDay';
		*--- Description ---;
		If Hierarchy = 'data-Brand-Branch-ContactInfo-OtherContactType-Description' Then Data_Element = 'OtherContactTypeDesc';
		If Hierarchy = 'data-Brand-Branch-OtherServiceAndFacility-Description' Then Data_Element = 'OtherServiceFacilityDesc';
		*--- Name ---;
		If Hierarchy = 'data-Brand-Branch-Availability-NonStandardAvailability-Day-Name' Then Data_Element = 'NonStandardDayName';
		If Hierarchy = 'data-Brand-Branch-Availability-NonStandardAvailability-Name' Then Data_Element = 'NonStandardName';
		If Hierarchy = 'data-Brand-Branch-Availability-StandardAvailability-Day-Name' Then Data_Element = 'StandardDayName';
		If Hierarchy = 'data-Brand-Branch-ContactInfo-OtherContactType-Name' Then Data_Element = 'OtherContactTypeName';
		If Hierarchy = 'data-Brand-Branch-Name' Then Data_Element = 'BranchName';
		If Hierarchy = 'data-Brand-Branch-OtherServiceAndFacility-Name' Then Data_Element = 'OtherServiceFacilityName';
		*--- Name ---;
		If Hierarchy = 'data-Brand-Branch-Availability-NonStandardAvailability-Notes' Then Data_Element = 'NonStandardNotes';
		If Hierarchy = 'data-Brand-Branch-Availability-StandardAvailability-Day-Notes' Then Data_Element = 'StandardDayNotes';
		*--- Notes ---;
		If Hierarchy = 'data-Brand-Branch-Availability-NonStandardAvailability-Notes' Then Data_Element = 'NonStandardAvailabilityNotes';
		If Hierarchy = 'data-Brand-Branch-Availability-StandardAvailability-Day-Notes' Then Data_Element = 'StandardAvailabilityDayNotes';
		*--- OpeningHours ---;
		If Hierarchy = 'data-Brand-Branch-Availability-NonStandardAvailability-Day-OpeningHours' Then Data_Element = 'NonStandardDayOpeningHours';
		If Hierarchy = 'data-Brand-Branch-Availability-StandardAvailability-Day-OpeningHours' Then Data_Element = 'StandardDayOpeningHours';
		*--- OpeningTime ---;
		If Hierarchy = 'data-Brand-Branch-Availability-NonStandardAvailability-Day-OpeningHours-OpeningTime' Then Data_Element = 'NonStandardDayOpeningTime';
		If Hierarchy = 'data-Brand-Branch-Availability-StandardAvailability-Day-OpeningHours-OpeningTime' Then Data_Element = 'StandardDayOpeningTime';
Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy Data_Element) 
	Out = Work.NoDUP_CMA9_&API Nodupkey;
	By Hierarchy;
	Run;

%Mend UniqueBRANCHES;

%If "&_action" EQ "CMA9 COMPARISON BRANCHES" %Then
%Do;
%UniqueBRANCHES(BCH);
%End;

%If "&_action" EQ "CMA9 COMPARISON BRANCHES" %Then
%Do;

	%Macro CreateIDs(APIDSN,Bankname);
	*--- Append PCA Datasets ---;
	Data Work.&APIDSN(Drop = P1-P&_P_Max);
		Merge Work.NoDUP_CMA9_BCH(In=a)
		Work.&APIDSN(In=b Drop = Data_Element);
		By Hierarchy;
		If a and b;
		Length Bank_Name $ 25;
		Bank_Name = "&Bankname";
	Run;
	*--- Sort by Row count to get the order of the rows correct ---;
	Proc Sort Data = Work.&APIDSN;
		By RowCnt;
	Run;
	Data Work.&APIDSN;
		Set Work.&APIDSN;
		If Hierarchy = 'data-Brand-BrandName' Then
		Do;
			_Record_ID = 0;
		End;
*--- Add this step just for Branches to get the counter correct as Identification is only
		at the end of the Hierarchy values for a specific BrandName ---;
		If Substr(Hierarchy,1,4) NE 'meta' and 
			Hierarchy NE 'data-Brand-BrandName' and 
			_Record_ID = 0 Then
		Do;
			_Record_ID = 1;
			_MarkStateID = 1;
		End;
		If Hierarchy = 'data-Brand-Branch-Identification' Then
		Do;
			_Record_ID + 1;
			_MarkStateID = 1;
		End;
		/*
		If Hierarchy = 'data-Brand-PCA-PCAMarketingState' Then
		Do;
			_MarkStateID + 1;
	 	End;
		*/
		Retain _Record_ID _MarkStateID;
	Run;

	%Mend CreateIDs;
	%CreateIDs(Bank_of_Ireland_BCH,Bank_of_Ireland);
	%CreateIDs(Bank_of_Scotland_BCH,Bank_of_Scotland);
	%CreateIDs(Barclays_BCH,Barclays);
	%CreateIDs(Danske_Bank_BCH,Danske_Bank);
	%CreateIDs(First_Trust_Bank_BCH,First_Trust_Bank);
	%CreateIDs(Halifax_BCH,Halifax);
	%CreateIDs(HSBC_BCH,HSBC);
	%CreateIDs(Lloyds_Bank_BCH,Lloyds_Bank);
	%CreateIDs(Nationwide_BCH,Nationwide);
	%CreateIDs(Natwest_BCH,Natwest);	
	%CreateIDs(RBS_BCH,RBS);
	%CreateIDs(Santander_BCH,Santander);
	%CreateIDs(Ulster_Bank_BCH,Ulster_Bank);

	%Let Datasets =;
	%Macro ConcatDsn(DsName);
		%If %Sysfunc(exist(&DsName)) %Then
		%Do;
			%Let DSNX = &DsName;
			%Put DSNX = &DSNX;

			%Let Datasets = &Datasets &DSNX;
			%Put Datasets = &Datasets;
		%End;
	%Mend ConcatDsn;
	%ConcatDsn(Bank_of_Ireland_BCH);
	%ConcatDsn(Bank_of_Scotland_BCH);
	%ConcatDsn(Barclays_BCH);
	%ConcatDsn(Danske_Bank_BCH);
	%ConcatDsn(First_Trust_Bank_BCH);
	%ConcatDsn(Halifax_BCH);
	%ConcatDsn(HSBC_BCH);
	%ConcatDsn(Lloyds_Bank_BCH);
	%ConcatDsn(Nationwide_BCH);
	%ConcatDsn(Natwest_BCH);
	%ConcatDsn(RBS_BCH);
	%ConcatDsn(Santander_BCH);
	%ConcatDsn(Ulster_Bank_BCH);

	Data OBData.CMA9_BCH;
		Set &Datasets;
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
	%TestDsn(Bank_of_Ireland_PCA);
	%TestDsn(Bank_of_Scotland_PCA);
	%TestDsn(Barclays_PCA);
	%TestDsn(Danske_Bank_PCA);
	%TestDsn(First_Trust_Bank_PCA);
	%TestDsn(Halifax_PCA);
	%TestDsn(HSBC_PCA);
	%TestDsn(Lloyds_Bank_PCA);
	%TestDsn(Nationwide_PCA);
	%TestDsn(Natwest_PCA);
	%TestDsn(RBS_PCA);
	%TestDsn(Santander_PCA);
	%TestDsn(Ulster_Bank_PCA);

	Data Work.NoDUP_CMA9_&API;
		Set &Datasets;
	Run;

*--- Create Unique Data_Element Names ---;
	Data Work.NoDUP_CMA9_&API;
		Set Work.NoDUP_CMA9_&API;

*--- Amount ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-Amount' Then Data_Element = 'CreditIntEligAmount';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Eligibility-OtherEligibility-Amount' Then Data_Element = 'OtherEligAmount';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Amount' Then Data_Element = 'FeatureBenefitEligAmount';

*--- ApplicationFrequency ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeDetail-ApplicationFrequency' Then Data_Element = 'FeeChargeAppFreq';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-ApplicationFrequency' Then Data_Element = 'OverDraftFeeChargeAppFreq';

*--- CalculationFrequency ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeDetail-CalculationFrequency' Then Data_Element = 'FeeChargeCalcFreq';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-CalculationFrequency' Then Data_Element = 'OverDraftFeeChargeCalcFreq';

*--- Description ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-Description' Then Data_Element = 'CreditIntEligDesc';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Eligibility-OtherEligibility-Description' Then Data_Element = 'OtherEligDesc';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-OtherType-Description' Then Data_Element = 'FeatBenefitGroupOtherDesc';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Description' Then Data_Element = 'FeatBenefitItemDesc';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-OtherType-Description' Then Data_Element = 'FeatBenefitItemOtherDesc';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-MobileWallet-OtherType-Description' Then Data_Element = 'MobileWalletOtherDesc';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeDetail-OtherFeeType-Description' Then Data_Element = 'FeeChargeOtherTypeDesc';

*--- FeeAmount ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeDetail-FeeAmount' Then Data_Element = 'FeeChargeAmount';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-FeeAmount' Then Data_Element = 'OverdraftFeeChargeAmount';

*--- FeeCategory ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeDetail-FeeCategory' Then Data_Element = 'FeeChargeFeeCategory';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeDetail-OtherFeeType-FeeCategory' Then Data_Element = 'FeeChargeOtherFeeCategory';

*--- FeeType ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeCap-FeeType' Then Data_Element = 'FeeChargeCapFeeType';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeDetail-FeeType' Then Data_Element = 'FeeChargeDetailFeeType';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-FeeType' Then Data_Element = 'OverdraftFeeChargeFeeType';

*--- Indetification ---;
	If Hierarchy = 'data-Brand-PCA-Identification' Then Data_Element = 'PCAIdentification';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-CreditInterest-TierBandSet-TierBand-Identification' Then Data_Element = 'TierBandIdentification';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Identification' Then Data_Element = 'FeatureBenGroupIdentification';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Identification' Then Data_Element = 'FeatureBenItemIdentification';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Identification' Then Data_Element = 'MarkStateIdentification';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Overdraft-OverdraftTierBandSet-Identification' Then Data_Element = 'OverdraftIdentification';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-Identification' Then Data_Element = 'OverdraftTierBandIdentification';

*--- Indetification ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Eligibility-OtherEligibility-Indicator' Then Data_Element = 'OtherEligIndicator';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Indicator' Then Data_Element = 'FeatureBenefitEligIndicator';

*--- Name ---;
	If Hierarchy = 'data-Brand-PCA-Name' Then Data_Element = 'ProductName';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-Name' Then Data_Element = 'CreditIntEligName';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Eligibility-OtherEligibility-Name' Then Data_Element = 'OtherEligName';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Name' Then Data_Element = 'FeatureBenefitItemName';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-Name' Then Data_Element = 'FeatureBenefitGrpName';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-OtherType-Name' Then Data_Element = 'FeatureBenefitGrpOtherName';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Name' Then Data_Element = 'FeatureBenefitEligName';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-OtherType-Name' Then Data_Element = 'FeatureBenefitEligOtherName';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Name' Then Data_Element = 'FeatureBenefitItemName';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-MobileWallet-OtherType-Name' Then Data_Element = 'MobileWalletOtherTypeName';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeDetail-OtherFeeType-Name' Then Data_Element = 'FeeChargeOtherFeeTypeName';


*--- Notes ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-CreditInterest-TierBandSet-Notes' Then Data_Element = 'CreditIntTierBandSetNotes';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Eligibility-AgeEligibility-Notes' Then Data_Element = 'AgeEligibilityNotes';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Eligibility-OtherEligibility-Notes' Then Data_Element = 'OtherEligibilityNotes';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Eligibility-ResidencyEligibility-Notes' Then Data_Element = 'ResidencyEligibilityNotes';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-Card-Notes' Then Data_Element = 'FeatureBenefitsCardNotes';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Notes' Then Data_Element = 'FeatureBenefitGrpItemNotes';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-Notes' Then Data_Element = 'FeatureBenefitGrpNotes';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Notes' Then Data_Element = 'FeatureBenefitItemNotes';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-MobileWallet-Notes' Then Data_Element = 'MobileWalletNotes';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Notes' Then Data_Element = 'PCAMarketingStateNotes';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeCap-Notes' Then Data_Element = 'FeeChargeCapNotes';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeDetail-Notes' Then Data_Element = 'FeeChargeDetailNotes';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-Notes' Then Data_Element = 'OverdraftFeeChargeNotes';

*--- Notes1 ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-CreditInterest-TierBandSet-Notes-Notes1' Then Data_Element = 'TierBandSetNotes1';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Eligibility-AgeEligibility-Notes-Notes1' Then Data_Element = 'AgeEligibilityNotes1';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Eligibility-OtherEligibility-Notes-Notes1' Then Data_Element = 'OtherEligibilityNotes1';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Eligibility-ResidencyEligibility-Notes-Notes1' Then Data_Element = 'ResidencyEligNotes1';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-Card-Notes-Notes1' Then Data_Element = 'FeatureBenefitsCardNotes1';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Notes-Notes1' Then Data_Element = 'FeatureBenefitItemNotes1';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-Notes-Notes1' Then Data_Element = 'FeatureBenefitGrpNotes1';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Notes-Notes1' Then Data_Element = 'FeatureBenefitItemNotes1';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-MobileWallet-Notes-Notes1' Then Data_Element = 'MobileWalletNotes1';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Notes-Notes1' Then Data_Element = 'PCAMarketingStateNotes1';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeCap-Notes-Notes1' Then Data_Element = 'FeeChargeCapNotes1';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeDetail-Notes-Notes1' Then Data_Element = 'FeeChargeDetailNotes1';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-Notes-Notes1' Then Data_Element = 'OverdraftFeeChargeNotes1';

*--- Notes2 ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Notes-Notes2' Then Data_Element = 'FeatureBenefitItemNotes2';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Notes-Notes2' Then Data_Element = 'FeatureBenefitItemNotes2';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeDetail-Notes-Notes2' Then Data_Element = 'FeeChargeDetailNotes2';


*--- Notes2 ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Notes-Notes3' Then Data_Element = 'FeatureBenefitItemNotes3';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-OtherFeesCharges-FeeChargeDetail-Notes-Notes3' Then Data_Element = 'FeeChargeDetailNotes3';

*--- OtherType ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-OtherType' Then Data_Element = 'FeatureBenefitGrpOtherType';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-OtherType' Then Data_Element = 'FeatureBenefitEligOtherType';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-MobileWallet-OtherType' Then Data_Element = 'MobileWalletOtherType';

*--- Period ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-Period' Then Data_Element = 'CreditIntEligPeriod';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Period' Then Data_Element = 'FeatureBenefitEligPeriod';

*--- Textual ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Textual' Then Data_Element = 'FeatureBenefitItemTextual';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Textual' Then Data_Element = 'FeatureBenefitEligTextual';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Textual' Then Data_Element = 'FeatureBenefitItemTextual';

*--- Method ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-CreditInterest-TierBandSet-TierBandMethod' Then Data_Element = 'TierBandMethod';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Overdraft-OverdraftTierBandSet-TierBandMethod' Then Data_Element = 'OverdraftTierBandSetMethod';

*--- Type ---;
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-Type' Then Data_Element = 'CreditInterestEligType';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-Eligibility-OtherEligibility-Type' Then Data_Element = 'OtherEligType';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-Card-Type' Then Data_Element = 'FeaturesBenefitsCardType';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Type' Then Data_Element = 'FeatureBenefitGrpItemType';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-Type' Then Data_Element = 'FeatureBenefitGrpType';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Type' Then Data_Element = 'FeatureBenefitEligType';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Type' Then Data_Element = 'FeatureBenefitItemType';
	If Hierarchy = 'data-Brand-PCA-PCAMarketingState-FeaturesAndBenefits-MobileWallet-Type' Then Data_Element = 'MobileWalletType';
Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy Data_Element) 
	Out = Work.NoDUP_CMA9_&API Nodupkey;
	By Hierarchy;
	Run;


%Mend UniquePCA;
%If "&_action" EQ "CMA9 COMPARISON PCA" %Then
%Do;
	%UniquePCA(PCA);
%End;

%If "&_action" EQ "CMA9 COMPARISON PCA" %Then
%Do;

	%Macro CreateIDs(APIDSN,Bankname);
	*--- Append PCA Datasets ---;
	Data Work.&APIDSN(Drop = P1-P&_P_Max);
		Merge Work.NoDUP_CMA9_PCA(In=a)
		Work.&APIDSN(In=b Drop = Data_Element);
		By Hierarchy;
		If a and b;
		Length Bank_Name $ 25;
		Bank_Name = "&Bankname";
	Run;
	*--- Sort by Row count to get the order of the rows correct ---;
	Proc Sort Data = Work.&APIDSN;
		By RowCnt;
	Run;
	Data Work.&APIDSN;
		Set Work.&APIDSN;
		If Hierarchy = 'data-Brand-BrandName' Then
		Do;
			_Record_ID = 0;
		End;
		If Hierarchy = 'data-Brand-PCA-Name' Then
		Do;
			_Record_ID + 1;
			_MarkStateID = 0;
		End;
		If Hierarchy = 'data-Brand-PCA-PCAMarketingState' Then
		Do;
			_MarkStateID + 1;
	 	End;
		Retain _Record_ID _MarkStateID;
	Run;

	%Mend CreateIDs;
	%CreateIDs(Bank_of_Ireland_PCA,Bank_of_Ireland);
	%CreateIDs(Bank_of_Scotland_PCA,Bank_of_Scotland);
	%CreateIDs(Barclays_PCA,Barclays);
	%CreateIDs(Danske_Bank_PCA,Danske_Bank);
	%CreateIDs(First_Trust_Bank_PCA,First_Trust_Bank);
	%CreateIDs(Halifax_PCA,Halifax);
	%CreateIDs(HSBC_PCA,HSBC);
	%CreateIDs(Lloyds_Bank_PCA,Lloyds_Bank);
	%CreateIDs(Nationwide_PCA,Nationwide);
	%CreateIDs(Natwest_PCA,Natwest);	
	%CreateIDs(RBS_PCA,RBS);
	%CreateIDs(Santander_PCA,Santander);
	%CreateIDs(Ulster_Bank_PCA,Ulster_Bank);


	%Let Datasets =;
	%Macro ConcatDsn(DsName);
		%If %Sysfunc(exist(&DsName)) %Then
		%Do;
			%Let DSNX = &DsName;
			%Put DSNX = &DSNX;

			%Let Datasets = &Datasets &DSNX;
			%Put Datasets = &Datasets;
		%End;
	%Mend ConcatDsn;
	%ConcatDsn(Bank_of_Ireland_PCA);
	%ConcatDsn(Bank_of_Scotland_PCA);
	%ConcatDsn(Barclays_PCA);
	%ConcatDsn(Danske_Bank_PCA);
	%ConcatDsn(First_Trust_Bank_PCA);
	%ConcatDsn(Halifax_PCA);
	%ConcatDsn(HSBC_PCA);
	%ConcatDsn(Lloyds_Bank_PCA);
	%ConcatDsn(Nationwide_PCA);
	%ConcatDsn(Natwest_PCA);
	%ConcatDsn(RBS_PCA);
	%ConcatDsn(Santander_PCA);
	%ConcatDsn(Ulster_Bank_PCA);

	Data OBData.CMA9_PCA;
		Set &Datasets;
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
	%Main(https://openapi.firsttrustbank.co.uk/open-banking/v2.1/business-current-accounts,First_Trust_Bank,BCA);
	%Main(https://api.hsbc.com/open-banking/v2.1/business-current-accounts,HSBC,BCA);
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
	%TestDsn(AIB_Group_BCA);
	%TestDsn(Bank_of_Ireland_BCA);
	%TestDsn(Bank_of_Scotland_BCA);
	%TestDsn(Barclays_BCA);
	%TestDsn(Danske_Bank_BCA);
	%TestDsn(First_Trust_Bank_BCA);
	%TestDsn(HSBC_BCA);
	%TestDsn(Lloyds_Bank_BCA);
	%TestDsn(Natwest_BCA);
	%TestDsn(RBS_BCA);
	%TestDsn(Santander_BCA);
	%TestDsn(Ulster_Bank_BCA);
	%TestDsn(Coutts_BCA);
	%TestDsn(Adam_Bank_BCA);

	Data Work.NoDUP_CMA9_&API;
		Set &Datasets;
	Run;

*--- Create Unique Data_Element Names ---;
	Data Work.NoDUP_CMA9_&API;
		Set Work.NoDUP_CMA9_&API;

		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-Amount' Then Data_Element = 'CreditInterestAmount';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-TradingHistoryEligibility-Amount' Then Data_Element = 'EligibilityAmount';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Amount' Then Data_Element = 'FeatureBenefitEligAmount';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Amount' Then Data_Element = 'FeatureBenefitGrpItemAmount';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Amount' Then Data_Element = 'FeatureBenefitGrpItemEligAmount';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Amount' Then Data_Element = 'FeatureBenefitItemAmount';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Amount' Then Data_Element = 'FeatureBenefitItemEligAmount';
		*--- ApplicationFrequency ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-TierBand-ApplicationFrequency' Then Data_Element = 'TierBandAppFreq';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-ApplicationFrequency' Then Data_Element = 'FeatureBenefitGrpAppFreq';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-ApplicationFrequency' Then Data_Element = 'FeeChargeDetailAppFreq';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-ApplicationFrequency' Then Data_Element = 'OverdraftFeeChargeDetailAppFreq';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-ApplicationFrequency' Then Data_Element = 'OverdraftTierbandAppFreq';

		*--- CalculationFrequency ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-TierBand-CalculationFrequency' Then Data_Element = 'TierBandCalcFreq';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-CalculationFrequency' Then Data_Element = 'FeatureBenefitGrpCalcFreq';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-CalculationFrequency' Then Data_Element = 'FeeChargeDetailCalcFreq';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-CalculationFrequency' Then Data_Element = 'OverdraftFeeChargeDetailCalcFreq';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-CalculationFrequency' Then Data_Element = 'OverdraftTierbandCalcFreq';

		*--- CappingPeriod ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeCap-CappingPeriod' Then Data_Element = 'FeeChargeCapPeriod';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeCap-CappingPeriod' Then Data_Element = 'OverdraftFeeChargeCapPeriod';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeCap-CappingPeriod' Then Data_Element = 'OverdraftTierbandCapPeriod';
		*--- Code ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OfficerEligibility-OtherOfficerType-Code' Then Data_Element = 'EligOtherOfficerTypeCode';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-OtherType-Code' Then Data_Element = 'FeatureBenefitItemOtherTypeCode';
		*--- Description ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-Description' Then Data_Element = 'CreditIntEligDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-OtherType-Description' Then Data_Element = 'CreditIntEligOtherTypeDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-IndustryEligibility-OtherSICCode-Description' Then Data_Element = 'OtherSICCodeDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-LegalStructureEligibility-OtherLegalStructure-Description' Then Data_Element = 'OtherLegalStructureDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OfficerEligibility-OtherOfficerType-Description' Then Data_Element = 'OtherOfficerTypeDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OtherEligibility-Description' Then Data_Element = 'OtherEligibilityDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OtherEligibility-OtherType-Description' Then Data_Element = 'OtherEligOtherTypeDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-Card-OtherType-Description' Then Data_Element = 'CardOtherTypeDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Description' Then Data_Element = 'FeatureBenefitGrpEligDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-OtherType-Description' Then Data_Element = 'FeatureBenItemGrpOtherTypeDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-OtherType-Description' Then Data_Element = 'FeatureBenGrpOtherTypeDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Description' Then Data_Element = 'FeatureBenItemEligDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-OtherType-Description' Then Data_Element = 'FeatureBenItemOtherTypeDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeCap-OtherFeeType-Description' Then Data_Element = 'FeeChargeCapOtherFeeTypeDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-OtherFeeType-Description' Then Data_Element = 'FeeChargeDetailOtherFeeTypeDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-OtherApplicationFrequency-Description' Then Data_Element = 'OtherAppFreqDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-OtherCalculationFrequency-Description' Then Data_Element = 'OtherCalcFreqDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-OtherApplicationFrequency-Description' Then Data_Element = 'OverdraftFeeChargeAppFreqDesc';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-OtherCalculationFrequency-Description' Then Data_Element = 'OverdraftFeeChargeCalcFreqDesc';
		*--- FeatureBenefitEligibility ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility' Then Data_Element = 'FeatureBenefitGrpElig';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility' Then Data_Element = 'FeatureBenefitGrpItemElig';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility' Then Data_Element = 'FeatureBenefitElig';
		*--- FeatureBenefitItem ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem' Then Data_Element = 'FeatureBenefitGrpItem';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem' Then Data_Element = 'FeatureBenefitItem';
		*--- FeeAmount ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-FeeAmount' Then Data_Element = 'OtherFeesChargesAmount';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-FeeAmount' Then Data_Element = 'OverdraftFeesChargesAmount';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-FeeAmount' Then Data_Element = 'OverdraftTierBandAmount';
		*--- FeeCapAmount ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeCap-FeeCapAmount' Then Data_Element = 'OtherFeesChargesFeeCapAmount';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeCap-FeeCapAmount' Then Data_Element = 'OverdraftTierBandSetFeeCapAmount';
		*--- FeeCapOccurrence ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeCap-FeeCapAmount' Then Data_Element = 'OverdraftFeeCapAmount';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeCap-FeeCapOccurrence' Then Data_Element = 'OverdraftFeeCapOccurrence';
		*--- FeeCategory ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-FeeCategory' Then Data_Element = 'FeeChargeDetailFeeCategory';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-OtherFeeType-FeeCategory' Then Data_Element = 'OtherFeeTypeFeeCategory';
		*--- FeeRate ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-FeeRate' Then Data_Element = 'FeeChargeDetailFeeRate';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-FeeRate' Then Data_Element = 'OverdraftFeesChargesFeeRate';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-FeeRate' Then Data_Element = 'OverdraftTierBandFeeRate';
		*--- FeeRateType ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-FeeRateType' Then Data_Element = 'FeeChargeDetailFeeRateType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-FeeRateType' Then Data_Element = 'OverdraftFeesChargesFeeRateType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-FeeRateType' Then Data_Element = 'OverdraftTierBandFeeRateType';
		*--- FeeType ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeCap-FeeType' Then Data_Element = 'FeeChargeCapFeeType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-FeeType' Then Data_Element = 'FeeChargeDetailFeeType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeCap-FeeType' Then Data_Element = 'OverdraftFeeChargeCapFeeType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-FeeType' Then Data_Element = 'OverdraftFeeChargeDetailFeeType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeCap-FeeType' Then Data_Element = 'OverdraftTierbandCapFeeType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-FeeType' Then Data_Element = 'OverdraftTierbandFeeType';
		*--- FeeType1 ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeCap-FeeType-FeeType1' Then Data_Element = 'FeeChargeCapFeeType1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeCap-FeeType-FeeType1' Then Data_Element = 'OverdraftFeesChargesFeeType1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeCap-FeeType-FeeType1' Then Data_Element = 'OverdraftTierBandFeeType1';
		*--- FeeType2 ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeCap-FeeType-FeeType2' Then Data_Element = 'FeeChargeCapFeeType2';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeCap-FeeType-FeeType2' Then Data_Element = 'OverdraftFeeChargeCapFeeType2';
		*--- FeeType3 ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeCap-FeeType-FeeType3' Then Data_Element = 'FeeChargeCapFeeType3';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeCap-FeeType-FeeType3' Then Data_Element = 'OverdraftFeeChargeCapFeeType3';
		*--- Identification ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-TierBand-Identification' Then Data_Element = 'CreditIntIndentification';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Identification' Then Data_Element = 'FeatureBenGrpItemIndentification';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Identification' Then Data_Element = 'FeatureBenItemIndentification';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Identification' Then Data_Element = 'BCAMarketingStateIdentification';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-Identification' Then Data_Element = 'OverdraftIdentification';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-Identification' Then Data_Element = 'OverdraftTierBandIdentification';
		If Hierarchy = 'data-Brand-BCA-Identification' Then Data_Element = 'BCAIdentification';
		*--- Indicator ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-Indicator' Then Data_Element = 'CreditIntEligIndicator';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OtherEligibility-Indicator' Then Data_Element = 'OtherEligIndicator';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-TradingHistoryEligibility-Indicator' Then Data_Element = 'TradingHistEligibIndicator';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Indicator' Then Data_Element = 'FeatureBenGrpEligIndicator';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Indicator' Then Data_Element = 'FeatureBenItemEligIndicator';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Indicator' Then Data_Element = 'FeatureBenGrpItemIndicator';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Indicator' Then Data_Element = 'FeatureBenEligIndicator';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Indicator' Then Data_Element = 'FeatureBenItemIndicator';
		*--- MinMaxType ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-TradingHistoryEligibility-MinMaxType' Then Data_Element = 'TradingHistEligibMinMaxType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeCap-MinMaxType' Then Data_Element = 'FeeChargeCapMinMaxType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeCap-MinMaxType' Then Data_Element = 'OverdraftFeeChargeCapMinMaxType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeCap-MinMaxType' Then Data_Element = 'OverdraftTierbandCapMinMaxType';
		*--- Name ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-Name' Then Data_Element = 'CreditIntEligName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-OtherType-Name' Then Data_Element = 'CreditIntEligOtherTypeName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-IndustryEligibility-OtherSICCode-Name' Then Data_Element = 'OtherSICCodeName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-LegalStructureEligibility-OtherLegalStructure-Name' Then Data_Element = 'OtherLegalStructureName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OfficerEligibility-OtherOfficerType-Name' Then Data_Element = 'OfficerEligOtherOfficerTypeName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OtherEligibility-Name' Then Data_Element = 'OtherEligName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OtherEligibility-OtherType-Name' Then Data_Element = 'OtherEligOtherTypeName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-Card-OtherType-Name' Then Data_Element = 'FeaturesBenCardOtherTypeName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Name' Then Data_Element = 'FeatureBenGrpEligName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Name' Then Data_Element = 'FeatureBenGrpItemEligName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Name' Then Data_Element = 'FeatureBenGrpItemName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-OtherType-Name' Then Data_Element = 'FeatureBenGrpItemOtherTypeName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-Name' Then Data_Element = 'FeatureBenefitGrpName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-OtherType-Name' Then Data_Element = 'FeatureBenGrpOtherTypeName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Name' Then Data_Element = 'FeatureBenItemEligName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Name' Then Data_Element = 'FeatureBenItemName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-OtherType-Name' Then Data_Element = 'FeatureBenOtherTypeName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeCap-OtherFeeType-Name' Then Data_Element = 'FeeChargeCapOtherFeeTypeName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-OtherFeeType-Name' Then Data_Element = 'FeeChargeDetailOtherFeeTypeName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-OtherApplicationFrequency-Name' Then Data_Element = 'OverdraftFeeOtherAppFreqName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-OtherCalculationFrequency-Name' Then Data_Element = 'OverdraftFeeOtherCalcFreqName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-OtherApplicationFrequency-Name' Then Data_Element = 'OverdraftTierbandAppFreqName';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-OtherCalculationFrequency-Name' Then Data_Element = 'OverdraftTierbandCalcFreqName';
		If Hierarchy = 'data-Brand-BCA-Name' Then Data_Element = 'BrandBCAName';
		*--- Negotiator ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-NegotiableIndicator' Then Data_Element = 'FeeChargeNegotiableIndicator';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-NegotiableIndicator' Then Data_Element = 'OverdraftTierbandNegleIndicator';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-NegotiableIndicator' Then Data_Element = 'OverdraftFeeChargeNegIndicator';
		*--- Notes ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CoreProduct-Notes' Then Data_Element = 'CoreProductNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-Notes' Then Data_Element = 'CreditIntTierBandSetNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-TierBand-Notes' Then Data_Element = 'CreditIntTierBandNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-AgeEligibility-Notes' Then Data_Element = 'AgeEligibilityNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-CreditCheckEligibility-Notes' Then Data_Element = 'CreditCheckEligNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-IDEligibility-Notes' Then Data_Element = 'IDEligNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-LegalStructureEligibility-Notes' Then Data_Element = 'LegalStructureEligNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OfficerEligibility-Notes' Then Data_Element = 'OfficerEligNotes';

		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OtherEligibility-Notes' Then Data_Element = 'OtherEligNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-ResidencyEligibility-Notes' Then Data_Element = 'ResidencyEligNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-TradingHistoryEligibility-Notes' Then Data_Element = 'TradingHistEligNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-Card-Notes' Then Data_Element = 'FeaturesBenCardNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Notes' Then Data_Element = 'FeatureBenGrpEligNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-Notes' Then Data_Element = 'FeatureBenGrpNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Notes' Then Data_Element = 'FeatureBenEligNotes';

		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Notes' Then Data_Element = 'FeatureBenItemNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-MobileWallet-Notes' Then Data_Element = 'MobileWalletNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Notes' Then Data_Element = 'BCAMarketingStateNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeCap-Notes' Then Data_Element = 'FeeChargeCapNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-Notes' Then Data_Element = 'FeeChargeDetailNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-Notes' Then Data_Element = 'OverdraftNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-Notes' Then Data_Element = 'OverdraftTierBandSetNotes';

		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-Notes' Then Data_Element = 'OverdraftFeeChargeDetailNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-Notes' Then Data_Element = 'OverdraftTierBandNotes';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-Notes' Then Data_Element = 'OverdraftTierbandNotes';
		*--- Notes1 ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CoreProduct-Notes-Notes1' Then Data_Element = 'CoreProductNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-Notes-Notes1' Then Data_Element = 'TierBandSetNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-TierBand-Notes-Notes1' Then Data_Element = 'TierBandNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-AgeEligibility-Notes-Notes1' Then Data_Element = 'AgeEligibilityNotes1';

		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-CreditCheckEligibility-Notes-Notes1' Then Data_Element = 'CreditCheckEligNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-IDEligibility-Notes-Notes1' Then Data_Element = 'IDEligNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-LegalStructureEligibility-Notes-Notes1' Then Data_Element = 'LegalStructureEligNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OfficerEligibility-Notes-Notes1' Then Data_Element = 'OfficerEligNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OtherEligibility-Notes-Notes1' Then Data_Element = 'OtherEligNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-ResidencyEligibility-Notes-Notes1' Then Data_Element = 'ResidencyEligNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-TradingHistoryEligibility-Notes-Notes1' Then Data_Element = 'TradingHistEligNotes1';

		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-Card-Notes-Notes1' Then Data_Element = 'FeaturesBenCardNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Notes-Notes1' Then Data_Element = 'FeatureBenItemEligNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-Notes-Notes1' Then Data_Element = 'FeatureBenGrpNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Notes-Notes1' Then Data_Element = 'FeatureBenEligNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Notes-Notes1' Then Data_Element = 'FeatureBenItemNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-MobileWallet-Notes-Notes1' Then Data_Element = 'MobileWalletNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Notes-Notes1' Then Data_Element = 'BCAMarketingStateNotes1';

		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-Notes-Notes1' Then Data_Element = 'FeeChargeDetailNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-Notes-Notes1' Then Data_Element = 'OverdraftTierBandSetNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-Notes-Notes1' Then Data_Element = 'OverdraftFeeChargeNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-Notes-Notes1' Then Data_Element = 'OverdraftTierBandNotes1';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-Notes-Notes1' Then Data_Element = 'OverdraftTierbandNotes1';
		*--- Notes2 ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Notes-Notes2' Then Data_Element = 'BCAMarketingStateNotes2';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-Notes-Notes2' Then Data_Element = 'FeeChargeDetailNotes2';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-Notes-Notes2' Then Data_Element = 'OverdraftTierBandSetNotes2';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-Notes-Notes2' Then Data_Element = 'OverdraftFeeChargeDetailNotes2';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-Notes-Notes2' Then Data_Element = 'OverdraftTierbandNotes2';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Notes-Notes3' Then Data_Element = 'BCAMarketingStateNotes3';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-Notes-Notes3' Then Data_Element = 'OtherFeesChargesDetailNotes3';
		*--- OtherApplicationFrequency ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-OtherApplicationFrequency' Then Data_Element = 'OverdraftFeesChargesOtherAppFreq';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-OtherApplicationFrequency' Then Data_Element = 'OverdraftTierBandOtherAppFreq';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-OtherCalculationFrequency' Then Data_Element = 'OverdraftFeeChargeOtherCalcFreq';
		If Hierarchy = 'OtherCalculationFrequency' Then Data_Element = 'OtherCalcFreq';
		*--- OtherFeeType ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeCap-OtherFeeType' Then Data_Element = 'FeeChargeCapOtherFeeType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-OtherFeesCharges-FeeChargeDetail-OtherFeeType' Then Data_Element = 'FeeChargeDetailOtherFeeType';
		*--- OtherType ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-OtherType' Then Data_Element = 'CreditIntEligOtherType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OtherEligibility-OtherType' Then Data_Element = 'OtherEligOtherType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-Card-OtherType' Then Data_Element = 'FeaturesBenCardOtherType';

		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-OtherType' Then Data_Element = 'FeatureBenefitGrpItemOtherType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-OtherType' Then Data_Element = 'FeatureBenGrpOtherType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-OtherType' Then Data_Element = 'FeatureBenItemOtherType';
		*--- OverdraftControlIndicator ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail-OverdraftControlIndicator' Then Data_Element = 'OverdraftFeesChargesIndicator';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail-OverdraftControlIndicator' Then Data_Element = 'OverdraftTierbandIndicator';
		*--- OverdraftFeeChargeCap ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeCap' Then Data_Element = 'OverdraftFeesChargesFeeChargeCap';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeCap' Then Data_Element = 'OverdraftTierBandFeeChargeCap';
		*--- OverdraftFeeChargeDetail ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges-OverdraftFeeChargeDetail' Then Data_Element = 'OverdraftFeesChargesDetail';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges-OverdraftFeeChargeDetail' Then Data_Element = 'OverdraftTierBandFeeChargeDetail';
		*--- OverdraftFeesCharges ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftFeesCharges' Then Data_Element = 'OverdraftTierBandSetFeesCharges';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-OverdraftTierBand-OverdraftFeesCharges' Then Data_Element = 'OverdraftTierBandFeesCharges';
		*--- Period ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-Period' Then Data_Element = 'CreditIntEligPeriod';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-TradingHistoryEligibility-Period' Then Data_Element = 'TradingHistEligtPeriod';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Period' Then Data_Element = 'FeatureBenEligPeriod';

		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Period' Then Data_Element = 'FeatureBenGrpEligPeriod';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Period' Then Data_Element = 'FeatureBenefitItemEligPeriod';
		*--- TcsAndCsURL ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CoreProduct-TcsAndCsURL' Then Data_Element = 'CoreProductTcsAndCsURL';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-TcsAndCsURL' Then Data_Element = 'OverdraftTcsAndCsURL';
		*--- Textual ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OtherEligibility-Textual' Then Data_Element = 'OtherEligTextual';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-TradingHistoryEligibility-Textual' Then Data_Element = 'TradingHistEligTextual';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Textual' Then Data_Element = 'FeatureBenefitItemTextual';

		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Textual' Then Data_Element = 'FeatureBenItemTextual';
		*--- TierBandMethod ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-TierBandMethod' Then Data_Element = 'CreditIntTierbandSetMethod';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Overdraft-OverdraftTierBandSet-TierBandMethod' Then Data_Element = 'OverdraftTierBandSetMethod';
		*--- Type ---;
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-CreditInterest-TierBandSet-CreditInterestEligibility-Type' Then Data_Element = 'CreditIntEligType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-Eligibility-OtherEligibility-Type' Then Data_Element = 'OtherEligibilityType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-Card-Type' Then Data_Element = 'FeaturesBenCardType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Type' Then Data_Element = 'FeatureBenGrpEligType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Type' Then Data_Element = 'FeatureBenGrpItemEligType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Type' Then Data_Element = 'FeatureBenGrpItemType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-Type' Then Data_Element = 'FeatureBenGrpType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Type' Then Data_Element = 'FeatureBenEligType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Type' Then Data_Element = 'FeatureBenItemType';
		If Hierarchy = 'data-Brand-BCA-BCAMarketingState-FeaturesAndBenefits-MobileWallet-Type' Then Data_Element = 'MobileWalletType';
Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy Data_Element) 
	Out = Work.NoDUP_CMA9_&API Nodupkey;
	By Hierarchy;
	Run;


%Mend UniqueBCA;
%If "&_action" EQ "CMA9 COMPARISON BCA" %Then
%Do;
	%UniqueBCA(BCA);
%End;

%If "&_action" EQ "CMA9 COMPARISON BCA" %Then
%Do;

	%Macro CreateIDs(APIDSN,Bankname);
	*--- Append BCA Datasets ---;
	Data Work.&APIDSN(Drop = P1-P&_P_Max);
		Merge Work.NoDUP_CMA9_BCA(In=a)
		Work.&APIDSN(In=b Drop = Data_Element);
		By Hierarchy;
		If a and b;
		Length Bank_Name $ 25;
		Bank_Name = "&Bankname";
	Run;
	*--- Sort by Row count to get the order of the rows correct ---;
	Proc Sort Data = Work.&APIDSN;
		By RowCnt;
	Run;
	Data Work.&APIDSN;
		Set Work.&APIDSN;
		If Hierarchy = 'data-Brand-BrandName' Then
		Do;
			_Record_ID = 0;
		End;
		If Hierarchy = 'data-Brand-BCA-Name' Then
		Do;
			_Record_ID + 1;
			_MarkStateID = 0;
		End;
		If Hierarchy = 'data-Brand-BCA-PCAMarketingState' Then
		Do;
			_MarkStateID + 1;
	 	End;
		Retain _Record_ID _MarkStateID;
	Run;

	%Mend CreateIDs;
	%CreateIDs(AIB_Group_BCA,AIB_Group);
	%CreateIDs(Bank_of_Ireland_BCA,Bank_of_Ireland);
	%CreateIDs(Bank_of_Scotland_BCA,Bank_of_Scotland);
	%CreateIDs(Barclays_BCA,Barclays);
	%CreateIDs(Danske_Bank_BCA,Danske_Bank);
	%CreateIDs(First_Trust_Bank_BCA,First_Trust_Bank);
	%CreateIDs(HSBC_BCA,HSBC);
	%CreateIDs(Lloyds_Bank_BCA,Lloyds_Bank);
	%CreateIDs(Natwest_BCA,Natwest);	
	%CreateIDs(RBS_BCA,RBS);
	%CreateIDs(Santander_BCA,Santander);
	%CreateIDs(Ulster_Bank_BCA,Ulster_Bank);
	%CreateIDs(Coutts_BCA,Coutts);
	%CreateIDs(Adam_Bank_BCA,Adam_Bank);

	%Let Datasets =;
	%Macro ConcatDsn(DsName);
		%If %Sysfunc(exist(&DsName)) %Then
		%Do;
			%Let DSNX = &DsName;
			%Put DSNX = &DSNX;

			%Let Datasets = &Datasets &DSNX;
			%Put Datasets = &Datasets;
		%End;
	%Mend ConcatDsn;
	%ConcatDsn(AIB_Group_BCA);
	%ConcatDsn(Bank_of_Ireland_BCA);
	%ConcatDsn(Bank_of_Scotland_BCA);
	%ConcatDsn(Barclays_BCA);
	%ConcatDsn(Danske_Bank_BCA);
	%ConcatDsn(First_Trust_Bank_BCA);
	%ConcatDsn(HSBC_BCA);
	%ConcatDsn(Lloyds_Bank_BCA);
	%ConcatDsn(Natwest_BCA);
	%ConcatDsn(RBS_BCA);
	%ConcatDsn(Santander_BCA);
	%ConcatDsn(Ulster_Bank_BCA);
	%ConcatDsn(Coutts_BCA);
	%ConcatDsn(Adam_Bank_BCA);

	Data OBData.CMA9_BCA;
		Set &Datasets;
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

*--- Create Unique Data_Element Names ---;
	Data Work.NoDUP_CMA9_&API;
		Set Work.NoDUP_CMA9_&API;

		*--- Amounts ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OtherEligibility-Amount' Then Data_Element = 'OtherEligAmount';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-TradingHistoryEligibility-Amount' Then Data_Element = 'TradingHistEligAmount';
		*--- ApplicationFrequency ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-ApplicationFrequency' Then Data_Element = 'LoanIntFeeChargeDetailAppFreq';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-ApplicationFrequency' Then Data_Element = 'LoanIntTierbandAppFreq';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeDetail-ApplicationFrequency' Then Data_Element = '';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentFeeCharges-RepaymentFeeChargeDetail-ApplicationFrequency' Then Data_Element = '';
		*--- CalculationFrequency ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-CalculationFrequency' Then Data_Element = 'LoanIntFeesChargesCalcFreq';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-CalculationFrequency' Then Data_Element = 'LoanIntTierbandCalcFreq';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeDetail-CalculationFrequency' Then Data_Element = 'OtherFeesChargesCalcFreq';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentFeeCharges-RepaymentFeeChargeDetail-CalculationFrequency' Then Data_Element = 'RepaymentFeeChargeCalcFreq';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-CalculationMethod' Then Data_Element = 'LoanIntTierBandSetCalcMethod';
		*--- Description ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OfficerEligibility-OtherOfficerType-Description' Then Data_Element = 'OfficerEligDesc';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OtherEligibility-Description' Then Data_Element = 'OtherEligDesc';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OtherEligibility-OtherType-Description' Then Data_Element = 'OtherEligOtherTypeDesc';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-OtherType-Description' Then Data_Element = 'FeatureBenEligDesc';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-OtherType-Description' Then Data_Element = 'FeatureBenItemEligDesc';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeCap-OtherFeeType-Description' Then Data_Element = 'OtherFeesChargesCapDesc';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-OtherRepaymentType-Description' Then Data_Element = 'OtherRepaymentTypeDesc';
		*--- FeatureBenefitEligibility ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility' Then Data_Element = 'FeatureBenGrpEligibility';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility' Then Data_Element = 'FeatureBenGrpItemEligibility';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility' Then Data_Element = 'FeatureBenEligibility';
		*--- FeatureBenefitItem ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem' Then Data_Element = 'FeatureBenefitGrpItem';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem' Then Data_Element = 'FeatureBenefitItem';
		*--- FeeAmount ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-FeeAmount' Then Data_Element = 'LoanIntFeeChargeFeeAmount';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeDetail-FeeAmount' Then Data_Element = 'OtherFeesChargesFeeAmount';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentFeeCharges-RepaymentFeeChargeDetail-FeeAmount' Then Data_Element = 'RepaymentFeesChargeFeeAmount';
		*--- FeeCapAmount ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeCap-FeeCapAmount' Then Data_Element = 'LoanIntFeesChargesFeeCapAmount';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeCap-FeeCapAmount' Then Data_Element = 'LoanIntTierbandFeeCapAmount';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeCap-FeeCapAmount' Then Data_Element = 'OtherFeesChargesFeeCapAmount';
		If Hierarchy = 'FeeCapAmount' Then Data_Element = '';
		*--- FeeRate ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-FeeRate' Then Data_Element = '';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeDetail-FeeRate' Then Data_Element = '';
		*--- FeeRateType ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-FeeRateType' Then Data_Element = 'LoanInterestFeeRateType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeDetail-FeeRateType' Then Data_Element = 'OtherFeesChargesFeeRateType';
		*--- FeeType ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeCap-FeeType' Then Data_Element = 'LoanIntFeeChargeCapFeeType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-FeeType' Then Data_Element = 'LoanIntFeeChargeDetailFeeType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeCap-FeeType' Then Data_Element = 'LoanIntTierbandCapFeeType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-FeeType' Then Data_Element = 'LoanIntTierbandDetailFeeType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeCap-FeeType' Then Data_Element = 'OtherFeesChargesFeeType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeDetail-FeeType' Then Data_Element = 'OtherFeesChargesDetailFeeType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentFeeCharges-RepaymentFeeChargeCap-FeeType' Then Data_Element = 'RepaymentFeeChargeCapFeeType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentFeeCharges-RepaymentFeeChargeDetail-FeeType' Then Data_Element = 'RepaymentFeeChargeDetailFeeType';
		*--- FeeType1 ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeCap-FeeType-FeeType1' Then Data_Element = 'LoanIntFeeChargeCapFeeType1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeCap-FeeType-FeeType1' Then Data_Element = 'LoanIntTierbandCapFeeType1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeCap-FeeType-FeeType1' Then Data_Element = 'OtherFeesChargesCapFeeType1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentFeeCharges-RepaymentFeeChargeCap-FeeType-FeeType1' Then Data_Element = 'RepaymentFeeChargeCapFeeType1';
		*--- Identification ---;
		If Hierarchy = 'data-Brand-SMELoan-Identification' Then Data_Element = 'SMELoanIdentification';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Identification' Then Data_Element = 'FeatureBenItemIdentification';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Identification' Then Data_Element = 'MarketingStateIdentification';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-Identification' Then Data_Element = 'LoanIntTierBandSetIdentification';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-Identification' Then Data_Element = 'LoanIntTierBandIdentification';
		*--- Indicator ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OtherEligibility-Indicator' Then Data_Element = 'OtherEligIndicator';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-TradingHistoryEligibility-Indicator' Then Data_Element = 'TradingHistEligIndicator';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Indicator' Then Data_Element = 'FeatureBenGrpEligIndicator';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Indicator' Then Data_Element = 'FeatureBenGrpItemEligIndicator';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Indicator' Then Data_Element = 'FeatureBenGrpItemIndicator';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Indicator' Then Data_Element = 'FeatureBenEligIndicator';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Indicator' Then Data_Element = 'FeatureBenItemIndicator';
		*--- LoanInterestFeeChargeCap ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeCap' Then Data_Element = 'LoanIntFeeChargeCap';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeCap' Then Data_Element = 'LoanIntTierBandFeeChargeCap';
		*--- LoanInterestFeeChargeDetail ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeDetail' Then Data_Element = 'LoanIntFeeChargeDetail';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeDetail' Then Data_Element = '';
		*--- LoanInterestFeesCharges ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges' Then Data_Element = 'LoanIntFeesCharges';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges' Then Data_Element = 'LoanIntTierBandFeesCharges';
		*--- MinMaxType ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-TradingHistoryEligibility-MinMaxType' Then Data_Element = 'TradingHistEligMinMaxType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeCap-MinMaxType' Then Data_Element = 'LoanIntFeeChargeCapMinMaxType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeCap-MinMaxType' Then Data_Element = 'LoanIntTiebandMinMaxType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeCap-MinMaxType' Then Data_Element = 'OtherFeesChargesCapMinMaxType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentFeeCharges-RepaymentFeeChargeCap-MinMaxType' Then Data_Element = 'RepaymentFeeChargeCapMinMaxType';
		*--- Name ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OtherEligibility-Name' Then Data_Element = 'OtherEligName';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OtherEligibility-OtherType-Name' Then Data_Element = 'OtherEligOtherTypeName';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Name' Then Data_Element = 'FeatureBenGrpEligName';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-OtherType-Name' Then Data_Element = 'FeatureBenGrpEligOtherTypeName';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Name' Then Data_Element = 'FeatureBenGrpItemEligName';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-Name' Then Data_Element = 'FeatureBenGrpName';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Name' Then Data_Element = 'FeatureBenItemEligName';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Name' Then Data_Element = 'FeatureBenItemName';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-OtherType-Name' Then Data_Element = 'FeatureBenItemOtherTypeName';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeCap-OtherFeeType-Name' Then Data_Element = 'FeeChargeCapOtherFeeTypeName';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-OtherRepaymentType-Name' Then Data_Element = 'OtherRepaymentTypeName';
		*--- NegotiableIndicator ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-NegotiableIndicator' Then Data_Element = 'LoanIntFeeChargeNegIndicator';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-NegotiableIndicator' Then Data_Element = 'LoanIntTiebandNegIndicator';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeDetail-NegotiableIndicator' Then Data_Element = 'OtherFeesChargesNegIndicator';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentFeeCharges-RepaymentFeeChargeDetail-NegotiableIndicator' Then Data_Element = 'RepaymentFeeChargeNegIndicator';
		*--- Notes ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-CoreProduct-Notes' Then Data_Element = 'CoreProductNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-AgeEligibility-Notes' Then Data_Element = 'AgeEligibilityNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-CreditCheckEligibility-Notes' Then Data_Element = 'CreditCheckEligNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-IDEligibility-Notes' Then Data_Element = 'IDEligNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-IndustryEligibility-Notes' Then Data_Element = 'IndustryEligNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OfficerEligibility-Notes' Then Data_Element = 'OfficerEligNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OtherEligibility-Notes' Then Data_Element = 'OtherEligNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-ResidencyEligibility-Notes' Then Data_Element = 'ResidencyEligNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-TradingHistoryEligibility-Notes' Then Data_Element = 'TradingHistEligNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Notes' Then Data_Element = 'FeatureBenItemNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-Notes' Then Data_Element = 'LoanIntFeeChargeDetailNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-Notes' Then Data_Element = 'LoanIntFeeChargeDetailNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-Notes' Then Data_Element = 'LoanIntTierBandNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-Notes' Then Data_Element = 'LoanIntNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeDetail-Notes' Then Data_Element = 'FeeChargeDetailNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-Notes' Then Data_Element = 'RepaymentNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentFeeCharges-RepaymentFeeChargeCap-Notes' Then Data_Element = 'RepaymentFeeChargeCapNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentFeeCharges-RepaymentFeeChargeDetail-Notes' Then Data_Element = 'RepaymentFeeChargeDetailNotes';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentHoliday-Notes' Then Data_Element = 'RepaymentHolidayNotes';
			*--- Notes1 ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-CoreProduct-Notes-Notes1' Then Data_Element = 'CoreProductNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-AgeEligibility-Notes-Notes1' Then Data_Element = 'AgeEligibilityNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-CreditCheckEligibility-Notes-Notes1' Then Data_Element = 'CreditCheckEligNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-IDEligibility-Notes-Notes1' Then Data_Element = 'IDEligNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-IndustryEligibility-Notes-Notes1' Then Data_Element = 'IndustryEligyNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OfficerEligibility-Notes-Notes1' Then Data_Element = 'OfficerEligNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-ResidencyEligibility-Notes-Notes1' Then Data_Element = 'ResidencyEligNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-TradingHistoryEligibility-Notes-Notes1' Then Data_Element = 'TradingHistEligNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Notes-Notes1' Then Data_Element = 'FeatureBenefitItemNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-Notes-Notes1' Then Data_Element = '';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-LoanInterestFeesCharges-LoanInterestFeeChargeDetail-Notes-Notes1' Then Data_Element = 'LoanIntFeeChargeDetailNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-LoanInterestTierBandSet-LoanInterestTierBand-Notes-Notes1' Then Data_Element = 'LoanIntTierBandNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-LoanInterest-Notes-Notes1' Then Data_Element = 'LoanIntNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-OtherFeesCharges-FeeChargeDetail-Notes-Notes1' Then Data_Element = '';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-Notes-Notes1' Then Data_Element = 'RepaymentNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentFeeCharges-RepaymentFeeChargeCap-Notes-Notes1' Then Data_Element = 'RepaymentFeeChargeCapNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentFeeCharges-RepaymentFeeChargeDetail-Notes-Notes1' Then Data_Element = 'RepaymentFeeChargeDetailNotes1';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Repayment-RepaymentHoliday-Notes-Notes1' Then Data_Element = 'RepaymentHolidayNotes1';
			*--- OtherType ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OtherEligibility-OtherType' Then Data_Element = 'OtherEligOtherType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-OtherType' Then Data_Element = 'FeatureBenGrpEligOtherType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-OtherType' Then Data_Element = 'FeatureBenItemOtherType';
			*--- Textual ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OtherEligibility-Textual' Then Data_Element = 'OtherEligTextual';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-TradingHistoryEligibility-Textual' Then Data_Element = 'TradingHistEligTextual';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Textual' Then Data_Element = 'FeatureBenItemTextual';
			*--- Type ---;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-Eligibility-OtherEligibility-Type' Then Data_Element = 'OtherEligibilityType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Type' Then Data_Element = 'FeatureBenGrpEligType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Type' Then Data_Element = 'FeatureBenGrpItemType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-Type' Then Data_Element = 'FeatureBenGrpType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Type' Then Data_Element = 'FeatureBenItemEligType';
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Type' Then Data_Element = 'FeatureBenItemType';
Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy Data_Element) 
	Out = Work.NoDUP_CMA9_&API Nodupkey;
	By Hierarchy;
	Run;

%Mend UniqueSME;
%If "&_action" EQ "CMA9 COMPARISON SME" %Then
%Do;
	%UniqueSME(SME);
%End;

%If "&_action" EQ "CMA9 COMPARISON SME" %Then
%Do;

	%Macro CreateIDs(APIDSN,Bankname);
	*--- Append BCA Datasets ---;
	Data Work.&APIDSN(Drop = P1-P&_P_Max);
		Merge Work.NoDUP_CMA9_SME(In=a)
		Work.&APIDSN(In=b Drop = Data_Element);
		By Hierarchy;
		If a and b;
		Length Bank_Name $ 25;
		Bank_Name = "&Bankname";
	Run;
	*--- Sort by Row count to get the order of the rows correct ---;
	Proc Sort Data = Work.&APIDSN;
		By RowCnt;
	Run;
	Data Work.&APIDSN;
		Set Work.&APIDSN;
		If Hierarchy = 'data-Brand-BrandName' Then
		Do;
			_Record_ID = 0;
		End;
		If Hierarchy = 'data-Brand-SMELoan-Name' Then
		Do;
			_Record_ID + 1;
			_MarkStateID = 0;
		End;
		If Hierarchy = 'data-Brand-SMELoan-SMELoanMarketingState-MarketingState' Then
		Do;
			_MarkStateID + 1;
	 	End;
		Retain _Record_ID _MarkStateID;
	Run;
	%Mend CreateIDs;
	%CreateIDs(AIB_Group_SME,AIB_Group);
	%CreateIDs(Bank_of_Ireland_SME,Bank_of_Ireland);
	%CreateIDs(Bank_of_Scotland_SME,Bank_of_Scotland);
	%CreateIDs(Barclays_SME,Barclays);
	%CreateIDs(Danske_Bank_SME,Danske_Bank);
	%CreateIDs(ESME_SME,ESME);
	%CreateIDs(First_Trust_Bank_SME,First_Trust_Bank);
	%CreateIDs(HSBC_SME,HSBC);
	%CreateIDs(Lloyds_Bank_SME,Lloyds_Bank);
	%CreateIDs(Natwest_SME,Natwest);	
	%CreateIDs(RBS_SME,RBS);
	%CreateIDs(Santander_SME,Santander);
	%CreateIDs(Ulster_Bank_SME,Ulster_Bank);

	%Let Datasets =;
	%Macro ConcatDsn(DsName);
		%If %Sysfunc(exist(&DsName)) %Then
		%Do;
			%Let DSNX = &DsName;
			%Put DSNX = &DSNX;

			%Let Datasets = &Datasets &DSNX;
			%Put Datasets = &Datasets;
		%End;
	%Mend ConcatDsn;
	%ConcatDsn(AIB_Group_SME);
	%ConcatDsn(Bank_of_Ireland_SME);
	%ConcatDsn(Bank_of_Scotland_SME);
	%ConcatDsn(Barclays_SME);
	%ConcatDsn(Danske_Bank_SME);
	%ConcatDsn(ESME_SME);
	%ConcatDsn(First_Trust_Bank_SME);
	%ConcatDsn(HSBC_SME);
	%ConcatDsn(Lloyds_Bank_SME);
	%ConcatDsn(Natwest_SME);
	%ConcatDsn(RBS_SME);
	%ConcatDsn(Santander_SME);
	%ConcatDsn(Ulster_Bank_SME);

	Data OBData.CMA9_SME;
		Set &Datasets;
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


*--- Create Unique Data_Element Names ---;
	Data Work.NoDUP_CMA9_&API;
		Set Work.NoDUP_CMA9_&API;

		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-TradingHistoryEligibility-Amount' Then Data_Element = 'TradingHistEligAmount';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Amount' Then Data_Element = 'FeatureBenEligAmount';
		*--- ApplicationFrequency ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-ApplicationFrequency' Then Data_Element = 'FeeChargeDetailAppFreq';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-ApplicationFrequency' Then Data_Element = 'NonRepaymentFeeChargeAppFreq';
		*--- CalculationFrequency ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-CalculationFrequency' Then Data_Element = 'FeatureBenGrpCalcFreq';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-CalculationFrequency' Then Data_Element = 'FeeChargeDetailCalcFreq';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-CalculationFrequency' Then Data_Element = 'NonRepaymentFeeChargeCalcFreq';
		*--- CappingPeriod ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeCap-CappingPeriod' Then Data_Element = 'FeeChargeCapCapPeriod';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeCap-CappingPeriod' Then Data_Element = 'NonRepaymentFeeChargeCapPeriod';
		*--- Description ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-OtherEligibility-Description' Then Data_Element = 'OtherEligDesc';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-OtherEligibility-OtherType-Description' Then Data_Element = 'OtherEligOtherTypeDesc';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-ResidencyEligibility-OtherResidencyType-Description' Then Data_Element = 'OtherResidencyTypeDesc';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Description' Then Data_Element = 'FeatureBenEligDesc';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Description' Then Data_Element = 'FeatureBenItemEligDesc';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-OtherType-Description' Then Data_Element = 'FeatureBenItemOtherTypeDesc';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-OtherApplicationFrequency-Description' Then Data_Element = 'OtherAppFreqDesc';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-OtherCalculationFrequency-Description' Then Data_Element = 'OtherCalculFreqDesc';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-OtherFeeType-Description' Then Data_Element = 'OtherFeeTypeDesc';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-OtherApplicationFrequency-Description' Then Data_Element = 'NonRepaymentOtherAppFreqDesc';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-OtherCalculationFrequency-Description' Then Data_Element = 'NonRepaymentOtherCalcFreqDesc';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-OtherFeeType-Description' Then Data_Element = 'NonRepaymentOtherFeeTypeDesc';
		*--- FeatureBenefitEligibility ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility' Then Data_Element = 'FeatureBenGrpEligibility';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility' Then Data_Element = 'FeatureBenGrpItemEligibility';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility' Then Data_Element = 'FeatureBenefitItemEligibility';
		*--- FeatureBenefitItem ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem' Then Data_Element = 'FeatureBenGrpItem';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem' Then Data_Element = 'FeatureBenefitItem';
		*--- FeatureBenefitItem ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-FeeAmount' Then Data_Element = 'FeeChargeFeeAmount';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-FeeAmount' Then Data_Element = 'NonRepaymentFeeChargeFeeAmount';
		*--- FeeCapAmount ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeCap-FeeCapAmount' Then Data_Element = 'FeeChargeCapAmount';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeCap-FeeCapAmount' Then Data_Element = 'NonRepaymentFeeChargeCapAmount';
		*--- FeeCategory ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-FeeCategory' Then Data_Element = 'OtherFeesChargesFeeCategory';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-OtherFeeType-FeeCategory' Then Data_Element = 'OtherFeeTypeFeeCategory';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-OtherFeeType-FeeCategory' Then Data_Element = 'NonRepaymentOtherFeeCategory';
		*--- FeeRateType ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-FeeRateType' Then Data_Element = 'OtherFeeChargesFeeRateType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-FeeRateType' Then Data_Element = 'NonRepaymentFeeChargeFeeRateType';
		*--- FeeType ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeCap-FeeType' Then Data_Element = 'FeeChargeCapFeeType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-FeeType' Then Data_Element = 'FeeChargeDetailFeeType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeCap-FeeType' Then Data_Element = 'NonRepaymentFeeChargeCapFeeType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-FeeType' Then Data_Element = 'NonRepaymentFeeChargeFeeType';
		*--- FeeType1 ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeCap-FeeType-FeeType1' Then Data_Element = 'FeeChargeCapFeeType1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeCap-FeeType-FeeType1' Then Data_Element = 'NonRepaymentFeeChargeCapFeeType1';
		*--- Identification ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Identification' Then Data_Element = 'FeatureBenItemIdentification';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Identification' Then Data_Element = 'FeatureBenItemIdentification';
		If Hierarchy = 'data-Brand-CCC-Identification' Then Data_Element = 'CCCIdentification';
		*--- Indicator ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-OtherEligibility-Indicator' Then Data_Element = 'OtherEligIndicator';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-TradingHistoryEligibility-Indicator' Then Data_Element = 'TradingHistEligIndicator';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Indicator' Then Data_Element = 'FeatureBenGrpEligIndicator';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Indicator' Then Data_Element = 'FeatureBenGrpItemEligIndicator';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Indicator' Then Data_Element = 'FeatureBentGrpItemIndicator';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Indicator' Then Data_Element = 'FeatureBenItemEligIndicator';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Indicator' Then Data_Element = 'FeatureBenItemIndicator';
		*--- MinMaxType ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-TradingHistoryEligibility-MinMaxType' Then Data_Element = 'TradingHistEligMinMaxType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeCap-MinMaxType' Then Data_Element = 'FeeChargeCapMinMaxType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeCap-MinMaxType' Then Data_Element = 'NonRepaymentFeeCapMinMaxType';
		*--- Name ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-OtherEligibility-Name' Then Data_Element = 'OtherEligName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-OtherEligibility-OtherType-Name' Then Data_Element = 'OtherEligOtherTypeName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-ResidencyEligibility-OtherResidencyType-Name' Then Data_Element = 'OtherResidencyTypeName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Name' Then Data_Element = 'FeatureBenGrpEligName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Name' Then Data_Element = 'FeatureBenGrpItemEligName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-Name' Then Data_Element = 'FeatureBenGrpName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Name' Then Data_Element = 'FeatureBenItemEligName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Name' Then Data_Element = 'FeatureBenItemName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-OtherType-Name' Then Data_Element = 'FeatureBenItemOtherTypeName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-OtherApplicationFrequency-Name' Then Data_Element = 'OtherAppFreqName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-OtherCalculationFrequency-Name' Then Data_Element = 'OtherCalcFreqName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-OtherFeeType-Name' Then Data_Element = 'OtherFeeTypeName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-OtherApplicationFrequency-Name' Then Data_Element = 'NonRepaymentOtherAppFreqName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-OtherCalculationFrequency-Name' Then Data_Element = 'NonRepaymentOtherCalcFreqName';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-OtherFeeType-Name' Then Data_Element = 'NonRepaymentOtherFeeTypeName';
		If Hierarchy = 'data-Brand-CCC-Name' Then Data_Element = 'CCCProductName';
		*--- NegotiableIndicator ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-NegotiableIndicator' Then Data_Element = 'OtherFeesChargesNegIndicator';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-NegotiableIndicator' Then Data_Element = 'NonRepaymentNegIndicator';
		*--- Notes ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-CoreProduct-Notes' Then Data_Element = 'CoreProductNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-AgeEligibility-Notes' Then Data_Element = 'AgeEligNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-CreditCheckEligibility-Notes' Then Data_Element = 'CreditCheckEligNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-IndustryEligibility-Notes' Then Data_Element = 'IndustryEligNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-OtherEligibility-Notes' Then Data_Element = 'OtherEligNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-ResidencyEligibility-Notes' Then Data_Element = 'ResidencyEligNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-TradingHistoryEligibility-Notes' Then Data_Element = 'TradingHistEligNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Notes' Then Data_Element = 'FeatureBenItem-Notes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Notes' Then Data_Element = 'CCCMarketingStateNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeCap-Notes' Then Data_Element = 'FeeChargeCapNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-Notes' Then Data_Element = 'FeeChargeDetailNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeCap-Notes' Then Data_Element = 'NonRepaymentFeeChargeCapNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-Notes' Then Data_Element = 'NonRepaymentFeeChargeDetailNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-Notes' Then Data_Element = 'RepaymentNotes';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-RepaymentAllocation-Notes' Then Data_Element = 'RepaymentAllocationNotes';
		*--- Notes1 ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-CoreProduct-Notes-Notes1' Then Data_Element = 'CoreProductNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-AgeEligibility-Notes-Notes1' Then Data_Element = 'AgeEligibilityNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-CreditCheckEligibility-Notes-Notes1' Then Data_Element = 'CreditCheckEligNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-IndustryEligibility-Notes-Notes1' Then Data_Element = 'IndustryEligNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-OtherEligibility-Notes-Notes1' Then Data_Element = 'OtherEligibilityNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-ResidencyEligibility-Notes-Notes1' Then Data_Element = 'ResidencyEligNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-TradingHistoryEligibility-Notes-Notes1' Then Data_Element = 'TradingHistEligNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Notes-Notes1' Then Data_Element = 'FeatureBenItemNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Notes-Notes1' Then Data_Element = 'CCCMarketingStateNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeCap-Notes-Notes1' Then Data_Element = 'FeeChargeCapNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-Notes-Notes1' Then Data_Element = 'FeeChargeDetailNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeCap-Notes-Notes1' Then Data_Element = 'NonRepaymentFeeCapNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-Notes-Notes1' Then Data_Element = 'NonRepaymentFeeDetailNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-Notes-Notes1' Then Data_Element = 'RepaymentNotes1';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-RepaymentAllocation-Notes-Notes1' Then Data_Element = 'RepaymentAllocationNotes1';
		*--- Notes2 ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-CoreProduct-Notes-Notes2' Then Data_Element = 'CoreProductNotes2';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-Notes-Notes2' Then Data_Element = 'OtherFeesChargesNotes2';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-Notes-Notes2' Then Data_Element = 'NonRepaymentFeeChargeNotes2';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-RepaymentAllocation-Notes-Notes2' Then Data_Element = 'RepaymentAllocationNotes2';
		*--- OtherApplicationFrequency ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-OtherApplicationFrequency' Then Data_Element = 'OtherAppFrequency';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-OtherApplicationFrequency' Then Data_Element = 'NonRepaymentOtherAppFrequency';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-OtherCalculationFrequency' Then Data_Element = 'OtherCalcFrequency';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-OtherCalculationFrequency' Then Data_Element = 'NonRepaymentFeeOtherCalcFrequency';
		*--- OtherFeeType ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-OtherFeesCharges-FeeChargeDetail-OtherFeeType' Then Data_Element = 'OtherFeesChargesOtherFeeType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Repayment-NonRepaymentFeeCharges-NonRepaymentFeeChargeDetail-OtherFeeType' Then Data_Element = 'NonRepaymentOtherFeeType';
		*--- OtherType ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-OtherEligibility-OtherType' Then Data_Element = 'OtherEligOtherType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-OtherType' Then Data_Element = 'FeatureBenItemOtherType';
		*--- Textual ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-TradingHistoryEligibility-Textual' Then Data_Element = 'TradingHistEligTextual';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Textual' Then Data_Element = 'FeatureBenItemTextual';
		*--- Type ---;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-Eligibility-OtherEligibility-Type' Then Data_Element = 'OtherEligType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitEligibility-Type' Then Data_Element = 'FeatureBenGrpEligType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-FeatureBenefitEligibility-Type' Then Data_Element = 'FeatureBenGrpItemEligType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-FeatureBenefitItem-Type' Then Data_Element = 'FeatureBenGrpItemType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitGroup-Type' Then Data_Element = 'FeatureBenGrpType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-FeatureBenefitEligibility-Type' Then Data_Element = 'FeatureBenItemEligType';
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-FeaturesAndBenefits-FeatureBenefitItem-Type' Then Data_Element = 'FeatureBenItemType';
Run;

	Proc Sort Data = Work.NoDUP_CMA9_&API(Keep=Hierarchy Data_Element) 
	Out = Work.NoDUP_CMA9_&API Nodupkey;
	By Hierarchy;
	Run;


/*
	*--- Create a unique identifier for the data hierarchy ---;
	Data Work.NoDUP_CMA9_&API(Drop = UniqueNum);
		Set Work.NoDUP_CMA9_&API;
		UniqueNum = Put(_N_,z4.);
		UniqueID = Compress("PCA"||UniqueNum);
	Run;
*/

%Mend UniqueCCC;
%If "&_action" EQ "CMA9 COMPARISON CCC" %Then
%Do;
	%UniqueCCC(CCC);
%End;

%If "&_action" EQ "CMA9 COMPARISON CCC" %Then
%Do;
	%Macro CreateIDs(APIDSN,Bankname);
	*--- Append BCA Datasets ---;
	Data Work.&APIDSN(Drop = P1-P&_P_Max);
		Merge Work.NoDUP_CMA9_CCC(In=a)
		Work.&APIDSN(In=b Drop = Data_Element);
		By Hierarchy;
		If a and b;
		Length Bank_Name $ 25;
		Bank_Name = "&Bankname";
	Run;
	*--- Sort by Row count to get the order of the rows correct ---;
	Proc Sort Data = Work.&APIDSN;
		By RowCnt;
	Run;
	Data Work.&APIDSN;
		Set Work.&APIDSN;
		If Hierarchy = 'data-Brand-BrandName' Then
		Do;
			_Record_ID = 0;
		End;
		If Hierarchy = 'data-Brand-CCC-Name' Then
		Do;
			_Record_ID + 1;
			_MarkStateID = 0;
		End;
		If Hierarchy = 'data-Brand-CCC-CCCMarketingState-MarketingState' Then
		Do;
			_MarkStateID + 1;
	 	End;
		Retain _Record_ID _MarkStateID;
	Run;
	%Mend CreateIDs;
	%CreateIDs(Bank_of_Ireland_CCC,Bank_of_Ireland);
	%CreateIDs(Bank_of_Scotland_CCC,Bank_of_Scotland);
	%CreateIDs(Barclays_CCC,Barclays);
	%CreateIDs(HSBC_CCC,HSBC);
	%CreateIDs(Lloyds_Bank_CCC,Lloyds_Bank);
	%CreateIDs(Natwest_CCC,Natwest);	
	%CreateIDs(RBS_CCC,RBS);
	%CreateIDs(Santander_CCC,Santander);

	%Let Datasets =;
	%Macro ConcatDsn(DsName);
		%If %Sysfunc(exist(&DsName)) %Then
		%Do;
			%Let DSNX = &DsName;
			%Put DSNX = &DSNX;

			%Let Datasets = &Datasets &DSNX;
			%Put Datasets = &Datasets;
		%End;
	%Mend ConcatDsn;
	%ConcatDsn(Bank_of_Ireland_CCC);
	%ConcatDsn(Bank_of_Scotland_CCC);
	%ConcatDsn(Barclays_CCC);
	%ConcatDsn(HSBC_CCC);
	%ConcatDsn(Lloyds_Bank_CCC);
	%ConcatDsn(Natwest_CCC);
	%ConcatDsn(RBS_CCC);
	%ConcatDsn(Santander_CCC);

	Data OBData.CMA9_CCC;
		Set &Datasets;
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

/*
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
*/
*--- Sort dataset by the RowCnt value to set the table in the original JSON script order ---; 
/*
Proc Sort Data = OBData.CMA9_&API;
	By RowCnt;
Run;
*/
*--- Create a Record-ID field for all records in the API JSON file ---;
*--- Each record in the API file starts with the Data_Element LEI ---;
*--- Every time the Data_Element value LEI is encountered a new records start in the JSON file ---;
Data OBData.CMA9_&API(Where=(V NE 0)) Work.X3 ;
	Set OBData.CMA9_&API;
Run;

*--- Correct the _MarkStateID value to show 1 from the first data-Brand-PCA-Name record ---;
Data OBData.CMA9_&API Work.X4;
	Set OBData.CMA9_&API;

	If _Record_ID = 0 Then 
	Do; 
		_MarkStateID = 1;
		_SegmentID = 1; 
	End;
	If _Record_ID >= 1 and _MarkStateID = 0 Then 
	Do; 
		_MarkStateID = 1;
	End;

	If Hierarchy EQ 'data-Brand-PCA-PCAMarketingState-MarketingState' 
	and _Record_ID > 1 and _MarkStateID >= 1 Then 
	Do; 
		_SegmentID + 1;
	End;
	Retain _SegmentID;
Run;

*--- Print ATMS Report ---;
/*Proc Print Data = OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);*/
/*Run;*/

/*
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";

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

*/

/*
PROC EXPORT DATA = OBData.CMA9_&API(Drop=Bank_API P Count RowCnt) 
            OUTFILE= "H:\STV\Open Banking\SAS\Temp\CMA9_&API..csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
*/

*--- Close Output Delivery Parameters  ---;
/*ODS HTML Close;*/


/*ODS CSV File="C:\inetpub\wwwroot\sasweb\data\results\CMA9_&API..csv";*/
/*
Proc Print Data=OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
*/
ODS CSV Close;

/*
ODS HTML File="&Path\Data\Results\CMA9_&API..xls";
Proc Print Data=OBData.CMA9_&API(Drop=Bank_API P Count RowCnt);
	Title1 "Open Banking - &API";
	Title2 "CMA9 Product Comparison Report - &Fdate";
Run;
ODS HTML Close;
*/

/*%ReturnButton;*/

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
