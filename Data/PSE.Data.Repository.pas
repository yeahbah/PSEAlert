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

var
  stockRepository: TStocksRepository;
  stockAlertRepository: TStockAlertRepository;


implementation

uses PSE.Data;

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
  result := PSEAlertDb.Session.GetList<TStockModel>('SELECT * FROM STOCKS WHERE ISFAVORITE = :0', [1]);
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

initialization
  stockRepository := TStocksRepository.Create(PSEAlertDb.Session);
  stockAlertRepository := TStockAlertRepository.Create(PSEAlertDb.Session);

end.
