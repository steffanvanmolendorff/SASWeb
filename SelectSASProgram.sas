Options Source Source2 Symbolgen MLogic MPrint;
%Macro Select();
*====================================================================================================
		CMA9 COMPARISON REPORTS PER API FOR OPEN DATA
=====================================================================================================;
%If "&_action" EQ "CMA9 COMPARISON ATMS" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_PCA.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";
%End;

%If "&_action" EQ "CMA9 COMPARISON BRANCHES" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_PCA.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";
%End;

%If "&_action" EQ "CMA9 COMPARISON PCA" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_PCA.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";
%End;

%If "&_action" EQ "CMA9 COMPARISON BCA" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_PCA.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";
%End;

%If "&_action" EQ "CMA9 COMPARISON CCC" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_PCA.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";
%End;

%If "&_action" EQ "CMA9 COMPARISON SME" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_PCA.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";
%End;

%If "&_action" EQ "CMA9 COMPARISON ALL" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_PCA.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";
%End;

/*
%If "&_action" EQ "API TEST APP" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\API_TEST_APP_V08.sas";
%End;


%If "&_action" EQ "API LIVE APP" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\API_LIVE_APP_V08.sas";
%End;
*/
*====================================================================================================
		BANK API END POINT vs. SCHEMA STRUCTURE - LIST DIFFERENCES BETWEEN API AND JSON SCHEMA
=====================================================================================================;
%If "&_action" EQ "SELECT API PARAMETERS" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters.sas";
%End;

%If "&_action" EQ "STATISTICS REPORT" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Stats.sas";
%End;

/*
%If "&_action" EQ "EXPORT CMA9" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Export Reports.sas";
%End;
*/

%If "&_action" EQ "RETURN" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Validate_Login.sas";
%End;

%If "&_action" EQ "OBPaySet JSON COMPARE" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\OBPaySet JSON Compare.sas";
%End;
/*
%If "&_action" EQ "ATM BRA PCA DD JSON COMPARE" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API.sas";
%End;
*/

%If "&_action" EQ "MASTER SWAGGER API JSON COMPARE" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Swagger API JSON Comparison V0.1.sas";
%End;

/*
%If "&_action" EQ "API_ALL DD JSON COMPARE1" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API.sas";
%End;
*/
*====================================================================================================
		DATA DICTIONARY VS. CODELIST COMPARISON
=====================================================================================================;

%If "&_action" EQ "ATM CODELIST COMPARISON" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\ATM CodeList Comparison.sas";
%End;

%If "&_action" EQ "BCH CODELIST COMPARISON" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\BCH CodeList Comparison.sas";
%End;

%If "&_action" EQ "PCA CODELIST COMPARISON" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\PCA CodeList Comparison.sas";
%End;

%If "&_action" EQ "BCA CODELIST COMPARISON" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\BCA CodeList Comparison.sas";
%End;

%If "&_action" EQ "CCC CODELIST COMPARISON" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\CCC CodeList Comparison.sas";
%End;

%If "&_action" EQ "SME CODELIST COMPARISON" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\SME CodeList Comparison.sas";
%End;

%If "&_action" EQ "API_ALL CODELIST COMPARISON" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\API_ALL CodeList Comparison.sas";
%End;

%If "&_action" EQ "API_ALL DD JSON COMPARE" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;

%If "&_action" EQ "API_ALL DD SWAGGER COMPARE" %Then
%Do;
/*	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API.sas";*/
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API_VER.sas";
%End;



%If "&_action" EQ "API_ALL DD JSON COMPARE WITH CODENAMES" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters_API.sas";
%End;

*====================================================================================================
		SWAGGER V2 VS. JSON COMPARISON - EARLY VERSIONS
=====================================================================================================;
%If "&_action" EQ "VALIDATE PCA V2 SWAGGER" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\General\Extract PCA V2 JSON Data.sas";
%End;

%If "&_action" EQ "VALIDATE BCA V2 SWAGGER" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\General\Extract BCA V2 JSON Data.sas";
%End;

%Mend Select;
%Select();
