unit PSE.Data.Repository;

interface

uses
  Spring.Collections,
  Spring.Persistence.Core.Session,
  Spring.Persistence.Core.Repository.Simple,
  PSE.Data.Model,
  SysUtils;

type
  TStocksRepository = class(TSimpleRepository<TStockModel, string>)
  public
    procedure MakeFavorite(const aStockSymbol: string);
    procedure UnFavorite(const aStockSymbol: string);
    function GetAllStocks: IList<TStockModel>; overload;
    function GetAllStocks(const aExcludeIndeces: boolean): IList<TStockModel>; overload;
    function GetFavoriteStocks: IList<TStockModel>;
  end;

  TStockAlertRepository = class(TSimpleRepository<TAlertModel, string>)
  public
    procedure AcknowledgeAlert(const aAlertModel: TAlertModel);
    procedure DeleteStockAlert(const aStockSymbol: string); overload;
    procedure DeleteStockAlert(const aId: integer); overload;
    function GetStockAlerts: IList<TAlertModel>;
  end;

  TStockAttributeRepository = class(TSimpleRepository<TStockAttribute, string>)
  public
    procedure SaveNewAttribute(const aSymbol: string; const aAttrKey: string;
      const aAttrValue: string; const aAttrType: string; const aAttrDisplayText: string);
    procedure Update(const aStockAttr: TStockAttribute);
    procedure DeleteAll;
  end;

var
  stockRepository: TStocksRepository;
  stockAlertRepository: TStockAlertRepository;
  stockAttributeRepository: TStockAttributeRepository;

implementation

uses
  PSE.Data, Spring.Persistence.Criteria.Interfaces,
  Spring.Persistence.Criteria.Restrictions;

{ TStocksRepository }

function TStocksRepository.GetAllStocks: IList<TStockModel>;
begin
  result := PSEAlertDb.Session.GetList<TStockModel>('SELECT * FROM STOCKS', []);
end;

function TStocksRepository.GetAllStocks(
  const aExcludeIndeces: boolean): IList<TStockModel>;
begin
  if aExcludeIndeces then
    result := PSEAlertDb.Session.GetList<TStockModel>('SELECT * FROM STOCKS WHERE SYMBOL LIKE :0', ['^%'])
  else
    result := GetAllStocks;
end;

function TStocksRepository.GetFavoriteStocks: IList<TStockModel>;
begin
  result := PSEAlertDb.Session.GetList<TStockModel>('SELECT * FROM STOCKS WHERE ISFAVORITE = :0 ORDER BY SYMBOL', [1]);
end;

procedure TStocksRepository.MakeFavorite(const aStockSymbol: string);
begin
  PSEAlertDb.Session.Execute('UPDATE STOCKS SET ISFAVORITE = 1 WHERE SYMBOL = :0', [aStockSymbol]);
end;

procedure TStocksRepository.UnFavorite(const aStockSymbol: string);
begin
  PSEAlertDb.Session.Execute('UPDATE STOCKS SET ISFAVORITE = 0 WHERE SYMBOL = :0', [aStockSymbol]);
end;

{ TStockAlertRepository }

procedure TStockAlertRepository.AcknowledgeAlert(const aAlertModel: TAlertModel);
begin
  PSEAlertDb.Session.Execute('UPDATE ALERTS SET ALERT_COUNT = :0 WHERE SYMBOL = :1',
          [aAlertModel.AlertCount.ToString, aAlertModel.StockSymbol]);
end;

procedure TStockAlertRepository.DeleteStockAlert(const aStockSymbol: string);
begin
  PSEAlertDb.Session.Execute('DELETE FROM ALERTS WHERE SYMBOL = :0', [aStockSymbol]);
end;

procedure TStockAlertRepository.DeleteStockAlert(const aId: integer);
begin
  PSEAlertDb.Session.Execute('DELETE FROM ALERTS WHERE ID = :0', [aId]);
end;

function TStockAlertRepository.GetStockAlerts: IList<TAlertModel>;
begin
  result := PSEAlertDb.Session.GetList<TAlertModel>('SELECT * FROM ALERTS', []);
end;

{ TStockAttributeRepository }

procedure TStockAttributeRepository.DeleteAll;
begin
  PSEAlertDb.Session.Execute('DELETE FROM STOCK_ATTRIBUTE', []);
end;

procedure TStockAttributeRepository.SaveNewAttribute(const aSymbol, aAttrKey,
  aAttrValue, aAttrType, aAttrDisplayText: string);
var
  stockAttrib: TStockAttribute;
begin
  stockAttrib := TStockAttribute.Create;
  try
    stockAttrib.Symbol := aSymbol;
    stockAttrib.AttributeKey := aAttrKey;
    stockAttrib.AttributeValue := aAttrValue;
    stockAttrib.AttributeType := aAttrType;
    stockAttrib.AttributeDisplayText := aAttrDisplayText;

    PSEAlertDb.Session.Insert(stockAttrib);
  finally
    stockAttrib.Free;
  end;
end;

procedure TStockAttributeRepository.Update(
  const aStockAttr: TStockAttribute);
var
  stockAttr: TStockAttribute;
  criteria: ICriteria<TStockAttribute>;
begin
  criteria := PSEAlertDb.Session.CreateCriteria<TStockAttribute>;
  criteria.Add(TRestrictions.Eq('SYMBOL', aStockAttr.Symbol));
  criteria.Add(TRestrictions.Eq('ATTR_KEY', aStockAttr.AttributeKey));

  stockAttr := criteria.ToList.SingleOrDefault(nil);
  if stockAttr <> nil then
  begin
    stockAttr.AttributeValue := aStockAttr.AttributeValue;
    PSEAlertDb.Session.Update(stockAttr);
  end;
end;

initialization
  stockRepository := TStocksRepository.Create(PSEAlertDb.Session);
  stockAlertRepository := TStockAlertRepository.Create(PSEAlertDb.Session);
  stockAttributeRepository := TStockAttributeRepository.Create(PSEAlertDb.Session);

end.
