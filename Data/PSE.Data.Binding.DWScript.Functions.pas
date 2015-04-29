unit PSE.Data.Binding.DWScript.Functions;

interface

uses
  dwsMagicExprs,
  dwsExprList,
  dwsStrings,
  dwsFunctions,
  SysUtils;

type
  TFormatFloatFunc = class(TInternalMagicStringFunction)
    procedure DoEvalAsString(const args : TExprBaseListExec; var Result : UnicodeString); override;
  end;

implementation

{ TFormatFloatFunc }

procedure TFormatFloatFunc.DoEvalAsString(const args: TExprBaseListExec;
  var Result: UnicodeString);
begin
  Result := FormatFloat(args.AsString[0], StrToFloat(args.AsString[1]));
end;

initialization
   RegisterInternalStringFunction(TFormatFloatFunc, 'FormatFloat',
    ['fmt', SYS_STRING, 'value', SYS_FLOAT], [iffStateLess], 'FormatFloat');

end.
