unit PSE.Data.Repository;

interface

uses
  Spring.Collections,
  Spring.Persistence.Core.Session,
  Spring.Persistence.Core.Repository.Simple,
  PSE.Data.Model;

type
  TStocksRepository = class(TSimpleRepository<TStockModel, string>)
  public
    procedure MakeFavorite(const aStockSymbol: string);
    procedure UnFavorite(const aStockSymbol: string);
    function GetAllStocks: IList<TStockModel>;
  end;

var
  stockRepository: TStocksRepository;


implementation

uses PSE.Data;

{ TStocksRepository }

function TStocksRepository.GetAllStocks: IList<TStockModel>;
begin
  result := PSEAlertDb.Session.GetList<TStockModel>('SELECT * FROM STOCKS', []);
end;

procedure TStocksRepository.MakeFavorite(const aStockSymbol: string);
begin
  PSEAlertDb.Session.Execute('UPDATE STOCKS SET ISFAVORITE = 1 WHERE SYMBOL = :0', [aStockSymbol]);
end;

procedure TStocksRepository.UnFavorite(const aStockSymbol: string);
begin
  PSEAlertDb.Session.Execute('UPDATE STOCKS SET ISFAVORITE = 0 WHERE SYMBOL = :0', [aStockSymbol]);
end;

initialization
  stockRepository := TStocksRepository.Create(PSEAlertDb.Session);

end.
