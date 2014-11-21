object frmException: TfrmException
  Left = 0
  Top = 0
  Caption = 'Ooooops!'
  ClientHeight = 243
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    472
    243)
  PixelsPerInch = 96
  TextHeight = 13
  object StaticText1: TStaticText
    Left = 24
    Top = 8
    Width = 352
    Height = 17
    Caption = 
      'Let'#39's fix this error. Send the information below to yeahbah@outl' +
      'ook.com'
    TabOrder = 0
  end
  object memException: TMemo
    Left = 8
    Top = 31
    Width = 456
    Height = 204
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    TabOrder = 1
  end
end
