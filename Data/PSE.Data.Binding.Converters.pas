unit PSE.Data.Binding.Converters;

interface

uses
  DSharp.Core.DataConversion,
  SysUtils,
  SvBindings;

type
  TIntegerConverter = class(TValueConverter)
  public
    function Convert(const Value: TValue): TValue; override;
    function ConvertBack(const Value: TValue): TValue; override;
  end;

implementation

procedure RegisterConverters;
begin
//    TDataBindManager.RegisterConverter(bctIntegerToString,
//    function(AAtribute: BindAttribute; ASource, ATarget: TObject): IValueConverter
//    begin
//      Result := TIntegerConverter.Create;
//    end );
end;

{ TIntegerConverter }

function TIntegerConverter.Convert(const Value: TValue): TValue;
var
  singleValue: real;
begin
  if Value.TryAsType<real>(singleValue) then
  begin
    result := FormatFloat('#,##0.00', singleValue);
  end;
end;

function TIntegerConverter.ConvertBack(const Value: TValue): TValue;
begin

end;

initialization
//  RegisterConverters;

end.
