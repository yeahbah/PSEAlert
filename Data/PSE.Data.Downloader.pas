unit PSE.Data.Downloader;

interface

uses
  System.Classes, System.SysUtils, PSE.Data.Model, Generics.Collections;

type
  TDownloaderBase<T: class> = class
  protected
    fUrl: string;
    procedure Download(const aSourceUrl: string; const aOuputStream: TStream); virtual;
  public
    procedure Execute(const aBeforeDownloadProc: TProc; const aAfterDownloadProc: TProc;
      const aForEachStockProc: TProc<T>); virtual;
  end;

  TIntradayDownloader = class sealed(TDownloaderBase<TIntradayModel>)
  public
    procedure Execute(const aBeforeDownloadProc: TProc; const aAfterDownloadProc: TProc;
      const aForEachStockProc: TProc<TIntradayModel>); override;
  end;

  TStockDataDownloader = class sealed(TDownloaderBase<TStockModel>)
  public
    constructor Create;
//    procedure Execute(const aBeforeDownloadProc: TProc; const aAfterDownloadProc: TProc;
//      const aForEachStockProc: TProc<TStockModel>); override;
  end;

  TIndexDataDownloader = class sealed(TDownloaderBase<TIndexModel>)
  public
    constructor Create(const aUrl: string);
    procedure Execute(const aBeforeDownloadProc: TProc; const aAfterDownloadProc: TProc;
      const aForEachStockProc: TProc<TIndexModel>); override;
  end;

  TPSEHeaderData = class
  private
    //fStockHeaderModel: TStockHeaderModel;
    fRecordCount: integer;
  protected
    procedure Deserialize(const aJSONText: string);
  public
    function UpdateStockHeaderObject(const aSymbol: string; aStockHeaderModel: TStockHeaderModel): boolean;
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
  System.JSON, PSE.Data.Model.JSON, PSEAlert.Utils, PSE.Data.Deserializer;



const
  PSE_INDEX_URL = 'http://www.pse.com.ph/stockMarket/marketInfo-marketActivity-indicesComposition.html?method=getCompositionIndices&ajax=true&sector=%s';

{ TDownloadTask }

procedure TIntradayDownloader.Execute(const aBeforeDownloadProc: TProc;
  const aAfterDownloadProc: TProc;
  const aForEachStockProc: TProc<TIntradayModel>);
var
  intradayList: TObjectList<TIntradayModel>;
  newList: TList<TIntradayModel>;
  lastUpdateDateTime: TDateTime;
  downloadStream: TStringStream;
  deserializer: TPSEIntradayDeserializer;
begin
  if Assigned(aBeforeDownloadProc) then
    aBeforeDownloadProc;

  MessengerInstance.SendMessage(TBeforeDownloadMessage.Create);
  Async(
    procedure
    begin
      downloadStream := TStringStream.Create;
      deserializer := TPSEIntradayDeserializer.Create;
      intradayList := TObjectList<TIntradayModel>.Create;
      try
        Download('http://pse.com.ph/stockMarket/home.html?method=getSecuritiesAndIndicesForPublic&ajax=true', downloadStream);

        deserializer.Deserialize(downloadstream.DataString, intradayList);
        if intradayList.Count = 0 then
        begin
          if Assigned(aForEachStockProc) then
            aForEachStockProc(nil);
          MessengerInstance.SendMessage(TNoDataMessage.Create);
          Exit;
        end;

        // save stock information
        lastUpdateDateTime := intradayList[0].LastUpdateDateTime;
        newList := TGenericQuery<TIntradayModel>.From(intradayList)
          .Skip(1)
          .Take(intradayList.Count - 9).ToList;
        try
          TGenericQuery<TIntradayModel>.ForEach(newList,
            procedure (stock: TIntradayModel)
            begin
              if Assigned(aForEachStockProc) then
                aForEachStockProc(stock);
            end);
        finally
          newList.Free;
        end;

        // rename indeces then save
        newList := TGenericQuery<TIntradayModel>.From(intradayList)
          .Skip(intradayList.Count - 8)
          .ToList;
        try
          TGenericQuery<TIntradayModel>.ForEach(newList,
            procedure (stock: TIntradayModel)
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
        downloadStream.Free;
        deserializer.Free;
        intradayList.Free;
      end;
  end)
  .Await(
    procedure
    begin
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

constructor TStockDataDownloader.Create;
begin
  fUrl := Format(PSE_INDEX_URL, ['ALL']);
end;

//procedure TStockDataDownloader.Execute(const aBeforeDownloadProc,
//  aAfterDownloadProc: TProc; const aForEachStockProc: TProc<TStockModel>);
//var
//  downloadStream: TStringStream;
//  stockDataList: TObjectList<TStockModel>;
//  deserializer: TPSEStockDataDeserializer;
//begin
//  if Assigned(aBeforeDownloadProc) then
//    aBeforeDownloadProc;
//
//  MessengerInstance.SendMessage(TBeforeDownloadMessage.Create);
//  Async(
//    procedure
//    begin
//      downloadStream := TStringStream.Create;
//      stockDataList := TObjectList<TStockModel>.Create;
//      deserializer := TPSEStockDataDeserializer.Create;
//      try
//        Download(Format(PSE_INDEX_URL, ['ALL']), downloadStream);
//        deserializer.Deserialize(downloadStream.DataString, stockDataList);
//        if stockDataList.Count = 0 then
//        begin
//          if Assigned(aForEachStockProc) then
//            aForEachStockProc(nil);
//          MessengerInstance.SendMessage(TNoDataMessage.Create);
//          Exit;
//        end;
//
//        TGenericQuery<TStockModel>.ForEach(stockDataList,
//          procedure (stock: TStockModel)
//          begin
//
//            if Assigned(aForEachStockProc) then
//              aForEachStockProc(stock);
//
//          end);
//
//      finally
//        downloadStream.Free;
//        stockDataList.Free;
//        deserializer.Free;
//      end;
//    end)
//  .Await(
//    procedure
//    begin
//      if Assigned(aAfterDownloadProc) then
//        aAfterDownloadProc;
//      MessengerInstance.SendMessage(TAfterDownloadMessage.Create(Now));
//    end);
//
//end;

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

    //TModelConverter.ConvertModel(jsonStockHeader, fStockHeaderModel);

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


{ TIndexDataDownloader }

constructor TIndexDataDownloader.Create(const aUrl: string);
begin
  inherited Create;
  fUrl := aUrl;
end;

procedure TIndexDataDownloader.Execute(const aBeforeDownloadProc,
  aAfterDownloadProc: TProc; const aForEachStockProc: TProc<TIndexModel>);
var
  downloadStream: TStringStream;
  stockDataList: TObjectList<TIndexModel>;
  deserializer: TPSEStockDataDeserializer;
begin
  if Assigned(aBeforeDownloadProc) then
    aBeforeDownloadProc;

  MessengerInstance.SendMessage(TBeforeDownloadMessage.Create);
  Async(
    procedure
    begin
      downloadStream := TStringStream.Create;
      stockDataList := TObjectList<TIndexModel>.Create;


      //deserializer := TPSEStockDataDeserializer.Create;
      try
        Download(fUrl, downloadStream);

        //deserializer.Deserialize(downloadStream.DataString, stockDataList);

        if stockDataList.Count = 0 then
        begin
          if Assigned(aForEachStockProc) then
            aForEachStockProc(nil);
          MessengerInstance.SendMessage(TNoDataMessage.Create);
          Exit;
        end;

//        TGenericQuery<TStockModel>.ForEach(stockDataList,
//          procedure (stock: TStockModel)
//          begin
//
//            if Assigned(aForEachStockProc) then
//              aForEachStockProc(stock);
//
//          end);

      finally
        downloadStream.Free;
        stockDataList.Free;
        deserializer.Free;
      end;
    end)
  .Await(
    procedure
    begin
      if Assigned(aAfterDownloadProc) then
        aAfterDownloadProc;
      MessengerInstance.SendMessage(TAfterDownloadMessage.Create(Now));
    end);

end;

{ TDownloaderBase }

procedure TDownloaderBase<T>.Download(const aSourceUrl: string; const aOuputStream: TStream);
var
  httpGet: TIndyHTTPClient;
  url: string;
begin
  httpGet := TIndyHTTPClient.Create;
  try
    httpGet.Get(aSourceUrl, aOuputStream);
  finally
    httpGet.Free;
  end;
end;

procedure TDownloaderBase<T>.Execute(const aBeforeDownloadProc,
  aAfterDownloadProc: TProc; const aForEachStockProc: TProc<T>);
var
  downloadStream: TStringStream;
  stockDataList: TObjectList<T>;
  deserializer: TDeserializerBase<T>;
begin
  if Assigned(aBeforeDownloadProc) then
    aBeforeDownloadProc;

  MessengerInstance.SendMessage(TBeforeDownloadMessage.Create);
  Async(
    procedure
    begin
      downloadStream := TStringStream.Create;
      stockDataList := TObjectList<T>.Create;
      deserializer := TDeserializerBase<T>.Create;
      try
        Download(Format(fUrl, ['ALL']), downloadStream);
        deserializer.Deserialize(downloadStream.DataString, stockDataList);
        if stockDataList.Count = 0 then
        begin
          if Assigned(aForEachStockProc) then
            aForEachStockProc(nil);
          MessengerInstance.SendMessage(TNoDataMessage.Create);
          Exit;
        end;

        TGenericQuery<T>.ForEach(stockDataList,
          procedure (stock: T)
          begin

            if Assigned(aForEachStockProc) then
              aForEachStockProc(stock);

          end);

      finally
        downloadStream.Free;
        stockDataList.Free;
        deserializer.Free;
      end;
    end)
  .Await(
    procedure
    begin
      if Assigned(aAfterDownloadProc) then
        aAfterDownloadProc;
      MessengerInstance.SendMessage(TAfterDownloadMessage.Create(Now));
    end);

end;

end.
