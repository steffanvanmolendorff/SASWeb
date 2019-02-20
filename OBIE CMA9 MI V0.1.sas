Libname OBData "C:\OB";

%Macro ImportIM(Dsn);

PROC IMPORT OUT= WORK.&Dsn 
            DATAFILE= "C:\OB\&Dsn..csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;


%Mend ImportIM;
%ImportIM(OBIE1);
%ImportIM(OBIE2);
%ImportIM(OBIE3);
%ImportIM(OBIE4);
%ImportIM(OBIE5);
%ImportIM(OBIE6);
%ImportIM(OBIE7);
%ImportIM(OBIE8);
%ImportIM(OBIE9);
%ImportIM(OBIE10);
