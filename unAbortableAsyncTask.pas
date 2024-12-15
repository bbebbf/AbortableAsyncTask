unit unAbortableAsyncTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, AbortableAsyncTask, AbortableAsyncTask.Types, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfmMain = class(TForm, IAbortableAsyncTaskProgressIndicator)
    ProgressBar: TProgressBar;
    btTaskStart: TButton;
    btRequestAbort: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btTaskStartClick(Sender: TObject);
    procedure btRequestAbortClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    fAbortableAsyncTaskRunner: IAbortableAsyncTaskRunner;
    fRequestAbort: Boolean;
    procedure CloseForm(Sender: TObject);

    procedure ProgressBegin(const aMaxWorkCount: Int64);
    procedure ProgressEnd();
    procedure ProgressStep(const aWorkCount: Int64; var aAbortRequested: Boolean);
  public
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses ExampleTask;

procedure TfmMain.btRequestAbortClick(Sender: TObject);
begin
  fAbortableAsyncTaskRunner.AbortTask;
end;

procedure TfmMain.btTaskStartClick(Sender: TObject);
begin
  fRequestAbort := False;
  var lTask: IAbortableAsyncTask := TExampleTask.Create(Self);
  fAbortableAsyncTaskRunner := TAbortableAsyncTaskRunner.New(lTask);
end;

procedure TfmMain.CloseForm(Sender: TObject);
begin
  Close;
end;

procedure TfmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(fAbortableAsyncTaskRunner) then
  begin
    if fAbortableAsyncTaskRunner.IsRunning then
    begin
      CanClose := False;
      if MessageDlg('Soll der laufende Download abgebrochen werden?', TMsgDlgType.mtConfirmation,
        mbYesNo, 0, TMsgDlgBtn.mbYes) = mrYes then
      begin
        fAbortableAsyncTaskRunner.OnFinishedTask := CloseForm;
        fAbortableAsyncTaskRunner.AbortTask;
      end;
    end;
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  ProgressBar.Visible := False;
end;

procedure TfmMain.ProgressBegin(const aMaxWorkCount: Int64);
begin
  ProgressBar.Position := 0;
  ProgressBar.Min := 0;
  ProgressBar.Max := aMaxWorkCount;
  ProgressBar.Visible := True;
end;

procedure TfmMain.ProgressEnd;
begin
  ProgressBar.Position := 0;
  ProgressBar.Visible := False;
end;

procedure TfmMain.ProgressStep(const aWorkCount: Int64; var aAbortRequested: Boolean);
begin
  ProgressBar.Position := aWorkCount;
  aAbortRequested := fRequestAbort;
  fRequestAbort := False;
end;

end.
