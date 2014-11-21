unit PSE.Data.Downloader;

interface

uses
  System.Classes, System.SysUtils, PSE.Data.Model;

type
  TDownloadTask = class
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
  Generics.Collections,
  OtlParallel, Yeahbah.Messaging, PSEAlert.Messages,
  SvHTTPClient.Indy,
  System.JSON;

{ TDownloadTask }

procedure TDownloadTask.Execute(const aBeforeDownloadProc: TProc;
  const aAfterDownloadProc: TProc;
  const aForEachStockProc: TProc<TStockModel>);
var
  pse: TPSEIntradayData;
  newList: TList<TStockModel>;
  lastUpdateDateTime: TDateTime;
begin
  if Assigned(aBeforeDownloadProc) then
    aBeforeDownloadProc;

  MessengerInstance.SendMessage(TBeforeDownloadMessage.Create);
  Async(
    procedure
    begin
    pse := TPSEIntradayData.Create;
    try
      pse.Update;

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

end.
