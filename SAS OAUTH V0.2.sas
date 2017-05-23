*================================================================================================================
				STEP 0. Set Default Path and Options
=================================================================================================================;
*--- Change directory to default location on PC to save data extracted from Google API ---;
X "CD H:\STV\Open Banking\SAS\Data\Temp";

*================================================================================================================
				STEP 1. Submit URL in Browser to get Authentication code
=================================================================================================================;
*https://accounts.google.com/o/oauth2/v2/auth?scope=https://www.googleapis.com/auth/analytics.readonly&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code&client_id=865598563534-rrbeueevd6rmkl80u2o7r1st8o0mn55f.apps.googleusercontent.com 
Options NOQUOTELENMAX;

%let auth_url=https://accounts.google.com/o/oauth2/v2/auth;
%let client_id=865598563534-rrbeueevd6rmkl80u2o7r1st8o0mn55f.apps.googleusercontent.com;
%let redirect_uri=urn:ietf:wg:oauth:2.0:oob;
%let drive_scope=https://www.googleapis.com/auth/drive;
%let url=&auth_url.?client_id=&client_id.%nrstr(&redirect_uri)=&redirect_uri.%nrstr(&response_type=code&scope=openid%20email)%20&drive_scope.&state=security_token);

Filename hdrs Temp;

proc http
url="&url"
headerout=hdrs
nofollow;
run;

data _null_;
infile hdrs length=len scanover truncover;
input @'Location: ' loc $varying1024. len;
call symput('location',trim(loc));
run;
%Put _ALL_;

options noxsync noxwait;
x "start """" ""&location.""";


*================================================================================================================
				STEP 2. Exchange the auth code for an access token file to store your result
=================================================================================================================;

*--- This is the Authentication Code as provided on the Google API page when executing STEP 1 ---;
*--- Next steps: Automate this manual process so that SAS reads the Access code from the Google API webpage ---;
%let code_given =4/msJ1Q_LtomrWPW5Woh2h9yI3dnR9ltCpxlu1SbKXD3E;

*--- This is the location and filename of where the Refreshed Token will be saved from the Proc HTTP step below ---;
Filename Token "H:\STV\Open Banking\SAS\Data\Temp\token.json";

*--- This is the Google API OAUTH2 token URL ---;
%Let OAuth2=https://www.googleapis.com/oauth2/v4/token;

*--- This is the client_id of the Google API Console Account Holder i.e. S van Molendorff ---;
*--- This step must also be automated to read the Client ID from file and not have it hard coded in the source program ---;
%Let Client_id = 865598563534-rrbeueevd6rmkl80u2o7r1st8o0mn55f.apps.googleusercontent.com ;

*--- This is the Client Secret code as provided by the Google API Console ---;
*--- This step must also be automated to read the Client ID from file and not have it hard coded in the source program ---;
*%Let Client_secret=d0AyYx8Bz1nLq_2aGVSrh_xV;

Filename Sec "H:\STV\Open Banking\SAS\Data\Perm";
Data _Null_;
	Length str $1024;
	Fid = Fopen("Sec");
	Rc = Fread(fid);
	Rc = Fget(fid, str, 256);

	Call Symput("Client_secret",trim(str));
	Rc = Fclose(fid);
run;


*--- Proc HTTP submits the Access code (&Code_Given) to Google API and receives the Refreshed Token which is saved in the Token.json file ---;
*--- Out = Token ---;
Proc HTTP
	URL="&oauth2.?client_id=&client_id.%str(&)code=&code_given.%str(&)client_secret=&client_secret.%str(&)redirect_uri=urn:ietf:wg:oauth:2.0:oob%str(&)grant_type=authorization_code%str(&)response_type=token"
 	Method="POST"
 	Out=Token;
Run;

*--- Read the Refresh Token data from the step above and save the Refresh Token in a Macro variable which is passed to the Resource Server ---;
*--- The Resource Server in this instance is the Google API Console ---;
Filename RToken "H:\STV\Open Banking\SAS\Data\Temp\token.json"; 

DATA Work.Bearer_Token; 
Infile RToken LRECL = 3456677 TRUNCOVER SCANOVER dsd dlm=",}"; 
	Input 	@'"token_type":' Token_Type : $30. 
			@'"expires_in":' Expires_In: $10. 
			@'"refresh_token":' Refresh_Token: $75.;
			Call Symput('Refresh_Token',Trim(Left(Refresh_Token)));
Run;


*================================================================================================================
	STEP 3. Do this every time you want to use the GA API to Turn in a Refresh-Token for a valid Access-Token
	Should be good for 60 minutes - So typically run once at beginning of the job
=================================================================================================================;
%let oauth2=https://www.googleapis.com/oauth2/v4/token;
*%let client_id= 865598563534-rrbeueevd6rmkl80u2o7r1st8o0mn55f.apps.googleusercontent.com ;
*%let client_secret=d0AyYx8Bz1nLq_2aGVSrh_xV;

Filename AToken "H:\STV\Open Banking\SAS\Data\Temp\token.json"; 
proc http
	URL="&oauth2.?client_id=&client_id.%str(&)client_secret=&client_secret.%str(&)grant_type=refresh_token%str(&)refresh_token=&refresh_token."
	Method="POST"
	Out=AToken;
run;
 
*--- Read the access token out of the refresh response - Relies on the JSON libname engine (9.4m4 or later) ---;
*--- Read the Access Token data from the step above and save the Access Token in a Macro variable which is passed to the Resource Server ---;
*--- The Resource Server in this instance is the Google API Console ---;
Libname AToken json Fileref=RToken;

*--- Save the Access Token within the dataset in a Macro Variable to use in further service requests to the Resource Server ---;
Data _Null_;
	Set AToken.Root;
 	Call Symputx('Access_Token',access_token);
Run;


 
*================================================================================================================
	STEP 4. Use the Google Analytics API to gather data
=================================================================================================================;

*--- Set the Start Date value for which statistical data will be requested from the Google Aalytics website ---;
%Let Startdate=%sysevalf('30Apr2017'd); 
*--- Set the End Date values for which statistical data will be requested from the Google Aalytics website ---;
%Let Enddate = %sysfunc(today()); 


*--- Metrics and dimensions are defined in the Google Analytics doc. Experiment in the developer console for the right mix
 	Your scenario might be different and would require a different type of query. 
	The GA API will "number" the return elements as element1, element2, element3 and so on.
	In my example, path and title will be 1 and 2 ---;
%let dimensions=  %sysfunc(urlencode(%str(ga:pagePath,ga:pageTitle)));

*--- then pageviews, uniquepageviews, timeonpage will be 3, 4, 5, etc. ---;
%let metrics = %sysfunc(urlencode(%str(ga:pageviews,ga:uniquePageviews,ga:timeOnPage,ga:entrances,ga:exits)));

*--- This ID is the "View ID" for the GA data you want to access ---;
%let id = %sysfunc(urlencode(%str(ga:150429035)));
 
*--- Assign the GA Libname to save the Proc HTTP routine ---;
Libname GA "H:\STV\Open Banking\SAS\Data\Temp";

*--- The Macro Get Gooogle Analytics Data will send the HTTP request and save the results in a table ---;
%Macro GetGAdata; 
*--- The WorkDate macro will loop through from the Start Date to the End Date as set above in the macro variables ---; 
 %Do Workdate = &Enddate %to &Startdate %By -1; 
*--- Set the format of the URLDate to Year Month Day ---;
 	%Let URLdate=%Sysfunc(Putn(&Workdate.,yymmdd10.)); 

*--- Assign a Temporary filename to output the results from the HTTP query ---;
*--- The same Filename as AToken or RToken can also be assigned - however this is more efficient ---;
	Filename GA_Resp Temp; 

*--- Proc HTTP will submit the query with Header information to the Google Analytics API ---;
 	Proc HTTP 
		URL="https://www.googleapis.com/analytics/v3/data/ga?ids=&id.%str(&)start-date=&urldate.%str(&)end-date=&urldate.%str(&)metrics=&metrics.%str(&)dimensions=&dimensions.%str(&)max-results=20000" 
 	 	Method="GET"
		Out=GA_Resp; 
 	 	Headers "Authorization"="Bearer &Access_Token." 
		"Client-id:"="&Client_id."; 
 	Run; 
 
*--- The JSON Libname Engine will translate the JSON code into a SAS table (SAS Dataset) ---;
 	Libname GA_Resp JSON Fileref=GA_Resp; 
 

 	Data GA.GA_Daily%Sysfunc(compress(&URLdate.,'-')) (Drop=Element:); 
 		Set GA_Resp.Alldata; 
* 		Drop Ordinal_root Ordinal_rows; 
 		Length Date 8 URL $ 300 Title $ 250 Views 8 Unique_views 8 Time_on_page 8 Entrances 8 Exits 8; 

*--- Format the Date value ---;
		Format Date yymmdd10.; 

*--- The Date variable is assigned the WorkDate ---;

		Date = &Workdate.; 
* Create new variables assign the elements variables to the new data variables ---; 
		URL = Element1; 
 		Title = Element2; 
 		Views = Input(element3, 5.); 
 		Unique_views = Input(element4, 6.); 
 		Time_on_page = Input(element5, 7.2); 
 		Entrances = Input(element6, 6.); 
 		Exits = Input(element7, 6.); 

 	Run;
 
 %End; 

 %Mend getGAdata; 
%getGAdata; 
 

*--- Append the the daily files/datasets into one data set ---; 
 Data Work.Alldays_GAdata; 
   Set GA.GA_Daily:; 
 Run; 

/*
Data X1;
 	X1=10;
Run;

Data X2;
 	X2=20;
Run;

Data X3;
 	X3=30;
Run;

Data XYZ;
	Merge X:;
Run;
