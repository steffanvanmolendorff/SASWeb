%Macro DD_CodeList(API);

%Include "C:\inetpub\wwwroot\sasweb\source\&API CodeList Comparison.sas";

%Mend DD_CodeList;
%DD_CodeList(ATM);
%DD_CodeList(BCH);
%DD_CodeList(PCA);
%DD_CodeList(BCA);
%DD_CodeList(SME);
%DD_CodeList(CCC);

