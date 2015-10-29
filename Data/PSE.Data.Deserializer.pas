unit PSE.Data.Deserializer;

interface

uses
  Generics.Collections;

type
  TDeserializer = class
  public
    procedure Deserialize(const aJSONText: string;
      const aObjects: TObjectList<TObject>); virtual; abstract;
  end;

  TDeserializerFactory = class
  public
    class function GetDeserializer(const aClass: TClass): TDeserializer;
  end;


implementation

uses
  PSE.Data.Model,
  PSE.Data.Model.JSON,
  System.JSON,
  SysUtils, PSEAlert.Utils,
  SvSerializer,
  Generics.Defaults,
  JclStrings;

type
  TModelConverter = class
  public
    class procedure ConvertModel(const aSource: TJSONIntradayModel;
      const aTarget: TIntradayModel); overload;
    class procedure ConvertModel(const aSource: TJSONStockHeaderModel;
      const aTarget: TStockHeaderModel); overload;
    class procedure ConvertModel(const aSource: TJSONStockModel;
      const aTarget: TStockModel); overload;
    class procedure ConvertModel(const aSource: TJSONIndexModel;
      const aTarget: TIndexModel); overload;
  end;

  // intraday data
  TPSEIntradayDeserializer = class sealed(TDeserializer)
  public
    procedure Deserialize(const aJSONText: string;
      const aObjects: TObjectList<TObject>); override;
  end;

  // stock information
  TPSEStockDataDeserializer = class sealed(TDeserializer)
  public
    procedure Deserialize(const aJSONText: string;
      const aObjects: TObjectList<TObject>); override;
  end;

  // market indeces
  TPSEIndexDataDeserializer = class sealed(TDeserializer)
  public
    procedure Deserialize(const aJSONText: string;
      const aObjects: TObjectList<TObject>); override;
  end;

  // most active / top gainers / top losers
  TPSEDailySummaryDeserializer = class sealed(TDeserializer)
  public
    procedure Deserialize(const aJSONText: string;
      const aObjects: TObjectList<TObject>); override;
  end;

  TPSEHeaderDataDeserializer = class sealed(TDeserializer)
  public
    procedure Deserialize(const aJSONText: string;
      const aObjects: TObjectList<TObject>); override;
  end;

{ TPSEIntradayDeserializer }

procedure TPSEIntradayDeserializer.Deserialize(const aJSONText: string;
  const aObjects: TObjectList<TObject>);
var
  jsonStock: TJSONIntradayModel;
  intradayData: TIntradayModel;

  jsonArray: TJSONArray;
  jsonValue: TJSONValue;
  jsonObject: TJSONObject;

  i: Integer;
  lastUpdate: TDateTime;
  formatSettings: TFormatSettings;
begin
  aObjects.Clear;
  lastUpdate := Now;

  jsonValue := TJSONObject.ParseJSONValue(aJSONText);
  Assert(jsonValue is TJSONArray);

  jsonArray := jsonValue as TJSONArray;

  for i := 0 to jsonArray.Count - 1  do
  begin
    jsonStock := TJSONIntradayModel.Create;
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
        formatSettings := TFormatSettings.Create('en-PH');
        formatSettings.ShortDateFormat := 'm/dd/yyyy';
        lastUpdate := StrToDateTime(jsonStock.securityAlias.Trim, formatSettings);
        Continue;
      end;

      intradayData := TIntradayModel.Create;
      TModelConverter.ConvertModel(jsonStock, intradayData);

      intradayData.LastUpdateDateTime := lastUpdate;
      aObjects.Add(intradayData);
    finally
      jsonStock.Free;
    end;
  end;

end;

{ TModelConverter }

class procedure TModelConverter.ConvertModel(const aSource: TJSONIntradayModel;
  const aTarget: TIntradayModel);
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
begin
  aTarget.Symbol := aSource.securitySymbol;
  aTarget.IntradayLow := aSource.headerSqLow;
  aTarget.IntradayHigh := aSource.headerSqHigh;
  aTarget.IntradayOpen := aSource.headerSqOpen;
  aTarget.PreviousClose := aSource.headerSqPrevious;
  aTarget.FiftyTwoWeekHigh := aSource.headerFiftyTwoWeekHigh;
  aTarget.FiftyTwoWeekLow := aSource.headerFiftyTwoWeekLow;
  aTarget.ChangeClose := aSource.headerChangeClose;
  aTarget.ChangeClosePercentage := aSource.headerPercChangeClose;
  aTarget.LastTradedPrice := aSource.headerLastTradePrice;
  aTarget.TotalValue := Trunc(StrRemoveChars(aSource.headerTotalValue, [',']).ToSingle);
  aTarget.TotalVolume := Trunc(StrRemoveChars(aSource.headerTotalVolume, [',']).ToSingle);
  aTarget.AvgPrice := aSource.headerAvgPrice;
  aTarget.CurrentPE := aSource.headerCurrentPe;

  aTarget.LastTradedDate := ConvertStringDateToSystem(aSource.lastTradedDate);
end;

class procedure TModelConverter.ConvertModel(const aSource: TJSONStockModel;
  const aTarget: TStockModel);
begin
  aTarget.Symbol := aSource.securitySymbol;
  aTarget.Description := aSource.securityName;
  aTarget.SecurityId := aSource.securityID;
  aTarget.CompanyId := aSource.companyId;
  aTarget.LastTradedPrice := aSource.lastTradePrice;
  if aSource.lastTradeDate.Trim <> '' then
    aTarget.LastTradedDate := ConvertStringDateToSystem(aSource.lastTradeDate);
  aTarget.MarketCapitalization := aSource.marketCapitilization;
  aTarget.FreeFloatLevel := aSource.freeFloatLevel;
  aTarget.OutstandingShares := aSource.outstandingShares;
end;

class procedure TModelConverter.ConvertModel(const aSource: TJSONIndexModel;
  const aTarget: TIndexModel);
begin
  aTarget.Id := aSource.indexId;
  aTarget.IndexSymbol := aSource.indexAbb;
  aTarget.IndexName := aSource.indexName;
  aTarget.IsSector := aSource.isSectoral;
  aTarget.SortOrder := aSource.sortOrder;
  if aTarget.IndexSymbol = 'PSE' then
    aTarget.AltIndexSymbol := '^PSEi'
  else
  if aTarget.IndexSymbol = 'ALL' then
    aTarget.AltIndexSymbol := '^ALLSHARES'
  else
  if aTarget.IndexSymbol = 'FIN' then
    aTarget.AltIndexSymbol := '^FINANCIAL'
  else
  if aTarget.IndexSymbol = 'IND' then
    aTarget.AltIndexSymbol := '^INDUSTRIAL'
  else
  if aTarget.IndexSymbol = 'HDG' then
    aTarget.AltIndexSymbol := '^HOLDING'
  else
  if aTarget.IndexSymbol = 'PRO' then
    aTarget.AltIndexSymbol := '^PROPERTY'
  else
  if aTarget.IndexSymbol = 'SVC' then
    aTarget.AltIndexSymbol := '^SERVICE'
  else
  if aTarget.IndexSymbol = 'M-O' then
    aTarget.AltIndexSymbol := '^MINING-OIL';

end;

{ TPSEStockDataDeserializer }

procedure TPSEStockDataDeserializer.Deserialize(const aJSONText: string;
  const aObjects: TObjectList<TObject>);
var
  jsonStock: TJSONStockModel;
  stockData: TStockModel;

  jsonArray: TJSONArray;
  jsonValue: TJSONValue;

  i: Integer;
begin
  aObjects.Clear;

  jsonValue := TJSONObject.ParseJSONValue(aJSONText);
  if jsonValue is TJSONObject then
  begin
    i := 0;
    if TryStrToInt(TJSONObject(jsonValue).Get('count').JsonValue.Value, i) then
      if i = 0 then
        exit;
  end;

  jsonValue := TJSONObject.ParseJSONValue(
    TJSONObject(jsonValue).Get('records').JsonValue.ToString);
  Assert(jsonValue is TJSONArray);

  jsonArray := jsonValue as TJSONArray;

  for i := 0 to jsonArray.Count - 1  do
  begin
    jsonStock := TJSONStockModel.Create;
    try
      TSvSerializer.DeSerializeObject(jsonStock, jsonArray.Items[i].ToJSON, sstSuperJson);
      stockData := TStockModel.Create;
      TModelConverter.ConvertModel(jsonStock, stockData);
      aObjects.Add(stockData);
    finally
      jsonStock.Free;
    end;
  end;

end;


{ TDeserializerFactory }

class function TDeserializerFactory.GetDeserializer(
  const aClass: TClass): TDeserializer;
begin
  if aClass = TIntradayModel then
    result := TPSEIntradayDeserializer.Create
  else
  if aClass = TStockModel then
    result := TPSEStockDataDeserializer.Create
  else
  if aClass = TIndexModel then
    result := TPSEIndexDataDeserializer.Create
  else
  if aClass = TJSONDailySummaryModel then
    result := TPSEDailySummaryDeserializer.Create
  else
  if aClass = TStockHeaderModel then
    result := TPSEHeaderDataDeserializer.Create
  else
    raise Exception.Create('Unsupported type for deserialization');
end;

{ TPSEIndexDataDeserializer }

procedure TPSEIndexDataDeserializer.Deserialize(const aJSONText: string;
  const aObjects: TObjectList<TObject>);
var
  jsonIndexModel: TJSONIndexModel;
  indexData: TIndexModel;

  jsonArray: TJSONArray;
  jsonValue: TJSONValue;

  i: Integer;
begin
  jsonValue := TJSONObject.ParseJSONValue(aJSONText);
  if jsonValue is TJSONObject then
  begin
    i := 0;
    if TryStrToInt(TJSONObject(jsonValue).Get('count').JsonValue.Value, i) then
      if i = 0 then
        exit;
  end;

  jsonValue := TJSONObject.ParseJSONValue(
    TJSONObject(jsonValue).Get('records').JsonValue.ToString);
  Assert(jsonValue is TJSONArray);

  jsonArray := jsonValue as TJSONArray;
  for i := 0 to jsonArray.Count - 1  do
  begin
    jsonIndexModel := TJSONIndexModel.Create;
    try
      TSvSerializer.DeSerializeObject(jsonIndexModel, jsonArray.Items[i].ToJSON, sstSuperJson);
      indexData := TIndexModel.Create;

      TModelConverter.ConvertModel(jsonIndexModel, indexData);
      aObjects.Add(indexData);
    finally
      jsonIndexModel.Free;
    end;
  end;

end;

{ TPSEDailySummaryDeserializer }

procedure TPSEDailySummaryDeserializer.Deserialize(const aJSONText: string;
  const aObjects: TObjectList<TObject>);
var
  jsonIndexModel: TJSONDailySummaryModel;

  jsonArray: TJSONArray;
  jsonValue: TJSONValue;

  i: Integer;
  sortResult: TDelegatedComparer<TObject>;
begin
  jsonValue := TJSONObject.ParseJSONValue(aJSONText);
  if jsonValue is TJSONObject then
  begin
    i := 0;
    if TryStrToInt(TJSONObject(jsonValue).Get('count').JsonValue.Value, i) then
      if i = 0 then
        exit;
  end;

  jsonValue := TJSONObject.ParseJSONValue(
    TJSONObject(jsonValue).Get('records').JsonValue.ToString);
  Assert(jsonValue is TJSONArray);

  jsonArray := jsonValue as TJSONArray;
  for i := 0 to jsonArray.Count - 1  do
  begin
    jsonIndexModel := TJSONDailySummaryModel.Create;

    TSvSerializer.DeSerializeObject(jsonIndexModel, jsonArray.Items[i].ToJSON, sstSuperJson);
    aObjects.Add(jsonIndexModel);

  end;

  sortResult := TDelegatedComparer<TObject>.Create(
    function (const l, r: TObject): integer
    begin
      result := TJSONDailySummaryModel(l).number - TJSONDailySummaryModel(r).number
    end);
  aObjects.Sort(sortResult);

end;


{ TPSEHeaderDataDeserializer }

procedure TPSEHeaderDataDeserializer.Deserialize(const aJSONText: string;
  const aObjects: TObjectList<TObject>);
var
  jsonStockHeader: TJSONStockHeaderModel;
  jsonArray: TJSONArray;
  jsonValue: TJSONValue;
  i: integer;
  stockHeaderModel: TStockHeaderModel;
begin

  jsonValue := TJSONObject.ParseJSONValue(aJSONText);
  if jsonValue is TJSONObject then
  begin
    i := 0;
    if TryStrToInt(TJSONObject(jsonValue).Get('count').JsonValue.Value, i) then
      if i = 0 then
        exit;
  end;

  jsonValue := TJSONObject.ParseJSONValue(
    TJSONObject(jsonValue).Get('records').JsonValue.ToString);
  Assert(jsonValue is TJSONArray);

  jsonArray := jsonValue as TJSONArray;
  for i := 0 to jsonArray.Count - 1  do
  begin
    jsonStockHeader := TJSONStockHeaderModel.Create;
    try
      TSvSerializer.DeSerializeObject(jsonStockHeader, jsonArray.Items[i].ToJSON, sstSuperJson);

      stockHeaderModel := TStockHeaderModel.Create;
      TModelConverter.ConvertModel(jsonStockHeader, stockHeaderModel);
      aObjects.Add(stockHeaderModel);
    finally
      jsonStockHeader.Free;
    end;

  end;
end;

end.
