IMPORT $,STD;
EXPORT Generate_IDX:=MODULE
SHARED BaseFile:=$.BWR_XTab.BASEDATAF;

EXPORT CSIDX:=INDEX(BaseFile,{city,state_id},{city,state_id,recPos},'~SAFE::DWC::OUT::BASEINDEX');
EXPORT FIDX:=INDEX(BASeFile,{County_fips},{county_fips,RecPos},'~SAFE::DWC::OUT::BASEFINDEX');

END;