unit enumprop;
{
  version 1.0.0.0
  version 1.0.0.1, updated 1 Jan 2006
  ------------------------------------------------
  Copyright (c) 2004, aa, Adrian Hafizh & Inge DR.
  Copyright (c) 2005-2006, Adrian H & Ray AF.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mail,to:@[zero_inge]AT@-y.a,h.o.o.@DOTcom,
  mail,to:@[aa]AT@-s.o.f.t,i.n.d.o.@DOTnet
  http://delphi.softindo.net
  ------------------------------------------------

  sometimes (or many), we just want to examine properties
  at run time. this little helper will do the job nicely.

  note:
    for an event to be correctly determined, the Owner argument
    should be supplied properly (usually it is the form container,
    or simply Self in the main form).

  example1:
    procedure TForm1.Button1Click(Sender: TObject);
    var
      i: integer;
      L: TStringList;
    begin
      L := TStringList.Create;
      try
        for i := 0 to ComponentCount - 1 do begin
          L.Add(Components[i].Name);
          enumComponentProperties(Components[i], L, Self);
          L.Add('');
        end;
        //ClipBoard.AsText := L.Text;
        showmessage(L.Text);
      finally
        L.Free;
      end;
    end;

  example2:
    procedure TForm1.Button2Click(Sender: TObject);
    var
      fr: tform;
      Compo: TComponent; // Instance to be enumerated
    begin
      fr := Tform.Create(Self);
      with fr do try
        BorderStyle := bsSizeToolWin;
        Position := poScreenCenter;
        Font := Self.Font;
        //Font.Name := 'Lucida Console';
        //Font.Size := 8;
        with tmemo.Create(fr) do begin
          Parent := fr;
          Align := alClient;
          WordWrap := FALSE;
          ScrollBars := ssBoth;

          // enumerate...
          Compo := Self; // ...for example
          Lines.Add('CONTROLS:');
          Lines.Add(stringOfChar('-', 72));
          enumprop.enumControls(Compo, Lines);
          Lines.Add(''); Lines.Add('COMPONENTS:');
          Lines.Add(stringOfChar('-', 72));
          enumprop.enumComponents(Compo, Lines);
          Lines.Add(''); Lines.Add('PROPERTIES:');
          Lines.Add(stringOfChar('-', 72));

          // for child control the owner should be set
          // properly (default = nil)
          enumprop.enumComponentProperties(Compo, Lines);
        end;
        ShowModal;
      finally
        Free;
      end;
    end;

}

interface

uses
  {.$I COMPILERS.INC}// checked for DELPHI only, version 3,4 and 5
{$IFNDEF VER100}{$IFNDEF VER120}{$IFNDEF VER130}Variants, {$ENDIF}{$ENDIF}{$ENDIF}
  Classes;

procedure enumControls(const Component: TComponent; const Strings: TStrings);
procedure enumComponents(const Component: TComponent; const Strings: TStrings);

//procedure enumComponentProperties(const Instance: TObject; const Strings: TStrings;
//  const Owner: TObject = nil; const ObjectLevel: integer = 0);

procedure enumComponentProperties(const Instance: TObject; const Strings: TStrings;
  //  const Owner: TObject = nil; const Recursive: boolean = FALSE);
  const Owner: TObject; const Recursive: boolean); // D3Compatible

// Left indentation of Object/Property, repeated by LevelCount
// may be modified at your convenience
const
  INDENSTR_OBJECT: string = ^i;
  INDENSTR_PROPERTY: string = '  ';
  LEVELBREAKSTR: string = ^m^j;

implementation
uses SysUtils, Controls, TypInfo; //, OrdNums;

type
  tMyControl = class(tControl);

procedure enumControls(const Component: TComponent; const Strings: TStrings);
var
  i: Integer;
begin
  if assigned(Component) then
    if Component is TWinControl then
      with Component as TWinControl do
        for i := 0 to ControlCount - 1 do
          with tMyControl(Controls[i]) do
            Strings.Add(Caption + ' ' + Name + ': ' + ClassName)
end;

procedure EnumComponents(const Component: TComponent; const Strings: TStrings);
var
  i: Integer;
begin
  if assigned(Component) then
    with Component do
      for i := 0 to ComponentCount - 1 do
        with Components[i] do
          Strings.Add(Name + ': ' + ClassName)
end;

function getIndenStr(const objLevel, propLevel: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to objLevel do
    Result := Result + INDENSTR_OBJECT;
  for i := 1 to propLevel do
    Result := Result + INDENSTR_PROPERTY;
end;

procedure _enumProp(const Instance: TObject; const Strings: TStrings;
  const Owner: TObject = nil; const ObjectLevel: integer = 0);
var
  Root: TObject;

  procedure enumObjectProperties(const Instance: TObject; const Strings: TStrings;
    const propLevel: integer = 0);

  const
    MethodKindName: array[TMethodKind] of string = ('procedure', 'function',
      'constructor', 'destructor', 'Class procedure', 'Class function',
      { Obsolete }'Safe procedure call', 'Safe function call');

    TypeKindName: array[TTypeKind] of string = (
      'Unknown', 'Integer', 'Char', 'Enumeration', 'Float',
      'ShortString', 'Set', 'Class', 'Method', 'WChar',
      'String', 'WideString', 'Variant', 'Array', 'Record',
      'Interface', 'Int64', 'Dynamic Array'
      );

    //propIndenChar = ' ';

  resourcestring
    SInvalidPropertyType = 'Invalid property type: %s';
    SQuote = '"';
    SNil = 'nil';
    SBoolean = 'Boolean';
    SUnknown = 'Unknown';
    SComma = ',';
    SHexSuffix = 'H';
    SFormat = '[%s] %s: %s = %s%s';

  var
    Count, Size, i, k, p, n: Integer;
    m: TMethod;
    Obj: TObject;
    List: PPropList;
    fPropInfo: PPropInfo;
    fPropType: PTypeInfo;
    fTypeData: PTypeData;
    enumPropType: PTypeInfo;
    enumTypeData: PTypeData;
    fPropTypeKind: TTypeKind;
    PropName, PropTypeName, PropTypeKindName, PropValue, enums: string;

    IndenStr, objIndenStr, propIndenStr: string;

  begin
    if not assigned(Instance) then exit;
    Count := GetPropList(Instance.ClassInfo, tkAny, nil);
    Size := Count * SizeOf(Pointer);
    GetMem(List, Size);

    objIndenStr := '';
    for n := 1 to ObjectLevel do
      objIndenStr := objIndenStr + INDENSTR_OBJECT;

    try
      Count := GetPropList(Instance.ClassInfo, tkAny, List);
      for i := 0 to Count - 1 do begin
        fPropInfo := List^[i];
        PropName := fPropInfo^.Name;
        fPropType := fPropInfo^.PropType^;
        PropTypeName := fPropInfo^.PropType^.Name;
        fPropTypeKind := fPropInfo^.PropType^.Kind;
        PropTypeKindName := TypeKindName[fPropTypeKind];

        PropValue := ''; enums := '';
        fTypeData := getTypeData(fPropType);

        //case fPropInfo^.PropType^^.Kind of
        p := 0;
        case fPropTypeKind of
          tkInteger: PropValue := inttoStr(GetOrdProp(Instance, fPropInfo));
          tkChar: PropValue := Char(GetOrdProp(Instance, fPropInfo));
          tkWChar: PropValue := WideChar(GetOrdProp(Instance, fPropInfo));
          tkClass: begin
              p := GetOrdProp(Instance, fPropInfo);
              if p = 0 then propValue := SNil
              else
                propValue := inttoHex(p, 8) + SHexSuffix;
            end;
          tkEnumeration: PropValue := GetEnumProp(Instance, fPropInfo);
          tkSet: PropValue := GetSetProp(Instance, fPropInfo, TRUE);
          tkFloat: PropValue := FloatToStr(GetFloatProp(Instance, fPropInfo));
          tkMethod: PropTypeKindName := MethodKindName[fTypeData^.MethodKind];
          tkString, tkLString, tkWString: PropValue := SQUOTE + GetStrProp(Instance, fPropInfo) + SQUOTE;
          tkVariant: PropValue := VarToStr(GetVariantProp(Instance, fPropInfo));
          tkInt64: PropValue := inttoHex(GetInt64Prop(Instance, fPropInfo), 16);
        else
          raise EPropertyConvertError.CreateResFmt(@SInvalidPropertyType, [fPropInfo.PropType^^.Name]);
        end;

        case fPropTypeKind of
          tkEnumeration:
            if fTyPeData^.BaseType^ = TypeInfo(Boolean) then
              PropTypeKindName := SBoolean
            else
              for k := fTypeData.MinValue to fTypeData.MaxValue do begin
                if enums <> '' then enums := enums + SCOMMA;
                enums := enums + GetEnumName(fPropType, k);
              end;
          tkSet: begin
              enumPropType := fTypeData.CompType^;
              enumTypeData := getTypeData(enumPropType);
              for k := enumTypeData.MinValue to enumTypeData.MaxValue do begin
                if enums <> '' then enums := enums + SCOMMA;
                enums := enums + GetEnumName(enumTypeData^.BaseType^, k);
              end;
            end;
          tkMethod: begin
              m := GetMethodProp(Instance, fPropInfo);
              if not assigned(m.code) then PropValue := SNil
              else if assigned(Root) then PropValue := Root.MethodName(m.Code);
              if PropValue = '' then PropValue := SUnknown;
            end;
        end;

        if enums <> '' then enums := ' of (' + enums + ')';

        propIndenStr := '';
        for n := 1 to propLevel do
          propIndenStr := propIndenStr + INDENSTR_PROPERTY;
        IndenStr := objIndenStr + propIndenStr;

        Strings.Add(IndenStr + Format(SFORMAT,
          [PropTypeKindName, PropName, PropTypeName, PropValue, enums]));

        case fPropTypeKind of
          tkClass: begin
              Obj := nil;
              if fPropType <> nil then
                if fPropInfo <> nil then
                  if fTypeData <> nil then
                    Obj := TObject(p);
              enumObjectProperties(Obj, Strings, propLevel + 1);
            end;
        else begin
          end;
        end;
      end;

    finally
      FreeMem(List);
    end;
  end;

begin
  Root := Owner;
  if Root = nil then Root := Instance;
  enumObjectProperties(Instance, Strings, 0);
end;

procedure _enumPropRecursive(const Instance: TObject; const Strings: TStrings;
  //  const Owner: TObject = nil; const Level: integer = 0);
  const Owner: TObject; const Level: integer); // D3Compatible
var
  i: integer;
  Com: tComponent;
begin
  _enumProp(Instance, Strings, Owner, Level);
  if Instance is tComponent then begin
    Com := tComponent(Instance);
    for i := 0 to Com.ComponentCount - 1 do begin
      _enumPropRecursive(Com.Components[i], Strings, Com, Level + 1);
    end;
  end;
end;

procedure enumComponentProperties(const Instance: TObject; const Strings: TStrings;
  //  const Owner: TObject = nil; const Recursive: boolean = FALSE);
  const Owner: TObject; const Recursive: boolean); // D3Compatible
begin
  if not Recursive then _enumProp(Instance, Strings, Owner, 0)
  else _enumPropRecursive(Instance, Strings, Owner, 0)
end;

function SimplePos(const pattern, text: ANSIString): integer;
var
  i, j, k, m, n: integer;
  skip: packed array[byte] of integer;
  found: boolean;
begin
  Result := 0; found := FALSE;
  m := length(pattern);
  if m = 0 then begin
    Result := 1;
    found := TRUE;
  end;

  for k := 0 to high(byte) do skip[k] := m;
  for k := 1 to m - 1 do skip[ord(pattern[k])] := m - k;

  k := m; n := length(text);

  while not found and (k <= n) do begin
    i := k;
    j := m;
    while (j >= 1) do
      if text[i] <> pattern[j] then j := -1
      else begin
        j := j - 1;
        i := i - 1;
      end;
    if j = 0 then begin
      Result := i + 1;
      found := TRUE;
    end;
    k := k + skip[ord(text[k])];
  end;
end;

end.

