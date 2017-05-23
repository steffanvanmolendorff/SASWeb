*http://support.sas.com/resources/papers/proceedings17/SAS0224-2017.pdf
 https://accounts.google.com/o/oauth2/v2/auth?
         scope=https://www.googleapis.com/auth/analytics.readonly
         &redirect_uri=urn:ietf:wg:oauth:2.0:oob
         &response_type=code
         &client_id=<your-client-id>.apps.googleusercontent.com;

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

filename sec "H:\STV\Open Banking\SAS\Data\Temp";
data _null_;
length str $1024;
fid = fopen("sec");
rc = fread(fid);
rc = fget(fid, str, 256);
call symput("client_secret",trim(str));
rc = fclose(fid);
run;


filename resp TEMP;
proc http url="https://www.googleapis.com/oauth2/v4/token"
method="POST"
out=resp
headerout=hdrs
ct="application/x-www-form-urlencoded"
in="code=&code.%nrstr(&client_id)=&client_id.%nrstr(&client_secret)=&client_secret.%nrstr(&redirect_uri)=&redirect_uri.&grant_type=client_credentials";
run;
%let client_secret=;


data _null_;
infile resp truncover scanover length=len;
input @'"access_token": ' t $varying1024. len;
token = dequote(t);
call symput("access_token",trim(token));
run;


filename sample "Getting Started.pdf";
proc http url="https://www.googleapis.com/drive/v3/files/0BwfmKHYUomArc3RhcnRlcl9maWxl?alt=media"
out=sample;
headers "Authorization" = "Bearer &access_token.";
run;



*=================================================================================================================;
/* file to store your result */
filename token "H:\STV\Open Banking\SAS\Data\Temp\token.json";
%let code_given =4/nbQmQ2pybqVtyUcBJcKRGnpGcYO4_V5HOC0EsxW4vok;
%let oauth2=https://www.googleapis.com/oauth2/v4/token;
%let client_id=865598563534-mhq96j414u8512mnfhdh6ehhqo7gg39g.apps.googleusercontent.com;
%let client_secret=uRJGZ9YJ1GhbIPj53Rk-UJ7t;
proc http
/* put this all on one line! */
 url="&oauth2.?client_id=&client_id.%str(&)code=&code_given.%str(&)client_secret=&client_secret.%str(&)redirect_uri=urn:ietf:wg:oauth:2.0:oob%str(&)grant_type=authorization_code%str(&)response_type=token"
 method="POST"
 out=token
;
run;



