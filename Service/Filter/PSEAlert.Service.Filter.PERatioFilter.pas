unit PSEAlert.Service.Filter.PERatioFilter;

interface

uses
  PSEAlert.Service.Filter.StockFilterItemBase,
  PSE.Data.Model,
  Classes,
  Generics.Collections;

type
  TPERatioFilter = class(TStockFilterItemBase)
  private
    function GetDescription: string; override;
  public
    procedure Run(aResult: TList<TStockAttribute>);
    property Description: string read GetDescription;
  end;

implementation

{ TPERatioFilter }

function TPERatioFilter.GetDescription: string;
begin
  result := 'P/E Ratio';
end;

procedure TPERatioFilter.Run(aResult: TList<TStockAttribute>);
begin

end;

end.
