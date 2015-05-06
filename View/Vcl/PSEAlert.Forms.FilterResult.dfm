object frmFilterResult: TfrmFilterResult
  Left = 0
  Top = 0
  Caption = 'Filter Result'
  ClientHeight = 300
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  DesignSize = (
    635
    300)
  PixelsPerInch = 96
  TextHeight = 13
  object gridResult: TStringGrid
    Left = 8
    Top = 8
    Width = 619
    Height = 284
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsNone
    ColCount = 1
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 0
  end
end
