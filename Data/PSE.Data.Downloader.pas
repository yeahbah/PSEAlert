unit PSE.Data.Downloader;

interface

uses
  System.Classes, System.SysUtils, PSE.Data.Model, Generics.Collections;

type
  TDataContainerBase<T: class> = class(TObjectList<T>)
  protected
    procedure Deserialize(const aJSONText: string); virtual; abstract;
  public
    procedure Update(const aSourceUrl: string); virtual;
  end;

  TPSEIntradayDataContainer = class sealed(TDataContainerBase<TStockModel>)
  protected
    procedure Deserialize(const aJSONText: string); override;
  end;

  TPSEStockDataContainer = class sealed(TDataContainerBase<TStockModel>)
  protected
    procedure Deserialize(const aJSONText: string); override;
  end;

  TIntradayDownloader = class
  private

  public
    procedure Execute(const aBeforeDownloadProc: TProc; const aAfterDownloadProc: TProc;
      const aForEachStockProc: TProc<TStockModel>);
  end;

  TStockDataDownloader = class
  private


  public
    procedure Execute(const aBeforeDownloadProc: TProc; const aAfterDownloadProc: TProc;
      const aForEachStockProc: TProc<TStockModel>);
  end;

//  TStockIdMapDownloader = class
//  public
//    procedure Execute;
//  end;

implementation

uses
  Yeahbah.GenericQuery, PSE.Data,
  OtlParallel, Yeahbah.Messaging, PSEAlert.Messages,
  SvHTTPClient.Indy,
  System.JSON, PSE.Data.Model.JSON;

{ TDownloadTask }

procedure TIntradayDownloader.Execute(const aBeforeDownloadProc: TProc;
  const aAfterDownloadProc: TProc;
  const aForEachStockProc: TProc<TStockModel>);
var
  pse: TPSEIntradayDataContainer;
  newList: TList<TStockModel>;
  lastUpdateDateTime: TDateTime;
begin
  if Assigned(aBeforeDownloadProc) then
    aBeforeDownloadProc;

  MessengerInstance.SendMessage(TBeforeDownloadMessage.Create);
  Async(
    procedure
    begin
    pse := TPSEIntradayDataContainer.Create;
    try
      pse.Update('http://pse.com.ph/stockMarket/home.html?method=getSecuritiesAndIndicesForPublic&ajax=true');

      if pse.Count = 0 then
      begin
        if Assigned(aForEachStockProc) then
          aForEachStockProc(nil);
        MessengerInstance.SendMessage(TNoDataMessage.Create);
        Exit;
      end;

      // save stock information
      lastUpdateDateTime := pse[0].LastUpdateDateTime;
      newList := TGenericQuery<TStockModel>.From(pse)
        .Skip(1)
        .Take(pse.Count - 9).ToList;
      try
        TGenericQuery<TStockModel>.ForEach(newList,
          procedure (stock: TStockModel)
          begin
            if Assigned(aForEachStockProc) then
              aForEachStockProc(stock);
          end);
      finally
        newList.Free;
      end;

      // rename indeces then save
      newList := TGenericQuery<TStockModel>.From(pse)
        .Skip(pse.Count - 8)
        .ToList;
      try
        TGenericQuery<TStockModel>.ForEach(newList,
          procedure (stock: TStockModel)
          begin
            if stock.Symbol = 'PSE' then
              stock.Symbol := '^PSEi'
            else
            if stock.Symbol = 'ALL' then
              stock.Symbol := '^ALLSHARES'
            else
            if stock.Symbol = 'FIN' then
              stock.Symbol := '^FINANCIAL'
            else
            if stock.Symbol = 'IND' then
              stock.Symbol := '^INDUSTRIAL'
            else
            if stock.Symbol = 'HDG' then
              stock.Symbol := '^HOLDING'
            else
            if stock.Symbol = 'PRO' then
              stock.Symbol := '^PROPERTY'
            else
            if stock.Symbol = 'SVC' then
              stock.Symbol := '^SERVICE'
            else
            if stock.Symbol = 'M-O' then
              stock.Symbol := '^MINING-OIL';

            if Assigned(aForEachStockProc) then
              aForEachStockProc(stock);

          end);
      finally
        newList.Free;
      end;

    finally
      pse.Free;
    end;
  end)
  .Await(
    procedure begin
      if Assigned(aAfterDownloadProc) then
        aAfterDownloadProc;
      MessengerInstance.SendMessage(TAfterDownloadMessage.Create(lastUpdateDateTime));
    end);
end;

{ TStockIdMapDownloader }

//procedure TStockIdMapDownloader.Execute;
//var
//  i: Integer;
//
//  httpGet: TIndyHTTPClient;
//  url: string;
//  stream: TStringStream;
//
//  jsonArray: TJSONArray;
//  jsonValue: TJSONValue;
//  jsonObject: TJSONObject;
//  recordCount: integer;
//  symbol: string;
//begin
//  for i := 100 to 5000 do
//  begin
//    httpGet := TIndyHTTPClient.Create;
//    try
//      stream := TStringStream.Create;
//      try
//        url := 'http://pse.com.ph/stockMarket/companyInfo.html?method=fetchHeaderData&ajax=true&security=' + i.ToString;
//        httpGet.Get(url, stream);
//
//        jsonValue := TJSONObject.ParseJSONValue(stream.DataString);
//
//        recordCount := StrToInt((jsonValue as TJSONObject).Get('count').JsonValue.Value);
//        if recordCount = 0 then
//          Continue;
//
//        jsonArray := (jsonValue as TJSONObject).Get('records').JsonValue as TJSONArray;
//
//        jsonObject := jsonArray.Items[0] as TJSONObject;
//        try
//          jsonValue := jsonObject.Get('securitySymbol').JsonValue;
//          symbol := jsonValue.Value;
//          PSEStocksData.PSEStocksConnection.ExecSQL('INSERT OR REPLACE INTO STOCKID_MAP (ID, SYMBOL) VALUES (' + i.ToString + ', ' + QuotedStr(symbol)+')');
//          Sleep(500);
//        except
//          Continue;
//        end;
//
//      finally
//        stream.Free;
//      end;
//    finally
//      httpGet.Free;
//    end;
//  end;
//end;

{ TStockDataDownloader }

procedure TStockDataDownloader.Execute(const aBeforeDownloadProc,
  aAfterDownloadProc: TProc; const aForEachStockProc: TProc<TStockModel>);
begin

end;

{ TIntradayDownloader.TPSEIntradayData }

procedure TPSEIntradayDataContainer.Deserialize(
  const aJSONText: string);
var
  jsonStock: TJSONIntradayModel;
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

      stockModel := TStockModel.Create;
      TModelConverter.ConvertModel(jsonStock, stockModel);

      stockModel.LastUpdateDateTime := lastUpdate;
      Self.Add(stockModel);
    finally
      jsonStock.Free;
    end;
  end;

end;

{ TStockDataDownloader.TPSEStockData }

procedure TPSEStockDataContainer.Deserialize(const aJSONText: string);
begin
  inherited;

end;

{ TDataContainerBase<T> }

procedure TDataContainerBase<T>.Update(const aSourceUrl: string);
var
  httpGet: TIndyHTTPClient;
  url: string;
  stream: TStringStream;
begin
  httpGet := TIndyHTTPClient.Create;
  try
    stream := TStringStream.Create;
    try
      //url := 'http://pse.com.ph/stockMarket/home.html?method=getSecuritiesAndIndicesForPublic&ajax=true';
      httpGet.Get(aSourceUrl, stream);
      Deserialize(stream.DataString);
    finally
      stream.Free;
    end;
  finally
    httpGet.Free;
  end;
end;

end.
