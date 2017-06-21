Options Source Source2 Symbolgen MLogic MPrint;
%Macro Select();

%If "&_action" EQ "CMA9 COMPARISON" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_PCA.sas";
%End;

%If "&_action" EQ "API TEST APP" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\API_TEST_APP_V08.sas";
%End;

%If "&_action" EQ "API LIVE APP" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\API_LIVE_APP_V08.sas";
%End;

%If "&_action" EQ "PARAMETERS" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Parameters.sas";
%End;

%If "&_action" EQ "STATISTICS" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Stats.sas";
%End;

%If "&_action" EQ "EXPORT CMA9" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Export Reports.sas";
%End;

%If "&_action" EQ "RETURN" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Validate_Login.sas";
%End;

%If "&_action" EQ "UML JSON COMPARE" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\Read JSON File.sas";
%End;

%Mend Select;
%Select();
