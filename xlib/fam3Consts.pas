unit fam3Consts;

interface
const
  YES=TRUE; NO=not YES;

  ALIAS='_family_tree_database_';
  ABSOLUTE_DATABASE_PATH:String='';
  PERSON_DB='person.db';
  ALAMAT_DB='alamat.db';
  TELP_DB='telepon.db';
  NIKAH_DB='nikah.db';
  INTERNET_DB='internet.db';
  field_00='ID';
  DEFAULT_FIELDNAME='DEFAULT';
  _RIntMark='_';

  //Origin=Person.ID
  f__Ayah='Ayah';
  f__Ibu='Ibu';
  f__Wali='Wali';
  f__Person='Person';
  f__Suami='Suami';
  f__Isteri='Isteri';

  //Origin=Alamat.Alamat
  f__Rumah='Rumah';
  f__Alamat='Alamat';
  f__Kantor='Kantor';
  f__Tempat='Tempat';

  //Origin=Telp.Telepon
  f__Telp='Telp';
  f__Telepon='Telepon';

  RInts_Origin_Self:String='';
  RInts_Origin_Person:String='';
  RInts_Origin_Alamat:String='';
  RInts_Origin_Telepon:String='';


  ///person.db
  fp_ID=field_00;
  fp_Nama='Nama';
  fp_Panggilan='Panggilan';
  fp_Gelar='Gelar';
  fp_Atribut='Atribut';
  fp_Sex='Sex';
  fp_LahirDi='Kelahiran';
  fp_TglLahir='TglLahir';
  fp_WafatDi='Dimakamkan';
  fp_TglWafat='TglWafat';
  fp_Ayah:String=f__Ayah;           //ID_Person Ayah Kandung
  fp_Ibu:String=f__Ibu;             //ID_Person Ibu Kandung
  fp_Wali:String=f__Wali;           //ID_Person Wali jika tidak ada orang tua kandung
  fp_Rumah:String=f__Rumah;        //ID_Alamat Rumah utama
  fp_Kantor:String=f__Kantor;       //ID_Alamat Kantor utama
  fp_Telp:String=f__Telp;     //ID_Telp saat ini / utama
//  fp_Internet=_RIntMark+'Internet';   //ID_Internet utama
  fp_Email='Email';   //ID_Internet utama
  fp_Photo='Photo';
  fp_Catatan='Catatan';
  nRI_Person=6;

  ///alamat.db
  fa_ID=field_00;
  fa_Person:String=f__Person;
  fa_Telepon:String=f__Telp;
  fa_JenisAlamat='Jenis';
    //Rumah, Kantor, GdPertemuan, Kontrakan, Kost, Flat, Villa,
    //Sekolah, Pesantren, Asrama, Mess, Dinas, Sementara, Lainnya
  fa_AlamatLengkap='Alamat';
  fa_Daerah='Daerah';
  fa_KodePos='KodePos';
  fa_Catatan='Catatan';
  nRI_Alamat=2;
  {not used
    fax_Jalan='Jalan';  fax_Nomor='Nomor';
    fax_RT='RT';  fa_RW='RW';
    fax_Kelurahan='Kelurahan';  fax_Kecamatan='Kecamatan';
    fax_Kota='Kota';  fax_Desa='Desa';  fax_Propinsi='Propinsi';
    fax_Gedung='Gedung';  fax_Lantai='Lantai';
    fax_Ruangan='Ruangan';  fax_Bagian='Bagian';
    fax_Blok='Blok';  fax_Kompleks='Kompleks';
    fax_Distrik='Distrik';  fax_NegaraBagian='NegaraBagian';
    fax_Negara='Negara';   fax_Benua='Benua';
  }

  ///telp.db
  ft_ID=field_00;
  ft_Person:String=f__Person;  //ID_Person
  ft_Alamat:String=f__Alamat;
  ft_JenisTelp='Jenis'; //Rumah, Ponsel, Kantor, FAX, Dinas, Hotline, Lainnya
  ft_KodeArea='KodeArea';
  ft_KodeNegara='KodeNegara';
  ft_Nomor='Nomor';
  ft_Extension='Extension';
  ft_Catatan='Catatan';
  nRI_Telepon=2;

  ///nikah.db
  fn_ID=field_00;
  fn_Suami:String=f__Suami;        //ID_Person
  fn_Isteri:String=f__Isteri;      //ID_Person
  fn_Tempat:String=f__Tempat;
  fn_Waktu='Waktu';
  fn_Cerai='Cerai';                     //Tanggal Cerai
  fn_Catatan='Catatan';
  nRI_Nikah=3;

{  ///internet.db
  fi_ID=field_00;
  fi_Person=_RIntMark+'Person';
  fi_JenisURL='Jenis';
  fi_URL='URL'; //Email, HomePage, FTP, Gopher, WAIS, Archie, Lainnya
  fi_Catatan='Catatan';
  nRI_Internet=1;
}

type
  TFieldConversion = (fxAuto2Int, fxInt2Auto);
  TFamTable = (dtPerson, dtAlamat, dtTelepon, dtNikah);//, dtInternet);
  TJenisAlamat = (jaRumah, jaKantor, jaGdPertemuan, jaKontrakan, jaKost, jaFlat,
    jaVilla, jaSekolah, jaPesantren, jaAsrama, jaMess, jaDinas, jaSementara, jaLainnya);
  TJenisTelepon = (jtRumah, jtPonsel, jtKantor, jtFAX, jtDinas, jtHotline, jtLainnya);
//  TJenisURL = (juEmail, juHomePage, juFTP, juGopher, juWAIS, juArchie, juLainnya);
  TIndexOption = (xoNone, xoPrimary, xoSecondary, xoClear);
  TIdxOptions = set of TIndexOption;
  TRIntMarkStyle = (rmNone, rmPrefix, rmSuffix, rmIdefix);

  TRModifier = packed record
    SETI: set of TIndexOption;
    //I:Integer;
    Test:Boolean;
  end;

const
  FamTablesName: array[TFamTable] of String =
    (PERSON_DB, ALAMAT_DB, TELP_DB, NIKAH_DB);//, INTERNET_DB);
  JenisAlamatStr: array[TJenisAlamat] of string =
    ('Rumah', 'Kantor', 'GdPertemuan', 'Kontrakan', 'Kost', 'Flat', 'Villa', 'Sekolah',
     'Pesantren', 'Asrama', 'Mess', 'Dinas', 'Sementara', 'Lainnya');
  JenisTeleponStr: array[TJenisTelepon] of string =
    ('Rumah', 'Ponsel', 'Kantor', 'FAX', 'Dinas', 'Hotline', 'Lainnya');
  nRInts: array[TFamTable] of Integer =
    (nRI_Person, nRI_Alamat, nRI_Telepon, nRI_Nikah);//, nRI_Internet);

  DEFAULT_RIntMarkStyle=rmSuffix;

function isRIntField(const Name:String):boolean;
function RIntMarkSet(const Name:String):String;
function RIntMarkStrip(const Name:String):String;
//procedure RIntFieldsBuildUp;

  type RInts = class(TObject)
    private
      procedure SetRIntMarkStyle(const rms:TRintMarkStyle);
      function GetRIntMarkStyle:TRIntMarkStyle;
    public
    property CurrentRIntMarkStyle:TRIntMarkStyle
     read GetRIntMarkStyle write SetRIntMarkStyle;
    Constructor Init;
    Destructor Done;
  end;

implementation
const fRintMarkStyle:TRintMarkStyle=rmNone;

function isRIntField(const Name:String):boolean;
begin
  if length(Name)<1 then Result:=FALSE else
  case fRIntMarkStyle of
    rmNone:Result:=TRUE;
    rmPrefix:Result:=Name[1]=_RIntMark;
    rmSuffix:Result:=Name[length(Name)]=_RIntMark;
    rmIdefix:Result:=pos(_RIntMark, Name) in [2..length(Name)-1];
    else Result:=FALSE;
  end;
end;

function RIntMarkSet(const Name:String):String; begin
  case fRIntMarkStyle of
    rmPrefix: Result:=_RIntMark+Name;
    rmSuffix: Result:=Name+_RIntMark;
    rmIdefix: Result:=Copy(Name, 1, length(Name) div 2)+ _RIntMark+
      Copy(Name, length(Name) div 2 +1, length(Name));
    else Result:=Name;
  end;
end;

function RIntMarkStrip(const Name:String):String; begin
  Result:=Name;
  if pos(_RIntMark, Name)>0 then
  case fRIntMarkStyle of
    rmPrefix: if pos(_RIntMark, Name)=1 then
      Result:=Copy(Name, 2, length(Name));
    rmSuffix: if pos(_RIntMark, Name)=length(Name) then
      Result:=Copy(Name, 1, length(Name)-1);
    rmIdefix: if pos(_RIntMark, Name) in [2..length(Name)-1] then
      Result:=Copy(Name, 1, pos(_RIntMark, Name)-1) +
        Copy(Name, pos(_RIntMark, Name)+1, length(Name));
    //rmNone, else: Result:=Name; //no need
  end
end;

procedure RIntFieldsBuildUp;
begin
  fp_Ayah:=RIntMarkSet(f__Ayah);
  fp_Ibu:=RIntMarkSet(f__Ibu);
  fp_Wali:=RIntMarkSet(f__Wali);
  fp_Rumah:=RIntMarkSet(f__Rumah);
  fp_Kantor:=RIntMarkSet(f__Kantor);
  fp_Telp:=RIntMarkSet(f__Telp);

  fa_Person:=RIntMarkSet(f__Person);
//  fa_Telepon:={RIntMarkSet}(f__Telepon);

  ft_Person:=RIntMarkSet(f__Person);
//  ft_Alamat:={RIntMarkSet}(f__Alamat);

  fn_Suami:=RIntMarkSet(f__Suami);
  fn_Isteri:=RIntMarkSet(f__Isteri);
  fn_Tempat:=RIntMarkSet(f__Tempat);

  RInts_Origin_Self:= fp_Ayah+fp_Ibu+fp_Wali;
  RInts_Origin_Person:= {fp_Ayah+fp_Ibu+fp_Wali+}fa_Person+fn_Suami+fn_Isteri;
  RInts_Origin_Alamat:= fp_Rumah+fp_Kantor{+ft_Alamat}+fn_Tempat;
  RInts_Origin_Telepon:=fp_Telp{+fa_Telepon};

end;

Constructor RInts.Init; begin inherited end;
Destructor RInts.Done; begin inherited end;

procedure RInts.SetRIntMarkStyle(const rms:TRintMarkStyle);
begin
  if rms<>fRIntMarkStyle then begin
    fRIntMarkStyle:=rms;
    RIntFieldsBuildUp;
  end;
end;

function RInts.GetRIntMarkStyle:TRintMarkStyle;
begin
  Result:=fRIntMarkStyle;
end;

initialization
  fRIntMarkStyle:=Default_RIntMarkStyle;
  RIntFieldsBuildUp;

end.



