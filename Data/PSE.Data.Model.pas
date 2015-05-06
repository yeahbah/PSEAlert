unit PSE.Data.Model;

interface

uses
  System.SysUtils,
  Spring,
  Spring.Persistence.Mapping.Attributes;

type
  TStockStatus = (Up, Down, Unchanged);

  [Entity]
  [Table('STOCKS')]
  TStockModel = class
  private
    fSymbol: string;
    fPercentChange: single;
    fLastTradedPrice: single;
    fDescription: string;
    fLastTradedDate: TDate;
    fSecurityId: integer;
    fMarketCapitalization: single;
    fCompanyId: integer;
    fFreeFloatLevel: single;
    fOutstandingShares: single;
  public
    constructor Create;
    [Column('SYMBOL', [cpRequired, cpPrimaryKey])]
    property Symbol: string read fSymbol write fSymbol;
    [Column('DESCRIPTION')]
    property Description: string read fDescription write fDescription;
    [Column('SECURITY_ID')]
    property SecurityId: integer read fSecurityId write fSecurityId;
    [Column('COMPANY_ID')]
    property CompanyId: integer read fCompanyId write fCompanyId;
    [Column('LAST_TRADED_PRICE')]
    property LastTradedPrice: single read fLastTradedPrice write fLastTradedPrice;
    [Column('LAST_TRADED_DATE')]
    property LastTradedDate: TDate read fLastTradedDate write fLastTradedDate;
    [Column('FREE_FLOAT_LEVEL')]
    property FreeFloatLevel: single read fFreeFloatLevel write fFreeFloatLevel;
    [Column('MARKET_CAPITALIZATION')]
    property MarketCapitalization: single read fMarketCapitalization write fMarketCapitalization;
    [Column('OUTSTANDING_SHARES')]
    property OutstandingShares: single read fOutstandingShares write fOutstandingShares;
  end;

  [Entity]
  [Table('INDECES')]
  TIndexModel = class
  private
    fIsSector: string;
    fId: string;
    fIndexSymbol: string;
    fIndexName: string;
    fSortOrder: integer;
    fAltIndexSymbol: string;
  public
    [Column('ID', [cpRequired, cpPrimaryKey])]
    property Id: string read fId write fId;
    [Column('INDEX_SYMBOL')]
    property IndexSymbol: string read fIndexSymbol write fIndexSymbol;
    [Column('ALT_INDEX_SYMBOL')]
    property AltIndexSymbol: string read fAltIndexSymbol write fAltIndexSymbol;
    [Column('INDEX_NAME')]
    property IndexName: string read fIndexName write fIndexName;
    [Column('IS_SECTORAL')]
    property IsSector: string read fIsSector write fIsSector;
    [Column('SORT_ORDER')]
    property SortOrder: integer read fSortOrder write fSortOrder;
  end;

  [Entity]
  [Table('INTRADAY')]
  TIntradayModel = class
  private
    fSymbol: string;
    fPercentChange: single;
    fPrice: single;
//    fValue: single;
    fVolume: single;
    fStockStatus: TStockStatus;
    fLastUpdateDateTime: TDateTime;
    fDescription: string;
  public
    [Column('SYMBOL', [cpRequired, cpPrimaryKey])]
    property Symbol: string read fSymbol write fSymbol;
    [Column('LASTPRICE')]
    property LastTradedPrice: single read fPrice write fPrice;
    [Column('LASTUPDATE_DATETIME')]
    property LastUpdateDateTime: TDateTime read fLastUpdateDateTime write fLastUpdateDateTime;
    [Column('PCTCHANGE')]
    property PercentChange: single read fPercentChange write fPercentChange;
    [Column('VOLUME')]
    property Volume: single read fVolume write fVolume;
    [Column('STATUS')]
    property Status: TStockStatus read fStockStatus write fStockStatus;

    property Description: string read fDescription write fDescription;
  end;

  TStockHeaderModel = class
  private
    fSymbol: string;
    fFiftyTwoWeekLow: single;
    fTotalVolume: int64;
    fTotalValue: int64;
    fChangeClose: single;
    fCurrentPE: single;
    fLastTradedDate: TDateTime;
    fPreviousClose: single;
    fFiftyTwoWeekHigh: single;
    fIntradayLow: single;
    fLastTradedPrice: single;
    fAvgPrice: single;
    fIntradayOpen: single;
    fIntradayHigh: single;
    fChangeClosePercentage: single;
  public
    constructor Create;
    destructor Destroy; override;
    property Symbol: string read fSymbol write fSymbol;
    property FiftyTwoWeekHigh: single read fFiftyTwoWeekHigh write fFiftyTwoWeekHigh;
    property FiftyTwoWeekLow: single read fFiftyTwoWeekLow write fFiftyTwoWeekLow;
    property PreviousClose: single read fPreviousClose write fPreviousClose;
    property ChangeClose: single read fChangeClose write fChangeClose;
    property ChangeClosePercentage: single read fChangeClosePercentage write fChangeClosePercentage;
    property LastTradedDate: TDateTime read fLastTradedDate write fLastTradedDate;
    property LastTradedPrice: single read fLastTradedPrice write fLastTradedPrice;
    property TotalValue: int64 read fTotalValue write fTotalValue;
    property TotalVolume: int64 read fTotalVolume write fTotalVolume;
    property IntradayLow: single read fIntradayLow write fIntradayLow;
    property IntradayHigh: single read fIntradayHigh write fIntradayHigh;
    property IntradayOpen: single read fIntradayOpen write fIntradayOpen;
    property AvgPrice: single read fAvgPrice write fAvgPrice;
    property CurrentPE: single read fCurrentPE write fCurrentPE;
  end;

  [Entity]
  [Table('STOCK_ATTRIBUTE')]
  TStockAttribute = class
  private
    fSymbol: string;
    fAttributeType: string;
    fAttributeValue: string;
    fAttributeKey: string;
    fId: integer;
    fAttributeDisplayText: string;
  public
    [Column('ID', [cpRequired, cpPrimaryKey])]
    property ID: integer read fId write fId;
    [Column('SYMBOL', [cpRequired])]
    property Symbol: string read fSymbol write fSymbol;
    [Column('ATTR_KEY', [cpRequired])]
    property AttributeKey: string read fAttributeKey write fAttributeKey;
    [Column('ATTR_VALUE')]
    property AttributeValue: string read fAttributeValue write fAttributeValue;
    [Column('ATTR_TYPE')]
    property AttributeType: string read fAttributeType write fAttributeType;
    [Column('ATTR_DISPLAYTEXT')]
    property AttributeDisplayText: string read fAttributeDisplayText write fAttributeDisplayText;
  end;

  TPriceTriggerType = (Below, Equal, Above, BelowEqual, AboveEqual);

  TLogicType = (None=0, LogicOr=1, LogicAND=2);

  [Entity]
  [Table('ALERTS')]
  TAlertModel = class
  private
    fStock: string;
    fCreatedDateTime: TDateTime;
    FNotes: string;
    FAlertCount: integer;
    FMaxAlertCount: integer;
    FPrice: single;
    FPriceTriggerType: TPriceTriggerType;
    FVolume: single;
    FLogic: TLogicType;
    procedure SetLogic(const Value: TLogicType);
    procedure SetPrice(const Value: single);
    procedure SetPriceTriggerType(const Value: TPriceTriggerType);
    procedure SetVolume(const Value: single);
//    procedure SetPriceTrigger(const Value: TPriceTrigger);
    procedure SetStock(const Value: string);
//    procedure SetVolumeTrigger(const Value: TVolumeTrigger);
    procedure SetNotes(const Value: string);
    procedure SetAlertCount(const Value: integer);
    procedure SetMaxAlertCount(const Value: integer);
    function GetPriceTriggerDescription: string;
    function GetVolumeTriggerDescription: string;
  private
    [Column('ID', [cpRequired, cpPrimaryKey, cpNotNull, cpDontInsert], 0, 0, 0, 'Primary Key')]
    [AutoGenerated]
    fId: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    property ID: Integer read FId write FId;
    [Column('SYMBOL', [cpNotNull])]
    property StockSymbol: string read fStock write SetStock;
    property CreatedDateTime: TDateTime read fCreatedDateTime write fCreatedDateTime;

    [Column('PRICE')]
    property Price: single read FPrice write SetPrice;
    [Column('PRICELEVEL')]
    property PriceTriggerType: TPriceTriggerType read FPriceTriggerType write SetPriceTriggerType;
    [Column('VOLUME')]
    property Volume: single read FVolume write SetVolume;
    [Column('VOL_CONJUNCT')]
    property Logic: TLogicType read FLogic write SetLogic;
    [Column('ALERT_COUNT')]
    property AlertCount: integer read FAlertCount write SetAlertCount;
    [Column('MAX_ALERT')]
    property MaxAlertCount: integer read FMaxAlertCount write SetMaxAlertCount;
    [Column('NOTES')]
    property Notes: string read FNotes write SetNotes;
    property PriceTriggerDescription: string read GetPriceTriggerDescription;
    property VolumeTriggerDescription: string read GetVolumeTriggerDescription;
    function CanTrigger: boolean;
  end;

implementation

uses
  TypInfo, StrUtils;


{ TStockModel }

constructor TStockModel.Create;
begin
  fPercentChange := 0;
  fLastTradedPrice := 0;
  fFreeFloatLevel := 0;
  fMarketCapitalization := 0;
  fOutstandingShares := 0;
end;

function TAlertModel.CanTrigger: boolean;
begin
  result := fAlertCount < fMaxAlertCount;
end;

constructor TAlertModel.Create;
begin
//  FPriceTrigger := TPriceTrigger.Create;
//  FVolumeTrigger := TVolumeTrigger.Create;
  fLogic := TLogicType.None;
  FAlertCount := 0;
  FMaxAlertCount := 10;
end;

destructor TAlertModel.Destroy;
begin
  inherited;
end;

function TAlertModel.GetPriceTriggerDescription: string;
begin
  result := 'Trigger alert when the price is ';
  if PriceTriggerType = TPriceTriggerType.BelowEqual then
    result := result + 'Below/Equal'
  else
  if PriceTriggerType = TPriceTriggerType.AboveEqual then
    result := result + 'Above/Equal'
  else
    result := result + GetEnumName(TypeInfo(TPriceTriggerType), integer(FPriceTriggerType));
  result := result + ' ' + FloatToStr(FPrice);
end;

function TAlertModel.GetVolumeTriggerDescription: string;
begin

  if FLogic <> TLogicType.None then
  begin
    result := ReplaceStr(GetEnumName(TypeInfo(TLogicType), integer(FLogic)), 'Logic', string.Empty).Trim;
    result := result +' when volume is at least ' + FloatToStr(FVolume);
  end

end;

procedure TAlertModel.SetAlertCount(const Value: integer);
begin
  FAlertCount := Value;
end;

procedure TAlertModel.SetLogic(const Value: TLogicType);
begin
  FLogic := Value;
end;

procedure TAlertModel.SetMaxAlertCount(const Value: integer);
begin
  FMaxAlertCount := Value;
end;

procedure TAlertModel.SetNotes(const Value: string);
begin
  FNotes := Value;
end;

procedure TAlertModel.SetPrice(const Value: single);
begin
  FPrice := Value;
end;

//procedure TAlertModel.SetPriceTrigger(const Value: TPriceTrigger);
//begin
//  FPriceTrigger := Value;
//end;

procedure TAlertModel.SetPriceTriggerType(const Value: TPriceTriggerType);
begin
  FPriceTriggerType := Value;
end;

procedure TAlertModel.SetStock(const Value: string);
begin
  fStock := Value;
end;

procedure TAlertModel.SetVolume(const Value: single);
begin
  FVolume := Value;
end;

//procedure TAlertModel.SetVolumeTrigger(const Value: TVolumeTrigger);
//begin
//  FVolumeTrigger := Value;
//end;

//{ TVolumeTrigger }
//
//function TVolumeTrigger.GetDescription: string;
//begin
//
//end;
//
//procedure TVolumeTrigger.SetLogic(const Value: TLogicType);
//begin
//  FLogic := Value;
//end;
//
//procedure TVolumeTrigger.SetVolume(const Value: single);
//begin
//  FVolume := Value;
//end;
//
//function TVolumeTrigger.ToString: string;
//begin
//  if FLogic <> TLogicType.None then
//  begin
//    result := ReplaceStr(GetEnumName(TypeInfo(TLogicType), integer(FLogic)), 'Logic', string.Empty).Trim;
//
//    result := result +' when volume is at least ' + FloatToStr(FVolume);
//  end;
//end;

{ TPriceTrigger }

//function TPriceTrigger.GetDescription: string;
//begin
//  result := ToString;
//end;
//
//procedure TPriceTrigger.SetPrice(const Value: single);
//begin
//  FPrice := Value;
//end;
//
//procedure TPriceTrigger.SetPriceTriggerType(const Value: TPriceTriggerType);
//begin
//  FPriceTriggerType := Value;
//end;
//
//function TPriceTrigger.ToString: string;
//begin
//  result := 'Trigger alert when the price is ';
//  if PriceTriggerType = TPriceTriggerType.BelowEqual then
//    result := result + 'Below/Equal'
//  else
//  if PriceTriggerType = TPriceTriggerType.AboveEqual then
//    result := result + 'Above/Equal'
//  else
//    result := result + GetEnumName(TypeInfo(TPriceTriggerType), integer(FPriceTriggerType));
//  result := result + ' ' + FloatToStr(FPrice);
//end;

{ TStockHeaderModel }

constructor TStockHeaderModel.Create;
begin
  fSymbol := '';
  fFiftyTwoWeekLow := 0;
  fTotalVolume := 0;
  fTotalValue := 0;
  fChangeClose := 0;
  fCurrentPE := 0;
  fLastTradedDate := 0;
  fPreviousClose := 0;
  fFiftyTwoWeekHigh := 0;
  fIntradayLow := 0;
  fLastTradedPrice := 0;
  fAvgPrice := 0;
  fIntradayOpen := 0;
  fIntradayHigh := 0;
  fChangeClosePercentage := 0;
end;

destructor TStockHeaderModel.Destroy;
begin

  inherited;
end;

end.
