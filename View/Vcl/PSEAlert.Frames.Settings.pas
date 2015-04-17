unit PSEAlert.Frames.Settings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.ImageList;

type
  TframeSettings = class(TFrame)
    StaticText1: TStaticText;
    btnReloadData: TButton;
    Label1: TLabel;
    cmbInterval: TComboBox;
    chkPlaySound: TCheckBox;
    edtOpenWav: TButtonedEdit;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    ImageList1: TImageList;
    StaticText4: TStaticText;
    Label2: TLabel;
    cmbSkin: TComboBox;
    procedure cmbSkinChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses
  Vcl.Themes, PSEAlert.Settings;

{ TframeSettings }

procedure TframeSettings.cmbSkinChange(Sender: TObject);
begin
  TStyleManager.TrySetStyle(cmbSkin.Text);
  PSEAlertSettings.Skin := cmbSkin.Text;
end;

constructor TframeSettings.Create(aOwner: TComponent);
var
  i: integer;
begin
  inherited;
  for i := 0 to ControlCount - 1 do
  begin
    if Controls[i] is TLabel then
      TLabel(Controls[i]).ParentFont := true;
    if Controls[i] is TEdit then
      TEdit(Controls[i]).ParentFont := true;
    if Controls[i] is TComboBox then
      TComboBox(Controls[i]).ParentFont := true;
    if Controls[i] is TMemo then
      TMemo(Controls[i]).ParentFont := true;

    if Controls[i] is TCheckBox then
      TCheckBox(Controls[i]).ParentFont := true;
    if Controls[i] is TButton then
      TButton(Controls[i]).ParentFont := true;
    if Controls[i] is TButtonedEdit then
      TButtonedEdit(Controls[i]).ParentFont := true;

    if Controls[i] is TStaticText then
      TStaticText(Controls[i]).ParentFont := true;
  end;

  Font.Size := 9;
  cmbSkin.ItemIndex := cmbSkin.Items.IndexOf(PSEAlertSettings.Skin);
end;

end.
