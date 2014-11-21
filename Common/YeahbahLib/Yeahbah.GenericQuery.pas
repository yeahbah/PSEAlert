unit Yeahbah.GenericQuery;

interface

uses
  Generics.Collections, Rtti, SysUtils, TypInfo, Yeahbah.GenericQueryTypes,
  Generics.Defaults;

type
  TGroupFunc<T, K> = reference to function(p: T): K;

  /// <summary>
  /// class used for grouping lists
  /// </summary>
  TGrouping<K, T> = class(TList<T>)
  strict private
    fKey: K;
    function GetKey: K;
  public
    constructor Create(aKey: K);
    destructor Destroy; override;
    property Key: K read GetKey;
  end;

  ISomething<T: class> = interface;

  ISomething<T: class> = interface
    function Where(p: TFunc<T, Boolean>): ISomething<T>; overload;
    function Where(p: TFunc<T, Integer, Boolean>): ISomething<T>; overload;
    function First: T; overload;
    function First(p: TFunc<T, Boolean>): T; overload;
    function Single(p: TFunc<T, Boolean>): T;
    function Last: T; overload;
    function Last(p: TFunc<T, Boolean>): T; overload;
    function IndexOf(const aItem: T): Integer;
    function Select(PropName: String): TList<TValue>;
    function Take(aCount: Integer): ISomething<T>;
    function Skip(aCount: Integer): ISomething<T>;
    function Distinct: ISomething<T>;
    function Sum(PropName: String): Extended; overload;
    function Sum(p: TFunc<T, Extended>): Extended; overload;
    function Min(PropName: String): Extended;
    function Max(PropName: String): Extended;
    function Avg(PropName: String): Extended;
    function Reverse: ISomething<T>;
    function Count(p: TFunc<T, Boolean>): Integer; overload;
    function Count: Integer; overload;
    function GroupBy(p: TGroupFunc<T, IString>): TObjectList<TGrouping<IString, T>>;
    function ToList: TList<T>;
  end;

  TSomething<T: class> = class sealed(TInterfacedObject<T>, ISomething<T>)
  public
    function Where(p: TFunc<T, Boolean>): ISomething<T>; overload;
    function Where(p: TFunc<T, Integer, Boolean>): ISomething<T>; overload;
    function First: T; overload;
    function First(p: TFunc<T, Boolean>): T; overload;
    function Single(p: TFunc<T, Boolean>): T;
    function Last: T; overload;
    function Last(p: TFunc<T, Boolean>): T; overload;
    function IndexOf(const aItem: T): Integer;
    function Select(PropName: String): TList<TValue>;
    function Take(aCount: Integer): ISomething<T>;
    function Skip(aCount: Integer): ISomething<T>;
    function Distinct: ISomething<T>;
    function Sum(PropName: String): Extended; overload;
    function Sum(p: TFunc<T, Extended>): Extended; overload;
    function Min(PropName: String): Extended;
    function Max(PropName: String): Extended;
    function Avg(PropName: String): Extended;
    function Reverse: ISomething<T>;
    function Count(p: TFunc<T, Boolean>): Integer; overload;
    function Count: Integer; overload;
    function GroupBy(p: TGroupFunc<T, IString>): TObjectList<TGrouping<IString, T>>;
    function ToList: TList<T>;
  end;

  TGenericQuery<T: class> = class
    class function From(l: TEnumerable<T>): ISomething<T>;
    class procedure Foreach(l: TEnumerable<T>; aDo: TProc<T>);
  end;

  TGenericQueryFunc<T: class> = reference to function(l: TEnumerable<T>): TEnumerable<T>;

implementation

{ TSomething }

class procedure TGenericQuery<T>.Foreach(l: TEnumerable<T>; aDo: TProc<T>);
var
  item: T;
begin
  for item in l do
    aDo(item);
end;

class function TGenericQuery<T>.From(l: TEnumerable<T>): ISomething<T>;
begin
  Result := TSomething<T>.Create;
  (Result as TSomething<T>).AddRange(l.ToArray);
end;

{ TSomething<T> }

function TSomething<T>.Avg(PropName: String): Extended;
begin
  Result := Self.Sum(PropName) / Self.Count;
end;

function TSomething<T>.Count(p: TFunc<T, Boolean>): Integer;
var
  item: T;
begin
  Result := 0;
  for item in Self do
    if p(item) = true then
      Result := Result + 1;
end;

function TSomething<T>.Count: Integer;
begin
  Result := (inherited Count);
end;

function TSomething<T>.Distinct: ISomething<T>;
var
  item: T;
  processed: TList<T>;
begin
  Result := TSomething<T>.Create;
  processed := TList<T>.Create;
  try
    for item in Self do
    begin
      if processed.IndexOf(item) >= 0 then
        Continue;

      processed.Add(item);
    end;

    (Result as TSomething<T>).AddRange(processed.ToArray);
  finally
    processed.Free;
  end;
end;

function TSomething<T>.First: T;
begin
  Result := nil;
  if Self.Count > 0 then
    Result := Self[0];
end;

function TSomething<T>.First(p: TFunc<T, Boolean>): T;
var
  x: T;
begin
  Result := nil;
  for x in Self do
  begin
    if p(x) = true then
      Exit(x);
  end;

end;

function TSomething<T>.GroupBy(p: TGroupFunc<T, IString>):
  TObjectList<TGrouping<IString, T>>;
var
  item: T;
  Key: IString;
  g: TGrouping<IString, T>;
  l: TObjectList<TGrouping<IString, T>>;
  s: string;
  ItemAdded: Boolean;
  Something: ISomething<T>;
begin
  l := TObjectList<TGrouping<IString, T>>.Create;

  for item in Self do
  begin
    Key := p(item);
    ItemAdded := false;

    for g in l do
    begin
      if g.Key.Value = Key.Value then
      begin
        g.Add(item);
        ItemAdded := true;
        break;
      end;
    end;
    if not ItemAdded then
    begin
      l.Add(TGrouping<IString, T>.Create(Key));
      l.Last.Add(item);
    end;
  end;
  Result := l;
end;

function TSomething<T>.IndexOf(const aItem: T): Integer;
var
  i: Integer;
  item: T;
begin
  i := 0;
  for item in Self do
  begin
    if item = aItem then
      Result := i;
    Inc(i);
  end;
end;

function TSomething<T>.Last: T;
begin
  Result := nil;
  if Self.Count > 0 then
    Result := Self.Items[Self.Count - 1];
end;

function TSomething<T>.Last(p: TFunc<T, Boolean>): T;
begin
  Result := Self.Where(p).Last;
end;

function TSomething<T>.Max(PropName: String): Extended;
var
  l: TList<TValue>;
  d: IComparer<TValue>;
begin
  l := Self.Select(PropName);
  try
    if l.Count > 0 then
    begin
      d := TDelegatedComparer<TValue>.Create(
              function(const Left, Right: TValue): Integer
              var
                i: Extended;
              begin
                i := Left.AsExtended - Right.AsExtended;
                Result := 0;
                if i < 0 then
                  Result := -1;
                if i > 0 then
                  Result := 1;
              end
            );
      l.Sort(d);
      Result := l.Items[l.Count - 1].AsExtended;
    end;
  finally
    l.Free;
  end;
end;

function TSomething<T>.Min(PropName: String): Extended;
var
  l: TList<TValue>;
  d: IComparer<TValue>;
begin
  Result := 0;
  l := Self.Select(PropName);
  try
    if l.Count > 0 then
    begin
      d := TDelegatedComparer<TValue>.Create(
              function(const Left, Right: TValue): Integer
              var
                i: Extended;
              begin
                i := Left.AsExtended - Right.AsExtended;
                Result := 0;
                if i < 0 then
                  Result := -1;
                if i > 0 then
                  Result := 1;
              end
            );
      l.Sort(d);
      Result := l.Items[0].AsExtended;
    end;
  finally
    l.Free;
  end;
end;

function TSomething<T>.Reverse: ISomething<T>;
var
  i: Integer;
begin
  Result := TSomething<T>.Create;
  for i := Pred(Self.Count) downto 0 do
    (Result as TSomething<T>).Add(Self.Items[i]);
end;

function TSomething<T>.Select(PropName: String): TList<TValue>;
var
  ctx: TRttiContext;
  rt: TRttiType;
  x: TRttiProperty;
  item: T;
  i: Integer;
begin
  Result := TList<TValue>.Create;
  ctx := TRttiContext.Create;
  try
    for item in Self do
    begin
      rt := ctx.GetType(item.ClassType);
      x := rt.GetProperty(PropName);
      if x <> nil then
        Result.Add( x.GetValue( TObject(item) ));
    end;
  finally
    ctx.Free;
  end;

end;

function TSomething<T>.Single(p: TFunc<T, Boolean>): T;
var
  x: T;
  c: Integer;
begin
  Result := nil;
  c := 0;
  for x in Self do
  begin

    if p(x) = true then
    begin
      Result := x;
      inc(c);
    end;

    if c > 1 then
      raise Exception.Create('Single() found multiple items');

  end;

end;

function TSomething<T>.Skip(aCount: Integer): ISomething<T>;
var
  Something: TSomething<T>;
begin

  Result := TSomething<T>.Create;
  Something := Result as TSomething<T>;
  Something.AddRange(Self.ToArray);

  Result := Something.Reverse.Take(Self.Count - aCount).Reverse;

end;

function TSomething<T>.Sum(p: TFunc<T, Extended>): Extended;
var
  item: T;
begin
  Result := 0;
  for item in Self do
    Result := Result + p(item);
end;

function TSomething<T>.Sum(PropName: String): Extended;
var
  l: TList<TValue>;
  item: TValue;
begin
  Result := 0;
  l := Self.Select(PropName);
  try
    for item in l do
      Result := Result + item.AsExtended;
  finally
    if l <> nil then
      l.Free;
  end;
end;

function TSomething<T>.Take(aCount: Integer): ISomething<T>;
var
  Something: TSomething<T>;
begin
  Result := TSomething<T>.Create;
  Something := Result as TSomething<T>;
  Something.AddRange(Self.ToArray);
  Something.Capacity := aCount;
  Something.TrimExcess;

end;

function TSomething<T>.ToList: TList<T>;
var
  item: T;
begin
  Result := TList<T>.Create;
  for item in Self do
  begin
    Result.Add(item);
  end;
end;

function TSomething<T>.Where(p: TFunc<T, Integer, Boolean>): ISomething<T>;
var
  x: T;
  i: Integer;
begin
  Result := TSomething<T>.Create;
  i := 0;
  for x in Self do
  begin
    if p(x, i) = true then
      (Result as TSomething<T>).Add(x);
    Inc(i);
  end;
end;

function TSomething<T>.Where(p: TFunc<T, Boolean>): ISomething<T>;
var
  x: T;
begin
  Result := TSomething<T>.Create;
  for x in Self do
    if p(x) = true then
      (Result as TSomething<T>).Add(x);
end;

{ TGrouping<K, T> }

constructor TGrouping<K, T>.Create(aKey: K);
begin
  fKey := aKey;
end;

destructor TGrouping<K, T>.Destroy;
begin

  inherited;
end;

function TGrouping<K, T>.GetKey: K;
begin
  Result := fKey;
end;

end.

