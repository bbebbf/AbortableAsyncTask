object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'AbortableTaskApp'
  ClientHeight = 467
  ClientWidth = 751
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnTop: TPanel
    Left = 0
    Top = 0
    Width = 751
    Height = 57
    Align = alTop
    TabOrder = 0
    ExplicitLeft = 72
    ExplicitTop = 128
    ExplicitWidth = 473
    object btTaskStart: TButton
      Left = 16
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Task starten'
      TabOrder = 0
      OnClick = btTaskStartClick
    end
  end
  object ScrollBox: TScrollBox
    Left = 0
    Top = 57
    Width = 751
    Height = 410
    Align = alClient
    TabOrder = 1
    ExplicitTop = 47
  end
end
