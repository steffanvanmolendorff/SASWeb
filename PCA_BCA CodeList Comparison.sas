%Global _APIName;
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

		Put '<script type="text/javascript" src="'"&_Path/js/jquery.js"'">';
		Put '</script>';

		Put '<link rel="stylesheet" type="text/css" href="'"&_Path/css/style.css"'">';

		Put '</HEAD>';
		Put '<BODY>';

		Put '<BODY>';
		Put '<table style="width: 100%; height: 5%" border="0">';
		Put '<tr>';
		Put '<td valign="top" style="background-color: lightblue; color: orange">';
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
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';

		Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit NAME=_action VALUE="API LIVE APP">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="API TEST APP">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit NAME=_action VALUE="CMA9 COMPARISON">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="PARAMETERS">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="STATISTICS">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="OBPaySet JSON COMPARE">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="ATM BRA JSON COMPARE">';
		Put '<INPUT TYPE=submit NAME=_action VALUE="CODELIST COMPARISON">';
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
		Put '<INPUT TYPE=hidden NAME=_action VALUE=' /
			"&_action"
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


%Macro ReturnButton();
Data _Null_;
		File _Webout;

		Put '<HTML>';
		Put '<HEAD>';
		Put '<html xmlns="http://www.w3.org/1999/xhtml">';
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

		Put '<p></p>';
		Put '<HR>';
		Put '<p></p>';

		Put '<Table align="center" style="width: 100%; height: 15%" border="0">';
		Put '<td valign="center" align="center" style="background-color: lightblue; color: White">';
		Put '<FORM NAME=check METHOD=get ACTION="'"http://&_Host/scripts/broker.exe"'">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=submit VALUE="Return" align="center">';
		Put '<p><br></p>';
		Put '<INPUT TYPE=hidden NAME=_program VALUE="Source.Validate_Login.sas">';
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
		Put '</Table>';

		Put '<Table align="center" style="width: 100%; height: 15%" border="0">';
		Put '<td valign="top" style="background-color: White; color: black">';
		Put '<H3>All Rights Reserved</H3>';
		Put '<A HREF="http://www.openbanking.org.uk">Open Banking Limited</A>';
		Put '</td>';
		Put '</Table>';

		Put '</BODY>';
		Put '<HTML>';
		
Run;
%Mend ReturnButton;

*--- Set Title Date in Proc Print ---;
%Macro Fdate(Fmt,Fmt2);
   %Global Fdate FdateTime;
   Data _Null_;
      Call Symput("Fdate",Left(Put("&Sysdate"d,&Fmt)));
      Call Symput("FdateTime",Left(Put("&Sysdate"d,&Fmt2)));
  Run;
%Mend Fdate;
%Fdate(worddate12., datetime.);



%Macro CodeList();
/*Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Temp";*/
/*
PROC IMPORT OUT= WORK.&_APIName._CodeList_NonFees 
            DATAFILE= "C:\inetpub\wwwroot\sasweb\Data\Temp\UML\&_APIName._CodeList_NonFees.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

PROC IMPORT OUT= WORK.&_APIName._CodeList_Fees 
            DATAFILE= "C:\inetpub\wwwroot\sasweb\Data\Temp\UML\&_APIName._CodeList_Fees.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
*/

    data WORK.&_APIName._CODELIST_NONFEES    ;
    %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile "C:\inetpub\wwwroot\sasweb\Data\Temp\od\ob\&_APIVersion.\&_APIName._CodeList_NonFees.csv" 
	delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 TermStr = CRLF;
       informat CodelistName $50. ;
       informat Endpoint_CodeName $50. ;
       informat Endpoint_Code $4. ;
       informat Description $1000. ;
       informat Include_in_v2_0_ $1. ;
       informat Added_in_v2_0 $1. ;
       informat Notes $121. ;
       informat ISO20022_CodeLIst $1. ;
       informat ISO20022_CodeName $1. ;
       format CodelistName $50. ;
       format Endpoint_CodeName $50. ;
       format Endpoint_Code $4. ;
       format Description $1000. ;
       format Include_in_v2_0_ $1. ;
       format Added_in_v2_0 $1. ;
       format Notes $121. ;
       format ISO20022_CodeLIst $1. ;
       format ISO20022_CodeName $1. ;

	   Input @;
		If Substr(Description,1,1) EQ '"' then
	  	Do;
			_Infile_ = Tranwrd(_Infile_,',','');
	  	End;

    input
                CodelistName $
                Endpoint_CodeName $
                Endpoint_Code $
                Description $
                Include_in_v2_0_ $
                Added_in_v2_0 $
                Notes $
                ISO20022_CodeLIst $
                ISO20022_CodeName $
    ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
    run;




data WORK.&_APIName._CODELIST_FEES;
    %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile "C:\inetpub\wwwroot\sasweb\Data\Temp\od\ob\&_APIVersion.\&_APIName._CodeList_Fees.csv" 
	delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 TermStr = CRLF;
       informat CodelistName $50. ;
       informat CodeName $50. ;
       informat CodeCategory $6. ;
       informat Code_Mnemonic $4. ;
       informat Description $1000. ;
       informat Include_in_v2_0_ $1. ;
       informat Added_in_v2_0 $1. ;
       informat Notes $89. ;
       informat ISO20022_CodeLIst $1. ;
       informat ISO20022_CodeName $1. ;
       format CodelistName $50. ;
       format CodeName $50. ;
       format CodeCategory $6. ;
       format Code_Mnemonic $4. ;
       format Description $1000. ;
       format Include_in_v2_0_ $1. ;
       format Added_in_v2_0 $1. ;
       format Notes $89. ;
       format ISO20022_CodeLIst $1. ;
       format ISO20022_CodeName $1. ;

	   Input @;
		If Substr(Description,1,1) EQ '"' then
	  	Do;
			_Infile_ = Tranwrd(_Infile_,',','');
	  	End;


		input
                CodelistName $
                CodeName $
                CodeCategory $
                Code_Mnemonic $
                Description $
                Include_in_v2_0_ $
                Added_in_v2_0 $
                Notes $
                ISO20022_CodeLIst $
                ISO20022_CodeName $
    ;
    if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
run;


Data Work.&_APIName._CodeList_Fees1(Drop = Description);
	Set Work.&_APIName._CodeList_Fees;
	CodeDescription = Description;
	If Include_in_v2_0_ EQ 'N' or CodeName EQ '' then Delete;
/*	Where CodeListName = 'OB_CardType1Code';*/
Run;

Data Work.&_APIName._CodeList_NonFees1(Drop = Description Rename=(EndPoint_CodeName = CodeName));
	Set Work.&_APIName._CodeList_NonFees;
	CodeDescription = Description;
	If Include_in_v2_0_ EQ 'N' or EndPoint_CodeName EQ '' then Delete;
/*	Where CodeListName = 'OB_CardType1Code';*/
Run;


Data OBData.&_APIName._CodeList;
	Length CodelistName $ 50 CodeName CodeDescription $ 1000;
	Set Work.&_APIName._CodeList_Fees1(In=a Drop = Notes)
	Work.&_APIName._CodeList_NonFees1(In=b Drop = Notes);
	Length Infile $ 8;
	If a then InFile = 'Fees';
	If b then Infile = 'Non-Fees';
	CodeListName = Trim(Left(CodeListName));
	CodeName = Trim(Left(CodeName));
	CodeDescription = Tranwrd(Trim(Left(CodeDescription)),'0A'x,' ');

	CodeListName_CL = CodeListName;
	CodeName_CL = CodeName;
	CodeDescription_CL = CodeDescription;

	CodeListName_CL = TRANSLATE(Trim(Left(CodeListName_CL)),"",'0A'x);
	CodeName_CL = TRANSLATE(Trim(Left(CodeName_CL)),"",'0A'x);
	CodeDescription_CL = TRANSLATE(Trim(Left(CodeDescription_CL)),"",'0A'x);

/*	Where CodeListName = 'OB_CardType1Code';*/
Run;

Proc Sort Data = OBData.&_APIName._CodeList(Keep = CodeName CodeListName CodeDescription
	CodeName_CL CodeListName_CL CodeDescription_CL Include_in_v2_0_) ;
	By CodeListName CodeName CodeDescription;
Run;



*--- Get data from API_&_APIName. Data Dictionary data ---;

Options MLOGIC MPRINT SOURCE SOURCE2 SYMBOLGEN;
/*Libname OBData "C:\inetpub\wwwroot\sasweb\Data\Temp";*/

%Macro Import(Filename,Dsn);
/**********************************************************************
*   PRODUCT:   SAS
*   VERSION:   9.4
*   CREATOR:   External File Interface
*   DATE:      22JUN17
*   DESC:      Generated SAS Datastep Code
*   TEMPLATE SOURCE:  (None Specified.)
***********************************************************************/
     data OBData.&Dsn;
     %let _EFIERR_ = 0; 
     infile "&Filename" delimiter = ','
  	MISSOVER DSD lrecl=32767 firstobs=2 Termstr=CRLF;
        informat XPath $1000. ;
        informat FieldName $91. ;
        informat ConstraintID $25. ;
        informat MinOccurs best32. ;
        informat MaxOccurs $9. ;
        informat DataType $50. ;
        informat Length $5. ;
        informat MinLength $1000. ;
        informat MaxLength $1000. ;
        informat Pattern $25. ;
        informat CodeName $1000. ;
        informat CodeDescription $1000. ;
        informat EnhancedDefinition $1024. ;
        informat XMLTag $25. ;
        format XPath $1000. ;
        format FieldName $91. ;
        format ConstraintID $25. ;
        format MinOccurs best12. ;
        format MaxOccurs $9. ;
        format DataType $50. ;
        format Length $5. ;
        format MinLength $1000. ;
        format MaxLength $1000. ;
        format Pattern $25. ;
        format CodeName $1000. ;
        format CodeDescription $1000. ;
        format EnhancedDefinition $1024. ;
        format XMLTag $25. ;

		If Substr(Xpath,1,1) EQ '"' then
	  	Do;
			_Infile_ = Tranwrd(_Infile_,',','');
	  	End;

     input
                 XPath $
                 FieldName $
                 ConstraintID $
                 MinOccurs
                 MaxOccurs $
                 DataType $
                 Length $
                 MinLength
                 MaxLength
                 Pattern $
                 CodeName $
                 CodeDescription $
                 EnhancedDefinition $
                 XMLTag $
     ;
     if _ERROR_ then call symputx('_EFIERR_',1);  
     run;


Data OBData.&Dsn/*(Drop = Hierarchy Position Want Rename=(Hierarchy1 = Hierarchy))*/;
	Length Pattern Hierarchy $ 1000 &DSN._Lev1 $ 1000;
	Set OBData.&Dsn;

	If XPath NE '';

	If "&Dsn" in ('BCA','PCA') Then 
	Do;
		Hierarchy = Tranwrd(Substr(Trim(Left(XPath)),16),'/','-');
	End;

	&DSN._Lev1 = Hierarchy;
Run;

Proc Sort Data = OBData.&Dsn
	Out = OBData.API_&Dsn.;
	By Hierarchy;
Run;

%Mend Import;
%Import(C:\inetpub\wwwroot\sasweb\Data\Temp\od\ob\&_APIVersion.\&_APIName.l_001_001_01DD.csv,&_APIName);

Proc Sort Data = OBData.API_&_APIName.
	Out = Work.API_&_APIName.(Keep = Hierarchy DataType CodeName CodeDescription
	Rename = (DataType = CodeListName)) NoDupKey;
	By Hierarchy DataType CodeName CodeDescription;
/*	Where DataType EQ 'OB_CardType1Code';*/
Run;


Data Work.API_&_APIName.1(Drop = CodeListName Rename = (NewVar = CodeListName));
	Set Work.API_&_APIName.;
	By Hierarchy CodeListName CodeName CodeDescription;

	Retain NewVar;	

	If Not Missing(CodeListName) Then NewVar = CodeListName;

	CodeListName_DD = CodeListName;
	CodeName_DD = CodeName;
	CodeDescription_DD = CodeDescription;

	CodeListName_DD = TRANSLATE(Trim(Left(CodeListName_DD)),"",'0A'x);
	CodeName_DD = TRANSLATE(Trim(Left(CodeName_DD)),"",'0A'x);
	CodeDescription_DD = TRANSLATE(Trim(Left(CodeDescription_DD)),"",'0A'x);


Run;

Proc Sort Data = Work.API_&_APIName.1
		Out = OBData.API_&_APIName.2 NoDupKey;
	By CodeListName CodeName CodeDescription;
Run;

Data OBData.API_&_APIName.2;
	Set OBData.API_&_APIName.2;

	CodeDescription = Tranwrd(CodeDescription,'0A'x,' ');
	CodeListName_DD = CodeListName;
*--- Only keep the underlying CodeNames which are not blank ---;
	If CodeName NE '';

Run;





%Macro Validate();
Options Symbolgen MLogic MPrint Source Source2;
Data OBData.&_APIName._Code_Compare Work.&_APIName._Code_Compare;
	Length Count 4 Hierarchy $ 1000 CodeListName $ 50 CodeName CodeDescription $ 1000;

	Merge OBData.API_&_APIName.2(In=b Keep = Hierarchy CodeListName CodeName CodeDescription
	CodeListName_DD CodeName_DD CodeDescription_DD)

	OBData.&_APIName._CodeList(In=a Keep = CodeListName CodeName CodeDescription
	CodeListName_CL CodeName_CL CodeDescription_CL Include_in_v2_0_);

	By CodeListName CodeName CodeDescription;
	If a and not b Then Infile = 'CodeList';
	If b and not a Then Infile = 'DD';
	If a and b Then Infile = 'Both';

	Count = _N_;

	If Trim(Left(CodeName_DD)) NE Trim(Left(CodeName_CL)) Then
	Do;
		CodeName_Flag = 'Mismatch';
	End;
	Else Do;
		CodeName_Flag = 'Match';
	End;

	If Trim(Left(CodeDescription_DD)) NE Trim(Left(CodeDescription_CL)) Then
	Do;
		CodeDesc_Flag = 'Mismatch';
	End;
	Else Do;
		CodeDesc_Flag = 'Match';
	End;

	If Trim(Left(CodeListName_DD)) NE Trim(Left(CodeListName_CL)) Then
	Do;
		CodeListName_Flag = 'Mismatch';
	End;
	Else Do;
		CodeListName_Flag = 'Match';
	End;

	If Trim(Left(Include_in_v2_0_)) NE 'Y' Then
	Do;
		InVersion_Flag = 'Mismatch';
	End;
	Else Do;
		InVersion_Flag = 'Match';
	End;

/*	Where CodeListName = 'OB_CardType1Code';*/
Run;

%Mend Validate;
%Validate();


%Macro Template;
Proc Template;
 	Define style Style.Sasweb;
	End;
Run; 
%Mend Template
%Template;


%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
*--- Set Output Delivery Parameters  ---;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.SASWeb 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 


Proc Report Data = OBData.&_APIName._Code_Compare nowd/*
	style(report)=[width=100%]
	style(report)=[rules=all cellspacing=0 bordercolor=gray] 
	style(header)=[background=lightskyblue foreground=black] 
	style(column)=[background=lightcyan foreground=black]*/;

	Title1 "Open Banking - CodeList Comparison";
	Title2 "Data Dictionary vs. CodeList Comparison Reports - %Sysfunc(UPCASE(&Fdate))";

	Columns Count Infile 
	Hierarchy 
	CodeListName 
	CodeName 
	CodeDescription
	CodeListName_DD 
	CodeListName_CL 
	CodeName_DD 
	CodeName_CL 
	CodeDescription_DD
	CodeDescription_CL
	CodeName_Flag
	CodeListName_Flag 
	CodeDesc_Flag
	Include_in_v2_0_
	InVersion_Flag;

	Define Count / display 'Row Count' left style(column)=[width=5%];
	Define Infile / display 'Infile' left style(column)=[width=5%];
	Define Hierarchy / display 'Data Level' left style(column)=[width=5%];
	Define CodeListName / display 'CodeList Name' left style(column)=[width=5%];
	Define CodeName / display 'Code Name' left style(column)=[width=5%];
	Define CodeDescription / display 'Code Description' left style(column)=[width=5%];
/*	Define CodeListName_Flag / display 'CodeList Name Flag' left style(column)=[width=5%];*/
	Define CodeName_Flag / display 'Code Name Flag' left style(column)=[width=5%];
	Define CodeListName_Flag / display 'Code List Name Flag' left style(column)=[width=5%];
	Define CodeDesc_Flag / display 'Code Description Flag' left style(column)=[width=5%];
	Define CodeListName_DD  / display 'CodeListName DD' left style(column)=[width=5%];
	Define CodeName_DD / display 'CodeName DD' left style(column)=[width=5%];
	Define CodeDescription_DD / display 'CodeDescription DD' left style(column)=[width=5%];
	Define CodeListName_CL  / display 'CodeListName CL' left style(column)=[width=5%];
	Define CodeName_CL  / display 'CodeName CL' left style(column)=[width=5%];
	Define CodeDescription_CL / display 'CodeDescription CL' left style(column)=[width=5%];
	Define Include_in_v2_0_ / display 'Inversion V2.0' left style(column)=[width=5%];
	Define Inversion_Flag / display 'Inversion Flag' left style(column)=[width=5%];

	Compute Infile;
	If Infile = 'DD' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=green background=lightyellow font_weight=bold]");
	End;
	If Infile = 'Both' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	If Infile = 'CodeList' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeName_Flag;
	If CodeName_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeListName_Flag;
	If CodeListName_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeDesc_Flag;
	If CodeDesc_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute Inversion_Flag;
	If Inversion_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

Run; 

Proc Export Data = OBData.&_APIName._Code_Compare
 	Outfile = "C:\inetpub\wwwroot\sasweb\Data\Results\&_APIName._CodeList_DD_Comparison_Final_%Sysfunc(UPCASE(&Fdate)).csv"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;

ods tagsets.tableeditor close; 
ods listing; 


%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
title "Listing of Product Sales"; 
*--- Set Output Delivery Parameters  ---;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.SASWeb 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 


Proc Report Data = OBData.&_APIName._Code_Compare(Where=(Infile='Both')) nowd/*
	style(report)=[width=100%]
	style(report)=[rules=all cellspacing=0 bordercolor=gray] 
	style(header)=[background=lightskyblue foreground=black] 
	style(column)=[background=lightcyan foreground=black]*/;

	Title1 "Open Banking - CodeList Comparison";
	Title2 "Records Both In Data Dictionary (DD) and CodeList Reports - %Sysfunc(UPCASE(&Fdate))";

	Columns Count Infile 
	Hierarchy 
	CodeListName 
	CodeName 
	CodeDescription
	CodeListName_DD 
	CodeListName_CL 
	CodeName_DD 
	CodeName_CL 
	CodeDescription_DD
	CodeDescription_CL
	CodeName_Flag
	CodeListName_Flag
	CodeDesc_Flag
	Include_in_v2_0_
	InVersion_Flag;

	Define Count / display 'Row Count' left style(column)=[width=5%];
	Define Infile / display 'Infile' left style(column)=[width=5%];
	Define Hierarchy / display 'Data Level' left style(column)=[width=5%];
	Define CodeListName / display 'CodeList Name' left style(column)=[width=5%];
	Define CodeName / display 'Code Name' left style(column)=[width=5%];
	Define CodeDescription / display 'Code Description' left style(column)=[width=5%];
/*	Define CodeListName_Flag / display 'CodeList Name Flag' left style(column)=[width=5%];*/
	Define CodeName_Flag / display 'Code Name Flag' left style(column)=[width=5%];
	Define CodeListName_Flag / display 'Code List Name Flag' left style(column)=[width=5%];
	Define CodeDesc_Flag / display 'Code Description Flag' left style(column)=[width=5%];
	Define CodeListName_DD  / display 'CodeListName DD' left style(column)=[width=5%];
	Define CodeName_DD / display 'CodeName DD' left style(column)=[width=5%];
	Define CodeDescription_DD / display 'CodeDescription DD' left style(column)=[width=5%];
	Define CodeListName_CL  / display 'CodeListName CL' left style(column)=[width=5%];
	Define CodeName_CL  / display 'CodeName CL' left style(column)=[width=5%];
	Define CodeDescription_CL / display 'CodeDescription CL' left style(column)=[width=5%];
	Define Include_in_v2_0_ / display 'Inversion V2.0' left style(column)=[width=5%];
	Define Inversion_Flag / display 'Inversion Flag' left style(column)=[width=5%];

	Compute Infile;
	If Infile = 'DD' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=green background=lightyellow font_weight=bold]");
	End;
	If Infile = 'Both' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	If Infile = 'CodeList' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeName_Flag;
	If CodeName_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeListName_Flag;
	If CodeListName_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeDesc_Flag;
	If CodeDesc_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute Inversion_Flag;
	If Inversion_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

Run; 

ods tagsets.tableeditor close; 
ods listing; 

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
title "Listing of Product Sales"; 
*--- Set Output Delivery Parameters  ---;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.SASWeb 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

/*	ODS HTML File="C:\inetpub\wwwroot\sasweb\data\Results\CodeList Results.xls";*/

Proc Report Data = OBData.&_APIName._Code_Compare(Where=(Infile='CodeList')) nowd/*
	style(report)=[width=100%]
	style(report)=[rules=all cellspacing=0 bordercolor=gray] 
	style(header)=[background=lightskyblue foreground=black] 
	style(column)=[background=lightcyan foreground=black]*/;

	Title1 "Open Banking - CodeList Comparison";
	Title2 "Records only in the CodeList Excel Reports - %Sysfunc(UPCASE(&Fdate))";

	Columns Count Infile 
	Hierarchy 
	CodeListName 
	CodeName 
	CodeDescription
	CodeListName_DD 
	CodeListName_CL 
	CodeName_DD 
	CodeName_CL 
	CodeDescription_DD
	CodeDescription_CL
	CodeName_Flag
	CodeListName_Flag
	CodeDesc_Flag
	Include_in_v2_0_
	InVersion_Flag;

	Define Count / display 'Row Count' left style(column)=[width=5%];
	Define Infile / display 'Infile' left style(column)=[width=5%];
	Define Hierarchy / display 'Data Level' left style(column)=[width=5%];
	Define CodeListName / display 'CodeList Name' left style(column)=[width=5%];
	Define CodeName / display 'Code Name' left style(column)=[width=5%];
	Define CodeDescription / display 'Code Description' left style(column)=[width=5%];
/*	Define CodeListName_Flag / display 'CodeList Name Flag' left style(column)=[width=5%];*/
	Define CodeName_Flag / display 'Code Name Flag' left style(column)=[width=5%];
	Define CodeListName_Flag / display 'Code List Name Flag' left style(column)=[width=5%];
	Define CodeDesc_Flag / display 'Code Description Flag' left style(column)=[width=5%];
	Define CodeListName_DD  / display 'CodeListName DD' left style(column)=[width=5%];
	Define CodeName_DD / display 'CodeName DD' left style(column)=[width=5%];
	Define CodeDescription_DD / display 'CodeDescription DD' left style(column)=[width=5%];
	Define CodeListName_CL  / display 'CodeListName CL' left style(column)=[width=5%];
	Define CodeName_CL  / display 'CodeName CL' left style(column)=[width=5%];
	Define CodeDescription_CL / display 'CodeDescription CL' left style(column)=[width=5%];
	Define Include_in_v2_0_ / display 'Inversion V2.0' left style(column)=[width=5%];
	Define Inversion_Flag / display 'Inversion Flag' left style(column)=[width=5%];

	Compute Infile;
	If Infile = 'DD' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=green background=lightyellow font_weight=bold]");
	End;
	If Infile = 'Both' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	If Infile = 'CodeList' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeName_Flag;
	If CodeName_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeListName_Flag;
	If CodeListName_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeDesc_Flag;
	If CodeDesc_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute Inversion_Flag;
	If Inversion_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

Run; 

Proc Export Data = OBData.&_APIName._Code_Compare(Where=(Infile='CodeList'))
 	Outfile = "C:\inetpub\wwwroot\sasweb\Data\Results\&_APIName._CodeList_DD_Comparison_%Sysfunc(UPCASE(&Fdate)).csv"
	DBMS = CSV REPLACE;
	PUTNAMES=YES;
Run;

ods tagsets.tableeditor close; 
ods listing; 

%include "C:\inetpub\wwwroot\sasweb\TableEdit\tableeditor.tpl";
title "Listing of Product Sales"; 
*--- Set Output Delivery Parameters  ---;
ODS _All_ Close;
ods listing close; 

ods tagsets.tableeditor file=_Webout
    style=styles.SASWeb 
    options(autofilter="YES" 
 	    autofilter_table="1" 
            autofilter_width="9em" 
 	    autofilter_endcol= "50" 
            frozen_headers="0" 
            frozen_rowheaders="0" 
            ); 

Proc Report Data = OBData.&_APIName._Code_Compare(Where=(Infile='DD')) nowd/*
	style(report)=[width=100%]
	style(report)=[rules=all cellspacing=0 bordercolor=gray] 
	style(header)=[background=lightskyblue foreground=black] 
	style(column)=[background=lightcyan foreground=black]*/;

	Title1 "Open Banking - CodeList Comparison";
	Title2 "Records only in the Data Dictionary (DD) Excel Reports - %Sysfunc(UPCASE(&Fdate))";

	Columns Count Infile 
	Hierarchy 
	CodeListName 
	CodeName 
	CodeDescription
	CodeListName_DD 
	CodeListName_CL 
	CodeName_DD 
	CodeName_CL 
	CodeDescription_DD
	CodeDescription_CL
	CodeName_Flag
	CodeListName_Flag
	CodeDesc_Flag
	Include_in_v2_0_
	InVersion_Flag;

	Define Count / display 'Row Count' left style(column)=[width=5%];
	Define Infile / display 'Infile' left style(column)=[width=5%];
	Define Hierarchy / display 'Data Level' left style(column)=[width=5%];
	Define CodeListName / display 'CodeList Name' left style(column)=[width=5%];
	Define CodeName / display 'Code Name' left style(column)=[width=5%];
	Define CodeDescription / display 'Code Description' left style(column)=[width=5%];
/*	Define CodeListName_Flag / display 'CodeList Name Flag' left style(column)=[width=5%];*/
	Define CodeName_Flag / display 'Code Name Flag' left style(column)=[width=5%];
	Define CodeListName_Flag / display 'Code List Name Flag' left style(column)=[width=5%];
	Define CodeDesc_Flag / display 'Code Description Flag' left style(column)=[width=5%];
	Define CodeListName_DD  / display 'CodeListName DD' left style(column)=[width=5%];
	Define CodeName_DD / display 'CodeName DD' left style(column)=[width=5%];
	Define CodeDescription_DD / display 'CodeDescription DD' left style(column)=[width=5%];
	Define CodeListName_CL  / display 'CodeListName CL' left style(column)=[width=5%];
	Define CodeName_CL  / display 'CodeName CL' left style(column)=[width=5%];
	Define CodeDescription_CL / display 'CodeDescription CL' left style(column)=[width=5%];
	Define Include_in_v2_0_ / display 'Inversion V2.0' left style(column)=[width=5%];
	Define Inversion_Flag / display 'Inversion Flag' left style(column)=[width=5%];

	Compute Infile;
	If Infile = 'DD' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=green background=lightyellow font_weight=bold]");
	End;
	If Infile = 'Both' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=blue background=lightcyan font_weight=bold]");
	End;
	If Infile = 'CodeList' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeName_Flag;
	If CodeName_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeListName_Flag;
	If CodeListName_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute CodeDesc_Flag;
	If CodeDesc_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

	Compute Inversion_Flag;
	If Inversion_Flag = 'Mismatch' then 
	Do;
		Call Define(_col_,'style',"style=[foreground=red background=pink font_weight=bold]");
	End;
	Endcomp;

Run; 

Data _Null_;
	%ReturnButton;
Run;

ods tagsets.tableeditor close; 
ods listing; 

%Mend CodeList;
%CodeList();
