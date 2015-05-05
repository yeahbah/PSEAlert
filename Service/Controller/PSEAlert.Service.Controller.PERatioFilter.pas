unit PSEAlert.Service.Controller.PERatioFilter;

interface

uses
  Controller.Base,
  SvBindings,
  Generics.Collections,
  PSE.Data.Model,
  Forms,
  Controls,
  StdCtrls,
  PSEAlert.Service.Filter.StockFilterItemBase;

type
  TPERatioFilterController = class(TBaseController<TStockFilterItemBase>)
  private
    [Bind('Description', 'Caption')]
    lblFilterDescription: TLabel;
  protected
    procedure Initialize; override;
  end;

function CreatePERatioFilterController(aOwner: TWinControl; aFilter: TStockFilterItemBase): IController<TStockFilterItemBase>;


implementation

uses PSEAlert.Service.View.PERatioFilter;

function CreatePERatioFilterController(aOwner: TWinControl; aFilter: TStockFilterItemBase): IController<TStockFilterItemBase>;
begin
  TControllerFactory<TStockFilterItemBase>.RegisterFactoryMethod(TframePERatioFilter,
    function: IController<TStockFilterItemBase>
    var
      frame: TframePERatioFilter;
    begin
      frame := TframePERatioFilter.Create(Application);
      frame.Align := {$IFDEF FMXAPP}TAlignLayout.Client{$ELSE}alClient{$ENDIF};
      frame.Parent := aOwner;
      result := TPERatioFilterController.Create(aFilter, frame);

      frame.Visible := true;
    end);
  result := TControllerfactory<TStockFilterItemBase>.GetInstance(TframePERatioFilter);
end;

{ TPERatioFilterController }

procedure TPERatioFilterController.Initialize;
begin
  inherited;

end;

end.
