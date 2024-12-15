object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'fmMain'
  ClientHeight = 402
  ClientWidth = 771
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  TextHeight = 15
  object ProgressBar: TProgressBar
    Left = 56
    Top = 144
    Width = 657
    Height = 33
    TabOrder = 0
  end
  object btTaskStart: TButton
    Left = 344
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Task starten'
    TabOrder = 1
    OnClick = btTaskStartClick
  end
  object btRequestAbort: TButton
    Left = 344
    Top = 208
    Width = 75
    Height = 25
    Caption = 'Abbrechen'
    TabOrder = 2
    OnClick = btRequestAbortClick
  end
end
