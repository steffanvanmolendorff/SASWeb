%Global _action;
%Global _APIVisual;
%Global _SRVNAME;
%Global _Host;

%Global ErrorCode;
%Global ErrorDesc;
%Global Datasets;

%Global Start;
%Global ATM_Data_Element_Total;
%Global BCH_Data_Element_Total;
%Global BCA_Data_Element_Total;
%Global PCA_Data_Element_Total;
%Global CCC_Data_Element_Total;
%Global SME_Data_Element_Total;
%Global DataSetName;
/*%Global _APIVisual;*/
*--- Assign Global maro variables to save total number of banks per product type ---;
%Global ATM_Bank_Name_Total;
%Global BCH_Bank_Name_Total;
%Global BCA_Bank_Name_Total;
%Global PCA_Bank_Name_Total;
%Global CCC_Bank_Name_Total;
%Global SME_Bank_Name_Total;

%Macro Main_Update(_RunAPI,_APIVisual);
/*Options Symbolgen MPrint MLogic Source Source2;*/

%If "&_action" EQ "UPDATE OPEN DATA CMA9 TABLES" %Then
%Do;
	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2_NoReport.sas";

	%Include "C:\inetpub\wwwroot\sasweb\Source\Extract All CMA9 API Data Elements V0.1.sas";

%End;
%Else %Do;

	%Let _action = &_RunAPI;
	%Let _APIVisual = &_APIVisual;
	%Let _Host = localhost;
	%Let _SRVNAME = localhost;


	%Include "C:\inetpub\wwwroot\sasweb\Source\CMA9_Comparison_V1_2_NoReport.sas";

	%Include "C:\inetpub\wwwroot\sasweb\Source\Extract All CMA9 API Data Elements V0.1.sas";

%End;

%Mend Main_Update;
%Main_Update(CMA9 COMPARISON ATMS,ATM);
%Main_Update(CMA9 COMPARISON BRANCHES,BCH);
%Main_Update(CMA9 COMPARISON BCA,BCA);
%Main_Update(CMA9 COMPARISON PCA,PCA);
%Main_Update(CMA9 COMPARISON CCC,CCC);
%Main_Update(CMA9 COMPARISON SME,SME);

%Macro BankName(Dsn);
Data OBData.&Dsn;
	Set OBData.&Dsn;

	Bank = Upcase(Bank);
	/*
	If Bank EQ "Barclays" Then Bank = "BARCLAYS BANK";
	If Bank EQ "Bank of Scotland" Then Bank = "BANK OF SCOTLAND";
	If Bank EQ "Danske Bank" Then Bank = "DANSKE BANK";
	If Bank EQ "HSBC" Then Bank = "HSBC GROUP";
	If Bank EQ "Halifax" Then Bank = "HALIFAX";
	If Bank EQ "Lloyds Bank" Then Bank = "LLOYDS BANK";
	If Bank EQ "Nationwide" Then Bank = "NATIONWIDE BUILDING SOCIETY";
	If Bank EQ "Coutts" Then Bank = "COUTTS";
	If Bank EQ "Bank of Ireland" Then Bank = "BANK OF IRELAND";
	If Bank EQ "Allied Irish Bank" Then Bank = "ALLIED IRISH BANK";
	If Bank EQ "Natwest" Then Bank = "NATWEST";
	If Bank EQ "RBS" Then Bank = "ROYAL BANK OF SCOTLAND";
	If Bank EQ "Ulster Bank" Then Bank = "ULSTER BANK";
	If Bank EQ "Adam" Then Bank = "ADAM AND COMPANY";
	If Bank EQ "First Trust Bank" Then Bank = "FIRST TRUST BANK";
	If Bank EQ "Esme" Then Bank = "ESME";
	If Bank EQ "Santander" Then Bank = "SANTANDER";
	*/
Run;
%Mend BankName;
%BankName(ATM_Geographic);
%BankName(BCH_Geographic);
%BankName(BCA_Geographic);
%BankName(PCA_Geographic);
%BankName(CCC_Geographic);
%BankName(SME_Geographic);

