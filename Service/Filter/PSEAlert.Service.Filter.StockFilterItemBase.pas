unit PSEAlert.Service.Filter.StockFilterItemBase;

interface

uses
  Generics.Collections,
  PSE.Data.Model;

type
  IStockFilterItem = interface
    ['{DAC07C91-0CC7-4818-804B-6983931D083C}']

    procedure Run(aResult: TList<TStockAttribute>);

    function GetDescription: string;
    property Description: string read GetDescription;
  end;

  TStockFilterItemBase = class(TInterfacedObject, IStockFilterItem)
  protected
    function GetDescription: string; virtual; abstract;
  public
    procedure Run(aResult: TList<TStockAttribute>); virtual; abstract;
    property Description: string read GetDescription;
  end;


implementation

end.
