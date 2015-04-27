unit PSEAlert.Controller.StockDetails;

interface

uses
  Controller.Base,
  SvBindings,
  ExtCtrls,
  Yeahbah.Messaging,
  ActnList,
  PSE.Data.Model,
  StdCtrls,
  SysUtils,
  Classes;

type
  TStockDetailsController = class(TBaseController<TStockHeaderModel>, IMessageReceiver)
  private
    [Bind]
    lblLastUpdateDateTime: TLabel;
  protected
    procedure Initialize; override;
    procedure Receive(const aMessage: IMessage);
  end;

function CreateStockDetailsController(aOwner: TComponent; aModel: TStockHeaderModel): IController<TStockHeaderModel>;

implementation

uses PSEAlert.Forms.StockDetails, Forms, PSEAlert.Messages;

function CreateStockDetailsController(aOwner: TComponent; aModel: TStockHeaderModel): IController<TStockHeaderModel>;
begin
  TControllerFactory<TStockHeaderModel>.RegisterFactoryMethod(TfrmStockDetails,
    function: IController<TStockHeaderModel>
    var
      frm: TfrmStockDetails;
    begin
      frm := TfrmStockDetails.Create(aOwner);

      result := TStockDetailsController.Create(aModel, frm);
      frm.Caption := aModel.Symbol;
      frm.Show;
    end);
  result := TControllerFactory<TStockHeaderModel>.GetInstance(TfrmStockDetails);
end;

{ TStockDetailsController }

procedure TStockDetailsController.Initialize;
begin
  inherited;
  MessengerInstance.RegisterReceiver(self, TAfterDownloadMessage);
end;

procedure TStockDetailsController.Receive(const aMessage: IMessage);
begin
  if aMessage is TAfterDownloadMessage then
  begin
    if (aMessage as TAfterDownloadMessage).Data > 0 then
      lblLastUpdateDateTime.Caption := 'As of ' + DateTimeToStr((aMessage as TAfterDownloadMessage).Data)
    else
      lblLastUpdateDateTime.Caption := 'Market Pre-Open';
  end;
end;

end.
