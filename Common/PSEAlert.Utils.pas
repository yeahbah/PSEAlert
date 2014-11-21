unit PSEAlert.Utils;

interface

uses
  SysUtils, StrUtils;

function GenerateControlName(const aSuggestedName: string): string;
function GetPollIntervalValue(const aIndex: integer): integer;

implementation

function GenerateControlName(const aSuggestedName: string): string;
begin
  result := Trim(ReplaceStr(aSuggestedName, '^', string.Empty));
  System.Delete(result, pos('-', result), 1);
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

end.
