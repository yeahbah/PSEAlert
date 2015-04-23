unit PSE.Data.Deserializer;

interface

uses
  Generics.Collections,
  PSE.Data.Model;

type
  TDeserializer = class
  public
    procedure Deserialize<T: class>(const aJSONText: string; const aObjects: TObjectList<T>);
  end;

  TPSEIntradayDeserializer = class sealed(TDeserializer)
  public
    procedure Deserialize<T>(const aJSONText: string; const aObjects: TObjectList<TIntradayModel>);
  end;

  TPSEStockDataDeserializer = class sealed(TDeserializer)
  protected
    procedure Deserialize<T>(const aJSONText: string; const aObjects: TObjectList<TStockModel>);
  end;




implementation

uses
  PSE.Data.Model.JSON,
  System.JSON,
  SysUtils, PSEAlert.Utils;

type
  TModelConverter = class
  public
    class procedure ConvertModel(const aSource: TJSONIntradayModel;
      const aTarget: TIntradayModel); overload;
    class procedure ConvertModel(const aSource: TJSONStockHeaderModel;
      const aTarget: TStockHeaderModel); overload;
    class procedure ConvertModel(const aSource: TJSONStockModel;
      const aTarget: TStockModel); overload;
  end;

{ TPSEIntradayDeserializer }

procedure TPSEIntradayDeserializer.Deserialize(const aJSONText: string;
  const aObjects: TObjectList<TIntradayModel>);
var
  jsonStock: TJSONIntradayModel;
  intradayData: TIntradayModel;

  jsonArray: TJSONArray;
  jsonValue: TJSONValue;
  jsonObject: TJSONObject;

  i: Integer;
  lastUpdate: TDateTime;
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
        lastUpdate := StrToDateTime(jsonStock.securityAlias);
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

  aTarget.LastTradedDate := ConvertStringDateToSystem(aSource.lastTradedDate);
end;

class procedure TModelConverter.ConvertModel(const aSource: TJSONStockModel;
  const aTarget: TStockModel);
begin
  aTarget.Symbol := aSource.securitySymbol;
  aTarget.Description := aSource.securityName;
  aTarget.SecurityId := StrToInt(aSource.securityID);
  aTarget.CompanyId := StrToInt(aSource.companyId);
  aTarget.LastTradedPrice := StrToFloat(aSource.lastTradePrice);
  if aSource.lastTradeDate.Trim <> '' then
    aTarget.LastTradedDate := ConvertStringDateToSystem(aSource.lastTradeDate);
  aTarget.MarketCapitalization := StrToFloat(aSource.marketCapitilization);
  aTarget.FreeFloatLevel := StrToFloat(aSource.freeFloatLevel);
  aTarget.OutstandingShares := StrToFloat(aSource.outstandingShares);
end;

{ TPSEStockDataDeserializer }

procedure TPSEStockDataDeserializer.Deserialize(const aJSONText: string;
  const aObjects: TObjectList<TStockModel>);
var
  jsonStock: TJSONStockModel;
  stockData: TStockModel;

  jsonArray: TJSONArray;
  jsonValue: TJSONValue;
  jsonObject: TJSONObject;
  jsonPair: TJSONPair;

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
      jsonObject := jsonArray.Items[i] as TJSONObject;
      jsonStock.securitySymbol := jsonObject.Get('securitySymbol').JsonValue.Value;
      jsonStock.securityName := jsonObject.Get('securityName').JsonValue.Value;
      jsonStock.lastTradePrice := jsonObject.Get('lastTradePrice').JsonValue.Value;

      jsonPair := jsonObject.Get('lastTradeDate');
      if jsonPair <> nil then
      begin
        jsonStock.lastTradeDate := jsonPair.JsonValue.Value;
      end;
      jsonStock.percentWeight := jsonObject.Get('percentWeight').JsonValue.Value;
      jsonStock.securityID := jsonObject.Get('securityID').JsonValue.Value;
      jsonStock.marketCapitilization := jsonObject.Get('marketCapitilization').JsonValue.Value;
      jsonStock.freeFloatLevel := jsonObject.Get('freeFloatLevel').JsonValue.Value;
      jsonStock.companyId := jsonObject.Get('companyId').JsonValue.Value;
      jsonStock.outstandingShares := jsonObject.Get('outstandingShares').JsonValue.Value;

      stockData := TStockModel.Create;
      TModelConverter.ConvertModel(jsonStock, stockData);

      aObjects.Add(stockData);
    finally
      jsonStock.Free;
    end;
  end;

end;

{ TDeserializer<T> }

procedure TDeserializer<T>.Deserialize(const aJSONText: string;
  const aObjects: TObjectList<T>);
begin
  if T = TStockModel then
  begin

    Deserialize(aJSONText, aObjects)
  end

end;

end.
