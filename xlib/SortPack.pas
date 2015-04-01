unit SortPack;
{$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-}//no-debug
{
  Copyright (c) 2004, aa, Inge DR. & Adrian Hafizh.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  (this format should stop spammer-bot, to be stripped are:
   at@, brackets[], comma,, overdots., and dash-
   DO NOT strip underscore_)

  mail,to:@[zero_inge]AT@-y.a,h.o.o.@DOTcom,
  mail,to:@[aa]AT@-s.o.f.t,i.n.d.o.@DOTnet
  http://delphi.softindo.net

  Description: trim, sort and pack routines of
    TInts : array of Integers;
    TArInts : array of array of Integers;
    TStrs : array of String;

  note: trim functions was carried from Delphi's SysUtils, not optimized yet

  Compiler: D5, maybe works also on D4, but not D3 (because of default args value)

  This software is free for any purposes, distribution licensed
  under the terms of BSD License, see COPYING.

  Version: 1.0.0.1
  LastUpdated: 2005.01.09
}
interface
uses ACConsts;

//type
//  TInts = array of integer;
//  TArInts = array of TInts; //array of array of integer; ~ugly
//  TStrs = array of string;
type
  TInts = ACConsts.TInts;
  TArInts = ACConsts.TArInts;
  TStrs = ACConsts.TStrs;
  TKeyVals = ACConsts.TKeyVals;

type
  TIntsMember = function(const I: integer): boolean;
  //whether some particular values are not belong to an Ints (used by pack function)

function SortUp(var a, b: integer): integer; overload //asm //returns max value
function SortDown(var a, b: integer): integer; overload //asm //returns min value
function SortUp(var a, b, c: integer): integer; overload //asm //returns max value
function SortDown(var a, b, c: integer): integer; overload //asm //returns max value
//function SortUp(var a, b, c: int64): integer; overload //asm //returns max value
//function SortDown(var a, b, c: int64): integer; overload //asm //returns max value

// sorting result is element[lowest or highest] value, depend on ascending/descending.
function SortInts(var Ints: TInts; const Ascending: boolean = TRUE): integer; overload;
function SortUp(var Ints: TInts): integer; overload;
function SortDown(var Ints: TInts): integer; overload;
function SortByKey(var KeyVals: TKeyVals; const Ascending: boolean = TRUE): TKeyVal; overload;
function SortByVal(var KeyVals: TKeyVals; const Ascending: boolean = TRUE): TKeyVal; overload;

//insert int in a sorted Ints, return pos

function packStrs(var Strs: TStrs): integer; // remove blank string from a Strs

function packInts(var Ints: TInts): integer; overload; // remove 0 from an Ints
function packInts(var Ints: TInts; const Removed: integer): integer; overload; // remove specific value from an Ints
function packInts(var Ints: TInts; const minValue, maxValue: integer): integer; overload; // remove outrange values from an Ints
function packInts(var Ints: TInts; const Valid: TIntsMember): integer; overload; // remove from an Ints by custom filter (only Valid Member)

function packArInts(var ArInts: TArInts): integer; overload; // remove nil from an ArInts
//function packArInts0(var ArInts: TArInts): integer; overload; // remove nil from 0-packed Ints items of an ArInts
function packArInts(var ArInts: TArInts; const Removed: integer): integer; overload; // remove nil from filter-packed Ints items of an ArInts
function packArInts(var ArInts: TArInts; const minValue, maxValue: integer): integer; overload; // see description below
function packArInts(var ArInts: TArInts; const Valid: TIntsMember): integer; overload; // see description below

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// function for test only,  DO NOT USE!
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//function test_packArInts0(var ArInts: TArInts): integer; overload; // remove nil from 0-packed Ints items of an ArInts
function test_packArInts(var ArInts: TArInts; const Removed: integer): integer; overload; // remove nil from filter-packed Ints items of an ArInts
function test_packArInts(var ArInts: TArInts; const minValue, maxValue: integer): integer; overload; // see description below
function test_packArInts(var ArInts: TArInts; const Valid: TIntsMember): integer; overload; // see description below

implementation

function SortUp(var a, b: integer): integer; overload asm //ascending, returns min value
  mov ecx, [eax]; cmp ecx, [edx]; jle @done
  xchg ecx, [edx]; mov [eax], ecx
  @done: mov eax, [eax] // +1 clock do no harm
end;

function SortDown(var a, b: integer): integer; overload asm //descending, returns max value
  mov ecx, [eax]; cmp ecx, [edx]; jge @done
  xchg ecx, [edx]; mov [eax], ecx
  @done: mov eax, [eax] // +1 clock do no harm
end;

function SortUp(var a, b, c: integer): integer; overload asm //ascending, returns min value
  @begin: push ebx; mov ebx, [edx]

  cmp [eax], ebx; jle @doneAB
  xchg [eax], ebx; mov [edx], ebx
  @doneAB: mov ebx, [ecx]

  cmp [eax], ebx; jle @doneAC
  xchg [eax], ebx; mov [ecx], ebx
  @doneAC:

  cmp [edx], ebx; jle @done
  xchg [edx], ebx; mov [ecx], ebx // 4 clock + LOCK

  @done: mov eax, [eax] // +1 clock do no harm
  @end:pop ebx
end;

function SortDown(var a, b, c: integer): integer; overload asm //descending, returns max value
  @begin: push ebx; mov ebx, [edx]

  cmp [eax], ebx; jge @doneAB
  xchg [eax], ebx; mov [edx], ebx

  @doneAB: mov ebx, [ecx]
  cmp [eax], ebx; jge @doneAC
  xchg [eax], ebx; mov [ecx], ebx

  @doneAC:
  cmp [edx], ebx; jge @done
  xchg ebx, [edx]; mov [ecx], ebx

  @done: mov eax, [eax] // +1 clock do no harm
  @end:pop ebx
end;

function SortInts(var Ints: TInts; const Ascending: boolean = TRUE): integer; overload;
// invalid Result is -1, may be coincident with Ints[0] value
  procedure QSortUp(const Ints: TInts; L, R: integer);
  var
    i, j: Integer;
    A, B: integer;
  begin
    repeat
      i := L; j := R;
      A := Ints[(L + R) shr 1];
      repeat
        //if Ascending then begin
        while Ints[i] < A do inc(i); //the only differences
        while Ints[j] > A do dec(j); //the only differences
        //end
        //else begin
        //  while Ints[i] > A do inc(i); //the only differences
        //  while Ints[j] < A do dec(j); //the only differences
        //end;
        if i <= j then begin
          B := Ints[i];
          Ints[i] := Ints[j];
          Ints[j] := B;
          inc(i); dec(j);
        end;
      until i > j;
      if L < j then
        QSortUp(Ints, L, j);
      L := i;
    until i >= R;
  end;

  procedure QSortDown(const Ints: TInts; L, R: integer);
  var
    i, j: Integer;
    A, B: integer;
  begin
    repeat
      i := L; j := R;
      A := Ints[(L + R) shr 1];
      repeat
        //if Ascending then begin
        //  while Ints[i] < A do inc(i); //the only differences
        //  while Ints[j] > A do dec(j); //the only differences
        //end
        //else begin
        while Ints[i] > A do inc(i); //the only differences
        while Ints[j] < A do dec(j); //the only differences
        //end;
        if i <= j then begin
          B := Ints[i];
          Ints[i] := Ints[j];
          Ints[j] := B;
          inc(i); dec(j);
        end;
      until i > j;
      if L < j then
        QSortDown(Ints, L, j);
      L := i;
    until i >= R;
  end;

var
  n: integer;
begin
  n := length(Ints); // valid value 0..MaxInt no negative?
  case n {and $7FFFFFFF} of
    0: Result := -1; // invalid Result is -1, may be coincident with Ints[0] value
    2: begin
        Result := Ints[0];
        if ascending xor (Result < Ints[1]) then begin
          Result := Ints[1];
          Ints[1] := Ints[0];
          Ints[0] := Result;
        end
      end;
    3: if ascending then
        Result := SortUp(Ints[0], Ints[1], Ints[2])
      else
        Result := SortDown(Ints[0], Ints[1], Ints[2]);
  else begin
      if n > 1 then
        if Ascending then
          QSortUp(Ints, 0, n - 1)
        else
          QSortDown(Ints, 0, n - 1);
      Result := Ints[0];
    end
  end;
end;

function SortByKey(var KeyVals: TKeyVals; const Ascending: boolean = TRUE): TKeyVal; overload;
// invalid Result is -1, may be coincident with Ints[0] value
  procedure QSortUp(const KeyVals: TKeyVals; L, R: integer);
  var
    i, j: Integer;
    A: integer;
    B: int64;
  begin
    repeat
      i := L; j := R;
      A := KeyVals[(L + R) shr 1].Key;
      repeat
        //if Ascending then begin
        while KeyVals[i].Key < A do inc(i); //the only differences
        while KeyVals[j].Key > A do dec(j); //the only differences
        //end
        //else begin
        //  while KeyVals[i].Key > A do inc(i); //the only differences
        //  while KeyVals[j].Key < A do dec(j); //the only differences
        //end;
        if i <= j then begin
          B := int64(KeyVals[i]);
          int64(KeyVals[i]) := int64(KeyVals[j]);
          int64(KeyVals[j]) := B;
          inc(i); dec(j);
        end;
      until i > j;
      if L < j then
        QSortUp(KeyVals, L, j);
      L := i;
    until i >= R;
  end;

  procedure QSortDown(const KeyVals: TKeyVals; L, R: integer);
  var
    i, j: Integer;
    A: integer;
    B: int64;
  begin
    repeat
      i := L; j := R;
      A := KeyVals[(L + R) shr 1].Key;
      repeat
        //if Ascending then begin
        //  while KeyVals[i].Key < A do inc(i); //the only differences
        //  while KeyVals[j].Key > A do dec(j); //the only differences
        //end
        //else begin
        while KeyVals[i].Key > A do inc(i); //the only differences
        while KeyVals[j].Key < A do dec(j); //the only differences
        //end;
        if i <= j then begin
          B := int64(KeyVals[i]);
          int64(KeyVals[i]) := int64(KeyVals[j]);
          int64(KeyVals[j]) := B;
          inc(i); dec(j);
        end;
      until i > j;
      if L < j then
        QSortDown(KeyVals, L, j);
      L := i;
    until i >= R;
  end;

var
  n: integer;
begin
  n := length(KeyVals); // valid value 0..MaxInt no negative?
  case n {and $7FFFFFFF} of
    0: int64(Result) := -1; // invalid Result is -1, may be coincident with KeyVals[0] value
    2: begin
        Result := KeyVals[0];
        if ascending xor (Result.Key < KeyVals[1].Key) then begin
          int64(Result) := int64(KeyVals[1]);
          int64(KeyVals[1]) := int64(KeyVals[0]);
          int64(KeyVals[0]) := int64(Result);
        end
      end;
    //3: if ascending then
    //    Result := SortUp(KeyVals[0], KeyVals[1], KeyVals[2])
    //  else
    //    Result := SortDown(KeyVals[0], KeyVals[1], KeyVals[2]);
  else begin
      if n > 1 then
        if Ascending then
          QSortUp(KeyVals, 0, n - 1)
        else
          QSortDown(KeyVals, 0, n - 1);
      Result := KeyVals[0];
    end
  end;
end;

function SortByVal(var KeyVals: TKeyVals; const Ascending: boolean = TRUE): TKeyVal; overload;
// invalid Result is -1, may be coincident with Ints[0] value
  procedure QSortUp(const KeyVals: TKeyVals; L, R: integer);
  var
    i, j: Integer;
    A: integer;
    B: int64;
  begin
    repeat
      i := L; j := R;
      A := KeyVals[(L + R) shr 1].Value;
      repeat
        //if Ascending then begin
        while KeyVals[i].Value < A do inc(i); //the only differences
        while KeyVals[j].Value > A do dec(j); //the only differences
        //end
        //else begin
        //  while KeyVals[i].Value > A do inc(i); //the only differences
        //  while KeyVals[j].Value < A do dec(j); //the only differences
        //end;
        if i <= j then begin
          B := int64(KeyVals[i]);
          int64(KeyVals[i]) := int64(KeyVals[j]);
          int64(KeyVals[j]) := B;
          inc(i); dec(j);
        end;
      until i > j;
      if L < j then
        QSortUp(KeyVals, L, j);
      L := i;
    until i >= R;
  end;

  procedure QSortDown(const KeyVals: TKeyVals; L, R: integer);
  var
    i, j: Integer;
    A: integer;
    B: int64;
  begin
    repeat
      i := L; j := R;
      A := KeyVals[(L + R) shr 1].Value;
      repeat
        //if Ascending then begin
        //  while KeyVals[i].Value < A do inc(i); //the only differences
        //  while KeyVals[j].Value > A do dec(j); //the only differences
        //end
        //else begin
        while KeyVals[i].Value > A do inc(i); //the only differences
        while KeyVals[j].Value < A do dec(j); //the only differences
        //end;
        if i <= j then begin
          B := int64(KeyVals[i]);
          int64(KeyVals[i]) := int64(KeyVals[j]);
          int64(KeyVals[j]) := B;
          inc(i); dec(j);
        end;
      until i > j;
      if L < j then
        QSortDown(KeyVals, L, j);
      L := i;
    until i >= R;
  end;

var
  n: integer;
begin
  n := length(KeyVals); // valid value 0..MaxInt no negative?
  case n {and $7FFFFFFF} of
    0: int64(Result) := -1; // invalid Result is -1, may be coincident with KeyVals[0] value
    2: begin
        Result := KeyVals[0];
        if ascending xor (Result.Value < KeyVals[1].Value) then begin
          int64(Result) := int64(KeyVals[1]);
          int64(KeyVals[1]) := int64(KeyVals[0]);
          int64(KeyVals[0]) := int64(Result);
        end
      end;
    //3: if ascending then
    //    Result := SortUp(KeyVals[0], KeyVals[1], KeyVals[2])
    //  else
    //    Result := SortDown(KeyVals[0], KeyVals[1], KeyVals[2]);
  else begin
      if n > 1 then
        if Ascending then
          QSortUp(KeyVals, 0, n - 1)
        else
          QSortDown(KeyVals, 0, n - 1);
      Result := KeyVals[0];
    end
  end;
end;

function SortUp(var Ints: TInts): integer; overload;
begin
  Result := SortInts(Ints);
end;

function SortDown(var Ints: TInts): integer; overload;
begin
  Result := SortInts(Ints, FALSE);
end;

// function SortUp(Ints: TInts): integer; overload;
// invalid Result is -1, may be coincident with Ints[0] value
//   procedure QSortUp(Ints: TInts; L, R: Integer);
//   var
//     i, j: Integer;
//     A, B: integer;
//   begin
//     repeat
//       i := L; j := R;
//       A := Ints[(L + R) shr 1];
//       repeat
//         while Ints[i] > A do inc(i); //the only differences
//         while Ints[j] < A do dec(j); //the only differences
//         if i <= j then begin
//           B := Ints[i];
//           Ints[i] := Ints[j];
//           Ints[j] := B;
//           inc(i); dec(j);
//         end;
//       until i > j;
//       if L < j then QSortUp(Ints, L, j);
//       L := i;
//     until i >= R;
//   end;
// var
//   n: integer;
// begin
//   n := length(Ints);
//   case n of
//     0: Result := -1;
//     2: Result := SortUp(Ints[0], Ints[1]);
//     3: Result := SortUp(Ints[0], Ints[1], Ints[2])
//     else begin
//         if n > 1 then QSortUp(Ints, 0, n - 1);
//         Result := Ints[0];
//       end
//   end;
// end;
//
// function SortDown(Ints: TInts): integer; overload;
// invalid Result is -1, may be coincident with Ints[0] value
//   procedure QSortDown(Ints: TInts; L, R: Integer);
//   var
//     i, j: Integer;
//     A, B: integer;
//   begin
//     repeat
//       i := L; j := R;
//       A := Ints[(L + R) shr 1];
//       repeat
//         while Ints[i] < A do inc(i); //the only differences
//         while Ints[j] > A do dec(j); //the only differences
//         if i <= j then begin
//           B := Ints[i];
//           Ints[i] := Ints[j];
//           Ints[j] := B;
//           inc(i); dec(j);
//         end;
//       until i > j;
//       if L < j then QSortDown(Ints, L, j);
//       L := i;
//     until i >= R;
//   end;
// var
//   n: integer;
// begin
//   n := length(Ints);
//   case n of
//     0: Result := -1;
//     2: Result := SortDown(Ints[0], Ints[1]);
//     3: Result := SortDown(Ints[0], Ints[1], Ints[2])
//     else begin
//         if n > 1 then QSortDown(Ints, 0, n - 1);
//         Result := Ints[0];
//       end
//   end;
// end;

function packStrs(var Strs: TStrs): integer; // remove blank string from a Strs
var
  n, k: integer;
  X: TStrs;
begin
  Result := length(Strs);
  if Result > 0 then begin
    SetLength(X, Result);
    k := 0;
    for n := 0 to Result - 1 do
      if Strs[n] <> '' then begin
        X[k] := Strs[n];
        inc(k);
      end;
    if k < length(Strs) then begin
      Result := k;
      SetLength(Strs, k);
      for k := 0 to k - 1 do
        Strs[k] := X[k]
    end;
  end;
end;

function packInts(var Ints: TInts): integer; overload;
// will remove 0 from an Ints
var
  n, k: integer;
  X: TInts;
begin
  Result := length(Ints);
  if Result > 0 then begin
    SetLength(X, Result);
    k := 0;
    for n := 0 to Result - 1 do
      if Ints[n] <> 0 then begin
        X[k] := Ints[n];
        inc(k);
      end;
    if k < length(Ints) then begin
      Result := k;
      SetLength(Ints, k);
      for k := 0 to k - 1 do
        Ints[k] := X[k]
    end;
  end;
end;

function packInts(var Ints: TInts; const Removed: integer): integer; overload;
// remove specific value from an Ints
var
  n, i: integer;
  X: TInts;
begin
  Result := length(Ints);
  if Result > 0 then begin
    SetLength(X, Result);
    i := 0;
    for n := 0 to Result - 1 do
      if Ints[n] <> Removed then begin
        X[n] := Ints[n];
        inc(i);
      end;
    if i < length(Ints) then begin
      Result := i;
      SetLength(Ints, i);
      for i := 0 to i - 1 do
        Ints[i] := X[i];
    end;
  end;
end;

function packInts(var Ints: TInts; const minValue, maxValue: integer): integer; overload;
// remove outrange values from an Ints
var
  n, i: integer;
  X: TInts;
begin
  Result := length(Ints);
  if Result > 0 then begin
    SetLength(X, Result);
    i := 0;
    for n := 0 to Result - 1 do
      if (Ints[n] >= MinValue) and (Ints[n] <= MaxValue) then begin
        X[n] := Ints[n];
        inc(i);
      end;
    if i < length(Ints) then begin
      Result := i;
      SetLength(Ints, i);
      for i := 0 to i - 1 do
        Ints[i] := X[i]
    end;
  end;
end;

function packInts(var Ints: TInts; const Valid: TIntsMember): integer; overload;
// remove from an Ints by custom filter (only Valid Member)
var
  n, i: integer;
  X: TInts;
begin
  Result := length(Ints);
  if Result > 0 then begin
    SetLength(X, Result);
    i := 0;
    for n := 0 to Result - 1 do
      if Valid(Ints[n]) then begin
        X[n] := Ints[n];
        inc(i);
      end;
    if i < length(Ints) then begin
      Result := i;
      SetLength(Ints, i);
      for i := 0 to i - 1 do
        Ints[i] := X[i]
    end;
  end;
end;

function packArInts(var ArInts: TArInts): integer; overload;
// remove nil from an ArInts
var
  n, i: integer;
  X: TArInts;
begin
  Result := length(ArInts);
  if Result > 0 then begin
    SetLength(X, Result);
    i := 0;
    for n := 0 to Result - 1 do
      if ArInts[n] <> nil then begin
        X[n] := ArInts[n];
        inc(i);
      end;
    if i < length(ArInts) then begin
      Result := i;
      SetLength(ArInts, i);
      for i := 0 to i - 1 do
        ArInts[i] := X[i]
    end;
  end;
end;

function packArInts0(var ArInts: TArInts): integer; overload;
// pack Ints member of an Arints, remove 0 value (result might be 0 or nil),
// then remove nil value from an ArInts, take account of pack Ints member result
var
  Changed: boolean;
  n, i, k: integer;
  X: TArInts;
  Ints: TInts;
begin
  Result := length(ArInts);
  if Result > 0 then begin
    Changed := FALSE;
    SetLength(X, Result);
    i := 0;
    for n := 0 to Result - 1 do
      if ArInts[n] <> nil then begin
        Ints := ArInts[n];
        k := packInts(Ints); // the only difference
        if (k > 0) and (k <> length(ArInts[n])) then begin
          if not Changed then
            Changed := TRUE;
          SetLength(X[n], k);
          for k := 0 to k - 1 do
            X[n, k] := Ints[k];
          inc(i);
        end;
      end;
    if Changed or (i < length(ArInts)) then begin
      Result := i;
      SetLength(ArInts, i);
      for i := 0 to i - 1 do begin
        k := length(X[i]);
        n := length(ArInts[i]);
        if n <> k then
          SetLength(ArInts[i], k);
        for k := 0 to k - 1 do begin
          n := X[i, k];
          if ArInts[i, k] <> n then
            ArInts[i, k] := n;
        end;
      end;
    end;
  end;
end;

function packArInts(var ArInts: TArInts; const Removed: integer): integer; overload;
// pack Ints member of an Arints, remove specific value (result might be 0 or nil),
// then remove nil value from an ArInts, take account of pack Ints member result
var
  Changed: boolean;
  n, i, k: integer;
  X: TArInts;
  Ints: TInts;
begin
  Result := length(ArInts);
  if Result > 0 then begin
    Changed := FALSE;
    SetLength(X, Result);
    i := 0;
    for n := 0 to Result - 1 do
      if ArInts[n] <> nil then begin
        Ints := ArInts[n];
        k := packInts(Ints, Removed); // the only difference
        if (k > 0) and (k <> length(ArInts[n])) then begin
          if not Changed then
            Changed := TRUE;
          SetLength(X[n], k);
          for k := 0 to k - 1 do
            X[n, k] := Ints[k];
          inc(i);
        end;
      end;
    if Changed or (i < length(ArInts)) then begin
      Result := i;
      SetLength(ArInts, i);
      for i := 0 to i - 1 do begin
        k := length(X[i]);
        n := length(ArInts[i]);
        if n <> k then
          SetLength(ArInts[i], k);
        for k := 0 to k - 1 do begin
          n := X[i, k];
          if ArInts[i, k] <> n then
            ArInts[i, k] := n;
        end;
      end;
    end;
  end;
end;

function packArInts(var ArInts: TArInts; const minValue, maxValue: integer): integer; overload;
// pack Ints member of an Arints, remove outrange min/max value (result might be 0 or nil),
// then remove nil value from an ArInts, take account of pack Ints member result
var
  Changed: boolean;
  n, i, k: integer;
  X: TArInts;
  Ints: TInts;
begin
  Result := length(ArInts);
  if Result > 0 then begin
    Changed := FALSE;
    SetLength(X, Result);
    i := 0;
    for n := 0 to Result - 1 do
      if ArInts[n] <> nil then begin
        Ints := ArInts[n];
        k := packInts(Ints, minValue, maxValue); // the only difference
        if (k > 0) and (k <> length(ArInts[n])) then begin
          if not Changed then
            Changed := TRUE;
          SetLength(X[n], k);
          for k := 0 to k - 1 do
            X[n, k] := Ints[k];
          inc(i);
        end;
      end;
    if Changed or (i < length(ArInts)) then begin
      Result := i;
      SetLength(ArInts, i);
      for i := 0 to i - 1 do begin
        k := length(X[i]);
        n := length(ArInts[i]);
        if n <> k then
          SetLength(ArInts[i], k);
        for k := 0 to k - 1 do begin
          n := X[i, k];
          if ArInts[i, k] <> n then
            ArInts[i, k] := n;
        end;
      end;
    end;
  end;
end;

function packArInts(var ArInts: TArInts; const Valid: TIntsMember): integer; overload;
// pack Ints member of an Arints, remove outrange min/max value (result might be 0 or nil),
// then remove nil value from an ArInts, take account of pack Ints member result
var
  Changed: boolean;
  n, i, k: integer;
  X: TArInts;
  Ints: TInts;
begin
  Result := length(ArInts);
  if Result > 0 then begin
    Changed := FALSE;
    SetLength(X, Result);
    i := 0;
    for n := 0 to Result - 1 do
      if ArInts[n] <> nil then begin
        Ints := ArInts[n];
        k := packInts(Ints, Valid); // the only difference
        if (k > 0) and (k <> length(ArInts[n])) then begin
          if not Changed then
            Changed := TRUE;
          SetLength(X[n], k);
          for k := 0 to k - 1 do
            X[n, k] := Ints[k];
          inc(i);
        end;
      end;
    if Changed or (i < length(ArInts)) then begin
      Result := i;
      SetLength(ArInts, i);
      for i := 0 to i - 1 do begin
        k := length(X[i]);
        n := length(ArInts[i]);
        if n <> k then
          SetLength(ArInts[i], k);
        for k := 0 to k - 1 do begin
          n := X[i, k];
          if ArInts[i, k] <> n then
            ArInts[i, k] := n;
        end;
      end;
    end;
  end;
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// function for test only,  DO NOT USE!
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

type
  TArIntsPackMode = (pm0, pmRemove, pmMinMax, pmMember);

function test_packArInts(var ArInts: TArInts; const mode: TArIntsPackMode;
  const Removed: integer = 0; const MinValue: integer = Low(integer); const MaxValue: integer = high(integer);
  const Valid: TIntsMember = nil): integer; overload;

var
  Ints: TInts;

  function fn_pm0: integer; begin
    Result := packInts(Ints); end;
  function fn_pmRemove: integer; begin
    Result := packInts(Ints, Removed); end;
  function fn_pmMinMax: integer; begin
    Result := packInts(Ints, minValue, maxValue); end;
  function fn_pmMember: integer; begin
    Result := packInts(Ints, Valid); end;

var
  Changed: boolean;
  n, i, k: integer;
  X: TArInts;
  fn: function: integer;

begin
  case mode of
    pm0: fn := @fn_pm0;
    pmRemove: fn := @fn_pmRemove;
    pmMinMax: fn := @fn_pmMinMax;
    pmMember: fn := @fn_pmMember;
  else
    fn := nil;
  end;

  Result := length(ArInts);
  if Result > 0 then begin
    Changed := FALSE;
    SetLength(X, Result);
    i := 0;
    for n := 0 to Result - 1 do
      if ArInts[n] <> nil then begin
        Ints := ArInts[n];
        //k := packInts(Ints); // the only difference
        //k := packInts(Ints, Removed); // the only difference
        //k := packInts(Ints, minValue, maxValue); // the only difference
        //k := packInts(Ints, Valid); // the only difference
        k := fn;
        if (k > 0) and (k <> length(ArInts[n])) then begin
          if not Changed then
            Changed := TRUE;
          SetLength(X[n], k);
          for k := 0 to k - 1 do
            X[n, k] := Ints[k];
          inc(i);
        end;
      end;
    if Changed or (i < length(ArInts)) then begin
      Result := i;
      SetLength(ArInts, i);
      for i := 0 to i - 1 do begin
        k := length(X[i]);
        n := length(ArInts[i]);
        if n <> k then
          SetLength(ArInts[i], k);
        for k := 0 to k - 1 do begin
          n := X[i, k];
          if ArInts[i, k] <> n then
            ArInts[i, k] := n;
        end;
      end;
    end;
  end;
end;

function test_packArInts0(var ArInts: TArInts): integer; overload; // remove nil from 0-packed Ints items of an ArInts
begin
  Result := test_packArInts(Arints, pm0);
end;

function test_packArInts(var ArInts: TArInts; const Removed: integer): integer; overload; // remove nil from filter-packed Ints items of an ArInts
begin
  Result := test_packArInts(Arints, pmRemove);
end;

function test_packArInts(var ArInts: TArInts; const minValue, maxValue: integer): integer; overload; // see description below
begin
  Result := test_packArInts(Arints, pmMinMax);
end;

function test_packArInts(var ArInts: TArInts; const Valid: TIntsMember): integer; overload; // see description below
begin
  Result := test_packArInts(Arints, pmMember);
end;

end.

