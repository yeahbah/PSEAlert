unit PSE.Data;

interface

uses
  System.SysUtils, PSE.Data.Model, Generics.Collections, System.JSON,
  System.Classes, Yeahbah.GenericQuery,
  SQLiteTable3,
  Spring.Persistence.Core.Interfaces,
  Spring.Persistence.Core.Session,
  Spring.Persistence.Mapping.Attributes;


type
  TPSEIntradayData = class(TObjectList<TStockModel>)
  protected
    procedure Deserialize(const aJSONText: string);
  public
    function Update: boolean;

  end;

  TPSEHeaderData = class
  private
    fStockHeaderModel: TStockHeaderModel;
    fRecordCount: integer;
  protected
    procedure Deserialize(const aJSONText: string);
  public
    function UpdateStockHeaderObject(const aSymbol: string; aStockHeaderModel: TStockHeaderModel): boolean;
  end;

  TJSONStockModel = class
  private
    ftotalVolume: string;
    fsecurityAlias: string;
    fpercChangeClose: string;
    flastTradedPrice: string;
    fsecuritySymbol: string;
    findicator: string;
  public
    property securitySymbol: string read fsecuritySymbol write fsecuritySymbol;
    property securityAlias: string read fsecurityAlias write fsecurityAlias;
    property lastTradedPrice: string read flastTradedPrice write flastTradedPrice;
    property percChangeClose: string read fpercChangeClose write fpercChangeClose;
    property totalVolume: string read ftotalVolume write ftotalVolume;
    property indicator: string read findicator write findicator;
  end;

  TJSONStockHeaderModel = class
  private
    FheaderSqLow: string;
    FheaderAvgPrice: string;
    FheaderSqOpen: string;
    FheaderFiftyTwoWeekLow: string;
    FlastTradedDate: string;
    FheaderSqHigh: string;
    FheaderTotalVolume: string;
    FheaderTotalValue: string;
    FheaderLastTradePrice: string;
    FheaderSqPrevious: string;
    FheaderChangeClose: string;
    FheaderCurrentPe: string;
    FsecuritySymbol: string;
    FheaderFiftyTwoWeekHigh: string;
    FheaderPercChangeClose: string;
    FheaderChangeClosePercChangeClose: string;
    procedure SetheaderSqLow(const Value: string);
    procedure SetheaderAvgPrice(const Value: string);
    procedure SetheaderChangeClose(const Value: string);
    procedure SetheaderChangeClosePercChangeClose(const Value: string);
    procedure SetheaderCurrentPe(const Value: string);
    procedure SetheaderFiftyTwoWeekHigh(const Value: string);
    procedure SetheaderFiftyTwoWeekLow(const Value: string);
    procedure SetheaderLastTradePrice(const Value: string);
    procedure SetheaderPercChangeClose(const Value: string);
    procedure SetheaderSqHigh(const Value: string);
    procedure SetheaderSqOpen(const Value: string);
    procedure SetheaderSqPrevious(const Value: string);
    procedure SetheaderTotalValue(const Value: string);
    procedure SetheaderTotalVolume(const Value: string);
    procedure SetlastTradedDate(const Value: string);
    procedure SetsecuritySymbol(const Value: string);
  public
    property headerSqLow: string read FheaderSqLow write SetheaderSqLow;
    property headerFiftyTwoWeekHigh: string read FheaderFiftyTwoWeekHigh write SetheaderFiftyTwoWeekHigh;
    property headerChangeClose: string read FheaderChangeClose write SetheaderChangeClose;
    property headerChangeClosePercChangeClose: string read FheaderChangeClosePercChangeClose write SetheaderChangeClosePercChangeClose;
    property lastTradedDate: string read FlastTradedDate write SetlastTradedDate;
    property headerTotalValue: string read FheaderTotalValue write SetheaderTotalValue;
    property headerLastTradePrice: string read FheaderLastTradePrice write SetheaderLastTradePrice;
    property headerSqHigh: string read FheaderSqHigh write SetheaderSqHigh;
    property headerPercChangeClose: string read FheaderPercChangeClose write SetheaderPercChangeClose;
    property headerFiftyTwoWeekLow: string read FheaderFiftyTwoWeekLow write SetheaderFiftyTwoWeekLow;
    property headerSqPrevious: string read FheaderSqPrevious write SetheaderSqPrevious;
    property securitySymbol: string read FsecuritySymbol write SetsecuritySymbol;
    property headerCurrentPe: string read FheaderCurrentPe write SetheaderCurrentPe;
    property headerSqOpen: string read FheaderSqOpen write SetheaderSqOpen;
    property headerAvgPrice: string read FheaderAvgPrice write SetheaderAvgPrice;
    property headerTotalVolume: string read FheaderTotalVolume write SetheaderTotalVolume;
  end;

  TJSONPseHeaderModel = class
  private
    fCount: integer;
    fRecords: TObjectList<TJSONStockHeaderModel>;
  public
    property Count: integer read fCount write fCount;
    property Records: TObjectList<TJSONStockHeaderModel> read fRecords write fRecords;
  end;


  TModelConverter = class
  public
    class procedure ConvertModel(const aSource: TJSONStockModel;
      const aTarget: TStockModel); overload;
    class procedure ConvertModel(const aSource: TJSONStockHeaderModel;
      const aTarget: TStockHeaderModel); overload;
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

{ TPSEJsonDeserializer }

procedure TPSEIntradayData.Deserialize(const aJSONText: string);
var
  jsonStock: TJSONStockModel;
  stockModel: TStockModel;

  jsonArray: TJSONArray;
  jsonValue: TJSONValue;
  jsonObject: TJSONObject;

  i: Integer;
  lastUpdate: TDateTime;
begin
  Self.Clear;
  lastUpdate := Now;

  jsonValue := TJSONObject.ParseJSONValue(aJSONText);
  Assert(jsonValue is TJSONArray);

  jsonArray := jsonValue as TJSONArray;

  for i := 0 to jsonArray.Count - 1  do
  begin
    jsonStock := TJSONStockModel.Create;
    try
      jsonObject := jsonArray.Items[i] as TJSONObject;
      jsonStock.securitySymbol := jsonObject.Get('securitySymbol').JsonValue.Value;
      jsonStock.securityAlias := jsonObject.Get('securityAlias').JsonValue.Value;
      jsonStock.lastTradedPrice := jsonObject.Get('lastTradedPrice').JsonValue.Value;
      jsonStock.percChangeClose := jsonObject.Get('percChangeClose').JsonValue.Value;
      jsonStock.totalVolume := jsonObject.Get('totalVolume').JsonValue.Value;
      jsonStock.indicator := jsonObject.Get('indicator').JsonValue.Value;
      if i = 0 then
      begin
        // first element of the array has the last update date time
        lastUpdate := StrToDateTime(jsonStock.securityAlias);
        Continue;
      end;

      stockModel := TStockModel.Create;
      TModelConverter.ConvertModel(jsonStock, stockModel);

      stockModel.LastUpdateDateTime := lastUpdate;
      Self.Add(stockModel);
    finally
      jsonStock.Free;
    end;
  end;
end;

function TPSEIntradayData.Update: boolean;
var
  httpGet: TIndyHTTPClient;
  url: string;
  stream: TStringStream;
begin
  httpGet := TIndyHTTPClient.Create;
  try
    stream := TStringStream.Create;
    try
      url := 'http://pse.com.ph/stockMarket/home.html?method=getSecuritiesAndIndicesForPublic&ajax=true';
      httpGet.Get(url, stream);
      Deserialize(stream.DataString);
    finally
      stream.Free;
    end;
  finally
    httpGet.Free;
  end;
  result := true;
end;

{ TModelConverter }

class procedure TModelConverter.ConvertModel(const aSource: TJSONStockModel;
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
end;

{ TJSONStockHeaderModel }

procedure TJSONStockHeaderModel.SetheaderAvgPrice(const Value: string);
begin
  FheaderAvgPrice := Value;
end;

procedure TJSONStockHeaderModel.SetheaderChangeClose(const Value: string);
begin
  FheaderChangeClose := Value;
end;

procedure TJSONStockHeaderModel.SetheaderChangeClosePercChangeClose(
  const Value: string);
begin
  FheaderChangeClosePercChangeClose := Value;
end;

procedure TJSONStockHeaderModel.SetheaderCurrentPe(const Value: string);
begin
  FheaderCurrentPe := Value;
end;

procedure TJSONStockHeaderModel.SetheaderFiftyTwoWeekHigh(const Value: string);
begin
  FheaderFiftyTwoWeekHigh := Value;
end;

procedure TJSONStockHeaderModel.SetheaderFiftyTwoWeekLow(const Value: string);
begin
  FheaderFiftyTwoWeekLow := Value;
end;

procedure TJSONStockHeaderModel.SetheaderLastTradePrice(const Value: string);
begin
  FheaderLastTradePrice := Value;
end;

procedure TJSONStockHeaderModel.SetheaderPercChangeClose(const Value: string);
begin
  FheaderPercChangeClose := Value;
end;

procedure TJSONStockHeaderModel.SetheaderSqHigh(const Value: string);
begin
  FheaderSqHigh := Value;
end;

procedure TJSONStockHeaderModel.SetheaderSqLow(const Value: string);
begin
  FheaderSqLow := Value;
end;

procedure TJSONStockHeaderModel.SetheaderSqOpen(const Value: string);
begin
  FheaderSqOpen := Value;
end;

procedure TJSONStockHeaderModel.SetheaderSqPrevious(const Value: string);
begin
  FheaderSqPrevious := Value;
end;

procedure TJSONStockHeaderModel.SetheaderTotalValue(const Value: string);
begin
  FheaderTotalValue := Value;
end;

procedure TJSONStockHeaderModel.SetheaderTotalVolume(const Value: string);
begin
  FheaderTotalVolume := Value;
end;

procedure TJSONStockHeaderModel.SetlastTradedDate(const Value: string);
begin
  FlastTradedDate := Value;
end;

procedure TJSONStockHeaderModel.SetsecuritySymbol(const Value: string);
begin
  FsecuritySymbol := Value;
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
