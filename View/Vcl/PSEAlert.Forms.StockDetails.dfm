object frmStockDetails: TfrmStockDetails
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'frmStockDetails'
  ClientHeight = 177
  ClientWidth = 577
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lblLastUpdateDateTime: TLabel
    Left = 8
    Top = 8
    Width = 28
    Height = 13
    Caption = 'As of '
  end
  object Label1: TLabel
    Left = 8
    Top = 40
    Width = 81
    Height = 13
    Caption = 'Last Trade Price:'
  end
  object Label2: TLabel
    Left = 8
    Top = 59
    Width = 41
    Height = 13
    Caption = 'Change:'
  end
  object Label3: TLabel
    Left = 8
    Top = 78
    Width = 55
    Height = 13
    Caption = '% Change:'
  end
  object Label4: TLabel
    Left = 8
    Top = 97
    Width = 30
    Height = 13
    Caption = 'Value:'
  end
  object Label5: TLabel
    Left = 8
    Top = 116
    Width = 38
    Height = 13
    Caption = 'Volume:'
  end
  object Label6: TLabel
    Left = 208
    Top = 40
    Width = 30
    Height = 13
    Caption = 'Open:'
  end
  object Label7: TLabel
    Left = 208
    Top = 59
    Width = 25
    Height = 13
    Caption = 'High:'
  end
  object Label8: TLabel
    Left = 208
    Top = 78
    Width = 23
    Height = 13
    Caption = 'Low:'
  end
  object Label9: TLabel
    Left = 208
    Top = 97
    Width = 53
    Height = 13
    Caption = 'Avg. Price:'
  end
  object Label10: TLabel
    Left = 368
    Top = 40
    Width = 74
    Height = 13
    Caption = 'Previous Close:'
  end
  object Label11: TLabel
    Left = 368
    Top = 59
    Width = 48
    Height = 13
    Caption = 'P/E Ratio:'
  end
  object Label12: TLabel
    Left = 368
    Top = 78
    Width = 70
    Height = 13
    Caption = '52 Week High:'
  end
  object Label13: TLabel
    Left = 368
    Top = 97
    Width = 68
    Height = 13
    Caption = '52 Week Low:'
  end
  object Button1: TButton
    Left = 203
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Create Alert'
    TabOrder = 0
  end
  object Button2: TButton
    Left = 284
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 1
    OnClick = Button2Click
  end
end
