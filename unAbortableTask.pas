unit unAbortableTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  AbortableTask.Types;

type
  TfmMain = class(TForm, IAbortableProgressIndicator<Integer>)
    pnTop: TPanel;
    btTaskStart: TButton;
    ScrollBox: TScrollBox;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btTaskStartClick(Sender: TObject);
  private
    fAbortableAsyncTaskList: IAbortableTaskAsyncRunnerList;
    fFrameCounter: Integer;
    procedure ProgressBegin(const aKey: Integer; const aMaxWorkCount: Int64);
    procedure ProgressEnd(const aKey: Integer);
    procedure ProgressStep(const aKey: Integer; const aWorkCount: Int64);
  public
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses System.IOUtils, unFraTask, AbortableTask.Async.RunnerList, AbortableTask.Async.Runner, ExampleTask;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  fAbortableAsyncTaskList := TAbortableTaskAsyncRunnerList.Create;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  fAbortableAsyncTaskList := nil;
end;

procedure TfmMain.btTaskStartClick(Sender: TObject);
begin
  Inc(fFrameCounter);
  var lFrame := TfraTask.Create(Self);
  lFrame.Name := 'Frame_Task_' + IntToStr(fFrameCounter);
  lFrame.Parent := ScrollBox;
  lFrame.Align := TAlign.alTop;
  lFrame.Visible := True;

  var lTask: IAbortableTask<Integer, Integer> := TExampleTask.Create(fFrameCounter, lFrame);
  lFrame.NewTask(lTask, fAbortableAsyncTaskList);
end;

procedure TfmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if fAbortableAsyncTaskList.Count > 0 then
  begin
    if MessageDlg('Sollen die laufenden Downloads abgebrochen werden?', TMsgDlgType.mtConfirmation,
      mbYesNo, 0, TMsgDlgBtn.mbYes) = mrYes then
    begin
      if fAbortableAsyncTaskList.Count > 0 then
      begin
        fAbortableAsyncTaskList.RequestAbortToAllAndWait;
      end;
    end
    else
    begin
      CanClose := False;
    end;
  end;
end;

procedure TfmMain.ProgressBegin(const aKey: Integer; const aMaxWorkCount: Int64);
begin
end;

procedure TfmMain.ProgressEnd(const aKey: Integer);
begin
end;

procedure TfmMain.ProgressStep(const aKey: Integer; const aWorkCount: Int64);
begin
end;

end.
