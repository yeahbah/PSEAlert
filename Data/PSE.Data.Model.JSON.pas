unit PSE.Data.Model.JSON;

interface

uses
  Generics.Collections;

type
  TJSONIntradayModel = class
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
    FheaderSqLow: single;
    FheaderAvgPrice: single;
    FheaderSqOpen: single;
    FheaderFiftyTwoWeekLow: single;
    FlastTradedDate: string;
    FheaderSqHigh: single;
    FheaderTotalVolume: string;
    FheaderTotalValue: string;
    FheaderLastTradePrice: single;
    FheaderSqPrevious: single;
    FheaderChangeClose: single;
    FheaderCurrentPe: single;
    FsecuritySymbol: string;
    FheaderFiftyTwoWeekHigh: single;
    FheaderPercChangeClose: single;
    FheaderChangeClosePercChangeClose: string;
    procedure SetheaderSqLow(const Value: single);
    procedure SetheaderAvgPrice(const Value: single);
    procedure SetheaderChangeClose(const Value: single);
    procedure SetheaderChangeClosePercChangeClose(const Value: string);
    procedure SetheaderCurrentPe(const Value: single);
    procedure SetheaderFiftyTwoWeekHigh(const Value: single);
    procedure SetheaderFiftyTwoWeekLow(const Value: single);
    procedure SetheaderLastTradePrice(const Value: single);
    procedure SetheaderPercChangeClose(const Value: single);
    procedure SetheaderSqHigh(const Value: single);
    procedure SetheaderSqOpen(const Value: single);
    procedure SetheaderSqPrevious(const Value: single);
    procedure SetheaderTotalValue(const Value: string);
    procedure SetheaderTotalVolume(const Value: string);
    procedure SetlastTradedDate(const Value: string);
    procedure SetsecuritySymbol(const Value: string);
  public
    property headerSqLow: single read FheaderSqLow write SetheaderSqLow;
    property headerFiftyTwoWeekHigh: single read FheaderFiftyTwoWeekHigh write SetheaderFiftyTwoWeekHigh;
    property headerChangeClose: single read FheaderChangeClose write SetheaderChangeClose;
    property headerChangeClosePercChangeClose: string read FheaderChangeClosePercChangeClose write SetheaderChangeClosePercChangeClose;
    property lastTradedDate: string read FlastTradedDate write SetlastTradedDate;
    property headerTotalValue: string read FheaderTotalValue write SetheaderTotalValue;
    property headerLastTradePrice: single read FheaderLastTradePrice write SetheaderLastTradePrice;
    property headerSqHigh: single read FheaderSqHigh write SetheaderSqHigh;
    property headerPercChangeClose: single read FheaderPercChangeClose write SetheaderPercChangeClose;
    property headerFiftyTwoWeekLow: single read FheaderFiftyTwoWeekLow write SetheaderFiftyTwoWeekLow;
    property headerSqPrevious: single read FheaderSqPrevious write SetheaderSqPrevious;
    property securitySymbol: string read FsecuritySymbol write SetsecuritySymbol;
    property headerCurrentPe: single read FheaderCurrentPe write SetheaderCurrentPe;
    property headerSqOpen: single read FheaderSqOpen write SetheaderSqOpen;
    property headerAvgPrice: single read FheaderAvgPrice write SetheaderAvgPrice;
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

  TJSONStockModel = class
  private
    fsecurityID: integer;
    fmarketCapitilization: single;
    flastTradePrice: single;
    fpercentWeight: single;
    fsecurityName: string;
    fcompanyId: integer;
    ftotalMarketCapitalization: single;
    ffreeFloatLevel: single;
    foutstandingShares: single;
    flastTradeDate: string;
    fsecuritySymbol: string;
  public
    property totalMarketCapitalization: single read ftotalMarketCapitalization write ftotalMarketCapitalization;
    property freeFloatLevel: single read ffreeFloatLevel write ffreeFloatLevel;
    property lastTradeDate: string read flastTradeDate write flastTradeDate;
    property lastTradePrice: single read flastTradePrice write flastTradePrice;
    property percentWeight: single read fpercentWeight write fpercentWeight;
    property securityID: integer read fsecurityID write fsecurityID;
    property marketCapitilization: single read fmarketCapitilization write fmarketCapitilization;
    property securitySymbol: string read fsecuritySymbol write fsecuritySymbol;
    property securityName: string read fsecurityName write fsecurityName;
    property companyId: integer read fcompanyId write fcompanyId;
    property outstandingShares: single read foutstandingShares write foutstandingShares;
  end;

  TJSONIndexModel = class
  private
    findexId: string;
    findexAbb: string;
    fisSectoral: string;
    findexName: string;
    fsortOrder: integer;
  public
    property indexId: string read findexId write findexId;
    property isSectoral: string read fisSectoral write fisSectoral;
    property sortOrder: integer read fsortOrder write fsortOrder;
    property indexName: string read findexName write findexName;
    property indexAbb: string read findexAbb write findexAbb;
  end;

  TJSONDailySummaryModel = class
  private
    ftotalValue: single;
    ftotalVolume: single;
    flastTradePrice: single;
    fchangeClose: single;
    fpercChangeClose: single;
    fnumber: integer;
    fsecuritySymbol: string;
    fsecurityName: string;
  public
    property percChangeClose: single read fpercChangeClose write fpercChangeClose;
    property totalVolume: single read ftotalVolume write ftotalVolume;
    property lastTradePrice: single read flastTradePrice write flastTradePrice;
    property securitySymbol: string read fsecuritySymbol write fsecuritySymbol;
    property number: integer read fnumber write fnumber;
    property securityName: string read fsecurityName write fsecurityName;
    property changeClose: single read fchangeClose write fchangeClose;
    property totalValue: single read ftotalValue write ftotalValue;
  end;

implementation


{ TJSONStockHeaderModel }

procedure TJSONStockHeaderModel.SetheaderAvgPrice(const Value: single);
begin
  FheaderAvgPrice := Value;
end;

procedure TJSONStockHeaderModel.SetheaderChangeClose(const Value: single);
begin
  FheaderChangeClose := Value;
end;

procedure TJSONStockHeaderModel.SetheaderChangeClosePercChangeClose(
  const Value: string);
begin
  FheaderChangeClosePercChangeClose := Value;
end;

procedure TJSONStockHeaderModel.SetheaderCurrentPe(const Value: single);
begin
  FheaderCurrentPe := Value;
end;

procedure TJSONStockHeaderModel.SetheaderFiftyTwoWeekHigh(const Value: single);
begin
  FheaderFiftyTwoWeekHigh := Value;
end;

procedure TJSONStockHeaderModel.SetheaderFiftyTwoWeekLow(const Value: single);
begin
  FheaderFiftyTwoWeekLow := Value;
end;

procedure TJSONStockHeaderModel.SetheaderLastTradePrice(const Value: single);
begin
  FheaderLastTradePrice := Value;
end;

procedure TJSONStockHeaderModel.SetheaderPercChangeClose(const Value: single);
begin
  FheaderPercChangeClose := Value;
end;

procedure TJSONStockHeaderModel.SetheaderSqHigh(const Value: single);
begin
  FheaderSqHigh := Value;
end;

procedure TJSONStockHeaderModel.SetheaderSqLow(const Value: single);
begin
  FheaderSqLow := Value;
end;

procedure TJSONStockHeaderModel.SetheaderSqOpen(const Value: single);
begin
  FheaderSqOpen := Value;
end;

procedure TJSONStockHeaderModel.SetheaderSqPrevious(const Value: single);
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

end.
