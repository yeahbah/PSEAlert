unit PSEAlert.Service.StockFilterService;

interface

uses
  Controller.Base,
  Generics.Collections,
  SysUtils,
  PSE.Data.Model,
  PSEAlert.Service.Filter.StockFilterItemBase,
  Controls;

type
  TFilterControllerMethod = TFunc<TWinControl, TStockFilterItemBase, IController<TStockFilterItemBase>>;
  IStockFilterService = interface
    ['{F3E017FC-5592-4FFA-9D46-7FF21B6FE9DC}']
    procedure RegisterFilter(const aFilterItem: TStockFilterItemBase;
      const aFilterControllerMethod: TFilterControllerMethod);
    procedure Run(aResult: TList<TStockAttribute>);
    function GetStockFilters: TDictionary<TStockFilterItemBase, TFilterControllerMethod>;
    property StockFilters: TDictionary<TStockFilterItemBase, TFilterControllerMethod> read GetStockFilters;
  end;

  TStockFilterService = class(TInterfacedObject, IStockFilterService)
  private
    fStockFilters: TDictionary<TStockFilterItemBase, TFilterControllerMethod>;
    function GetStockFilters: TDictionary<TStockFilterItemBase, TFilterControllerMethod>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterFilter(const aFilterItem: TStockFilterItemBase;
      const aFilterControllerMethod: TFilterControllerMethod);
    procedure Run(aResult: TList<TStockAttribute>);
    property StockFilters: TDictionary<TStockFilterItemBase, TFilterControllerMethod> read GetStockFilters;
  end;

var
  StockFilterService: TStockFilterService;

implementation

uses PSEAlert.Service.Filter.PERatioFilter,
  PSEAlert.Service.Controller.PERatioFilter,
  PSEAlert.Service.Controller.SharePriceFilter,
  PSEAlert.Service.Filter.SharePriceFilter, Spring.Container;

procedure RegisterStockFilters;
begin
  StockFilterService.RegisterFilter(TPERatioFilter.Create,
    CreatePERatioFilterController);

  StockFilterService.RegisterFilter(TSharePriceFilter.Create,
    CreateSharePriceFilterController);
end;

{ TStockFilterService }

constructor TStockFilterService.Create;
begin
  fStockFilters := TDictionary<TStockFilterItemBase, TFilterControllerMethod>.Create;
end;

destructor TStockFilterService.Destroy;
begin
  fStockFilters.Free;
  inherited;
end;

function TStockFilterService.GetStockFilters: TDictionary<TStockFilterItemBase, TFilterControllerMethod>;
begin
  result := fStockFilters;
end;

procedure TStockFilterService.RegisterFilter(
  const aFilterItem: TStockFilterItemBase; const aFilterControllerMethod: TFilterControllerMethod);
begin
  fStockFilters.Add(aFilterItem, aFilterControllerMethod);
end;

procedure TStockFilterService.Run(aResult: TList<TStockAttribute>);
//var
//  stockFilter: IStockFilterItem;
//  filterResult: TList<TStockAttribute>;
begin
//  filterResult := TList<TStockAttribute>.Create;
//  try
//    for stockFilter in fStockFilters do
//    begin
//      filterResult.Clear;
//      stockFilter.Run(filterResult);
//      aResult.AddRange(filterResult.ToArray);
//    end;
//  finally
//    filterResult.Free;
//  end;

end;

initialization
  StockFilterService := TStockFilterService.Create;
  RegisterStockFilters;

finalization
  StockFilterService.Free;


end.
