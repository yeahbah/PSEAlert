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

  TJSONStockModel = class
  private
    fsecurityID: string;
    fmarketCapitilization: string;
    flastTradePrice: string;
    fpercentWeight: string;
    fsecurityName: string;
    fcompanyId: string;
    ftotalMarketCapitalization: string;
    ffreeFloatLevel: string;
    foutstandingShares: string;
    flastTradeDate: string;
  public
    property totalMarketCapitalization: string read ftotalMarketCapitalization write ftotalMarketCapitalization;
    property freeFloatLevel: string read ffreeFloatLevel write ffreeFloatLevel;
    property lastTradeDate: string read flastTradeDate write flastTradeDate;
    property lastTradePrice: string read flastTradePrice write flastTradePrice;
    property percentWeight: string read fpercentWeight write fpercentWeight;
    property securityID: string read fsecurityID write fsecurityID;
    property marketCapitilization: string read fmarketCapitilization write fmarketCapitilization;
    property securitySymbol: string read fmarketCapitilization write fmarketCapitilization;
    property securityName: string read fsecurityName write fsecurityName;
    property companyId: string read fcompanyId write fcompanyId;
    property outstandingShares: string read foutstandingShares write foutstandingShares;
  end;

implementation


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

end.
