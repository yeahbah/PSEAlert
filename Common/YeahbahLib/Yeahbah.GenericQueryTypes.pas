unit Yeahbah.GenericQueryTypes;

interface

uses
  Generics.Collections, SysUtils;

type
  /// <summary>
  /// record version of a string type
  /// that stores a single string value.
  /// this record is compatible with a native string value
  /// </summary>
  TStringRec = record
  strict private
    Value: String;
  public
    class operator Add(a, b: TStringRec): TStringRec;
    class operator Implicit(s: String): TStringRec;
    class operator Implicit(s: TStringRec): String;
    class operator Explicit(s: String): TStringRec;
    class operator Equal(a, b: TStringRec): Boolean;
  end;

  IString = interface
    function GetValue: TStringRec;
    procedure SetValue(const v: TStringRec);
    property Value: TStringRec read GetValue write SetValue;
  end;

  /// <summary>
  /// class version of a string stype
  /// </summary>
  TString = class(TInterfacedObject, IString)
  strict private
    fValue: TStringRec;
    function GetValue: TStringRec;
    procedure SetValue(const v: TStringRec);
  public
    constructor Create(aValue: TStringRec);
    destructor Destroy; override;
    property Value: TStringRec read GetValue;
  end;

  /// <summary>
  /// generic version of a TInterfacedObject
  /// </summary>
  TInterfacedObject<T> = class(TList<T>, IInterface)
  protected
{$IFNDEF AUTOREFCOUNT}
    [Volatile] FRefCount: Integer;
{$ENDIF}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
{$IFNDEF AUTOREFCOUNT}
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    class function NewInstance: TObject; override;
    property RefCount: Integer read FRefCount;
{$ENDIF}
  end;

implementation

{ TString }

constructor TString.Create(aValue: TStringRec);
begin
  fValue := aValue;
end;

destructor TString.Destroy;
begin

  inherited;
end;

function TString.GetValue: TStringRec;
begin
  Result := fValue;
end;

procedure TString.SetValue(const v: TStringRec);
begin
  fValue := v;
end;

{ TStringRec }

class operator TStringRec.Add(a, b: TStringRec): TStringRec;
begin
  Result := a.Value + a.Value;
end;

class operator TStringRec.Equal(a, b: TStringRec): Boolean;
begin
  Result := a.Value = b.Value;
end;

class operator TStringRec.Explicit(s: String): TStringRec;
begin
  Result.Value := s;
end;

class operator TStringRec.Implicit(s: TStringRec): String;
begin
  Result := s.Value;
end;

class operator TStringRec.Implicit(s: String): TStringRec;
begin
  Result.Value := s;
end;

{ TInterfacedObject<T> }

procedure TInterfacedObject<T>.AfterConstruction;
begin
  AtomicDecrement(FRefCount);

end;

procedure TInterfacedObject<T>.BeforeDestruction;
begin
  if RefCount <> 0 then
    raise Exception.Create('RefCount Error');
end;

class function TInterfacedObject<T>.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TInterfacedObject<T>(Result).FRefCount := 1;
end;

function TInterfacedObject<T>.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TInterfacedObject<T>._AddRef: Integer;
begin
  Result := AtomicIncrement(FRefCount);
end;

function TInterfacedObject<T>._Release: Integer;
begin
  Result := AtomicDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

end.
