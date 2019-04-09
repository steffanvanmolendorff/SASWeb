Options Source Source2 Symbolgen MLogic MPrint;
%Global _action;

%Let _action = &_action;

%Macro Select();
*====================================================================================================
		CMA9 COMPARISON REPORTS PER API FOR OPEN DATA
=====================================================================================================;
%If "&_action" EQ "CMA9 COMPARISON ATMS" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V2_2.sas";

%End;

%Else %If "&_action" EQ "CMA9 COMPARISON BRANCHES" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V2_2.sas";
%End;

%Else %If "&_action" EQ "CMA9 COMPARISON PCA" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V2_2.sas";
%End;

%Else %If "&_action" EQ "CMA9 COMPARISON BCA" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V2_2.sas";
%End;

%Else %If "&_action" EQ "CMA9 COMPARISON CCC" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V2_2.sas";
%End;

%Else %If "&_action" EQ "CMA9 COMPARISON SME" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V2_2.sas";
%End;

%Else %If "&_action" EQ "UPDATE OPEN DATA CMA9 TABLES" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\Qlick2\Extract All CMA9 API Data Elements V0.1.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\Qlick2\CMA9 API Data Extracts V1.3.sas";
%End;


/*
*====================================================================================================
		BANK API END POINT vs. SCHEMA STRUCTURE - LIST DIFFERENCES BETWEEN API AND JSON SCHEMA
=====================================================================================================;
*/
%Else %If "&_action" EQ "SELECT OD API PARAMETERS" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters.sas";
%End;

%Else %If "&_action" EQ "SELECT RW API PARAMETERS" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters.sas";
%End;

%Else %If "&_action" EQ "STATISTICS REPORT" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Stats.sas";
%End;
/*
*====================================================================================================
		RETURN TO MAIN MENU
=====================================================================================================;
*/
%Else %If "&_action" EQ "RETURN" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Validate_Login.sas";
%End;
/*
*====================================================================================================
		READ / WRITE SECTION
=====================================================================================================;
*/
%Else %If "&_action" EQ "OBPaySet JSON COMPARE" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\OBPaySet JSON Compare.sas";
%End;

%Else %If "&_action" EQ "Account Information SWAGGER COMPARE" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Read RW ACCINFO Files V0.3.sas";
%End;
/*
*====================================================================================================
		OPEN DATA _ QUERY TOOL
=====================================================================================================;
*/
%Else %If "&_action" EQ "ATM" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\API Columns V0.2.sas";
%End;

%Else %If "&_action" EQ "BRANCH" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\API Columns V0.2.sas";
%End;

%Else %If "&_action" EQ "PERSONAL CURRENT ACCOUNT" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\API Columns V0.2.sas";
%End;

%Else %If "&_action" EQ "BUSINESS CURRENT ACCOUNT" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\API Columns V0.2.sas";
%End;

%Else %If "&_action" EQ "COMMERCIAL CREDIT CARD" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\API Columns V0.2.sas";
%End;

%Else %If "&_action" EQ "SME LOAN" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\API Columns V0.2.sas";
%End;

%Else %If "&_action" EQ "MASTER SWAGGER API JSON COMPARE" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Swagger API JSON Comparison V0.1.sas";
%End;
/*
*====================================================================================================
		DATA DICTIONARY VS. CODELIST COMPARISON
=====================================================================================================;
*/
%Else %If "&_action" EQ "ATM CODELIST COMPARISON" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\ATM CodeList Comparison.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;

%Else %If "&_action" EQ "BCH CODELIST COMPARISON" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\BCH CodeList Comparison.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;

%Else %If "&_action" EQ "PCA CODELIST COMPARISON" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\PCA CodeList Comparison.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;

%Else %If "&_action" EQ "API CODELIST COMPARISON" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\BCA CodeList Comparison.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;

%Else %If "&_action" EQ "PCA BCA CODELIST COMPARISON" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\BCA CodeList Comparison.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;

%Else %If "&_action" EQ "CCC CODELIST COMPARISON" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CCC CodeList Comparison.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;

%Else %If "&_action" EQ "SME CODELIST COMPARISON" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\SME CodeList Comparison.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;

%Else %If "&_action" EQ "API_ALL DD JSON COMPARE" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;

%Else %If "&_action" EQ "API_PAI_BAI DD JSON COMPARE" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;


%Else %If "&_action" EQ "API_ALL DD SWAGGER COMPARE" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;

%Else %If "&_action" EQ "API_ALL DD JSON COMPARE WITH CODENAMES" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API.sas";
%End;

%Else %If "&_action" EQ "API_SQM DD SWAGGER COMPARE" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;

%Else %If "&_action" EQ "API_FCA DD SWAGGER COMPARE" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;

%Else %If "&_action" EQ "API_SQM DATA VALIDATION" %Then
%Do;
*	%Include "C:\inetpub\wwwroot\sasweb\Source\API_SQM Data Value Validation v0.1.sas";
	%Include "C:\inetpub\wwwroot\sasweb\Source\API_SQM Data Value Validation v0.2.sas";
%End;

/*
*====================================================================================================
		SWAGGER V2 VS. JSON COMPARISON - EARLY VERSIONS
=====================================================================================================;
*/
%Else %If "&_action" EQ "Test Other Script" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\NHSData.sas";
%End;
%Else %If "&_action" EQ "Run API Access" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Qlick2\Proc HTTP - Test API Access V0.1.sas";
%End;
/*
*====================================================================================================
		SWAGGER V2 VS. JSON COMPARISON - EARLY VERSIONS
=====================================================================================================;
*/
%Else %If "&_action" EQ "VALIDATE PCA V2 SWAGGER" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\General\Extract PCA V2 JSON Data.sas";
%End;

%Else %If "&_action" EQ "VALIDATE BCA V2 SWAGGER" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\General\Extract BCA V2 JSON Data.sas";
%End;

%Mend Select;
%Select();
