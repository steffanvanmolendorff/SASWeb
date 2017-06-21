%Macro Main();
/*Libname OBData "C:\inetpub\wwwroot\sasweb\data\Perm";*/

%Global _WebUser;
%Global _WebPass;
%Global _RegUser;
%Global _RegPass;
%Global _service;
%Global _debug;

%Macro Valid();
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

		Put '<script type="text/javascript" src="http://localhost/sasweb/js/jquery.js">';
		Put '</script>';

		Put '<link rel="stylesheet" type="text/css" href="http://localhost/sasweb/css/style.css">';

		Put '</HEAD>';
		Put '<BODY>';

		Put '<BODY>';
		Put '<table style="width: 100%; height: 5%" border="0">';
		Put '<tr>';
		Put '<td valign="top" style="background-color: lightblue; color: orange">';
		Put '<img src="http://localhost/sasweb/images/london.jpg" alt="Cannot find image" style="width:100%;height:8%px;">';
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
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';

		Put '<FORM NAME=check METHOD=get ACTION="http://localhost/scripts/broker.exe">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit NAME=_action VALUE="API LIVE APP">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="API TEST APP">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit NAME=_action VALUE="CMA9 COMPARISON">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="PARAMETERS">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="STATISTICS">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="UML JSON COMPARE">';
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
		Put '<td valign="top" style="background-color: White; color: black">';
		Put '<H3>All Rights Reserved</H3>';
		Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
		Put '</td>';
		Put '</table>';

		Put '</BODY>';
		Put '<HTML>';
%Mend Valid;


%Macro NewUser();
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

		Put '<script type="text/javascript" src="http://localhost/sasweb/js/jquery.js">';
		Put '</script>';

		Put '<link rel="stylesheet" type="text/css" href="http://localhost/sasweb/css/style.css">';

		Put '</HEAD>';
		Put '<BODY>';

		Put '<BODY>';
		Put '<table style="width: 100%; height: 5%" border="0">';
		Put '<tr>';
		Put '<td valign="top" style="background-color: lightblue; color: orange">';
		Put '<img src="http://localhost/sasweb/images/london.jpg" alt="Cannot find image" style="width:100%;height:8%px;">';
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
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';

		Put '<FORM NAME=check METHOD=get ACTION="http://localhost/scripts/broker.exe">';
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
		Put '<HTML>';
%Mend NewUser;

%Macro InValid();
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

		Put '<script type="text/javascript" src="http://localhost/sasweb/js/jquery.js">';
		Put '</script>';

		Put '<link rel="stylesheet" type="text/css" href="http://localhost/sasweb/css/style.css">';

		Put '</HEAD>';
		Put '<BODY>';

		Put '<BODY>';
		Put '<table style="width: 100%; height: 5%" border="0">';
		Put '<tr>';
		Put '<td valign="top" style="background-color: lightblue; color: orange">';
		Put '<img src="http://localhost/sasweb/images/london.jpg" alt="Cannot find image" style="width:100%;height:8%px;">';
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
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';

		Put '<FORM NAME=check METHOD=get ACTION="http://localhost/scripts/broker.exe">';
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
		Put '</Form>';

		Put '</td>';
		Put '</tr>';
		Put '<td valign="top" style="background-color: White; color: black">';
		Put '<H3>All Rights Reserved</H3>';
		Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
		Put '</td>';
		Put '</table>';

		Put '</BODY>';
		Put '<HTML>';
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

ODS _ALL_ Close;
ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;

Data OBData.Validate;
*	Length Username WebUser $ 100 Password WebPass $ 25 ValidUser InvalidUser ValidPass InvalidPass $ 1;
	Set OBData.Client_Login;

	If Trim(Left(Username)) EQ Trim(Left("&_WebUser")) and Trim(Left(Password)) EQ Trim(Left("&_WebPass")) then
	Do;
		ValidUser = '1';
		ValidPass = '1';
		Call Symput('ValidUser',Trim(Left(ValidUser)));
		Call Symput('ValidPass',Trim(Left(ValidPass)));
		Output OBData.Validate;
	End;
Run;

Data _Null_;

	%If	"&ValidUser" = "1" and "&ValidPass" EQ "1" %Then
	%Do;
		%Valid;
	%End;
	%Else %If "&ValidUser" = "2" and "&ValidPass" EQ "2" %Then
	%Do;
		%NewUser;
	%End;
	%Else %Do;
		%Invalid;
	%End;
Run;

ODS HTML;
ODS Listing;

%Mend Validate_Login;
%Validate_Login(&_Webuser,&_WebPass);

%Mend Main;
%Main();


/*

Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Perm";
Proc Append Base = OBData.Client_Login
	Data = OBData.Validate_Login;
Run;


Data OBData.Client_Login;
	Length Username $ 100 Password $ 25;
	Username = "vamola@mac.com";
	Password = "Test";
	Output;
	Username = "";
	Password = "";
	Output;
Run;
*/
