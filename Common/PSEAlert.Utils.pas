unit PSEAlert.Utils;

interface

uses
  SysUtils, StrUtils;

function GenerateControlName(const aSuggestedName: string): string;
function GetPollIntervalValue(const aIndex: integer): integer;
function ConvertStringDateToSystem(const aDate: string): TDateTime;
function ExtractStockSymbol(const aValue: string): string;

implementation

var
  internalCounter: integer = 1;

function ExtractStockSymbol(const aValue: string): string;
var
  splitResult: TArray<string>;
begin
  splitResult := aValue.Split(['_']);
  if Length(splitResult) > 1 then
    result := splitResult[1]
  else
    result := aValue;

  System.Delete(result, pos('-', result), 1);
end;

function GenerateControlName(const aSuggestedName: string): string;
begin
  result := Trim(ReplaceStr(aSuggestedName, '^', string.Empty));
  System.Delete(result, pos('-', result), 1);
  inc(internalCounter);
  result := 'stock'+internalCounter.ToString+'_' + result;
end;

function GetPollIntervalValue(const aIndex: integer): integer;
var
  OneMinute: integer;
begin
  OneMinute := 1000 * 60;
  result := 0;

  case aIndex of
    1: result := 10000;
    2: result := 30000;
    3: result := OneMinute;
    4: result := OneMinute * 5;
    5: result := OneMinute * 10;
    6: result := OneMinute * 15;
    7: result := OneMinute * 20;
    8: result := OneMinute * 25;
  end;
end;

function ConvertStringDateToSystem(const aDate: string): TDateTime;
var
  f: TFormatSettings;
begin
  f := TFormatSettings.Create;
  f.DateSeparator := '-';
  f.ShortDateFormat := 'yyyy-mm-dd';
  result := StrToDateTime(aDate, f);
end;

end.
