/*
%Macro Import(Filename);
PROC IMPORT DATAFILE="&Filename"
 	OUT=Work.Bank_API_List
 	DBMS=csv
 	REPLACE;
 	GETNAMES=Yes;
RUN;

Proc Sort Data = Work.Bank_API_List;
	By Bank_Name;
Run;

Data AAA;
	Set Work.Bank_API_List;
	By Bank_Name;
	Retain Bank_Cnt;
	If First.Bank_Name Then
	Do;
		Bank_Cnt+1;
		API_Cnt = 1;
		Call Symput(Compress('Bank_API_List'||Put(Bank_Cnt,3.)),Trim(Left(Bank_Name)));
		Call Symput(Compress('API_List_Name'||Put(Bank_Cnt,3.)||Put(API_Cnt,3.)),Trim(Left(API_Name)));
		Call Symput(Compress('API_Count'||Put(Bank_Cnt,3.)||Put(API_Cnt,3.)),Put(API_Cnt,3.));
	End;
	If Not First.Bank_Name Then
	Do;
		API_Cnt + 1;
		Call Symput(Compress('Bank_API_List'||Put(Bank_Cnt,3.)),Trim(Left(Bank_Name)));
		Call Symput(Compress('API_List_Name'||Put(Bank_Cnt,3.)||Put(API_Cnt,3.)),Trim(Left(API_Name)));
		Call Symput(Compress('API_Count'||Put(Bank_Cnt,3.)||Put(API_Cnt,3.)),Put(API_Cnt,3.));
	End;
	If Last.Bank_Name Then
	Do;
		Call Symput('Tot_Bank_Cnt',Put(Bank_Cnt,3.));
		Call Symput(Compress('Tot_API_Count'||Put(Bank_Cnt,3.)),Put(API_Cnt,3.));
	End;
Run;

%Macro Loop();
%Do i = 1 %To &Tot_Bank_Cnt;
	Data _Null_;

		%Put Bank_API_List&i = "&&Bank_API_List&i";

		%Do j = 1 %To &&Tot_API_Count&i;
				%Put API_List_Name&i&j = "&&API_List_Name&i&j";
		%End;

	Run;
%End;
%Mend Loop;
%Loop();



%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Perm\Bank_API_List.csv);
%Put _All_;

*/


Data _NULL_;
*File 'H:\StV\Open Banking\SAS\SAS Intrnet\Report.html';
File _Webout;

Put '<HTML>';
Put '<HEAD>';
Put '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">';
Put '<head>';
Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
Put '<meta http-equiv="X-UA-Compatible" content="IE=10"/>';
Put '<title>OB TESTING</title>';

/*Put '<!-- Basic Page Needs ================================================== -->';*/
Put '<meta charset="utf-8" />';
Put '<title>Open Data Test Application</title>';
Put '<meta name="description" content="">';
Put '<meta name="author" content="">';
/*Put '<!--[if lt IE 9]>';*/
/*Put '<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>';*/
/*Put '<![endif]-->';*/
	
/*Put '<!-- Mobile Specific Metas ================================================== -->';*/
Put '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />'; 
	
/*Put '<!-- CSS ================================================== -->';*/
*Put '<link rel="stylesheet" href="http://localhost/sasweb/css/style.css">';
*Put '<link rel="stylesheet" href="stylesheets/skeleton.css">';
*Put '<link rel="stylesheet" href="stylesheets/layout.css">';
	
/*Put '<!-- Favicons ================================================== -->';*/
/*Put '<link rel="shortcut icon" href="images/favicon.ico">';*/
/*Put '<link rel="apple-touch-icon" href="images/apple-touch-icon.png">';*/
/*Put '<link rel="apple-touch-icon" sizes="72x72" href="images/apple-touch-icon-72x72.png" />';*/
/*Put '<link rel="apple-touch-icon" sizes="114x114" href="images/apple-touch-icon-114x114.png" />';*/

Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
Put '<title>OBIE</title>';

Put '<script type="text/javascript" src="http://localhost/sasweb/js/jquery.js">';
Put '</script>';


Put '<link rel="stylesheet" type="text/css" href="http://localhost/sasweb/css/style.css">';

Put '</HEAD>';
Put '<BODY>';

Put '<table style="width: 100%; height: 5%" border="0">';
Put '<tr>';
Put '<td valign="top" style="background-color: lightblue; color: orange">';
Put '<img src="http://localhost/sasweb/images/london.jpg" alt="Cannot find image" style="width:100%;height:80%;">';
Put '</td>';
Put '</tr>';
Put '</table>';

Put '<p></p>';


	Put '<Table align="center" style="width: 100%; height: 10%" border="0">';
	Put '<tr>';

	Put '<td>';
	Put '<div style="float:left; width: 10%">';
	Put '<a href="https://www.openbanking.org.uk/">Home</a>';
	Put '</div>';
	Put '<div style="float:left; width: 10%">';
	Put '<a href="https://www.openbanking.org.uk/about/">About</a>';
	Put '</div>';
	Put '<div style="float:left; width: 10%">';
	Put '<a href="https://www.openbanking.org.uk/industry/">Portfolio</a>';
	Put '</div>';
	Put '<div style="float:left; width: 10%">';
	Put '<a href="https://www.openbanking.org.uk/contact/">Contact</a>';
	Put '</div>';
	Put '</td>';
	Put '</tr>';
	Put '</table>';


/*	Put '<p><br></p>';*/
	Put '<HR>';
/*	Put '<p><br></p>';*/

	Put '<FORM Name="param" ID="param" METHOD=GET ACTION="http://localhost/scripts/broker.exe">';

	Put '<Table align="center" style="width: 100%; height: 50%" border="1">';

	Put '<tr>';
	Put '<td>';
/*	Put '<div id="header" style="width:75%;">';*/
	Put '<div class="dropdown" align="center" style="float:center; width: 100%">';
/*	Put '<div class="dropdown" align="center" style="float:left; width: 50%">';*/
	Put '<b>SELECT  BANK</b>';	
	Put '<p></p>';

	Put '<SELECT NAME="_BankName" Size="14" onchange="this.form.submit()">';
	Put '<OPTION VALUE="AIB">ALLIED IRISH BANK</OPTION>';
	Put '<OPTION VALUE="BOI">BANK OF IRELAND</OPTION>';
	Put '<OPTION VALUE="BOS">BANK OF SCOTLAND</OPTION>';
	Put '<OPTION VALUE="Barclays">BARCLAYS BANK</OPTION>';
	Put '<OPTION VALUE="Danske">DANSKE BANK</OPTION>';
	Put '<OPTION VALUE="Firsttrust">FIRST TRUST BANK</OPTION>';
	Put '<OPTION VALUE="Halifax">HALIFAX</OPTION>';
	Put '<OPTION VALUE="HSBC">HSBC GROUP</OPTION>';
	Put '<OPTION VALUE="Lloyds">LLOYDS BANK</OPTION>';
	Put '<OPTION VALUE="NBS">NATIONWIDE BUILDING SOCIETY</OPTION>';
	Put '<OPTION VALUE="Natwest">NATWEST</OPTION>';
	Put '<OPTION VALUE="RBS">ROYAL BANK OF SCOTLAND</OPTION>';
	Put '<OPTION VALUE="Santander">SANTANDER</OPTION>';
	Put '<OPTION VALUE="Ulster">ULSTER BANK</OPTION>';
	Put '</SELECT>';
	Put '</div>';
	Put '</td>';
/*
	Put '<td>';
	Put '<div class="dropdown" align="center" style="float:left; width: 50%">';

	Put '<b>SELECT API</b>';
	Put '<SELECT NAME="_APIName" Size="6"</option>';
	Put '<OPTION VALUE="ATM">ATMS</option>';
	Put '<OPTION VALUE="BCH">BRANCHES</option>';
	Put '<OPTION SELECTED VALUE="BCA">BUSINESS CURRENT ACCOUNTS</option>';
	Put '<OPTION VALUE="PCA">PERSONAL CURRENT ACCOUNTS</option>';
	Put '<OPTION VALUE="CCC">COMMERCIAL CREDIT CARDS</option>';
	Put '<OPTION VALUE="SME">UNSECURED SME LOANS</option>';
	Put '</SELECT>';

	Put '</div>';
	Put '</td>';


	Put '<td>';
	Put '<div class="dropdown" align="center" style="float:left; width: 50%">';
	Put '<b>SELECT VERSION</b>';
	Put '<SELECT NAME="_VersionNo" Size="6">';
	Put '<OPTION SELECTED VALUE="v1.2">API VERSION 1.2.4</option>';
	Put '<OPTION VALUE="v1.3">API VERSION 1.3</option>';
	Put '<OPTION VALUE="v2.0">API VERSION 2.0</option>';
	Put '</SELECT>';

	Put '</div>';
	Put '</td>';
*/
*	Put '</div>';
	Put '</td>';
	Put '</tr>';
	Put '</table>';

	Put '<p><br></p>';
	Put '<p><br></p>';

	Put '<p></p>';
	Put '<HR>';
	Put '<p></p>';

	Put '<Table align="center" style="width: 100%; height: 20%" border="0">';
	Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';
	Put '<p><br></p>';
/*	Put '<INPUT TYPE=submit VALUE=Submit align="center">';*/
	Put '<p><br></p>';
	Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.Parameters1.sas">';
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

	Put '</FORM>';

	Put '</td>';
	Put '</tr>';
	Put '<td valign="top" style="background-color: White; color: black">';
	Put '<H3>All Rights Reserved</H3>';
	Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
	Put '</td>';
	Put '</table>';


Put '</body>';
Put '</html>';

Run;
