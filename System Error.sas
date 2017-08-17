%Macro Sys_Errors(Bank, API);

*--- Set Output Delivery Parameters  ---;
		ODS _All_ Close;
	/*
				ODS HTML Body="&Bank._&API._Body_%sysfunc(datetime(),B8601DT15.).html" 
					Contents="&Bank._&API._Contents.html" 
					Frame="&Bank._&API._Frame.html" 
					Style=HTMLBlue;
	*/
  		ODS HTML BODY = _Webout (url=&_replay) Style=HTMLBlue;



	Data Work.System_Error;
		Length ERROR_DESC $ 100;

					ERROR_DESC = '';
					Output;
					ERROR_DESC = "There are crytical system Errors in the execution of the program.";
					Output;
					ERROR_DESC = '';
					Output;
					ERROR_DESC = "*** Error Code: &SYSERR ***";
					Output;
					ERROR_DESC = '';
					Output;
					ERROR_DESC = "*** Error Description: &SysErrorText ***";
					Output;
					ERROR_DESC = '';
					Output;
					ERROR_DESC = 'Please contact the System Administrator - Steffan van Molendorff.';
					Output;
					ERROR_DESC = '';
					Output;
					ERROR_DESC = 'Steffan van Molendorff - Open Banking Limited';
					Output;
					ERROR_DESC = '';
					Output;
					ERROR_DESC = 'Email: steffan.vanmolendorff@openbanking.org.uk';
					Output;
					ERROR_DESC = '';
					Output;
					ERROR_DESC = 'UK Mobile: +44 749 7002 765';
					Output;
					ERROR_DESC = '';
					Output;
				Run;


				Title1 "OPEN BANKING - QUALITY ASSURANCE TESTING";
	/*			Title2 "%Sysfunc(UPCASE(&Bank)) %Sysfunc(UPCASE(&API)) API HAS DATA VALIDATION ERRORS - %Sysfunc(UPCASE(&Fdate))";*/

				Proc Report Data =  OBData.System_Error nowd
					style(report)=[rules=all cellspacing=0 bordercolor=gray] 
					style(header)=[background=lightskyblue foreground=black] 
					style(column)=[background=lightcyan foreground=black];

					Columns ERROR_DESC;

					Define ERROR_DESC / display 'System Execution Error' left;

					Compute ERROR_DESC;
					If ERROR_DESC NE '' then 
						Do;
							call define(_col_,'style',"style=[foreground=Red background=pink font_weight=bold]");
						End;
					Endcomp;

				Run;
*--- Add bottom of report Menu ReturnButton code here ---;
		%ReturnButton();

	ODS HTML;
	ODS Listing;

%Mend Sys_Errors;
%Sys_Errors(&_BankName, &_APIName);
