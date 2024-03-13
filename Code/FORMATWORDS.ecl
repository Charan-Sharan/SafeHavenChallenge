import STD;
EXPORT FORMATWORDS:=MODULE
EXPORT FORMATCITY_V1(STRING S ) := FUNCTION
 RmSp:=STD.Str.CleanSpaces(S);
 Cap:=STD.Str.ToUpperCase(Rmsp);
 standard1:=STD.Str.FindReplace(Cap, 'ST.', 'SAINT');
 Standard2:=STD.STR.FindReplace(Standard1,'FT.','FORT');
 Standard3:=STD.Str.FindReplace(Standard2, 'MT.', 'MOUNT');
 RETURN Standard3;
END;

EXPORT FORMATCITY_V2(STRING S ) :=FUNCTION 
      JustCity:=IF(STD.Str.Find(S, ',',1)>0,S[1..STD.Str.Find(S, ',',1)-1],s);
     RmSp:=STD.Str.CleanSpaces(JustCity);
     Cap:=STD.Str.ToUpperCase(Rmsp); 
	 standard1:=STD.Str.FindReplace(CAp, 'ST.', 'SAINT');
     Standard2:=STD.STR.FindReplace(Standard1,'FT.','FORT');
     Standard3:=STD.Str.FindReplace(Standard2, 'MT.', 'MOUNT');
	 standard4:=STD.STR.FindReplace(Standard3,'COUNTY','');
	 Standard5:=STD.STR.FIndReplace(Standard4,'CITY','');

	 RETURN standard5;
END;

END;