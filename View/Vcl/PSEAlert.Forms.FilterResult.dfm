object frmFilterResult: TfrmFilterResult
  Left = 0
  Top = 0
  Caption = 'Filter Result'
  ClientHeight = 375
  ClientWidth = 794
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  DesignSize = (
    794
    375)
  PixelsPerInch = 120
  TextHeight = 19
  object gridResult: TStringGrid
    Left = 10
    Top = 10
    Width = 774
    Height = 355
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsNone
    ColCount = 1
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 0
  end
end
