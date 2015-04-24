object frmAlert: TfrmAlert
  Left = 0
  Top = 0
  AlphaBlend = True
  BorderStyle = bsDialog
  ClientHeight = 99
  ClientWidth = 205
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object lblStockSymbol: TLabel
    Left = 6
    Top = 6
    Width = 143
    Height = 14
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Caption = 'Alert Triggered for %s!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblPriceTrigger: TLabel
    Left = 6
    Top = 25
    Width = 61
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Caption = 'lblPriceTrigger'
  end
  object lblVolumeTrigger: TLabel
    Left = 6
    Top = 40
    Width = 74
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Caption = 'lblVolumeTrigger'
  end
  object lblNote: TLabel
    Left = 6
    Top = 55
    Width = 31
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Caption = 'lblNote'
  end
  object BitBtn1: TBitBtn
    Left = 51
    Top = 76
    Width = 53
    Height = 18
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Dismiss'
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object btnOk: TButton
    Left = 108
    Top = 76
    Width = 53
    Height = 18
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Ok'
    TabOrder = 1
    OnClick = btnOkClick
  end
  object Timer1: TTimer
    Interval = 20000
    OnTimer = Timer1Timer
    Left = 248
    Top = 24
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 50
    OnTimer = Timer2Timer
    Left = 248
    Top = 80
  end
end
