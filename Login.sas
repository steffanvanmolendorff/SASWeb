%Global _service;
%Global _Host;
%Global _Path;

%Let _Host = &_SRVNAME;
%Put _Host = &_Host;

%Let _Path = http://&_Host/sasweb;
%Put _Path = &_Path;

%Macro Login();
Data _NULL_;
File _Webout;


Put '<HTML>';
Put '<HEAD>';
Put '<html xmlns="http://www.w3.org/1999/xhtml">';
Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
Put '<meta http-equiv="X-UA-Compatible" content="IE=10"/>';
Put '<title>OB TESTING</title>';

Put '<meta charset="utf-8" />';
Put '<title>Open Data Test Application</title>';
Put '<meta name="description" content="">';
Put '<meta name="author" content="">';
	
Put '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />'; 
	
Put '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
Put '<title>OBIE</title>';

Put '<script type="text/javascript" src="'"&_Path/js/jquery.js"'">';
Put '</script>';

Put '<link rel="stylesheet" type="text/css" href="'"&_Path/css/style.css"'">';

Put '</HEAD>';

Put '<BODY>';
Put '<table style="width: 100%; height: 5%" border="0">';
Put '<tr>';
Put '<td valign="top" style="background-color: #D4E6F1; color: orange">';
Put '<img src="'"&_Path/images/london.jpg"'" alt="Cannot find image" style="width:100%;height:8%px;">';
Put '</td>';
Put '</tr>';
Put '</table>';

Put '<table style="width: 100%; height: 20%" border="0">';
Put '<tr>';
Put '<td valign="middle" style="background-color: White; color: black">';
Put '<p><br></p>';
Put '<H1 align="center">OPEN BANKING - API STANDARDS</H1>';
Put '<p><br></p>';
Put '<H2 valign="top" align="center">API TEST APPLICATION</H2>';
Put '<p><br><br></p>';
Put '</td>';
Put '</tr>';
Put '<tr>';
Put '</table>';

Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';
Put '<table align="center" style="width: 100%; height: 20%" border="0">';
Put '<tr>';

Put '<td valign="center" align="center" border="0" style="background-color: #D4E6F1; color: Black">';
Put '<p><br></p>';
Put '<b>Existing Users</b>';
Put '<p></p>';
Put '<font size=5><font color="black"><input type="text" placeholder="Enter Email" name="_WebUser"><br /><br /></font>';
Put '<font size=5><font color="white"><input type="password" placeholder="Password" name="_WebPass"><br /><br /></font>';

Put '<INPUT TYPE=submit VALUE="Submit Details" valign="center">';
Put '<p><br></p>';
Put '</td>';

Put '<td valign="center" align="center" border="0" style="background-color: #D4E6F1; color: Black">';
Put '<p><br></p>';
Put '<b>New Users</b>';
Put '<p></p>';
Put '<font size=5><font color="black"><input type="text" placeholder="Enter Email" name="_RegUser"><br /><br /></font>';
Put '<font size=5><font color="white"><input type="password" placeholder="Password" name="_RegPass"><br /><br /></font>';
Put '<INPUT TYPE=submit VALUE="Register Details" valign="center">';
Put '<p><br></p>';
/*Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.Validate_Login.sas">';*/
Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.Validate_Login1.sas">';
Put '<INPUT TYPE=hidden NAME=_service VALUE=' /
	"&_service"
	'>';
Put '</td>';
Put '<INPUT TYPE=hidden NAME=_debug VALUE=' /
	"&_debug"
	'>';
Put '</td>';
Put '</tr>';
Put '</table>';
Put '</FORM>';

Put '<table style="width: 100%; height: 10%" border="0">';
Put '<td valign="top" style="background-color: White; color: black">';
Put '<H3>All Rights Reserved</H3>';
Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
Put '</td>';
Put '</table>';

Put '</BODY>';
Put '<HTML>';

Run;
%Mend Login;
%Login();
