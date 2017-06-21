PROC IMPORT OUT= WORK.OBPaySet 
            DATAFILE= "C:\inetpub\wwwroot\sasweb\Data\Temp\OBPAYSET.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
