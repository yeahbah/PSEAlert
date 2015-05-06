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
  PSEAlert.Service.Filter.StockFilterItemBase,
  ActnList,
  Classes;

type
  TPERatioFilterController = class(TBaseController<TStockFilterItemBase>)
  private
    [Bind('Description', 'Caption')]
    lblFilterDescription: TLabel;
    [Bind]
    actClose: TAction;
    [Bind('FromPE', 'Text')]
    edtPEFrom: TEdit;
    [Bind('ToPE', 'Text')]
    edtPETo: TEdit;
  protected
    procedure Initialize; override;
    procedure ExecuteCloseAction(Sender: TObject);
    procedure EditChange(Sender: TObject);
  end;

function CreatePERatioFilterController(aOwner: TWinControl; aFilter: TStockFilterItemBase): IController<TStockFilterItemBase>;

implementation

uses PSEAlert.Service.View.PERatioFilter, Yeahbah.Messaging, PSEAlert.Messages;

function CreatePERatioFilterController(aOwner: TWinControl; aFilter: TStockFilterItemBase): IController<TStockFilterItemBase>;
begin
  TControllerFactory<TStockFilterItemBase>.RegisterFactoryMethod(TframePERatioFilter,
    function: IController<TStockFilterItemBase>
    var
      frame: TframePERatioFilter;
    begin
      frame := TframePERatioFilter.Create(aOwner);
      frame.Align := {$IFDEF FMXAPP}TAlignLayout.Client{$ELSE}alTop{$ENDIF};
      frame.Parent := aOwner;
      result := TPERatioFilterController.Create(aFilter, frame);

      frame.Visible := true;
    end);
  result := TControllerfactory<TStockFilterItemBase>.GetInstance(TframePERatioFilter);
end;

{ TPERatioFilterController }

procedure TPERatioFilterController.EditChange(Sender: TObject);
begin
  UpdateSources;
end;

procedure TPERatioFilterController.ExecuteCloseAction(Sender: TObject);
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

procedure TPERatioFilterController.Initialize;
begin
  inherited;
  actClose.OnExecute := ExecuteCloseAction;
  edtPEFrom.OnChange := EditChange;
  edtPETo.OnChange := EditChange;
  UpdateTargets;
end;

end.
