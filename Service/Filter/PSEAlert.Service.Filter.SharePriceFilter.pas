unit PSEAlert.Service.Filter.SharePriceFilter;

interface

uses
  PSEAlert.Service.Filter.StockFilterItemBase,
  PSE.Data.Model,
  Classes,
  Generics.Collections;

type
  TSharePriceFilter = class(TStockFilterItemBase)
  private
    fToPE: single;
    fFromPE: single;
    fToPrice: single;
    fFromPrice: single;
    function GetDescription: string; override;
  public
    constructor Create;
    procedure Run(aResult: TList<TStockAttribute>); override;
    property Description: string read GetDescription;
    property FromPrice: single read fFromPrice write fFromPrice;
    property ToPrice: single read fToPrice write fToPrice;
  end;

implementation

{ TSharePriceFilter }

uses Yeahbah.GenericQuery, SysUtils;

constructor TSharePriceFilter.Create;
begin
  fFromPrice := 100;
  fToPrice := 1000;
end;

function TSharePriceFilter.GetDescription: string;
begin
  result := 'Share Price';
end;

procedure TSharePriceFilter.Run(aResult: TList<TStockAttribute>);
var
  stocks, tmp: TList<TStockAttribute>;
begin
  stocks := TGenericQuery<TStockAttribute>.From(aResult)
    .Where(
      function(s: TStockAttribute): boolean
      begin
        result := s.AttributeKey = 'LastTradedPrice';
        result := result and (StrToFloat(s.AttributeValue) >= fFromPrice);
        result := result and (StrToFloat(s.AttributeValue) <= fToPrice);
      end).ToList;

  tmp := TGenericQuery<TStockAttribute>.From(aResult)
    .Where(
      function (s: TStockAttribute): boolean
      begin
        result := TGenericQuery<TStockAttribute>.From(stocks)
          .Count(
            function (x: TStockAttribute): boolean
            begin
              result := x.Symbol = s.Symbol;
            end) > 0;
      end).ToList;

  aResult.Clear;
  aResult.AddRange(tmp.ToArray);

  stocks.Free;
  tmp.Free;
end;

end.
