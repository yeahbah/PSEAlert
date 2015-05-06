unit PSEAlert.Service.Controller.SharePriceFilter;

interface

uses
  Controller.Base,
  SvBindings,
  Generics.Collections,
  PSE.Data.Model,
  Forms,
  Controls,
  StdCtrls,
  PSEAlert.Service.Filter.StockFilterItemBase,
  ActnList,
  Classes;

type
  TSharePriceFilterController = class(TBaseController<TStockFilterItemBase>)
  private
    [Bind('Description', 'Caption')]
    lblFilterDescription: TLabel;
    [Bind]
    actClose: TAction;
    [Bind('FromPrice', 'Text')]
    edtFromPrice: TEdit;
    [Bind('ToPrice', 'Text')]
    edtToPrice: TEdit;
  protected
    procedure Initialize; override;
    procedure ExecuteCloseAction(Sender: TObject);
    procedure EditChange(Sender: TObject);
  end;

function CreateSharePriceFilterController(aOwner: TWinControl; aFilter: TStockFilterItemBase): IController<TStockFilterItemBase>;

implementation

uses PSEAlert.Service.View.SharePriceFilter, PSEAlert.Messages,
  Yeahbah.Messaging;

function CreateSharePriceFilterController(aOwner: TWinControl; aFilter: TStockFilterItemBase): IController<TStockFilterItemBase>;
begin
  TControllerFactory<TStockFilterItemBase>.RegisterFactoryMethod(TframeSharePriceFilter,
    function: IController<TStockFilterItemBase>
    var
      frame: TframeSharePriceFilter;
    begin
      frame := TframeSharePriceFilter.Create(aOwner);
      frame.Align := {$IFDEF FMXAPP}TAlignLayout.Client{$ELSE}alTop{$ENDIF};
      frame.Parent := aOwner;
      result := TSharePriceFilterController.Create(aFilter, frame);

      frame.Visible := true;
    end);
  result := TControllerfactory<TStockFilterItemBase>.GetInstance(TframeSharePriceFilter);
end;

{ TSharePriceFilterController }

procedure TSharePriceFilterController.EditChange(Sender: TObject);
begin
  UpdateSources;
end;

procedure TSharePriceFilterController.ExecuteCloseAction(Sender: TObject);
var
  p: TWinControl;
begin
  p := (Sender as TComponent).Owner as TWinControl;
  try
    p.Parent.RemoveControl(p);
    MessengerInstance.SendMessage(TCloseFilterMessage.Create(Model.Description));
  finally
    p.Free;
  end;

end;

procedure TSharePriceFilterController.Initialize;
begin
  inherited;
  actClose.OnExecute := ExecuteCloseAction;
  UpdateTargets;
  edtFromPrice.OnChange := EditChange;
  edtToPrice.OnChange := EditChange;
end;

end.
