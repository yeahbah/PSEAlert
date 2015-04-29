unit PSE.Data.Downloader;

interface

uses
  System.Classes, System.SysUtils, PSE.Data.Model, Generics.Collections,
  PSE.Data.Model.JSON;

type
  TPSEDownloader<T: class> = class
  protected
    fUrl: string;
    procedure Download(const aSourceUrl: string; const aOuputStream: TStream); virtual;
  public
    procedure ExecuteAsync(const aBeforeDownloadProc: TProc; const aAfterDownloadProc: TProc;
      const aForEachStockProc: TProc<T>); virtual;
    procedure Execute(const aForEachStockProc: TProc<T>); virtual;
  end;

  // intraday data
  TIntradayDownloader = class sealed(TPSEDownloader<TIntradayModel>)
  public
    procedure ExecuteAsync(const aBeforeDownloadProc: TProc; const aAfterDownloadProc: TProc;
      const aForEachStockProc: TProc<TIntradayModel>); override;
  end;

  // stock information
  TStockDataDownloader = class sealed(TPSEDownloader<TStockModel>)
  public
    constructor Create(const aSector: string);
  end;

  // market summary: most active, top gainers, top losers
  TActivityDownloadType = (MostActive, Advance, Decline);
  TStockActivityDownloader = class sealed(TPSEDownloader<TJSONDailySummaryModel>)
  public
    constructor Create(const aActivityDownloadType: TActivityDownloadType);
  end;

  // market indeces
  TIndexDataDownloader = class sealed(TPSEDownloader<TIndexModel>)
  public
    constructor Create;
  end;

  // stock header information i.e. PE ratio, 52 wk hi/lo etc
  TStockDetail_HeaderDownloader = class sealed(TPSEDownloader<TStockHeaderModel>)
  public
    constructor Create(const aStockId: integer);
  end;

implementation

uses
  Yeahbah.GenericQuery, PSE.Data,
  OtlParallel, Yeahbah.Messaging, PSEAlert.Messages,
  SvHTTPClient.Indy,
  System.JSON, PSEAlert.Utils, PSE.Data.Deserializer;

{ TDownloadTask }

procedure TIntradayDownloader.ExecuteAsync(const aBeforeDownloadProc: TProc;
  const aAfterDownloadProc: TProc;
  const aForEachStockProc: TProc<TIntradayModel>);
var
  intradayList: TObjectList<TObject>;
  newList: TList<TObject>;
  lastUpdateDateTime: TDateTime;
  downloadStream: TStringStream;
  deserializer: TDeserializer;
begin
  if Assigned(aBeforeDownloadProc) then
    aBeforeDownloadProc;

  MessengerInstance.SendMessage(TBeforeDownloadMessage.Create);
  Async(
    procedure
    begin
      downloadStream := TStringStream.Create;
      deserializer := TDeserializerFactory.GetDeserializer(TIntradayModel);
      intradayList := TObjectList<TObject>.Create;
      try
        Download('http://pse.com.ph/stockMarket/home.html?method=getSecuritiesAndIndicesForPublic&ajax=true', downloadStream);

        deserializer.Deserialize(downloadstream.DataString, intradayList);
        if intradayList.Count = 0 then
        begin
          if Assigned(aForEachStockProc) then
            aForEachStockProc(nil);
          MessengerInstance.SendMessage(TNoDataMessage<TIntradayModel>.Create);
          Exit;
        end;

        // save stock information
        lastUpdateDateTime := TIntradayModel(intradayList[0]).LastUpdateDateTime;
        newList := TGenericQuery<TObject>.From(intradayList)
          .Skip(1)
          .Take(intradayList.Count - 9).ToList;
        try
          TGenericQuery<TObject>.ForEach(newList,
            procedure (stock: TObject)
            begin
              if Assigned(aForEachStockProc) then
                aForEachStockProc(stock as TIntradayModel);
            end);
        finally
          newList.Free;
        end;

        // rename indeces then save
        newList := TGenericQuery<TObject>.From(intradayList)
          .Skip(intradayList.Count - 8)
          .ToList;
        try
          TGenericQuery<TObject>.ForEach(newList,
            procedure (stock: TObject)
            var
              obj: TIntradayModel;
            begin
              obj := stock as TIntradayModel;
              if obj.Symbol = 'PSE' then
                obj.Symbol := '^PSEi'
              else
              if obj.Symbol = 'ALL' then
                obj.Symbol := '^ALLSHARES'
              else
              if obj.Symbol = 'FIN' then
                obj.Symbol := '^FINANCIAL'
              else
              if obj.Symbol = 'IND' then
                obj.Symbol := '^INDUSTRIAL'
              else
              if obj.Symbol = 'HDG' then
                obj.Symbol := '^HOLDING'
              else
              if obj.Symbol = 'PRO' then
                obj.Symbol := '^PROPERTY'
              else
              if obj.Symbol = 'SVC' then
                obj.Symbol := '^SERVICE'
              else
              if obj.Symbol = 'M-O' then
                obj.Symbol := '^MINING-OIL';

              if Assigned(aForEachStockProc) then
                aForEachStockProc(obj);

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

{ TStockDataDownloader }

constructor TStockDataDownloader.Create(const aSector: string);
const
  PSE_INDEX_URL = 'http://www.pse.com.ph/stockMarket/marketInfo-marketActivity-indicesComposition.html?method=getCompositionIndices&ajax=true&sector=%s';
begin
  inherited Create;
  fUrl := Format(PSE_INDEX_URL, [aSector]);
end;

{ TIndexDataDownloader }

constructor TIndexDataDownloader.Create;
begin
  inherited Create;
  fUrl := 'http://www.pse.com.ph/stockMarket/marketInfo-marketActivity-indicesComposition.html?method=getMarketIndices&ajax=true';
end;

{ TDownloaderBase }

procedure TPSEDownloader<T>.Download(const aSourceUrl: string; const aOuputStream: TStream);
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

procedure TPSEDownloader<T>.Execute(const aForEachStockProc: TProc<T>);
var
  downloadStream: TStringStream;
  objects: TObjectList<TObject>;
  deserializer: TDeserializer;
begin
  downloadStream := TStringStream.Create;
  objects := TObjectList<TObject>.Create;
  deserializer := TDeserializerFactory.GetDeserializer(T);
  try
    Download(fUrl, downloadStream);
    deserializer.Deserialize(downloadStream.DataString, objects);
    if objects.Count = 0 then
    begin
      if Assigned(aForEachStockProc) then
        aForEachStockProc(nil);
      MessengerInstance.SendMessage(TNoDataMessage<T>.Create);
      Exit;
    end;

    TGenericQuery<TObject>.ForEach(objects,
      procedure (stock: TObject)
      begin

        if Assigned(aForEachStockProc) then
          aForEachStockProc(stock as T);

      end);

  finally
    downloadStream.Free;
    objects.Free;
    deserializer.Free;
  end;
end;

procedure TPSEDownloader<T>.ExecuteAsync(const aBeforeDownloadProc,
  aAfterDownloadProc: TProc; const aForEachStockProc: TProc<T>);

begin
  if Assigned(aBeforeDownloadProc) then
    aBeforeDownloadProc;

  MessengerInstance.SendMessage(TBeforeDownloadMessage.Create);
  Async(
    procedure
    begin
      Execute(aForEachStockProc);
    end)
  .Await(
    procedure
    begin
      if Assigned(aAfterDownloadProc) then
        aAfterDownloadProc;
      MessengerInstance.SendMessage(TAfterDownloadMessage.Create(Now));
    end);

end;

{ TStockActivityDownloader }

constructor TStockActivityDownloader.Create(
  const aActivityDownloadType: TActivityDownloadType);
begin
  inherited Create;
  case aActivityDownloadType of
    MostActive: fUrl := 'http://www.pse.com.ph/stockMarket/dailySummary.html?method=getTopActiveStocks&ajax=true';
    Advance: fUrl := 'http://www.pse.com.ph/stockMarket/dailySummary.html?method=getAdvancedSecurity&ajax=true';
    Decline: fUrl := 'http://www.pse.com.ph/stockMarket/dailySummary.html?method=getDeclinesSecurity&ajax=true';
  end;
end;

{ TStockDetail_HeaderDownloader }

constructor TStockDetail_HeaderDownloader.Create(const aStockId: integer);
begin
  inherited Create;
  fUrl := 'http://pse.com.ph/stockMarket/companyInfo.html?method=fetchHeaderData&ajax=true&security=' + aStockId.ToString;
end;

end.
