data _null_;
 file _webout ;
 put '<HTML>' ;
 put '<HEAD><TITLE>Test SAS Intrnet</TITLE></HEAD>' ;
 put '<BODY>' ;
 put '<H2 ALIGN=center>Open Banking</H2><HR><BR><BR>' ;
 put '<CENTER><A HREF="mailto:support@companyx.com">Click here to send us a message</A></CENTER><BR><BR><HR><BR>' ;
 put '<CENTER><INPUT TYPE=button VALUE=Back onClick="javascript:history.back();"></CENTER>' ;
 put '</BODY>' ;
 put '</HTML>' ;
run ;

%Macro Test();
ODS HTML Close;
ODS Listing Close;

ODS HTML Body = _Webout;

Data Work.Test;

	A = 'Test1';
	B = 'The _Webout function for ODS';
	Output;
	A = 'Test2';
	B = 'The _Webout function for ODS';
	Output;
	A = 'Test3';
	B = 'The _Webout function for ODS';
	Output;
Run;

Title "Test Report";
Proc Print Data = Work.Test;
Run;

ODS HTML;
ODS Listing;	
%Mend Test;
%Test();