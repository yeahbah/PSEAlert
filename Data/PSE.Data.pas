unit PSE.Data;

interface

uses
  System.SysUtils, PSE.Data.Model, Generics.Collections, System.JSON,
  System.Classes, Yeahbah.GenericQuery,
  SQLiteTable3,
  Spring.Persistence.Core.Interfaces,
  Spring.Persistence.Core.Session,
  Spring.Persistence.Mapping.Attributes,
  PSE.Data.Model.JSON;


type


  TPSEHeaderData = class
  private
    fStockHeaderModel: TStockHeaderModel;
    fRecordCount: integer;
  protected
    procedure Deserialize(const aJSONText: string);
  public
    function UpdateStockHeaderObject(const aSymbol: string; aStockHeaderModel: TStockHeaderModel): boolean;
  end;

  TModelConverter = class
  public
    class procedure ConvertModel(const aSource: TJSONIntradayModel;
      const aTarget: TStockModel); overload;
    class procedure ConvertModel(const aSource: TJSONStockHeaderModel;
      const aTarget: TStockHeaderModel); overload;
    class procedure ConvertModel(const aSource: TJSONStockModel;
      const aTarget: TStockModel); overload;
  end;

  TPSEAlertDatabase = class
  private
    fConnection: IDBConnection;
    fDatabase: TSQLiteDatabase;
    fSession: TSession;
  public
    constructor Create;
    destructor Destroy; override;
    property Database: TSQLiteDatabase read fDatabase write fDatabase;
    property Connection: IDBConnection read fConnection write fConnection;
    property Session: TSession read fSession write fSession;
  end;

var
  PSEAlertDb: TPSEAlertDatabase;

implementation

uses
  SvHTTPClient.Indy,
  Spring.Persistence.Core.DatabaseManager,
  Spring.Persistence.Core.ConnectionFactory,
  Spring.Persistence.Adapters.SQLite;

//function getStockId(const aSymbol: string): integer;
//var
//  v: Variant;
//begin
//  v := PSEStocksData.PSEStocksConnection.ExecSQLScalar('SELECT ID FROM STOCKID_MAP WHERE SYMBOL = ' + QuotedStr(aSymbol));
//  if v.IsNull then
//    raise Exception.Create('Unable to find stock id of ' + aSymbol +'. Try updating your database. Settings > Reload Stock List');
//
//  result := v
//end;

{ TModelConverter }

class procedure TModelConverter.ConvertModel(const aSource: TJSONIntradayModel;
  const aTarget: TStockModel);
begin
  aTarget.Symbol := aSource.securitySymbol;
  aTarget.Description := aSource.securityAlias;
  aTarget.LastTradedPrice := StrToFloat(
    StringReplace(aSource.lastTradedPrice, ',', EmptyStr, [rfReplaceAll]));

  aTarget.Volume := StrToFloat(
    StringReplace(aSource.totalVolume, ',', EmptyStr, [rfReplaceAll]));

  aTarget.PercentChange := StrToFloat(
    StringReplace(aSource.percChangeClose, ',', EmptyStr, [rfReplaceAll]));

  if aSource.indicator = 'U' then
    aTarget.Status := TStockStatus.Up
  else
  if aSource.indicator = 'D' then
    aTarget.Status := TStockStatus.Down
  else
  if aSource.indicator = 'N' then
    aTarget.Status := TStockStatus.Unchanged;
end;

class procedure TModelConverter.ConvertModel(
  const aSource: TJSONStockHeaderModel; const aTarget: TStockHeaderModel);
var
  f: TFormatSettings;
begin
  aTarget.Symbol := aSource.securitySymbol;
  aTarget.IntradayLow := StrToFloat(aSource.headerSqLow);
  aTarget.IntradayHigh := StrToFloat(aSource.headerSqHigh);
  aTarget.IntradayOpen := StrToFloat(aSource.headerSqOpen);
  aTarget.PreviousClose := StrToFloat(aSource.headerSqPrevious);
  aTarget.FiftyTwoWeekHigh := StrToFloat(aSource.headerFiftyTwoWeekHigh);
  aTarget.FiftyTwoWeekLow := StrToFloat(aSource.headerFiftyTwoWeekLow);
  aTarget.ChangeClose := StrToFloat(aSource.headerChangeClose);
  aTarget.ChangeClosePercentage := StrToFloat(aSource.headerPercChangeClose);
  aTarget.LastTradedPrice := StrToFloat(aSource.headerLastTradePrice);
  aTarget.TotalValue := StrToInt64(aSource.headerTotalValue);
  aTarget.TotalVolume := StrToInt64(aSource.headerTotalVolume);
  aTarget.AvgPrice := StrToFloat(aSource.headerAvgPrice);
  aTarget.CurrentPE := StrToFloat(aSource.headerCurrentPe);

  f := TFormatSettings.Create;
  f.DateSeparator := '-';
  f.ShortDateFormat := 'yyyy-mm-dd';
  aTarget.LastTradedDate := StrToDate(aSource.lastTradedDate, f);
end;

class procedure TModelConverter.ConvertModel(const aSource: TJSONStockModel;
  const aTarget: TStockModel);
begin

end;

{ TPSEHeaderData }

procedure TPSEHeaderData.Deserialize(const aJSONText: string);
var
  jsonStockHeader: TJSONStockHeaderModel;
  jsonArray: TJSONArray;
  jsonValue: TJSONValue;
  jsonObject: TJSONObject;
begin

  jsonValue := TJSONObject.ParseJSONValue(aJSONText);

  fRecordCount := StrToInt((jsonValue as TJSONObject).Get('count').JsonValue.Value);
  if fRecordCount = 0 then
    Exit;

  jsonArray := (jsonValue as TJSONObject).Get('records').JsonValue as TJSONArray;

  jsonStockHeader := TJSONStockHeaderModel.Create;
  try
    jsonObject := jsonArray.Items[0] as TJSONObject;
    jsonStockHeader.headerSqLow := jsonObject.Get('headerSqLow').JsonValue.Value;
    jsonStockHeader.headerFiftyTwoWeekHigh := jsonObject.Get('headerFiftyTwoWeekHigh').JsonValue.Value;
    jsonStockHeader.headerChangeClose := jsonObject.Get('headerChangeClose').JsonValue.Value;
    jsonStockHeader.lastTradedDate := jsonObject.Get('lastTradedDate').JsonValue.Value;
    jsonStockHeader.headerTotalValue := jsonObject.Get('headerTotalValue').JsonValue.Value;
    jsonStockHeader.headerLastTradePrice := jsonObject.Get('headerLastTradePrice').JsonValue.Value;
    jsonStockHeader.headerSqHigh := jsonObject.Get('headerSqHigh').JsonValue.Value;;
    jsonStockHeader.headerPercChangeClose := jsonObject.Get('headerPercChangeClose').JsonValue.Value;;
    jsonStockHeader.headerFiftyTwoWeekLow := jsonObject.Get('headerFiftyTwoWeekLow').JsonValue.Value;;
    jsonStockHeader.headerSqPrevious := jsonObject.Get('headerSqPrevious').JsonValue.Value;;
    jsonStockHeader.securitySymbol := jsonObject.Get('securitySymbol').JsonValue.Value;;
    jsonStockHeader.headerCurrentPe := jsonObject.Get('headerCurrentPe').JsonValue.Value;;
    jsonStockHeader.headerSqOpen := jsonObject.Get('headerSqOpen').JsonValue.Value;;
    jsonStockHeader.headerAvgPrice := jsonObject.Get('headerAvgPrice').JsonValue.Value;;
    jsonStockHeader.headerTotalVolume := jsonObject.Get('headerTotalVolume').JsonValue.Value;;

    TModelConverter.ConvertModel(jsonStockHeader, fStockHeaderModel);

  finally
    jsonStockHeader.Free;
  end;


end;

function TPSEHeaderData.UpdateStockHeaderObject(const aSymbol: string; aStockHeaderModel: TStockHeaderModel): boolean;
//var
//  httpGet: TIndyHTTPClient;
//  url: string;
//  stream: TStringStream;
begin
//  fStockHeaderModel := aStockHeaderModel;
//  httpGet := TIndyHTTPClient.Create;
//  try
//    stream := TStringStream.Create;
//    try
//      url := 'http://http://pse.com.ph/stockMarket/companyInfo.html?method=fetchHeaderData&ajax=true&security=' + getStockId(aSymbol).ToString;
//      httpGet.Get(url, stream);
//      Deserialize(stream.DataString);
//      result := fRecordCount > 0;
//    finally
//      stream.Free;
//    end;
//  finally
//    httpGet.Free;
//  end;
  result := false;
end;

{ TPSEAlertDatabase }

constructor TPSEAlertDatabase.Create;
begin
  fDatabase := TSQLiteDatabase.Create;
  fDatabase.Filename := 'psestocks.s3db';
  fConnection := TSQLiteConnectionAdapter.Create(fDatabase);
  fConnection.AutoFreeConnection := true;
  fConnection.Connect;

  fSession := TSession.Create(fConnection);
end;

destructor TPSEAlertDatabase.Destroy;
begin
  fSession.Free;
  inherited;
end;

initialization
  PSEAlertDb := TPSEAlertDatabase.Create;

finalization
  PSEAlertDb.Free;

end.
