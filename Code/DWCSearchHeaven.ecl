// #OPTION('obfuscateOutput',TRUE);
import $,STD;
BASEDATAF:=$.BWR_XTAB.BASEDATAF;
// STRING44 City_key := '' : STORED('City');
// STRING2 State_key:= '' : STORED('State_id');
// UNSIGNED3 Fips_key:=0 : STORED('County_Fips');

CS_base_Key := $.Generate_IDX.CSIDX;
F_base_Key :=$.Generate_IDX.FIDX;

EXPORT DWCSearchHeaven(STRING44 City_key,STRING2 State_key) := FUNCTION
// Heaven_filter:=IF(city_key='' OR state_key='',
//                   F_base_key(County_fips=Fips_key),
//                 //   CS_base_key(STD.STR.ToUpperCase(STD.Str.CleanSpaces(City))=STD.STR.ToUpperCase(STD.Str.CleanSpaces(City_key)),
//                 //   State_id=STD.Str.ToUpperCase(STD.Str.CleanSpaces(state_key))  )) ;
//                   CS_base_key(state_key=state_id AND city=city_key AND fips_key=County_fips));
Heaven_filter:=CS_base_key(state_key=state_id AND city=city_key);
AllFields:=FETCH(BASEDATAF,Heaven_Filter,RIGHT.RecPos);
 RETURN ALLFields;
END;
