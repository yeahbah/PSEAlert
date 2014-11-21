unit PSEAlert.AlertForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  PSE.Data.Model;

type
  TfrmAlert = class(TForm)
    lblStockSymbol: TLabel;
    lblPriceTrigger: TLabel;
    lblVolumeTrigger: TLabel;
    BitBtn1: TBitBtn;
    btnOk: TButton;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
    fAlertModel: TAlertModel;
    Procedure WMWindowposChanging(Var msg: TWMWindowposChanging); message WM_WINDOWPOSCHANGING;
  public
    { Public declarations }
    property AlertModel: TAlertModel read fAlertModel write fAlertModel;
  end;

implementation

{$R *.dfm}

uses Yeahbah.Messaging, PSEAlert.Messages;

procedure TfrmAlert.BitBtn1Click(Sender: TObject);
begin
  MessengerInstance.SendMessage(TDismissAlertMessage.Create(fAlertModel));
  Close;
end;

procedure TfrmAlert.btnOkClick(Sender: TObject);
begin
  MessengerInstance.SendMessage(TAcknoledgeAlertMessage.Create(fAlertModel));
  Close;
end;

procedure TfrmAlert.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MessengerInstance.SendMessage(TAlertFormHasClosedMessage.Create(self));
  if fAlertModel <> nil then
    fAlertModel.Free;
  Action := caFree;
end;

procedure TfrmAlert.FormCreate(Sender: TObject);
begin
  SetWindowPos(handle, hwnd_TopMost,0,0,0,0, swp_NoMove or swp_NoSize)
end;

procedure TfrmAlert.Timer1Timer(Sender: TObject);
begin
  Timer2.Enabled := true;
  Timer1.Enabled := false;
end;

procedure TfrmAlert.Timer2Timer(Sender: TObject);
begin
  AlphaBlendValue := AlphaBlendValue - 5;
  if AlphaBlendValue <= 0 then
    btnOk.Click;
end;

procedure TfrmAlert.WMWindowposChanging(var msg: TWMWindowposChanging);
begin
  With msg.Windowpos^ Do
  Begin
      If (flags and SWP_NOZORDER) = 0 Then Begin
        hwndInsertAfter := HWND_TOPMOST;
       flags := flags or SWP_NOACTIVATE;
      End;
  End;
  inherited;
end;

end.
