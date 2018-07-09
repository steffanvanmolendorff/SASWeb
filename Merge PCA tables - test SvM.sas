data work.x1;
 set work.pca_pcamarketingstate;
	ID = compress(ordinal_root||'-'||
	ordinal_data||'-'||
	ordinal_brand||'-'||
	ordinal_pca||'-'||
	ordinal_pcamarketingstate);
run;


data work.x2;
	set work.pcamarketingstate_coreproduct;
	ID = compress(ordinal_root||'-'||
	ordinal_data||'-'||
	ordinal_brand||'-'||
	ordinal_pca||'-'||
	ordinal_pcamarketingstate/*||'-'||
	ordinal_Coreproduct*/);
run;

data work.x3;
	set work.Otherfeescharges_feechargecap;
	ID = compress(ordinal_root||'-'||
	ordinal_data||'-'||
	ordinal_brand||'-'||
	ordinal_pca||'-'||
	ordinal_pcamarketingstate/*||'-'||
	ordinal_Coreproduct*/);
run;

data work.x4;
	set work.Feechargedetail_otherfeetype;
	ID = compress(ordinal_root||'-'||
	ordinal_data||'-'||
	ordinal_brand||'-'||
	ordinal_pca||'-'||
	ordinal_pcamarketingstate/*||'-'||
	ordinal_Coreproduct*/);
run;

data work.x5;
	set work.Feechargecap_feetype;
	ID = compress(ordinal_root||'-'||
	ordinal_data||'-'||
	ordinal_brand||'-'||
	ordinal_pca||'-'||
	ordinal_pcamarketingstate/*||'-'||
	ordinal_Coreproduct*/);
run;

data work.x6;
	set work.Feechargedetail_notes;
	ID = compress(ordinal_root||'-'||
	ordinal_data||'-'||
	ordinal_brand||'-'||
	ordinal_pca||'-'||
	ordinal_pcamarketingstate/*||'-'||
	ordinal_Coreproduct*/);
run;

data work.x7/*(keep = ID 
	ordinal_root
	ordinal_data
	ordinal_brand
	ordinal_pca
	ordinal_pcamarketingstate
	ordinal_Coreproduct
	ordinal_OtherFeesCharges
	ordinal_FeeChargeCap)*/;
merge work.x1(in=a)
work.x2(in=b)
work.x3(in=c)
work.x4(in=d)
work.x5(in=e)
work.x6(in=f);
by id;
if a then dsn = 'a';
if b then dsn = 'b';
if c then dsn = 'c';
if d then dsn = 'd';
if e then dsn = 'e';
if f then dsn = 'f';
/*if a and b then dsn = 'd';*/
run;
