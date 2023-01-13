unit UTGDT1;



interface

uses  SysUtils, Classes, Strutils, ValEdit, FileUtil, windows, LazFileUtils, LazUTF8;

type TGDTeinstellungen= Record
			empfaengerkuerzel, senderkuerzel : string[4];
			eingangsmodus,ausgangsmodus	 : boolean;
			extension			    : string[3];
			austauschpfad			: string[255];
                        exportpfad                      : string[255];
			zaehler				    : string[3];
      geraetekennung    : string[10];
   end;

                     TGdtRec= record
                                    laenge: integer;
                                    kennung: string[4];
                                    wert: string;
                     end;
                     Teinaus= (ein, aus);
                     str4   = string[4];

      Tsatzkennungen= Record
					Startsatz, StammdatenAnfordern,StammDatenUebermitteln,
					NeueUntersuchung,UntersuchungsDatenUebermitteln,
					UntersuchungsDatenZeigen, satzlaenge,GdtIdEmpfaenger,GdtIdSender,
					VerwendeterZeichensatz, GDTVersion,Patientennummer,
					Nammenszusatz,NamePatient,VornamePatient,GeburtsdatumPatient,TitelPatient,
					VerischertennummerPatient,WohnortPatient,StrassePatient,VersichertenartPatient,
					Geschlechtpatient,GroessePatient,GewichtPatient,SprachePatient,
					Softwareverantwortlicher,Software,Release,GeraeteKennfeld,TestIdent,
					TagDaten,ZeitDaten,Diagnose,Befund,Fremdbefund,Kommentar,AnzahlDZeilen,
					Ergebnistext,DateiarchivKenner,Dateiformat,DateiInhalt,DateiURL,
					TestBezeichnung,ProbematerialIdent,ProbematerialIndex,
					ProbematerialSpezifikation,EinheitenfuerDatenstrom,Datenstrom,Teststatus,
					ErgebnisWert,Einheit,AbnahmeDatum,AbnahmeZeit,Normalwerttext,
					NormalWertuntereGrenze,NormalwertobereGrenze,Anmerkung,
					Signatur: string[4];
                                        index: array[1..58] of ^str4;
				     end;
		  Tsatzindex= Record
					Startsatz, StammdatenAnfordern,StammDatenUebermitteln,
					NeueUntersuchung,UntersuchungsDatenUebermitteln,
					UntersuchungsDatenZeigen, satzlaenge,GdtIdEmpfaenger,GdtIdSender,
					VerwendeterZeichensatz, GDTVersion,Patientennummer,
					Nammenszusatz,NamePatient,VornamePatient,GeburtsdatumPatient,TitelPatient,
					VerischertennummerPatient,WohnortPatient,StrassePatient,VersichertenartPatient,
					Geschlechtpatient,GroessePatient,GewichtPatient,SprachePatient,
					Softwareverantwortlicher,Software,Release,GeraeteKennfeld,TestIdent,
					TagDaten,ZeitDaten,Diagnose,Befund,Fremdbefund,Kommentar,AnzahlDZeilen,
					Ergebnistext,DateiarchivKenner,Dateiformat,DateiInhalt,DateiURL,
					TestBezeichnung,ProbematerialIdent,ProbematerialIndex,
					ProbematerialSpezifikation,EinheitenfuerDatenstrom,Datenstrom,Teststatus,
					ErgebnisWert,Einheit,AbnahmeDatum,AbnahmeZeit,Normalwerttext,
					NormalWertuntereGrenze,NormalwertobereGrenze,Anmerkung,
					Signatur: integer;
				     end;

		  Tsatzdaten    = Array[1..58] of string[255];
               	     Tsatzaktiv    = Array[1..58] of boolean;

		  dbretfile = Record
				    bilder				 : array[1..10] of string[255];
				    titel				 : array[1..10] of string[80];
				    texte				 : array[1..10] of string[255];
				    id					 : string[80];
				    tag,monat,jahr,stunde,minute,sekunde : array[1..10] of string[10];
			end;
      dbapp     = record
                                       bilder : array[1..10] of array[0..255] of char;
                                       titel  : array[1..10] of array[0..255] of char;
                                       texte  : array[1..10] of array[0..255] of char;
                                       id     : array[0..80] of char;
				    tag,monat,jahr,stunde,minute,sekunde : array[1..10] of array[0..10] of char;
                end;

type
  TUgdt = class(TComponent)
  private
    function lesegdtdatei: string;
    procedure gdtfileeinordnen(daten: string);
    procedure printgdt;
    Function gdtzeile(var daten: string): Tgdtrec;
    function asc(a: char): byte;
    function loescheleer(a:string):string;
    procedure gengdt(a,b: string; append: boolean);


    { Private-Deklarationen }
  protected
    { Protected-Deklarationen }
  public
    function cvascii(s: pchar): string;
    function datenvorhanden: boolean;
    procedure gdtparametersetzen(daten: Tgdteinstellungen);
    function gdtlesen(daten: TGDTEinstellungen): String;
    procedure exportgdt(daten: Tgdteinstellungen; werte: TValueListEditor; Startsatz: string);
    function wideStrToMbyte(s: WideString; CodePage: word): ansistring;
    function mbytetowidestr(s: ansistring; CodePage: word): WideString;
    { Public-Deklarationen }
     constructor Create(ABesitzer: TComponent); override;
  published
    { Published-Deklarationen }
  end;

const kennzeichnung_fuer_edv = 'GDT-D-10';
   cr			     = #13;
   lf			     = #10;
   SatzIndex		     : TSatzIndex = (
				  Startsatz			 : 1 ;
				  StammdatenAnfordern		 : 2 ;
				  StammDatenUebermitteln	 : 3 ;
				  NeueUntersuchung		 : 4 ;
				  UntersuchungsDatenUebermitteln : 5 ;
				  UntersuchungsDatenZeigen	 : 6 ;
				  satzlaenge			 : 7;
				  GdtIdEmpfaenger		 : 8;
				  GdtIdSender			 : 9;
				  VerwendeterZeichensatz	 : 10;
				  GDTVersion			 : 11;
				  Patientennummer		 : 12;
				  Nammenszusatz			 : 13;
				  NamePatient			 : 14;
				  VornamePatient		 : 15;
				  GeburtsdatumPatient		 : 16;
				  TitelPatient			 : 17;
				  VerischertennummerPatient	 : 18;
				  WohnortPatient		 : 19;
				  StrassePatient		 : 20;
				  VersichertenartPatient	 : 21;
				  Geschlechtpatient		 : 22;
				  GroessePatient		 : 23;
				  GewichtPatient		 : 24;
				  SprachePatient		 : 25;
				  Softwareverantwortlicher	 : 26;
				  Software			 : 27;
				  Release			 : 28;
				  GeraeteKennfeld		 : 29;
				  TestIdent			 : 30;
				  TagDaten			 : 31;
				  ZeitDaten			 : 32;
				  Diagnose			 : 33;
				  Befund			 : 34;
				  Fremdbefund		         : 35;
				  Kommentar			 : 36;
				  AnzahlDZeilen			 : 37;
				  Ergebnistext			 : 38;
				  DateiarchivKenner		 : 39;
				  Dateiformat			 : 40;
				  DateiInhalt			 : 41 ;
				  DateiURL			 : 42;
				  TestBezeichnung		 : 43;
				  ProbematerialIdent		 : 44;
				  ProbematerialIndex		 : 45;
				  ProbematerialSpezifikation	 : 46;
				  EinheitenfuerDatenstrom	 : 47;
				  Datenstrom			 : 48;
				  Teststatus			 : 49;
				  ErgebnisWert			 : 50;
				  Einheit			 : 51;
				  AbnahmeDatum			 : 52;
				  AbnahmeZeit			 : 53;
				  Normalwerttext		 : 54;
				  NormalWertuntereGrenze	 : 55;
				  NormalwertobereGrenze		 : 56;
				  Anmerkung			 : 57;
				  Signatur			 : 58);
                                                                    
   satzkennung		     : Tsatzkennungen = (
				  Startsatz			 : '8000' ;
				  StammdatenAnfordern		 : '6300' ;
				  StammDatenUebermitteln	 : '6301' ;
				  NeueUntersuchung		 : '6302' ;
				  UntersuchungsDatenUebermitteln : '6310' ;
				  UntersuchungsDatenZeigen	 : '6311' ;
				  satzlaenge			 : '8100' ;
				  GdtIdEmpfaenger		 : '8315' ;
				  GdtIdSender			 : '8316' ;
				  VerwendeterZeichensatz	 : '9206' ;
				  GDTVersion			 : '9218' ;
				  Patientennummer		 : '3000' ;
				  Nammenszusatz			 : '3100' ;
				  NamePatient			 : '3101' ;
				  VornamePatient		 : '3102' ;
				  GeburtsdatumPatient		 : '3103' ;
				  TitelPatient			 : '3104' ;
				  VerischertennummerPatient	 : '3105' ;
				  WohnortPatient		 : '3106' ;
				  StrassePatient		 : '3107' ;
				  VersichertenartPatient	 : '3108' ;
				  Geschlechtpatient		 : '3110' ;
				  GroessePatient		 : '3622' ;
				  GewichtPatient		 : '3623' ;
				  SprachePatient		 : '3628' ;
				  Softwareverantwortlicher	 : '0102' ;
				  Software			 : '0103' ;
				  Release			 : '0123' ;
				  GeraeteKennfeld		 : '8402' ;
				  TestIdent			 : '8410' ;
				  TagDaten			 : '6200' ;
				  ZeitDaten			 : '6201' ;
				  Diagnose			 : '6205' ;
				  Befund			 : '6220' ;
				  Fremdbefund		         : '6221' ;
				  Kommentar			 : '6227' ;
				  AnzahlDZeilen			 : '6226' ;
				  Ergebnistext			 : '6228' ;
				  DateiarchivKenner		 : '6302' ;
				  Dateiformat			 : '6303' ;
				  DateiInhalt			 : '6304' ;
				  DateiURL			 : '6305' ;
				  TestBezeichnung		 : '8411' ;
				  ProbematerialIdent		 : '8428' ;
				  ProbematerialIndex		 : '8429' ;
				  ProbematerialSpezifikation	 : '8430' ;
				  EinheitenfuerDatenstrom	 : '8431' ;
				  Datenstrom			 : '8437' ;
				  Teststatus			 : '8418' ;
				  ErgebnisWert			 : '8420' ;
				  Einheit			 : '8421' ;
				  AbnahmeDatum			 : '8432' ;
				  AbnahmeZeit			 : '8439' ;
				  Normalwerttext		 : '8460' ;
				  NormalWertuntereGrenze	 : '8461' ;
				  NormalwertobereGrenze		 : '8462' ;
				  Anmerkung			 : '8470' ;
				  Signatur			 : '8990' ;
                                  index: (@Satzkennung.Startsatz,
                                         @Satzkennung.StammdatenAnfordern,
                                         @satzkennung.StammDatenUebermitteln,
                                         @satzkennung.NeueUntersuchung,
                                         @satzkennung.UntersuchungsDatenUebermitteln,
                                         @satzkennung.UntersuchungsDatenZeigen,
                                         @satzkennung.satzlaenge,
                                         @satzkennung.GdtIdEmpfaenger,
                                         @satzkennung.GdtIdSender,
                                         @satzkennung.VerwendeterZeichensatz,
                                         @satzkennung.GDTVersion,
                                         @satzkennung.Patientennummer,
                                         @satzkennung.Nammenszusatz,
                                         @satzkennung.NamePatient,
                                         @satzkennung.VornamePatient,
                                         @satzkennung.GeburtsdatumPatient,
                                         @satzkennung.TitelPatient,
                                         @satzkennung.VerischertennummerPatient,
                                         @satzkennung.WohnortPatient,
                                         @satzkennung.StrassePatient,
                                         @satzkennung.VersichertenartPatient,
                                         @satzkennung.Geschlechtpatient,
                                         @satzkennung.GroessePatient,
                                         @satzkennung.GewichtPatient,
                                         @satzkennung.SprachePatient,
                                         @satzkennung.Softwareverantwortlicher,
                                         @satzkennung.Software,
                                         @satzkennung.Release,
                                         @satzkennung.GeraeteKennfeld,
                                         @satzkennung.TestIdent,
                                         @satzkennung.TagDaten,
                                         @satzkennung.ZeitDaten,
                                         @satzkennung.Diagnose,
                                         @satzkennung.Befund,
                                         @satzkennung.Fremdbefund,
                                         @satzkennung.Kommentar,
                                         @satzkennung.AnzahlDZeilen,
                                         @satzkennung.Ergebnistext,
                                         @satzkennung.DateiarchivKenner,
                                         @satzkennung.Dateiformat,
                                         @satzkennung.DateiInhalt,
                                         @satzkennung.DateiURL,
                                         @satzkennung.TestBezeichnung,
                                         @satzkennung.ProbematerialIdent,
                                         @satzkennung.ProbematerialIndex,
                                         @satzkennung.ProbematerialSpezifikation,
                                         @satzkennung.EinheitenfuerDatenstrom,
                                         @satzkennung.Datenstrom,
                                         @satzkennung.Teststatus,
                                         @satzkennung.ErgebnisWert,
                                         @satzkennung.Einheit,
                                         @satzkennung.AbnahmeDatum,
                                         @satzkennung.AbnahmeZeit,
                                         @satzkennung.Normalwerttext,
                                         @satzkennung.NormalWertuntereGrenze,
                                         @satzkennung.NormalwertobereGrenze,
                                         @satzkennung.Anmerkung,
                                         @satzkennung.Signatur
                                         )
				  );
   FeldBeschreibung: Array[1..58]
   of string=('Startsatz','StammdatenAnfordern','StammDatenUebermitteln',
   'NeueUntersuchung','UntersuchungsDatenUebermitteln','UntersuchungsDatenZeigen',
   'satzlaenge','GdtIdEmpfaenger','GdtIdSender','VerwendeterZeichensatz','GDTVersion',
   'Patientennummer','Nammenszusatz','NamePatient','VornamePatient',
   'GeburtsdatumPatient',  'TitelPatient',   'VerischertennummerPatient',
   'WohnortPatient',   'StrassePatient',   'VersichertenartPatient',
   'Geschlechtpatient',   'GroessePatient',   'GewichtPatient',   'SprachePatient',
   'Softwareverantwortlicher','Software','Release','GeraeteKennfeld',
   'TestIdent','TagDaten','ZeitDaten','Diagnose','Befund',
   'Fremdbefund','Kommentar','AnzahlDZeilen','Ergebnistext','DateiarchivKenner',
   'Dateiformat','DateiInhalt','DateiURL','TestBezeichnung','ProbematerialIdent',
   'ProbematerialIndex','ProbematerialSpezifikation','EinheitenfuerDatenstrom',
   'Datenstrom','Teststatus','ErgebnisWert','Einheit','AbnahmeDatum',
   'AbnahmeZeit','Normalwerttext','NormalWertuntereGrenze',
   'NormalwertobereGrenze','Anmerkung','Signatur');


var intern: Record
             Gdt: TGDTeinstellungen;
             uebergabedatei: string;
             einaus: Teinaus;
             gdtdaten: string;
             felderaktiv: Tsatzaktiv;
             satzdaten: Tsatzdaten;
            end;

   meldungen: TStringList;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Urs Gerodetti', [TUgdt]);
end;

constructor TUgdt.Create(ABesitzer: TComponent);
Begin
  inherited create(ABesitzer);
  meldungen:=TStringList.Create;
end;

function TUgdt.mbytetowidestr(s: ansistring; CodePage: word): WideString;
var
  ci: integer;
begin
  if s = '' then
  begin
    Result := '';
    exit;
  end;
  ci := MultiBytetoWideChar(CodePage, 0, PChar(@s[1]), -1, nil, 0);
  setLength(Result, ci - 1);
  MultiBytetoWideChar(CodePage, 0, PChar(@s[1]), -1, PWideChar(@Result[1]), ci - 1);

end;

function TUgdt.wideStrToMbyte(s: WideString; CodePage: word): ansistring;
var
  ci: integer;
begin
  if s = '' then
  begin
    Result := '';
    exit;
  end;
  ci := WideChartoMultiByte(CodePage, 0, PwideChar(@s[1]), -1, nil, 0, nil, nil);
  setLength(Result, ci - 1);
  WideChartoMultiByte(CodePage, 0, PwideChar(@s[1]), -1, PChar(@Result[1]),
    ci - 1, nil, nil);

end;

procedure TUGDT.gdtparametersetzen(daten: Tgdteinstellungen);
var temp: TStringList;
    gebdat: string;
Begin
    intern.Gdt:=daten;
end;


function TUGDT.gdtlesen(daten: Tgdteinstellungen): string;
var temp: TStringList;
    gebdat: string;
Begin
    intern.Gdt:=daten;
    intern.gdtdaten:=lesegdtdatei;
    if intern.gdtdaten>'' then Begin
    gdtfileeinordnen(pchar(intern.gdtdaten));
    temp:=TStringList.Create;
    temp.Add('id='+inttostr(strtoint(intern.satzdaten[Satzindex.patientennummer])));
    temp.add('name='+intern.satzdaten[Satzindex.namePatient]);
    temp.add('vorname='+intern.satzdaten[Satzindex.vornamePatient]);
    temp.add('geschlecht='+intern.satzdaten[Satzindex.Geschlechtpatient]);
    temp.add('kasse='+intern.satzdaten[satzindex.VersichertenartPatient]);
    temp.add('Strasse='+intern.satzdaten[satzindex.StrassePatient]);
    temp.add('Plz='+intern.satzdaten[satzindex.WohnortPatient]);
    temp.add('Ort='+intern.satzdaten[satzindex.WohnortPatient]);
    gebdat:=intern.satzdaten[satzindex.GeburtsdatumPatient];
    gebdat:=copy(gebdat,1,2)+'.'+copy(gebdat,3,2)+'.'+copy(gebdat,5,4);
    temp.add('gebdat='+gebdat);
    temp.add('geraetekennfeld='+intern.satzdaten[satzindex.GeraeteKennfeld]);
    temp.add('geraeteid='+copy(intern.satzdaten[satzindex.GdtIdEmpfaenger],1,6));
    temp.add('GdtIdEmpfaenger='+intern.satzdaten[satzindex.GdtIdEmpfaenger]);
    temp.add('GdtIdSender='+intern.satzdaten[satzindex.GdtIdSender]);
    result:=temp.commatext;
    temp.free;
    end else Begin
      result:='';
    end;
end;

function Tugdt.datenvorhanden: boolean;
var
    dateiname: string;
    vollername: String;
Begin
     dateiname:=intern.Gdt.senderkuerzel+intern.Gdt.empfaengerkuerzel;
     if intern.Gdt.eingangsmodus then
        dateiname:=dateiname+'.'+intern.gdt.extension
     else begin
          meldungen.add('Fehler aufsteigende Dateierweiterung im Enfangsmodus wird nicht unterstützt!');
          dateiname:=dateiname+'.'+intern.gdt.extension;
     end;
     vollername:=intern.Gdt.austauschpfad+'\'+dateiname;
     result:=fileexists(vollername);
end;

function TUgdt.lesegdtdatei: string;
var gdtdatei : file of char;
    pbuffer: pointer;
    buffer : pchar;
    dateiname: string;
    dateilaenge: longint;
    error: integer;
    vollername: String;
    s: widestring;
Begin
  {$i-}
     dateiname:=intern.Gdt.senderkuerzel+intern.Gdt.empfaengerkuerzel;
     if intern.Gdt.eingangsmodus then
        dateiname:=dateiname+'.'+intern.gdt.extension
     else begin
          meldungen.add('Fehler aufsteigende Dateierweiterung im Enfangsmodus wird nicht unterstützt!');
          dateiname:=dateiname+'.'+intern.gdt.extension;
     end;
     vollername:=intern.Gdt.austauschpfad+'\'+dateiname;
     assignfile(gdtdatei,vollername);
     reset(gdtdatei);
     if (ioresult<>0) then begin
        meldungen.add(pchar('Fehler beim öffnen der Datei: '+vollername));
        error:=ioresult;
        result:='';
     end else begin
       pbuffer:=allocmem(filesize(vollername)+10);

       blockread(gdtdatei,pbuffer^,filesize(vollername),dateilaenge);
{     new(buffer);}
       buffer:=pbuffer;
{     writeln(buffer); }
//         system.DefaultAnsi2WideMove(buffer,s,length(buffer));
           s:=buffer;
         result:=(buffer);
//         system.DefaultWide2AnsiMove(s,result,length(s));
//       system.DefaultUnicode2AnsiMove(buffer,result,length(buffer));
//       result:=buffer;
       freemem(pbuffer,filesize(vollername)+10);
//       writeln(dateilaenge);
       close(gdtdatei);
       DeleteFileUTF8(intern.Gdt.austauschpfad+'\'+dateiname); { *Converted from DeleteFile*  }

     end;
{     delfile(intern.Gdt.austauschpfad+'\'+dateiname); }
end;

function TUgdt.cvascii(s: pchar): string;
var ci,offset: integer;
    g: char;
    rs: string;

Begin
//     rs:=string(s);
     ci:=0;
     offset:=0;
     while ci<length(s) do Begin
         if s[ci]>chr(126) then Begin
            case s[ci] of
                 #$81: Begin
                        rs:=rs+'ü';
                        g:=rs[length(rs)];
                        inc(offset);
                     end;

                 #$84: Begin
                        rs:=copy(rs,1,ci+offset)+'ä'+copy(rs,ci+2+offset,length(rs));
                        g:=rs[ci];
                        inc(offset);
                     end;
                 #$8E: Begin
                        rs:=copy(rs,1,ci+offset)+'Ä'+copy(rs,ci+2+offset,length(rs));
                        g:=rs[ci];
                        inc(offset);
                     end;

                 #$94: Begin
                        rs:=copy(rs,1,ci+offset)+'ö'+copy(rs,ci+2+offset,length(rs));
                        g:=rs[ci];
                        inc(offset);
                     end;
                 #$99: Begin
                        rs:=copy(rs,1,ci+offset)+'Ö'+copy(rs,ci+2+offset,length(rs));
                        g:=rs[ci];
                        inc(offset);
                     end;
                 #$9A: Begin
                        rs:=copy(rs,1,ci+offset)+'Ü'+copy(rs,ci+2+offset,length(rs));
                        g:=rs[ci];
                        inc(offset);
                     end;
                 #$E1: Begin
                        rs:=copy(rs,1,ci+offset)+'ß'+copy(rs,ci+2+offset,length(rs));
                        g:=rs[ci];
                        inc(offset);
                     end;
                 #$83: Begin
                        rs:=copy(rs,1,ci+offset)+'à'+copy(rs,ci+2+offset,length(rs));
                        g:=rs[ci];
                        inc(offset);
                     end;
                 #$A0: Begin
                        rs:=copy(rs,1,ci+offset)+'â'+copy(rs,ci+2+offset,length(rs));
                        g:=rs[ci];
                        inc(offset);
                     end;
                 #$82: Begin
                        rs:=copy(rs,1,ci+offset)+'é'+copy(rs,ci+2+offset,length(rs));
                        g:=rs[ci];
                        inc(offset);
                     end;

                 otherwise
                   rs:=rs+s[ci];
            end;
            end else rs:=rs+s[ci];
         inc(ci);
     end;
     result:=rs;
end;

Function TUgdt.gdtzeile(var daten: string): Tgdtrec;
var temp: string;
    l: integer;
begin
     {writeln(copy(daten,1,3),' ',daten);}
     l:=strtoint(copy(daten,1,3));
     gdtzeile.laenge:=l;
     temp:=copy(daten,1,l);
     if (temp[l-1]<>#13) or (temp[l]<>#10) then
        begin
            writeln('Fehler in GDT Zeile Länge nicht korrekt angegeben oder falscher Zeilenanbschluss');
            writeln(temp);
            halt(1);
        end;
     gdtzeile.kennung:=copy(daten,4,4);
     gdtzeile.wert:=pchar(copy(daten,8,l-9));
     daten:=pchar(rightStr(daten,length(daten)-l)); { cr lf wird gekappt }
end;

procedure TUgdt.gdtfileeinordnen(daten: string);
var i,z: integer;
    zeile: Tgdtrec;
    f: boolean;

Begin
     z:=0;
     while (daten>cr+lf) do Begin
           z:=z+1;
           zeile:=gdtzeile(daten);
           f:=false;

           for i:=1 to 58 do
               if zeile.kennung=satzkennung.index[i]^ then Begin
//                system.DefaultUnicode2AnsiMove(zeile.wert,s,length(zeile.wert));
                  intern.satzdaten[i]:=zeile.wert;
                  meldungen.Add('Gefunden: '+FeldBeschreibung[i]+' = '+zeile.wert);
                  f:=true;
               end;
           if (z=1) and (zeile.kennung<>satzkennung.index[Satzindex.Startsatz]^) then
           Begin
               meldungen.Add('Fehlerhafte GDT Eintrag in Zeile '+inttostr(z)+' muss Feld ');
               meldungen.Add(satzkennung.index[Satzindex.Startsatz]^+' stehen!');
               meldungen.Add(inttostr(zeile.laenge));
               meldungen.Add(zeile.kennung);
               meldungen.Add(zeile.wert);
//              halt(1);
           end;

           if not(f) then begin
              meldungen.Add('Fehlerhafte GDT Eintrag in Zeile '+inttostr(z)+' :');
              meldungen.Add(inttostr(zeile.laenge));
              meldungen.Add(zeile.kennung);
              meldungen.Add(zeile.wert);
//              halt(1);
           end;
     end;
//     meldungen.SaveToFile('GDT-IMP.LOG');
end;


function TUgdt.asc(a: char): byte;
var b: byte absolute a;
Begin
    asc:=b;
end;

function TUgdt.loescheleer(a:string):string;
Begin
     while (length(a)>0) and ((a[length(a)]=' ') or (a[length(a)]=#0)) do begin
            a:=leftstr(a,length(a)-1);
            if length(a)=0 then Begin
               loescheleer:='';
               exit;
            end;            
     end;
     loescheleer:=a;
end;

Var igdtbuffer: array[0..255] of array[1..255] of char;
    gdtlen    : array[0..255] of integer;
    gdtindex  : integer;
    
procedure TUgdt.gengdt(a,b: string; append: boolean);
var i,u: integer;
    l,d: string;
Begin
    d:=a+b+chr(10)+chr(13); { +#10+#13; }
    if a='8000' then begin
       for i:=0 to 255 do for u:=1 to 255 do
           igdtbuffer[i,u]:=' ';
           
       gdtindex:=0;
    end;
    if a='8100' then begin
        for i:=1 to length(d) do
            igdtbuffer[2][i+3]:=d[i];
    end else
    for i:=1 to length(d) do
        igdtbuffer[gdtindex][i+3]:=d[i];
    l:=inttostr(length(d)+3);
    l:=RightStr('000'+l,3);
    if a='8100' then begin
        for i:=1 to length(l) do
            igdtbuffer[2][i]:=l[i];
        gdtlen[2]:=length(d)+3;            
    end else Begin
        for i:=1 to length(l) do    
            igdtbuffer[gdtindex][i]:=l[i];  
        gdtlen[gdtindex]:=length(d)+3;
    end;
    if append then gdtindex:=gdtindex+1;
end;

procedure TUgdt.printgdt;
var i,u: integer;
    dateiname: string;
    dnext: string;
    edat: file of TGDTeinstellungen;
    datei: file of char;
    lfc    : char;
    crc    : char;
begin
     if not(intern.Gdt.ausgangsmodus) then begin
        dnext:=rightstr('000'+intern.Gdt.zaehler,3);
        intern.Gdt.zaehler:=rightstr('000'+inttostr(strtoint(intern.Gdt.zaehler)+1),3);
     end else begin
        dnext:=intern.Gdt.extension;
     end;
     crc:=cr; lfc:=lf;
     if intern.Gdt.exportpfad='' then Begin
     dateiname:=intern.Gdt.austauschpfad+'\'+intern.Gdt.empfaengerkuerzel+intern.Gdt.senderkuerzel+'.'+dnext;

     end
     else Begin
     dateiname:=intern.Gdt.exportpfad+'\'+intern.Gdt.empfaengerkuerzel+intern.Gdt.senderkuerzel+'.'+dnext;

     end;

     meldungen.Clear;
//     form1.Label3.Caption:=dateiname;
     assignfile(datei,dateiname);
     rewrite(datei);
     if (ioresult<>0) then Begin
//        messagebox(pchar('IO fehler '+ioresult,'Fehler',MB_OK);
        exit;
     end;
     for i:=0 to gdtindex-1 do Begin
         meldungen.Add(inttostr(i));
         for u:=1 to gdtlen[i]-2 do begin
             meldungen[i]:=meldungen[i]+igdtbuffer[i][u];
             write(datei,igdtbuffer[i][u]);
         end;
         write(datei,crc);
         write(datei,lfc);
     end;
     closefile(datei);
//     assignfile(edat,'gdtinst\'+dateiname+'.data');
//     assignfile(edat,dateiname);
//     rewrite(edat);
//     write(edat,intern.gdt);
//     closefile(edat);
end;

procedure TUgdt.exportgdt(daten: Tgdteinstellungen; werte: TValueListEditor; Startsatz: string);
var ci: integer;
    gdtl: longint;
    datenzeilen,kommentarzeilen: TStringList;
Begin
//     assignfile(gdtdatei,intern.Gdt.austauschpfad+'\'+dateiname);
      datenzeilen:=TStringList.create;
      kommentarzeilen:=TStringlist.create;
      intern.Gdt:=daten;
      gdtindex:=0;
      gengdt(satzkennung.Startsatz,Startsatz,true);
      gengdt(satzkennung.GDTVersion,'2.10',true);
      gengdt(satzkennung.satzlaenge,'00000',true);
      if werte.Values['geraetekennfeld']<>'' then Begin
      gengdt(satzkennung.GeraeteKennfeld,werte.Values['geraetekennfeld'],true);
      end;
      gengdt(satzkennung.Patientennummer,werte.Values['id'],true);
      if werte.Values['name']<>'' then gengdt(satzkennung.NamePatient,werte.values['name'],true);
      if werte.Values['vorname']<>'' then gengdt(satzkennung.VornamePatient,werte.values['vorname'],true);
      if werte.Values['gebdat']<>'' then gengdt(satzkennung.GeburtsdatumPatient,werte.values['gebdat'],true);
      if werte.Values['adresse']<>'' then gengdt(satzkennung.StrassePatient,werte.values['adresse'],true);
      if werte.Values['wohnort']<>'' then gengdt(satzkennung.WohnortPatient,werte.values['wohnort'],true);
      if werte.Values['datum']<>'' then  gengdt(satzkennung.TagDaten,werte.values['datum'],true);
      if werte.Values['zeit']<>'' then gengdt(satzkennung.ZeitDaten,werte.Values['zeit'],true);
      if werte.Values['GdtIdEmpfaenger']<>'' then gengdt(satzkennung.GdtIdEmpfaenger,werte.Values['GdtIdEmpfaenger'],true);
      if werte.Values['GdtIdSender']<>'' then gengdt(satzkennung.GdtIdSender,werte.Values['GdtIdSender'],true);
      if werte.Values['text']<>'' then Begin
      datenzeilen.CommaText:=werte.Values['text'];
//      kommentarzeilen.CommaText:=werte.Values['kommentar'];
        for ci:=0 to datenzeilen.Count-1 do Begin
            gengdt(satzkennung.Ergebnistext,datenzeilen[ci],true);
//        gengdt(satzkennung.Ergebnistext,kommentarzeilen[ci],true);
          end;
      end;
      ci:=1;
      while werte.Values['werte'+inttostr(ci)]<>'' do Begin
          gengdt(satzkennung.TestIdent,werte.Values['ident'+inttostr(ci)],true);
          gengdt(satzkennung.ErgebnisWert,werte.Values['werte'+inttostr(ci)],true);
          inc(ci);
//          gengdt(satzkennung.ErgebnisWert,werte.Values['werte'+inttostr(ci)],true);
      end;
      if werte.Values['DateiarchivKenner']<>'' then gengdt(satzkennung.DateiarchivKenner,werte.Values['DateiarchivKenner'],true);
      if werte.Values['Dateiformat']<>'' then gengdt(satzkennung.Dateiformat,werte.Values['Dateiformat'],true);
      if werte.Values['DateiURL']<>'' then gengdt(satzkennung.DateiURL,werte.Values['DateiURL'],true);
      if werte.Values['DateiInhalt']<>'' then gengdt(satzkennung.DateiInhalt,werte.Values['DateiInhalt'],true);

      gdtl:=0;
      for ci:=0 to 255 do gdtl:=gdtl+gdtlen[ci];
      gengdt(satzkennung.satzlaenge,rightStr('00000'+inttostr(gdtl),5),false);
      printgdt;
      datenzeilen.Free;
end;

end.
