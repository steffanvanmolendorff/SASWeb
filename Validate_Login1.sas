%Global _WebUser;
%Global _WebPass;
%Global _RegUser;
%Global _RegPass;
%Global _service;
%Global _debug;
%Global _SRVNAME;

%Global _Host;
%Global _Path;

%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

%Macro Main();
/*Libname OBData "C:\inetpub\wwwroot\sasweb\data\Perm";*/
/*Libname OBData "C:\inetpub\wwwroot\sasweb\data\Temp";*/


%Macro Valid();
Data _Null_;
		File _Webout;

		Put '<HTML>';

		Put '<Head>';
		Put '<title>OBIE JSON APP</title>';
		Put '</Head>';

		Put '<script type="text/javascript" src="'"&_Path/js/jquery.js"'">';
		Put '</script>';

		Put '<link rel="stylesheet" type="text/css" href="'"&_Path/css/style.css"'">';


		Put '<BODY>';
		Put '<table style="width: 100%; height: 5%" border="0">';
		Put '<tr>';
		Put '<td valign="top" style="background-color: #D4E6F1; color: orange">';
		Put '<img src="'"&_Path/images/london.jpg"'" alt="Cannot find image" style="width:100%;height:8%px;">';
		Put '</td>';
		Put '</tr>';
		Put '</table>';


		Put '<table style="width: 100%; height: 5%" border="1">';
		Put '<tr>';
		Put '<td valign="middle" style="background-color: white; color: black" style="width: 100%; height: 40%" border="1">';
		Put '<p><br></p>';
		Put '<H1 align="center">OPEN BANKING - STANDARDS</H1>';
		Put '</tr>';
		Put '</td>';
		Put '</table>';


		Put '<table style="width: 100%; height: 20%" border="1">';
		Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';
		Put '<tr>';
		Put '<td valign="center" align="center" style="background-color: #D4E6F1; color: Blue" border="1">';
		Put '<p><br></p>';
		Put '<H1>OPEN DATA</H1>';
		Put '<p><br></p>';
		Put '<H2>OPEN DATA CMA9 COMPARISON REPORTS</H2>';
		Put '<p><br></p>';

		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<SELECT NAME="_action" size="6" onchange="this.form.submit()"</option>';
		Put '<OPTION VALUE="CMA9 COMPARISON ATMS"> 1. CMA9 COMPARISON ATMS </option>';
		Put '<OPTION VALUE="CMA9 COMPARISON BRANCHES"> 2. CMA9 COMPARISON BRANCHES </option>';
		Put '<OPTION VALUE="CMA9 COMPARISON PCA"> 3. CMA9 COMPARISON PCA </option>';
		Put '<OPTION VALUE="CMA9 COMPARISON BCA"> 4. CMA9 COMPARISON BCA </option>';
		Put '<OPTION VALUE="CMA9 COMPARISON SME"> 5. CMA9 COMPARISON SME </option>';
		Put '<OPTION VALUE="CMA9 COMPARISON CCC"> 6. CMA9 COMPARISON CCC </option>';
		Put '<OPTION VALUE="UPDATE OPEN DATA CMA9 TABLES"> 7. UPDATE OPEN DATA CMA9 TABLES </option>';
		Put '</SELECT>';
		Put '</div>';



		Put '<H2>OPEN DATA INTERNAL JSON VALIDATION</H2>';
		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<SELECT NAME="_action" size="8" onchange="this.form.submit()"</option>';
		Put '<OPTION VALUE="ATM CODELIST COMPARISON"> 1. ATM CODELIST COMPARISON </option>';
		Put '<OPTION VALUE="BCH CODELIST COMPARISON"> 2. BCH CODELIST COMPARISON </option>';
		Put '<OPTION VALUE="PCA CODELIST COMPARISON"> 3. PCA CODELIST COMPARISON </option>';
		Put '<OPTION VALUE="BCA CODELIST COMPARISON"> 4. BCA CODELIST COMPARISON </option>';
		Put '<OPTION VALUE="CCC CODELIST COMPARISON"> 5. CCC CODELIST COMPARISON </option>';
		Put '<OPTION VALUE="SME CODELIST COMPARISON"> 6. SME CODELIST COMPARISON </option>';
		Put '<OPTION VALUE="API_ALL DD JSON COMPARE"> 7. API_ALL DD JSON COMPARE </option>';
		Put '<OPTION VALUE="API_ALL DD SWAGGER COMPARE"> 8. API_ALL DD SWAGGER COMPARE </option>';
		Put '</SELECT>';
		Put '</div>';

		Put '<H2>OPEN DATA - JSON VALIDATION APPLICATION</H2>';
		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<SELECT NAME="_action" size="2" onchange="this.form.submit()"</option>';
		Put '<OPTION VALUE="SELECT OD API PARAMETERS"> 1. RUN OD JSON VALIDATION APP </option>';
		Put '<OPTION VALUE="SELECT RW API PARAMETERS"> 1. RUN RW JSON VALIDATION APP </option>';
		Put '<OPTION VALUE="STATISTICS REPORT"> 2. STATISTICS REPORT </option>';
		Put '</SELECT>';
		Put '</div>';
		Put '<p><br></p>';


		Put '<H2>OPEN DATA V2 SWAGGER VALIDATION</H2>';
		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<SELECT NAME="_action" size="2" onchange="this.form.submit()"</option>';
		Put '<OPTION VALUE="VALIDATE PCA V2 SWAGGER"> 1. VALIDATE PCA V2 SWAGGER </option>';
		Put '<OPTION VALUE="VALIDATE BCA V2 SWAGGER"> 2. VALIDATE BCA V2 SWAGGER </option>';
		Put '</SELECT>';
		Put '</div>';



		Put '<td valign="center" align="center" style="background-color: #D4E6F1; color: Blue" border="1">';
		Put '<p><br></p>';
		Put '<p><br><br></p>';
		Put '<p><br><br></p>';
		Put '<H2>AD-HOC REPORT - SELECT API PRODUCT</H2>';
		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<SELECT NAME="_action" size="6" onchange="this.form.submit()"</option>';
		Put '<OPTION VALUE="ATM"> 1. ATM </option>';
		Put '<OPTION VALUE="BRANCH"> 2. BRANCH </option>';
		Put '<OPTION VALUE="PERSONAL CURRENT ACCOUNT"> 3. PERSONAL CURRENT ACCOUNT </option>';
		Put '<OPTION VALUE="BUSINESS CURRENT ACCOUNT"> 4. BUSINESS CURRENT ACCOUNT </option>';
		Put '<OPTION VALUE="COMMERCIAL CREDIT CARD"> 5. COMMERCIAL CREDIT CARD </option>';
		Put '<OPTION VALUE="SME LOAN"> 6. SME LOAN </option>';
		Put '</SELECT>';
		Put '</div>';

		Put '<p><br></p>';
		Put '********************************************************';
		Put '<H1>READ / WRITE</H1>';
		Put '<p><br></p>';
		Put '<H2>PAYMENT / ACC-INFO VALIDATION</H2>';
		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<SELECT NAME="_action" size="2" onchange="this.form.submit()"</option>';
		Put '<OPTION VALUE="OBPaySet JSON COMPARE"> 1. OBPAYSET JSON COMPARE </option>';
		Put '<OPTION VALUE="Account Information SWAGGER COMPARE"> 2. ACCOUNT INFO SWAGGER COMPARE </option>';
		Put '</SELECT>';
		Put '</div>';
		Put '<p><br></p>';

		Put '<H2>TEST</H2>';
		Put '<div class="dropdown" align="center" style="float:center; width: 70%">';
		Put '<SELECT NAME="_action" size="2" onchange="this.form.submit()"</option>';
		Put '<OPTION VALUE="Null"> Select option below </option>';
		Put '<OPTION VALUE="Test Other Script"> 1. TEST OTHER SCRIPT </option>';
		Put '</SELECT>';
		Put '</div>';
		Put '<p><br></p>';

		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.SelectSASProgram.sas">';
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
		Put '</table>';

		Put '</BODY>';
		Put '</HTML>';
Run;
%Mend Valid;

%Macro NewUser();
Data _Null_;
		File _Webout;
		Put '<HTML>';
		Put '<HEAD>';
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

		Put '</HEAD>';
		Put '<BODY>';

		Put '<BODY>';
		Put '<table style="width: 100%; height: 5%" border="0">';
		Put '<tr>';
		Put '<td valign="top" style="background-color: #D4E6F1; color: orange">';
		Put '<img src="'"&_Path/images/london.jpg"'" alt="Cannot find image" style="width:100%;height:8%px;">';
		Put '</td>';
		Put '</tr>';
		Put '</table>';

		Put '<table style="width: 100%; height: 40%" border="0">';
		Put '<tr>';
		Put '<td valign="middle" style="background-color: White; color: black">';
		Put '<p><br><br></p>';
		Put '<H1 align="center">OPEN BANKING - API STANDARDS</H1>';
		Put '<p><br><br></p>';
		Put '<H2 valign="top" align="center">API TEST APPLICATION</H2>';
		Put '<p><br><br></p>';
		Put '</td>';
		Put '</tr>';
		Put '<tr>';
		Put '<td valign="center" align="center" style="background-color: #D4E6F1; color: White">';

		Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';
		Put '<p><br></p>';
		Put '<H1 align="center">Registration Successful - Return to Login</H1>'; 
 		Put '<INPUT TYPE=submit VALUE="Re-Submit Details" valign="center">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.Login.sas">';
		Put '<INPUT TYPE=hidden NAME=_service VALUE=' /
			"&_service"
			'>';
		Put '<INPUT TYPE=hidden NAME=_debug VALUE=' /
			"&_debug"
			'>';

		Put '</Form>';

		Put '</td>';
		Put '</tr>';
		Put '<td valign="top" style="background-color: White; color: black">';
		Put '<H3>All Rights Reserved</H3>';
		Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
		Put '</td>';
		Put '</table>';

		Put '</BODY>';
		Put '</HTML>';
	Run;
%Mend NewUser;

%Macro InValid();
Data _Null_;
		File _Webout;
		Put '<HTML>';
		Put '<HEAD>';
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

		Put '</HEAD>';
		Put '<BODY>';

		Put '<BODY>';
		Put '<table style="width: 100%; height: 5%" border="0">';
		Put '<tr>';
		Put '<td valign="top" style="background-color: #D4E6F1; color: orange">';
		Put '<img src="'"&_Path/images/london.jpg"'" alt="Cannot find image" style="width:100%;height:8%px;">';
		Put '</td>';
		Put '</tr>';
		Put '</table>';

		Put '<table style="width: 100%; height: 40%" border="0">';
		Put '<tr>';
		Put '<td valign="middle" style="background-color: White; color: black">';
		Put '<p><br><br></p>';
		Put '<H1 align="center">OPEN BANKING - API STANDARDS</H1>';
		Put '<p><br><br></p>';
		Put '<H2 valign="top" align="center">API TEST APPLICATION</H2>';
		Put '<p><br><br></p>';
		Put '</td>';
		Put '</tr>';
		Put '<tr>';
		Put '<td valign="center" align="center" style="background-color: #D4E6F1; color: White">';

		Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';
		Put '<p><br></p>';
		Put '<H1 align="center">Invalid Login Details</H1>'; 
 		Put '<INPUT TYPE=submit VALUE="Re-Submit Details" valign="center">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.Login.sas">';
		Put '<INPUT TYPE=hidden NAME=_service VALUE=' /
			"&_service"
			'>';
		Put '<INPUT TYPE=hidden NAME=_debug VALUE=' /
			"&_debug"
			'>';
		Put '<INPUT TYPE=hidden NAME=_Host VALUE=' /
			"localhost"
			'>';
		Put '</Form>';
		Put '</td>';
		Put '</tr>';
		Put '<td valign="top" style="background-color: White; color: black">';
		Put '<p><br><br></p>';
		Put '<H3>All Rights Reserved</H3>';
		Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
		Put '</td>';
		Put '</table>';

		Put '</BODY>';
		Put '</HTML>';
	Run;
%Mend InValid;

%If "&_RegUser" NE "" and "_RegPass" NE "" %Then
%Do;
%Macro Register_User();

Data OBData.Register_User;
	Length Username $ 100 Password $ 25;
	Username = "&_RegUser";
	Password = "&_RegPass";

		ValidUser = '2';
		ValidPass = '2';
		Call Symput('ValidUser',Trim(Left(ValidUser)));
		Call Symput('ValidPass',Trim(Left(ValidPass)));

Run;

Data OBData.Client_Login;
	Set OBData.Client_Login
		OBData.Register_User;
Run;

Proc Sort Data = OBData.Client_Login NoDupKey;
	By Username Password;
Run;

%Mend Register_User;
%Register_User();
%End;


%Macro Validate_Login(_WebUser,_WebPass);
/*
*%Let WebUser = vamola@mac.com;
*%Let WebPass = Test;
*/
Option Spool Symbolgen MLogic Mprint Source Source2;


Data OBData.Validate;
	Length Username WebUser $ 100 Password WebPass $ 25 ValidUser InvalidUser ValidPass InvalidPass $ 1;
	Set OBData.Client_Login;

	If Trim(Left(Username)) EQ "&_WebUser" and Trim(Left(Password)) EQ "&_WebPass" then
	Do;
		ValidUser = "1";
		ValidPass = "1";
		Call Symput('ValidUser',Trim(Left(ValidUser)));
		Call Symput('ValidPass',Trim(Left(ValidPass)));
		Output OBData.Validate;
	End;
Run;

	%If	"&ValidUser" = "1" and "&ValidPass" EQ "1" %Then
	%Do;
		%Valid();
	%End;
	%Else %If "&ValidUser" = "2" and "&ValidPass" EQ "2" %Then
	%Do;
		%NewUser();
	%End;
	%Else %Do;
		%Invalid();
	%End;


%Mend Validate_Login;
%Validate_Login(&_Webuser,&_WebPass);

%Mend Main;
%Main();
