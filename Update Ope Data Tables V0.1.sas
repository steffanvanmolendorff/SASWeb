
%Macro Main_Update(_RunAPI,_APIVisual);
Options Symbolgen MPrint MLogic Source Source2;
%Global _action;
%Global _APIVisual;

%If "&_action" NE "" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";

	%Include "C:\inetpub\wwwroot\sasweb\Source\qlick2\Extract All CMA9 API Data Elements V0.1.sas";

%End;
%Else %Do;
	%Let _action = &_RunAPI;
	%Let _APIVisual = &_APIVisual;

	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2.sas";

	%Include "C:\inetpub\wwwroot\sasweb\Source\qlick2\All CMA9 API Fields.sas";

%End;

%Mend;
%Main_Update(CMA9 COMPARISON ATMS,ATM);
%Main(CMA9 COMPARISON BRANCHES,BCH);
%Main(CMA9 COMPARISON BCA,BCA);
%Main(CMA9 COMPARISON PCA,PCA);
%Main(CMA9 COMPARISON CCC,CCC);
%Main(CMA9 COMPARISON SME,SME);
